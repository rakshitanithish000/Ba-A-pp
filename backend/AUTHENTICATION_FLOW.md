# Authentication Flow Diagram

## Before Patch (VULNERABLE)

```
┌─────────────┐
│   Attacker  │
└──────┬──────┘
       │
       │ POST /backend/api/manage_owners.php?action=delete_lease_owner
       │ Body: id=1
       │ (NO AUTHENTICATION)
       │
       ▼
┌──────────────────────────────────────┐
│  manage_owners.php                   │
│  ┌────────────────────────────────┐  │
│  │ switch($action)                │  │
│  │   case 'delete_lease_owner':   │  │
│  │     DELETE FROM lease_owners   │  │
│  │     WHERE id = ?               │  │
│  └────────────────────────────────┘  │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│         Database                     │
│  ┌────────────────────────────────┐  │
│  │ DELETE lease_owner record      │  │
│  │ CASCADE DELETE:                │  │
│  │   → flats                      │  │
│  │   → rooms                      │  │
│  │   → bed_spaces                 │  │
│  │   → rental_records             │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘

Result: ❌ UNAUTHORIZED DELETION SUCCESSFUL
```

## After Patch (SECURE)

### Scenario 1: Unauthenticated Request (BLOCKED)

```
┌─────────────┐
│   Attacker  │
└──────┬──────┘
       │
       │ POST /backend/api/manage_owners.php?action=delete_lease_owner
       │ Body: id=1
       │ (NO SESSION COOKIE)
       │
       ▼
┌──────────────────────────────────────┐
│  manage_owners.php                   │
│  ┌────────────────────────────────┐  │
│  │ require_once "auth_check.php"  │  │
│  │ require_authentication()       │  │
│  │                                │  │
│  │ ┌────────────────────────────┐ │  │
│  │ │ is_authenticated()?        │ │  │
│  │ │ → Check $_SESSION          │ │  │
│  │ │ → NO valid session         │ │  │
│  │ │ → Return 401 Unauthorized  │ │  │
│  │ │ → exit()                   │ │  │
│  │ └────────────────────────────┘ │  │
│  │                                │  │
│  │ // Code never reaches here     │  │
│  │ switch($action) { ... }        │  │
│  └────────────────────────────────┘  │
└──────────────┬───────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Response: 401 Unauthorized             │
│  {                                      │
│    "status": "error",                   │
│    "message": "Unauthorized...",        │
│    "error_code": "AUTH_REQUIRED"        │
│  }                                      │
└─────────────────────────────────────────┘

Result: ✅ ATTACK BLOCKED - NO DATABASE ACCESS
```

### Scenario 2: Authenticated Request (ALLOWED)

```
┌──────────────────┐
│ Legitimate Admin │
└────────┬─────────┘
         │
         │ Step 1: Login
         │ POST /backend/login.php
         │ Body: username=admin&password=admin123
         │
         ▼
┌──────────────────────────────────────┐
│  login.php                           │
│  ┌────────────────────────────────┐  │
│  │ session_start()                │  │
│  │ Verify credentials             │  │
│  │ $_SESSION['authenticated']=true│  │
│  │ $_SESSION['user_id'] = 1       │  │
│  │ Return session info            │  │
│  └────────────────────────────────┘  │
└──────────────┬───────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Response: 200 OK                       │
│  {                                      │
│    "status": "success",                 │
│    "session_id": "abc123...",           │
│    "session_token": "xyz789..."         │
│  }                                      │
│  Set-Cookie: PHPSESSID=abc123...       │
└──────────────┬──────────────────────────┘
               │
               │ Step 2: Make authenticated request
               │ POST /backend/api/manage_owners.php?action=delete_lease_owner
               │ Body: id=1
               │ Cookie: PHPSESSID=abc123...
               │
               ▼
┌──────────────────────────────────────┐
│  manage_owners.php                   │
│  ┌────────────────────────────────┐  │
│  │ require_once "auth_check.php"  │  │
│  │ require_authentication()       │  │
│  │                                │  │
│  │ ┌────────────────────────────┐ │  │
│  │ │ is_authenticated()?        │ │  │
│  │ │ → Check $_SESSION          │ │  │
│  │ │ → Valid session found      │ │  │
│  │ │ → Continue execution       │ │  │
│  │ └────────────────────────────┘ │  │
│  │                                │  │
│  │ switch($action)                │  │
│  │   case 'delete_lease_owner':   │  │
│  │     Validate ID                │  │
│  │     DELETE FROM lease_owners   │  │
│  └────────────────────────────────┘  │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│         Database                     │
│  ┌────────────────────────────────┐  │
│  │ DELETE lease_owner record      │  │
│  │ (Authorized by admin)          │  │
│  └────────────────────────────────┘  │
└──────────────┬───────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Response: 200 OK                       │
│  {                                      │
│    "status": "success",                 │
│    "message": "Lease Owner deleted..."  │
│  }                                      │
└─────────────────────────────────────────┘

Result: ✅ AUTHORIZED DELETION SUCCESSFUL
```

## Security Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Request Flow                         │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Layer 1: Session Validation (auth_check.php)          │
│  ─────────────────────────────────────────────────────  │
│  • Check session exists                                 │
│  • Verify $_SESSION['authenticated'] === true           │
│  • Verify $_SESSION['user_id'] is set                  │
│  • Regenerate session ID periodically                   │
│  ─────────────────────────────────────────────────────  │
│  ❌ FAIL → Return 401 Unauthorized & exit()             │
│  ✅ PASS → Continue to Layer 2                          │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Layer 2: Action Processing (manage_owners.php)        │
│  ─────────────────────────────────────────────────────  │
│  • Parse action parameter                               │
│  • Validate input data                                  │
│  • Execute business logic                               │
│  ─────────────────────────────────────────────────────  │
│  ❌ FAIL → Return error message                         │
│  ✅ PASS → Continue to Layer 3                          │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Layer 3: Database Operation                            │
│  ─────────────────────────────────────────────────────  │
│  • Prepared statements (SQL injection protection)       │
│  • Execute query                                        │
│  • Return result                                        │
│  ─────────────────────────────────────────────────────  │
│  ✅ Success → Return success response                   │
└─────────────────────────────────────────────────────────┘
```

## Session Security Features

```
┌─────────────────────────────────────────────────────────┐
│              Session Configuration                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  🔒 HttpOnly Cookie                                     │
│     └─ Prevents JavaScript access (XSS protection)     │
│                                                         │
│  🔒 SameSite=Strict                                     │
│     └─ Prevents CSRF attacks                           │
│                                                         │
│  🔒 Session Regeneration (every 5 minutes)             │
│     └─ Prevents session fixation                       │
│                                                         │
│  🔒 Session Timeout (1 hour)                           │
│     └─ Limits exposure window                          │
│                                                         │
│  🔒 Secure Cookie (HTTPS only - production)            │
│     └─ Prevents man-in-the-middle attacks              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Attack Mitigation Summary

```
┌──────────────────────────────────────────────────────────────┐
│                    Attack Scenarios                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ❌ BEFORE: Unauthenticated Delete                          │
│     → Direct database deletion                              │
│     → Cascading data loss                                   │
│     → No audit trail                                        │
│                                                              │
│  ✅ AFTER: Authentication Required                          │
│     → 401 Unauthorized response                             │
│     → No database access                                    │
│     → Attack logged in web server logs                      │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ❌ BEFORE: Session Fixation                                │
│     → No session management                                 │
│     → N/A (no sessions existed)                             │
│                                                              │
│  ✅ AFTER: Session Regeneration                             │
│     → Session ID regenerated every 5 minutes                │
│     → Prevents session fixation attacks                     │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ❌ BEFORE: XSS Session Theft                               │
│     → No session cookies                                    │
│     → N/A (no sessions existed)                             │
│                                                              │
│  ✅ AFTER: HttpOnly Cookies                                 │
│     → JavaScript cannot access session cookie               │
│     → XSS cannot steal session                              │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ❌ BEFORE: CSRF Attacks                                    │
│     → No CSRF protection                                    │
│     → Any site could trigger actions                        │
│                                                              │
│  ✅ AFTER: SameSite=Strict                                  │
│     → Cookies only sent from same site                      │
│     → CSRF attacks blocked                                  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Compliance Mapping

```
┌─────────────────────────────────────────────────────────┐
│  OWASP Top 10 2021                                      │
│  ✅ A01:2021 - Broken Access Control                    │
│     → Fixed by implementing authentication              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  CWE (Common Weakness Enumeration)                      │
│  ✅ CWE-306: Missing Authentication for Critical Func   │
│     → All critical functions now require auth           │
│  ✅ CWE-862: Missing Authorization                      │
│     → Authorization checks implemented                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  NIST 800-53                                            │
│  ✅ AC-3: Access Enforcement                            │
│     → Access controls enforced via sessions             │
│  ✅ IA-2: Identification and Authentication             │
│     → Users must authenticate before access             │
└─────────────────────────────────────────────────────────┘
```
