<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $query = "SELECT w.*, c.file_path FROM winners w LEFT JOIN customer_photos c ON w.photo_id = c.id ORDER BY w.created_at DESC";
    $result = $conn->query($query);
    
    $winners = [];
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $winners[] = [
                'id' => $row['id'],
                'salesman_name' => $row['salesman_name'],
                'product_name' => $row['product_name'],
                'customer_name' => $row['customer_name'],
                'mobile_number' => $row['mobile_number'],
                'prize_won' => $row['prize_won'],
                'photo_path' => $row['file_path'] ? 'api/' . $row['file_path'] : null,
                'latitude' => $row['latitude'],
                'longitude' => $row['longitude'],
                'quantity' => (int)($row['quantity'] ?? 1),
                'order_total' => (float)($row['order_total'] ?? 0.0),
                'discount_applied' => (float)($row['discount_applied'] ?? 0.0),
                'net_amount' => (float)($row['net_amount'] ?? 0.0),
                'spin_eligible' => (int)($row['spin_eligible'] ?? 1),
                'created_at' => $row['created_at']
            ];
        }
    }
    
    echo json_encode(["status" => "success", "data" => $winners]);
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
