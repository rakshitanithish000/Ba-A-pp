-- Admin Users Table for Authentication
-- This table stores admin user credentials for the rental management system

CREATE TABLE IF NOT EXISTS admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    status ENUM('Active', 'Inactive') DEFAULT 'Active'
);

-- Create a default admin user (username: admin, password: admin123)
-- Password is hashed using PHP's password_hash() with bcrypt
-- You should change this password after first login
INSERT INTO admin_users (username, password, email) 
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@example.com')
ON DUPLICATE KEY UPDATE username=username;

-- Note: The default password is 'admin123' - CHANGE THIS IMMEDIATELY after deployment
