-- Clean Schema & Sample Data for Rental Management System
-- This script drops tables in the correct order (children first) to avoid foreign key errors.
-- WARNING: This script will DROP and RECREATE your tables. All existing data in these tables will be lost.

-- Temporarily disable foreign key checks for safety
SET FOREIGN_KEY_CHECKS = 0;

-- 1. Drop tables in REVERSE order of dependency (Children first)
DROP TABLE IF EXISTS rental_records;
DROP TABLE IF EXISTS guests;
DROP TABLE IF EXISTS bed_spaces;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS flats;
DROP TABLE IF EXISTS lease_owners;
DROP TABLE IF EXISTS re_owners;

-- 2. Create tables in Correct Order of dependency (Parents first)

-- Table 1: RE Owners
CREATE TABLE re_owners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    re_id VARCHAR(50),
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    phone VARCHAR(20),
    contact_person VARCHAR(255),
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table 2: Lease Owners
CREATE TABLE lease_owners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    re_owner_id INT,
    lease_owner_id_text VARCHAR(50) UNIQUE,
    name VARCHAR(255) NOT NULL,
    nationality VARCHAR(100),
    eid_ref VARCHAR(100),
    expiry_date DATE,
    phone VARCHAR(20),
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    remarks TEXT,
    FOREIGN KEY (re_owner_id) REFERENCES re_owners(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table 3: Flats
CREATE TABLE flats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lease_owner_id INT,
    flat_number VARCHAR(50) NOT NULL,
    bhk_type ENUM('Studio', '1BHK', '2BHK', '3BHK', '4BHK', 'Other') DEFAULT '1BHK',
    address TEXT,
    FOREIGN KEY (lease_owner_id) REFERENCES lease_owners(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table 4: Rooms
CREATE TABLE rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flat_id INT,
    room_number VARCHAR(50) NOT NULL,
    max_occupancy INT DEFAULT 1,
    FOREIGN KEY (flat_id) REFERENCES flats(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table 5: Bed-Spaces
CREATE TABLE bed_spaces (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT,
    bed_name VARCHAR(50) NOT NULL,
    status ENUM('Available', 'Occupied', 'Maintenance') DEFAULT 'Available',
    monthly_rent DECIMAL(10,2),
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table 6: Guests
CREATE TABLE guests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bed_space_id INT,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    id_proof_number VARCHAR(100),
    check_in_date DATE,
    FOREIGN KEY (bed_space_id) REFERENCES bed_spaces(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table 7: Rental Records
CREATE TABLE rental_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT,
    amount_paid DECIMAL(10,2),
    payment_date DATE,
    payment_month VARCHAR(20),
    payment_status ENUM('Paid', 'Partial', 'Pending') DEFAULT 'Paid',
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- --- INSERT SAMPLE DATA ---

-- 1. RE Owners
INSERT INTO re_owners (re_id, name, city, phone, contact_person, status) VALUES 
('RE001', 'Global Properties', 'Dubai', '+971501112233', 'John Doe', 'Active'),
('RE002', 'Elite Estates', 'Abu Dhabi', '+971502223344', 'Jane Smith', 'Active');

-- 2. Lease Owners
INSERT INTO lease_owners (re_owner_id, lease_owner_id_text, name, nationality, eid_ref, expiry_date, phone, status, remarks) VALUES 
(1, 'TN001', 'Ahmed Al-Farsi', 'Omani', '784-1234-5678901-1', '2026-12-31', '+971504445566', 'Active', 'Al-Farsi Rentals'),
(1, 'TN002', 'Sarah Smith', 'British', '784-5678-1234567-2', '2027-05-15', '+971507778899', 'Active', 'Smith Management'),
(2, 'TN003', 'Mohammed Rashid', 'Emirati', '784-9876-5432109-3', '2026-09-20', '+971501234567', 'Active', 'Rashid Property Group');

-- 3. Flats
INSERT INTO flats (lease_owner_id, flat_number, bhk_type, address) VALUES 
(1, '101', '2BHK', 'Building A, Marina, Dubai'),
(1, '202', '1BHK', 'Building A, Marina, Dubai'),
(2, '505', 'Studio', 'Building B, Deira, Dubai'),
(3, '1204', '3BHK', 'Elite Tower, Reem Island, Abu Dhabi');

-- 4. Rooms
INSERT INTO rooms (flat_id, room_number, max_occupancy) VALUES 
(1, 'R1', 2),
(1, 'R2', 2),
(2, 'R1', 1),
(3, 'R1', 4),
(4, 'Master Room', 2);

-- 5. Bed-Spaces
INSERT INTO bed_spaces (room_id, bed_name, status, monthly_rent) VALUES 
(1, 'Bed A', 'Available', 1500.00),
(1, 'Bed B', 'Occupied', 1500.00),
(2, 'Bed A', 'Available', 1600.00),
(4, 'Bed 1', 'Occupied', 800.00),
(4, 'Bed 2', 'Available', 800.00),
(5, 'Bed Left', 'Available', 2500.00);

-- 6. Guests
INSERT INTO guests (bed_space_id, name, phone, id_proof_number, check_in_date) VALUES 
(2, 'Michael Scott', '+971551234567', 'E1234567', '2025-12-01'),
(4, 'Jim Halpert', '+971557654321', 'E7654321', '2026-01-05');

-- 7. Rental Records
INSERT INTO rental_records (guest_id, amount_paid, payment_date, payment_month, payment_status) VALUES 
(1, 1500.00, '2025-12-05', 'December 2025', 'Paid'),
(2, 800.00, '2026-01-07', 'January 2026', 'Paid');

-- 8. Admin Users (default password: admin123)
INSERT INTO admin_users (username, password) VALUES 
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');
