<?php
// Include the database configuration from the parent folder
include_once "../db_config.php";

// Set response type to JSON
header('Content-Type: application/json');

$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($action) {
    case 'get_re_owners':
        // Select strictly the columns from the Excel schema + the primary key
        $result = $conn->query("SELECT id, re_id, name, city, phone, contact_person, status FROM re_owners ORDER BY id DESC");
        $owners = [];
        while ($row = $result->fetch_assoc()) {
            $owners[] = $row;
        }
        echo json_encode(['status' => 'success', 'data' => $owners]);
        break;

    case 'add_re_owner':
        try {
            $re_id = $_POST['re_id'] ?? '';
            $name = $_POST['name'] ?? '';
            $city = $_POST['city'] ?? '';
            $phone = $_POST['phone'] ?? '';
            $contact_person = $_POST['contact_person'] ?? '';
            $status = $_POST['status'] ?? 'Active';

            if (empty($name)) {
                echo json_encode(['status' => 'error', 'message' => 'Name is required']);
                break;
            }

            // Check if re_id already exists
            if (!empty($re_id)) {
                $checkStmt = $conn->prepare("SELECT id FROM re_owners WHERE re_id = ?");
                $checkStmt->bind_param("s", $re_id);
                $checkStmt->execute();
                if ($checkStmt->get_result()->num_rows > 0) {
                    echo json_encode(['status' => 'error', 'message' => 'This RE ID already exists. Please use a unique ID.']);
                    break;
                }
            }

            $stmt = $conn->prepare("INSERT INTO re_owners (re_id, name, city, phone, contact_person, status) VALUES (?, ?, ?, ?, ?, ?)");
            if ($stmt === false) {
                throw new Exception('Prepare failed: ' . $conn->error);
            }
            $stmt->bind_param("ssssss", $re_id, $name, $city, $phone, $contact_person, $status);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'RE Owner added successfully', 'id' => $conn->insert_id]);
            } else {
                throw new Exception('Execute failed: ' . $stmt->error);
            }
        } catch (Exception $e) {
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        }
        break;

    case 'update_re_owner':
        try {
            $id = $_POST['id'] ?? null;
            $re_id = $_POST['re_id'] ?? '';
            $name = $_POST['name'] ?? '';
            $city = $_POST['city'] ?? '';
            $phone = $_POST['phone'] ?? '';
            $contact_person = $_POST['contact_person'] ?? '';
            $status = $_POST['status'] ?? 'Active';

            if (!$id || empty($name)) {
                echo json_encode(['status' => 'error', 'message' => 'ID and Name are required']);
                break;
            }

            // Check if another record already has this re_id
            if (!empty($re_id)) {
                $checkStmt = $conn->prepare("SELECT id FROM re_owners WHERE re_id = ? AND id != ?");
                $checkStmt->bind_param("si", $re_id, $id);
                $checkStmt->execute();
                if ($checkStmt->get_result()->num_rows > 0) {
                    echo json_encode(['status' => 'error', 'message' => 'This RE ID is already assigned to another owner.']);
                    break;
                }
            }

            $stmt = $conn->prepare("UPDATE re_owners SET re_id = ?, name = ?, city = ?, phone = ?, contact_person = ?, status = ? WHERE id = ?");
            if ($stmt === false) {
                throw new Exception('Prepare failed: ' . $conn->error);
            }
            $stmt->bind_param("ssssssi", $re_id, $name, $city, $phone, $contact_person, $status, $id);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'RE Owner updated successfully']);
            } else {
                throw new Exception('Execute failed: ' . $stmt->error);
            }
        } catch (Exception $e) {
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        }
        break;

    case 'delete_re_owner':
        try {
            $id = $_POST['id'] ?? null;
            if (!$id) {
                echo json_encode(['status' => 'error', 'message' => 'ID is required']);
                break;
            }

            $stmt = $conn->prepare("DELETE FROM re_owners WHERE id = ?");
            if ($stmt === false) {
                throw new Exception('Prepare failed: ' . $conn->error);
            }
            $stmt->bind_param("i", $id);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'RE Owner deleted successfully']);
            } else {
                throw new Exception('Execute failed: ' . $stmt->error);
            }
        } catch (Exception $e) {
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        }
        break;

    case 'get_lease_owners':
        // We join with re_owners to show who they lease from
        $sql = "SELECT l.*, r.name as re_owner_name 
                FROM lease_owners l 
                LEFT JOIN re_owners r ON l.re_owner_id = r.id 
                ORDER BY l.id DESC";
        $result = $conn->query($sql);
        $owners = [];
        while ($row = $result->fetch_assoc()) {
            $owners[] = $row;
        }
        echo json_encode(['status' => 'success', 'data' => $owners]);
        break;

    case 'add_lease_owner':
        $re_owner_id = $_POST['re_owner_id'] ?? null;
        $name = $_POST['name'] ?? '';
        $phone = $_POST['phone'] ?? '';
        $company_name = $_POST['company_name'] ?? '';

        if (empty($name)) {
            echo json_encode(['status' => 'error', 'message' => 'Name is required']);
            break;
        }

        $stmt = $conn->prepare("INSERT INTO lease_owners (re_owner_id, name, phone, company_name) VALUES (?, ?, ?, ?)");
        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Prepare failed: ' . $conn->error]);
            break;
        }
        $stmt->bind_param("isss", $re_owner_id, $name, $phone, $company_name);

        if ($stmt->execute()) {
            echo json_encode(['status' => 'success', 'message' => 'Lease Owner added successfully', 'id' => $conn->insert_id]);
        } else {
            echo json_encode(['status' => 'error', 'message' => $conn->error]);
        }
        break;

    case 'update_lease_owner':
        try {
            $id = $_POST['id'] ?? null;
            $re_owner_id = $_POST['re_owner_id'] ?? null;
            $name = $_POST['name'] ?? '';
            $phone = $_POST['phone'] ?? '';
            $company_name = $_POST['company_name'] ?? '';

            if (!$id || empty($name)) {
                echo json_encode(['status' => 'error', 'message' => 'ID and Name are required']);
                break;
            }

            $stmt = $conn->prepare("UPDATE lease_owners SET re_owner_id = ?, name = ?, phone = ?, company_name = ? WHERE id = ?");
            if ($stmt === false) {
                throw new Exception('Prepare failed: ' . $conn->error);
            }
            $stmt->bind_param("isssi", $re_owner_id, $name, $phone, $company_name, $id);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Lease Owner updated successfully']);
            } else {
                throw new Exception('Execute failed: ' . $stmt->error);
            }
        } catch (Exception $e) {
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        }
        break;

    case 'delete_lease_owner':
        try {
            $id = $_POST['id'] ?? null;
            if (!$id) {
                echo json_encode(['status' => 'error', 'message' => 'ID is required']);
                break;
            }

            $stmt = $conn->prepare("DELETE FROM lease_owners WHERE id = ?");
            if ($stmt === false) {
                throw new Exception('Prepare failed: ' . $conn->error);
            }
            $stmt->bind_param("i", $id);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Lease Owner deleted successfully']);
            } else {
                throw new Exception('Execute failed: ' . $stmt->error);
            }
        } catch (Exception $e) {
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        }
        break;

    default:
        echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
        break;
}

$conn->close();
?>