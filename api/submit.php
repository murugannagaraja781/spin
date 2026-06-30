<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $salesman = $_POST['salesman'] ?? '';
    $product = $_POST['product'] ?? '';
    $customer_name = $_POST['customer_name'] ?? '';
    $mobile_number = $_POST['mobile_number'] ?? '';
    $prize = $_POST['prize'] ?? '';
    $latitude = $_POST['latitude'] ?? '';
    $longitude = $_POST['longitude'] ?? '';
    
    // New Order Metrics
    $quantity = isset($_POST['quantity']) ? (int)$_POST['quantity'] : 1;
    $order_total = isset($_POST['order_total']) ? (float)$_POST['order_total'] : 0.00;
    $discount_applied = isset($_POST['discount_applied']) ? (float)$_POST['discount_applied'] : 0.00;
    $net_amount = isset($_POST['net_amount']) ? (float)$_POST['net_amount'] : 0.00;
    $spin_eligible = isset($_POST['spin_eligible']) ? (int)$_POST['spin_eligible'] : 1;

    // Check if mobile number already played TODAY, only if they are trying to spin
    if ($spin_eligible == 1 && !empty($mobile_number)) {
        $check_stmt = $conn->prepare("SELECT id FROM winners WHERE mobile_number = ? AND DATE(created_at) = CURDATE() AND spin_eligible = 1");
        $check_stmt->bind_param("s", $mobile_number);
        $check_stmt->execute();
        $check_stmt->store_result();
        if ($check_stmt->num_rows > 0) {
            echo json_encode(["status" => "error", "message" => "This mobile number has already completed a spin today!"]);
            $check_stmt->close();
            $conn->close();
            exit;
        }
        $check_stmt->close();
    }

    // Handle File Upload
    $photo_id = null;
    if (isset($_FILES['photo']) && $_FILES['photo']['error'] == UPLOAD_ERR_OK) {
        $upload_dir = 'uploads/';
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0755, true);
        }
        
        $file_extension = pathinfo($_FILES['photo']['name'], PATHINFO_EXTENSION);
        $new_filename = uniqid('photo_', true) . '.' . $file_extension;
        $target_file = $upload_dir . $new_filename;

        if (move_uploaded_file($_FILES['photo']['tmp_name'], $target_file)) {
            $stmt = $conn->prepare("INSERT INTO customer_photos (file_path) VALUES (?)");
            $stmt->bind_param("s", $target_file);
            if ($stmt->execute()) {
                $photo_id = $stmt->insert_id;
            }
            $stmt->close();
        }
    }

    // Insert Winner/Order Data
    $stmt = $conn->prepare("INSERT INTO winners (salesman_name, product_name, customer_name, mobile_number, prize_won, photo_id, latitude, longitude, quantity, order_total, discount_applied, net_amount, spin_eligible) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssssissddddi", $salesman, $product, $customer_name, $mobile_number, $prize, $photo_id, $latitude, $longitude, $quantity, $order_total, $discount_applied, $net_amount, $spin_eligible);
    
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Order submitted successfully!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to submit order: " . $stmt->error]);
    }
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
