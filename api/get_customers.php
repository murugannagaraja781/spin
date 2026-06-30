<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $result = $conn->query("SELECT id, name, mobile FROM customers ORDER BY name ASC");
    $customers = [];
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $customers[] = [
                'id' => (int)$row['id'],
                'name' => $row['name'],
                'mobile' => $row['mobile']
            ];
        }
    }
    echo json_encode(["status" => "success", "data" => $customers]);
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
