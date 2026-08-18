<?php
include_once "../db_config.php";
include_once "../auth_helper.php";

// Require authentication for all operations
require_authentication();

header('Content-Type: application/json');

$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($action) {
    case 'get_bed_spaces':
        $room_id = $_GET['room_id'] ?? null;
        if ($room_id) {
            $sql = "SELECT b.*, r.room_number, f.flat_number 
                    FROM bed_spaces b 
                    JOIN rooms r ON b.room_id = r.id 
                    JOIN flats f ON r.flat_id = f.id 
                    WHERE b.room_id = ? ORDER BY b.id DESC";
            $stmt = $conn->prepare($sql);
            if ($stmt === false) {
                echo json_encode(['status' => 'error', 'message' => 'Prepare failed: ' . $conn->error]);
                break;
            }
            $stmt->bind_param("i", $room_id);
            $stmt->execute();
            $result = $stmt->get_result();
        } else {
            $sql = "SELECT b.*, r.room_number, f.flat_number 
                    FROM bed_spaces b 
                    JOIN rooms r ON b.room_id = r.id 
                    JOIN flats f ON r.flat_id = f.id 
                    ORDER BY b.id DESC";
            $result = $conn->query($sql);
        }

        $beds = [];
        while ($row = $result->fetch_assoc()) {
            $beds[] = $row;
        }
        echo json_encode(['status' => 'success', 'data' => $beds]);
        break;

    case 'add_bed_space':
        $room_id = $_POST['room_id'] ?? null;
        $bed_name = $_POST['bed_name'] ?? '';
        $monthly_rent = $_POST['monthly_rent'] ?? 0;
        $status = $_POST['status'] ?? 'Available';

        if (empty($bed_name) || empty($room_id)) {
            echo json_encode(['status' => 'error', 'message' => 'Bed name and Room selection are required']);
            break;
        }

        $stmt = $conn->prepare("INSERT INTO bed_spaces (room_id, bed_name, monthly_rent, status) VALUES (?, ?, ?, ?)");
        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Prepare failed: ' . $conn->error]);
            break;
        }
        $stmt->bind_param("isds", $room_id, $bed_name, $monthly_rent, $status);

        if ($stmt->execute()) {
            echo json_encode(['status' => 'success', 'message' => 'Bed-space added successfully', 'id' => $conn->insert_id]);
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