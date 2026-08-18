# Quick Reference: Authentication Implementation

## For Backend Developers

### Adding Authentication to New Endpoints

When creating a new API endpoint, always add these lines at the top:

```php
<?php
// Include authentication check
require_once "../auth_check.php";

// Require authentication for all operations in this API
require_authentication();

// Your existing includes
include_once "../db_config.php";
header('Content-Type: application/json');

// Your code here...
```

### Available Authentication Functions

```php
// Check if user is authenticated (returns boolean)
if (is_authenticated()) {
    // User is logged in
}

// Get current user ID (returns int or null)
$user_id = get_current_user_id();

// Require authentication or exit with 401 (use at endpoint entry)
require_authentication();
```

## For Frontend/Mobile Developers

### Login Flow

```dart
// 1. Send login request
final response = await http.post(
  Uri.parse('http://your-domain/backend/login.php'),
  body: {
    'username': username,
    'password': password,
  },
);

// 2. Parse response
final data = json.decode(response.body);
if (data['status'] == 'success') {
  // Store session information
  final sessionId = data['session_id'];
  final sessionToken = data['session_token'];
  
  // The session cookie (PHPSESSID) is automatically stored by http client
  // You need to maintain this cookie for subsequent requests
}
```

### Making Authenticated Requests

```dart
// Use the same http client that received the login cookie
final response = await http.post(
  Uri.parse('http://your-domain/backend/api/manage_owners.php?action=get_lease_owners'),
  // The session cookie is automatically included
);

// Handle 401 Unauthorized
if (response.statusCode == 401) {
  // Session expired or invalid - redirect to login
  navigateToLogin();
}
```

### Logout

```dart
await http.post(
  Uri.parse('http://your-domain/backend/logout.php'),
);
// Clear local session data
clearSessionData();
navigateToLogin();
```

## Error Handling

### 401 Unauthorized Response

```json
{
  "status": "error",
  "message": "Unauthorized. Please login to access this resource.",
  "error_code": "AUTH_REQUIRED"
}
```

**Action**: Redirect user to login screen and clear any stored session data.

## Security Best Practices

### For Backend
1. ✅ Always use `require_authentication()` at the start of protected endpoints
2. ✅ Never bypass authentication checks
3. ✅ Use prepared statements for database queries (already implemented)
4. ✅ Validate and sanitize all user inputs
5. ✅ Enable HTTPS in production (uncomment `session.cookie_secure` in auth_check.php)

### For Frontend
1. ✅ Store session cookies securely
2. ✅ Clear session data on logout
3. ✅ Handle 401 responses by redirecting to login
4. ✅ Don't store passwords locally
5. ✅ Use HTTPS for all API calls in production

## Testing Checklist

- [ ] Unauthenticated requests return 401
- [ ] Login creates valid session
- [ ] Authenticated requests succeed with valid session
- [ ] Session expires after timeout (1 hour)
- [ ] Logout properly destroys session
- [ ] Session cookie is HttpOnly
- [ ] Session cookie is SameSite=Strict

## Common Issues

### Issue: "Session not persisting"
**Solution**: Ensure the HTTP client maintains cookies between requests. In Flutter, use a persistent `http.Client()` or cookie manager.

### Issue: "401 even after login"
**Solution**: Check that:
1. Login response shows `"status": "success"`
2. Session cookie (PHPSESSID) is being sent with subsequent requests
3. Session hasn't expired (1 hour timeout)

### Issue: "CORS errors"
**Solution**: The backend already has CORS headers in `db_config.php`. Ensure your frontend is sending credentials:
```dart
// In Flutter http package, cookies are handled automatically
// For web, you may need to set credentials: 'include'
```

## Session Configuration

Current settings (in `backend/auth_check.php`):
- **Timeout**: 1 hour (3600 seconds)
- **Cookie**: HttpOnly, SameSite=Strict
- **Regeneration**: Every 5 minutes
- **Secure**: Disabled (enable for HTTPS in production)

To modify timeout, edit `auth_check.php`:
```php
ini_set('session.gc_maxlifetime', '7200'); // 2 hours
```

## Support

For questions or issues:
1. Check `backend/AUTHENTICATION_SECURITY.md` for detailed documentation
2. Review `backend/SECURITY_PATCH_SUMMARY.md` for implementation details
3. Run `backend/test_security_patch.sh` to verify the patch is working
