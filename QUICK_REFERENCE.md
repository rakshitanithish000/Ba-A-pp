# Quick Reference - Authentication System

## For Backend Developers

### Adding Authentication to New API Endpoints
```php
<?php
include_once "../db_config.php";
include_once "../auth_helper.php";

// This line enforces authentication
require_authentication();

header('Content-Type: application/json');

// Your API logic here...
?>
```

### Getting Current User ID
```php
$user_id = get_authenticated_user_id();
if ($user_id) {
    // User is authenticated
    echo "User ID: " . $user_id;
}
```

### Optional Authentication Check
```php
if (is_authenticated()) {
    // User is logged in
} else {
    // User is not logged in
}
```

## For Frontend/Mobile Developers

### Login Flow
```dart
// 1. Login
final response = await http.post(
  Uri.parse('$baseUrl/login.php'),
  body: {
    'username': username,
    'password': password,
  },
);

// 2. Store cookies from response
// The session cookie will be automatically handled by http package
// if you use a persistent client

// 3. Use the same client for subsequent requests
```

### Using Persistent HTTP Client (Recommended)
```dart
import 'package:http/http.dart' as http;

class ApiService {
  static final http.Client _client = http.Client();
  
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/login.php'),
      body: {'username': username, 'password': password},
    );
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> getRentalRecords() async {
    // Uses same client, so session cookie is automatically sent
    final response = await _client.get(
      Uri.parse('$baseUrl/api/manage_rental_records.php?action=get_rental_records'),
    );
    return json.decode(response.body);
  }
}
```

### Handling 401 Errors
```dart
if (response.statusCode == 401) {
  // Session expired or not authenticated
  // Redirect to login screen
  Navigator.pushReplacementNamed(context, '/login');
}
```

## API Endpoints

### Authentication Endpoints
- `POST /login.php` - Login and create session
- `GET /logout.php` - Destroy session

### Protected Endpoints (Require Authentication)
- `GET /api/manage_rental_records.php?action=get_rental_records`
- `POST /api/manage_rental_records.php?action=add_rental_record`
- `GET /api/manage_guests.php?action=get_guests`
- `POST /api/manage_guests.php?action=add_guest`
- `GET /api/manage_flats.php?action=get_flats`
- `POST /api/manage_flats.php?action=add_flat`
- `GET /api/manage_rooms.php?action=get_rooms`
- `POST /api/manage_rooms.php?action=add_room`
- `GET /api/manage_bed_spaces.php?action=get_bed_spaces`
- `POST /api/manage_bed_spaces.php?action=add_bed_space`
- `GET /api/manage_owners.php?action=get_re_owners`
- `POST /api/manage_owners.php?action=add_re_owner`
- `GET /get_dashboard_stats.php`

## Error Responses

### 401 Unauthorized
```json
{
  "status": "error",
  "message": "Authentication required. Please login first."
}
```

### Login Failed
```json
{
  "status": "error",
  "message": "Invalid password"
}
```

### Login Success
```json
{
  "status": "success",
  "message": "Login successful",
  "user_id": 1
}
```

## Testing with cURL

### Login
```bash
curl -X POST http://localhost/login.php \
  -d "username=admin&password=admin123" \
  -c cookies.txt
```

### Access Protected Endpoint
```bash
curl http://localhost/api/manage_rental_records.php?action=get_rental_records \
  -b cookies.txt
```

### Logout
```bash
curl http://localhost/logout.php -b cookies.txt
```

## Security Notes

1. **Always use HTTPS in production**
2. **Change default admin password immediately**
3. **Session cookies are httpOnly by default**
4. **Sessions expire based on PHP configuration**
5. **Never log passwords or session IDs**

## Troubleshooting

### "Authentication required" error
- Check if login was successful
- Verify cookies are being sent with requests
- Check PHP session configuration

### Session not persisting
- Ensure `session_start()` is called
- Check session storage directory permissions
- Verify cookies are enabled in client

### Password not working
- Verify password is correct
- Check if admin_users table exists
- Ensure password is properly hashed in database
