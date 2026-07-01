<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = intval($input['id'] ?? $_POST['id'] ?? 0);
    $name = trim($input['name'] ?? $_POST['name'] ?? '');
    $price = floatval($input['price'] ?? $_POST['price'] ?? 0.0);

    if ($id > 0 && !empty($name)) {
        $stmt = $conn->prepare("UPDATE products SET name = ?, price = ? WHERE id = ?");
        $stmt->bind_param("sdi", $name, $price, $id);
        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Product updated successfully!"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to update product: " . $stmt->error]);
        }
        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid parameters. Please provide ID, Name, and Price."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
