<?php
require_once 'db_config.php';

// Start session for authentication
session_start();

header('Content-Type: application/json');

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Please provide both username and password"]);
    exit;
}

$stmt = $conn->prepare("SELECT id, username, password FROM admin_users WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc();
    if (password_verify($password, $user['password'])) {
        // Regenerate session ID to prevent session fixation attacks
        session_regenerate_id(true);
        
        // Set session variables for authentication
        $_SESSION['authenticated'] = true;
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['username'] = $user['username'];
        $_SESSION['last_activity'] = time();
        
        // Set secure session cookie parameters
        $cookieParams = session_get_cookie_params();
        setcookie(
            session_name(),
            session_id(),
            [
                'expires' => time() + 86400, // 24 hours
                'path' => $cookieParams['path'],
                'domain' => $cookieParams['domain'],
                'secure' => isset($_SERVER['HTTPS']), // Only send over HTTPS if available
                'httponly' => true, // Prevent JavaScript access
                'samesite' => 'Lax' // CSRF protection
            ]
        );
        
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