<?php
session_start();
require_once 'config.php';

if (isset($_GET['logout']) && $_GET['logout'] === 'true') {
    $_SESSION = array();
    session_destroy();
    header("Location: login.php");
    exit;
}

if (isset($_SESSION['superadmin']) && $_SESSION['superadmin'] === true) {
    header("Location: dashboard.php");
    exit;
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $password = trim($_POST['password'] ?? '');
    
    // Get current superadmin password from settings table
    $superadmin_pass = 'superadmin123';
    $result = $conn->query("SELECT superadmin_password FROM settings WHERE id = 1");
    if ($result && $result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $superadmin_pass = $row['superadmin_password'];
    }

    if ($password === $superadmin_pass) {
        $_SESSION['superadmin'] = true;
        header("Location: dashboard.php");
        exit;
    } else {
        $error = 'Invalid password!';
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Super Admin Login</title>
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #070C16 0%, #0D1527 100%); 
            color: #fff; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0; 
        }
        .login-box { 
            background: rgba(13, 27, 42, 0.7); 
            backdrop-filter: blur(12px);
            padding: 40px; 
            border-radius: 16px; 
            box-shadow: 0 8px 32px 0 rgba(0, 229, 255, 0.15); 
            text-align: center; 
            border: 1px solid rgba(0, 229, 255, 0.2); 
            width: 320px;
        }
        h2 { 
            color: #00E5FF; 
            margin-bottom: 24px; 
            font-size: 24px;
            letter-spacing: 1px;
        }
        input[type="password"] { 
            width: 100%; 
            padding: 12px; 
            margin: 12px 0; 
            border: 1px solid rgba(255, 255, 255, 0.1); 
            border-radius: 8px; 
            box-sizing: border-box; 
            background: rgba(255, 255, 255, 0.05);
            color: #fff;
            font-size: 15px;
            outline: none;
            transition: border-color 0.3s;
        }
        input[type="password"]:focus {
            border-color: #00E5FF;
        }
        .btn { 
            background: linear-gradient(90deg, #00E5FF 0%, #00E676 100%); 
            color: #000; 
            border: none; 
            padding: 12px 20px; 
            font-weight: bold; 
            cursor: pointer; 
            width: 100%; 
            border-radius: 8px; 
            margin-top: 12px; 
            font-size: 15px;
            letter-spacing: 0.5px;
            transition: opacity 0.3s;
        }
        .btn:hover {
            opacity: 0.9;
        }
        .error { color: #ff4c4c; margin-top: 15px; font-size: 14px; }
        .back-home { margin-top: 20px; display: block; color: rgba(255,255,255,0.4); text-decoration: none; font-size: 13px; }
        .back-home:hover { color: #00E5FF; }
    </style>
</head>
<body>
    <div class="login-box">
        <h2>🔒 SUPER ADMIN</h2>
        <form method="POST">
            <input type="password" name="password" placeholder="Enter Admin Password" required>
            <button type="submit" class="btn">LOGIN TO DASHBOARD</button>
            <?php if($error): ?><div class="error"><?= $error ?></div><?php endif; ?>
        </form>
        <a href="index.php" class="back-home">← Back to Homepage</a>
    </div>
</body>
</html>
