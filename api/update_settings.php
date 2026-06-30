<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $app_title = trim($input['app_title'] ?? $_POST['app_title'] ?? '');
    $app_subtitle = trim($input['app_subtitle'] ?? $_POST['app_subtitle'] ?? '');
    $premium_title = trim($input['premium_title'] ?? $_POST['premium_title'] ?? '');

    // Get current values to prevent overwriting with empty defaults
    $curr_res = $conn->query("SELECT superadmin_password, salesman_password FROM settings WHERE id = 1");
    $curr_row = $curr_res ? $curr_res->fetch_assoc() : null;

    $superadmin_password = trim($input['superadmin_password'] ?? $_POST['superadmin_password'] ?? '');
    if (empty($superadmin_password)) {
        $superadmin_password = $curr_row ? $curr_row['superadmin_password'] : 'superadmin123';
    }

    $salesman_password = trim($input['salesman_password'] ?? $_POST['salesman_password'] ?? '');
    if (empty($salesman_password)) {
        $salesman_password = $curr_row ? $curr_row['salesman_password'] : 'admin123';
    }

    if (!empty($app_title)) {
        // Initialize settings row if it doesn't exist
        $conn->query("INSERT IGNORE INTO settings (id, app_title, app_subtitle, premium_title, superadmin_password, salesman_password) VALUES (1, 'மினிக்குட்டி பீடி', 'മിനിക്കുട്ടി ബീഡി', '💎 PREMIUM SPIN & WIN 💎', 'superadmin123', 'admin123')");

        $stmt = $conn->prepare("UPDATE settings SET app_title = ?, app_subtitle = ?, premium_title = ?, superadmin_password = ?, salesman_password = ? WHERE id = 1");
        $stmt->bind_param("sssss", $app_title, $app_subtitle, $premium_title, $superadmin_password, $salesman_password);
        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Branding settings updated successfully!"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to update settings: " . $stmt->error]);
        }
        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => "App Title is required."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
