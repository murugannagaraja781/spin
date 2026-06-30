<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

$response = [];
try {
    if ($conn && !$conn->connect_error) {
        $response["status"] = "success";
        $response["message"] = "Database connection is working successfully!";
        
        // Fetch list of tables
        $tables = [];
        $result = $conn->query("SHOW TABLES");
        if ($result) {
            while ($row = $result->fetch_array()) {
                $tables[] = $row[0];
            }
            $response["created_tables"] = $tables;
        } else {
            $response["table_error"] = "Could not query tables: " . $conn->error;
        }
    } else {
        $response["status"] = "error";
        $response["message"] = "Connection failed: " . ($conn ? $conn->connect_error : "Connection object is null");
    }
} catch (Exception $e) {
    $response["status"] = "error";
    $response["message"] = "Exception caught: " . $e->getMessage();
}

echo json_encode($response);
if ($conn) {
    @$conn->close();
}
?>
