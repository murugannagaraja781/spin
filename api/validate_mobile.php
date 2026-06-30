<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET' || $_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $mobile = trim($input['mobile'] ?? $_POST['mobile'] ?? $_GET['mobile'] ?? '');
    $product = trim($input['product'] ?? $_POST['product'] ?? $_GET['product'] ?? '');

    if (empty($mobile)) {
        echo json_encode(["status" => "error", "message" => "Mobile number is required."]);
        $conn->close();
        exit;
    }

    // Check if the mobile number has completed a spin today for this product
    $stmt = $conn->prepare("SELECT id FROM winners WHERE mobile_number = ? AND product_name = ? AND DATE(created_at) = CURDATE() AND spin_eligible = 1");
    $stmt->bind_param("ss", $mobile, $product);
    $stmt->execute();
    $stmt->store_result();
    
    if ($stmt->num_rows > 0) {
        echo json_encode([
            "status" => "error", 
            "message" => "This mobile number has already completed a spin today!"
        ]);
    } else {
        echo json_encode([
            "status" => "success", 
            "message" => "Mobile number is eligible."
        ]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
