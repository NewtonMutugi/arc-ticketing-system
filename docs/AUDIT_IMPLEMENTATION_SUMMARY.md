# Audit Trail System - Implementation Summary

## Overview
A comprehensive audit trail system has been implemented for the Arc Ticketing System to track all administrative actions including event creation, ticket creation, and payment approvals via Mpesa.

## Files Modified/Created

### 1. **Migrations** (3 files)
Located in `db/migrate/`

#### `20260329205326_add_admin_to_users.rb`
- Adds `admin: boolean` (default: false) to users table
- Allows role-based access control for admin features

#### `20260329205327_add_audit_references_to_trackable_models.rb`
- Adds `created_by_user_id` and `updated_by_user_id` to events
- Adds `created_by_user_id` and `updated_by_user_id` to tickets
- Adds `approved_by_user_id`, `approved_at`, and `approval_notes` to orders
- All include proper foreign key constraints and indexes

#### `20260329205328_create_audit_logs.rb`
- Creates `audit_logs` table with fields:
  - `user_id` - Admin who performed action
  - `action` - Type of action (created, updated, deleted, payment_approved, etc.)
  - `auditable_type` & `auditable_id` - Link to affected record (polymorphic)
  - `changes` - JSON of what changed
  - `status` - Result status (approved, rejected)
  - `reason` - Reason for action
  - `ip_address` - Admin's IP
  - `user_agent` - Admin's browser/device
  - Includes indexes for performance

### 2. **Models** (5 files)

#### `app/models/user.rb` ✏️ MODIFIED
- Added relationships:
  - `has_many :created_events`
  - `has_many :created_tickets`
  - `has_many :approved_orders`
  - `has_many :audit_logs`
- Added `admin?` helper method

#### `app/models/audit_log.rb` ✨ NEW
- Polymorphic model linking to any auditable record
- Enums for action types
- Scopes for filtering (recent, by_user, by_action, by_model)
- Class method `log_action` for creating audit entries
- Method `changes_hash` to parse JSON changes

#### `app/models/event.rb` ✏️ MODIFIED
- Added `include Auditable` concern
- Added relationships:
  - `belongs_to :user, foreign_key: "created_by_user_id"`
- Added `track_audit_on` for fields to track
- Added `created_by` helper method

#### `app/models/ticket.rb` ✏️ MODIFIED
- Added `include Auditable` concern
- Added relationships:
  - `belongs_to :user, foreign_key: "created_by_user_id"`
- Added `track_audit_on` for fields to track
- Added `created_by` helper method

#### `app/models/order.rb` ✏️ MODIFIED
- Added `include Auditable` concern
- Added relationships:
  - `belongs_to :user, foreign_key: "approved_by_user_id"`
- Added `track_audit_on` for status and payment fields
- Added `log_payment_approval` callback for payment tracking
- Added `approved_by` helper method
- Captures `approved_at` timestamp on approval/rejection

#### `app/models/current.rb` ✏️ MODIFIED
- Added attributes: `ip_address` and `user_agent`
- These are set by ApplicationController and used in audit logs

### 3. **Concerns** (1 file)

#### `app/models/concerns/auditable.rb` ✨ NEW
- Reusable concern for audit logging
- Automatically creates audit logs via `after_create`, `after_update`, `after_destroy`
- Tracks only specified attributes via `track_audit_on`
- Captures user, IP, and user agent from Current context
- Handles change tracking for updates
- Should be included in any model that needs auditing

### 4. **Controllers** (5 files)

#### `app/controllers/application_controller.rb` ✏️ MODIFIED
- Added `set_current_request_context` action
- Sets `Current.ip_address` and `Current.user_agent` before each request
- Runs as `before_action`

#### `app/controllers/admin/base_controller.rb` ✏️ MODIFIED
- Added `authorize_admin!` check
- Verifies `Current.user.admin?` before allowing access
- Redirects non-admins with alert message

#### `app/controllers/admin/events_controller.rb` ✏️ MODIFIED
- **create method**: Sets `created_by_user_id` to `Current.user.id` before save

#### `app/controllers/admin/tickets_controller.rb` ✏️ MODIFIED
- **create method**: Sets `created_by_user_id` to `Current.user.id` before save

#### `app/controllers/admin/orders_controller.rb` ✏️ MODIFIED
- **approve method**:
  - Sets `approved_by_user_id` to `Current.user.id`
  - Sets `approved_at` to `Time.current`
- **reject_payment method**:
  - Sets `approved_by_user_id` to `Current.user.id`
  - Captures rejection reason in `approval_notes`

#### `app/controllers/admin/audit_logs_controller.rb` ✨ NEW
- Displays audit logs with filtering
- Filters by: user, action, model type, date range
- Pagination using Pagy
- Show action for detailed view

### 5. **Documentation** (2 files)

#### `AUDIT_TRAIL_DOCS.md` ✨ NEW
- Comprehensive documentation with:
  - System overview
  - Database schema details
  - Usage examples with code
  - Query examples
  - Admin dashboard features
  - Security considerations
  - Future enhancements

#### `AUDIT_SETUP.md` ✨ NEW
- Quick start guide
- Setup instructions
- Troubleshooting
- Model relationships
- Example queries

## Key Features Implemented

### ✅ Admin Role Management
- Users must have `admin: true` to access admin features
- Protected via `authorize_admin!` in base controller
- Fallback auth checks in sessions controller

### ✅ Event Tracking
- Logs creation with creator ID and timestamp
- Tracks updates to: title, description, location, dates, publish status
- Logs deletion

### ✅ Ticket Tracking
- Logs creation with creator ID and timestamp
- Tracks updates to: title, description, price, quantity, status, benefits
- Logs deletion

### ✅ Payment Approval Tracking
- Logs when Mpesa payment is approved
  - Records approver, timestamp, IP address
  - Creates audit entry with action: `payment_approved`
- Logs when Mpesa payment is rejected
  - Records rejector, timestamp, IP address
  - Captures rejection reason in `approval_notes`
  - Creates audit entry with action: `payment_rejected`

### ✅ Context Capture
- IP address of admin captured with every action
- User agent (browser/device) captured with every action
- All timestamps automatic (created_at on audit logs)

## Database Changes Summary

```ruby
# Users Table
- admin: boolean (default: false)

# Events Table
- created_by_user_id: bigint
- updated_by_user_id: bigint
- Foreign key to users(id)

# Tickets Table
- created_by_user_id: bigint
- updated_by_user_id: bigint
- Foreign key to users(id)

# Orders Table
- approved_by_user_id: bigint
- approved_at: datetime
- approval_notes: text
- Foreign key to users(id)

# Audit Logs (NEW TABLE)
- id, user_id, action, auditable_type, auditable_id
- changes (JSON), status, reason
- ip_address, user_agent
- created_at, updated_at
```

## How to Use

### 1. Run Migrations
```bash
rails db:migrate
```

### 2. Promote Users to Admin
```ruby
user = User.find_by(email_address: "admin@example.com")
user.update(admin: true)
```

### 3. Access Audit Logs
- In browser: `/admin/audit_logs`
- Filter by user, action, model, date range

### 4. Query in Code
```ruby
# Who created an event?
event.created_by

# When was an order approved?
order.approved_at

# View all audit trail for an order
order.audit_logs

# Get all payment approvals by a user
AuditLog.where(user_id: user_id, action: :payment_approved)
```

## Security Considerations

✅ **Admin-Only Access**: Protected controller methods
✅ **IP Tracking**: Forensic evidence of who/where actions came from
✅ **User Agent**: Device/browser tracking
✅ **Immutable**: Audit logs should never be deleted (consider paranoia gem)
✅ **Reason Tracking**: Payment rejections require documented reason

## Testing

### Create Test Audit Entries
```ruby
# In Rails console
user = User.first
user.update(admin: true)

# Create event
event = Event.create(
  title: "Test",
  description: "Test event",
  created_by_user_id: user.id
)

# View audit logs
AuditLog.recent.first
```

## Performance Considerations

- Audit logs indexed by created_at for reports
- Indexed by auditable_type and auditable_id for specific records
- Indexed by user_id and action for filtering
- Consider archiving old logs periodically
- Pagination implemented for log viewers

## Future Enhancements

1. **Email Notifications**: Alert on payment approvals/rejections
2. **Export Reports**: CSV/PDF exports of audit trails
3. **Retention Policy**: Auto-delete logs after N days
4. **Advanced Analytics**: Dashboard with trends/patterns
5. **Role-based Access**: Different audit log views for different roles
6. **Real-time Alerts**: Notify on sensitive actions
7. **Blockchain Storage**: For compliance-critical logs

## Relationships Summary

```
User
├── admin: boolean
├── has_many :sessions
├── has_many :created_events (through created_by_user_id)
├── has_many :created_tickets (through created_by_user_id)
├── has_many :approved_orders (through approved_by_user_id)
└── has_many :audit_logs

Event
├── created_by_user_id → User
├── belongs_to :user (as creator)
├── has_many :audit_logs (polymorphic)
├── auditable_type: "Event"
└── Tracked fields: title, description, location, dates, publish

Ticket
├── created_by_user_id → User
├── belongs_to :user (as creator)
├── has_many :audit_logs (polymorphic)
├── auditable_type: "Ticket"
└── Tracked fields: title, price, quantity, status, benefits

Order
├── approved_by_user_id → User
├── approved_at: datetime
├── approval_notes: text
├── belongs_to :user (as approver)
├── has_many :audit_logs (polymorphic)
├── auditable_type: "Order"
└── Tracked fields: status, payment_reference, payment_provider

AuditLog
├── user_id → User (who did it)
├── auditable_type + auditable_id (what was affected)
├── action (created, updated, deleted, payment_approved, payment_rejected)
├── changes (JSON of what changed)
├── status (approved, rejected)
├── reason (why - for rejections)
├── ip_address (where from)
└── user_agent (what device)
```

## Deployment Checklist

- [ ] Run `rails db:migrate` on all environments
- [ ] Promote admin users: `User.update(admin: true)` where needed
- [ ] Verify audit logs appear: Visit `/admin/audit_logs`
- [ ] Test payment approval tracking
- [ ] Test payment rejection tracking
- [ ] Monitor performance with large audit log table
- [ ] Set up log rotation/archival policy

## Support

For detailed documentation and examples, see:
- [AUDIT_TRAIL_DOCS.md](./AUDIT_TRAIL_DOCS.md)
- [AUDIT_SETUP.md](./AUDIT_SETUP.md)

Or check code examples in:
- [User Model](./app/models/user.rb)
- [AuditLog Model](./app/models/audit_log.rb)
- [Auditable Concern](./app/models/concerns/auditable.rb)
