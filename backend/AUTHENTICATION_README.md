# Authentication Implementation

## Overview
This patch implements session-based authentication for all API endpoints to prevent unauthorized access to sensitive data.

## Changes Made

### 1. New Files Created
- **backend/auth_helper.php**: Core authentication helper with session management functions
- **backend/logout.php**: Logout endpoint to clear user sessions
- **backend/admin_users_migration.sql**: Database migration to create admin_users table

### 2. Modified Files
- **backend/login.php**: Updated to create authenticated sessions upon successful login
- **backend/get_dashboard_stats.php**: Added authentication requirement
- **backend/api/manage_guests.php**: Added authentication requirement
- **backend/api/manage_flats.php**: Added authentication requirement
- **backend/api/manage_rooms.php**: Added authentication requirement
- **backend/api/manage_bed_spaces.php**: Added authentication requirement
- **backend/api/manage_rental_records.php**: Added authentication requirement
- **backend/api/manage_owners.php**: Added authentication requirement

## Database Setup

Run the following SQL migration to create the admin_users table:

```bash
mysql -u your_username -p your_database < backend/admin_users_migration.sql
```

Or execute the SQL directly in your database management tool.

## Default Credentials

**Username:** admin  
**Password:** admin123

**⚠️ IMPORTANT:** Change the default password immediately after deployment!

## How Authentication Works

1. **Login Flow:**
   - User submits credentials to `/backend/login.php`
   - Server validates credentials against `admin_users` table
   - On success, server creates a PHP session and stores user_id
   - Session cookie is automatically sent to client

2. **Protected Endpoints:**
   - All API endpoints now require authentication
   - Each request checks for valid session using `require_authentication()`
   - If session is invalid, returns 401 Unauthorized response
   - If session is valid, request proceeds normally

3. **Session Management:**
   - Sessions are managed by PHP's native session handling
   - Session cookies are automatically handled by the browser
   - Sessions persist across requests until logout or expiration

## API Response Changes

### Unauthenticated Requests
All protected endpoints now return:
```json
{
  "status": "error",
  "message": "Unauthorized. Please login to access this resource."
}
```
HTTP Status Code: 401

### Login Response
Login endpoint now includes session information:
```json
{
  "status": "success",
  "message": "Login successful",
  "user_id": 1,
  "session_id": "session_identifier"
}
```

## Security Considerations

1. **Session Security:**
   - Sessions use PHP's default secure session handling
   - Session IDs are automatically rotated
   - Sessions expire based on PHP's session.gc_maxlifetime setting

2. **Password Security:**
   - Passwords are hashed using bcrypt (password_hash/password_verify)
   - Never store or transmit plain-text passwords

3. **HTTPS Requirement:**
   - In production, ensure all traffic uses HTTPS
   - Configure session cookies as secure and httponly

## Testing

### Test Authentication
```bash
# 1. Login
curl -X POST https://your-domain.com/backend/login.php \
  -d "username=admin&password=admin123" \
  -c cookies.txt

# 2. Access protected endpoint (should succeed)
curl https://your-domain.com/backend/api/manage_guests.php?action=get_guests \
  -b cookies.txt

# 3. Access without session (should fail with 401)
curl https://your-domain.com/backend/api/manage_guests.php?action=get_guests
```

## Client Application Updates Required

The Flutter/mobile client needs to be updated to:
1. Store and send session cookies with each request
2. Handle 401 responses by redirecting to login
3. Implement proper session management

Example using http package with cookies:
```dart
import 'package:http/http.dart' as http;
import 'dart:io';

// Store cookies after login
var response = await http.post(loginUrl, body: credentials);
String? rawCookie = response.headers['set-cookie'];

// Send cookies with subsequent requests
var headers = {
  'cookie': rawCookie ?? '',
};
var response = await http.get(apiUrl, headers: headers);
```

## Troubleshooting

### Issue: "Unauthorized" after login
- Ensure cookies are being sent with requests
- Check that session.cookie_domain is configured correctly
- Verify PHP session settings in php.ini

### Issue: Sessions not persisting
- Check that session files directory is writable
- Verify session.save_path in php.ini
- Ensure session cookies are not being blocked

### Issue: CORS errors
- Session cookies require proper CORS configuration
- Ensure credentials: 'include' is set in client requests
- Configure Access-Control-Allow-Credentials header

## Migration Notes

This is a breaking change. All existing API clients must:
1. Implement login flow before accessing protected endpoints
2. Store and send session cookies with each request
3. Handle 401 responses appropriately

## Future Enhancements

Consider implementing:
- Token-based authentication (JWT) for stateless API
- Role-based access control (RBAC)
- API rate limiting
- Session timeout warnings
- Multi-factor authentication (MFA)
- Password reset functionality
- Account lockout after failed attempts
