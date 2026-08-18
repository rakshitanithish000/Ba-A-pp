<?php
require_once 'auth_helper.php';

header('Content-Type: application/json');

// Clear the authentication session
clear_authentication();

echo json_encode([
    "status" => "success",
    "message" => "Logged out successfully"
]);
?>
