# Quick Reference Guide - Authentication System

## For Backend Developers

### Adding Authentication to a New Endpoint

```php
<?php
// 1. Include required files
include_once "../db_config.php";
include_once "../auth_helper.php";

// 2. Require authentication (this blocks unauthenticated requests)
require_authentication();

// 3. Set response type
header('Content-Type: application/json');

// 4. Your endpoint logic here
$action = $_GET['action'] ?? '';

switch ($action) {
    case 'your_action':
        // Your code here
        // You can get the current user ID if needed:
        $user_id = get_current_user_id();
        
        echo json_encode(['status' => 'success', 'data' => $result]);
        break;
        
    default:
        echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}

$conn->close();
?>
```

### Available Authentication Functions

```php
// Check if user is authenticated (returns boolean)
if (is_authenticated()) {
    // User is logged in
}

// Require authentication (blocks request if not authenticated)
require_authentication();

// Get current user ID
$user_id = get_current_user_id(); // Returns int or null

// Set authenticated user (used in login.php)
set_authenticated_user($user_id);

// Clear authentication (used in logout.php)
clear_authentication();
```

### Creating Admin Users

```bash
# Command line method
php backend/create_admin_user.php username password email@example.com

# Example
php backend/create_admin_user.php john.doe SecurePass123! john@example.com
```

### Testing Authentication

```bash
# Test unauthenticated access (should return 401)
curl -i https://your-domain.com/backend/api/your_endpoint.php

# Test login
curl -i -c cookies.txt -X POST https://your-domain.com/backend/login.php \
  -d "username=admin&password=yourpassword"

# Test authenticated access (should return 200)
curl -i -b cookies.txt https://your-domain.com/backend/api/your_endpoint.php
```

## For Frontend Developers

### Login Flow

```dart
// 1. Store session cookie after login
class ApiService {
  static String? sessionCookie;
  
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      body: {
        'username': username,
        'password': password,
      },
    );
    
    // Extract and store session cookie
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      sessionCookie = rawCookie.split(';')[0];
    }
    
    return json.decode(response.body);
  }
}
```

### Making Authenticated Requests

```dart
// 2. Include session cookie in all API requests
static Future<Map<String, dynamic>> getGuests({String? bedSpaceId}) async {
  // Prepare headers with session cookie
  final headers = <String, String>{};
  if (sessionCookie != null) {
    headers['cookie'] = sessionCookie!;
  }
  
  final url = bedSpaceId != null 
      ? '$baseUrl/api/manage_guests.php?action=get_guests&bed_space_id=$bedSpaceId'
      : '$baseUrl/api/manage_guests.php?action=get_guests';
      
  final response = await http.get(Uri.parse(url), headers: headers);
  
  // Handle 401 Unauthorized
  if (response.statusCode == 401) {
    sessionCookie = null;
    throw Exception('Session expired. Please login again.');
  }
  
  return json.decode(response.body);
}
```

### Logout

```dart
static Future<void> logout() async {
  if (sessionCookie != null) {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout.php'),
        headers: {'cookie': sessionCookie!},
      );
    } catch (e) {
      // Ignore errors during logout
    }
  }
  sessionCookie = null;
}
```

### Global Error Handling

```dart
// Add this to your API service
static Future<Map<String, dynamic>> handleResponse(http.Response response) async {
  if (response.statusCode == 401) {
    // Clear session and redirect to login
    sessionCookie = null;
    throw UnauthorizedException('Please login to continue');
  }
  
  if (response.statusCode != 200) {
    throw ApiException('Server error: ${response.statusCode}');
  }
  
  return json.decode(response.body);
}

// Custom exceptions
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}
```

### Session Persistence (Optional)

```dart
// Store session cookie in secure storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'session_cookie';
  
  static Future<void> saveSession(String cookie) async {
    await _storage.write(key: _sessionKey, value: cookie);
  }
  
  static Future<String?> loadSession() async {
    return await _storage.read(key: _sessionKey);
  }
  
  static Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }
}

// Use in ApiService
static Future<void> init() async {
  sessionCookie = await SessionManager.loadSession();
}

static Future<void> login(String username, String password) async {
  // ... login logic ...
  if (sessionCookie != null) {
    await SessionManager.saveSession(sessionCookie!);
  }
}

static Future<void> logout() async {
  // ... logout logic ...
  await SessionManager.clearSession();
}
```

## Common Issues and Solutions

### Issue: "Unauthorized" error after login

**Cause:** Session cookie not being sent with requests

**Solution:** Ensure you're including the cookie header:
```dart
headers['cookie'] = sessionCookie!;
```

### Issue: Session expires too quickly

**Cause:** PHP session timeout is too short

**Solution:** Increase session lifetime in php.ini:
```ini
session.gc_maxlifetime = 3600  ; 1 hour
```

### Issue: CORS errors with credentials

**Cause:** CORS not configured for credentials

**Solution:** Update backend CORS headers:
```php
header("Access-Control-Allow-Origin: https://your-frontend-domain.com");
header("Access-Control-Allow-Credentials: true");
```

And in frontend:
```dart
// For web apps, ensure credentials are included
final response = await http.get(
  url,
  headers: headers,
  // Note: http package doesn't support credentials flag
  // Use dio package for better CORS support
);
```

### Issue: Session not persisting across app restarts

**Cause:** Session cookie not stored persistently

**Solution:** Use secure storage to persist session cookie (see Session Persistence above)

## Security Best Practices

### DO ✅
- Always include authentication checks on sensitive endpoints
- Use HTTPS in production
- Store session cookies securely
- Clear session on logout
- Handle 401 errors gracefully
- Validate user input
- Use prepared statements for SQL queries

### DON'T ❌
- Don't store passwords in plaintext
- Don't log session cookies
- Don't share session cookies between users
- Don't ignore 401 errors
- Don't hardcode credentials
- Don't disable SSL verification
- Don't expose sensitive data in error messages

## API Response Formats

### Success Response
```json
{
  "status": "success",
  "data": { ... },
  "message": "Optional success message"
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Error description"
}
```

### Unauthorized Response (401)
```json
{
  "status": "error",
  "message": "Unauthorized. Please login to access this resource."
}
```

## Endpoints

### Authentication Endpoints
- `POST /backend/login.php` - Login
- `POST /backend/logout.php` - Logout

### Protected API Endpoints (require authentication)
- `GET /backend/api/manage_guests.php?action=get_guests`
- `POST /backend/api/manage_guests.php?action=add_guest`
- `GET /backend/api/manage_flats.php?action=get_flats`
- `POST /backend/api/manage_flats.php?action=add_flat`
- `GET /backend/api/manage_rooms.php?action=get_rooms`
- `POST /backend/api/manage_rooms.php?action=add_room`
- `GET /backend/api/manage_bed_spaces.php?action=get_bed_spaces`
- `POST /backend/api/manage_bed_spaces.php?action=add_bed_space`
- `GET /backend/api/manage_rental_records.php?action=get_rental_records`
- `POST /backend/api/manage_rental_records.php?action=add_rental_record`
- `GET /backend/api/manage_owners.php?action=get_re_owners`
- `GET /backend/api/manage_owners.php?action=get_lease_owners`
- `POST /backend/api/manage_owners.php?action=add_re_owner`
- `POST /backend/api/manage_owners.php?action=add_lease_owner`
- `GET /backend/get_dashboard_stats.php`

## Support

For questions or issues:
1. Check this guide first
2. Review AUTHENTICATION_README.md for detailed documentation
3. Check DEPLOYMENT_CHECKLIST.md for deployment issues
4. Contact the security team

## Version History

- **v1.0** (2024-01-XX) - Initial authentication implementation
  - Session-based authentication
  - Protected all API endpoints
  - Added admin user management
