<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

$columns_to_add = [
    'latitude' => "VARCHAR(50) DEFAULT NULL",
    'longitude' => "VARCHAR(50) DEFAULT NULL",
    'quantity' => "INT DEFAULT 1",
    'order_total' => "DECIMAL(10,2) DEFAULT 0.00",
    'discount_applied' => "DECIMAL(10,2) DEFAULT 0.00",
    'net_amount' => "DECIMAL(10,2) DEFAULT 0.00",
    'spin_eligible' => "TINYINT DEFAULT 1"
];

$added = [];
$errors = [];

foreach ($columns_to_add as $column => $definition) {
    // Check if column exists
    $result = $conn->query("SHOW COLUMNS FROM winners LIKE '$column'");
    if ($result && $result->num_rows == 0) {
        // Column does not exist, add it
        $alter_query = "ALTER TABLE winners ADD COLUMN $column $definition";
        if ($conn->query($alter_query)) {
            $added[] = $column;
        } else {
            $errors[] = "Failed to add $column: " . $conn->error;
        }
    }
}

// Check if settings table exists
$result = $conn->query("SHOW TABLES LIKE 'settings'");
if ($result && $result->num_rows == 0) {
    $create_settings = "CREATE TABLE settings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        app_title VARCHAR(255) NOT NULL DEFAULT 'மினிக்குட்டி பீடி',
        app_subtitle VARCHAR(255) NOT NULL DEFAULT 'മിനിക്കുട്ടി ബീഡി',
        premium_title VARCHAR(255) NOT NULL DEFAULT '💎 PREMIUM SPIN & WIN 💎',
        logo_path VARCHAR(500) DEFAULT NULL,
        superadmin_password VARCHAR(255) NOT NULL DEFAULT 'superadmin123',
        salesman_password VARCHAR(255) NOT NULL DEFAULT 'admin123',
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )";
    if ($conn->query($create_settings)) {
        $added[] = 'settings_table';
        $conn->query("INSERT IGNORE INTO settings (id, app_title, app_subtitle, premium_title, superadmin_password, salesman_password) VALUES (1, 'மினிக்குட்டி பீடி', 'മിനിക്കുട്ടി ബീഡി', '💎 PREMIUM SPIN & WIN 💎', 'superadmin123', 'admin123')");
    } else {
        $errors[] = "Failed to create settings table: " . $conn->error;
    }
} else {
    // Add columns to existing settings table if missing
    $settings_columns_to_add = [
        'superadmin_password' => "VARCHAR(255) NOT NULL DEFAULT 'superadmin123'",
        'salesman_password' => "VARCHAR(255) NOT NULL DEFAULT 'admin123'"
    ];
    foreach ($settings_columns_to_add as $column => $definition) {
        $result = $conn->query("SHOW COLUMNS FROM settings LIKE '$column'");
        if ($result && $result->num_rows == 0) {
            $alter_query = "ALTER TABLE settings ADD COLUMN $column $definition";
            if ($conn->query($alter_query)) {
                $added[] = "settings_$column";
            } else {
                $errors[] = "Failed to add $column to settings: " . $conn->error;
            }
        }
    }
}

// Force update settings to match new launch branding logo and app title
try {
    $conn->query("UPDATE settings SET app_title = 'Mini kutty Beedi', app_subtitle = 'Mini kutty Beedi', logo_path = 'api/uploads/logo.jpg' WHERE id = 1");
} catch (Exception $e) {
    // Suppress errors if settings table is being constructed
}

echo json_encode([
    "status" => empty($errors) ? "success" : "partial_error",
    "added" => $added,
    "errors" => $errors
]);

$conn->close();
?>
