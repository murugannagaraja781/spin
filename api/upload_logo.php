<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_FILES['logo']) && $_FILES['logo']['error'] === UPLOAD_ERR_OK) {
        $fileTmpPath = $_FILES['logo']['tmp_name'];
        $fileName = $_FILES['logo']['name'];
        
        $uploadFileDir = 'uploads/';
        if (!is_dir($uploadFileDir)) {
            mkdir($uploadFileDir, 0755, true);
        }

        $fileExtension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
        $newFileName = 'logo_' . time() . '.' . $fileExtension;
        $dest_path = $uploadFileDir . $newFileName;

        if (move_uploaded_file($fileTmpPath, $dest_path)) {
            $dbPath = 'api/' . $dest_path;
            
            // Initialize settings row if it doesn't exist
            $conn->query("INSERT IGNORE INTO settings (id, app_title, app_subtitle, premium_title, superadmin_password, salesman_password) VALUES (1, 'மினிக்குட்டி பீடி', 'മിനിക്കുട്ടി ബീഡി', '💎 PREMIUM SPIN & WIN 💎', 'superadmin123', 'admin123')");
            
            $stmt = $conn->prepare("UPDATE settings SET logo_path = ? WHERE id = 1");
            $stmt->bind_param("s", $dbPath);
            if ($stmt->execute()) {
                echo json_encode([
                    "status" => "success",
                    "message" => "Logo uploaded successfully!",
                    "logo_path" => $dbPath
                ]);
            } else {
                echo json_encode(["status" => "error", "message" => "Database update failed: " . $stmt->error]);
            }
            $stmt->close();
        } else {
            echo json_encode(["status" => "error", "message" => "Error moving the uploaded file."]);
        }
    } else {
        $errorCode = isset($_FILES['logo']) ? $_FILES['logo']['error'] : 'No file uploaded';
        echo json_encode(["status" => "error", "message" => "Upload failed. Error Code: " . $errorCode]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
}
$conn->close();
?>
