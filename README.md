# ARC Events System

ARC Events System is a Ruby on Rails platform for publishing events, managing ticket sales, and processing attendee orders with integrated mobile and card payment workflows.

## 1. Project Title & Description

ARC Events System provides a public event storefront and an admin back office for managing events, tickets, attendees, payments, and order fulfillment.

### Tech Stack

- Ruby: 3.4.3
- Rails: 8.1.1 (Gemfile) / load defaults 8.0
- Database: PostgreSQL
- Frontend: Hotwire (Turbo + Stimulus), Tailwind CSS, ViewComponent
- Background and infrastructure: Solid Queue, Solid Cache, Solid Cable
- Integrations: M-Pesa, PayPal, Letter Opener (development)

## 2. Features

- Public event catalog with event detail pages.
- Ticket ordering flow with attendee capture and checkout states.
- Payment integrations for M-Pesa and PayPal.
- Admin dashboard for events, tickets, attendees, orders, transactions, and settings.
- Admin authentication, password flows, and profile management.
- Audit trail support for administrative actions.
- PDF and QR-code capabilities for communication and fulfillment workflows.

## 3. Prerequisites

Install the following before setup:

- Ruby 3.4.3
- Bundler
- PostgreSQL 16+ (or Docker to run PostgreSQL container)
- libvips (required by image_processing for Active Storage variants)
- Foreman (auto-installed by bin/dev if missing)

Optional for full local development and tests:

- Chrome/Chromium and compatible ChromeDriver for system tests
- Docker and Docker Compose

## 4. Installation & Setup

### 1. Clone and enter the project

```bash
git clone <your-repository-url>
cd arc-ticketing-system
```

### 2. Install gems

```bash
bundle install
```

### 3. Configure environment variables

```bash
cp .env.example .env
```

Fill in values in .env before running the app.

### 4. Start PostgreSQL

Option A: Local PostgreSQL service

Option B: Docker

```bash
docker compose up -d db
```

### 5. Prepare the database

```bash
bin/rails db:create
bin/rails db:migrate
```

Alternatively, run:

```bash
bin/rails db:prepare
```

### 6. Seed data (if needed)

```bash
bin/rails db:seed
```

Use seed data to bootstrap initial records such as admin-accessible data and sample entities.

### 7. One-command setup (optional)

```bash
bin/setup
```

bin/setup installs dependencies, prepares the database, clears temp files, and starts the dev server unless --skip-server is passed.

## 5. Environment Variables

Create a .env file using .env.example. The project expects values like the following:

### Database and Rails

- POSTGRES_HOST
- POSTGRES_USER
- POSTGRES_PASSWORD
- RAILS_MAX_THREADS
- RAILS_MASTER_KEY

### Deployment and registry

- VPS_IP
- KAMAL_REGISTRY_PASSWORD

### M-Pesa

- MPESA_CONSUMER_KEY
- MPESA_CONSUMER_SECRET
- MPESA_SHORTCODE
- MPESA_PASSKEY
- MPESA_CALLBACK_URL (default in example: http://localhost:3000/webhooks/mpesa)

### PayPal

- PAYPAL_CLIENT_ID
- PAYPAL_CLIENT_SECRET

## 6. Running the App

Recommended local startup:

```bash
bin/dev
```

This starts the Rails server and Tailwind watcher via Procfile.dev.

Default app URL:

- http://localhost:3000

Useful development endpoint:

- /letter_opener (development only)

## 7. Testing

This project uses Rails built-in test framework (Minitest).

Run the full test suite:

```bash
bin/rails test
```

Run system tests:

```bash
bin/rails test:system
```

If you use CI checks locally, you can also run lint/security tools included in the Gemfile (for example RuboCop and Brakeman).

## 8. Deployment

Deployment documentation will be added here.

Suggested structure for this section:

- Hosting target and architecture
- Required secrets and credentials
- Build and release steps
- Database migration strategy
- Rollback procedure
- Monitoring and health checks

## 9. License

Add your project license here (for example, MIT, Apache-2.0, or proprietary).
