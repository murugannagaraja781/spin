<?php
session_start();
if (!isset($_SESSION['superadmin']) || $_SESSION['superadmin'] !== true) {
    header("Location: login.php");
    exit;
}
require_once 'config.php';

// Handle Add/Delete Salesman and Settings POST requests
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['action'])) {
    if ($_POST['action'] == 'add_salesman') {
        $name = trim($_POST['salesman_name'] ?? '');
        if (!empty($name)) {
            $stmt = $conn->prepare("INSERT INTO salesmen (name) VALUES (?)");
            $stmt->bind_param("s", $name);
            $stmt->execute();
            $stmt->close();
        }
        header("Location: index.php");
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
        header("Location: index.php");
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
        $conn->query("INSERT IGNORE INTO settings (id, app_title, app_subtitle, premium_title) VALUES (1, 'மினிக்குட்டி பீடி', 'மினிகுட்டி ബീഡി', '💎 PREMIUM SPIN & WIN 💎')");

        if ($logo_path) {
            $stmt = $conn->prepare("UPDATE settings SET app_title = ?, app_subtitle = ?, premium_title = ?, logo_path = ? WHERE id = 1");
            $stmt->bind_param("ssss", $app_title, $app_subtitle, $premium_title, $logo_path);
        } else {
            $stmt = $conn->prepare("UPDATE settings SET app_title = ?, app_subtitle = ?, premium_title = ? WHERE id = 1");
            $stmt->bind_param("sss", $app_title, $app_subtitle, $premium_title);
        }
        $stmt->execute();
        $stmt->close();
        
        header("Location: index.php");
        exit;
    }
}

// Fetch current settings for pre-population
$settings_query = $conn->query("SELECT * FROM settings WHERE id = 1");
$settings = $settings_query ? $settings_query->fetch_assoc() : null;
$app_title_val = $settings['app_title'] ?? 'மினிக்குட்டி பீடி';
$app_subtitle_val = $settings['app_subtitle'] ?? 'மினിക്കുட்டி ബീഡി';
$premium_title_val = $settings['premium_title'] ?? '💎 PREMIUM SPIN & WIN 💎';
$logo_path_val = $settings['logo_path'] ?? '';

// Filter inputs
$date_from = $_GET['date_from'] ?? '';
$date_to = $_GET['date_to'] ?? '';
$salesman_filter = $_GET['salesman'] ?? '';
$product_filter = $_GET['product'] ?? '';

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

$query .= " ORDER BY w.created_at DESC";
$result = $conn->query($query);

// Fetch Salesmen and Products for filter dropdowns
$salesmen_query = $conn->query("SELECT DISTINCT salesman_name FROM winners WHERE salesman_name IS NOT NULL");
$products_query = $conn->query("SELECT DISTINCT product_name FROM winners WHERE product_name IS NOT NULL");

// Generate Reports Data
$salesman_reports = $conn->query("SELECT salesman_name, COUNT(*) as total_spins FROM winners GROUP BY salesman_name");
$product_reports = $conn->query("SELECT product_name, COUNT(*) as total_spins FROM winners GROUP BY product_name");
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Lucky Spin Admin Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f7f6; padding: 20px; color: #333; }
        h1, h2 { color: #000814; }
        .container { display: flex; gap: 20px; flex-wrap: wrap; }
        .card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); flex: 1; min-width: 300px; }
        table { width: 100%; border-collapse: collapse; background: #fff; margin-top: 15px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #000814; color: #FFD700; }
        tr:hover { background-color: #f1f1f1; }
        img { width: 50px; height: 50px; object-fit: cover; border-radius: 5px; }
        .btn { display: inline-block; padding: 10px 15px; background: #FFD700; color: #000; text-decoration: none; font-weight: bold; border-radius: 5px; border: none; cursor: pointer; }
        .btn:hover { background: #e6c200; }
        .filter-form { background: #fff; padding: 15px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 0 10px rgba(0,0,0,0.1); display: flex; gap: 15px; align-items: flex-end; flex-wrap: wrap; }
        .form-group { display: flex; flex-direction: column; }
        label { font-weight: bold; font-size: 14px; margin-bottom: 5px; }
        input, select { padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
    </style>
</head>
<body>

    <h1>🏆 Lucky Spin Rewards - Admin Dashboard</h1>
    
    <div class="container">
        <!-- Reports Section -->
        <div class="card">
            <h2>Salesman-wise Report</h2>
            <table>
                <tr><th>Salesman</th><th>Total Spins</th></tr>
                <?php while($s = $salesman_reports->fetch_assoc()): ?>
                    <tr><td><?= htmlspecialchars($s['salesman_name']) ?></td><td><?= $s['total_spins'] ?></td></tr>
                <?php endwhile; ?>
            </table>
        </div>
        
        <div class="card">
            <h2>Product-wise Report</h2>
            <table>
                <tr><th>Product</th><th>Total Spins</th></tr>
                <?php while($p = $product_reports->fetch_assoc()): ?>
                    <tr><td><?= htmlspecialchars($p['product_name']) ?></td><td><?= $p['total_spins'] ?></td></tr>
                <?php endwhile; ?>
            </table>
        </div>

        <!-- Add & Manage Salesmen Card -->
        <div class="card" style="min-width: 320px;">
            <h2>Manage Salesmen</h2>
            <form method="POST" style="display: flex; gap: 8px; margin-bottom: 12px;">
                <input type="hidden" name="action" value="add_salesman">
                <input type="text" name="salesman_name" placeholder="New Salesman Name" required style="flex: 1; padding: 6px;">
                <button type="submit" class="btn" style="padding: 6px 12px;">➕ Add</button>
            </form>
            <div style="max-height: 200px; overflow-y: auto;">
                <table style="margin-top: 0;">
                    <tr><th>Salesman Name</th><th>Action</th></tr>
                    <?php 
                    $salesmen_list = $conn->query("SELECT * FROM salesmen ORDER BY name ASC");
                    while($sm = $salesmen_list->fetch_assoc()): 
                    ?>
                        <tr>
                            <td><?= htmlspecialchars($sm['name']) ?></td>
                            <td>
                                <form method="POST" style="margin: 0; display: inline;" onsubmit="return confirm('Delete <?= htmlspecialchars($sm['name']) ?>?');">
                                    <input type="hidden" name="action" value="delete_salesman">
                                    <input type="hidden" name="salesman_id" value="<?= $sm['id'] ?>">
                                    <button type="submit" class="btn" style="background: #ff4c4c; color: white; padding: 4px 8px; font-size: 12px;">❌ Delete</button>
                                </form>
                            </td>
                        </tr>
                    <?php endwhile; ?>
                </table>
            </div>
        </div>

        <!-- App Settings & White Labeling Card -->
        <div class="card" style="min-width: 320px;">
            <h2>App Settings & Branding (White Label)</h2>
            <form method="POST" enctype="multipart/form-data" style="display: flex; flex-direction: column; gap: 10px;">
                <input type="hidden" name="action" value="update_settings">
                
                <div style="display: flex; flex-direction: column;">
                    <label style="font-size: 12px; margin-bottom: 2px;">App Title (Standard):</label>
                    <input type="text" name="app_title" value="<?= htmlspecialchars($app_title_val) ?>" required style="padding: 6px;">
                </div>
                
                <div style="display: flex; flex-direction: column;">
                    <label style="font-size: 12px; margin-bottom: 2px;">App Subtitle (Standard):</label>
                    <input type="text" name="app_subtitle" value="<?= htmlspecialchars($app_subtitle_val) ?>" required style="padding: 6px;">
                </div>
                
                <div style="display: flex; flex-direction: column;">
                    <label style="font-size: 12px; margin-bottom: 2px;">App Title (Premium):</label>
                    <input type="text" name="premium_title" value="<?= htmlspecialchars($premium_title_val) ?>" required style="padding: 6px;">
                </div>
                
                <div style="display: flex; flex-direction: column;">
                    <label style="font-size: 12px; margin-bottom: 2px;">App Logo (PNG/JPG):</label>
                    <input type="file" name="logo" accept="image/*" style="padding: 4px;">
                    <?php if ($logo_path_val): ?>
                        <div style="margin-top: 5px; align-items: center; display: flex; gap: 5px;">
                            <span style="font-size: 12px; color: #666;">Current Logo:</span>
                            <img src="api/<?= htmlspecialchars($logo_path_val) ?>" style="width: 30px; height: 30px; object-fit: contain; background: #000814; padding: 2px; border-radius: 4px;">
                        </div>
                    <?php endif; ?>
                </div>
                
                <button type="submit" class="btn" style="margin-top: 5px; padding: 8px;">💾 Save Branding Settings</button>
            </form>
        </div>
    </div>

    <hr style="margin: 30px 0; border: 1px solid #ddd;">

    <h2>Winners & Spin History</h2>
    
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
            <button type="submit" class="btn">Filter</button>
            <a href="index.php" class="btn" style="background:#ccc;">Reset</a>
        </div>
        <div class="form-group" style="margin-left: auto;">
            <a href="export_csv.php?date_from=<?= urlencode($date_from) ?>&date_to=<?= urlencode($date_to) ?>&salesman=<?= urlencode($salesman_filter) ?>&product=<?= urlencode($product_filter) ?>" class="btn">📥 Export Filtered to CSV</a>
        </div>
    </form>

    <table>
        <tr>
            <th>ID</th>
            <th>Date</th>
            <th>Salesman</th>
            <th>Product</th>
            <th>Customer Name</th>
            <th>Mobile</th>
            <th>Prize Won</th>
            <th>Location</th>
            <th>Photo</th>
        </tr>
        <?php while($row = $result->fetch_assoc()): ?>
        <tr>
            <td><?= $row['id'] ?></td>
            <td><?= $row['created_at'] ?></td>
            <td><?= htmlspecialchars($row['salesman_name']) ?></td>
            <td><?= htmlspecialchars($row['product_name']) ?></td>
            <td><?= htmlspecialchars($row['customer_name']) ?></td>
            <td><?= htmlspecialchars($row['mobile_number']) ?></td>
            <td><b><?= htmlspecialchars($row['prize_won']) ?></b></td>
            <td>
                <?php if (!empty($row['latitude']) && !empty($row['longitude'])): ?>
                    <div style="margin-top: 5px; text-align: center;">
                        <iframe width="150" height="90" src="https://maps.google.com/maps?q=<?= $row['latitude'] ?>,<?= $row['longitude'] ?>&z=14&output=embed" frameborder="0" style="border:0; border-radius: 4px; box-shadow: 0 0 5px rgba(0,0,0,0.15);"></iframe>
                        <a href="https://www.google.com/maps/search/?api=1&query=<?= $row['latitude'] ?>,<?= $row['longitude'] ?>" target="_blank" style="color: #0088cc; text-decoration: none; font-size: 11px; font-weight: bold; display: block; margin-top: 4px;">
                            📍 Open full map
                        </a>
                    </div>
                <?php else: ?>
                    <span style="color: #888;">N/A</span>
                <?php endif; ?>
            </td>
            <td>
                <?php if ($row['file_path']): ?>
                    <a href="api/<?= $row['file_path'] ?>" target="_blank">
                        <img src="api/<?= $row['file_path'] ?>" alt="Photo">
                    </a>
                <?php else: ?>
                    N/A
                <?php endif; ?>
            </td>
        </tr>
        <?php endwhile; ?>
        <?php if($result->num_rows == 0): ?>
        <tr><td colspan="9" style="text-align: center;">No history found.</td></tr>
        <?php endif; ?>
    </table>

</body>
</html>
<?php $conn->close(); ?>
