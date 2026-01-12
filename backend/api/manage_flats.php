<?php
include_once "../db_config.php";
header('Content-Type: application/json');

$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($action) {
    case 'get_flats':
        $sql = "SELECT f.*, l.name as lease_owner_name 
                FROM flats f 
                LEFT JOIN lease_owners l ON f.lease_owner_id = l.id 
                ORDER BY f.id DESC";
        $result = $conn->query($sql);
        $flats = [];
        while ($row = $result->fetch_assoc()) {
            $flats[] = $row;
        }
        echo json_encode(['status' => 'success', 'data' => $flats]);
        break;

    case 'add_flat':
        $lease_owner_id = $_POST['lease_owner_id'] ?? null;
        $flat_number = $_POST['flat_number'] ?? '';
        $bhk_type = $_POST['bhk_type'] ?? '1BHK';
        $address = $_POST['address'] ?? '';

        if (empty($flat_number) || empty($lease_owner_id)) {
            echo json_encode(['status' => 'error', 'message' => 'Flat number and Lease Owner are required']);
            break;
        }

        $stmt = $conn->prepare("INSERT INTO flats (lease_owner_id, flat_number, bhk_type, address) VALUES (?, ?, ?, ?)");
        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Prepare failed: ' . $conn->error]);
            break;
        }
        $stmt->bind_param("isss", $lease_owner_id, $flat_number, $bhk_type, $address);

        if ($stmt->execute()) {
            echo json_encode(['status' => 'success', 'message' => 'Flat added successfully', 'id' => $conn->insert_id]);
        } else {
            echo json_encode(['status' => 'error', 'message' => $conn->error]);
        }
        break;

    default:
        echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
        break;
}

$conn->close();
?>