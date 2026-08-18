<?php
// Include authentication check - must be authenticated to access this API
require_once "../auth_check.php";

include_once "../db_config.php";
header('Content-Type: application/json');

$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($action) {
    case 'get_rooms':
        $flat_id = $_GET['flat_id'] ?? null;
        if ($flat_id) {
            $sql = "SELECT r.*, f.flat_number FROM rooms r 
                    JOIN flats f ON r.flat_id = f.id 
                    WHERE r.flat_id = ? ORDER BY r.id DESC";
            $stmt = $conn->prepare($sql);
            if ($stmt === false) {
                echo json_encode(['status' => 'error', 'message' => 'Prepare failed: ' . $conn->error]);
                break;
            }
            $stmt->bind_param("i", $flat_id);
            $stmt->execute();
            $result = $stmt->get_result();
        } else {
            $sql = "SELECT r.*, f.flat_number FROM rooms r 
                    JOIN flats f ON r.flat_id = f.id 
                    ORDER BY r.id DESC";
            $result = $conn->query($sql);
        }

        $rooms = [];
        while ($row = $result->fetch_assoc()) {
            $rooms[] = $row;
        }
        echo json_encode(['status' => 'success', 'data' => $rooms]);
        break;

    case 'add_room':
        $flat_id = $_POST['flat_id'] ?? null;
        $room_number = $_POST['room_number'] ?? '';
        $max_occupancy = $_POST['max_occupancy'] ?? 1;

        if (empty($room_number) || empty($flat_id)) {
            echo json_encode(['status' => 'error', 'message' => 'Room number and Flat selection are required']);
            break;
        }

        $stmt = $conn->prepare("INSERT INTO rooms (flat_id, room_number, max_occupancy) VALUES (?, ?, ?)");
        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Prepare failed: ' . $conn->error]);
            break;
        }
        $stmt->bind_param("isi", $flat_id, $room_number, $max_occupancy);

        if ($stmt->execute()) {
            echo json_encode(['status' => 'success', 'message' => 'Room added successfully', 'id' => $conn->insert_id]);
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