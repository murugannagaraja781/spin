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

    // Check if mobile number already played
    $check_stmt = $conn->prepare("SELECT id FROM winners WHERE mobile_number = ?");
    $check_stmt->bind_param("s", $mobile_number);
    $check_stmt->execute();
    $check_stmt->store_result();
    if ($check_stmt->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "This mobile number has already been used for a spin!"]);
        $check_stmt->close();
        $conn->close();
        exit;
    }
    $check_stmt->close();

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

    // Insert Winner Data
    $stmt = $conn->prepare("INSERT INTO winners (salesman_name, product_name, customer_name, mobile_number, prize_won, photo_id, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssssiss", $salesman, $product, $customer_name, $mobile_number, $prize, $photo_id, $latitude, $longitude);
    
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Data saved successfully!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to save data."]);
    }
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
