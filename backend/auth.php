<?php
/**
 * Authentication Helper
 * Provides session-based authentication for API endpoints
 */

// Start session if not already started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

/**
 * Check if the current request is authenticated
 * @return bool True if authenticated, false otherwise
 */
function isAuthenticated() {
    return isset($_SESSION['user_id']) && !empty($_SESSION['user_id']);
}

/**
 * Require authentication for the current request
 * Sends JSON error response and exits if not authenticated
 * @return void
 */
function requireAuth() {
    if (!isAuthenticated()) {
        http_response_code(401);
        header('Content-Type: application/json');
        echo json_encode([
            'status' => 'error',
            'message' => 'Authentication required. Please login first.',
            'error_code' => 'UNAUTHORIZED'
        ]);
        exit;
    }
}

/**
 * Get the current authenticated user ID
 * @return int|null User ID if authenticated, null otherwise
 */
function getCurrentUserId() {
    return $_SESSION['user_id'] ?? null;
}

/**
 * Get the current authenticated username
 * @return string|null Username if authenticated, null otherwise
 */
function getCurrentUsername() {
    return $_SESSION['username'] ?? null;
}

/**
 * Set authentication session data
 * @param int $userId User ID
 * @param string $username Username
 * @return void
 */
function setAuthSession($userId, $username) {
    $_SESSION['user_id'] = $userId;
    $_SESSION['username'] = $username;
    $_SESSION['login_time'] = time();
    
    // Regenerate session ID to prevent session fixation attacks
    session_regenerate_id(true);
}

/**
 * Clear authentication session data
 * @return void
 */
function clearAuthSession() {
    $_SESSION = array();
    
    // Destroy the session cookie
    if (isset($_COOKIE[session_name()])) {
        setcookie(session_name(), '', time() - 3600, '/');
    }
    
    session_destroy();
}
?>
