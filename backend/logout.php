<?php
require_once 'auth.php';

header('Content-Type: application/json');

// Clear the authentication session
clearAuthSession();

echo json_encode([
    'status' => 'success',
    'message' => 'Logged out successfully'
]);
?>
