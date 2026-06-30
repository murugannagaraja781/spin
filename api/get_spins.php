<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $stmt = $conn->prepare("SELECT id, prize_name, probability FROM spins ORDER BY id ASC");
    $stmt->execute();
    $result = $stmt->get_result();
    
    $spins = [];
    while ($row = $result->fetch_assoc()) {
        $spins[] = [
            'id' => $row['id'],
            'prize_name' => $row['prize_name'],
            'probability' => $row['probability']
        ];
    }
    
    echo json_encode(["status" => "success", "data" => $spins]);
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
