<?php
/* csrf check */

date_default_timezone_set('Asia/Manila');
if (session_status() !== PHP_SESSION_ACTIVE) session_start();

$remoteAddress = (string)($_SERVER['REMOTE_ADDR'] ?? '');
$isLocalRequest = PHP_SAPI === 'cli' || in_array($remoteAddress, ['127.0.0.1', '::1'], true);
if (!$isLocalRequest) {
    http_response_code(403);
    header('Content-Type: text/plain; charset=utf-8');
    exit("Setup is available only from localhost on the XAMPP computer.\n");
}

if (empty($_SESSION['setup_csrf'])) $_SESSION['setup_csrf'] = bin2hex(random_bytes(32));
$csrfToken = $_SESSION['setup_csrf'];
$backendDir = __DIR__ . '/backend';
$configLocalPath = $backendDir . '/config.local.php';
$message = '';
$messageType = 'info';

function setup_escape($value): string {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

function setup_valid_csrf(): bool {
    return isset($_POST['csrf']) && hash_equals((string)($_SESSION['setup_csrf'] ?? ''), (string)$_POST['csrf']);
}

function setup_env_value(string $key, string $fallback = ''): string {
    $value = getenv($key);
    return $value === false ? $fallback : (string)$value;
}

function setup_db_name(string $value): string {
    $value = trim($value);
    if (!preg_match('/^[A-Za-z0-9_]{1,64}$/', $value)) throw new RuntimeException('Database name may contain only letters, numbers, and underscores.');
    return $value;
}

function setup_write_local_config(string $path, array $settings): void {
    $existing = is_file($path) ? (string)file_get_contents($path) : "<?php\n\n";
    if (strpos($existing, '<?php') === false) throw new RuntimeException('The existing config.local.php is not a valid PHP file.');

    foreach ($settings as $key => $value) {
        $line = "putenv(" . var_export($key . '=' . $value, true) . ");";
        $pattern = '/putenv\s*\(\s*([\'\"])' . preg_quote($key, '/') . '=.*?\1\s*\)\s*;/';
        if (preg_match($pattern, $existing)) {
            $existing = preg_replace($pattern, $line, $existing, 1);
        } else {
            $existing = preg_replace('/<\?php\s*/', "<?php\n" . $line . "\n", $existing, 1);
        }
    }

    $temporary = $path . '.tmp';
    if (file_put_contents($temporary, $existing, LOCK_EX) === false) throw new RuntimeException('Apache cannot write backend/config.local.php. Check the folder permission.');
    @chmod($temporary, 0600);
    if (!rename($temporary, $path)) {
        @unlink($temporary);
        throw new RuntimeException('Unable to finish saving backend/config.local.php.');
    }
}

function setup_probe_database(array $settings): array {
    try {
        $database = setup_db_name($settings['DB_NAME']);
        $pdo = new PDO(
            'mysql:host=' . $settings['DB_HOST'] . ';charset=utf8mb4',
            $settings['DB_USER'],
            $settings['DB_PASS'],
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]
        );
        $pdo->exec("CREATE DATABASE IF NOT EXISTS `{$database}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
        $pdo->exec("USE `{$database}`");
        return ['ok' => true, 'pdo' => $pdo, 'error' => ''];
    } catch (Throwable $error) {
        return ['ok' => false, 'pdo' => null, 'error' => $error->getMessage()];
    }
}

if (is_file($configLocalPath)) require $configLocalPath;
$dbSettings = [
    'DB_HOST' => setup_env_value('DB_HOST', 'localhost'),
    'DB_NAME' => setup_env_value('DB_NAME', 'health_center_system'),
    'DB_USER' => setup_env_value('DB_USER', 'root'),
    'DB_PASS' => setup_env_value('DB_PASS', ''),
];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'save_connection') {
    if (!setup_valid_csrf()) {
        $message = 'Expired setup form. Refresh the page and try again.';
        $messageType = 'error';
    } else {
        $candidate = [
            'DB_HOST' => trim((string)($_POST['db_host'] ?? 'localhost')),
            'DB_NAME' => trim((string)($_POST['db_name'] ?? 'health_center_system')),
            'DB_USER' => trim((string)($_POST['db_user'] ?? 'root')),
            'DB_PASS' => (string)($_POST['db_pass'] ?? ''),
        ];
        $probe = setup_probe_database($candidate);
        if (!$probe['ok']) {
            $dbSettings = $candidate;
            $message = 'Hindi makakonekta sa MySQL. Check kung naka-Start ang MySQL at tama ang username/password.';
            $messageType = 'error';
        } else {
            try {
                setup_write_local_config($configLocalPath, $candidate);
                header('Location: setup.php?connection=saved');
                exit;
            } catch (Throwable $error) {
                $dbSettings = $candidate;
                $message = $error->getMessage();
                $messageType = 'error';
            }
        }
    }
}

$probe = setup_probe_database($dbSettings);
$databaseReady = (bool)$probe['ok'];
$pdo = $probe['pdo'];
$counts = ['patients' => 0, 'admins' => 0, 'appointments' => 0];
$moduleStatus = [];

if ($databaseReady) {
    // config setup
    // env config
    require $backendDir . '/config.php';
    header('Content-Type: text/html; charset=utf-8');

    if (!function_exists('allowed_rhu_branches')) {
        function allowed_rhu_branches(): array {
            return ['RHU I - Poblacion', 'RHU II - Cutcot', 'RHU III - Tinejero', 'RHU IV - Tibag'];
        }
    }
    if (!function_exists('ensure_appointment_arrival_columns')) {
        function ensure_appointment_arrival_columns(PDO $pdo): void {
            hc_add_column($pdo, 'appointments', 'arrival_status', "VARCHAR(20) NOT NULL DEFAULT 'not_arrived' AFTER status");
            hc_add_column($pdo, 'appointments', 'arrived_at', 'DATETIME NULL AFTER arrival_status');
        }
    }
    if (!function_exists('ensure_announcement_attachment_columns')) {
        function ensure_announcement_attachment_columns(PDO $pdo): void {
            hc_add_column($pdo, 'announcements', 'attachment_path', 'VARCHAR(255) NULL AFTER status');
            hc_add_column($pdo, 'announcements', 'attachment_name', 'VARCHAR(255) NULL AFTER attachment_path');
            hc_add_column($pdo, 'announcements', 'attachment_mime', 'VARCHAR(100) NULL AFTER attachment_name');
        }
    }

    require_once $backendDir . '/operations_features.php';
    require_once $backendDir . '/innovation_features.php';

    $safeCounts = function () use ($pdo): array {
        $result = [];
        foreach (['patients', 'admins', 'appointments'] as $table) {
            try { $result[$table] = (int)$pdo->query("SELECT COUNT(*) FROM `{$table}`")->fetchColumn(); }
            catch (Throwable $error) { $result[$table] = 0; }
        }
        return $result;
    };

    $runUpgrade = function () use ($pdo, $safeCounts): array {
        $before = $safeCounts();
        ensure_appointment_arrival_columns($pdo);
        ensure_announcement_attachment_columns($pdo);
        ensure_innovation_tables($pdo);
        ensure_help_chat_automation($pdo);
        operations_ensure_tables($pdo);

        $pdo->exec("CREATE TABLE IF NOT EXISTS notifications (
          id INT AUTO_INCREMENT PRIMARY KEY, patient_id INT NOT NULL, appointment_id INT NULL,
          type VARCHAR(40) NOT NULL DEFAULT 'info', title VARCHAR(150) NOT NULL, message TEXT NOT NULL,
          link VARCHAR(255) NULL, is_read TINYINT(1) NOT NULL DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_notifications_patient (patient_id,is_read,created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        $pdo->exec("CREATE TABLE IF NOT EXISTS email_logs (
          id INT AUTO_INCREMENT PRIMARY KEY, patient_id INT NULL, appointment_id INT NULL,
          recipient VARCHAR(190) NOT NULL, event_type VARCHAR(50) NOT NULL, subject VARCHAR(190) NOT NULL,
          status VARCHAR(30) NOT NULL DEFAULT 'pending', provider_message_id VARCHAR(190) NULL,
          provider_response TEXT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_email_patient (patient_id,created_at), INDEX idx_email_appointment (appointment_id,created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        $pdo->exec("CREATE TABLE IF NOT EXISTS sms_logs (
          id INT AUTO_INCREMENT PRIMARY KEY, patient_id INT NULL, appointment_id INT NULL,
          recipient VARCHAR(30) NOT NULL, event_type VARCHAR(50) NOT NULL, message TEXT NOT NULL,
          status VARCHAR(30) NOT NULL DEFAULT 'pending', provider_message_id VARCHAR(150) NULL,
          provider_response TEXT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_sms_patient (patient_id,created_at), INDEX idx_sms_appointment (appointment_id,created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        $pdo->exec("CREATE TABLE IF NOT EXISTS disease_cases (
          id INT AUTO_INCREMENT PRIMARY KEY, patient_id INT NULL, appointment_id INT NULL,
          disease_category VARCHAR(150) NOT NULL, diagnosis VARCHAR(255) NULL, symptoms TEXT NULL,
          barangay VARCHAR(120) NOT NULL, rhu_branch VARCHAR(150) NOT NULL, case_date DATE NOT NULL,
          onset_date DATE NULL, age_group VARCHAR(50) NOT NULL DEFAULT 'Unknown',
          case_status VARCHAR(50) NOT NULL DEFAULT 'Recorded', recorded_by INT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_disease_date (case_date), INDEX idx_disease_category (disease_category),
          INDEX idx_disease_barangay (barangay), INDEX idx_disease_rhu (rhu_branch)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

        $after = $safeCounts();
        foreach ($before as $table => $count) {
            if ($after[$table] < $count) throw new RuntimeException("Safety check failed for {$table}; no data was intentionally removed.");
        }
        return $after;
    };

    if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'run_upgrade') {
        if (!setup_valid_csrf()) {
            $message = 'Expired setup form. Refresh the page and try again.';
            $messageType = 'error';
        } else {
            try {
                $counts = $runUpgrade();
                $message = 'Safe upgrade complete. Existing patients, admins, appointments, and chat records were preserved.';
                $messageType = 'success';
            } catch (Throwable $error) {
                $message = 'Upgrade stopped: ' . $error->getMessage();
                $messageType = 'error';
            }
        }
    }

    $counts = $safeCounts();
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'create_first_admin') {
        if (!setup_valid_csrf()) {
            $message = 'Expired setup form. Refresh the page and try again.';
            $messageType = 'error';
        } elseif ($counts['admins'] > 0) {
            $message = 'May existing administrator na. Walang password o account na binago.';
            $messageType = 'error';
        } else {
            $name = trim((string)($_POST['admin_name'] ?? ''));
            $email = strtolower(trim((string)($_POST['admin_email'] ?? '')));
            $password = (string)($_POST['admin_password'] ?? '');
            $confirm = (string)($_POST['admin_password_confirm'] ?? '');
            if (mb_strlen($name) < 3 || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $message = 'Enter a valid administrator name and email.';
                $messageType = 'error';
            } elseif (strlen($password) < 10 || !preg_match('/[A-Z]/', $password) || !preg_match('/[a-z]/', $password) || !preg_match('/\d/', $password)) {
                $message = 'Password must have at least 10 characters, uppercase, lowercase, and a number.';
                $messageType = 'error';
            } elseif (!hash_equals($password, $confirm)) {
                $message = 'Passwords do not match.';
                $messageType = 'error';
            } else {
                try {
                    $stmt = $pdo->prepare("INSERT INTO admins(name,email,password_hash,role,branch) VALUES(?,?,?,'System Administrator','All Branches')");
                    $stmt->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT)]);
                    $message = 'First administrator created. You can now sign in.';
                    $messageType = 'success';
                    $counts = $safeCounts();
                } catch (Throwable $error) {
                    $message = 'Administrator was not created: ' . $error->getMessage();
                    $messageType = 'error';
                }
            }
        }
    }

    $tableChecks = [
        'Help chat + automatic reply' => ['chat_messages', 'chat_thread_status'],
        'Clinic schedules + capacity' => ['clinic_schedules', 'clinic_capacity_rules', 'clinic_closures'],
        'Privacy + caregiver verification' => ['privacy_policy_versions', 'patient_consents', 'patient_access_history', 'family_care_links'],
        'Announcements + reach analytics' => ['announcements', 'announcement_reads', 'notification_delivery_logs'],
        'Disease early warning' => ['disease_cases'],
        'QR arrival + queue alerts' => ['qr_arrival_tokens', 'queue_proximity_alerts', 'booking_slot_locks'],
    ];
    foreach ($tableChecks as $label => $tables) {
        $ready = true;
        foreach ($tables as $table) {
            $stmt = $pdo->prepare('SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?');
            $stmt->execute([$table]);
            if (!(int)$stmt->fetchColumn()) { $ready = false; break; }
        }
        $moduleStatus[$label] = $ready;
    }
}

if (isset($_GET['connection']) && $_GET['connection'] === 'saved') {
    $message = 'Database connection saved on this XAMPP computer.';
    $messageType = 'success';
}
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>System Setup | Pulilan Health Center</title>
  <link rel="stylesheet" href="setup.css">
</head>
<body>
  <header class="topbar">
    <div class="brand-mark">PHC</div>
    <div><strong>Pulilan Health Center</strong><span>Local Setup & Safe Upgrade</span></div>
    <span class="local-badge">Localhost only</span>
  </header>

  <main class="setup-shell">
    <section class="intro">
      <p class="eyebrow">ONE-PAGE SETUP</p>
      <h1>Ready na para sa XAMPP</h1>
      <p>Ito na ang gagamitin sa existing system o fresh installation. Hindi nito nire-reset ang existing accounts at records.</p>
    </section>

    <?php if ($message): ?>
      <div class="notice <?= setup_escape($messageType) ?>" role="status"><?= setup_escape($message) ?></div>
    <?php endif; ?>

    <section class="status-grid">
      <article class="status-card">
        <span class="status-icon <?= $databaseReady ? 'ready' : 'not-ready' ?>"><?= $databaseReady ? '✓' : '!' ?></span>
        <div><small>DATABASE</small><strong><?= $databaseReady ? 'Connected' : 'Needs setup' ?></strong><span><?= setup_escape($dbSettings['DB_NAME']) ?></span></div>
      </article>
      <article class="status-card">
        <span class="status-icon ready">✓</span>
        <div><small>DATA MODE</small><strong><?= ($counts['admins'] ?? 0) > 0 ? 'Existing system' : 'Fresh system' ?></strong><span>No destructive reset</span></div>
      </article>
      <article class="status-card">
        <span class="status-icon <?= ($counts['admins'] ?? 0) > 0 ? 'ready' : 'not-ready' ?>"><?= ($counts['admins'] ?? 0) > 0 ? '✓' : '!' ?></span>
        <div><small>ADMIN ACCOUNT</small><strong><?= (int)($counts['admins'] ?? 0) ?> detected</strong><span><?= ($counts['admins'] ?? 0) > 0 ? 'Existing login preserved' : 'Create the first admin below' ?></span></div>
      </article>
    </section>

    <?php if (!$databaseReady): ?>
      <section class="panel">
        <div class="panel-heading"><div><span class="step">1</span><h2>Connect MySQL</h2></div><p>Default XAMPP usually uses root with a blank password.</p></div>
        <form method="post" class="form-grid" autocomplete="off">
          <input type="hidden" name="csrf" value="<?= setup_escape($csrfToken) ?>">
          <input type="hidden" name="action" value="save_connection">
          <label>Host<input name="db_host" value="<?= setup_escape($dbSettings['DB_HOST']) ?>" required></label>
          <label>Database name<input name="db_name" value="<?= setup_escape($dbSettings['DB_NAME']) ?>" required></label>
          <label>MySQL username<input name="db_user" value="<?= setup_escape($dbSettings['DB_USER']) ?>" required></label>
          <label>MySQL password<input name="db_pass" type="password" value=""></label>
          <button class="primary" type="submit">Test & Save Connection</button>
        </form>
        <p class="hint">Current error: <?= setup_escape($probe['error'] ?? 'Unknown connection error') ?></p>
      </section>
    <?php else: ?>
      <section class="two-column">
        <article class="panel">
          <div class="panel-heading"><div><span class="step">1</span><h2>Safe database upgrade</h2></div><p>Creates only the missing tables and columns.</p></div>
          <div class="record-strip">
            <span><strong><?= (int)$counts['patients'] ?></strong> patients</span>
            <span><strong><?= (int)$counts['admins'] ?></strong> admins/staff</span>
            <span><strong><?= (int)$counts['appointments'] ?></strong> appointments</span>
          </div>
          <form method="post">
            <input type="hidden" name="csrf" value="<?= setup_escape($csrfToken) ?>">
            <input type="hidden" name="action" value="run_upgrade">
            <button class="primary full" type="submit">Run Safe Upgrade</button>
          </form>
          <p class="hint">Existing data is counted before and after the upgrade. No DROP, TRUNCATE, or password reset is used.</p>
        </article>

        <article class="panel">
          <div class="panel-heading"><div><span class="step">2</span><h2>Administrator</h2></div><p><?= $counts['admins'] > 0 ? 'Your current account stays unchanged.' : 'Required only for a new database.' ?></p></div>
          <?php if ($counts['admins'] > 0): ?>
            <div class="existing-admin"><span>✓</span><div><strong>Existing admin found</strong><p>Hindi na kailangan ang create_admin.php. Gamitin ang dati mong login.</p></div></div>
            <a class="secondary full link-button" href="admin/admin-login.html">Open Admin Login</a>
          <?php else: ?>
            <form method="post" class="stacked-form" autocomplete="off">
              <input type="hidden" name="csrf" value="<?= setup_escape($csrfToken) ?>">
              <input type="hidden" name="action" value="create_first_admin">
              <label>Full name<input name="admin_name" required></label>
              <label>Email<input type="email" name="admin_email" required></label>
              <label>Password<input type="password" name="admin_password" minlength="10" required></label>
              <label>Confirm password<input type="password" name="admin_password_confirm" minlength="10" required></label>
              <button class="primary full" type="submit">Create First Administrator</button>
            </form>
          <?php endif; ?>
        </article>
      </section>

      <section class="panel modules-panel">
        <div class="panel-heading"><div><span class="step">3</span><h2>Feature readiness</h2></div><p>Run Safe Upgrade until every module is ready.</p></div>
        <div class="module-list">
          <?php foreach ($moduleStatus as $label => $ready): ?>
            <div><span class="mini-status <?= $ready ? 'ready' : 'not-ready' ?>"><?= $ready ? '✓' : '!' ?></span><strong><?= setup_escape($label) ?></strong><em><?= $ready ? 'Ready' : 'Needs upgrade' ?></em></div>
          <?php endforeach; ?>
        </div>
      </section>

      <section class="finish-panel">
        <div><p class="eyebrow">NEXT</p><h2>Kapag puro “Ready” na</h2><p>Buksan ang admin login, then Operations & Compliance. Sa actual test, gumamit ng normal at Incognito window para sa dalawang staff session.</p></div>
        <div class="finish-actions">
          <a class="primary link-button" href="admin/admin-login.html">Admin Login</a>
          <a class="secondary link-button" href="patient/register.html">Patient Portal</a>
          <a class="secondary link-button" href="tv-display.html">TV Display</a>
        </div>
      </section>
    <?php endif; ?>
  </main>
</body>
</html>
