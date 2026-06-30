<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config.php';

$salesmen = [];
$result = $conn->query("SELECT id, name FROM salesmen ORDER BY name ASC");
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $salesmen[] = $row["name"];
    }
    echo json_encode(["status" => "success", "salesmen" => $salesmen]);
} else {
    echo json_encode(["status" => "error", "message" => "Could not retrieve salesmen: " . $conn->error]);
}
$conn->close();
?>
