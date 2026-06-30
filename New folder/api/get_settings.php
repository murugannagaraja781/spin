<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

$result = $conn->query("SELECT app_title, app_subtitle, premium_title, logo_path FROM settings WHERE id = 1");
if ($result && $row = $result->fetch_assoc()) {
    echo json_encode([
        "status" => "success",
        "app_title" => $row["app_title"],
        "app_subtitle" => $row["app_subtitle"],
        "premium_title" => $row["premium_title"],
        "logo_path" => $row["logo_path"]
    ]);
} else {
    // Fallback default settings
    echo json_encode([
        "status" => "success",
        "app_title" => "மினிக்குட்டி பீடி",
        "app_subtitle" => "மிനിക്കുട്ടി ബീഡി",
        "premium_title" => "💎 PREMIUM SPIN & WIN 💎",
        "logo_path" => null
    ]);
}
$conn->close();
?>
