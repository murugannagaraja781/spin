<?php
session_start();

if (isset($_SESSION['superadmin']) && $_SESSION['superadmin'] === true) {
    header("Location: index.php");
    exit;
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $password = $_POST['password'] ?? '';
    if ($password === 'superadmin123') {
        $_SESSION['superadmin'] = true;
        header("Location: index.php");
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
    <title>Super Admin Login</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #000814; color: #fff; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .login-box { background: #0d1b2a; padding: 40px; border-radius: 10px; box-shadow: 0 0 20px rgba(255,215,0,0.2); text-align: center; border: 1px solid #FFD700; }
        h2 { color: #FFD700; margin-bottom: 20px; }
        input[type="password"] { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 5px; box-sizing: border-box; }
        .btn { background: #FFD700; color: #000; border: none; padding: 10px 20px; font-weight: bold; cursor: pointer; width: 100%; border-radius: 5px; margin-top: 10px; }
        .error { color: #ff4c4c; margin-top: 10px; }
    </style>
</head>
<body>
    <div class="login-box">
        <h2>🔒 Super Admin</h2>
        <form method="POST">
            <input type="password" name="password" placeholder="Enter Password" required>
            <button type="submit" class="btn">LOGIN</button>
            <?php if($error): ?><div class="error"><?= $error ?></div><?php endif; ?>
        </form>
    </div>
</body>
</html>
