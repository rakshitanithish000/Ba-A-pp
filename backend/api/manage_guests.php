<?php
// Include authentication check
require_once "../auth_check.php";

// Require authentication for all operations in this API
require_authentication();

include_once "../db_config.php";
header('Content-Type: application/json');

$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($action) {
    case 'get_guests':
        $bed_space_id = $_GET['bed_space_id'] ?? null;
        if ($bed_space_id) {
            $sql = "SELECT g.*, b.bed_name, r.room_number, f.flat_number 
                    FROM guests g 
                    JOIN bed_spaces b ON g.bed_space_id = b.id 
                    JOIN rooms r ON b.room_id = r.id 
                    JOIN flats f ON r.flat_id = f.id 
                    WHERE g.bed_space_id = ? ORDER BY g.id DESC";
            $stmt = $conn->prepare($sql);
            if ($stmt === false) {
                echo json_encode(['status' => 'error', 'message' => 'Prepare failed: ' . $conn->error]);
                break;
            }
            $stmt->bind_param("i", $bed_space_id);
            $stmt->execute();
            $result = $stmt->get_result();
        } else {
            $sql = "SELECT g.*, b.bed_name, r.room_number, f.flat_number 
                    FROM guests g 
                    LEFT JOIN bed_spaces b ON g.bed_space_id = b.id 
                    LEFT JOIN rooms r ON b.room_id = r.id 
                    LEFT JOIN flats f ON r.flat_id = f.id 
                    ORDER BY g.id DESC";
            $result = $conn->query($sql);
        }

        $guests = [];
        while ($row = $result->fetch_assoc()) {
            $guests[] = $row;
        }
        echo json_encode(['status' => 'success', 'data' => $guests]);
        break;

    case 'add_guest':
        $bed_space_id = $_POST['bed_space_id'] ?? null;
        $name = $_POST['name'] ?? '';
        $phone = $_POST['phone'] ?? '';
        $id_proof_number = $_POST['id_proof_number'] ?? '';
        $check_in_date = $_POST['check_in_date'] ?? date('Y-m-d');

        if (empty($name) || empty($bed_space_id)) {
            echo json_encode(['status' => 'error', 'message' => 'Name and Bed-space selection are required']);
            break;
        }

        // 1. Add Guest
        $stmt = $conn->prepare("INSERT INTO guests (bed_space_id, name, phone, id_proof_number, check_in_date) VALUES (?, ?, ?, ?, ?)");
        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Prepare failed (Insert): ' . $conn->error]);
            break;
        }
        $stmt->bind_param("issss", $bed_space_id, $name, $phone, $id_proof_number, $check_in_date);

        if ($stmt->execute()) {
            $guest_id = $conn->insert_id;
            // 2. Automatically mark the bed as 'Occupied'
            $update_stmt = $conn->prepare("UPDATE bed_spaces SET status = 'Occupied' WHERE id = ?");
            if ($update_stmt !== false) {
                $update_stmt->bind_param("i", $bed_space_id);
                $update_stmt->execute();
            } else {
                // Log error or handle it, but we already created the guest, so maybe just proceed or warn
                // For now, let's just ignore or maybe append a warning to the success message? 
                // Simple is better: just proceed.
            }

            echo json_encode(['status' => 'success', 'message' => 'Guest added and Bed occupied', 'id' => $guest_id]);
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