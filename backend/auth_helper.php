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
function is_authenticated() {
    return isset($_SESSION['user_id']) && !empty($_SESSION['user_id']);
}

/**
 * Require authentication for the current request
 * Sends a 401 Unauthorized response and exits if not authenticated
 */
function require_authentication() {
    if (!is_authenticated()) {
        http_response_code(401);
        echo json_encode([
            'status' => 'error',
            'message' => 'Unauthorized. Please login to access this resource.'
        ]);
        exit;
    }
}

/**
 * Get the current authenticated user ID
 * @return int|null User ID if authenticated, null otherwise
 */
function get_current_user_id() {
    return $_SESSION['user_id'] ?? null;
}

/**
 * Set the authenticated user session
 * @param int $user_id The user ID to authenticate
 */
function set_authenticated_user($user_id) {
    $_SESSION['user_id'] = $user_id;
    $_SESSION['login_time'] = time();
}

/**
 * Clear the authenticated user session (logout)
 */
function clear_authentication() {
    session_unset();
    session_destroy();
}
?>
