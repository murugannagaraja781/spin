<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $name = trim($input['name'] ?? $_POST['name'] ?? '');

    if (!empty($name)) {
        $stmt = $conn->prepare("INSERT INTO salesmen (name) VALUES (?)");
        $stmt->bind_param("s", $name);
        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Salesman added successfully!"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to add salesman: " . $stmt->error]);
        }
        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid salesman name."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
