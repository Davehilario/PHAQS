<?php

// password handling
// password handling

require __DIR__ . '/config.php';

function usage_and_exit($msg = ''){
    if ($msg) echo $msg . PHP_EOL;
    echo "Usage: php create_admin.php email@example.com \"Full Name\" password\n";
    echo "Or open this file in a browser and submit the form.\n";
    exit(1);
}

if (php_sapi_name() === 'cli') {
    global $argv;
    if (count($argv) < 4) usage_and_exit();
    $email = trim($argv[1]);
    $name = trim($argv[2]);
    $password = $argv[3];
} else {
    $email = trim($_POST['email'] ?? '');
    $name = trim($_POST['name'] ?? '');
    $password = $_POST['password'] ?? '';
    if (!$email || !$name || !$password) {

        echo '<form method="post">';
        echo '<label>Email: <input name="email"></label><br>';
        echo '<label>Name: <input name="name"></label><br>';
        echo '<label>Password: <input name="password" type="password"></label><br>';
        echo '<button type="submit">Create Admin</button>';
        echo '</form>';
        exit;
    }
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) usage_and_exit('Invalid email');
if (strlen($password) < 6) usage_and_exit('Password must be at least 6 characters');

try {
    $stmt = $pdo->prepare('SELECT id FROM admins WHERE email = ? LIMIT 1');
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        echo "An admin with that email already exists.\n";
        exit(0);
    }

    $hash = password_hash($password, PASSWORD_DEFAULT);
    $ins = $pdo->prepare('INSERT INTO admins(name,email,password_hash,role,branch) VALUES(?,?,?,?,?)');
    $ins->execute([$name, $email, $hash, 'System Administrator', 'All RHU Branches']);
    echo "Admin created: {$email} ({$name})\n";
    echo "Please delete create_admin.php after use to avoid leaving a writable helper on the server.\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . PHP_EOL;
}
