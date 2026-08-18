<?php
// Include authentication check - this will exit if user is not authenticated
require_once "../auth_check.php";

include_once "../db_config.php";
header('Content-Type: application/json');

$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($action) {
    case 'get_rental_records':
        $guest_id = $_GET['guest_id'] ?? null;
        if ($guest_id) {
            $sql = "SELECT rr.*, g.name as guest_name, b.bed_name, r.room_number, f.flat_number 
                    FROM rental_records rr 
                    JOIN guests g ON rr.guest_id = g.id 
                    JOIN bed_spaces b ON g.bed_space_id = b.id 
                    JOIN rooms r ON b.room_id = r.id 
                    JOIN flats f ON r.flat_id = f.id 
                    WHERE rr.guest_id = ? ORDER BY rr.payment_date DESC";
            $stmt = $conn->prepare($sql);
            if ($stmt === false) {
                echo json_encode(['status' => 'error', 'message' => 'Prepare failed: ' . $conn->error]);
                break;
            }
            $stmt->bind_param("i", $guest_id);
            $stmt->execute();
            $result = $stmt->get_result();
        } else {
            $sql = "SELECT rr.*, g.name as guest_name, b.bed_name, r.room_number, f.flat_number 
                    FROM rental_records rr 
                    JOIN guests g ON rr.guest_id = g.id 
                    JOIN bed_spaces b ON g.bed_space_id = b.id 
                    JOIN rooms r ON b.room_id = r.id 
                    JOIN flats f ON r.flat_id = f.id 
                    ORDER BY rr.payment_date DESC";
            $result = $conn->query($sql);
        }

        $records = [];
        while ($row = $result->fetch_assoc()) {
            $records[] = $row;
        }
        echo json_encode(['status' => 'success', 'data' => $records]);
        break;

    case 'add_rental_record':
        $guest_id = $_POST['guest_id'] ?? null;
        $amount_paid = $_POST['amount_paid'] ?? 0;
        $payment_date = $_POST['payment_date'] ?? date('Y-m-d');
        $payment_month = $_POST['payment_month'] ?? '';
        $payment_status = $_POST['payment_status'] ?? 'Paid';

        if (empty($guest_id) || empty($amount_paid)) {
            echo json_encode(['status' => 'error', 'message' => 'Guest and Amount are required']);
            break;
        }

        $stmt = $conn->prepare("INSERT INTO rental_records (guest_id, amount_paid, payment_date, payment_month, payment_status) VALUES (?, ?, ?, ?, ?)");
        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Prepare failed: ' . $conn->error]);
            break;
        }
        $stmt->bind_param("idsss", $guest_id, $amount_paid, $payment_date, $payment_month, $payment_status);

        if ($stmt->execute()) {
            echo json_encode(['status' => 'success', 'message' => 'Payment recorded successfully', 'id' => $conn->insert_id]);
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