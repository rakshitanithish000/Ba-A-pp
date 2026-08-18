<?php
/**
 * Logout endpoint
 * Destroys the current session and logs out the user
 */

// Start session
session_start();

header('Content-Type: application/json');

// Destroy all session data
$_SESSION = array();

// Delete the session cookie
if (isset($_COOKIE[session_name()])) {
    setcookie(session_name(), '', time() - 3600, '/');
}

// Destroy the session
session_destroy();

echo json_encode([
    'status' => 'success',
    'message' => 'Logged out successfully'
]);
?>
