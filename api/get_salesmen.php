<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $stmt = $conn->prepare("SELECT id, name FROM salesmen");
    $stmt->execute();
    $result = $stmt->get_result();
    
    $salesmen = [];
    while ($row = $result->fetch_assoc()) {
        $salesmen[] = [
            "id" => intval($row["id"]),
            "name" => $row["name"]
        ];
    }
    
    echo json_encode(["status" => "success", "salesmen" => $salesmen]);
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
