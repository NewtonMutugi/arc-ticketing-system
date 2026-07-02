# Audit Trail System - Setup Guide

## Quick Start

### 1. Run Migrations

Execute the following command to set up the audit trail system:

```bash
rails db:migrate
```

This creates:
- Audit logs table with proper indexes
- Adds `admin` field to users
- Adds audit reference fields to events, tickets, and orders

### 2. Set Admin Users

Promote users to admin status (required to access admin features):

```bash
# Via Rails console
rails c
> user = User.find_by(email_address: "admin@example.com")
> user.update(admin: true)
```

### 3. Verify Setup

In Rails console:

```ruby
# Should return true for admin user
user.admin?

# Should have no errors
AuditLog.first  # May return nil if no actions yet

# Should show admin check works
User.find_by(admin: true)
```

## What Gets Tracked

✅ **Events**
- When created (who, what time, IP address)
- When updated (what changed, who changed it)
- When deleted

✅ **Tickets**
- When created (who, what time, IP address)
- When updated (what changed, who changed it)
- When deleted

✅ **Order/Payment Approvals**
- When admin approves Mpesa payment (who, timestamp, IP)
- When admin rejects Mpesa payment (who, reason, IP)

## How to View Audit Logs

1. **Admin Dashboard** - `/admin/audit_logs`
   - Filter by admin user
   - Filter by action
   - Filter by date range
   - View all details

2. **In Rails Console**
   ```ruby
   # View all recent activity
   AuditLog.recent.limit(10)

   # View activity by specific user
   AuditLog.where(user_id: 1).recent

   # View payment approvals/rejections
   AuditLog.where(action: :payment_approved).recent
   ```

3. **In Code**
   ```ruby
   # Who created this event?
   event.created_by  # Returns User object

   # View all audit trail for this event
   event.audit_logs

   # Who approved this order?
   order.approved_by  # Returns User object
   order.approved_at  # Returns timestamp
   ```

## Key Models & Relationships

### User
- `admin: boolean` - Admin access flag
- `has_many :audit_logs` - All actions performed by this user
- `has_many :created_events` - Events created by this user
- `has_many :created_tickets` - Tickets created by this user
- `has_many :approved_orders` - Orders approved/rejected by this user

### Event
- `created_by_user_id: bigint` - Reference to creator
- `created_by` method - Returns User who created it
- `has_many :audit_logs` - All audit trail entries

### Ticket
- `created_by_user_id: bigint` - Reference to creator
- `created_by` method - Returns User who created it
- `has_many :audit_logs` - All audit trail entries

### Order
- `approved_by_user_id: bigint` - Reference to approver
- `approved_at: datetime` - When it was approved/rejected
- `approval_notes: text` - Reason for rejection
- `approved_by` method - Returns User who approved/rejected it
- `has_many :audit_logs` - All audit trail entries

## Troubleshooting

### "You do not have permission to access the admin dashboard"
**Solution**: Ensure the user has `admin: true`
```ruby
user = User.find_by(email_address: "your@email.com")
user.update(admin: true)
```

### Audit logs not showing actions
**Solution**: Ensure Current.user is set (it should be automatic)
- Check that you're logged in as an admin
- Verify migrations ran: `rails db:migrate:status`

### Migration errors
**Solution**:
```bash
# Check migration status
rails db:migrate:status

# If stuck, reset (dev only!)
rails db:migrate:reset
```

## Model Actions Tracked

| Model | Actions | Fields Tracked |
|-------|---------|-----------------|
| **Event** | create, update, delete | title, description, location, dates, publish |
| **Ticket** | create, update, delete | title, price, quantity, status, benefits |
| **Order** | status_change | status (paid/failed/rejected), payment_ref, notes |

## Example Queries

```ruby
# Get all actions in the last 7 days
AuditLog.where("created_at >= ?", 7.days.ago).recent

# Get all payment approvals by user
AuditLog.where(user_id: user_id, action: :payment_approved)

# Get actions on a specific event
Event.find(id).audit_logs

# Get the creator of an event
Event.find(id).created_by

# Get who approved an order
Order.find(id).approved_by

# Get approval timestamp
Order.find(id).approved_at
```

## Database Schema

Three key migrations were created:

1. **20260329205326_add_admin_to_users.rb**
   - Adds `admin` boolean to users

2. **20260329205327_add_audit_references_to_trackable_models.rb**
   - Adds created_by_user_id/updated_by_user_id to events
   - Adds created_by_user_id/updated_by_user_id to tickets
   - Adds approved_by_user_id/approved_at/approval_notes to orders

3. **20260329205328_create_audit_logs.rb**
   - Creates audit_logs table with all tracking fields

## Need Help?

For detailed documentation, see [AUDIT_TRAIL_DOCS.md](./AUDIT_TRAIL_DOCS.md)

Key sections:
- Usage examples with code
- Query examples
- Security considerations
- Future enhancements
