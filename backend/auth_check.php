<?php
/**
 * Authentication Check Middleware
 * This file should be included at the top of all protected API endpoints
 * to ensure only authenticated users can access them.
 */

// Configure secure session settings
if (session_status() === PHP_SESSION_NONE) {
    // Set secure session parameters before starting session
    ini_set('session.cookie_httponly', '1');  // Prevent JavaScript access to session cookie
    ini_set('session.use_only_cookies', '1'); // Only use cookies for session ID
    ini_set('session.cookie_samesite', 'Strict'); // CSRF protection
    
    // For production with HTTPS, uncomment the following line:
    // ini_set('session.cookie_secure', '1');  // Only send cookie over HTTPS
    
    // Session timeout: 1 hour (3600 seconds)
    ini_set('session.gc_maxlifetime', '3600');
    
    session_start();
    
    // Regenerate session ID periodically to prevent session fixation
    if (!isset($_SESSION['last_regeneration'])) {
        $_SESSION['last_regeneration'] = time();
    } elseif (time() - $_SESSION['last_regeneration'] > 300) { // Every 5 minutes
        session_regenerate_id(true);
        $_SESSION['last_regeneration'] = time();
    }
}

/**
 * Check if the current request is authenticated
 * @return bool True if authenticated, false otherwise
 */
function is_authenticated() {
    return isset($_SESSION['authenticated']) && 
           $_SESSION['authenticated'] === true && 
           isset($_SESSION['user_id']);
}

/**
 * Require authentication or terminate with error
 * Call this function at the beginning of protected endpoints
 */
function require_authentication() {
    if (!is_authenticated()) {
        http_response_code(401);
        echo json_encode([
            'status' => 'error', 
            'message' => 'Unauthorized. Please login to access this resource.',
            'error_code' => 'AUTH_REQUIRED'
        ]);
        exit;
    }
}

/**
 * Get the current authenticated user ID
 * @return int|null User ID if authenticated, null otherwise
 */
function get_current_user_id() {
    return is_authenticated() ? $_SESSION['user_id'] : null;
}
?>
