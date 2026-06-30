<?php
$host = "localhost";
$username = "u682341828_rootspin"; // Hostinger usually provides a specific DB username
$password = "Spin2026";     // Hostinger DB password
$dbname = "u682341828_spin";

$conn = new mysqli($host, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}
?>
