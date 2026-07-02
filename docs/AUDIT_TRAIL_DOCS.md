# Audit Trail System Documentation

## Overview

The audit trail system tracks all administrative actions on the platform, providing a comprehensive record of who did what and when. This is essential for accountability, security, and compliance.

## Key Features

### 1. **User Admin Role**
- Added `admin` boolean field to the `User` model
- Only users with `admin: true` can access admin features
- Admin role verification is enforced in `Admin::BaseController`

### 2. **Tracked Actions**

#### Event Management
- **Created**: Logs when an event is created
- **Updated**: Logs changes to event details (title, description, location, dates, publish status)
- **Deleted**: Logs when an event is deleted

#### Ticket Management
- **Created**: Logs when a ticket is created for an event
- **Updated**: Logs changes to ticket details (price, quantity, status, benefits, etc.)
- **Deleted**: Logs when a ticket is deleted

#### Order/Payment Management
- **Payment Approved**: Logs when an admin approves a Mpesa payment
- **Payment Rejected**: Logs when an admin rejects a Mpesa payment
- **Reason**: Captures the reason/notes for rejection

### 3. **Audit Log Model**

The `AuditLog` model stores audit trail records with the following information:

| Field | Type | Purpose |
|-------|------|---------|
| `user_id` | bigint | Who performed the action (foreign key to Users) |
| `action` | string | Type of action (created, updated, approved, rejected, etc.) |
| `auditable_type` | string | Model type affected (Event, Ticket, Order) |
| `auditable_id` | bigint | ID of the affected record |
| `changes` | text (JSON) | What was changed (only for updates) |
| `status` | string | Result of action (approved, rejected) |
| `reason` | text | Reason for action (e.g., rejection reason) |
| `ip_address` | string | IP address of the admin |
| `user_agent` | string | Browser/device info |
| `created_at` | timestamp | When the action occurred |

### 4. **Database Schema Changes**

#### Users Table
```sql
ALTER TABLE users ADD COLUMN admin BOOLEAN DEFAULT false NOT NULL;
```

#### Events Table
```sql
ALTER TABLE events
  ADD COLUMN created_by_user_id BIGINT,
  ADD COLUMN updated_by_user_id BIGINT,
  ADD FOREIGN KEY (created_by_user_id) REFERENCES users(id),
  ADD INDEX (created_by_user_id);
```

#### Tickets Table
```sql
ALTER TABLE tickets
  ADD COLUMN created_by_user_id BIGINT,
  ADD COLUMN updated_by_user_id BIGINT,
  ADD FOREIGN KEY (created_by_user_id) REFERENCES users(id),
  ADD INDEX (created_by_user_id);
```

#### Orders Table
```sql
ALTER TABLE orders
  ADD COLUMN approved_by_user_id BIGINT,
  ADD COLUMN approved_at DATETIME,
  ADD COLUMN approval_notes TEXT,
  ADD FOREIGN KEY (approved_by_user_id) REFERENCES users(id),
  ADD INDEX (approved_by_user_id);
```

#### AuditLogs Table
```sql
CREATE TABLE audit_logs (
  id BIGINT PRIMARY KEY,
  user_id BIGINT NOT NULL FOREIGN KEY REFERENCES users(id),
  action VARCHAR(255) NOT NULL,
  auditable_type VARCHAR(255) NOT NULL,
  auditable_id BIGINT NOT NULL,
  changes TEXT,
  status VARCHAR(255),
  reason TEXT,
  ip_address VARCHAR(255),
  user_agent TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  INDEX (auditable_type, auditable_id),
  INDEX (user_id, action),
  INDEX (created_at)
);
```

## Usage Examples

### Creating an Event
When an admin creates an event, the system:
1. Associates the event with the creator via `created_by_user_id`
2. Creates an audit log with action: `created`
3. Captures the IP address and user agent

```ruby
# In Admin::EventsController#create
@event = Event.new(event_params)
@event.created_by_user_id = Current.user.id
@event.save
# → Automatically logs audit trail
```

### Approving a Payment
When an admin approves an Mpesa payment:
1. Updates order status to `:paid`
2. Records the approver via `approved_by_user_id`
3. Records approval timestamp via `approved_at`
4. Creates audit log with action: `payment_approved`

```ruby
# In Admin::OrdersController#approve
@order.update(
  status: :paid,
  approved_by_user_id: Current.user.id,
  approved_at: Time.current
)
# → Automatically logs audit trail with payment_approved action
```

### Rejecting a Payment
When an admin rejects an Mpesa payment:
1. Updates order status to `:failed`
2. Records the rejection reason via `approval_notes`
3. Records the rejector via `approved_by_user_id`
4. Creates audit log with action: `payment_rejected`

```ruby
# In Admin::OrdersController#reject_payment
@order.update(
  status: :failed,
  approved_by_user_id: Current.user.id,
  approval_notes: params[:rejection_reason]
)
# → Automatically logs audit trail with payment_rejected action
```

## Querying Audit Logs

### Find who created a specific event
```ruby
event = Event.find(id)
creator = event.user  # Via created_by_user_id association
audit_entry = event.audit_logs.where(action: :created).first
```

### Find all actions by a user
```ruby
user = User.find(id)
user_actions = AuditLog.by_user(user.id)
user_actions.recent  # Ordered by most recent first
```

### Find all payment approvals
```ruby
approvals = AuditLog.by_action(:payment_approved).recent
rejections = AuditLog.by_action(:payment_rejected).recent
```

### Find all audit logs for a specific order
```ruby
order = Order.find(id)
order.audit_logs
```

### Generate audit report for date range
```ruby
start_date = Date.parse("2026-03-01")
end_date = Date.parse("2026-03-31")

Report = AuditLog
  .where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  .where(auditable_type: "Order")
  .where(action: [:payment_approved, :payment_rejected])
  .order(created_at: :desc)
```

## Admin Dashboard Features

### Audit Log Viewer
Access admin audit logs at `/admin/audit_logs`

Features:
- Filter by admin user
- Filter by action type
- Filter by model type (Event, Ticket, Order)
- Filter by date range
- View detailed changes for each action
- See IP address and user agent for each action

### Scopes Available on AuditLog
```ruby
AuditLog.recent              # Most recent first
AuditLog.by_user(user_id)    # Actions by specific user
AuditLog.by_action(:created) # Specific action type
AuditLog.by_model("Event")   # Specific model type
```

## Security Considerations

1. **Admin-Only Access**: Admin features are protected by `authorize_admin!` in `Admin::BaseController`
2. **IP Tracking**: Every audit log captures the admin's IP address for forensics
3. **User Agent**: Browser/device information is captured for device tracking
4. **Immutable Records**: Audit logs should never be deleted (consider adding paranoia gem if needed)
5. **Reason Tracking**: Payment rejections require a reason in `approval_notes`

## Setting Admin Role

To grant a user admin privileges:

### Via Rails Console
```ruby
user = User.find_by(email_address: "admin@example.com")
user.update(admin: true)
```

### Via Database
```sql
UPDATE users SET admin = true WHERE email_address = 'admin@example.com';
```

## Enums in AuditLog

```ruby
enum :action, {
  created: 0,
  updated: 1,
  deleted: 2,
  approved: 3,
  rejected: 4,
  payment_approved: 5,
  payment_rejected: 6
}
```

## Related Models

- `User`: Admin user who performed the action
- `Event`: Can belong to created_by_user
- `Ticket`: Can belong to created_by_user
- `Order`: Can belong to approved_by_user with approval timestamp

## Future Enhancements

Potential improvements to the audit system:
1. Add audit log retention policy (auto-delete after N days)
2. Real-time notifications for sensitive actions
3. Audit log export (CSV, PDF)
4. Advanced analytics and reporting
5. Email alerts for specific actions
6. Role-based audit log access (super-admins only)
7. Blockchain/immutable storage for compliance

## Running Migrations

To set up the audit trail system:

```bash
rails db:migrate
```

This will:
1. Add admin field to users table
2. Add audit reference fields to events, tickets, and orders
3. Create the audit_logs table with proper indexes

## Testing the Audit System

```ruby
# In Rails console
user = User.first
user.update(admin: true)

# Create event (should generate audit log)
event = Event.create!(
  title: "Test Event",
  description: "Testing audit trail",
  created_by_user_id: user.id
)

# View audit logs
AuditLog.recent.first
# => #<AuditLog id: 1, user_id: 1, action: "created", auditable_type: "Event", ...>

# Check relationships
event.created_by  # => User object
event.audit_logs  # => [AuditLog records]
```

## Troubleshooting

### Audit logs not being created
1. Ensure `Current.user` is set in the controller
2. Check that the `Auditable` concern is included in the model
3. Verify `track_audit_on` is called with the correct attributes

### Missing IP address or user agent
- Ensure `set_current_request_context` is called in ApplicationController
- Current should have `ip_address` and `user_agent` attributes set

### Performance issues
- Consider adding pagination to audit log views
- Use database indexes on `created_at`, `user_id`, and `auditable_type`
- Archive old audit logs to a separate table if you have millions of records
