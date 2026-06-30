<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

$result = $conn->query("SELECT app_title, app_subtitle, premium_title, logo_path, superadmin_password, salesman_password FROM settings WHERE id = 1");
if ($result && $row = $result->fetch_assoc()) {
    echo json_encode([
        "status" => "success",
        "app_title" => $row["app_title"],
        "app_subtitle" => $row["app_subtitle"],
        "premium_title" => $row["premium_title"],
        "logo_path" => $row["logo_path"],
        "superadmin_password" => $row["superadmin_password"],
        "salesman_password" => $row["salesman_password"]
    ]);
} else {
    // Fallback default settings
    echo json_encode([
        "status" => "success",
        "app_title" => "மினிக்குட்டி பீடி",
        "app_subtitle" => "മിനിക്കുട്ടി ബീഡി",
        "premium_title" => "💎 PREMIUM SPIN & WIN 💎",
        "logo_path" => null,
        "superadmin_password" => "superadmin123",
        "salesman_password" => "admin123"
    ]);
}
$conn->close();
?>
