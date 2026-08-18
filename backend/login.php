<?php
require_once 'db_config.php';
require_once 'auth_helper.php';

header('Content-Type: application/json');

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Please provide both username and password"]);
    exit;
}

$stmt = $conn->prepare("SELECT id, password FROM admin_users WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc();
    if (password_verify($password, $user['password'])) {
        // Set authenticated session
        set_authenticated_user($user['id']);
        
        echo json_encode([
            "status" => "success",
            "message" => "Login successful",
            "user_id" => $user['id'],
            "session_id" => session_id()
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid password"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "User not found"]);
}

$stmt->close();
$conn->close();
?>