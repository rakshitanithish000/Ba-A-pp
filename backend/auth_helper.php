<?php
// Authentication helper for API endpoints
// This file should be included in all protected API endpoints

// Start session if not already started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

/**
 * Check if the user is authenticated
 * Returns true if authenticated, false otherwise
 */
function is_authenticated() {
    return isset($_SESSION['admin_user_id']) && !empty($_SESSION['admin_user_id']);
}

/**
 * Require authentication for the current request
 * If not authenticated, sends a 401 JSON response and exits
 */
function require_authentication() {
    if (!is_authenticated()) {
        http_response_code(401);
        echo json_encode([
            'status' => 'error',
            'message' => 'Authentication required. Please login first.'
        ]);
        exit;
    }
}

/**
 * Get the current authenticated user ID
 * Returns the user ID if authenticated, null otherwise
 */
function get_authenticated_user_id() {
    return $_SESSION['admin_user_id'] ?? null;
}
?>
