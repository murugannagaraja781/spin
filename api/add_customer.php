<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Read input (could be from raw json or form-data)
    $input = json_decode(file_get_contents('php://input'), true);
    $name = trim($input['name'] ?? $_POST['name'] ?? '');
    $mobile = trim($input['mobile'] ?? $_POST['mobile'] ?? '');

    if (empty($name)) {
        echo json_encode(["status" => "error", "message" => "Customer name is required."]);
        $conn->close();
        exit;
    }

    $stmt = $conn->prepare("INSERT INTO customers (name, mobile) VALUES (?, ?)");
    $stmt->bind_param("ss", $name, $mobile);
    if ($stmt->execute()) {
        $new_id = $stmt->insert_id;
        echo json_encode([
            "status" => "success",
            "message" => "Customer added successfully.",
            "data" => [
                "id" => (int)$new_id,
                "name" => $name,
                "mobile" => $mobile
            ]
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to add customer: " . $conn->error]);
    }
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
