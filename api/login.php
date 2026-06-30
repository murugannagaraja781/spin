<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $password = trim($input['password'] ?? $_POST['password'] ?? '');

    // Default fallbacks
    $superadmin_pass = 'superadmin123';
    $salesman_pass = 'admin123';

    $result = $conn->query("SELECT superadmin_password, salesman_password FROM settings WHERE id = 1");
    if ($result && $result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $superadmin_pass = $row['superadmin_password'];
        $salesman_pass = $row['salesman_password'];
    }

    if ($password === $salesman_pass) {
        echo json_encode([
            "status" => "success",
            "role" => "user",
            "message" => "Login successful"
        ]);
    } elseif ($password === $superadmin_pass) {
        echo json_encode([
            "status" => "success",
            "role" => "admin",
            "message" => "Admin login successful"
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Invalid password"
        ]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
