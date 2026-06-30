<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $prize_name = trim($input['prize_name'] ?? $_POST['prize_name'] ?? '');

    if (!empty($prize_name)) {
        $stmt = $conn->prepare("INSERT INTO spins (prize_name, probability) VALUES (?, 10.0)");
        $stmt->bind_param("s", $prize_name);
        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Prize added successfully!"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to add prize: " . $stmt->error]);
        }
        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid prize name."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
