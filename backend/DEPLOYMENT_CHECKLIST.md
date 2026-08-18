# Deployment Checklist - Authentication Security Patch

## Pre-Deployment Steps

### 1. Database Migration
- [ ] Backup your current database
- [ ] Run the admin_users migration:
  ```bash
  mysql -u your_username -p your_database < backend/admin_users_migration.sql
  ```
- [ ] Verify the admin_users table was created:
  ```sql
  DESCRIBE admin_users;
  SELECT * FROM admin_users;
  ```

### 2. File Deployment
- [ ] Upload all modified PHP files to the server
- [ ] Ensure file permissions are correct (644 for PHP files)
- [ ] Verify auth_helper.php is readable by all API files

### 3. PHP Configuration
- [ ] Verify PHP sessions are enabled in php.ini:
  ```ini
  session.save_handler = files
  session.save_path = "/tmp"  ; or another writable directory
  session.use_cookies = 1
  session.cookie_httponly = 1
  ```
- [ ] Ensure session directory is writable by PHP
- [ ] For production, set secure session cookies:
  ```ini
  session.cookie_secure = 1  ; Only if using HTTPS
  session.cookie_samesite = "Strict"
  ```

### 4. Security Configuration
- [ ] Change default admin password immediately:
  ```bash
  php backend/create_admin_user.php newadmin YourSecurePassword123! admin@yourdomain.com
  ```
- [ ] Delete or disable the default 'admin' account if not needed
- [ ] Delete create_admin_user.php after creating your admin users

## Deployment Steps

### 1. Deploy Backend Files
```bash
# Upload new files
- backend/auth_helper.php
- backend/logout.php
- backend/admin_users_migration.sql
- backend/create_admin_user.php

# Upload modified files
- backend/login.php
- backend/get_dashboard_stats.php
- backend/api/manage_guests.php
- backend/api/manage_flats.php
- backend/api/manage_rooms.php
- backend/api/manage_bed_spaces.php
- backend/api/manage_rental_records.php
- backend/api/manage_owners.php
```

### 2. Run Database Migration
```bash
mysql -u u690977936_mobile_app -p u690977936_mobile_app < backend/admin_users_migration.sql
```

### 3. Test Authentication
```bash
# Make test_authentication.sh executable
chmod +x backend/test_authentication.sh

# Run the test script
./backend/test_authentication.sh
```

## Post-Deployment Verification

### 1. Test Unauthenticated Access (Should Fail)
```bash
curl -i https://app.efficientgroupdubai.com/backend/api/manage_guests.php?action=get_guests
# Expected: HTTP 401 with error message
```

### 2. Test Login
```bash
curl -i -c cookies.txt -X POST https://app.efficientgroupdubai.com/backend/login.php \
  -d "username=admin&password=admin123"
# Expected: HTTP 200 with success message and session_id
```

### 3. Test Authenticated Access (Should Succeed)
```bash
curl -i -b cookies.txt https://app.efficientgroupdubai.com/backend/api/manage_guests.php?action=get_guests
# Expected: HTTP 200 with guest data
```

### 4. Test All Protected Endpoints
- [ ] GET /backend/api/manage_guests.php?action=get_guests
- [ ] GET /backend/api/manage_flats.php?action=get_flats
- [ ] GET /backend/api/manage_rooms.php?action=get_rooms
- [ ] GET /backend/api/manage_bed_spaces.php?action=get_bed_spaces
- [ ] GET /backend/api/manage_rental_records.php?action=get_rental_records
- [ ] GET /backend/api/manage_owners.php?action=get_re_owners
- [ ] GET /backend/get_dashboard_stats.php

All should return 401 without authentication, 200 with authentication.

## Client Application Updates

### Flutter/Mobile App Changes Required

The mobile application needs to be updated to handle authentication:

1. **Store Session Cookie After Login**
   ```dart
   // In api_service.dart, update login method
   static String? sessionCookie;
   
   static Future<Map<String, dynamic>> login(String username, String password) async {
     final response = await http.post(
       Uri.parse('$baseUrl/login.php'),
       body: {'username': username, 'password': password},
     );
     
     // Store session cookie
     String? rawCookie = response.headers['set-cookie'];
     if (rawCookie != null) {
       sessionCookie = rawCookie.split(';')[0];
     }
     
     return json.decode(response.body);
   }
   ```

2. **Send Cookie With All Requests**
   ```dart
   static Future<Map<String, dynamic>> getGuests({String? bedSpaceId}) async {
     final headers = sessionCookie != null ? {'cookie': sessionCookie!} : {};
     
     final url = bedSpaceId != null 
         ? '$baseUrl/api/manage_guests.php?action=get_guests&bed_space_id=$bedSpaceId'
         : '$baseUrl/api/manage_guests.php?action=get_guests';
         
     final response = await http.get(Uri.parse(url), headers: headers);
     return json.decode(response.body);
   }
   ```

3. **Handle 401 Responses**
   ```dart
   // Add global error handler
   if (response.statusCode == 401) {
     // Clear session and redirect to login
     sessionCookie = null;
     Navigator.pushReplacementNamed(context, '/login');
     return {'status': 'error', 'message': 'Session expired. Please login again.'};
   }
   ```

4. **Implement Logout**
   ```dart
   static Future<void> logout() async {
     if (sessionCookie != null) {
       await http.post(
         Uri.parse('$baseUrl/logout.php'),
         headers: {'cookie': sessionCookie!},
       );
     }
     sessionCookie = null;
   }
   ```

## Rollback Plan

If issues occur, rollback by:

1. **Restore Previous PHP Files**
   ```bash
   # Remove authentication checks from all API files
   # Restore original versions without auth_helper.php include
   ```

2. **Keep Database Changes**
   ```bash
   # The admin_users table can remain - it won't affect functionality
   # Or drop it if needed:
   # DROP TABLE IF EXISTS admin_users;
   ```

## Security Hardening (Recommended)

### 1. HTTPS Configuration
- [ ] Ensure all traffic uses HTTPS
- [ ] Configure HSTS header
- [ ] Set secure flag on session cookies

### 2. Session Security
- [ ] Set session timeout (e.g., 30 minutes)
- [ ] Implement session regeneration on login
- [ ] Add CSRF protection for state-changing operations

### 3. Rate Limiting
- [ ] Implement login attempt rate limiting
- [ ] Add IP-based throttling for failed logins
- [ ] Consider using fail2ban or similar tools

### 4. Monitoring
- [ ] Set up logging for authentication events
- [ ] Monitor for suspicious login patterns
- [ ] Alert on multiple failed login attempts

### 5. Additional Hardening
- [ ] Implement password complexity requirements
- [ ] Add password expiration policy
- [ ] Enable account lockout after failed attempts
- [ ] Implement audit logging for sensitive operations

## Troubleshooting

### Issue: Sessions not working
**Solution:** Check PHP session configuration and directory permissions
```bash
# Check session save path
php -i | grep session.save_path

# Ensure directory is writable
ls -la /tmp | grep sess
```

### Issue: CORS errors with cookies
**Solution:** Update CORS headers in db_config.php
```php
header("Access-Control-Allow-Origin: https://your-frontend-domain.com");
header("Access-Control-Allow-Credentials: true");
```

### Issue: 401 errors after successful login
**Solution:** Verify session cookies are being sent
```bash
# Check if Set-Cookie header is present in login response
curl -i -X POST https://app.efficientgroupdubai.com/backend/login.php \
  -d "username=admin&password=admin123" | grep Set-Cookie
```

## Support Contacts

- Security Team: [security@yourdomain.com]
- DevOps Team: [devops@yourdomain.com]
- On-Call Engineer: [oncall@yourdomain.com]

## Sign-off

- [ ] Database migration completed
- [ ] All files deployed
- [ ] Authentication tested and working
- [ ] Default password changed
- [ ] Client application updated
- [ ] Documentation reviewed
- [ ] Stakeholders notified

**Deployed by:** _______________  
**Date:** _______________  
**Verified by:** _______________  
**Date:** _______________
