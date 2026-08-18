<?php
// Authentication check helper
// Include this file at the top of any API endpoint that requires authentication

// Start session if not already started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Check if user is authenticated
if (!isset($_SESSION['user_id']) || empty($_SESSION['user_id'])) {
    http_response_code(401);
    header('Content-Type: application/json');
    echo json_encode([
        'status' => 'error',
        'message' => 'Unauthorized. Please login first.',
        'error_code' => 'AUTH_REQUIRED'
    ]);
    exit;
}

// Optional: Check session timeout (30 minutes of inactivity)
$timeout_duration = 1800; // 30 minutes in seconds
if (isset($_SESSION['last_activity']) && (time() - $_SESSION['last_activity']) > $timeout_duration) {
    // Session expired
    session_unset();
    session_destroy();
    http_response_code(401);
    header('Content-Type: application/json');
    echo json_encode([
        'status' => 'error',
        'message' => 'Session expired. Please login again.',
        'error_code' => 'SESSION_EXPIRED'
    ]);
    exit;
}

// Update last activity timestamp
$_SESSION['last_activity'] = time();
?>
