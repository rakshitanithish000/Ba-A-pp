# Authentication Security Implementation

## Overview
This document describes the authentication security measures implemented to protect all API endpoints from unauthorized access.

## Changes Made

### 1. Session-Based Authentication System
- **File**: `backend/login.php`
- **Changes**: 
  - Added `session_start()` to initialize PHP sessions
  - Upon successful login, the system now creates a server-side session with:
    - `$_SESSION['user_id']` - The authenticated user's ID
    - `$_SESSION['username']` - The authenticated user's username
    - `$_SESSION['authenticated']` - Boolean flag set to true
    - `$_SESSION['session_token']` - A cryptographically secure random token
  - Returns session information to the client including session_id and session_token

### 2. Authentication Middleware
- **File**: `backend/auth_check.php` (NEW)
- **Purpose**: Centralized authentication checking for all protected endpoints
- **Functions**:
  - `is_authenticated()` - Checks if current session is authenticated
  - `require_authentication()` - Enforces authentication or returns 401 Unauthorized
  - `get_current_user_id()` - Retrieves the current authenticated user's ID

### 3. Protected API Endpoints
All API endpoints now require authentication before processing any requests:

- `backend/api/manage_owners.php` - RE Owners and Lease Owners management
- `backend/api/manage_flats.php` - Flats management
- `backend/api/manage_rooms.php` - Rooms management
- `backend/api/manage_bed_spaces.php` - Bed spaces management
- `backend/api/manage_guests.php` - Guests management
- `backend/api/manage_rental_records.php` - Rental records management
- `backend/get_dashboard_stats.php` - Dashboard statistics

Each file now includes:
```php
require_once "../auth_check.php";
require_authentication();
```

### 4. Logout Endpoint
- **File**: `backend/logout.php` (NEW)
- **Purpose**: Properly destroys sessions and logs out users
- **Actions**:
  - Clears all session variables
  - Deletes session cookie
  - Destroys the session

## Security Benefits

### Mitigated Vulnerabilities
1. **Unauthenticated Access**: All API endpoints now require valid authentication
2. **Arbitrary Data Deletion**: The `delete_lease_owner` action (and all other delete operations) can only be performed by authenticated users
3. **Data Exposure**: Read operations (get_*) now require authentication
4. **Unauthorized Modifications**: Create and update operations require authentication

### Defense in Depth
- Session-based authentication prevents replay attacks
- Cryptographically secure session tokens
- Proper session cleanup on logout
- Consistent authentication checks across all endpoints

## Client Integration Requirements

### Login Flow
1. Client sends POST request to `backend/login.php` with username and password
2. Server validates credentials and creates session
3. Server returns session information:
```json
{
  "status": "success",
  "message": "Login successful",
  "user_id": 1,
  "session_token": "...",
  "session_id": "..."
}
```
4. Client must maintain the session cookie (PHPSESSID) for subsequent requests

### API Requests
- All API requests must include the session cookie
- If session is invalid or expired, server returns:
```json
{
  "status": "error",
  "message": "Unauthorized. Please login to access this resource.",
  "error_code": "AUTH_REQUIRED"
}
```
- HTTP Status Code: 401 Unauthorized

### Logout Flow
1. Client sends request to `backend/logout.php`
2. Server destroys session
3. Client should clear stored session information

## Testing Authentication

### Test Unauthenticated Access (Should Fail)
```bash
# This should return 401 Unauthorized
curl -X POST "http://your-domain/backend/api/manage_owners.php?action=delete_lease_owner" \
  -d "id=1"
```

### Test Authenticated Access (Should Succeed)
```bash
# First login
curl -X POST "http://your-domain/backend/login.php" \
  -d "username=admin&password=admin123" \
  -c cookies.txt

# Then make authenticated request
curl -X POST "http://your-domain/backend/api/manage_owners.php?action=get_lease_owners" \
  -b cookies.txt
```

## Database Schema Considerations

The database schema includes CASCADE DELETE relationships:
- `flats.lease_owner_id` → `lease_owners.id` (ON DELETE CASCADE)
- `rooms.flat_id` → `flats.id` (ON DELETE CASCADE)
- `bed_spaces.room_id` → `rooms.id` (ON DELETE CASCADE)
- `rental_records.guest_id` → `guests.id` (ON DELETE CASCADE)

With authentication in place, only authorized administrators can trigger these cascading deletes, preventing unauthorized data loss.

## Session Configuration

For production environments, consider adding these PHP session configurations in `php.ini` or at the start of `auth_check.php`:

```php
// Recommended session security settings
ini_set('session.cookie_httponly', 1);  // Prevent JavaScript access to session cookie
ini_set('session.cookie_secure', 1);    // Only send cookie over HTTPS
ini_set('session.use_strict_mode', 1);  // Reject uninitialized session IDs
ini_set('session.cookie_samesite', 'Strict'); // CSRF protection
```

## Maintenance

### Adding New Protected Endpoints
When creating new API endpoints, always include:
```php
<?php
require_once "../auth_check.php";
require_authentication();
// ... rest of your code
```

### Session Timeout
PHP's default session timeout is 24 minutes (1440 seconds). To customize:
```php
ini_set('session.gc_maxlifetime', 3600); // 1 hour
```

## Compliance
This implementation addresses:
- OWASP Top 10: A01:2021 - Broken Access Control
- CWE-306: Missing Authentication for Critical Function
- CWE-862: Missing Authorization
