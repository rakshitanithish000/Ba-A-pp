<?php
/**
 * Admin User Creation Script
 * 
 * This script helps create new admin users with hashed passwords.
 * Run this script from command line or temporarily place it in a secure location.
 * 
 * Usage:
 *   php create_admin_user.php <username> <password> [email]
 * 
 * Example:
 *   php create_admin_user.php john.doe SecurePass123 john@example.com
 * 
 * Security Note: Delete this file after creating your admin users!
 */

require_once 'db_config.php';

// Check if running from command line
if (php_sapi_name() !== 'cli') {
    die("This script must be run from the command line for security reasons.\n");
}

// Get command line arguments
$username = $argv[1] ?? null;
$password = $argv[2] ?? null;
$email = $argv[3] ?? null;

if (!$username || !$password) {
    echo "Usage: php create_admin_user.php <username> <password> [email]\n";
    echo "Example: php create_admin_user.php john.doe SecurePass123 john@example.com\n";
    exit(1);
}

// Validate username
if (strlen($username) < 3 || strlen($username) > 50) {
    die("Error: Username must be between 3 and 50 characters.\n");
}

// Validate password strength
if (strlen($password) < 8) {
    die("Error: Password must be at least 8 characters long.\n");
}

// Hash the password
$hashed_password = password_hash($password, PASSWORD_BCRYPT);

// Insert into database
$stmt = $conn->prepare("INSERT INTO admin_users (username, password, email) VALUES (?, ?, ?)");
if ($stmt === false) {
    die("Error preparing statement: " . $conn->error . "\n");
}

$stmt->bind_param("sss", $username, $hashed_password, $email);

if ($stmt->execute()) {
    echo "✓ Success! Admin user created:\n";
    echo "  Username: $username\n";
    echo "  Email: " . ($email ?: "Not provided") . "\n";
    echo "  User ID: " . $conn->insert_id . "\n";
    echo "\nThe password has been securely hashed and stored.\n";
    echo "\n⚠️  IMPORTANT: Delete this script after creating your admin users!\n";
} else {
    if ($conn->errno === 1062) {
        die("Error: Username '$username' already exists.\n");
    } else {
        die("Error creating user: " . $conn->error . "\n");
    }
}

$stmt->close();
$conn->close();
?>
