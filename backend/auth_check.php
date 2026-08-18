<?php
// Authentication check module
// Include this file at the beginning of any protected API endpoint

// Start session if not already started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Check if user is authenticated
if (!isset($_SESSION['authenticated']) || $_SESSION['authenticated'] !== true || !isset($_SESSION['user_id'])) {
    http_response_code(401);
    header('Content-Type: application/json');
    echo json_encode([
        'status' => 'error',
        'message' => 'Unauthorized. Please log in to access this resource.'
    ]);
    exit;
}

// Optional: Refresh session timeout on each request
$_SESSION['last_activity'] = time();
?>
