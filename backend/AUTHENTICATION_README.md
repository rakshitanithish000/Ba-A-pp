# Authentication System - Security Update

## Overview
This security update implements session-based authentication for all API endpoints to prevent unauthorized access to sensitive data.

## Changes Made

### 1. Database Schema Updates
- **backend/database.sql**: Added `admin_users` table for storing admin credentials
- **backend/sample_data.sql**: Added default admin user (username: `admin`, password: `admin123`)

### 2. Authentication Infrastructure
- **backend/auth_helper.php**: New authentication helper with functions:
  - `is_authenticated()`: Check if user is authenticated
  - `require_authentication()`: Enforce authentication (returns 401 if not authenticated)
  - `get_authenticated_user_id()`: Get current user ID

### 3. Login System
- **backend/login.php**: Updated to create PHP sessions upon successful login
- **backend/logout.php**: New endpoint to destroy sessions

### 4. Protected API Endpoints
All API endpoints now require authentication:
- backend/api/manage_rental_records.php
- backend/api/manage_guests.php
- backend/api/manage_flats.php
- backend/api/manage_rooms.php
- backend/api/manage_bed_spaces.php
- backend/api/manage_owners.php
- backend/get_dashboard_stats.php

## Setup Instructions

### 1. Update Database Schema
Run the following SQL to add the admin_users table:

```sql
CREATE TABLE IF NOT EXISTS admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. Create Admin User
Insert a default admin user (password is hashed using bcrypt):

```sql
-- Default password: admin123
INSERT INTO admin_users (username, password) VALUES 
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');
```

### 3. PHP Session Configuration
Ensure your PHP installation has sessions enabled. The authentication system uses PHP's native session management.

### 4. Client-Side Updates Required
The mobile app needs to be updated to:
1. Store session cookies after successful login
2. Include session cookies in all API requests
3. Handle 401 responses by redirecting to login

## Security Features

1. **Session-Based Authentication**: Uses PHP sessions to maintain authenticated state
2. **Password Hashing**: Passwords are stored using bcrypt (password_hash/password_verify)
3. **Centralized Auth Check**: Single authentication helper prevents code duplication
4. **401 Unauthorized Response**: Clear error messages for unauthenticated requests
5. **All Endpoints Protected**: Comprehensive protection across all API endpoints

## Testing

### Test Authentication
```bash
# 1. Login (creates session)
curl -X POST http://your-domain.com/login.php \
  -d "username=admin&password=admin123" \
  -c cookies.txt

# 2. Access protected endpoint (with session)
curl -X GET http://your-domain.com/api/manage_rental_records.php?action=get_rental_records \
  -b cookies.txt

# 3. Access without authentication (should return 401)
curl -X GET http://your-domain.com/api/manage_rental_records.php?action=get_rental_records
```

## Creating Additional Admin Users

Use this PHP script to generate password hashes:

```php
<?php
$password = "your_password_here";
$hash = password_hash($password, PASSWORD_DEFAULT);
echo "Password hash: " . $hash . "\n";
?>
```

Then insert into database:
```sql
INSERT INTO admin_users (username, password) VALUES ('newadmin', 'generated_hash_here');
```

## Migration Notes

- **Breaking Change**: All API endpoints now require authentication
- **Client Update Required**: Mobile app must be updated to handle sessions
- **Backward Compatibility**: None - this is a security fix that intentionally breaks unauthenticated access

## Security Considerations

1. **HTTPS Required**: Always use HTTPS in production to protect session cookies
2. **Session Security**: Configure PHP session settings appropriately:
   - `session.cookie_httponly = 1`
   - `session.cookie_secure = 1` (for HTTPS)
   - `session.cookie_samesite = "Strict"`
3. **Password Policy**: Change default admin password immediately
4. **Regular Updates**: Keep PHP and dependencies updated

## Troubleshooting

### "Authentication required" error
- Ensure you're logged in first via `/login.php`
- Check that session cookies are being sent with requests
- Verify PHP sessions are working (`session_start()` succeeds)

### Session not persisting
- Check PHP session configuration
- Ensure cookies are enabled in the client
- Verify session storage directory is writable

## Support

For issues or questions, refer to the PHP session documentation:
https://www.php.net/manual/en/book.session.php
