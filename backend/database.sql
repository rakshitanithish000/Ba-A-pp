-- Rental Management System Database Schema Backup
-- Created: 2026-01-07

-- 1. RE Owners
CREATE TABLE IF NOT EXISTS re_owners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    re_id VARCHAR(50),
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    phone VARCHAR(20),
    contact_person VARCHAR(255),
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Lease Owners
CREATE TABLE IF NOT EXISTS lease_owners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    re_owner_id INT,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    company_name VARCHAR(255),
    FOREIGN KEY (re_owner_id) REFERENCES re_owners(id) ON DELETE SET NULL
);

-- 3. Flats (Categorized by BHK)
CREATE TABLE IF NOT EXISTS flats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lease_owner_id INT,
    flat_number VARCHAR(50) NOT NULL,
    bhk_type ENUM('Studio', '1BHK', '2BHK', '3BHK', '4BHK', 'Other') DEFAULT '1BHK',
    address TEXT,
    FOREIGN KEY (lease_owner_id) REFERENCES lease_owners(id) ON DELETE CASCADE
);

-- 4. Rooms
CREATE TABLE IF NOT EXISTS rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flat_id INT,
    room_number VARCHAR(50) NOT NULL,
    max_occupancy INT DEFAULT 1,
    FOREIGN KEY (flat_id) REFERENCES flats(id) ON DELETE CASCADE
);

-- 5. Bed-Spaces
CREATE TABLE IF NOT EXISTS bed_spaces (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT,
    bed_name VARCHAR(50) NOT NULL,
    status ENUM('Available', 'Occupied', 'Maintenance') DEFAULT 'Available',
    monthly_rent DECIMAL(10,2),
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
);

-- 6. Guests
CREATE TABLE IF NOT EXISTS guests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bed_space_id INT,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    id_proof_number VARCHAR(100),
    check_in_date DATE,
    FOREIGN KEY (bed_space_id) REFERENCES bed_spaces(id) ON DELETE SET NULL
);

-- 7. Rental Records
CREATE TABLE IF NOT EXISTS rental_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT,
    amount_paid DECIMAL(10,2),
    payment_date DATE,
    payment_month VARCHAR(20),
    payment_status ENUM('Paid', 'Partial', 'Pending') DEFAULT 'Paid',
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE
);
