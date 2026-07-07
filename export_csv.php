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
$export_type = $_GET['export_type'] ?? 'all';

header('Content-Type: text/csv; charset=utf-8');

$filename = 'all_sales_report_' . date('Ymd_His') . '.csv';
if ($export_type === 'spin') {
    $filename = 'spin_sales_report_' . date('Ymd_His') . '.csv';
} elseif ($export_type === 'direct') {
    $filename = 'direct_sales_report_' . date('Ymd_His') . '.csv';
}
header('Content-Disposition: attachment; filename=' . $filename);

$output = fopen('php://output', 'w');
fputcsv($output, array('ID', 'Date', 'Salesman Name', 'Product Name', 'Qty', 'Customer Name', 'Mobile Number', 'Spin Eligible', 'Prize Won/Status'));

$query = "SELECT id, created_at, salesman_name, product_name, quantity, customer_name, mobile_number, spin_eligible, prize_won FROM winners WHERE 1=1 AND product_name NOT LIKE '%Multiple%'";

if ($date_from) {
    $query .= " AND DATE(created_at) >= '" . $conn->real_escape_string($date_from) . "'";
}
if ($date_to) {
    $query .= " AND DATE(created_at) <= '" . $conn->real_escape_string($date_to) . "'";
}
if ($salesman_filter !== '') {
    $query .= " AND TRIM(salesman_name) = '" . $conn->real_escape_string(trim($salesman_filter)) . "'";
}
if ($product_filter !== '') {
    $query .= " AND TRIM(product_name) = '" . $conn->real_escape_string(trim($product_filter)) . "'";
}
if ($export_type === 'spin') {
    $query .= " AND spin_eligible = 1";
} elseif ($export_type === 'direct') {
    $query .= " AND spin_eligible = 0";
}

$query .= " ORDER BY created_at DESC";
$result = $conn->query($query);

while ($row = $result->fetch_assoc()) {
    $prize_won = $row['prize_won'];
    if ($prize_won) {
        $clean_prize = preg_replace('/[^0-9.]/', '', $prize_won);
        $clean_prize = rtrim($clean_prize, '.');
        $prize_display = ($clean_prize !== '') ? $clean_prize : $prize_won;
    } else {
        $prize_display = ($row['spin_eligible'] == 1 ? '-' : 'Direct Checkout');
    }

    fputcsv($output, array(
        $row['id'],
        $row['created_at'],
        $row['salesman_name'],
        $row['product_name'],
        $row['quantity'] ?? 1,
        $row['customer_name'],
        $row['mobile_number'],
        ($row['spin_eligible'] == 1 ? 'Yes' : 'No'),
        $prize_display
    ));
}

fclose($output);
$conn->close();
?>
