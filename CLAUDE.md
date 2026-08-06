# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

ARC Events System — a Rails 8 app for publishing events, selling tickets, and processing attendee orders, with M-Pesa (STK Push) and PayPal payment integrations. Public storefront + an admin back office.

Stack: Ruby 3.4.3, Rails 8.1, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS, ViewComponent, Pundit, Solid Queue/Cache/Cable, Prawn (PDF tickets) + RQRCode.

## Commands

```bash
bin/setup                 # install deps, prepare db, start server (--skip-server to skip)
bin/dev                    # start Rails server + Tailwind watcher (Procfile.dev)
bin/rails db:prepare       # create/migrate db
bin/rails db:seed

bin/rails test                                   # full test suite (Minitest)
bin/rails test test/models/order_test.rb          # single file
bin/rails test test/models/order_test.rb:23       # single test at line
bin/rails test:system                             # Capybara/Selenium system tests

bin/rubocop                # lint (rubocop-rails-omakase house style)
bin/brakeman               # security static analysis
```

No JS test runner or bundler build step is configured — importmap-rails serves JS directly; Tailwind is compiled via `tailwindcss-rails`/`bin/dev`.

## Architecture

### Two front ends, one controller tree

`config/routes.rb` splits into `scope module: :public` (storefront: `Public::EventsController`, `Public::OrdersController`) and `namespace :admin` (back office). Almost every admin controller inherits from `Admin::BaseController`, which:
- Requires an authenticated `Current.user` (redirects to `admin_new_session_path` otherwise).
- Includes `Pundit::Authorization` with `pundit_user` = `Current.user`; policies live in `app/policies/*_policy.rb` (`ApplicationPolicy` defaults: `create?`/`destroy?` → admin only, `update?` → admin or editor).
- Picks a layout per action (`event_dashboard` for show/edit/update, otherwise `dashboard`).

Session/auth machinery is in `app/controllers/concerns/authentication.rb` (included by `ApplicationController`) plus `Current` (`app/models/current.rb`, an `ActiveSupport::CurrentAttributes`) and the `Session` model — sessions are cookie-based (`cookies.signed[:session_id]`), not Rails' built-in `session[]`, and expire via `Setting.session_timeout`.

### Users, roles, and settings

`User` has a `role` enum (`viewer: 0, editor: 1, admin: 2`); `ApplicationPolicy` gates `create?`/`destroy?` to admin only and `update?` to admin-or-editor. Admin user management is folded into `Admin::SettingsController#show` (lists all users) rather than having its own index — `Admin::UsersController` only has `create`/`edit`/`update`/`destroy`, all redirecting back to `admin_settings_path`. `update` supports both classic HTML redirects and turbo-stream responses (replaces the `user_#{id}` row partial, closes the role-edit modal, appends a `ToastComponent` flash). New users get a random password plus a `PasswordsMailer.reset` email rather than a set-your-own-password flow at creation. Runtime-tunable settings (`mpesa_mode`, `mpesa_business_number`, `session_timeout`) live on the `Setting` model/table, not `Rails.application.config` or credentials.

### Order lifecycle

`Order` (`app/models/order.rb`) is the core state machine: `draft → submitted → paid|failed` (+ `refunded`), via the `status` enum.
- `draft`: created by `Public::OrdersController#create` from cart params; safe to auto-delete after 5 days (`Orders::CleanupPendingJob`).
- `submitted`: buyer entered a manual payment reference, or an M-Pesa STK push was sent.
- `paid`: set either by an admin action, the `WebhooksController#mpesa` callback, or `PaypalController#capture_order`. An `after_update` callback (`generate_attendees`) auto-creates `Attendee` records from `order_items` the moment status flips to `paid`.
- Status changes are audited via `log_payment_approval` → `AuditLog`.

Buyer flow across `Public::OrdersController`: `new/create` (build order + `order_items`) → `attendees` (collect attendee details) → `confirm` (persist `Attendee`s in a transaction) → `checkout`/`pay` (choose M-Pesa or manual reference) → `status` (JSON polling endpoint).

### Payments

- **M-Pesa**: `MpesaService` (`app/services/mpesa_service.rb`) wraps the Safaricom Daraja API (OAuth token + STK Push) via Faraday. Sandbox vs production base URL/callback URL chosen from `Rails.env.production?`. Toggled by `Setting.mpesa_mode` (`"automated"` vs manual). Async result comes back on `POST /webhooks/mpesa` (`WebhooksController#mpesa`, CSRF-exempt), matched to an `Order` by `checkout_request_id`.
- **PayPal**: `PaypalController` (`create_order`/`capture_order`) talks directly to the PayPal REST API via Faraday, no service object. Both payment controllers render `ToastComponent` turbo-stream errors into a `flash-toasts` target rather than using classic flash for failure states.

### Auditing

`Auditable` concern (`app/models/concerns/auditable.rb`) is mixed into `Event`, `Ticket`, and `Order`. Call `track_audit_on :attr1, :attr2, ...` at the class level to auto-log `created`/`updated`/`deleted` into polymorphic `AuditLog` rows (`app/models/audit_log.rb`), attributed to `Current.user` (falls back to `User.first`). Order additionally logs `payment_approved`/`payment_rejected` explicitly via a separate `after_update` callback, not through `track_audit_on`.

### Tickets & PDFs

`TicketPdfGenerator` (`app/services/ticket_pdf_generator.rb`) renders one Prawn page per `Attendee` on a fixed-size event ticket (8.5"x2.5"), with a QR code (`RQRCode`) encoding a link to `admin/verify/:token` used by `Admin::VerificationsController` for door check-in. Ticket sales/revenue math (`tickets_sold`, `tickets_left`, `revenue`) lives on `Ticket`/`Event` models, scoped by `order.status`.

### UI components

`app/components/` holds ViewComponent classes (Button, Card, Dropdown, FileUpload, Input, Sidebar, Toast), each namespaced with matching `.html.erb` templates and nested subcomponents (e.g. `Sidebar::ItemComponent`, `Dropdown::ItemComponent`). Tests for these live in `test/components/`.

### Background jobs

`Orders::CleanupPendingJob` deletes stale draft orders (>5 days old); `Sessions::CleanupExpiredJob` deletes expired sessions. Both run on Solid Queue.
