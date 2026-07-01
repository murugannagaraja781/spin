<?php
session_start();
if (!isset($_SESSION['superadmin']) || $_SESSION['superadmin'] !== true) {
    header("Location: login.php");
    exit;
}
require_once 'config.php';

// Handle Add/Delete Salesman, Spin Values, and Settings POST requests
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['action'])) {
    if ($_POST['action'] == 'add_salesman') {
        $name = trim($_POST['salesman_name'] ?? '');
        if (!empty($name)) {
            $stmt = $conn->prepare("INSERT INTO salesmen (name) VALUES (?)");
            $stmt->bind_param("s", $name);
            $stmt->execute();
            $stmt->close();
        }
        header("Location: dashboard.php");
        exit;
    }
    if ($_POST['action'] == 'delete_salesman') {
        $id = (int)($_POST['salesman_id'] ?? 0);
        if ($id > 0) {
            $stmt = $conn->prepare("DELETE FROM salesmen WHERE id = ?");
            $stmt->bind_param("i", $id);
            $stmt->execute();
            $stmt->close();
        }
        header("Location: dashboard.php");
        exit;
    }
    if ($_POST['action'] == 'add_spin') {
        $prize_name = trim($_POST['prize_name'] ?? '');
        if (!empty($prize_name)) {
            $stmt = $conn->prepare("INSERT INTO spins (prize_name, probability) VALUES (?, 10.0)");
            $stmt->bind_param("s", $prize_name);
            $stmt->execute();
            $stmt->close();
        }
        header("Location: dashboard.php");
        exit;
    }
    if ($_POST['action'] == 'delete_spin') {
        $id = (int)($_POST['spin_id'] ?? 0);
        if ($id > 0) {
            $stmt = $conn->prepare("DELETE FROM spins WHERE id = ?");
            $stmt->bind_param("i", $id);
            $stmt->execute();
            $stmt->close();
        }
        header("Location: dashboard.php");
        exit;
    }
    if ($_POST['action'] == 'add_product') {
        $name = trim($_POST['product_name'] ?? '');
        $price = floatval($_POST['product_price'] ?? 0.0);
        if (!empty($name) && $price >= 0) {
            $stmt = $conn->prepare("INSERT INTO products (name, price) VALUES (?, ?)");
            $stmt->bind_param("sd", $name, $price);
            $stmt->execute();
            $stmt->close();
        }
        header("Location: dashboard.php");
        exit;
    }
    if ($_POST['action'] == 'delete_product') {
        $id = (int)($_POST['product_id'] ?? 0);
        if ($id > 0) {
            $stmt = $conn->prepare("DELETE FROM products WHERE id = ?");
            $stmt->bind_param("i", $id);
            $stmt->execute();
            $stmt->close();
        }
        header("Location: dashboard.php");
        exit;
    }
    if ($_POST['action'] == 'delete_winner') {
        $id = (int)($_POST['winner_id'] ?? 0);
        $winner_ids = trim($_POST['winner_ids'] ?? '');
        if (!empty($winner_ids)) {
            $ids_arr = explode(',', $winner_ids);
            $clean_ids = array_map('intval', $ids_arr);
            $ids_str = implode(',', $clean_ids);
            $conn->query("DELETE FROM winners WHERE id IN ($ids_str)");
        } elseif ($id > 0) {
            $stmt = $conn->prepare("DELETE FROM winners WHERE id = ?");
            $stmt->bind_param("i", $id);
            $stmt->execute();
            $stmt->close();
        }
        header("Location: dashboard.php");
        exit;
    }
    if ($_POST['action'] == 'edit_product') {
        $id = (int)($_POST['product_id'] ?? 0);
        $name = trim($_POST['product_name'] ?? '');
        $price = floatval($_POST['product_price'] ?? 0.0);
        if ($id > 0 && !empty($name)) {
            $stmt = $conn->prepare("UPDATE products SET name = ?, price = ? WHERE id = ?");
            $stmt->bind_param("sdi", $name, $price, $id);
            $stmt->execute();
            $stmt->close();
        }
        header("Location: dashboard.php");
        exit;
    }
    if ($_POST['action'] == 'update_settings') {
        $app_title = trim($_POST['app_title'] ?? '');
        $app_subtitle = trim($_POST['app_subtitle'] ?? '');
        $premium_title = trim($_POST['premium_title'] ?? '');
        
        $logo_path = null;
        if (isset($_FILES['logo']) && $_FILES['logo']['error'] == UPLOAD_ERR_OK) {
            $upload_dir = 'api/uploads/';
            if (!is_dir($upload_dir)) {
                mkdir($upload_dir, 0755, true);
            }
            $file_extension = pathinfo($_FILES['logo']['name'], PATHINFO_EXTENSION);
            $new_filename = 'logo_' . time() . '.' . $file_extension;
            $target_file = $upload_dir . $new_filename;
            if (move_uploaded_file($_FILES['logo']['tmp_name'], $target_file)) {
                $logo_path = 'uploads/' . $new_filename;
            }
        }

        // Initialize settings row if it doesn't exist
        $conn->query("INSERT IGNORE INTO settings (id, app_title, app_subtitle, premium_title) VALUES (1, 'மினிக்குட்டி பீடி', 'മിനിക്കുട്ടി ബീഡി', '💎 PREMIUM SPIN & WIN 💎')");

        if ($logo_path) {
            $stmt = $conn->prepare("UPDATE settings SET app_title = ?, app_subtitle = ?, premium_title = ?, logo_path = ? WHERE id = 1");
            $stmt->bind_param("ssss", $app_title, $app_subtitle, $premium_title, $logo_path);
        } else {
            $stmt = $conn->prepare("UPDATE settings SET app_title = ?, app_subtitle = ?, premium_title = ? WHERE id = 1");
            $stmt->bind_param("sss", $app_title, $app_subtitle, $premium_title);
        }
        $stmt->execute();
        $stmt->close();
        
        header("Location: dashboard.php");
        exit;
    }
}

// Fetch current settings for pre-population
$settings_query = $conn->query("SELECT * FROM settings WHERE id = 1");
$settings = $settings_query ? $settings_query->fetch_assoc() : null;
$app_title_val = $settings['app_title'] ?? 'மினிக்குட்டி பீடி';
$app_subtitle_val = $settings['app_subtitle'] ?? 'മിനിക്കുട്ടി ബീഡി';
$premium_title_val = $settings['premium_title'] ?? '💎 PREMIUM SPIN & WIN 💎';
$logo_path_val = $settings['logo_path'] ?? '';

// Filter inputs
$date_from = $_GET['date_from'] ?? '';
$date_to = $_GET['date_to'] ?? '';
$salesman_filter = $_GET['salesman'] ?? '';
$product_filter = $_GET['product'] ?? '';
$sales_type = $_GET['sales_type'] ?? '';

// Build Query
$query = "SELECT w.*, c.file_path FROM winners w LEFT JOIN customer_photos c ON w.photo_id = c.id WHERE 1=1";

if ($date_from) {
    $query .= " AND DATE(w.created_at) >= '" . $conn->real_escape_string($date_from) . "'";
}
if ($date_to) {
    $query .= " AND DATE(w.created_at) <= '" . $conn->real_escape_string($date_to) . "'";
}
if ($salesman_filter) {
    $query .= " AND w.salesman_name = '" . $conn->real_escape_string($salesman_filter) . "'";
}
if ($product_filter) {
    $query .= " AND w.product_name = '" . $conn->real_escape_string($product_filter) . "'";
}
if ($sales_type === 'spin') {
    $query .= " AND w.spin_eligible = 1";
} elseif ($sales_type === 'direct') {
    $query .= " AND w.spin_eligible = 0";
}

$query .= " ORDER BY w.created_at DESC";
$result = $conn->query($query);

// Fetch Salesmen and Products for filter dropdowns
$salesmen_query = $conn->query("SELECT DISTINCT salesman_name FROM winners WHERE salesman_name IS NOT NULL");
$products_query = $conn->query("SELECT DISTINCT product_name FROM winners WHERE product_name IS NOT NULL");

// Generate Reports Data
$salesman_reports = $conn->query("SELECT salesman_name, COUNT(*) as total_spins FROM winners GROUP BY salesman_name");
$product_reports = $conn->query("SELECT product_name, COUNT(*) as total_spins FROM winners GROUP BY product_name");

// Overview Stats
$total_sales_val = 0.00;
$total_spins_val = 0;
$total_salesmen_val = 0;
$total_products_val = 0;
$today_sales_val = 0.00;

$m_sales = $conn->query("SELECT SUM(net_amount) as sum_val FROM winners")->fetch_assoc();
$total_sales_val = floatval($m_sales['sum_val'] ?? 0.00);

$m_spins = $conn->query("SELECT COUNT(*) as count_val FROM winners WHERE spin_eligible = 1")->fetch_assoc();
$total_spins_val = intval($m_spins['count_val'] ?? 0);

$m_salesmen = $conn->query("SELECT COUNT(*) as count_val FROM salesmen")->fetch_assoc();
$total_salesmen_val = intval($m_salesmen['count_val'] ?? 0);

$m_products = $conn->query("SELECT COUNT(*) as count_val FROM products")->fetch_assoc();
$total_products_val = intval($m_products['count_val'] ?? 0);

$m_today = $conn->query("SELECT SUM(net_amount) as sum_val FROM winners WHERE DATE(created_at) = CURDATE()")->fetch_assoc();
$today_sales_val = floatval($m_today['sum_val'] ?? 0.00);

// Daily Sales and Spins Trend for Chart.js
$chart_dates = [];
$chart_sales = [];
$chart_spins = [];
$chart_query = $conn->query("
    SELECT DATE(created_at) as date_val, SUM(net_amount) as total_sales, COUNT(id) as total_spins
    FROM winners
    GROUP BY DATE(created_at)
    ORDER BY DATE(created_at) ASC
    LIMIT 30
");
if ($chart_query) {
    while($row = $chart_query->fetch_assoc()) {
        $chart_dates[] = date('d M', strtotime($row['date_val']));
        $chart_sales[] = floatval($row['total_sales']);
        $chart_spins[] = intval($row['total_spins']);
    }
}

// Count Spin vs Direct Sales for Circle Chart
$spin_sales_count = 0;
$direct_sales_count = 0;
$pie_query = $conn->query("SELECT SUM(CASE WHEN spin_eligible = 1 THEN 1 ELSE 0 END) as spin_cnt, SUM(CASE WHEN spin_eligible = 0 THEN 1 ELSE 0 END) as direct_cnt FROM winners");
if ($pie_query) {
    $row = $pie_query->fetch_assoc();
    $spin_sales_count = intval($row['spin_cnt'] ?? 0);
    $direct_sales_count = intval($row['direct_cnt'] ?? 0);
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lucky Spin Admin Dashboard</title>
    <!-- Google Fonts Inter & Outfit -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@400;600;700;800&display=swap" rel="stylesheet">
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --bg-primary: #070c16;
            --bg-secondary: #0d1527;
            --accent-color: #00f2fe; /* Sky blue */
            --accent-green: #00e676; /* Emerald green */
            --text-main: #f1f5f9;
            --text-secondary: #94a3b8;
            --border-glass: rgba(0, 242, 254, 0.12);
            --card-glass: rgba(13, 21, 39, 0.85);
            --card-glass-green: rgba(0, 230, 118, 0.05);
            --card-glass-blue: rgba(0, 242, 254, 0.05);
        }
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-primary);
            background-image: radial-gradient(circle at 10% 20%, #0d1527 0%, #05080f 90%);
            margin: 0;
            padding: 30px;
            color: var(--text-main);
            min-height: 100vh;
        }
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border-glass);
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .header-title {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .header-title img {
            width: 50px;
            height: 50px;
            object-fit: contain;
            background: #000814;
            padding: 5px;
            border-radius: 8px;
            border: 1px solid var(--accent-color);
        }
        h1 {
            font-family: 'Outfit', sans-serif;
            font-size: 28px;
            font-weight: 800;
            margin: 0;
            letter-spacing: 0.5px;
            background: linear-gradient(135deg, #fff 0%, var(--accent-color) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        h2 {
            font-family: 'Outfit', sans-serif;
            font-size: 20px;
            font-weight: 700;
            color: var(--accent-color);
            margin-top: 0;
            margin-bottom: 20px;
            letter-spacing: 0.5px;
        }
        .logout-btn {
            background: transparent;
            color: #ff4c4c;
            border: 1px solid #ff4c4c;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        .logout-btn:hover {
            background: #ff4c4c;
            color: white;
            box-shadow: 0 0 10px rgba(255, 76, 76, 0.4);
        }
        
        /* Stats Grid Dashboard */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: var(--card-glass);
            border: 1px solid var(--border-glass);
            border-radius: 12px;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 15px;
            backdrop-filter: blur(10px);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0, 242, 254, 0.1);
        }
        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        .stat-icon.blue {
            background: rgba(0, 242, 254, 0.1);
            color: var(--accent-color);
            border: 1px solid rgba(0, 242, 254, 0.2);
        }
        .stat-icon.green {
            background: rgba(0, 230, 118, 0.1);
            color: var(--accent-green);
            border: 1px solid rgba(0, 230, 118, 0.2);
        }
        .stat-info {
            display: flex;
            flex-direction: column;
        }
        .stat-label {
            font-size: 12px;
            color: var(--text-secondary);
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .stat-value {
            font-size: 22px;
            font-weight: 700;
            color: #ffffff;
            margin-top: 4px;
        }

        .grid-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        .card {
            background: var(--card-glass);
            border: 1px solid var(--border-glass);
            border-radius: 12px;
            padding: 24px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
        }
        .form-group {
            display: flex;
            flex-direction: column;
            margin-bottom: 15px;
        }
        label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            margin-bottom: 6px;
        }
        input, select {
            background: rgba(0, 8, 20, 0.5);
            border: 1px solid rgba(0, 242, 254, 0.2);
            color: white;
            padding: 10px;
            border-radius: 6px;
            font-family: 'Inter', sans-serif;
            outline: none;
            transition: border-color 0.3s;
        }
        input:focus, select:focus {
            border-color: var(--accent-color);
        }
        .btn {
            background: var(--accent-color);
            color: #000;
            border: none;
            padding: 10px 16px;
            font-weight: 700;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            text-decoration: none;
        }
        .btn:hover {
            background: var(--accent-color-hover);
            box-shadow: 0 0 15px rgba(0, 242, 254, 0.4);
            transform: translateY(-1px);
        }
        .btn-red {
            background: #ff4c4c;
            color: white;
        }
        .btn-red:hover {
            background: #e03b3b;
            box-shadow: 0 0 15px rgba(255, 76, 76, 0.4);
        }
        .btn-secondary {
            background: rgba(255, 255, 255, 0.05);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.15);
            box-shadow: none;
        }
        .list-container {
            max-height: 200px;
            overflow-y: auto;
            border: 1px solid rgba(0, 242, 254, 0.1);
            border-radius: 6px;
            margin-top: 10px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        th, td {
            padding: 12px;
            font-size: 13.5px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }
        th {
            background-color: rgba(0, 8, 20, 0.6);
            color: var(--accent-color);
            font-weight: 600;
        }
        tr:hover {
            background: rgba(255, 255, 255, 0.02);
        }
        .filter-form {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
            background: var(--card-glass);
            border: 1px solid var(--border-glass);
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 30px;
        }
        .photo-thumbnail {
            width: 48px;
            height: 48px;
            object-fit: cover;
            border-radius: 6px;
            border: 1px solid rgba(0, 242, 254, 0.3);
            transition: transform 0.3s;
        }
        .photo-thumbnail:hover {
            transform: scale(1.1);
        }
        .map-iframe {
            border: 1px solid rgba(0, 242, 254, 0.2);
            border-radius: 6px;
        }
        .pill {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .pill-yes {
            background: rgba(0, 230, 118, 0.2);
            color: var(--accent-green);
            border: 1px solid rgba(0, 230, 118, 0.3);
        }
        .pill-no {
            background: rgba(244, 67, 54, 0.2);
            color: #e57373;
            border: 1px solid rgba(244, 67, 54, 0.3);
        }
        
        /* Dropdown Export menu style */
        .dropdown-menu {
            display: none;
            position: absolute;
            right: 0;
            top: 45px;
            background: #0d1527;
            border: 1px solid var(--accent-color);
            border-radius: 8px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.5);
            z-index: 100;
            min-width: 220px;
            padding: 5px 0;
        }
        .dropdown-menu a {
            display: block;
            padding: 12px 16px;
            color: var(--text-main);
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            transition: background 0.3s;
        }
        .dropdown-menu a:hover {
            background: rgba(0, 242, 254, 0.1);
            color: var(--accent-color);
        }
        .show {
            display: block !important;
        }
        
        /* SIDE NAVIGATION MENU CSS */
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-primary);
            background-image: radial-gradient(circle at 50% 10%, #0d1527 0%, #05080f 80%);
            margin: 0;
            padding: 0;
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: row;
        }

        /* Sidebar container */
        .sidebar {
            width: 260px;
            background: #040812;
            border-right: 1px solid var(--border-glass);
            display: flex;
            flex-direction: column;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 1000;
        }
        
        .sidebar-brand {
            padding: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            border-bottom: 1px solid var(--border-glass);
        }
        .sidebar-brand img {
            width: 38px;
            height: 38px;
            object-fit: contain;
            border-radius: 6px;
            border: 1px solid var(--accent-color);
        }
        .sidebar-brand h1 {
            font-family: 'Outfit', sans-serif;
            font-size: 18px;
            font-weight: 800;
            margin: 0;
            background: linear-gradient(135deg, #fff 0%, var(--accent-color) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .sidebar-menu {
            padding: 20px 14px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex: 1;
            overflow-y: auto;
        }
        .sidebar-menu a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            border-radius: 8px;
            transition: all 0.3s;
            cursor: pointer;
        }
        .sidebar-menu a:hover {
            color: var(--accent-color);
            background: rgba(0, 242, 254, 0.05);
        }
        .sidebar-menu a.active {
            color: #000 !important;
            background: linear-gradient(90deg, var(--accent-color) 0%, var(--accent-green) 100%) !important;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(0, 242, 254, 0.2);
        }
        .sidebar-menu a.active i, .sidebar-menu a.active span {
            color: #000 !important;
        }
        
        .sidebar-footer {
            padding: 20px;
            border-top: 1px solid var(--border-glass);
            text-align: center;
        }
        
        /* Main Layout Content Area */
        .main-content {
            margin-left: 260px;
            flex: 1;
            padding: 30px;
            box-sizing: border-box;
            min-height: 100vh;
        }
        
        .top-navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            border-bottom: 1px solid var(--border-glass);
            padding-bottom: 20px;
        }
        .section-header-title h2 {
            font-family: 'Outfit', sans-serif;
            font-size: 24px;
            font-weight: 800;
            margin: 0;
            color: #fff;
        }

        .dashboard-section {
            display: none;
            animation: fadeIn 0.3s ease-in-out forwards;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 992px) {
            body {
                flex-direction: column;
            }
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
                border-right: none;
                border-bottom: 1px solid var(--border-glass);
            }
            .sidebar-menu {
                flex-direction: row;
                overflow-x: auto;
                padding: 10px;
                gap: 12px;
            }
            .sidebar-menu a {
                padding: 8px 12px;
                white-space: nowrap;
            }
            .main-content {
                margin-left: 0;
                padding: 20px;
            }
        }
    </style>
</head>
<body>

    <!-- Left Sidebar Menu -->
    <div class="sidebar">
        <div class="sidebar-brand">
            <?php if ($logo_path_val): ?>
                <img src="api/<?= htmlspecialchars($logo_path_val) ?>" alt="Logo">
            <?php else: ?>
                <div style="font-size: 20px;">🏆</div>
            <?php endif; ?>
            <h1>Mini Kutty Beedi</h1>
        </div>
        <div class="sidebar-menu">
            <a id="menu-dashboard" onclick="showSection('dashboard')" class="active">📊 <span>Dashboard</span></a>
            <a id="menu-logs" onclick="showSection('logs')">🧾 <span>Sales Logs</span></a>
            <a id="menu-products" onclick="showSection('products')">📦 <span>Products</span></a>
            <a id="menu-salesmen" onclick="showSection('salesmen')">👨‍💼 <span>Salesmen</span></a>
            <a id="menu-spins" onclick="showSection('spins')">🎡 <span>Spin Prizes</span></a>
            <a id="menu-settings" onclick="showSection('settings')">⚙️ <span>Branding</span></a>
        </div>
        <div class="sidebar-footer">
            <a href="login.php?logout=true" class="logout-btn" style="display:block; width:100%; text-align:center; box-sizing:border-box;">🔒 LOGOUT</a>
        </div>
    </div>

    <!-- Main Content Panel Wrapper -->
    <div class="main-content">
        <!-- Top Navigation Bar -->
        <div class="top-navbar">
            <div class="section-header-title">
                <h2 id="active-section-title">Overview Dashboard</h2>
            </div>
            <div style="font-size: 13px; color: var(--text-secondary); font-weight: 500;">
                Admin Portal &bull; <span id="live-date"></span>
            </div>
        </div>

    <!-- SECTION 1: DASHBOARD OVERVIEW -->
    <div id="section-dashboard" class="dashboard-section" style="display: block;">
        <!-- Overview Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue">💰</div>
                <div class="stat-info">
                    <span class="stat-label">Total Sales</span>
                    <span class="stat-value">₹<?= number_format($total_sales_val, 2) ?></span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">🎡</div>
                <div class="stat-info">
                    <span class="stat-label">Total Spins</span>
                    <span class="stat-value"><?= $total_spins_val ?></span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue">👨‍💼</div>
                <div class="stat-info">
                    <span class="stat-label">Salesmen</span>
                    <span class="stat-value"><?= $total_salesmen_val ?></span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">📦</div>
                <div class="stat-info">
                    <span class="stat-label">Products Active</span>
                    <span class="stat-value"><?= $total_products_val ?></span>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue">📅</div>
                <div class="stat-info">
                    <span class="stat-label">Today's Sales</span>
                    <span class="stat-value">₹<?= number_format($today_sales_val, 2) ?></span>
                </div>
            </div>
        </div>

        <!-- Charts Section Grid -->
        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 25px; margin-bottom: 35px;">
            <!-- Sales Tracking Chart Card -->
            <div class="card" style="padding: 24px;">
                <h2>📊 Sales Tracking & Spins Trend</h2>
                <div style="width: 100%; height: 320px; position: relative;">
                    <canvas id="salesTrendChart"></canvas>
                </div>
            </div>

            <!-- Spin vs Direct Sales Distribution Chart Card -->
            <div class="card" style="padding: 24px; display: flex; flex-direction: column;">
                <h2>🍩 Sales Breakdown (Spin vs Direct)</h2>
                <div style="width: 100%; height: 260px; position: relative; display: flex; justify-content: center; align-items: center; margin-top: auto; margin-bottom: auto;">
                    <canvas id="salesBreakdownChart"></canvas>
                </div>
                <div style="display: flex; justify-content: space-around; margin-top: 15px; font-size: 13px; font-weight: 600;">
                    <span style="color: var(--accent-color);">🌀 Spin: <?= $spin_sales_count ?></span>
                    <span style="color: var(--accent-green);">🛍️ Direct: <?= $direct_sales_count ?></span>
                </div>
            </div>
        </div>
        
        <div class="grid-container" style="grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); margin-bottom: 0;">
            <!-- Salesmanwise spins report -->
            <div class="card">
                <h2>Salesman Report</h2>
                <div class="list-container" style="max-height: 250px;">
                    <table>
                        <thead><tr><th>Salesman</th><th>Total Orders/Spins</th></tr></thead>
                        <tbody>
                            <?php while($s = $salesman_reports->fetch_assoc()): ?>
                                <tr><td><?= htmlspecialchars($s['salesman_name'] ?? 'N/A') ?></td><td><?= $s['total_spins'] ?></td></tr>
                            <?php endwhile; ?>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Productwise spins report -->
            <div class="card">
                <h2>Product Report</h2>
                <div class="list-container" style="max-height: 250px;">
                    <table>
                        <thead><tr><th>Product</th><th>Total Orders/Spins</th></tr></thead>
                        <tbody>
                            <?php while($p = $product_reports->fetch_assoc()): ?>
                                <tr><td><?= htmlspecialchars($p['product_name'] ?? 'N/A') ?></td><td><?= $p['total_spins'] ?></td></tr>
                            <?php endwhile; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- SECTION 4: MANAGE SALESMEN -->
    <div id="section-salesmen" class="dashboard-section">
        <div class="grid-container" style="grid-template-columns: 1fr;">
            <!-- Manage Salesmen -->
            <div class="card">
                <h2>Manage Salesmen</h2>
                <form method="POST" style="display: flex; gap: 8px; margin-bottom: 12px;">
                    <input type="hidden" name="action" value="add_salesman">
                    <input type="text" name="salesman_name" placeholder="New Salesman Name" required style="flex: 1;">
                    <button type="submit" class="btn">➕ Add</button>
                </form>
                <div class="list-container">
                    <table>
                        <thead><tr><th>Name</th><th>Action</th></tr></thead>
                        <tbody>
                            <?php 
                            $salesmen_list = $conn->query("SELECT * FROM salesmen ORDER BY name ASC");
                            while($sm = $salesmen_list->fetch_assoc()): 
                            ?>
                                <tr>
                                    <td><?= htmlspecialchars($sm['name']) ?></td>
                                    <td>
                                        <form method="POST" style="margin:0;" onsubmit="return confirm('Delete <?= htmlspecialchars($sm['name']) ?>?');">
                                            <input type="hidden" name="action" value="delete_salesman">
                                            <input type="hidden" name="salesman_id" value="<?= $sm['id'] ?>">
                                            <button type="submit" class="btn btn-red" style="padding: 4px 8px; font-size: 11px;">❌ Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            <?php endwhile; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- SECTION 5: MANAGE SPIN VALUES -->
    <div id="section-spins" class="dashboard-section">
        <div class="grid-container" style="grid-template-columns: 1fr;">
            <!-- Manage Spin Wheel Values -->
            <div class="card">
                <h2>Manage Spin Wheel Values</h2>
                <form method="POST" style="display: flex; gap: 8px; margin-bottom: 12px;">
                    <input type="hidden" name="action" value="add_spin">
                    <input type="text" name="prize_name" placeholder="Spin Value (e.g. ₹5, ₹10)" required style="flex: 1;">
                    <button type="submit" class="btn">➕ Add</button>
                </form>
                <div class="list-container">
                    <table>
                        <thead><tr><th>Spin Wheel Value</th><th>Action</th></tr></thead>
                        <tbody>
                            <?php 
                            $spins_list = $conn->query("SELECT * FROM spins ORDER BY id ASC");
                            while($sp = $spins_list->fetch_assoc()): 
                            ?>
                                <tr>
                                    <td><b><?= htmlspecialchars($sp['prize_name']) ?></b></td>
                                    <td>
                                        <form method="POST" style="margin:0;" onsubmit="return confirm('Delete <?= htmlspecialchars($sp['prize_name']) ?>?');">
                                            <input type="hidden" name="action" value="delete_spin">
                                            <input type="hidden" name="spin_id" value="<?= $sp['id'] ?>">
                                            <button type="submit" class="btn btn-red" style="padding: 4px 8px; font-size: 11px;">❌ Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            <?php endwhile; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- SECTION 3: MANAGE PRODUCTS -->
    <div id="section-products" class="dashboard-section">
        <div class="grid-container" style="grid-template-columns: 1fr;">
            <!-- Manage Products -->
            <div class="card">
                <h2>Manage Products</h2>
                <form method="POST" style="display: flex; gap: 8px; margin-bottom: 12px;">
                    <input type="hidden" name="action" value="add_product">
                    <input type="text" name="product_name" placeholder="Product Name" required style="flex: 2;">
                    <input type="number" step="0.01" name="product_price" placeholder="Price (₹)" required style="flex: 1; background: rgba(0, 8, 20, 0.5); border: 1px solid rgba(255, 215, 0, 0.2); color: white; padding: 10px; border-radius: 6px;">
                    <button type="submit" class="btn">➕ Add</button>
                </form>
                <div class="list-container">
                    <table>
                        <thead><tr><th>Product Name</th><th>Price</th><th>Action</th></tr></thead>
                        <tbody>
                            <?php 
                            $products_list = $conn->query("SELECT * FROM products ORDER BY name ASC");
                            if ($products_list):
                                while($p = $products_list->fetch_assoc()): 
                                ?>
                                    <tr>
                                        <td><?= htmlspecialchars($p['name']) ?></td>
                                        <td><b>₹<?= htmlspecialchars(number_format($p['price'], 2)) ?></b></td>
                                        <td>
                                            <div style="display: flex; gap: 5px;">
                                                <button type="button" class="btn" style="padding: 4px 8px; font-size: 11px; background: var(--accent-color); color: black;" onclick="editProductPrompt(<?= $p['id'] ?>, '<?= htmlspecialchars(addslashes($p['name'])) ?>', <?= $p['price'] ?>)">✏️ Edit</button>
                                                <form method="POST" style="margin:0;" onsubmit="return confirm('Delete <?= htmlspecialchars($p['name']) ?>?');">
                                                    <input type="hidden" name="action" value="delete_product">
                                                    <input type="hidden" name="product_id" value="<?= $p['id'] ?>">
                                                    <button type="submit" class="btn btn-red" style="padding: 4px 8px; font-size: 11px;">❌ Delete</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                <?php 
                                endwhile;
                            endif;
                            ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- SECTION 6: BRANDING SETTINGS -->
    <div id="section-settings" class="dashboard-section">
        <div class="grid-container" style="grid-template-columns: 1fr;">
            <!-- White Labeling Branding settings -->
            <div class="card">
                <h2>App Settings & Branding (White Label)</h2>
                <form method="POST" enctype="multipart/form-data" style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                    <input type="hidden" name="action" value="update_settings">
                    
                    <div class="form-group">
                        <label>App Title (Standard):</label>
                        <input type="text" name="app_title" value="<?= htmlspecialchars($app_title_val) ?>" required>
                    </div>
                    
                    <div class="form-group">
                        <label>App Subtitle (Standard):</label>
                        <input type="text" name="app_subtitle" value="<?= htmlspecialchars($app_subtitle_val) ?>" required>
                    </div>
                    
                    <div class="form-group">
                        <label>App Title (Premium):</label>
                        <input type="text" name="premium_title" value="<?= htmlspecialchars($premium_title_val) ?>" required>
                    </div>
                    
                    <div class="form-group">
                        <label>App Logo (PNG/JPG):</label>
                        <div style="display: flex; gap: 10px; align-items: center;">
                            <input type="file" name="logo" accept="image/*" style="flex: 1;">
                            <?php if ($logo_path_val): ?>
                                <img src="api/<?= htmlspecialchars($logo_path_val) ?>" style="width: 38px; height: 38px; object-fit: contain; background: #000814; padding: 2px; border-radius: 4px; border: 1px solid var(--accent-gold);">
                            <?php endif; ?>
                        </div>
                    </div>
                    
                    <div style="grid-column: span 2; text-align: right; margin-top: 10px;">
                        <button type="submit" class="btn" style="width: 100%;">💾 Save Branding Settings</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <!-- SECTION 2: SALES LOGS -->
    <div id="section-logs" class="dashboard-section">
        <h2>Winners & Order History</h2>
    
    <form class="filter-form" method="GET">
        <div class="form-group">
            <label>From Date:</label>
            <input type="date" name="date_from" value="<?= htmlspecialchars($date_from) ?>">
        </div>
        <div class="form-group">
            <label>To Date:</label>
            <input type="date" name="date_to" value="<?= htmlspecialchars($date_to) ?>">
        </div>
        <div class="form-group">
            <label>Salesman:</label>
            <select name="salesman">
                <option value="">All</option>
                <?php while($s = $salesmen_query->fetch_assoc()): ?>
                    <option value="<?= htmlspecialchars($s['salesman_name']) ?>" <?= $salesman_filter == $s['salesman_name'] ? 'selected' : '' ?>><?= htmlspecialchars($s['salesman_name']) ?></option>
                <?php endwhile; ?>
            </select>
        </div>
        <div class="form-group">
            <label>Product:</label>
            <select name="product">
                <option value="">All</option>
                <?php while($p = $products_query->fetch_assoc()): ?>
                    <option value="<?= htmlspecialchars($p['product_name']) ?>" <?= $product_filter == $p['product_name'] ? 'selected' : '' ?>><?= htmlspecialchars($p['product_name']) ?></option>
                <?php endwhile; ?>
            </select>
        </div>
        <div class="form-group">
            <label>Sales Type:</label>
            <select name="sales_type">
                <option value="" <?= $sales_type == '' ? 'selected' : '' ?>>All Sales</option>
                <option value="spin" <?= $sales_type == 'spin' ? 'selected' : '' ?>>Spin Sales Only</option>
                <option value="direct" <?= $sales_type == 'direct' ? 'selected' : '' ?>>Direct Sales Only</option>
            </select>
        </div>
        <div style="display: flex; gap: 8px; align-items: flex-end; position: relative;">
            <button type="submit" class="btn">Filter</button>
            <a href="dashboard.php" class="btn btn-secondary">Reset</a>
            <div style="position: relative; display: inline-block;">
                <button type="button" class="btn btn-secondary" onclick="toggleExportMenu(event)" style="gap: 5px;">
                    📥 Export CSV ▼
                </button>
                <div id="exportMenu" class="dropdown-menu">
                    <a href="export_csv.php?export_type=all&date_from=<?= urlencode($date_from) ?>&date_to=<?= urlencode($date_to) ?>&salesman=<?= urlencode($salesman_filter) ?>&product=<?= urlencode($product_filter) ?>">Export All Records</a>
                    <a href="export_csv.php?export_type=spin&date_from=<?= urlencode($date_from) ?>&date_to=<?= urlencode($date_to) ?>&salesman=<?= urlencode($salesman_filter) ?>&product=<?= urlencode($product_filter) ?>">Export Spin Sales Only</a>
                    <a href="export_csv.php?export_type=direct&date_from=<?= urlencode($date_from) ?>&date_to=<?= urlencode($date_to) ?>&salesman=<?= urlencode($salesman_filter) ?>&product=<?= urlencode($product_filter) ?>">Export Direct Sales Only</a>
                </div>
            </div>
            <button type="button" id="bulkDeleteBtn" class="btn btn-red" style="display: none; gap: 5px;" onclick="bulkDeleteSelected()">
                🗑️ Delete Selected
            </button>
        </div>
    </form>

    <div class="card" style="padding: 0; overflow-x: auto;">
        <table>
            <thead>
                <tr>
                    <th><input type="checkbox" id="selectAllWinners" onclick="toggleSelectAllWinners(this)"></th>
                    <th>ID</th>
                    <th>Date</th>
                    <th>Salesman</th>
                    <th>Customer Name</th>
                    <th>Mobile</th>
                    <th>Product</th>
                    <th>Qty</th>
                    <th>Order Total</th>
                    <th>Spin?</th>
                    <th>Discount Won</th>
                    <th>Net Amount</th>
                    <th>Location</th>
                    <th>Photo</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <?php while($row = $result->fetch_assoc()): ?>
                <tr>
                    <td><input type="checkbox" class="winner-checkbox" value="<?= $row['id'] ?>" onclick="updateBulkDeleteButtonVisibility()"></td>
                    <td><?= $row['id'] ?></td>
                    <td><?= htmlspecialchars(date('d-m-Y H:i', strtotime($row['created_at']))) ?></td>
                    <td><?= htmlspecialchars($row['salesman_name']) ?></td>
                    <td><?= htmlspecialchars($row['customer_name']) ?></td>
                    <td><?= htmlspecialchars($row['mobile_number']) ?></td>
                    <td><?= htmlspecialchars($row['product_name']) ?></td>
                    <td><?= htmlspecialchars($row['quantity'] ?? '1') ?></td>
                    <td><b>₹<?= htmlspecialchars(number_format($row['order_total'] ?? 0.00, 2)) ?></b></td>
                    <td>
                        <?php if (($row['spin_eligible'] ?? 1) == 1): ?>
                            <span class="pill pill-yes">Yes</span>
                        <?php else: ?>
                            <span class="pill pill-no">No</span>
                        <?php endif; ?>
                    </td>
                    <td><b><?= htmlspecialchars($row['prize_won'] ? $row['prize_won'] : '-') ?></b></td>
                    <td><b style="color: var(--accent-green);">₹<?= htmlspecialchars(number_format($row['net_amount'] ?? 0.00, 2)) ?></b></td>
                    <td>
                        <?php if (!empty($row['latitude']) && !empty($row['longitude'])): ?>
                            <div style="text-align: center;">
                                <iframe class="map-iframe" width="130" height="80" src="https://maps.google.com/maps?q=<?= $row['latitude'] ?>,<?= $row['longitude'] ?>&z=14&output=embed" frameborder="0"></iframe>
                                <a href="https://www.google.com/maps/search/?api=1&query=<?= $row['latitude'] ?>,<?= $row['longitude'] ?>" target="_blank" style="color: var(--accent-color); text-decoration: none; font-size: 11px; display: block; margin-top: 3px;">
                                    📍 Open Map
                                </a>
                            </div>
                        <?php else: ?>
                            <span style="color: var(--text-secondary);">N/A</span>
                        <?php endif; ?>
                    </td>
                    <td>
                        <?php if ($row['file_path']): ?>
                            <a href="api/<?= $row['file_path'] ?>" target="_blank">
                                <img class="photo-thumbnail" src="api/<?= $row['file_path'] ?>" alt="Photo">
                            </a>
                        <?php else: ?>
                            <span style="color: var(--text-secondary);">N/A</span>
                        <?php endif; ?>
                    </td>
                    <td>
                        <form method="POST" style="margin:0;" onsubmit="return confirm('Delete this order entry (ID: <?= $row['id'] ?>)?');">
                            <input type="hidden" name="action" value="delete_winner">
                            <input type="hidden" name="winner_id" value="<?= $row['id'] ?>">
                            <button type="submit" class="btn btn-red" style="padding: 4px 8px; font-size: 11px;">❌ Delete</button>
                        </form>
                    </td>
                </tr>
                <?php endwhile; ?>
                <?php if($result->num_rows == 0): ?>
                <tr><td colspan="14" style="text-align: center; color: var(--text-secondary); padding: 30px;">No history found.</td></tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
    </div> <!-- Closes section-logs -->
    </div> <!-- Closes main-content -->

    <!-- Chart.js Config -->
    <script>
        const ctx = document.getElementById('salesTrendChart').getContext('2d');
        
        // Sky Blue and Emerald Green Gradient colors
        const blueGradient = ctx.createLinearGradient(0, 0, 0, 300);
        blueGradient.addColorStop(0, 'rgba(0, 242, 254, 0.3)');
        blueGradient.addColorStop(1, 'rgba(0, 242, 254, 0.0)');

        const salesTrendChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: <?= json_encode($chart_dates) ?>,
                datasets: [
                    {
                        label: 'Sales Collection (₹)',
                        data: <?= json_encode($chart_sales) ?>,
                        borderColor: '#00f2fe',
                        backgroundColor: blueGradient,
                        fill: true,
                        tension: 0.3,
                        borderWidth: 3,
                        yAxisID: 'ySales',
                        pointBackgroundColor: '#00f2fe',
                        pointHoverRadius: 6
                    },
                    {
                        label: 'Spins Completed',
                        data: <?= json_encode($chart_spins) ?>,
                        type: 'bar',
                        backgroundColor: 'rgba(0, 230, 118, 0.3)',
                        borderColor: '#00e676',
                        borderWidth: 1.5,
                        borderRadius: 4,
                        yAxisID: 'ySpins',
                        barPercentage: 0.4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        labels: {
                            color: '#94a3b8',
                            font: { family: 'Inter', size: 12 }
                        }
                    }
                },
                scales: {
                    x: {
                        grid: { color: 'rgba(255, 255, 255, 0.03)' },
                        ticks: { color: '#94a3b8', font: { family: 'Inter' } }
                    },
                    ySales: {
                        type: 'linear',
                        position: 'left',
                        grid: { color: 'rgba(255, 255, 255, 0.05)' },
                        ticks: {
                            color: '#00f2fe',
                            font: { family: 'Inter' },
                            callback: function(value) { return '₹' + value; }
                        },
                        title: {
                            display: true,
                            text: 'Sales Collection Amount (₹)',
                            color: '#00f2fe'
                        }
                    },
                    ySpins: {
                        type: 'linear',
                        position: 'right',
                        grid: { drawOnChartArea: false },
                        ticks: {
                            color: '#00e676',
                            font: { family: 'Inter' },
                            stepSize: 1
                        },
                        title: {
                            display: true,
                            text: 'Spins Count',
                            color: '#00e676'
                        }
                    }
                }
            }
        });

        // Doughnut Breakdown Chart
        const breakdownCtx = document.getElementById('salesBreakdownChart').getContext('2d');
        const salesBreakdownChart = new Chart(breakdownCtx, {
            type: 'doughnut',
            data: {
                labels: ['Spin Sales', 'Direct Sales (No Spin)'],
                datasets: [{
                    data: [<?= $spin_sales_count ?>, <?= $direct_sales_count ?>],
                    backgroundColor: [
                        'rgba(0, 242, 254, 0.75)', // Sky blue
                        'rgba(0, 230, 118, 0.75)'   // Emerald green
                    ],
                    borderColor: [
                        '#00f2fe',
                        '#00e676'
                    ],
                    borderWidth: 1.5,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                cutout: '65%'
            }
        });

        // Dropdown menu toggle helper
        function toggleExportMenu(e) {
            e.stopPropagation();
            document.getElementById('exportMenu').classList.toggle('show');
        }

        function editProductPrompt(id, currentName, currentPrice) {
            const newName = prompt("Enter new Product Name:", currentName);
            if (newName === null || newName.trim() === "") return;
            const newPriceStr = prompt("Enter new Product Price (₹):", currentPrice);
            if (newPriceStr === null) return;
            const newPrice = parseFloat(newPriceStr);
            if (isNaN(newPrice) || newPrice < 0) {
                alert("Invalid price!");
                return;
            }
            
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'dashboard.php';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'edit_product';
            form.appendChild(actionInput);
            
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'product_id';
            idInput.value = id;
            form.appendChild(idInput);
            
            const nameInput = document.createElement('input');
            nameInput.type = 'hidden';
            nameInput.name = 'product_name';
            nameInput.value = newName.trim();
            form.appendChild(nameInput);
            
            const priceInput = document.createElement('input');
            priceInput.type = 'hidden';
            priceInput.name = 'product_price';
            priceInput.value = newPrice;
            form.appendChild(priceInput);
            
            document.body.appendChild(form);
            form.submit();
        }

        function toggleSelectAllWinners(masterCheckbox) {
            const checkboxes = document.querySelectorAll('.winner-checkbox');
            checkboxes.forEach(cb => {
                cb.checked = masterCheckbox.checked;
            });
            updateBulkDeleteButtonVisibility();
        }

        function updateBulkDeleteButtonVisibility() {
            const checkedCount = document.querySelectorAll('.winner-checkbox:checked').length;
            const bulkBtn = document.getElementById('bulkDeleteBtn');
            if (bulkBtn) {
                if (checkedCount > 0) {
                    bulkBtn.style.display = 'inline-flex';
                    bulkBtn.innerText = '🗑️ Delete Selected (' + checkedCount + ')';
                } else {
                    bulkBtn.style.display = 'none';
                }
            }
        }

        function bulkDeleteSelected() {
            const checked = document.querySelectorAll('.winner-checkbox:checked');
            if (checked.length === 0) return;
            
            if (confirm("Are you sure you want to delete the " + checked.length + " selected sales records? This cannot be undone!")) {
                const ids = [];
                checked.forEach(cb => {
                    ids.push(cb.value);
                });
                
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'dashboard.php';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete_winner';
                form.appendChild(actionInput);
                
                const idsInput = document.createElement('input');
                idsInput.type = 'hidden';
                idsInput.name = 'winner_ids';
                idsInput.value = ids.join(',');
                form.appendChild(idsInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }

        // Close dropdown menu when clicking anywhere else
        document.addEventListener('click', function(e) {
            const menu = document.getElementById('exportMenu');
            if (menu && !e.target.closest('#exportMenu') && !e.target.closest('.btn-secondary')) {
                menu.classList.remove('show');
            }
        });

        // Navigation / Section Toggler Logic
        function showSection(sectionId) {
            // Hide all sections
            document.querySelectorAll('.dashboard-section').forEach(function(sec) {
                sec.style.display = 'none';
            });
            // Show selected section
            const targetSec = document.getElementById('section-' + sectionId);
            if (targetSec) {
                targetSec.style.display = 'block';
            }
            
            // Mark correct menu item active
            document.querySelectorAll('.sidebar-menu a').forEach(function(link) {
                link.classList.remove('active');
            });
            const targetLink = document.getElementById('menu-' + sectionId);
            if (targetLink) {
                targetLink.classList.add('active');
            }
            
            // Update Top Bar Title
            const titles = {
                'dashboard': 'Overview Dashboard',
                'logs': 'Winners & Order History',
                'products': 'Manage Products',
                'salesmen': 'Manage Salesmen',
                'spins': 'Manage Spin Wheel Values',
                'settings': 'Branding & App Settings'
            };
            const activeTitle = document.getElementById('active-section-title');
            if (activeTitle && titles[sectionId]) {
                activeTitle.innerText = titles[sectionId];
            }
            
            // Save tab state to local storage
            localStorage.setItem('active_admin_tab', sectionId);
        }

        // Initialize active tab on load
        document.addEventListener('DOMContentLoaded', function() {
            // Display live date
            const dateSpan = document.getElementById('live-date');
            if (dateSpan) {
                const now = new Date();
                dateSpan.innerText = now.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
            }

            // Restore last active section, default to 'dashboard'
            let activeTab = localStorage.getItem('active_admin_tab') || 'dashboard';
            
            // Check if there is a query filter active, if so force 'logs' tab!
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('date_from') || urlParams.has('date_to') || urlParams.has('salesman') || urlParams.has('product') || urlParams.has('sales_type')) {
                activeTab = 'logs';
            }

            showSection(activeTab);
        });
    </script>

</body>
</html>
<?php $conn->close(); ?>
