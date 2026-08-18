<?php
// Include authentication check
require_once 'auth_check.php';

// Require authentication for dashboard stats
require_authentication();

require_once 'db_config.php';

header('Content-Type: application/json');

$stats = [];

$queries = [
    "RE owners" => "SELECT COUNT(*) as count FROM re_owners",
    "Lease Owners" => "SELECT COUNT(*) as count FROM lease_owners",
    "Flats" => "SELECT COUNT(*) as count FROM flats",
    "Rooms" => "SELECT COUNT(*) as count FROM rooms",
    "Bed-spaces" => "SELECT COUNT(*) as count FROM bed_spaces",
    "Guests" => "SELECT COUNT(*) as count FROM guests",
    "Rental-Records" => "SELECT COUNT(*) as count FROM rental_records"
];

foreach ($queries as $label => $query) {
    if ($result = $conn->query($query)) {
        $row = $result->fetch_assoc();
        $stats[] = [
            "title" => $label,
            "count" => (int) $row['count']
        ];
    } else {
        $stats[] = [
            "title" => $label,
            "count" => 0
        ];
    }
}

echo json_encode(["status" => "success", "data" => $stats]);

$conn->close();
?>