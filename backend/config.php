<?php
if (file_exists(__DIR__ . '/config.local.php')) { require_once __DIR__ . '/config.local.php'; }
date_default_timezone_set('Asia/Manila');
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
header('Content-Type: application/json; charset=utf-8');

// env config

// env config
$DB_HOST = getenv('DB_HOST') ?: 'localhost';
$DB_NAME = getenv('DB_NAME') ?: 'health_center_system';
$DB_USER = getenv('DB_USER') ?: 'root';
$DB_PASS = getenv('DB_PASS') ?: '';

// env config
define('GOOGLE_CLIENT_ID', getenv('GOOGLE_CLIENT_ID') ?: '701320665083-q9o0vpr2delb6o3l9cstq6omhu8fd3de.apps.googleusercontent.com');

try {
    $pdo = new PDO("mysql:host=$DB_HOST;charset=utf8mb4", $DB_USER, $DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    $pdo->exec("CREATE DATABASE IF NOT EXISTS `$DB_NAME` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    $pdo->exec("USE `$DB_NAME`");
    $pdo->exec("SET time_zone = '+08:00'");
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'message' => 'Database connection failed. Start MySQL in XAMPP, then check backend/config.php.']);
    exit;
}

function hc_column_exists(PDO $pdo, string $table, string $column): bool {
    $stmt = $pdo->prepare("SHOW COLUMNS FROM `$table` LIKE ?");
    $stmt->execute([$column]);
    return (bool)$stmt->fetch();
}

function hc_add_column(PDO $pdo, string $table, string $column, string $definition): void {
    if (!hc_column_exists($pdo, $table, $column)) {
        $pdo->exec("ALTER TABLE `$table` ADD COLUMN `$column` $definition");
    }
}

try {
    $pdo->exec("CREATE TABLE IF NOT EXISTS patients (
      id INT AUTO_INCREMENT PRIMARY KEY,
      patient_code VARCHAR(20) UNIQUE,
      first_name VARCHAR(100) NOT NULL,
      last_name VARCHAR(100) NOT NULL,
      email VARCHAR(150) NOT NULL UNIQUE,
      password_hash VARCHAR(255) NOT NULL,
      phone VARCHAR(30) NULL,
      birthdate DATE NULL,
      gender VARCHAR(30) NULL,
      address TEXT NULL,
      barangay VARCHAR(100) NULL,
      philhealth_no VARCHAR(80) NULL,
      is_senior TINYINT(1) DEFAULT 0,
      is_pwd TINYINT(1) DEFAULT 0,
      is_4ps TINYINT(1) DEFAULT 0,
      preferred_rhu VARCHAR(150) NULL,
      account_status ENUM('Active','Archived') NOT NULL DEFAULT 'Active',
      archived_at DATETIME NULL,
      profile_json LONGTEXT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    hc_add_column($pdo, 'patients', 'patient_code', 'VARCHAR(20) UNIQUE AFTER id');
    hc_add_column($pdo, 'patients', 'phone', 'VARCHAR(30) NULL AFTER password_hash');
    hc_add_column($pdo, 'patients', 'birthdate', 'DATE NULL AFTER phone');
    hc_add_column($pdo, 'patients', 'gender', 'VARCHAR(30) NULL AFTER birthdate');
    hc_add_column($pdo, 'patients', 'address', 'TEXT NULL AFTER gender');
    hc_add_column($pdo, 'patients', 'barangay', 'VARCHAR(100) NULL AFTER address');
    hc_add_column($pdo, 'patients', 'philhealth_no', 'VARCHAR(80) NULL AFTER barangay');
    hc_add_column($pdo, 'patients', 'is_senior', 'TINYINT(1) DEFAULT 0 AFTER philhealth_no');
    hc_add_column($pdo, 'patients', 'is_pwd', 'TINYINT(1) DEFAULT 0 AFTER is_senior');
    hc_add_column($pdo, 'patients', 'is_4ps', 'TINYINT(1) DEFAULT 0 AFTER is_pwd');
    hc_add_column($pdo, 'patients', 'preferred_rhu', 'VARCHAR(150) NULL AFTER is_4ps');
    hc_add_column($pdo, 'patients', 'account_status', "ENUM('Active','Archived') NOT NULL DEFAULT 'Active' AFTER preferred_rhu");
    hc_add_column($pdo, 'patients', 'archived_at', 'DATETIME NULL AFTER account_status');
    hc_add_column($pdo, 'patients', 'profile_json', 'LONGTEXT NULL AFTER archived_at');
    hc_add_column($pdo, 'patients', 'failed_login_attempts', 'INT NOT NULL DEFAULT 0 AFTER profile_json');
    hc_add_column($pdo, 'patients', 'locked_until', 'DATETIME NULL AFTER failed_login_attempts');
    $pdo->exec("UPDATE patients SET archived_at=NOW() WHERE account_status='Archived' AND archived_at IS NULL");

    $pdo->exec("CREATE TABLE IF NOT EXISTS admins (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(120) NOT NULL,
      email VARCHAR(150) NOT NULL UNIQUE,
      password_hash VARCHAR(255) NOT NULL,
      role VARCHAR(60) NOT NULL DEFAULT 'RHU Staff',
      branch VARCHAR(120) NOT NULL DEFAULT 'All RHU Branches',
      account_status ENUM('Active','Disabled') NOT NULL DEFAULT 'Active',
      last_notification_read_at DATETIME NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    hc_add_column($pdo, 'admins', 'account_status', "ENUM('Active','Disabled') NOT NULL DEFAULT 'Active' AFTER branch");
    hc_add_column($pdo, 'admins', 'last_notification_read_at', 'DATETIME NULL AFTER account_status');
    hc_add_column($pdo, 'admins', 'failed_login_attempts', 'INT NOT NULL DEFAULT 0 AFTER last_notification_read_at');
    hc_add_column($pdo, 'admins', 'locked_until', 'DATETIME NULL AFTER failed_login_attempts');

    $pdo->exec("CREATE TABLE IF NOT EXISTS appointments (
      id INT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT NOT NULL,
      queue_number VARCHAR(20) NOT NULL,
      center VARCHAR(120) NOT NULL,
      service VARCHAR(120) NOT NULL,
      appointment_date DATE NOT NULL,
      appointment_time VARCHAR(30) NOT NULL,
      queue_type ENUM('regular','priority','emergency') DEFAULT 'regular',
      priority_reason VARCHAR(120) NULL,
      status ENUM('Pending','Confirmed','Serving','Done','Cancelled','No Show','Hold') DEFAULT 'Confirmed',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_patient_status (patient_id, status),
      INDEX idx_center_status (center, status),
      CONSTRAINT fk_appointments_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS password_resets (
      id INT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT NOT NULL,
      email VARCHAR(150) NOT NULL,
      token_hash VARCHAR(255) NOT NULL,
      expires_at DATETIME NOT NULL,
      used_at DATETIME NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_token_hash (token_hash),
      INDEX idx_email (email),
      CONSTRAINT fk_password_resets_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // database setup
    // email setup
    hc_add_column($pdo, 'password_resets', 'patient_id', 'INT NOT NULL AFTER id');
    hc_add_column($pdo, 'password_resets', 'email', 'VARCHAR(150) NOT NULL AFTER patient_id');
    hc_add_column($pdo, 'password_resets', 'token_hash', 'VARCHAR(255) NOT NULL AFTER email');
    hc_add_column($pdo, 'password_resets', 'expires_at', 'DATETIME NOT NULL AFTER token_hash');
    hc_add_column($pdo, 'password_resets', 'used_at', 'DATETIME NULL AFTER expires_at');

    $pdo->exec("CREATE TABLE IF NOT EXISTS audit_logs (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_type VARCHAR(30) NOT NULL,
      user_name VARCHAR(120) NOT NULL,
      action VARCHAR(150) NOT NULL,
      details TEXT NULL,
      module VARCHAR(80) NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    hc_add_column($pdo, 'audit_logs', 'user_type', "VARCHAR(30) NOT NULL DEFAULT 'admin' AFTER id");
    hc_add_column($pdo, 'audit_logs', 'user_name', "VARCHAR(150) NOT NULL DEFAULT 'Administrator' AFTER user_type");
    hc_add_column($pdo, 'audit_logs', 'email', "VARCHAR(150) NULL AFTER user_name");
    hc_add_column($pdo, 'audit_logs', 'role', "VARCHAR(100) NULL AFTER email");
    hc_add_column($pdo, 'audit_logs', 'branch', "VARCHAR(150) NULL AFTER role");
    hc_add_column($pdo, 'audit_logs', 'module', "VARCHAR(100) NULL AFTER branch");
    hc_add_column($pdo, 'audit_logs', 'action', "VARCHAR(150) NOT NULL DEFAULT 'Action' AFTER module");
    hc_add_column($pdo, 'audit_logs', 'details', "TEXT NULL AFTER action");

    $pdo->exec("CREATE TABLE IF NOT EXISTS chat_messages (
      id INT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT NOT NULL,
      admin_id INT NULL,
      sender_type ENUM('patient','admin') NOT NULL,
      message TEXT NOT NULL,
      is_read TINYINT(1) DEFAULT 0,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_chat_patient (patient_id, id),
      CONSTRAINT fk_chat_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    hc_add_column($pdo, 'chat_messages', 'patient_id', 'INT NULL AFTER id');
    hc_add_column($pdo, 'chat_messages', 'admin_id', 'INT NULL AFTER patient_id');
    hc_add_column($pdo, 'chat_messages', 'is_read', 'TINYINT(1) DEFAULT 0 AFTER message');
    hc_add_column($pdo, 'chat_messages', 'is_automated', 'TINYINT(1) NOT NULL DEFAULT 0 AFTER is_read');
    if (hc_column_exists($pdo, 'chat_messages', 'thread_id')) {
      $pdo->exec("UPDATE chat_messages SET patient_id=thread_id WHERE patient_id IS NULL");
      $pdo->exec("ALTER TABLE chat_messages MODIFY thread_id INT NULL");
    }
    if (hc_column_exists($pdo, 'chat_messages', 'sender_name')) {
      $pdo->exec("ALTER TABLE chat_messages MODIFY sender_name VARCHAR(160) NULL");
    }

    $pdo->exec("CREATE TABLE IF NOT EXISTS chat_thread_status (
      patient_id INT PRIMARY KEY,
      status ENUM('Open','Waiting for Patient','Resolved') NOT NULL DEFAULT 'Open',
      rhu_branch VARCHAR(150) NULL,
      assigned_admin_id INT NULL,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_chat_thread_status (status,updated_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    hc_add_column($pdo, 'chat_thread_status', 'rhu_branch', 'VARCHAR(150) NULL AFTER status');
    hc_add_column($pdo, 'chat_thread_status', 'assigned_admin_id', 'INT NULL AFTER rhu_branch');
    hc_add_column($pdo, 'chat_thread_status', 'updated_at', 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER assigned_admin_id');

    $pdo->exec("CREATE TABLE IF NOT EXISTS announcements (
      id INT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(180) NOT NULL, message TEXT NOT NULL,
      branch VARCHAR(150) NOT NULL DEFAULT 'All Branches',
      status ENUM('Draft','Published','Archived') NOT NULL DEFAULT 'Published',
      attachment_path VARCHAR(255) NULL, attachment_name VARCHAR(255) NULL,
      attachment_mime VARCHAR(100) NULL,
      created_by INT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_announcements_branch_status (branch,status,created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    hc_add_column($pdo, 'announcements', 'attachment_path', 'VARCHAR(255) NULL AFTER status');
    hc_add_column($pdo, 'announcements', 'attachment_name', 'VARCHAR(255) NULL AFTER attachment_path');
    hc_add_column($pdo, 'announcements', 'attachment_mime', 'VARCHAR(100) NULL AFTER attachment_name');
    $pdo->exec("CREATE TABLE IF NOT EXISTS system_settings (
      setting_key VARCHAR(100) PRIMARY KEY, setting_value TEXT NULL, updated_by INT NULL,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    // password handling

    if (getenv('ALLOW_DEMO_ACCOUNTS') === '1') {
      $demoHash = password_hash((string)(getenv('DEMO_ADMIN_PASSWORD') ?: bin2hex(random_bytes(12))), PASSWORD_DEFAULT);
      $seedAdmins = [
        ['System Administrator','admin@pulilan.gov.ph',$demoHash,'System Administrator','All Branches']
      ];
      $stmt = $pdo->prepare("INSERT IGNORE INTO admins(name,email,password_hash,role,branch) VALUES(?,?,?,?,?)");
      foreach ($seedAdmins as $adminSeed) { $stmt->execute($adminSeed); }
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'message' => 'Database setup failed. Please import backend/database.sql or check table permissions.']);
    exit;
}

// env config
define('SMTP_HOST', getenv('SMTP_HOST') ?: 'smtp.gmail.com');
define('SMTP_PORT', intval(getenv('SMTP_PORT') ?: 587));
define('SMTP_EMAIL', getenv('SMTP_EMAIL') ?: 'you@example.com');
define('SMTP_PASSWORD', getenv('SMTP_PASSWORD') ?: '');

// config setup
if (!defined('PHPUNIT_RUNNING') && PHP_SAPI !== 'cli' && SMTP_PASSWORD === '') {

  error_log('[config] SMTP_PASSWORD is empty. Email sending will fail until configured via environment.');
}
