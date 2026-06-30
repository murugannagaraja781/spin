<?php
session_start();
if (!isset($_SESSION['superadmin']) || $_SESSION['superadmin'] !== true) {
    header("Location: login.php");
    exit;
}
require_once 'config.php';

// Filter inputs
$date_from = $_GET['date_from'] ?? '';
$date_to = $_GET['date_to'] ?? '';
$salesman_filter = $_GET['salesman'] ?? '';
$product_filter = $_GET['product'] ?? '';

header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename=lucky_spin_winners_' . date('Y-m-d') . '.csv');

$output = fopen('php://output', 'w');
fputcsv($output, array('ID', 'Date', 'Salesman Name', 'Product Name', 'Customer Name', 'Mobile Number', 'Prize Won', 'Latitude', 'Longitude'));

$query = "SELECT id, created_at, salesman_name, product_name, customer_name, mobile_number, prize_won, latitude, longitude FROM winners WHERE 1=1";

if ($date_from) {
    $query .= " AND DATE(created_at) >= '" . $conn->real_escape_string($date_from) . "'";
}
if ($date_to) {
    $query .= " AND DATE(created_at) <= '" . $conn->real_escape_string($date_to) . "'";
}
if ($salesman_filter) {
    $query .= " AND salesman_name = '" . $conn->real_escape_string($salesman_filter) . "'";
}
if ($product_filter) {
    $query .= " AND product_name = '" . $conn->real_escape_string($product_filter) . "'";
}

$query .= " ORDER BY created_at DESC";
$result = $conn->query($query);

while ($row = $result->fetch_assoc()) {
    fputcsv($output, $row);
}

fclose($output);
$conn->close();
?>
