# Admin Panel

## Overview

The Admin Panel provides super admin access to manage all accounts, users, subscriptions, and other admins across the platform.

## Access Control

Access is controlled via the `SUPER_ADMIN_EMAILS` environment variable. Add comma-separated email addresses:

```bash
SUPER_ADMIN_EMAILS=admin@example.com,superadmin@example.com
```

Only users with emails in this list will see the "Admin Panel" link in their dropdown menu after signing in as a regular user.

Alternatively, admins have separate authentication at `/admin/session/new` with email/password.

## Default Admin Account

A default admin account is created via `db/seeds.rb`:

- Email: `admin@example.com`
- Password: `password123`

**Change this password in production!**

## Features

### Dashboard (`/admin`)
- Quick stats: Total accounts, users, active subscriptions
- Quick action links to manage resources

### Accounts (`/admin/accounts`)
- List all accounts with search
- View account details, users, and subscription
- Update account settings
- Delete accounts

### Users (`/admin/users`)
- List all users with search
- View user details and session history
- **Impersonate users** to debug issues
- Update user details
- Delete users

### Subscriptions (`/admin/subscriptions`)
- List all subscriptions
- Filter by status (active, trialing, past_due)
- View associated accounts

### Admins (`/admin/admins`)
- List all super admins
- Create new admins
- Delete admins (cannot delete self)

## Impersonation

Admins can impersonate any user to debug issues:

1. Navigate to Users list or user detail page
2. Click "Impersonate" button
3. You'll be signed in as that user and redirected to `/app`
4. An orange banner appears at the top: "⚠️ Admin Impersonating: user@example.com"
5. Click "Stop Impersonating" to return to admin panel

**Security:**
- Admin identity is preserved during impersonation
- All actions are logged with the impersonation flag
- Cannot impersonate other admins

## Architecture

### Separate Authentication
- Admin authentication is completely separate from user authentication
- Uses `Admin` and `AdminSession` models
- Separate signed cookies: `admin_session_id` vs `session_id`
- No way for users to elevate to admin through the app

### Authorization
- `Admin::BaseController` requires admin authentication
- All admin controllers inherit from `Admin::BaseController`
- Regular users cannot access `/admin/*` routes

### Current Attributes
- `Current.admin` - The authenticated admin
- `Current.user` - The impersonated user (if impersonating)
- Both can be present simultaneously during impersonation

## Development

### Create an Admin

Via Rails console:
```ruby
Admin.create!(
  email: "newadmin@example.com",
  name: "New Admin",
  password: "securepassword",
  password_confirmation: "securepassword"
)
```

Or use the Admin Panel UI at `/admin/admins` (requires existing admin access).

### Testing

Admin tests are in `test/controllers/admin/` and `test/models/admin*.rb`.

Run admin-specific tests:
```bash
rails test test/controllers/admin
rails test test/models/admin_test.rb
```

## Production Deployment

1. Set `SUPER_ADMIN_EMAILS` environment variable
2. Create admin accounts via Rails console or seed data
3. **Change default admin password!**
4. Consider adding IP whitelist for `/admin` routes (nginx/load balancer level)
5. Enable 2FA for admins (future enhancement)

## Future Enhancements

- [ ] Audit log for all admin actions
- [ ] Two-factor authentication for admins
- [ ] IP whitelist for admin access
- [ ] Email notifications for admin actions
- [ ] Bulk operations (delete multiple users, etc.)
- [ ] Admin activity dashboard with charts
