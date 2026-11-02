<?php

ini_set('display_errors','0');
ini_set('log_errors','1');
ob_start();
register_shutdown_function(function(){
    $error=error_get_last();
    if(!$error || !in_array($error['type'],[E_ERROR,E_PARSE,E_CORE_ERROR,E_COMPILE_ERROR,E_USER_ERROR],true)) return;
    while(ob_get_level()>0){ob_end_clean();}
    if(!headers_sent()){
        http_response_code(500);
        header('Content-Type: application/json; charset=utf-8');
        header('Cache-Control: no-store');
    }
    echo json_encode(['ok'=>false,'message'=>'Server error while loading Patient Inquiries. Check the PHP error log.','debug'=>$error['message']]);
});
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require __DIR__ . '/config.php';
require __DIR__ . '/PHPMailer/src/Exception.php';
require __DIR__ . '/PHPMailer/src/PHPMailer.php';
require __DIR__ . '/PHPMailer/src/SMTP.php';

$action = $_GET['action'] ?? '';
$data = body();

function json_out($data, $code = 200) {
    while (ob_get_level() > 0) { ob_end_clean(); }
    http_response_code($code);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('Pragma: no-cache');
    header('Expires: 0');
    echo json_encode($data);
    exit;
}

function body() {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);
    return is_array($data) ? $data : $_POST;
}


function login_lock_remaining_seconds($lockedUntil) {
    if (empty($lockedUntil)) return 0;
    $until = strtotime((string)$lockedUntil);
    return $until && $until > time() ? $until - time() : 0;
}

function login_lock_message($seconds) {
    $minutes = max(1, (int)ceil($seconds / 60));
    return 'Too many failed login attempts. Please try again in '.$minutes.' minute'.($minutes === 1 ? '' : 's').'.';
}

function record_failed_login(PDO $pdo, string $table, int $id, int $currentAttempts, int $lockMinutes) {
    $attempts = $currentAttempts + 1;
    if ($attempts >= 5) {
        $stmt = $pdo->prepare("UPDATE `$table` SET failed_login_attempts=0, locked_until=DATE_ADD(NOW(), INTERVAL ? MINUTE) WHERE id=?");
        $stmt->execute([$lockMinutes, $id]);
        return $lockMinutes * 60;
    }
    $stmt = $pdo->prepare("UPDATE `$table` SET failed_login_attempts=?, locked_until=NULL WHERE id=?");
    $stmt->execute([$attempts, $id]);
    return 0;
}

function clear_login_lock(PDO $pdo, string $table, int $id) {
    $stmt = $pdo->prepare("UPDATE `$table` SET failed_login_attempts=0, locked_until=NULL WHERE id=?");
    $stmt->execute([$id]);
}

function ensure_appointment_arrival_columns($pdo) {
    $cols = $pdo->query("SHOW COLUMNS FROM appointments")->fetchAll(PDO::FETCH_COLUMN);
    if (!in_array('concern', $cols, true)) {
        $pdo->exec("ALTER TABLE appointments ADD COLUMN concern TEXT NULL AFTER priority_reason");
    }
    if (!in_array('arrival_status', $cols, true)) {
        $pdo->exec("ALTER TABLE appointments ADD COLUMN arrival_status VARCHAR(20) NOT NULL DEFAULT 'not_arrived' AFTER status");
    }
    if (!in_array('arrived_at', $cols, true)) {
        $pdo->exec("ALTER TABLE appointments ADD COLUMN arrived_at DATETIME NULL AFTER arrival_status");
    }
    if (!in_array('service_started_at', $cols, true)) {
        $pdo->exec("ALTER TABLE appointments ADD COLUMN service_started_at DATETIME NULL AFTER arrived_at");
    }
    if (!in_array('completed_at', $cols, true)) {
        $pdo->exec("ALTER TABLE appointments ADD COLUMN completed_at DATETIME NULL AFTER service_started_at");
    }
}

function ensure_patient_management_columns($pdo) {
    $columns=$pdo->query("SHOW COLUMNS FROM patients")->fetchAll(PDO::FETCH_COLUMN);
    if (!in_array('preferred_rhu',$columns,true)) $pdo->exec("ALTER TABLE patients ADD COLUMN preferred_rhu VARCHAR(150) NULL AFTER is_4ps");
    if (!in_array('account_status',$columns,true)) $pdo->exec("ALTER TABLE patients ADD COLUMN account_status ENUM('Active','Archived') NOT NULL DEFAULT 'Active' AFTER preferred_rhu");
    if (!in_array('archived_at',$columns,true)) {
        $pdo->exec("ALTER TABLE patients ADD COLUMN archived_at DATETIME NULL AFTER account_status");
        $pdo->exec("UPDATE patients SET archived_at=NOW() WHERE account_status='Archived' AND archived_at IS NULL");
    }
}

function ensure_chat_thread_status_table($pdo) {
    $pdo->exec("CREATE TABLE IF NOT EXISTS chat_thread_status (
      patient_id INT PRIMARY KEY,
      status ENUM('Open','Waiting for Patient','Resolved') NOT NULL DEFAULT 'Open',
      rhu_branch VARCHAR(150) NULL,
      assigned_admin_id INT NULL,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_chat_thread_status (status,updated_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    $columns = $pdo->query("SHOW COLUMNS FROM chat_thread_status")->fetchAll(PDO::FETCH_COLUMN);
    if (!in_array('rhu_branch', $columns, true)) {
        $pdo->exec("ALTER TABLE chat_thread_status ADD COLUMN rhu_branch VARCHAR(150) NULL AFTER status");
    }
    if (!in_array('assigned_admin_id', $columns, true)) {
        $pdo->exec("ALTER TABLE chat_thread_status ADD COLUMN assigned_admin_id INT NULL AFTER rhu_branch");
    }
    if (!in_array('updated_at', $columns, true)) {
        $pdo->exec("ALTER TABLE chat_thread_status ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER assigned_admin_id");
    }
    $chatColumns = $pdo->query("SHOW COLUMNS FROM chat_messages")->fetchAll(PDO::FETCH_COLUMN);
    if (!in_array('is_automated', $chatColumns, true)) {
        $pdo->exec("ALTER TABLE chat_messages ADD COLUMN is_automated TINYINT(1) NOT NULL DEFAULT 0 AFTER is_read");
    }
}

function ensure_announcement_attachment_columns($pdo) {
    $columns=$pdo->query("SHOW COLUMNS FROM announcements")->fetchAll(PDO::FETCH_COLUMN);
    if (!in_array('attachment_path',$columns,true)) $pdo->exec("ALTER TABLE announcements ADD COLUMN attachment_path VARCHAR(255) NULL AFTER status");
    if (!in_array('attachment_name',$columns,true)) $pdo->exec("ALTER TABLE announcements ADD COLUMN attachment_name VARCHAR(255) NULL AFTER attachment_path");
    if (!in_array('attachment_mime',$columns,true)) $pdo->exec("ALTER TABLE announcements ADD COLUMN attachment_mime VARCHAR(100) NULL AFTER attachment_name");
    if (!in_array('target_barangay',$columns,true)) $pdo->exec("ALTER TABLE announcements ADD COLUMN target_barangay VARCHAR(120) NOT NULL DEFAULT 'All Barangays' AFTER branch");
    if (!in_array('priority',$columns,true)) $pdo->exec("ALTER TABLE announcements ADD COLUMN priority VARCHAR(30) NOT NULL DEFAULT 'normal' AFTER target_barangay");
    if (!in_array('publish_at',$columns,true)) $pdo->exec("ALTER TABLE announcements ADD COLUMN publish_at DATETIME NULL AFTER priority");
    if (!in_array('expires_at',$columns,true)) $pdo->exec("ALTER TABLE announcements ADD COLUMN expires_at DATETIME NULL AFTER publish_at");
}

function announcement_payload($row) {
    $path=ltrim((string)($row['attachment_path']??''),'/');
    $name=(string)($row['attachment_name']??'');
    $mime=strtolower((string)($row['attachment_mime']??''));
    $extension=strtolower(pathinfo($path!==''?$path:$name,PATHINFO_EXTENSION));
    $row['attachment_url']=$path!=='' ? '../backend/'.$path : '';
    $row['is_image']=strpos($mime,'image/')===0 || in_array($extension,['jpg','jpeg','png','webp'],true);
    return $row;
}

function save_announcement_attachment() {
    if (empty($_FILES['attachment']) || (int)($_FILES['attachment']['error']??UPLOAD_ERR_NO_FILE)===UPLOAD_ERR_NO_FILE) return null;
    $file=$_FILES['attachment'];
    $error=(int)($file['error']??UPLOAD_ERR_NO_FILE);
    if ($error!==UPLOAD_ERR_OK) {
        $message=in_array($error,[UPLOAD_ERR_INI_SIZE,UPLOAD_ERR_FORM_SIZE],true) ? 'The attachment is larger than the server upload limit.' : 'The announcement attachment could not be uploaded.';
        json_out(['ok'=>false,'message'=>$message],422);
    }
    if ((int)($file['size']??0)>5*1024*1024) json_out(['ok'=>false,'message'=>'Announcement attachments must be 5 MB or smaller.'],422);
    $finfo=new finfo(FILEINFO_MIME_TYPE);
    $mime=(string)$finfo->file($file['tmp_name']);
    $allowed=['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp','application/pdf'=>'pdf','text/plain'=>'txt'];
    if (!isset($allowed[$mime])) json_out(['ok'=>false,'message'=>'Use a JPG, PNG, WEBP, PDF, or TXT attachment.'],422);
    $directory=__DIR__.'/uploads/announcements';
    if (!is_dir($directory) && !mkdir($directory,0755,true) && !is_dir($directory)) json_out(['ok'=>false,'message'=>'Unable to prepare the announcement upload folder.'],500);
    $stored=bin2hex(random_bytes(16)).'.'.$allowed[$mime];
    if (!move_uploaded_file($file['tmp_name'],$directory.'/'.$stored)) json_out(['ok'=>false,'message'=>'Unable to save the announcement attachment.'],500);
    $original=preg_replace('/[^A-Za-z0-9._ -]/','_',basename((string)($file['name']??'attachment')));
    return ['path'=>'uploads/announcements/'.$stored,'name'=>mb_substr($original,0,255),'mime'=>$mime];
}

function delete_announcement_attachment($path) {
    $path=ltrim((string)$path,'/');
    if ($path==='' || strpos($path,'uploads/announcements/')!==0) return;
    $full=__DIR__.'/'.$path;
    if (is_file($full)) @unlink($full);
}

function ensure_notifications_table($pdo) {
    $pdo->exec("CREATE TABLE IF NOT EXISTS notifications (
      id INT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT NOT NULL,
      appointment_id INT NULL,
      type VARCHAR(40) NOT NULL DEFAULT 'info',
      title VARCHAR(150) NOT NULL,
      message TEXT NOT NULL,
      link VARCHAR(255) NULL,
      dedupe_key VARCHAR(190) NULL,
      is_read TINYINT(1) NOT NULL DEFAULT 0,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_notifications_patient (patient_id, is_read, created_at),
      UNIQUE KEY uniq_notification_dedupe (patient_id,dedupe_key)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    $columns=$pdo->query("SHOW COLUMNS FROM notifications")->fetchAll(PDO::FETCH_COLUMN);
    if (!in_array('dedupe_key',$columns,true)) {
        $pdo->exec("ALTER TABLE notifications ADD COLUMN dedupe_key VARCHAR(190) NULL AFTER link");
        try {$pdo->exec("ALTER TABLE notifications ADD UNIQUE KEY uniq_notification_dedupe (patient_id,dedupe_key)");} catch (Throwable $e) {}
    }
}



function ensure_smart_waitlist_tables($pdo) {
    $pdo->exec("CREATE TABLE IF NOT EXISTS appointment_waitlist (
      id INT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT NOT NULL,
      center VARCHAR(120) NOT NULL,
      service VARCHAR(150) NOT NULL,
      appointment_date DATE NOT NULL,
      appointment_time VARCHAR(20) NOT NULL,
      status ENUM('waiting','offered','accepted','declined','expired','cancelled') NOT NULL DEFAULT 'waiting',
      offer_expires_at DATETIME NULL,
      recovered_appointment_id INT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      UNIQUE KEY uniq_active_waitlist (patient_id,center,service,appointment_date,appointment_time),
      INDEX idx_waitlist_match (center,service,appointment_date,appointment_time,status,created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}

function smart_waitlist_offer_next($pdo,$appointment) {
    ensure_smart_waitlist_tables($pdo);
    $pdo->prepare("UPDATE appointment_waitlist SET status='expired' WHERE status='offered' AND offer_expires_at<NOW()") ->execute();
    $stmt=$pdo->prepare("SELECT * FROM appointment_waitlist WHERE center=? AND service=? AND appointment_date=? AND appointment_time=? AND status='waiting' ORDER BY created_at,id LIMIT 1");
    $stmt->execute([$appointment['center'],$appointment['service'],$appointment['appointment_date'],$appointment['appointment_time']]);
    $entry=$stmt->fetch();
    if(!$entry)return null;
    $expires=date('Y-m-d H:i:s',time()+600);
    $pdo->prepare("UPDATE appointment_waitlist SET status='offered',offer_expires_at=?,recovered_appointment_id=? WHERE id=? AND status='waiting'")->execute([$expires,$appointment['id'],$entry['id']]);
    create_patient_notification($pdo,(int)$entry['patient_id'],null,'appointment','Earlier Appointment Slot Available',
      "A {$appointment['service']} slot is now available at {$appointment['center']} on ".date('F j, Y',strtotime($appointment['appointment_date']))." at {$appointment['appointment_time']}. Accept it within 10 minutes.",
      'book.html?waitlist_offer='.(int)$entry['id'],'waitlist-offer:'.(int)$entry['id'].':'.strtotime($expires));
    return $entry;
}
function create_patient_notification($pdo, $patientId, $appointmentId, $type, $title, $message, $link = 'appointments.html', $dedupeKey = null) {
    try {
        ensure_notifications_table($pdo);
        if ($dedupeKey === null && $appointmentId) {
            $dedupeKey='appointment:'.(int)$appointmentId.':'.strtolower(preg_replace('/[^a-z0-9]+/i','-',trim((string)$title))).':'.date('Y-m-d');
        }
        $dedupeKey=$dedupeKey!==null?mb_substr((string)$dedupeKey,0,190):null;
        $stmt = $pdo->prepare("INSERT IGNORE INTO notifications(patient_id,appointment_id,type,title,message,link,dedupe_key) VALUES(?,?,?,?,?,?,?)");
        $stmt->execute([(int)$patientId, $appointmentId ? (int)$appointmentId : null, $type, $title, $message, $link, $dedupeKey]);
        if (!$stmt->rowCount()) return true;
        if (function_exists('operations_log_delivery')) operations_log_delivery($pdo,[
            'channel'=>'in_app','patient_id'=>(int)$patientId,'appointment_id'=>$appointmentId ? (int)$appointmentId : null,
            'event_type'=>$type ?: 'notification','title'=>$title,'message'=>$message,'link'=>$link,
            'status'=>'delivered','provider_record_id'=>(string)$pdo->lastInsertId()
        ]);
        return true;
    } catch (Throwable $e) {
        error_log('[notifications] ' . $e->getMessage());
        if (function_exists('operations_log_delivery')) operations_log_delivery($pdo,[
            'channel'=>'in_app','patient_id'=>(int)$patientId,'appointment_id'=>$appointmentId ? (int)$appointmentId : null,
            'event_type'=>$type ?: 'notification','title'=>$title,'message'=>$message,'link'=>$link,
            'status'=>'failed','error_message'=>$e->getMessage()
        ]);
        return false;
    }
}

function appointment_notification_copy($status, $appointment) {
    $service = $appointment['service'] ?? 'appointment';
    $date = $appointment['appointment_date'] ?? '';
    $time = $appointment['appointment_time'] ?? '';
    $queue = $appointment['queue_number'] ?? '';
    $when = trim($date . ' ' . $time);

    $map = [
      'Confirmed' => ['success', 'Appointment Confirmed', "Your {$service} appointment on {$when} is confirmed. Your live queue number will be assigned when you check in."],
      'Serving' => ['queue', 'Your Queue Is Being Called', "Queue {$queue} is now being served. Please proceed to the assigned service area."],
      'Done' => ['success', 'Appointment Completed', "Your {$service} appointment has been marked completed."],
      'Cancelled' => ['danger', 'Appointment Cancelled', "Your {$service} appointment on {$when} was cancelled."],
      'No Show' => ['warning', 'Appointment Marked No Show', "Your {$service} appointment on {$when} was marked as no show."],
      'Hold' => ['warning', 'Queue Temporarily On Hold', "Queue {$queue} is temporarily on hold. Please wait for the next staff update."],
      'Pending' => ['info', 'Appointment Pending Review', "Your {$service} appointment requires manual review."]
    ];
    return $map[$status] ?? ['info', 'Appointment Updated', "Your appointment status changed to {$status}."];
}

function apply_appointment_auto_confirmation_policy($pdo) {
    static $applied = false;
    if ($applied) return;
    $applied = true;
    try {
        $rows = $pdo->query("SELECT * FROM appointments WHERE LOWER(TRIM(status))='pending' AND appointment_date>=CURDATE()")->fetchAll();
        if (!$rows) return;
        $pdo->exec("UPDATE appointments SET status='Confirmed',updated_at=NOW() WHERE LOWER(TRIM(status))='pending' AND appointment_date>=CURDATE()");
        foreach ($rows as $row) {
            $row['status'] = 'Confirmed';
            [$type,$title,$message] = appointment_notification_copy('Confirmed',$row);
            create_patient_notification($pdo,(int)$row['patient_id'],(int)$row['id'],$type,$title,$message,'appointments.html?appointment='.(int)$row['id'],'auto-confirm:'.(int)$row['id']);
        }
    } catch (Throwable $e) {
        error_log('[appointment-auto-confirm] ' . $e->getMessage());
    }
}

function patient_display_name($pdo, $patientId) {
    $stmt=$pdo->prepare("SELECT TRIM(CONCAT(COALESCE(first_name,''),' ',COALESCE(last_name,''))) FROM patients WHERE id=? LIMIT 1");
    $stmt->execute([(int)$patientId]);
    return trim((string)$stmt->fetchColumn()) ?: 'Patient';
}

function ensure_sms_logs_table($pdo) {
    $pdo->exec("CREATE TABLE IF NOT EXISTS sms_logs (
      id INT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT NULL,
      appointment_id INT NULL,
      recipient VARCHAR(30) NOT NULL,
      event_type VARCHAR(50) NOT NULL,
      message TEXT NOT NULL,
      status VARCHAR(30) NOT NULL DEFAULT 'pending',
      provider_message_id VARCHAR(150) NULL,
      provider_response TEXT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_sms_patient (patient_id, created_at),
      INDEX idx_sms_appointment (appointment_id, created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}

function normalize_ph_mobile($phone) {
    $digits = preg_replace('/\D+/', '', (string)$phone);

    if (strpos($digits, '0063') === 0) {
        $digits = substr($digits, 2);
    }

    if (strpos($digits, '63') === 0 && strlen($digits) === 12) {
        return '+' . $digits;
    }

    if (strpos($digits, '09') === 0 && strlen($digits) === 11) {
        return '+63' . substr($digits, 1);
    }

    if (strpos($digits, '9') === 0 && strlen($digits) === 10) {
        return '+63' . $digits;
    }

    return null;
}

function brevo_sms_enabled() {
    $key = trim((string)getenv('BREVO_API_KEY'));
    return $key !== '' && stripos($key, 'REPLACE_') !== 0;
}

function send_brevo_sms($pdo, $recipient, $message, $eventType, $patientId = null, $appointmentId = null) {
    $normalized = normalize_ph_mobile($recipient);

    if (!$normalized) {
        return ['ok'=>false, 'skipped'=>true, 'message'=>'Patient mobile number is missing or invalid.'];
    }

    if (!brevo_sms_enabled()) {
        return ['ok'=>false, 'skipped'=>true, 'message'=>'Brevo SMS is not configured.'];
    }

    if (!function_exists('curl_init')) {
        return ['ok'=>false, 'skipped'=>true, 'message'=>'PHP cURL extension is not enabled.'];
    }

    $apiKey = trim((string)getenv('BREVO_API_KEY'));
    $sender = preg_replace('/[^A-Za-z0-9]/', '', (string)(getenv('BREVO_SMS_SENDER') ?: 'PULILANHC'));
    $sender = substr($sender, 0, 11);
    $content = trim((string)$message);

    try {
        ensure_sms_logs_table($pdo);
        $log = $pdo->prepare("INSERT INTO sms_logs(patient_id,appointment_id,recipient,event_type,message,status) VALUES(?,?,?,?,?,'pending')");
        $log->execute([
            $patientId ? (int)$patientId : null,
            $appointmentId ? (int)$appointmentId : null,
            $normalized,
            $eventType,
            $content
        ]);
        $logId = (int)$pdo->lastInsertId();
    } catch (Throwable $e) {
        $logId = 0;
        error_log('[sms-log] ' . $e->getMessage());
    }

    $payload = json_encode([
        'sender' => $sender,
        'recipient' => $normalized,
        'content' => $content,
        'type' => 'transactional',
        'tag' => 'pulilan-health-center'
    ], JSON_UNESCAPED_SLASHES);

    $curl = curl_init('https://api.brevo.com/v3/transactionalSMS/sms');
    curl_setopt_array($curl, [
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CONNECTTIMEOUT => 10,
        CURLOPT_TIMEOUT => 25,
        CURLOPT_HTTPHEADER => [
            'accept: application/json',
            'api-key: ' . $apiKey,
            'content-type: application/json'
        ],
        CURLOPT_POSTFIELDS => $payload
    ]);

    $responseBody = curl_exec($curl);
    $curlError = curl_error($curl);
    $httpCode = (int)curl_getinfo($curl, CURLINFO_HTTP_CODE);
    curl_close($curl);

    $decoded = json_decode((string)$responseBody, true);
    $providerId = is_array($decoded)
        ? (string)($decoded['messageId'] ?? $decoded['reference'] ?? '')
        : '';

    $ok = $curlError === '' && $httpCode >= 200 && $httpCode < 300;

    if ($logId > 0) {
        try {
            $update = $pdo->prepare("UPDATE sms_logs SET status=?, provider_message_id=?, provider_response=? WHERE id=?");
            $update->execute([
                $ok ? 'sent' : 'failed',
                $providerId ?: null,
                $curlError !== '' ? $curlError : (string)$responseBody,
                $logId
            ]);
        } catch (Throwable $e) {
            error_log('[sms-log-update] ' . $e->getMessage());
        }
    }

    if (!$ok) {
        error_log('[brevo-sms] HTTP ' . $httpCode . ' ' . ($curlError ?: (string)$responseBody));
    }

    return [
        'ok' => $ok,
        'httpCode' => $httpCode,
        'messageId' => $providerId,
        'message' => $ok ? 'SMS accepted by Brevo.' : 'SMS could not be sent.',
        'providerResponse' => $decoded ?: $responseBody
    ];
}

function appointment_sms_message($status, $appointment, $patientName = 'Patient') {
    $service = trim((string)($appointment['service'] ?? 'appointment'));
    $date = trim((string)($appointment['appointment_date'] ?? ''));
    $time = trim((string)($appointment['appointment_time'] ?? ''));
    $queue = trim((string)($appointment['queue_number'] ?? ''));
    $center = trim((string)($appointment['center'] ?? 'Pulilan Health Center'));
    $firstName = trim(explode(' ', trim((string)$patientName))[0] ?? 'Patient');

    $messages = [
        'Confirmed' => "Pulilan Health Center: Hi {$firstName}, your {$service} appointment is confirmed for {$date} at {$time}, {$center}. Queue: {$queue}. Please arrive 15 minutes early.",
        'Serving' => "Pulilan Health Center: Hi {$firstName}, queue {$queue} is now being called at {$center}. Please proceed to the assigned service area.",
        'Cancelled' => "Pulilan Health Center: Hi {$firstName}, your {$service} appointment on {$date} at {$time} has been cancelled. Please log in to book another schedule.",
        'No Show' => "Pulilan Health Center: Hi {$firstName}, your {$service} appointment on {$date} at {$time} was marked No Show. Please contact the health center or book again.",
        'Done' => "Pulilan Health Center: Hi {$firstName}, your {$service} appointment has been completed. Thank you.",
        'Hold' => "Pulilan Health Center: Hi {$firstName}, queue {$queue} is temporarily on hold. Please wait for the next staff update.",
        'Rescheduled' => "Pulilan Health Center: Hi {$firstName}, your {$service} appointment was rescheduled to {$date} at {$time}, {$center}. Queue: {$queue}."
    ];

    return $messages[$status] ?? "Pulilan Health Center: Hi {$firstName}, your appointment status is now {$status}.";
}

function send_appointment_sms($pdo, $appointment, $status) {
    if (!$appointment || empty($appointment['patient_id'])) {
        return ['ok'=>false, 'skipped'=>true, 'message'=>'Appointment patient is unavailable.'];
    }

    $stmt = $pdo->prepare("SELECT first_name,last_name,phone FROM patients WHERE id=?");
    $stmt->execute([(int)$appointment['patient_id']]);
    $patient = $stmt->fetch();

    if (!$patient) {
        return ['ok'=>false, 'skipped'=>true, 'message'=>'Patient record was not found.'];
    }

    $name = trim(($patient['first_name'] ?? '') . ' ' . ($patient['last_name'] ?? ''));
    $message = appointment_sms_message($status, $appointment, $name ?: 'Patient');

    return send_brevo_sms(
        $pdo,
        $patient['phone'] ?? '',
        $message,
        strtolower(str_replace(' ', '_', $status)),
        (int)$appointment['patient_id'],
        (int)($appointment['id'] ?? 0)
    );
}

function ensure_email_logs_table($pdo) {
    $pdo->exec("CREATE TABLE IF NOT EXISTS email_logs (
      id INT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT NULL,
      appointment_id INT NULL,
      recipient VARCHAR(190) NOT NULL,
      event_type VARCHAR(50) NOT NULL,
      subject VARCHAR(190) NOT NULL,
      status VARCHAR(30) NOT NULL DEFAULT 'pending',
      provider_message_id VARCHAR(190) NULL,
      provider_response TEXT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_email_patient (patient_id, created_at),
      INDEX idx_email_appointment (appointment_id, created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}

function brevo_email_enabled() {
    $key = trim((string)getenv('BREVO_API_KEY'));
    $senderEmail = trim((string)getenv('BREVO_SENDER_EMAIL'));

    return $key !== ''
        && stripos($key, 'REPLACE_') !== 0
        && filter_var($senderEmail, FILTER_VALIDATE_EMAIL);
}

function send_brevo_email(
    $pdo,
    $recipientEmail,
    $recipientName,
    $subject,
    $htmlContent,
    $eventType,
    $patientId = null,
    $appointmentId = null
) {
    $recipientEmail = trim((string)$recipientEmail);

    if (!filter_var($recipientEmail, FILTER_VALIDATE_EMAIL)) {
        if (function_exists('operations_log_delivery')) operations_log_delivery($pdo,['channel'=>'email','patient_id'=>$patientId,'appointment_id'=>$appointmentId,'recipient'=>$recipientEmail,'event_type'=>$eventType,'title'=>$subject,'status'=>'skipped','error_message'=>'Recipient email address is missing or invalid.']);
        return ['ok'=>false,'skipped'=>true,'message'=>'Patient email address is missing or invalid.'];
    }

    if (!brevo_email_enabled()) {
        if (function_exists('operations_log_delivery')) operations_log_delivery($pdo,['channel'=>'email','patient_id'=>$patientId,'appointment_id'=>$appointmentId,'recipient'=>$recipientEmail,'event_type'=>$eventType,'title'=>$subject,'status'=>'skipped','error_message'=>'Brevo email is not configured.']);
        return ['ok'=>false,'skipped'=>true,'message'=>'Brevo email is not configured.'];
    }

    if (!function_exists('curl_init')) {
        if (function_exists('operations_log_delivery')) operations_log_delivery($pdo,['channel'=>'email','patient_id'=>$patientId,'appointment_id'=>$appointmentId,'recipient'=>$recipientEmail,'event_type'=>$eventType,'title'=>$subject,'status'=>'skipped','error_message'=>'PHP cURL extension is not enabled.']);
        return ['ok'=>false,'skipped'=>true,'message'=>'PHP cURL extension is not enabled.'];
    }

    $apiKey = trim((string)getenv('BREVO_API_KEY'));
    $senderEmail = trim((string)getenv('BREVO_SENDER_EMAIL'));
    $senderName = trim((string)(getenv('BREVO_SENDER_NAME') ?: 'Pulilan Health Center'));

    try {
        ensure_email_logs_table($pdo);
        $log = $pdo->prepare(
            "INSERT INTO email_logs(
                patient_id,appointment_id,recipient,event_type,subject,status
             ) VALUES(?,?,?,?,?,'pending')"
        );
        $log->execute([
            $patientId ? (int)$patientId : null,
            $appointmentId ? (int)$appointmentId : null,
            $recipientEmail,
            $eventType,
            $subject
        ]);
        $logId = (int)$pdo->lastInsertId();
    } catch (Throwable $e) {
        $logId = 0;
        error_log('[email-log] ' . $e->getMessage());
    }

    $payload = json_encode([
        'sender' => [
            'name' => $senderName,
            'email' => $senderEmail
        ],
        'to' => [[
            'email' => $recipientEmail,
            'name' => trim((string)$recipientName) ?: 'Patient'
        ]],
        'subject' => $subject,
        'htmlContent' => $htmlContent,
        'tags' => ['pulilan-health-center']
    ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);

    $curl = curl_init('https://api.brevo.com/v3/smtp/email');
    curl_setopt_array($curl, [
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CONNECTTIMEOUT => 10,
        CURLOPT_TIMEOUT => 25,
        CURLOPT_HTTPHEADER => [
            'accept: application/json',
            'api-key: ' . $apiKey,
            'content-type: application/json'
        ],
        CURLOPT_POSTFIELDS => $payload
    ]);

    $responseBody = curl_exec($curl);
    $curlError = curl_error($curl);
    $httpCode = (int)curl_getinfo($curl, CURLINFO_HTTP_CODE);
    curl_close($curl);

    $decoded = json_decode((string)$responseBody, true);
    $providerId = is_array($decoded)
        ? (string)($decoded['messageId'] ?? $decoded['message_id'] ?? '')
        : '';

    $ok = $curlError === '' && $httpCode >= 200 && $httpCode < 300;

    if ($logId > 0) {
        try {
            $update = $pdo->prepare(
                "UPDATE email_logs
                 SET status=?,provider_message_id=?,provider_response=?
                 WHERE id=?"
            );
            $update->execute([
                $ok ? 'sent' : 'failed',
                $providerId ?: null,
                $curlError !== '' ? $curlError : (string)$responseBody,
                $logId
            ]);
        } catch (Throwable $e) {
            error_log('[email-log-update] ' . $e->getMessage());
        }
    }

    if (!$ok) {
        error_log('[brevo-email] HTTP ' . $httpCode . ' ' . ($curlError ?: (string)$responseBody));
    }

    return [
        'ok'=>$ok,
        'httpCode'=>$httpCode,
        'messageId'=>$providerId,
        'message'=>$ok ? 'Email accepted by Brevo.' : 'Email could not be sent.',
        'providerResponse'=>$decoded ?: $responseBody
    ];
}

function appointment_email_content($status, $appointment, $patientName = 'Patient') {
    $service = htmlspecialchars((string)($appointment['service'] ?? 'Appointment'));
    $date = htmlspecialchars((string)($appointment['appointment_date'] ?? ''));
    $time = htmlspecialchars((string)($appointment['appointment_time'] ?? ''));
    $queue = htmlspecialchars((string)($appointment['queue_number'] ?? ''));
    $queueLabel=preg_match('/^[APE]-/',$appointment['queue_number']??'')?'Queue Number':'Appointment Reference';
    $center = htmlspecialchars((string)($appointment['center'] ?? 'Pulilan Health Center'));
    $safeName = htmlspecialchars(trim((string)$patientName) ?: 'Patient');

    $titles = [
        'Confirmed'=>'Appointment Confirmed',
        'Serving'=>'Your Queue Is Being Called',
        'Cancelled'=>'Appointment Cancelled',
        'No Show'=>'Appointment Marked No Show',
        'Done'=>'Appointment Completed',
        'Hold'=>'Queue Temporarily On Hold',
        'Rescheduled'=>'Appointment Rescheduled'
    ];

    $messages = [
        'Confirmed'=>"Your {$service} appointment has been confirmed.",
        'Serving'=>"Your queue number <strong>{$queue}</strong> is now being called. Please proceed to the assigned service area.",
        'Cancelled'=>"Your {$service} appointment has been cancelled.",
        'No Show'=>"Your {$service} appointment was marked as No Show.",
        'Done'=>"Your {$service} appointment has been completed.",
        'Hold'=>"Your queue number <strong>{$queue}</strong> is temporarily on hold.",
        'Rescheduled'=>"Your {$service} appointment has been rescheduled."
    ];

    $title = $titles[$status] ?? 'Appointment Update';
    $message = $messages[$status] ?? "Your appointment status is now {$status}.";

    $html = "
    <div style='font-family:Arial,sans-serif;background:#f3f6fb;padding:28px'>
      <div style='max-width:620px;margin:auto;background:#ffffff;border:1px solid #dbe4ef;border-radius:12px;overflow:hidden'>
        <div style='background:#0b3d91;color:#ffffff;padding:20px 24px'>
          <h2 style='margin:0;font-size:21px'>Pulilan Health Center</h2>
          <p style='margin:5px 0 0;color:#dbeafe;font-size:13px'>Appointment and Queue Management System</p>
        </div>
        <div style='padding:24px'>
          <p style='margin:0 0 14px'>Hello <strong>{$safeName}</strong>,</p>
          <h3 style='margin:0 0 10px;color:#0f274f'>{$title}</h3>
          <p style='margin:0 0 20px;color:#475569;line-height:1.6'>{$message}</p>

          <table style='width:100%;border-collapse:collapse;font-size:14px'>
            <tr><td style='padding:9px;border-bottom:1px solid #edf2f7;color:#64748b'>Service</td><td style='padding:9px;border-bottom:1px solid #edf2f7;font-weight:bold'>{$service}</td></tr>
            <tr><td style='padding:9px;border-bottom:1px solid #edf2f7;color:#64748b'>Date</td><td style='padding:9px;border-bottom:1px solid #edf2f7;font-weight:bold'>{$date}</td></tr>
            <tr><td style='padding:9px;border-bottom:1px solid #edf2f7;color:#64748b'>Time</td><td style='padding:9px;border-bottom:1px solid #edf2f7;font-weight:bold'>{$time}</td></tr>
            <tr><td style='padding:9px;border-bottom:1px solid #edf2f7;color:#64748b'>Health Center</td><td style='padding:9px;border-bottom:1px solid #edf2f7;font-weight:bold'>{$center}</td></tr>
            <tr><td style='padding:9px;color:#64748b'>{$queueLabel}</td><td style='padding:9px;font-weight:bold;color:#0b4eea'>{$queue}</td></tr>
          </table>

          <p style='margin:22px 0 0;color:#64748b;font-size:12px'>
            Please arrive 15 minutes before your scheduled time and bring a valid ID.
          </p>
        </div>
        <div style='padding:14px 24px;background:#f8fafc;color:#94a3b8;text-align:center;font-size:11px'>
          © 2026 Pulilan Health Center
        </div>
      </div>
    </div>";

    return [$title, $html];
}

function send_appointment_email($pdo, $appointment, $status) {
    if (!$appointment || empty($appointment['patient_id'])) {
        return ['ok'=>false,'skipped'=>true,'message'=>'Appointment patient is unavailable.'];
    }

    $stmt = $pdo->prepare(
        "SELECT first_name,last_name,email
         FROM patients
         WHERE id=?"
    );
    $stmt->execute([(int)$appointment['patient_id']]);
    $patient = $stmt->fetch();

    if (!$patient) {
        return ['ok'=>false,'skipped'=>true,'message'=>'Patient record was not found.'];
    }

    $name = trim(($patient['first_name'] ?? '') . ' ' . ($patient['last_name'] ?? ''));
    [$subject, $html] = appointment_email_content($status, $appointment, $name);

    return send_brevo_email(
        $pdo,
        $patient['email'] ?? '',
        $name,
        'Pulilan Health Center - ' . $subject,
        $html,
        strtolower(str_replace(' ', '_', $status)),
        (int)$appointment['patient_id'],
        (int)($appointment['id'] ?? 0)
    );
}

function pulilan_barangays() {
    return ["Balatong A", "Balatong B", "Cutcot", "Dampol 1st", "Dampol 2nd - A", "Dampol 2nd - B", "Dulong Malabon", "Inaon", "Longos", "Lumbac", "Paltao", "Penabatan", "Poblacion", "Santa Peregrina", "Santo Cristo", "Taal", "Tabon", "Tenejeros", "Tibag"];
}

function allowed_disease_categories() {
    return ["Acute Respiratory Infection", "Hypertension", "Diabetes", "Dengue", "Diarrhea", "Skin Disease", "Maternal Health Condition", "Tuberculosis", "Other"];
}

function allowed_rhu_branches() {
    return ["RHU I - Poblacion", "RHU II - Cutcot", "RHU III - Tinejero", "RHU IV - Tibag"];
}

function allowed_disease_statuses() {
    return ["Recorded", "Under Monitoring", "Recovered", "Referred"];
}

function normalize_barangay_name($value) {
    $value = trim((string)$value);
    foreach (pulilan_barangays() as $barangay) {
        if (strcasecmp($barangay, $value) === 0) return $barangay;
    }
    return null;
}

function validate_disease_case_payload($pdo, $data, $existingId = 0) {
    $patientId = (int)($data['patient_id'] ?? 0);
    $appointmentId = (int)($data['appointment_id'] ?? 0);
    $category = trim((string)($data['disease_category'] ?? ''));
    $diagnosis = trim((string)($data['diagnosis'] ?? ''));
    $symptoms = trim((string)($data['symptoms'] ?? ''));
    $barangay = normalize_barangay_name($data['barangay'] ?? '');
    $rhu = trim((string)($data['rhu_branch'] ?? ''));
    $caseDate = trim((string)($data['case_date'] ?? ''));
    $onsetDate = trim((string)($data['onset_date'] ?? ''));
    $caseStatus = trim((string)($data['case_status'] ?? 'Recorded'));

    if (!in_array($category, allowed_disease_categories(), true)) {
        json_out(['ok'=>false,'message'=>'Select a valid disease category.'],422);
    }
    if ($barangay === null) {
        json_out(['ok'=>false,'message'=>'Select a valid Pulilan barangay.'],422);
    }
    if (!in_array($rhu, allowed_rhu_branches(), true)) {
        json_out(['ok'=>false,'message'=>'Select a valid RHU branch.'],422);
    }
    if (!in_array($caseStatus, allowed_disease_statuses(), true)) {
        json_out(['ok'=>false,'message'=>'Select a valid case status.'],422);
    }

    $caseDt = DateTime::createFromFormat('Y-m-d', $caseDate);
    $caseErrors = DateTime::getLastErrors();
    if (!$caseDt || ($caseErrors && ($caseErrors['warning_count'] || $caseErrors['error_count']))) {
        json_out(['ok'=>false,'message'=>'Enter a valid case date.'],422);
    }
    $today = new DateTime('today');
    if ($caseDt > $today) {
        json_out(['ok'=>false,'message'=>'Case date cannot be in the future.'],422);
    }

    if ($onsetDate !== '') {
        $onsetDt = DateTime::createFromFormat('Y-m-d', $onsetDate);
        $onsetErrors = DateTime::getLastErrors();
        if (!$onsetDt || ($onsetErrors && ($onsetErrors['warning_count'] || $onsetErrors['error_count']))) {
            json_out(['ok'=>false,'message'=>'Enter a valid onset date.'],422);
        }
        if ($onsetDt > $caseDt) {
            json_out(['ok'=>false,'message'=>'Onset date cannot be later than the case date.'],422);
        }
    }

    if ($patientId > 0) {
        $stmt=$pdo->prepare("SELECT id FROM patients WHERE id=?");
        $stmt->execute([$patientId]);
        if (!$stmt->fetchColumn()) json_out(['ok'=>false,'message'=>'Linked patient does not exist.'],422);
    }

    if ($appointmentId > 0) {
        $stmt=$pdo->prepare("SELECT patient_id FROM appointments WHERE id=?");
        $stmt->execute([$appointmentId]);
        $appointmentPatient=$stmt->fetchColumn();
        if ($appointmentPatient === false) json_out(['ok'=>false,'message'=>'Linked appointment does not exist.'],422);
        if ($patientId > 0 && (int)$appointmentPatient !== $patientId) {
            json_out(['ok'=>false,'message'=>'Appointment does not belong to the selected patient.'],422);
        }
    }

    $duplicateSql = "SELECT id FROM disease_cases
                     WHERE disease_category=? AND case_date=?
                       AND ((appointment_id IS NOT NULL AND appointment_id=?)
                         OR (appointment_id IS NULL AND patient_id IS NOT NULL AND patient_id=?))";
    $params = [$category,$caseDate,$appointmentId ?: -1,$patientId ?: -1];
    if ($existingId > 0) {
        $duplicateSql .= " AND id<>?";
        $params[] = $existingId;
    }
    $duplicateSql .= " LIMIT 1";
    $stmt=$pdo->prepare($duplicateSql);
    $stmt->execute($params);
    if ($stmt->fetchColumn()) {
        json_out(['ok'=>false,'message'=>'A matching disease case already exists for this patient or appointment and case date.'],409);
    }

    return [
      'patient_id'=>$patientId ?: null,
      'appointment_id'=>$appointmentId ?: null,
      'disease_category'=>$category,
      'diagnosis'=>$diagnosis ?: null,
      'symptoms'=>$symptoms ?: null,
      'barangay'=>$barangay,
      'rhu_branch'=>$rhu,
      'case_date'=>$caseDate,
      'onset_date'=>$onsetDate ?: null,
      'case_status'=>$caseStatus
    ];
}

function ensure_disease_cases_table($pdo) {
    $pdo->exec("CREATE TABLE IF NOT EXISTS disease_cases (
      id INT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT NULL,
      appointment_id INT NULL,
      disease_category VARCHAR(150) NOT NULL,
      diagnosis VARCHAR(255) NULL,
      symptoms TEXT NULL,
      barangay VARCHAR(120) NOT NULL,
      rhu_branch VARCHAR(150) NOT NULL,
      case_date DATE NOT NULL,
      onset_date DATE NULL,
      age_group VARCHAR(50) NOT NULL DEFAULT 'Unknown',
      case_status VARCHAR(50) NOT NULL DEFAULT 'Recorded',
      verification_status ENUM('Verified','Pending','Rejected') NOT NULL DEFAULT 'Verified',
      record_source VARCHAR(120) NOT NULL DEFAULT 'RHU Consultation',
      recorded_by INT NULL,
      verified_by INT NULL,
      verified_at DATETIME NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_disease_date (case_date),
      INDEX idx_disease_category (disease_category),
      INDEX idx_disease_barangay (barangay),
      INDEX idx_disease_rhu (rhu_branch)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $columns=$pdo->query("SHOW COLUMNS FROM disease_cases")->fetchAll(PDO::FETCH_COLUMN);
    if (!in_array('verification_status',$columns,true)) {
        $pdo->exec("ALTER TABLE disease_cases ADD COLUMN verification_status ENUM('Verified','Pending','Rejected') NOT NULL DEFAULT 'Verified' AFTER case_status");
    }
    if (!in_array('record_source',$columns,true)) {
        $pdo->exec("ALTER TABLE disease_cases ADD COLUMN record_source VARCHAR(120) NOT NULL DEFAULT 'RHU Consultation' AFTER verification_status");
    }
    if (!in_array('verified_by',$columns,true)) {
        $pdo->exec("ALTER TABLE disease_cases ADD COLUMN verified_by INT NULL AFTER recorded_by");
    }
    if (!in_array('verified_at',$columns,true)) {
        $pdo->exec("ALTER TABLE disease_cases ADD COLUMN verified_at DATETIME NULL AFTER verified_by");
        $pdo->exec("UPDATE disease_cases SET verified_at=COALESCE(verified_at,created_at) WHERE verification_status='Verified'");
    }

    try {
        $pdo->exec("ALTER TABLE disease_cases ADD UNIQUE KEY uniq_disease_appointment_date (appointment_id,disease_category,case_date)");
    } catch (Throwable $e) {

    }
}

function derive_age_group($birthdate, $caseDate = null) {
    if (!$birthdate) return 'Unknown';
    try {
        $birth = new DateTime($birthdate);
        $ref = new DateTime($caseDate ?: 'today');
        $age = (int)$birth->diff($ref)->y;
        if ($age <= 5) return '0-5';
        if ($age <= 12) return '6-12';
        if ($age <= 17) return '13-17';
        if ($age <= 35) return '18-35';
        if ($age <= 59) return '36-59';
        return '60+';
    } catch (Throwable $e) {
        return 'Unknown';
    }
}

function ensure_admin_activity_columns($pdo) {
    $columns = [
      'account_status' => "ENUM('Active','Disabled') NOT NULL DEFAULT 'Active'",
      'last_login_at' => "DATETIME NULL",
      'last_activity_at' => "DATETIME NULL",
      'last_logout_at' => "DATETIME NULL",
      'last_notification_read_at' => "DATETIME NULL",
      'last_ip' => "VARCHAR(64) NULL",
      'last_user_agent' => "VARCHAR(255) NULL"
    ];
    foreach ($columns as $name => $definition) {
        try {
            $check=$pdo->prepare("SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='admins' AND COLUMN_NAME=?");
            $check->execute([$name]);
            if (!(int)$check->fetchColumn()) {
                $pdo->exec("ALTER TABLE admins ADD COLUMN {$name} {$definition}");
                if ($name === 'last_notification_read_at') {
                    $pdo->exec("UPDATE admins SET last_notification_read_at=NOW() WHERE last_notification_read_at IS NULL");
                }
            }
        } catch (Throwable $e) { error_log('[admin activity column] '.$e->getMessage()); }
    }
}

function touch_admin_activity($pdo, $adminId, $login=false, $logout=false) {
    ensure_admin_activity_columns($pdo);
    $ip=substr((string)($_SERVER['REMOTE_ADDR'] ?? ''),0,64);
    $ua=substr((string)($_SERVER['HTTP_USER_AGENT'] ?? ''),0,255);
    if ($login) {
        $stmt=$pdo->prepare("UPDATE admins SET last_login_at=NOW(),last_activity_at=NOW(),last_ip=?,last_user_agent=? WHERE id=?");
        $stmt->execute([$ip,$ua,$adminId]);
    } elseif ($logout) {
        $stmt=$pdo->prepare("UPDATE admins SET last_logout_at=NOW(),last_activity_at=NOW() WHERE id=?");
        $stmt->execute([$adminId]);
    } else {
        $stmt=$pdo->prepare("UPDATE admins SET last_activity_at=NOW(),last_ip=?,last_user_agent=? WHERE id=?");
        $stmt->execute([$ip,$ua,$adminId]);
    }
}

function ensure_audit_columns($pdo) {
    $defs = [
      'user_type' => "VARCHAR(30) NOT NULL DEFAULT 'admin' AFTER id",
      'user_name' => "VARCHAR(150) NOT NULL DEFAULT 'Administrator' AFTER user_type",
      'email' => "VARCHAR(150) NULL AFTER user_name",
      'role' => "VARCHAR(100) NULL AFTER email",
      'branch' => "VARCHAR(150) NULL AFTER role",
      'module' => "VARCHAR(100) NULL AFTER branch",
      'action' => "VARCHAR(150) NOT NULL DEFAULT 'Action' AFTER module",
      'details' => "TEXT NULL AFTER action"
    ];
    foreach ($defs as $column => $definition) {
        hc_add_column($pdo, 'audit_logs', $column, $definition);
    }
}

function audit_event($pdo, $admin, $module, $action, $details) {
    try {
        $pdo->exec("CREATE TABLE IF NOT EXISTS audit_logs (
          id INT AUTO_INCREMENT PRIMARY KEY,
          user_type VARCHAR(30) NOT NULL DEFAULT 'admin',
          user_name VARCHAR(150) NOT NULL DEFAULT 'Administrator',
          email VARCHAR(150) NULL,
          role VARCHAR(100) NULL,
          branch VARCHAR(150) NULL,
          module VARCHAR(100) NULL,
          action VARCHAR(150) NOT NULL DEFAULT 'Action',
          details TEXT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        ensure_audit_columns($pdo);
        $stmt=$pdo->prepare("INSERT INTO audit_logs(user_type,user_name,email,role,branch,module,action,details) VALUES(?,?,?,?,?,?,?,?)");
        $stmt->execute([
          'admin',
          $admin['name'] ?? 'Administrator',
          $admin['email'] ?? '',
          $admin['role'] ?? '',
          $admin['branch'] ?? '',
          $module,
          $action,
          $details
        ]);
    } catch (Throwable $e) {
        error_log('[audit] '.$e->getMessage());
    }
}

function require_admin_context($pdo, $systemOnly = false) {
    if (empty($_SESSION['admin_id'])) json_out(['ok'=>false,'message'=>'Admin login required.'],401);
    ensure_admin_activity_columns($pdo);
    $stmt = $pdo->prepare('SELECT id, name, email, role, branch, account_status FROM admins WHERE id=?');
    $stmt->execute([$_SESSION['admin_id']]);
    $admin = $stmt->fetch();
    if (!$admin) json_out(['ok'=>false,'message'=>'Admin account not found.'],404);
    if (($admin['account_status'] ?? 'Active') !== 'Active') {
        unset($_SESSION['admin_id']);
        json_out(['ok'=>false,'message'=>'This administrator account is disabled. Contact the System Administrator.'],403);
    }
    $role = strtolower(trim((string)($admin['role'] ?? '')));
    $branch = strtolower(trim((string)($admin['branch'] ?? '')));
    $admin['is_system_admin'] = in_array($role, ['system administrator','super administrator','super admin'], true)
        || in_array($branch, ['all branches','all rhu branches','all branch','all rhu'], true);
    $admin['branch'] = $admin['is_system_admin'] ? 'All Branches' : (string)($admin['branch'] ?? '');
    if ($systemOnly && !$admin['is_system_admin']) {
        json_out(['ok'=>false,'message'=>'This feature is available to System Administrators only.'],403);
    }
    return $admin;
}

function require_staff_branch($admin, $requestedBranch) {
    if (!$admin['is_system_admin'] && $requestedBranch !== $admin['branch']) {
        json_out(['ok'=>false,'message'=>'RHU staff can access their assigned branch only.'],403);
    }
}

function patient_record_branch($pdo,$patientId) {
    ensure_patient_management_columns($pdo);
    $allowed=allowed_rhu_branches();
    $stmt=$pdo->prepare('SELECT preferred_rhu FROM patients WHERE id=? LIMIT 1');
    $stmt->execute([(int)$patientId]);
    $branch=trim((string)$stmt->fetchColumn());
    if (in_array($branch,$allowed,true)) return $branch;
    $stmt=$pdo->prepare('SELECT center FROM appointments WHERE patient_id=? ORDER BY appointment_date DESC,id DESC LIMIT 1');
    $stmt->execute([(int)$patientId]);
    $branch=trim((string)$stmt->fetchColumn());
    return in_array($branch,$allowed,true)?$branch:'';
}

function require_patient_record_access($pdo,$patientId) {
    $admin=require_admin_context($pdo);
    $stmt=$pdo->prepare('SELECT id FROM patients WHERE id=? LIMIT 1');
    $stmt->execute([(int)$patientId]);
    if(!$stmt->fetchColumn()) json_out(['ok'=>false,'message'=>'Patient record not found.'],404);
    if(!$admin['is_system_admin'] && patient_record_branch($pdo,$patientId)!==$admin['branch']) json_out(['ok'=>false,'message'=>'This patient record is outside your assigned RHU.'],403);
    return $admin;
}

function chat_thread_branch($pdo, $patientId) {
    ensure_chat_thread_status_table($pdo);
    $allowed = allowed_rhu_branches();

    $stmt=$pdo->prepare('SELECT rhu_branch FROM chat_thread_status WHERE patient_id=? LIMIT 1');
    $stmt->execute([(int)$patientId]);
    $branch=trim((string)$stmt->fetchColumn());
    if (in_array($branch,$allowed,true)) return $branch;

    $stmt=$pdo->prepare("SELECT center FROM appointments WHERE patient_id=? AND center IN (?,?,?,?) ORDER BY appointment_date DESC,id DESC LIMIT 1");
    $stmt->execute(array_merge([(int)$patientId],$allowed));
    $branch=trim((string)$stmt->fetchColumn());
    if (in_array($branch,$allowed,true)) return $branch;

    $stmt=$pdo->prepare('SELECT profile_json FROM patients WHERE id=? LIMIT 1');
    $stmt->execute([(int)$patientId]);
    $profile=json_decode((string)$stmt->fetchColumn(),true);
    if (is_array($profile)) {
        foreach (['preferredRhu','rhuPreference','selectedRhu','preferred_rhu'] as $key) {
            $branch=trim((string)($profile[$key]??''));
            if (in_array($branch,$allowed,true)) return $branch;
        }
    }

    return $allowed[0];
}

function require_admin_patient_access($pdo, $patientId) {
    $admin = require_admin_context($pdo);
    if ($admin['is_system_admin']) return $admin;
    if (chat_thread_branch($pdo,$patientId) !== $admin['branch']) {
        json_out(['ok'=>false,'message'=>'This conversation is outside your assigned RHU branch.'],403);
    }
    return $admin;
}

function send_admin_otp_email($pdo, $admin, $otp) {
    $safeName = htmlspecialchars((string)$admin['name']);
    $subject = 'Pulilan Health Center administrator verification code';
    $html = '<div style="font-family:Arial,sans-serif;background:#f3f6fb;padding:28px">'
        . '<div style="max-width:560px;margin:auto;background:#fff;border:1px solid #dbe4ef;border-radius:12px;overflow:hidden">'
        . '<div style="background:#0b3d91;color:#fff;padding:20px 24px"><h2 style="margin:0;font-size:20px">Pulilan Health Center</h2>'
        . '<p style="margin:5px 0 0;color:#dbeafe;font-size:12px">Secure administrator sign-in</p></div>'
        . '<div style="padding:24px"><p>Hello <strong>' . $safeName . '</strong>,</p>'
        . '<p>Use this one-time verification code to complete your sign-in:</p>'
        . '<div style="font-size:32px;font-weight:800;letter-spacing:8px;color:#0b3d91;padding:18px;background:#eff6ff;text-align:center;border-radius:10px">' . $otp . '</div>'
        . '<p style="color:#64748b;font-size:12px;line-height:1.6">This code expires in 10 minutes. If you did not request this sign-in, do not share the code.</p></div>'
        . '<div style="padding:12px 24px;background:#f8fafc;color:#94a3b8;text-align:center;font-size:10px">© 2026 Pulilan Health Center</div>'
        . '</div></div>';

    if (function_exists('brevo_email_enabled') && brevo_email_enabled()) {
        $result = send_brevo_email(
            $pdo,
            $admin['email'],
            $admin['name'],
            $subject,
            $html,
            'admin_otp',
            null,
            null
        );
        if (!empty($result['ok'])) return;
        throw new Exception($result['message'] ?? 'Unable to send OTP through Brevo.');
    }

    if (SMTP_PASSWORD === '' || SMTP_EMAIL === '' || SMTP_EMAIL === 'you@example.com') {
        throw new Exception('Email OTP is not configured. Configure Brevo or SMTP before administrator login.');
    }

    $mail = new PHPMailer(true);
    $mail->isSMTP();
    $mail->Host = SMTP_HOST;
    $mail->SMTPAuth = true;
    $mail->Username = SMTP_EMAIL;
    $mail->Password = SMTP_PASSWORD;
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = SMTP_PORT;
    $mail->setFrom(SMTP_EMAIL, 'Pulilan Health Center Security');
    $mail->addAddress($admin['email'], $admin['name']);
    $mail->isHTML(true);
    $mail->Subject = $subject;
    $mail->Body = $html;
    $mail->AltBody = 'Your Pulilan Health Center verification code is ' . $otp . '. It expires in 10 minutes.';
    $mail->send();
}

function send_patient_reset_otp_email($pdo, $patient, $otp) {
    $safeName = htmlspecialchars((string)($patient['first_name'] ?? 'Patient'));
    $subject = 'Pulilan Health Center password reset code';
    $html = '<div style="font-family:Arial,sans-serif;background:#f3f6fb;padding:28px">'
        . '<div style="max-width:560px;margin:auto;background:#fff;border:1px solid #dbe4ef;border-radius:12px;overflow:hidden">'
        . '<div style="background:#0b3d91;color:#fff;padding:20px 24px"><h2 style="margin:0;font-size:20px">Pulilan Health Center</h2>'
        . '<p style="margin:5px 0 0;color:#dbeafe;font-size:12px">Patient account password reset</p></div>'
        . '<div style="padding:24px"><p>Hello <strong>' . $safeName . '</strong>,</p>'
        . '<p>Use this one-time code to reset your patient account password:</p>'
        . '<div style="font-size:32px;font-weight:800;letter-spacing:8px;color:#0b3d91;padding:18px;background:#eff6ff;text-align:center;border-radius:10px">' . $otp . '</div>'
        . '<p style="color:#64748b;font-size:12px;line-height:1.6">This code expires in 10 minutes. If you did not request this, you can safely ignore this email — your password will not change.</p></div>'
        . '<div style="padding:12px 24px;background:#f8fafc;color:#94a3b8;text-align:center;font-size:10px">© 2026 Pulilan Health Center</div>'
        . '</div></div>';

    if (function_exists('brevo_email_enabled') && brevo_email_enabled()) {
        $result = send_brevo_email(
            $pdo,
            $patient['email'],
            $safeName,
            $subject,
            $html,
            'patient_reset_otp',
            null,
            null
        );
        if (!empty($result['ok'])) return;
        throw new Exception($result['message'] ?? 'Unable to send the code through Brevo.');
    }

    if (SMTP_PASSWORD === '' || SMTP_EMAIL === '' || SMTP_EMAIL === 'you@example.com') {
        throw new Exception('Email delivery is not configured for this deployment.');
    }

    $mail = new PHPMailer(true);
    $mail->isSMTP();
    $mail->Host = SMTP_HOST;
    $mail->SMTPAuth = true;
    $mail->Username = SMTP_EMAIL;
    $mail->Password = SMTP_PASSWORD;
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = SMTP_PORT;
    $mail->setFrom(SMTP_EMAIL, 'Pulilan Health Center');
    $mail->addAddress($patient['email'], $safeName);
    $mail->isHTML(true);
    $mail->Subject = $subject;
    $mail->Body = $html;
    $mail->AltBody = 'Your Pulilan Health Center password reset code is ' . $otp . '. It expires in 10 minutes.';
    $mail->send();
}

function masked_email($email) {
    [$name, $domain] = array_pad(explode('@', $email, 2), 2, '');
    $visible = substr($name, 0, min(2, strlen($name)));
    return $visible . str_repeat('*', max(3, strlen($name) - strlen($visible))) . '@' . $domain;
}

function fetch_remote_url($url) {
    if (function_exists('curl_version')) {
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
        $response = curl_exec($ch);
        curl_close($ch);
        return $response;
    }
    return @file_get_contents($url);
}

function verify_google_id_token($idToken) {
    if (!$idToken || GOOGLE_CLIENT_ID === 'YOUR_GOOGLE_CLIENT_ID_HERE' || GOOGLE_CLIENT_ID === '') {
        return null;
    }
    $url = 'https://oauth2.googleapis.com/tokeninfo?id_token=' . urlencode($idToken);
    $response = fetch_remote_url($url);
    if (!$response) {
        return null;
    }
    $payload = json_decode($response, true);
    if (!is_array($payload) || empty($payload['aud']) || $payload['aud'] !== GOOGLE_CLIENT_ID) {
        return null;
    }
    return $payload;
}

function verify_google_access_token($accessToken) {
    if (!$accessToken || GOOGLE_CLIENT_ID === 'YOUR_GOOGLE_CLIENT_ID_HERE' || GOOGLE_CLIENT_ID === '') {
        return null;
    }
    $tokenInfoUrl = 'https://oauth2.googleapis.com/tokeninfo?access_token=' . urlencode($accessToken);
    $tokenInfoResponse = fetch_remote_url($tokenInfoUrl);
    if (!$tokenInfoResponse) {
        return null;
    }
    $tokenInfo = json_decode($tokenInfoResponse, true);
    if (!is_array($tokenInfo) || empty($tokenInfo['aud']) || $tokenInfo['aud'] !== GOOGLE_CLIENT_ID) {
        return null;
    }

    $userinfoUrl = 'https://www.googleapis.com/oauth2/v3/userinfo?access_token=' . urlencode($accessToken);
    $userinfoResponse = fetch_remote_url($userinfoUrl);
    if (!$userinfoResponse) {
        return null;
    }
    $userinfo = json_decode($userinfoResponse, true);
    if (!is_array($userinfo) || empty($userinfo['email'])) {
        return null;
    }
    return array_merge($userinfo, ['aud' => $tokenInfo['aud'] ?? GOOGLE_CLIENT_ID]);
}

function login_or_create_google_patient($email, $name = '', $googleId = null, $payload = []) {
    global $pdo;
    ensure_patient_management_columns($pdo);
    $email = strtolower(trim($email));
    $name = trim($name);
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        json_out(['ok'=>false,'message'=>'Please enter a valid Google email.'], 422);
    }
    $parts = preg_split('/\s+/', $name, 2);
    $first = trim($parts[0] ?? 'Patient') ?: 'Patient';
    $last = trim($parts[1] ?? 'User') ?: 'User';

    $stmt = $pdo->prepare('SELECT * FROM patients WHERE email=?');
    $stmt->execute([$email]);
    $p = $stmt->fetch();
    if ($p && (($p['account_status']??'Active')==='Archived')) json_out(['ok'=>false,'message'=>'This patient account is archived. Contact Pulilan Health Center for assistance.'],403);
    if (!$p) {
        $hash = password_hash(bin2hex(random_bytes(16)), PASSWORD_DEFAULT);
        $profileData = json_encode([
            'auth_provider' => 'google',
            'google_id' => $googleId,
            'google_payload' => $payload,
        ], JSON_UNESCAPED_UNICODE);
        $stmt = $pdo->prepare('INSERT INTO patients(first_name,last_name,email,password_hash,profile_json) VALUES(?,?,?,?,?)');
        $stmt->execute([$first, $last, $email, $hash, $profileData]);
        $id = $pdo->lastInsertId();
        $code = 'USR-' . str_pad($id, 3, '0', STR_PAD_LEFT);
        $pdo->prepare('UPDATE patients SET patient_code=? WHERE id=?')->execute([$code, $id]);
        $stmt = $pdo->prepare('SELECT * FROM patients WHERE id=?');
        $stmt->execute([$id]);
        $p = $stmt->fetch();
    }
    // password handling
    // session check
    session_regenerate_id(true);
    unset(
        $_SESSION['admin_id'],
        $_SESSION['pending_admin_id'],
        $_SESSION['admin_otp_hash'],
        $_SESSION['admin_otp_expires'],
        $_SESSION['admin_otp_attempts'],
        $_SESSION['admin_otp_sent_at']
    );
    $_SESSION['patient_id'] = (int)$p['id'];
    return patient_payload($p);
}

function patient_payload($p) {
    $extra = [];
    if (!empty($p['profile_json'])) {
        $decoded = json_decode($p['profile_json'], true);
        if (is_array($decoded)) $extra = $decoded;
    }

    $mapped = [
        'id' => $p['patient_code'] ?: ('USR-' . str_pad($p['id'], 3, '0', STR_PAD_LEFT)),
        'dbId' => (int)$p['id'],
        'email' => $p['email'],
        'firstName' => $p['first_name'],
        'lastName' => $p['last_name'],
        'name' => trim($p['first_name'] . ' ' . $p['last_name']),
        'phone' => $p['phone'] ?? '',
        'mobile' => $p['phone'] ?? '',
        'birthdate' => $p['birthdate'] ?? '',
        'dob' => $p['birthdate'] ?? '',
        'gender' => $p['gender'] ?? '',
        'sex' => $p['gender'] ?? '',
        'address' => $p['address'] ?? '',
        'street' => $p['address'] ?? '',
        'barangay' => $p['barangay'] ?? '',
        'philhealthNo' => $p['philhealth_no'] ?? '',
        'philhealthNum' => $p['philhealth_no'] ?? '',
        'isSenior' => (bool)($p['is_senior'] ?? false),
        'isPwd' => (bool)($p['is_pwd'] ?? false),
        'is4ps' => (bool)($p['is_4ps'] ?? false),
        'preferredRhu' => $p['preferred_rhu'] ?? ($extra['preferredRhu'] ?? ''),
        'accountStatus' => $p['account_status'] ?? 'Active',
        'archivedAt' => $p['archived_at'] ?? null,
        'createdAt' => $p['created_at'] ?? null,
    ];

    return array_merge($extra, $mapped);
}

function appt_payload($a, $patientName = null) {
    return [
        'id' => (int)$a['id'],
        'queue' => $a['queue_number'],
        'center' => $a['center'],
        'rhu' => $a['center'],
        'service' => $a['service'],
        'date' => $a['appointment_date'],
        'time' => $a['appointment_time'],
        'status' => $a['status'],
        'arrivalStatus' => $a['arrival_status'] ?? 'not_arrived',
        'arrivedAt' => $a['arrived_at'] ?? null,
        'serviceStartedAt' => $a['service_started_at'] ?? null,
        'completedAt' => $a['completed_at'] ?? null,
        'isPriority' => in_array(($a['queue_type'] ?? 'regular'), ['priority','emergency'], true),
        'isEmergency' => (($a['queue_type'] ?? '') === 'emergency' || strpos((string)($a['queue_number'] ?? ''), 'E-') === 0),
        'queueType' => $a['queue_type'] ?? 'regular',
        'priorityReason' => $a['priority_reason'] ?? '',
        'concern' => $a['concern'] ?? '',
        'notes' => $a['concern'] ?? '',
        'patient' => $patientName ?: ($a['patient_name'] ?? ''),
        'barangay' => $a['patient_barangay'] ?? '',
        'createdAt' => $a['created_at'] ?? null,
        'updatedAt' => $a['updated_at'] ?? null,
        'patientDbId' => isset($a['patient_id']) ? (int)$a['patient_id'] : null,
    ];
}

require __DIR__ . '/operations_features.php';
require __DIR__ . '/innovation_features.php';
ensure_appointment_arrival_columns($pdo);
apply_appointment_auto_confirmation_policy($pdo);
operations_route($action,$pdo,$data);

if ($action === 'public_landing_status') {
    operations_ensure_tables($pdo);
    ensure_innovation_tables($pdo);
    $today=date('Y-m-d');
    $day=(int)date('w');
    $now=date('H:i:s');
    $branches=[];
    $openNow=0;
    $scheduledToday=0;
    $closureStmt=$pdo->prepare("SELECT title,closed_all_day,start_time,end_time FROM clinic_closures WHERE closure_date=? AND status='Active' AND branch IN ('All Branches',?) AND service='All Services' ORDER BY FIELD(closure_type,'Emergency','Holiday','Maintenance','Special Event'),id DESC LIMIT 1");
    foreach(allowed_rhu_branches() as $branch){
        $schedule=operations_schedule_for($pdo,$branch,$day);
        $isScheduled=$schedule&&(int)($schedule['is_open']??0)===1&&!empty($schedule['open_time'])&&!empty($schedule['close_time']);
        if($isScheduled)$scheduledToday++;
        $closureStmt->execute([$today,$branch]);
        $closure=$closureStmt->fetch();
        $isAllDayClosed=$closure&&(int)($closure['closed_all_day']??0)===1;
        $isPartialClosed=$closure&&!$isAllDayClosed&&!empty($closure['start_time'])&&!empty($closure['end_time'])&&$now>=$closure['start_time']&&$now<$closure['end_time'];
        $onBreak=$isScheduled&&!empty($schedule['break_start'])&&!empty($schedule['break_end'])&&$now>=$schedule['break_start']&&$now<$schedule['break_end'];
        $isOpen=$isScheduled&&!$isAllDayClosed&&!$isPartialClosed&&!$onBreak&&$now>=$schedule['open_time']&&$now<$schedule['close_time'];
        if($isOpen)$openNow++;
        if($isAllDayClosed)$label='Closed — '.($closure['title']??'Special closure');
        elseif(!$isScheduled)$label='Closed today';
        elseif($isPartialClosed)$label='Temporarily closed';
        elseif($onBreak)$label='On break';
        elseif($isOpen)$label='Open now';
        elseif($now<$schedule['open_time'])$label='Opens '.date('g:i A',strtotime($schedule['open_time']));
        else $label='Closed for today';
        $branches[]=['branch'=>$branch,'status'=>$label,'open_now'=>$isOpen,'hours'=>$isScheduled?date('g:i A',strtotime($schedule['open_time'])).'–'.date('g:i A',strtotime($schedule['close_time'])):'Closed'];
    }
    $facility=[];
    $settingStmt=$pdo->query("SELECT setting_key,setting_value FROM system_settings WHERE setting_key IN ('facilityName','municipality','supportEmail','supportContact')");
    foreach($settingStmt->fetchAll() as $setting){
        $value=trim((string)($setting['setting_value']??''));
        if($value!=='')$facility[$setting['setting_key']]=$value;
    }

    $advisoryStmt=$pdo->query("SELECT id,title,message,priority,publish_at,created_at,
                                     attachment_path,attachment_name,attachment_mime
      FROM announcements
      WHERE status='Published'
        AND branch='All Branches'
        AND target_barangay='All Barangays'
        AND (publish_at IS NULL OR publish_at<=NOW())
        AND (expires_at IS NULL OR expires_at>NOW())
      ORDER BY FIELD(priority,'urgent','important','normal'),COALESCE(publish_at,created_at) DESC
      LIMIT 6");
    $advisories=array_map(static function(array $row): array {
        $payload=announcement_payload($row);
        return [
          'id'=>(int)($row['id']??0),
          'title'=>(string)($row['title']??''),
          'message'=>(string)($row['message']??''),
          'priority'=>(string)($row['priority']??'normal'),
          'published_at'=>$row['publish_at']??$row['created_at']??null,
          'attachment_url'=>(string)($payload['attachment_url']??''),
          'attachment_name'=>(string)($row['attachment_name']??''),
          'attachment_mime'=>(string)($row['attachment_mime']??''),
          'is_image'=>!empty($payload['is_image']),
        ];
    },$advisoryStmt->fetchAll());
    json_out(['ok'=>true,'server_date'=>$today,'server_time'=>date('c'),'open_now'=>$openNow,'scheduled_today'=>$scheduledToday,'total_branches'=>count($branches),'branches'=>$branches,'facility'=>$facility,'advisories'=>$advisories]);
}

if ($action === 'csrf_token') {
    if (empty($_SESSION['csrf_token'])) $_SESSION['csrf_token']=bin2hex(random_bytes(32));
    json_out(['ok'=>true,'csrfToken'=>$_SESSION['csrf_token']]);
}

if ($action === 'public_auth_config') {
    $googleClientId = defined('GOOGLE_CLIENT_ID') ? trim((string)GOOGLE_CLIENT_ID) : '';
    $googleEnabled = $googleClientId !== '' && $googleClientId !== 'YOUR_GOOGLE_CLIENT_ID_HERE';
    json_out(['ok'=>true,'googleEnabled'=>$googleEnabled,'googleClientId'=>$googleEnabled?$googleClientId:'']);
}

if ($action === 'patient_register') {
    ensure_patient_management_columns($pdo);
    $first = trim($data['firstName'] ?? '');
    $last = trim($data['lastName'] ?? '');
    $email = strtolower(trim($data['email'] ?? ''));
    $mobile = trim($data['mobile'] ?? $data['phone'] ?? '');
    $address = trim($data['address'] ?? '');
    $pass = (string)($data['password'] ?? '');
    if (!$first || !$last || !filter_var($email, FILTER_VALIDATE_EMAIL) || !$mobile || !$address || strlen($pass) < 8) json_out(['ok'=>false,'message'=>'Please complete all registration fields.'],422);
    if (empty($data['privacyConsent'])) json_out(['ok'=>false,'message'=>'Please review and accept the Privacy and Data Retention Policy.'],422);
    $check = $pdo->prepare('SELECT id FROM patients WHERE email=?');
    $check->execute([$email]);
    if ($check->fetch()) json_out(['ok'=>false,'message'=>'An account with this email already exists.'],409);
    $hash = password_hash($pass, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare('INSERT INTO patients(first_name,last_name,email,password_hash,phone,address) VALUES(?,?,?,?,?,?)');
    $stmt->execute([$first,$last,$email,$hash,$mobile,$address]);
    $id = $pdo->lastInsertId();
    $code = 'USR-' . str_pad($id,3,'0',STR_PAD_LEFT);
    $pdo->prepare('UPDATE patients SET patient_code=? WHERE id=?')->execute([$code,$id]);
    operations_record_consent($pdo,(int)$id,'registration');
    json_out(['ok'=>true,'message'=>'Registration successful.']);
}

if ($action === 'patient_google_login') {
    $idToken = trim($data['idToken'] ?? $data['credential'] ?? '');
    if (!$idToken) {
        json_out(['ok'=>false,'message'=>'Google token is required.'], 400);
    }
    $payload = verify_google_id_token($idToken);
    if (!$payload || empty($payload['email'])) {
        json_out(['ok'=>false,'message'=>'Invalid Google login token. Make sure your Google Client ID and localhost origin are authorized.'], 401);
    }
    $patient = login_or_create_google_patient(
        $payload['email'],
        $payload['name'] ?? (($payload['given_name'] ?? 'Patient') . ' ' . ($payload['family_name'] ?? 'User')),
        $payload['sub'] ?? null,
        $payload
    );
    json_out(['ok' => true, 'patient' => $patient]);
}

if ($action === 'patient_google_access_login') {
    $accessToken = trim($data['accessToken'] ?? $data['access_token'] ?? '');
    if (!$accessToken) {
        json_out(['ok'=>false,'message'=>'Google access token is required.'], 400);
    }
    $payload = verify_google_access_token($accessToken);
    if (!$payload || empty($payload['email'])) {
        json_out(['ok'=>false,'message'=>'Invalid Google account. Check Google Client ID, Authorized JavaScript origin, and internet connection.'], 401);
    }
    $patient = login_or_create_google_patient(
        $payload['email'],
        $payload['name'] ?? (($payload['given_name'] ?? 'Patient') . ' ' . ($payload['family_name'] ?? 'User')),
        $payload['sub'] ?? null,
        $payload
    );
    json_out(['ok' => true, 'patient' => $patient]);
}

if ($action === 'patient_request_password_reset') {
    try {
        $pdo->exec("CREATE TABLE IF NOT EXISTS password_resets (
          id INT AUTO_INCREMENT PRIMARY KEY,
          patient_id INT NOT NULL,
          email VARCHAR(150) NOT NULL,
          otp_hash VARCHAR(255) NOT NULL,
          attempts INT NOT NULL DEFAULT 0,
          expires_at DATETIME NOT NULL,
          used_at DATETIME NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_email (email)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        if (function_exists('hc_add_column')) {
            hc_add_column($pdo, 'password_resets', 'patient_id', 'INT NOT NULL AFTER id');
            hc_add_column($pdo, 'password_resets', 'email', 'VARCHAR(150) NOT NULL AFTER patient_id');
            hc_add_column($pdo, 'password_resets', 'otp_hash', 'VARCHAR(255) NOT NULL AFTER email');
            hc_add_column($pdo, 'password_resets', 'attempts', 'INT NOT NULL DEFAULT 0 AFTER otp_hash');
            hc_add_column($pdo, 'password_resets', 'expires_at', 'DATETIME NOT NULL AFTER attempts');
            hc_add_column($pdo, 'password_resets', 'used_at', 'DATETIME NULL AFTER expires_at');
        }
    } catch (Exception $e) {
        json_out(['ok'=>false,'message'=>'Password reset table error: '.$e->getMessage()], 500);
    }
    $email = strtolower(trim($data['email'] ?? ''));
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        json_out(['ok'=>false,'message'=>'Please enter a valid registered email address.'], 422);
    }

    $stmt = $pdo->prepare('SELECT id, first_name, last_name, email FROM patients WHERE email=? LIMIT 1');
    $stmt->execute([$email]);
    $patient = $stmt->fetch();

    // email setup
    // email setup
    $genericOk = ['ok' => true, 'message' => 'If this email is registered, a verification code has been sent.'];
    if (!$patient) {
        json_out($genericOk);
    }

    $patientId = (int)$patient['id'];

    // otp handling
    $recent = $pdo->prepare('SELECT created_at FROM password_resets WHERE patient_id=? ORDER BY id DESC LIMIT 1');
    $recent->execute([$patientId]);
    $lastCreated = $recent->fetchColumn();
    if ($lastCreated && (time() - strtotime($lastCreated)) < 30) {
        json_out(['ok'=>false,'message'=>'Please wait a bit before requesting another code.'], 429);
    }

    $otp = (string)random_int(100000, 999999);
    $otpHash = password_hash($otp, PASSWORD_DEFAULT);
    $expires = date('Y-m-d H:i:s', time() + 600);

    $pdo->prepare('UPDATE password_resets SET used_at=NOW() WHERE patient_id=? AND used_at IS NULL')
        ->execute([$patientId]);

    $pdo->prepare('INSERT INTO password_resets (patient_id, email, otp_hash, expires_at) VALUES (?, ?, ?, ?)')
        ->execute([$patientId, $email, $otpHash, $expires]);

    $mailSent = false;
    try {
        send_patient_reset_otp_email($pdo, $patient, $otp);
        $mailSent = true;
    } catch (Exception $e) {
        error_log('[patient_password_reset] Mail send failed: ' . $e->getMessage());
    }

    if (!$mailSent) {
        json_out(['ok'=>false,'message'=>'Unable to send the verification code right now. Please try again shortly.'], 503);
    }

    json_out([
        'ok' => true,
        'message' => 'A 6-digit verification code was sent to your email.',
        'mailSent' => true,
        'maskedEmail' => masked_email($email)
    ]);
}

if ($action === 'patient_verify_reset_otp') {
    $email = strtolower(trim($data['email'] ?? ''));
    $otp = preg_replace('/\D/', '', (string)($data['otp'] ?? ''));

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) json_out(['ok'=>false,'message'=>'Please enter a valid email address.'], 422);
    if (strlen($otp) !== 6) json_out(['ok'=>false,'message'=>'Enter the 6-digit code sent to your email.'], 422);

    $stmt = $pdo->prepare('SELECT * FROM password_resets WHERE email=? AND used_at IS NULL ORDER BY id DESC LIMIT 1');
    $stmt->execute([$email]);
    $row = $stmt->fetch();

    if (!$row || strtotime($row['expires_at']) < time()) {
        json_out(['ok'=>false,'message'=>'This code is invalid or expired. Please request a new one.'], 401);
    }
    if ((int)$row['attempts'] >= 5) {
        $pdo->prepare('UPDATE password_resets SET used_at=NOW() WHERE id=?')->execute([$row['id']]);
        json_out(['ok'=>false,'message'=>'Too many incorrect attempts. Please request a new code.'], 429);
    }
    if (!password_verify($otp, $row['otp_hash'])) {
        $pdo->prepare('UPDATE password_resets SET attempts=attempts+1 WHERE id=?')->execute([$row['id']]);
        json_out(['ok'=>false,'message'=>'Incorrect verification code.'], 401);
    }

    // password handling
    // password handling
    // password handling
    json_out(['ok'=>true,'message'=>'Code verified. You can now set a new password.']);
}

if ($action === 'patient_reset_password_otp') {
    $email = strtolower(trim($data['email'] ?? ''));
    $otp = preg_replace('/\D/', '', (string)($data['otp'] ?? ''));
    $newPassword = (string)($data['password'] ?? '');

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) json_out(['ok'=>false,'message'=>'Please enter a valid email address.'], 422);
    if (strlen($otp) !== 6) json_out(['ok'=>false,'message'=>'Enter the 6-digit code sent to your email.'], 422);
    if (strlen($newPassword) < 8) json_out(['ok'=>false,'message'=>'Password must be at least 8 characters.'], 422);

    $stmt = $pdo->prepare('SELECT * FROM password_resets WHERE email=? AND used_at IS NULL ORDER BY id DESC LIMIT 1');
    $stmt->execute([$email]);
    $row = $stmt->fetch();

    if (!$row || strtotime($row['expires_at']) < time()) {
        json_out(['ok'=>false,'message'=>'This code is invalid or expired. Please request a new one.'], 401);
    }
    if ((int)$row['attempts'] >= 5) {
        $pdo->prepare('UPDATE password_resets SET used_at=NOW() WHERE id=?')->execute([$row['id']]);
        json_out(['ok'=>false,'message'=>'Too many incorrect attempts. Please request a new code.'], 429);
    }
    if (!password_verify($otp, $row['otp_hash'])) {
        $pdo->prepare('UPDATE password_resets SET attempts=attempts+1 WHERE id=?')->execute([$row['id']]);
        json_out(['ok'=>false,'message'=>'Incorrect verification code.'], 401);
    }

    $hash = password_hash($newPassword, PASSWORD_DEFAULT);
    $pdo->prepare('UPDATE patients SET password_hash=? WHERE id=?')->execute([$hash, $row['patient_id']]);
    $pdo->prepare('UPDATE password_resets SET used_at=NOW() WHERE id=?')->execute([$row['id']]);
    json_out(['ok'=>true,'message'=>'Password changed successfully. You can now log in.']);
}

if ($action === 'patient_login') {
    ensure_patient_management_columns($pdo);
    $email = strtolower(trim($data['email'] ?? ''));
    $pass = (string)($data['password'] ?? '');
    $stmt = $pdo->prepare('SELECT * FROM patients WHERE email=?');
    $stmt->execute([$email]);
    $p = $stmt->fetch();
    if ($p) {
        $remaining = login_lock_remaining_seconds($p['locked_until'] ?? null);
        if ($remaining > 0) json_out(['ok'=>false,'message'=>login_lock_message($remaining),'retry_after'=>$remaining],429);
        if (!empty($p['locked_until'])) clear_login_lock($pdo, 'patients', (int)$p['id']);
    }
    if (!$p || !password_verify($pass, $p['password_hash'])) {
        if ($p) {
            $locked = record_failed_login($pdo, 'patients', (int)$p['id'], (int)($p['failed_login_attempts'] ?? 0), 15);
            if ($locked > 0) json_out(['ok'=>false,'message'=>login_lock_message($locked),'retry_after'=>$locked],429);
        }
        json_out(['ok'=>false,'message'=>'Invalid email or password.'],401);
    }
    clear_login_lock($pdo, 'patients', (int)$p['id']);
    if (($p['account_status']??'Active')==='Archived') json_out(['ok'=>false,'message'=>'This patient account is archived. Contact Pulilan Health Center for assistance.'],403);
    session_regenerate_id(true);
    unset(
        $_SESSION['admin_id'],
        $_SESSION['pending_admin_id'],
        $_SESSION['admin_otp_hash'],
        $_SESSION['admin_otp_expires'],
        $_SESSION['admin_otp_attempts'],
        $_SESSION['admin_otp_sent_at']
    );
    $_SESSION['patient_id'] = $p['id'];
    json_out(['ok'=>true,'patient'=>patient_payload($p)]);
}

if ($action === 'patient_me') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false],401);
    ensure_patient_management_columns($pdo);
    $stmt=$pdo->prepare('SELECT * FROM patients WHERE id=?'); $stmt->execute([$_SESSION['patient_id']]);
    $patient=$stmt->fetch();
    if(!$patient||($patient['account_status']??'Active')==='Archived'){unset($_SESSION['patient_id']);json_out(['ok'=>false,'message'=>'This patient account is archived.'],403);}
    json_out(['ok'=>true,'patient'=>patient_payload($patient)]);
}

if ($action === 'patient_logout') {
    unset($_SESSION['patient_id']);
    if (session_status() === PHP_SESSION_ACTIVE) {
        $_SESSION = [];
        if (ini_get('session.use_cookies')) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], $params['secure'], $params['httponly']);
        }
        session_destroy();
    }
    json_out(['ok'=>true]);
}


if ($action === 'patient_change_password') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    $currentPassword = (string)($data['currentPassword'] ?? '');
    $newPassword = (string)($data['newPassword'] ?? '');
    if ($currentPassword === '' || $newPassword === '') json_out(['ok'=>false,'message'=>'Complete the current and new password fields.'],422);
    if (strlen($newPassword) < 8) json_out(['ok'=>false,'message'=>'Password must be at least 8 characters.'],422);
    $stmt=$pdo->prepare('SELECT password_hash FROM patients WHERE id=? LIMIT 1');
    $stmt->execute([$_SESSION['patient_id']]);
    $hash=(string)$stmt->fetchColumn();
    if ($hash==='' || !password_verify($currentPassword,$hash)) json_out(['ok'=>false,'message'=>'Current password is incorrect.'],401);
    if (password_verify($newPassword,$hash)) json_out(['ok'=>false,'message'=>'Choose a new password different from your current password.'],422);
    $pdo->prepare('UPDATE patients SET password_hash=? WHERE id=?')->execute([password_hash($newPassword,PASSWORD_DEFAULT),$_SESSION['patient_id']]);
    json_out(['ok'=>true,'message'=>'Password changed successfully.']);
}

if ($action === 'profile_save') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_patient_management_columns($pdo);

    $first = trim($data['firstName'] ?? $data['first_name'] ?? '');
    $last  = trim($data['lastName'] ?? $data['last_name'] ?? '');
    $phone = trim($data['mobile'] ?? $data['phone'] ?? '');
    $birth = trim($data['dob'] ?? $data['birthdate'] ?? '');
    $gender = trim($data['sex'] ?? $data['gender'] ?? '');
    $barangay = trim($data['barangay'] ?? '');
    $address = trim($data['street'] ?? $data['address'] ?? '');
    $philhealth = trim($data['philhealthNum'] ?? $data['philhealthNo'] ?? '');
    $preferredRhu=trim((string)($data['preferredRhu']??$data['rhuPreference']??$data['selectedRhu']??''));
    if($preferredRhu!==''&&!in_array($preferredRhu,allowed_rhu_branches(),true)) json_out(['ok'=>false,'message'=>'Please select a valid preferred RHU.'],422);

    if ($birth !== '') {
        $ts = strtotime($birth);
        $birth = $ts ? date('Y-m-d', $ts) : null;
    } else {
        $birth = null;
    }

    // Preserve values owned by other profile sections (especially profilePhoto and card images).
    // Saving one section must never erase data that was not present in that section's form payload.
    $existingProfile = [];
    $existingStmt = $pdo->prepare('SELECT profile_json FROM patients WHERE id=? LIMIT 1');
    $existingStmt->execute([$_SESSION['patient_id']]);
    $existingJson = (string)$existingStmt->fetchColumn();
    if ($existingJson !== '') {
        $decodedExisting = json_decode($existingJson, true);
        if (is_array($decodedExisting)) $existingProfile = $decodedExisting;
    }
    $mergedProfile = array_merge($existingProfile, $data);
    $profileJson = json_encode($mergedProfile, JSON_UNESCAPED_UNICODE);

    $stmt=$pdo->prepare('UPDATE patients SET first_name=COALESCE(NULLIF(?,""), first_name), last_name=COALESCE(NULLIF(?,""), last_name), phone=?, birthdate=?, gender=?, address=?, barangay=?, philhealth_no=?, is_senior=?, is_pwd=?, is_4ps=?, preferred_rhu=COALESCE(NULLIF(?,""),preferred_rhu), profile_json=? WHERE id=?');
    $stmt->execute([
        $first, $last, $phone, $birth, $gender, $address, $barangay, $philhealth,
        (!empty($data['isSenior']) || !empty($data['seniorCitizen']))?1:0,
        !empty($data['isPwd'])?1:0,
        (!empty($data['toggle4ps']) || !empty($data['is4ps']))?1:0,
        $preferredRhu,
        $profileJson,
        $_SESSION['patient_id']
    ]);

    $stmt=$pdo->prepare('SELECT * FROM patients WHERE id=?');
    $stmt->execute([$_SESSION['patient_id']]);
    json_out(['ok'=>true,'patient'=>patient_payload($stmt->fetch()),'message'=>'Profile saved successfully.']);
}


if ($action === 'patient_branch_recommendations') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);

    $service = trim((string)($_GET['service'] ?? $data['service'] ?? ''));
    $date = trim((string)($_GET['date'] ?? $data['date'] ?? ''));
    $ts = strtotime($date);
    if ($ts) $date = date('Y-m-d', $ts);
    if (!$service || !$date) json_out(['ok'=>false,'message'=>'Select a service and appointment date.'],422);

    $branches = allowed_rhu_branches();
    $items = [];
    foreach ($branches as $branch) {
        $plan = operations_booking_plan($pdo,$branch,$service,$date);
        $totalRemaining = 0;
        foreach (($plan['slots'] ?? []) as $time => $remaining) {
            if (($plan['slotStatus'][$time] ?? '') === 'available') $totalRemaining += max(0,(int)$remaining);
        }

        $queueStmt=$pdo->prepare("SELECT COUNT(*) FROM appointments WHERE center=? AND appointment_date=? AND (LOWER(status) IN ('serving','hold','waiting') OR (LOWER(status)='confirmed' AND LOWER(COALESCE(arrival_status,'not_arrived'))='arrived'))");
        $queueStmt->execute([$branch,$date]);
        $activeQueue=(int)$queueStmt->fetchColumn();

        $avgStmt=$pdo->prepare("SELECT ROUND(AVG(TIMESTAMPDIFF(MINUTE,service_started_at,completed_at)),1) FROM appointments WHERE center=? AND service=? AND service_started_at IS NOT NULL AND completed_at IS NOT NULL AND completed_at>=DATE_SUB(NOW(),INTERVAL 30 DAY) AND TIMESTAMPDIFF(MINUTE,service_started_at,completed_at) BETWEEN 1 AND 180");
        $avgStmt->execute([$branch,$service]);
        $actualAvg=$avgStmt->fetchColumn();
        $hasActual=$actualAvg!==false && $actualAvg!==null;
        $avgMinutes=$hasActual?max(1,(float)$actualAvg):max(5,(int)($plan['intervalMinutes']??10));
        $projectedWait=(int)round($activeQueue*$avgMinutes);
        $dailyCapacity=max(1,(int)($plan['dailyCapacity']??1));
        $dailyRemaining=max(0,(int)($plan['dailyRemaining']??0));
        $utilization=max(0,min(1,($dailyCapacity-$dailyRemaining)/$dailyCapacity));
        $open=(bool)($plan['open']??false) && $totalRemaining>0 && $dailyRemaining>0;
        $score=$open?($projectedWait+($utilization*25)-min(20,$totalRemaining)*0.45):999999;

        $load='Low workload';
        if(!$open)$load='Unavailable';
        elseif($utilization>=0.85 || $activeQueue>=8)$load='High workload';
        elseif($utilization>=0.55 || $activeQueue>=4)$load='Moderate workload';

        $items[]=[
            'branch'=>$branch,
            'open'=>$open,
            'message'=>$plan['message']??'',
            'clinicHours'=>$plan['clinicHours']??'Closed',
            'availableSlots'=>min($totalRemaining,$dailyRemaining),
            'dailyRemaining'=>$dailyRemaining,
            'dailyCapacity'=>$dailyCapacity,
            'activeQueue'=>$activeQueue,
            'averageServiceMinutes'=>$hasActual?(float)$avgMinutes:null,
            'estimateBasis'=>$hasActual?'Recent completed visits':'Clinic slot interval',
            'projectedWait'=>$projectedWait,
            'load'=>$load,
            '_score'=>$score
        ];
    }

    $eligible=array_values(array_filter($items,fn($item)=>$item['open']));
    usort($eligible,fn($a,$b)=>$a['_score']<=>$b['_score']);
    $recommended=$eligible[0]['branch']??null;
    foreach($items as &$item){$item['recommended']=$recommended!==null&&$item['branch']===$recommended;unset($item['_score']);}
    unset($item);

    json_out([
        'ok'=>true,
        'service'=>$service,
        'date'=>$date,
        'recommendedBranch'=>$recommended,
        'branches'=>$items,
        'message'=>$recommended?'Recommendation is based on branch availability, remaining capacity, active queue volume, and recent service time.':'No RHU has an available schedule for the selected service and date.'
    ]);
}



if ($action === 'patient_waitlist_status') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_smart_waitlist_tables($pdo);
    $patientId=(int)$_SESSION['patient_id'];
    $pdo->prepare("UPDATE appointment_waitlist SET status='expired' WHERE status='offered' AND offer_expires_at<NOW()") ->execute();
    $stmt=$pdo->prepare("SELECT * FROM appointment_waitlist WHERE patient_id=? AND status IN ('waiting','offered') ORDER BY created_at DESC");
    $stmt->execute([$patientId]);
    $items=$stmt->fetchAll();
    $recovered=(int)$pdo->query("SELECT COUNT(*) FROM appointment_waitlist WHERE status='accepted' AND DATE(updated_at)=CURDATE()")->fetchColumn();
    json_out(['ok'=>true,'items'=>$items,'recoveredToday'=>$recovered]);
}

if ($action === 'join_waitlist') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_smart_waitlist_tables($pdo);
    $patientId=(int)$_SESSION['patient_id'];
    $center=trim((string)($data['center']??''));$service=trim((string)($data['service']??''));$date=trim((string)($data['date']??''));$time=trim((string)($data['time']??''));
    if(!$center||!$service||!$date||!$time)json_out(['ok'=>false,'message'=>'Select a full time slot first.'],422);
    $plan=operations_booking_plan($pdo,$center,$service,$date);
    $remaining=(int)($plan['slots'][$time]??0);$status=(string)($plan['slotStatus'][$time]??'closed');
    if($status==='available'&&$remaining>0)json_out(['ok'=>false,'message'=>'This slot is currently available. Please book it directly instead.'],409);
    $stmt=$pdo->prepare("INSERT INTO appointment_waitlist(patient_id,center,service,appointment_date,appointment_time,status,offer_expires_at,recovered_appointment_id) VALUES(?,?,?,?,?,'waiting',NULL,NULL) ON DUPLICATE KEY UPDATE status=IF(status IN ('accepted','cancelled','declined','expired'),'waiting',status),offer_expires_at=NULL,recovered_appointment_id=NULL,updated_at=NOW()");
    $stmt->execute([$patientId,$center,$service,$date,$time]);
    $pos=$pdo->prepare("SELECT COUNT(*) FROM appointment_waitlist WHERE center=? AND service=? AND appointment_date=? AND appointment_time=? AND status='waiting' AND created_at <= (SELECT created_at FROM appointment_waitlist WHERE patient_id=? AND center=? AND service=? AND appointment_date=? AND appointment_time=? LIMIT 1)");
    $pos->execute([$center,$service,$date,$time,$patientId,$center,$service,$date,$time]);
    json_out(['ok'=>true,'message'=>'You joined the waitlist. We will notify you if this slot becomes available.','position'=>(int)$pos->fetchColumn()]);
}

if ($action === 'accept_waitlist_offer') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_smart_waitlist_tables($pdo);
    $patientId=(int)$_SESSION['patient_id'];$id=(int)($data['id']??0);
    $stmt=$pdo->prepare("SELECT * FROM appointment_waitlist WHERE id=? AND patient_id=? AND status='offered' AND offer_expires_at>=NOW()");$stmt->execute([$id,$patientId]);$w=$stmt->fetch();
    if(!$w)json_out(['ok'=>false,'message'=>'This waitlist offer is no longer available.'],409);
    $active=$pdo->prepare("SELECT COUNT(*) FROM appointments WHERE patient_id=? AND LOWER(status) IN ('pending','confirmed','serving','hold','waiting')");$active->execute([$patientId]);
    if((int)$active->fetchColumn()>0)json_out(['ok'=>false,'message'=>'You already have an active appointment.'],409);
    $plan=operations_booking_plan($pdo,$w['center'],$w['service'],$w['appointment_date']);
    if((int)($plan['slots'][$w['appointment_time']]??0)<=0)json_out(['ok'=>false,'message'=>'The recovered slot was already taken.'],409);
    $p=$pdo->prepare("SELECT * FROM patients WHERE id=?");$p->execute([$patientId]);$patient=$p->fetch();
    $q='APT-'.str_pad((string)(1+(int)$pdo->query('SELECT COALESCE(MAX(id),0) FROM appointments')->fetchColumn()),5,'0',STR_PAD_LEFT);
    $ins=$pdo->prepare("INSERT INTO appointments(patient_id,service,center,appointment_date,appointment_time,status,queue_number,queue_type,arrival_status,created_at) VALUES(?,?,?,?,?,'Confirmed',?,'Regular','not_arrived',NOW())");
    $ins->execute([$patientId,$w['service'],$w['center'],$w['appointment_date'],$w['appointment_time'],$q]);
    $appointmentId=(int)$pdo->lastInsertId();
    $pdo->prepare("UPDATE appointment_waitlist SET status='accepted',recovered_appointment_id=?,offer_expires_at=NULL WHERE id=?")->execute([$appointmentId,$id]);
    create_patient_notification($pdo,$patientId,$appointmentId,'appointment','Waitlist Slot Confirmed',"Your recovered {$w['service']} appointment is confirmed for {$w['appointment_date']} at {$w['appointment_time']}.",'appointments.html?appointment='.$appointmentId,'waitlist-accepted:'.$id);
    json_out(['ok'=>true,'message'=>'The recovered appointment slot is now confirmed.','appointmentId'=>$appointmentId]);
}

if ($action === 'patient_booking_info') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);

    $center = trim($_GET['center'] ?? $data['center'] ?? '');
    $service = trim($_GET['service'] ?? $data['service'] ?? '');
    $date = trim($_GET['date'] ?? $data['date'] ?? '');

    $ts = strtotime($date);
    if ($ts) $date = date('Y-m-d', $ts);

    $requestedQueueType = strtolower(trim($data['queueType'] ?? $_GET['queueType'] ?? 'regular'));
    $isPriority = $requestedQueueType === 'priority';
    if (!$center || !$service || !$date) json_out(['ok'=>false,'message'=>'Select a service, RHU branch, and appointment date.'],422);
    $plan=operations_booking_plan($pdo,$center,$service,$date);

    $estimatedWait=0;foreach(($plan['slots']??[]) as $remaining)$estimatedWait=max($estimatedWait,max(0,(int)($plan['capacity']??0)-(int)$remaining)*10);

    json_out([
        'ok'=>true,
        'queuePreview'=>'Assigned at check-in',
        'isPriority'=>$isPriority,
        'isOpen'=>(bool)($plan['open']??false),
        'message'=>$plan['message']??'',
        'availableTimes'=>$plan['times']??[],
        'slots'=>$plan['slots']??[],
        'slotStatus'=>$plan['slotStatus']??[],
        'capacity'=>(int)($plan['capacity']??0),
        'dailyCapacity'=>(int)($plan['dailyCapacity']??0),
        'dailyRemaining'=>(int)($plan['dailyRemaining']??0),
        'estimatedWait'=>$estimatedWait,
        'clinicHours'=>$plan['clinicHours']??'Closed',
        'closures'=>$plan['closures']??[]
    ]);
}

if ($action === 'book_appointment') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_innovation_tables($pdo);
    $caregiverId=(int)$_SESSION['patient_id'];
    operations_require_patient_consent($pdo,$caregiverId);
    $requestedBookingPatientId=(int)($data['for_patient_id']??0);

    // cache handling
    $bookingPatientId=$requestedBookingPatientId>0?$requestedBookingPatientId:$caregiverId;
    if(!innovation_patient_can_manage($pdo,$caregiverId,$bookingPatientId)) {
        json_out(['ok'=>false,'message'=>'You do not have approved Family Care access for this patient.'],403);
    }
    $center = trim($data['center'] ?? '');
    $service=trim($data['service'] ?? '');
    $date=trim($data['date'] ?? '');
    $time=trim($data['time'] ?? '');
    if (!$center || !$service || !$date || !$time) json_out(['ok'=>false,'message'=>'Please complete all booking fields.'],422);

    $pstmt=$pdo->prepare('SELECT * FROM patients WHERE id=? AND account_status=\'Active\'');
    $pstmt->execute([$bookingPatientId]);
    $p=$pstmt->fetch();
    if(!$p) json_out(['ok'=>false,'message'=>'The selected patient record is unavailable.'],404);
    $birthInput = trim($data['birthdate'] ?? '');
    $genderInput = trim($data['gender'] ?? '');
    $barangayInput = trim($data['barangay'] ?? '');
    if ($bookingPatientId===$caregiverId && ($birthInput || $genderInput || $barangayInput)) {
        $birthValue = $birthInput ? date('Y-m-d', strtotime($birthInput)) : $p['birthdate'];
        $genderValue = $genderInput ?: $p['gender'];
        $barangayValue = $barangayInput ?: $p['barangay'];
        $pdo->prepare('UPDATE patients SET birthdate=?, gender=?, barangay=? WHERE id=?')->execute([$birthValue,$genderValue,$barangayValue,$bookingPatientId]);
        $p['birthdate']=$birthValue; $p['gender']=$genderValue; $p['barangay']=$barangayValue;
    }
    $missing=[];
    if (empty($p['birthdate'])) $missing[]='Date of Birth';
    if (empty($p['gender'])) $missing[]='Sex';
    if (empty($p['barangay'])) $missing[]='Barangay';
    if ($missing) json_out(['ok'=>false,'message'=>'Please complete: '.implode(', ', $missing).'.'],422);

    $ts = strtotime($date);
    if ($ts) $date = date('Y-m-d', $ts);

    if ($date < date('Y-m-d')) json_out(['ok'=>false,'message'=>'Past dates cannot be booked.'],422);
    $plan=operations_booking_plan($pdo,$center,$service,$date);
    if(empty($plan['open']))json_out(['ok'=>false,'message'=>$plan['message']??'This RHU is closed on the selected date.'],409);
    if(!in_array($time,$plan['times']??[],true)||($plan['slotStatus'][$time]??'closed')!=='available')json_out(['ok'=>false,'message'=>'The selected time is closed, full, or no longer available. Refresh the schedule and choose another slot.'],409);
    $requestedQueueType = strtolower(trim($data['queueType'] ?? 'regular'));
    $isPriority = $requestedQueueType === 'priority';
    $reason = $isPriority ? trim($data['priorityReason'] ?? '') : '';
    $concern = trim((string)($data['concern'] ?? $data['notes'] ?? ''));
    if (mb_strlen($concern) > 1000) $concern = mb_substr($concern, 0, 1000);
    operations_ensure_tables($pdo);
    try {
        $pdo->beginTransaction();
        $lock=$pdo->prepare("INSERT INTO booking_slot_locks(branch,service,appointment_date,appointment_time) VALUES(?,?,?,?) ON DUPLICATE KEY UPDATE touched_at=NOW()");$lock->execute([$center,$service,$date,$time]);
        $lock=$pdo->prepare("SELECT branch FROM booking_slot_locks WHERE branch=? AND service=? AND appointment_date=? AND appointment_time=? FOR UPDATE");$lock->execute([$center,$service,$date,$time]);$lock->fetchColumn();
        $active=$pdo->prepare("SELECT id FROM appointments WHERE patient_id=? AND LOWER(status) IN ('pending','confirmed','serving','hold','waiting') LIMIT 1 FOR UPDATE");$active->execute([$bookingPatientId]);if($active->fetchColumn())throw new RuntimeException('You already have an active appointment.');
        $slotCheck=$pdo->prepare("SELECT COUNT(*) FROM appointments WHERE center=? AND service=? AND appointment_date=? AND appointment_time=? AND LOWER(status) IN ('pending','confirmed','serving','hold','waiting')");$slotCheck->execute([$center,$service,$date,$time]);if((int)$slotCheck->fetchColumn()>=(int)$plan['capacity'])throw new RuntimeException('Selected time slot has just become full. Please choose another time.');
        $dailyCheck=$pdo->prepare("SELECT COUNT(*) FROM appointments WHERE center=? AND appointment_date=? AND LOWER(status) IN ('pending','confirmed','serving','hold','waiting')");$dailyCheck->execute([$center,$date]);if((int)$dailyCheck->fetchColumn()>=(int)($plan['dailyCapacity']??200))throw new RuntimeException('This RHU has just reached its daily appointment capacity. Please choose another date.');
        $temporaryReference='APT-NEW-'.bin2hex(random_bytes(3));
        $stmt=$pdo->prepare("INSERT INTO appointments(patient_id,queue_number,center,service,appointment_date,appointment_time,queue_type,priority_reason,concern,status) VALUES(?,?,?,?,?,?,?,?,?, 'Confirmed')");
        $stmt->execute([$bookingPatientId,$temporaryReference,$center,$service,$date,$time,$isPriority?'priority':'regular',$reason,$concern]);
        $id=$pdo->lastInsertId();
        $appointmentReference='APT-'.str_pad((string)$id,5,'0',STR_PAD_LEFT);
        $pdo->prepare("UPDATE appointments SET queue_number=? WHERE id=?")->execute([$appointmentReference,$id]);
        $pdo->commit();
    } catch (RuntimeException $e) {
        if($pdo->inTransaction())$pdo->rollBack();json_out(['ok'=>false,'message'=>$e->getMessage()],409);
    } catch (Throwable $e) {
        if($pdo->inTransaction())$pdo->rollBack();throw $e;
    }
    $row=$pdo->query('SELECT * FROM appointments WHERE id='.(int)$id)->fetch();
    if ($row) {
        [$ntype,$ntitle,$nmessage] = appointment_notification_copy('Confirmed',$row);
        create_patient_notification(
            $pdo,
            $row['patient_id'],
            $row['id'],
            $ntype,
            $ntitle,
            $nmessage,
            'appointments.html?appointment=' . (int)$row['id']
        );
    }
    $emailResult = $row
        ? send_appointment_email($pdo,$row,'Confirmed')
        : ['ok'=>false,'skipped'=>true,'message'=>'Appointment record was not found.'];
    if ($row) {
        $patientFullName=trim($p['first_name'].' '.$p['last_name']);
        audit_event($pdo,[
          'name'=>$patientFullName,
          'email'=>$p['email']??'',
          'role'=>'Patient',
          'branch'=>$row['center']
        ],'Appointments','Booked Appointment',
          "{$patientFullName} booked Appointment {$row['queue_number']} for {$row['service']} on ".date('F j, Y',strtotime($row['appointment_date']))." at {$row['appointment_time']} in {$row['center']}; automatically confirmed and added to the RHU schedule.");
    }
    if($bookingPatientId!==$caregiverId){
        $me=$pdo->prepare("SELECT CONCAT(first_name,' ',last_name) FROM patients WHERE id=?");$me->execute([$caregiverId]);
        operations_log_patient_access($pdo,$bookingPatientId,'caregiver',$caregiverId,trim((string)$me->fetchColumn())?:'Approved caregiver','Booked dependent appointment','Appointment','Approved Family Care appointment management',$center);
    }

    json_out([
        'ok'=>true,
        'appointment'=>appt_payload($row, trim($p['first_name'].' '.$p['last_name'])),
        'email'=>$emailResult
    ]);
}

if ($action === 'patient_appointments') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false],401);
    $ownerId=(int)$_SESSION['patient_id'];$managedIds=innovation_managed_patient_ids($pdo,$ownerId);
    $marks=implode(',',array_fill(0,count($managedIds),'?'));
    $stmt=$pdo->prepare("SELECT a.*, CONCAT(p.first_name,' ',p.last_name) patient_name FROM appointments a JOIN patients p ON p.id=a.patient_id WHERE a.patient_id IN ({$marks}) ORDER BY a.id DESC");
    $stmt->execute($managedIds);$rows=$stmt->fetchAll();$appointments=[];
    foreach($rows as $row){$item=appt_payload($row,$row['patient_name']);$item['isDependent']=(int)$row['patient_id']!==$ownerId;$appointments[]=$item;}
    json_out(['ok'=>true,'appointments'=>$appointments]);
}

if ($action === 'cancel_appointment') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false],401);

    $id = (int)($data['id'] ?? 0);$ownerId=(int)$_SESSION['patient_id'];
    $access=$pdo->prepare('SELECT patient_id FROM appointments WHERE id=?');$access->execute([$id]);$appointmentPatientId=(int)$access->fetchColumn();
    if(!$appointmentPatientId||!innovation_patient_can_manage($pdo,$ownerId,$appointmentPatientId))json_out(['ok'=>false,'message'=>'Appointment was not found or is outside your Family Care access.'],404);
    $stmt = $pdo->prepare(
        "UPDATE appointments
         SET status='Cancelled'
         WHERE id=? AND patient_id=?"
    );
    $stmt->execute([$id,$appointmentPatientId]);

    $stmt = $pdo->prepare(
        "SELECT *
         FROM appointments
         WHERE id=? AND patient_id=?"
    );
    $stmt->execute([$id,$appointmentPatientId]);
    $appointment = $stmt->fetch();

    $emailResult = null;

    if ($appointment) {
        [$type,$title,$message] = appointment_notification_copy('Cancelled',$appointment);

        create_patient_notification(
            $pdo,
            $appointment['patient_id'],
            $appointment['id'],
            $type,
            $title,
            $message,
            'appointments.html?appointment=' . (int)$appointment['id']
        );

        $emailResult = send_appointment_email(
            $pdo,
            $appointment,
            'Cancelled'
        );
        smart_waitlist_offer_next($pdo,$appointment);
        $patientFullName=patient_display_name($pdo,$appointment['patient_id']);
        audit_event($pdo,[
          'name'=>$patientFullName,
          'email'=>'',
          'role'=>'Patient',
          'branch'=>$appointment['center']
        ],'Appointments','Patient Cancelled Appointment',
          "{$patientFullName} cancelled Appointment APT-".str_pad((string)$appointment['id'],5,'0',STR_PAD_LEFT)." for {$appointment['service']} at {$appointment['center']}.");
    }

    json_out([
        'ok'=>true,
        'email'=>$emailResult
    ]);
}

if ($action === 'patient_logout') {
    unset($_SESSION['patient_id']);
    json_out(['ok'=>true]);
}

if ($action === 'patient_notifications') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    try {
        ensure_notifications_table($pdo);
    } catch (Throwable $e) {
        json_out(['ok'=>true,'notifications'=>[],'unread'=>0,'warning'=>'Notifications are temporarily unavailable.']);
    }
    $limit = max(1, min(100, (int)($_GET['limit'] ?? 50)));
    $stmt = $pdo->prepare("SELECT id, appointment_id, type, title, message, link, is_read, created_at
                           FROM notifications
                           WHERE patient_id=?
                           ORDER BY created_at DESC, id DESC
                           LIMIT {$limit}");
    $stmt->execute([$_SESSION['patient_id']]);
    $rows = $stmt->fetchAll();
    $countStmt = $pdo->prepare("SELECT COUNT(*) FROM notifications WHERE patient_id=? AND is_read=0");
    $countStmt->execute([$_SESSION['patient_id']]);
    json_out(['ok'=>true,'notifications'=>$rows,'unread'=>(int)$countStmt->fetchColumn()]);
}

if ($action === 'patient_notification_read') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_notifications_table($pdo);
    $id = (int)($data['id'] ?? 0);
    if ($id > 0) {
        $stmt = $pdo->prepare("UPDATE notifications SET is_read=1 WHERE id=? AND patient_id=?");
        $stmt->execute([$id, $_SESSION['patient_id']]);
    }
    json_out(['ok'=>true]);
}

if ($action === 'patient_notifications_read_all') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_notifications_table($pdo);
    $stmt = $pdo->prepare("UPDATE notifications SET is_read=1 WHERE patient_id=?");
    $stmt->execute([$_SESSION['patient_id']]);
    json_out(['ok'=>true]);
}

if ($action === 'admin_test_brevo_email') {
    require_admin_context($pdo, true);

    $email = trim((string)($data['email'] ?? ''));
    $name = trim((string)($data['name'] ?? 'Patient'));

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        json_out(['ok'=>false,'message'=>'Enter a valid email address.'],422);
    }

    $result = send_brevo_email(
        $pdo,
        $email,
        $name,
        'Pulilan Health Center - Email Test',
        "<div style='font-family:Arial,sans-serif;padding:24px'>
           <h2 style='color:#0b3d91'>Pulilan Health Center</h2>
           <p>Your Brevo transactional email integration is working.</p>
         </div>",
        'test'
    );

    json_out([
        'ok'=>(bool)($result['ok'] ?? false),
        'message'=>$result['message'] ?? 'Email test completed.',
        'email'=>$result
    ], !empty($result['ok']) ? 200 : 422);
}

if ($action === 'admin_test_brevo_sms') {
    require_admin_context($pdo, true);

    $phone = trim((string)($data['phone'] ?? ''));
    $message = trim((string)($data['message'] ?? 'Pulilan Health Center SMS integration test.'));

    if ($phone === '') {
        json_out(['ok'=>false,'message'=>'Enter a mobile number for the SMS test.'],422);
    }

    $result = send_brevo_sms($pdo,$phone,$message,'test');
    json_out([
        'ok'=>(bool)($result['ok'] ?? false),
        'message'=>$result['message'] ?? 'SMS test completed.',
        'sms'=>$result
    ], !empty($result['ok']) ? 200 : 422);
}

if ($action === 'disease_case_create') {
    $admin = require_admin_context($pdo);
    ensure_disease_cases_table($pdo);
    $payload = validate_disease_case_payload($pdo,$data,0);
    require_staff_branch($admin,$payload['rhu_branch']);

    $birthdate = null;
    if (!empty($payload['patient_id'])) {
        $stmt=$pdo->prepare("SELECT birthdate FROM patients WHERE id=?");
        $stmt->execute([$payload['patient_id']]);
        $birthdate=$stmt->fetchColumn() ?: null;
    }
    $ageGroup=derive_age_group($birthdate,$payload['case_date']);

    $recordSource=trim((string)($data['record_source'] ?? 'RHU Consultation'));
    if (!in_array($recordSource,['RHU Consultation','Laboratory Result','Referral Record','Surveillance Report'],true)) {
        json_out(['ok'=>false,'message'=>'Select a valid record source.'],422);
    }
    $stmt=$pdo->prepare("INSERT INTO disease_cases(
      patient_id,appointment_id,disease_category,diagnosis,symptoms,barangay,
      rhu_branch,case_date,onset_date,age_group,case_status,verification_status,
      record_source,recorded_by,verified_by,verified_at
    ) VALUES(?,?,?,?,?,?,?,?,?,?,?,'Verified',?,?,?,NOW())");
    $stmt->execute([
      $payload['patient_id'],$payload['appointment_id'],$payload['disease_category'],
      $payload['diagnosis'],$payload['symptoms'],$payload['barangay'],
      $payload['rhu_branch'],$payload['case_date'],$payload['onset_date'],
      $ageGroup,$payload['case_status'],$recordSource,$admin['id'],$admin['id']
    ]);

    $id=(int)$pdo->lastInsertId();
    audit_event($pdo,$admin,'Disease Trends','Recorded Disease Case',
      "{$payload['disease_category']} in {$payload['barangay']} ({$payload['case_date']})");
    json_out(['ok'=>true,'id'=>$id,'message'=>'Disease case recorded.']);
}

if ($action === 'disease_case_update') {
    $admin = require_admin_context($pdo);
    ensure_disease_cases_table($pdo);
    $id=(int)($data['id'] ?? 0);
    if ($id<=0) json_out(['ok'=>false,'message'=>'Disease case ID is required.'],422);

    $oldStmt=$pdo->prepare("SELECT * FROM disease_cases WHERE id=?");
    $oldStmt->execute([$id]);
    $old=$oldStmt->fetch();
    if (!$old) json_out(['ok'=>false,'message'=>'Disease case was not found.'],404);
    require_staff_branch($admin,$old['rhu_branch']);

    $payload=validate_disease_case_payload($pdo,$data,$id);
    require_staff_branch($admin,$payload['rhu_branch']);

    $birthdate=null;
    if (!empty($payload['patient_id'])) {
        $stmt=$pdo->prepare("SELECT birthdate FROM patients WHERE id=?");
        $stmt->execute([$payload['patient_id']]);
        $birthdate=$stmt->fetchColumn() ?: null;
    }
    $ageGroup=derive_age_group($birthdate,$payload['case_date']);

    $recordSource=trim((string)($data['record_source'] ?? $old['record_source'] ?? 'RHU Consultation'));
    if (!in_array($recordSource,['RHU Consultation','Laboratory Result','Referral Record','Surveillance Report'],true)) {
        json_out(['ok'=>false,'message'=>'Select a valid record source.'],422);
    }
    $stmt=$pdo->prepare("UPDATE disease_cases SET
      patient_id=?,appointment_id=?,disease_category=?,diagnosis=?,symptoms=?,
      barangay=?,rhu_branch=?,case_date=?,onset_date=?,age_group=?,case_status=?,
      verification_status='Verified',record_source=?,verified_by=?,verified_at=NOW()
      WHERE id=?");
    $stmt->execute([
      $payload['patient_id'],$payload['appointment_id'],$payload['disease_category'],
      $payload['diagnosis'],$payload['symptoms'],$payload['barangay'],
      $payload['rhu_branch'],$payload['case_date'],$payload['onset_date'],
      $ageGroup,$payload['case_status'],$recordSource,$admin['id'],$id
    ]);

    audit_event($pdo,$admin,'Disease Trends','Edited Disease Case',
      "Disease case ID {$id}: {$payload['disease_category']} in {$payload['barangay']}");
    json_out(['ok'=>true,'message'=>'Disease case updated.']);
}

if ($action === 'disease_case_detail') {
    $admin = require_admin_context($pdo);
    ensure_disease_cases_table($pdo);
    $id=(int)($_GET['id'] ?? $data['id'] ?? 0);

    $stmt=$pdo->prepare("SELECT dc.*,
      CONCAT(p.first_name,' ',p.last_name) AS patient_name,
      a.queue_number,a.service,
      COALESCE(ad.name,'Unknown') AS recorded_by_name
      FROM disease_cases dc
      LEFT JOIN patients p ON p.id=dc.patient_id
      LEFT JOIN appointments a ON a.id=dc.appointment_id
      LEFT JOIN admins ad ON ad.id=dc.recorded_by
      WHERE dc.id=?");
    $stmt->execute([$id]);
    $case=$stmt->fetch();
    if (!$case) json_out(['ok'=>false,'message'=>'Disease case was not found.'],404);
    require_staff_branch($admin,$case['rhu_branch']);
    json_out(['ok'=>true,'case'=>$case]);
}

if ($action === 'disease_case_delete') {
    $admin = require_admin_context($pdo);
    ensure_disease_cases_table($pdo);
    $id=(int)($data['id'] ?? 0);

    $stmt=$pdo->prepare("SELECT * FROM disease_cases WHERE id=?");
    $stmt->execute([$id]);
    $case=$stmt->fetch();
    if (!$case) json_out(['ok'=>false,'message'=>'Disease case was not found.'],404);
    require_staff_branch($admin,$case['rhu_branch']);

    $pdo->prepare("DELETE FROM disease_cases WHERE id=?")->execute([$id]);
    audit_event($pdo,$admin,'Disease Trends','Deleted Disease Case',
      "Disease case ID {$id}: {$case['disease_category']} in {$case['barangay']}");
    json_out(['ok'=>true,'message'=>'Disease case deleted.']);
}

if ($action === 'disease_cases_data') {
    $admin = require_admin_context($pdo);
    ensure_disease_cases_table($pdo);

    $year=(int)($_GET['year'] ?? date('Y'));
    $month=(int)($_GET['month'] ?? 0);
    $category=trim((string)($_GET['category'] ?? 'all'));
    $barangay=trim((string)($_GET['barangay'] ?? 'all'));
    $rhu=trim((string)($_GET['rhu'] ?? 'all'));
    $ageGroup=trim((string)($_GET['age_group'] ?? 'all'));

    if (!$admin['is_system_admin']) $rhu=$admin['branch'];

    $where=["YEAR(dc.case_date)=?","dc.verification_status='Verified'"];
    $params=[$year];
    if ($month > 0) { $where[]="MONTH(dc.case_date)=?"; $params[]=$month; }
    if ($category !== 'all' && $category !== '') { $where[]="dc.disease_category=?"; $params[]=$category; }
    if ($barangay !== 'all' && $barangay !== '') { $where[]="dc.barangay=?"; $params[]=$barangay; }
    if ($rhu !== 'all' && $rhu !== '') { $where[]="dc.rhu_branch=?"; $params[]=$rhu; }
    if ($ageGroup !== 'all' && $ageGroup !== '') { $where[]="dc.age_group=?"; $params[]=$ageGroup; }

    $sql="SELECT dc.id,dc.disease_category,dc.diagnosis,dc.barangay,dc.rhu_branch,
      dc.case_date,dc.onset_date,dc.age_group,dc.case_status,dc.verification_status,
      dc.record_source,dc.verified_at,dc.created_at,COALESCE(ad.name,'System') verified_by_name
      FROM disease_cases dc
      LEFT JOIN admins ad ON ad.id=dc.verified_by
      WHERE ".implode(" AND ",$where)."
      ORDER BY dc.case_date DESC,dc.id DESC";
    $stmt=$pdo->prepare($sql);
    $stmt->execute($params);
    $cases=$stmt->fetchAll();

    json_out([
      'ok'=>true,
      'cases'=>$cases,
      'categories'=>allowed_disease_categories(),
      'barangays'=>pulilan_barangays(),
      'rhuBranches'=>allowed_rhu_branches(),
      'year'=>$year,
      'dateRange'=>[
        'from'=>$month>0?sprintf('%04d-%02d-01',$year,$month):sprintf('%04d-01-01',$year),
        'to'=>$month>0?date('Y-m-t',strtotime(sprintf('%04d-%02d-01',$year,$month))):sprintf('%04d-12-31',$year)
      ],
      'privacyRule'=>'Verified barangay totals only. Patient names are never included in heatmap data.'
    ]);
}

if ($action === 'admin_audit_write') {
    $admin=require_admin_context($pdo);
    $module=trim((string)($data['module'] ?? 'System'));
    $eventAction=trim((string)($data['event_action'] ?? 'Viewed Page'));
    $details=trim((string)($data['details'] ?? ''));
    audit_event($pdo,$admin,$module,$eventAction,$details);
    json_out(['ok'=>true]);
}

if ($action === 'system_backup_export') {
    $admin=require_admin_context($pdo,true);
    ensure_disease_cases_table($pdo);
    ensure_notifications_table($pdo);
    ensure_innovation_tables($pdo);operations_ensure_tables($pdo);ensure_email_logs_table($pdo);ensure_sms_logs_table($pdo);
    $tables=['patients','appointments','disease_cases','notifications','announcements','announcement_reads','chat_messages','chat_thread_status','family_care_links','clinic_schedules','clinic_capacity_rules','clinic_closures','privacy_policy_versions','patient_consents','patient_access_history','notification_delivery_logs','email_logs','sms_logs','system_settings','audit_logs'];
    $backup=['_meta'=>[
      'system'=>'Pulilan Health Center',
      'version'=>'3.0-operations',
      'createdAt'=>date(DATE_ATOM),
      'createdBy'=>$admin['name'],
      'restoreMode'=>'merge'
    ],'data'=>[]];
    foreach ($tables as $table) {
        try { $backup['data'][$table]=$pdo->query("SELECT * FROM {$table}")->fetchAll(); }
        catch (Throwable $e) { $backup['data'][$table]=[]; }
    }
    audit_event($pdo,$admin,'Backup & Restore','Created Backup','Exported operational, privacy, caregiver, communication, and core system tables');
    json_out(['ok'=>true,'backup'=>$backup]);
}

if ($action === 'system_backup_restore') {
    $admin=require_admin_context($pdo,true);
    $backup=$data['backup'] ?? null;
    if (!is_array($backup) || !isset($backup['data']) || !is_array($backup['data'])) {
        json_out(['ok'=>false,'message'=>'Invalid backup file.'],422);
    }
    ensure_disease_cases_table($pdo);ensure_innovation_tables($pdo);operations_ensure_tables($pdo);ensure_email_logs_table($pdo);ensure_sms_logs_table($pdo);
    $allowed=[
      'patients'=>['id','patient_code','first_name','last_name','email','password_hash','phone','birthdate','gender','address','barangay','philhealth_no','is_senior','is_pwd','is_4ps','preferred_rhu','account_status','archived_at','profile_json','created_at'],
      'appointments'=>['id','patient_id','queue_number','center','service','appointment_date','appointment_time','queue_type','priority_reason','concern','status','arrival_status','arrived_at','service_started_at','completed_at','created_at','updated_at'],
      'disease_cases'=>['id','patient_id','appointment_id','disease_category','diagnosis','symptoms','barangay','rhu_branch','case_date','onset_date','age_group','case_status','verification_status','record_source','recorded_by','verified_by','verified_at','created_at'],
      'notifications'=>['id','patient_id','appointment_id','type','title','message','link','dedupe_key','is_read','created_at'],
      'announcements'=>['id','title','message','branch','target_barangay','status','priority','publish_at','expires_at','attachment_path','attachment_name','attachment_mime','created_by','created_at','updated_at'],
      'announcement_reads'=>['announcement_id','patient_id','read_at'],
      'chat_messages'=>['id','patient_id','admin_id','sender_type','message','is_read','is_automated','created_at'],
      'chat_thread_status'=>['patient_id','status','rhu_branch','assigned_admin_id','updated_at'],
      'family_care_links'=>['id','caregiver_patient_id','dependent_patient_id','relationship','verification_required','verification_status','verification_method','verification_notes','verification_path','verification_name','verification_mime','verified_by_admin_id','verified_at','consent_scope','status','requested_at','responded_at'],
      'clinic_schedules'=>['id','branch','day_of_week','is_open','open_time','close_time','break_start','break_end','slot_interval_minutes','updated_by','updated_at'],
      'clinic_capacity_rules'=>['id','branch','service','capacity_per_slot','daily_capacity','updated_by','updated_at'],
      'clinic_closures'=>['id','branch','service','closure_date','closure_type','title','details','closed_all_day','start_time','end_time','status','created_by','created_at','updated_at'],
      'privacy_policy_versions'=>['id','version_label','title','content','retention_days','status','effective_at','created_by','created_at','updated_at'],
      'patient_consents'=>['id','patient_id','policy_id','status','source','accepted_at','withdrawn_at','created_at'],
      'patient_access_history'=>['id','patient_id','actor_type','actor_id','actor_name','action','resource','purpose','branch','created_at'],
      'notification_delivery_logs'=>['id','channel','patient_id','appointment_id','recipient','event_type','title','message','link','status','provider_record_id','error_message','attempts','last_attempt_at','created_at'],
      'email_logs'=>['id','patient_id','appointment_id','recipient','event_type','subject','status','provider_message_id','provider_response','created_at'],
      'sms_logs'=>['id','patient_id','appointment_id','recipient','event_type','message','status','provider_message_id','provider_response','created_at'],
      'system_settings'=>['setting_key','setting_value','updated_by','updated_at'],
      'audit_logs'=>['id','user_name','email','role','branch','module','action','details','created_at']
    ];
    $restored=[];
    $pdo->beginTransaction();
    try {
      foreach ($allowed as $table=>$columns) {
        $rows=$backup['data'][$table] ?? [];
        if (!is_array($rows)) continue;
        $count=0;
        foreach ($rows as $row) {
          if (!is_array($row)) continue;
          $use=[];
          foreach ($columns as $col) if (array_key_exists($col,$row)) $use[$col]=$row[$col];
          if (!$use) continue;
          $cols=array_keys($use);
          $marks=implode(',',array_fill(0,count($cols),'?'));
          $updates=array_values(array_filter($cols,fn($c)=>$c!=='id'));
          $updateSql=$updates ? implode(',',array_map(fn($c)=>"`{$c}`=VALUES(`{$c}`)",$updates)) : "`id`=`id`";
          $sql="INSERT INTO `{$table}` (`".implode('`,`',$cols)."`) VALUES({$marks}) ON DUPLICATE KEY UPDATE {$updateSql}";
          $stmt=$pdo->prepare($sql);
          $stmt->execute(array_values($use));
          $count++;
        }
        $restored[$table]=$count;
      }
      $pdo->commit();
      audit_event($pdo,$admin,'Backup & Restore','Restored Backup','Merged backup data: '.json_encode($restored));
      json_out(['ok'=>true,'restored'=>$restored,'message'=>'Backup restored using safe merge mode.']);
    } catch (Throwable $e) {
      if ($pdo->inTransaction()) $pdo->rollBack();
      json_out(['ok'=>false,'message'=>'Restore failed: '.$e->getMessage()],500);
    }
}

if ($action === 'admin_me') {
    if (empty($_SESSION['admin_id'])) json_out(['ok'=>false,'message'=>'Admin login required.'],401);
    ensure_admin_activity_columns($pdo);
    $stmt=$pdo->prepare('SELECT * FROM admins WHERE id=?');
    $stmt->execute([$_SESSION['admin_id']]);
    $a=$stmt->fetch();
    if (!$a) json_out(['ok'=>false,'message'=>'Admin not found.'],404);
    if (($a['account_status'] ?? 'Active') !== 'Active') {
        unset($_SESSION['admin_id']);
        json_out(['ok'=>false,'message'=>'This administrator account is disabled. Contact the System Administrator.'],403);
    }
    touch_admin_activity($pdo,(int)$_SESSION['admin_id']);
    $role = (string)$a['role'];
    $branch = ($a['branch'] === 'All RHU Branches') ? 'All Branches' : (string)$a['branch'];
    $roleKey = strtolower(trim($role));
    $branchKey = strtolower(trim($branch));
    $isSystemAdmin = in_array($roleKey, ['system administrator','super administrator','super admin'], true)
        || in_array($branchKey, ['all branches','all rhu branches','all branch','all rhu'], true);
    if ($isSystemAdmin) {
        $branch = 'All Branches';
        $role = 'System Administrator';
    }
    json_out(['ok'=>true,'admin'=>['id'=>(int)$a['id'],'email'=>$a['email'],'name'=>$a['name'],'role'=>$role,'branch'=>$branch,'is_system_admin'=>$isSystemAdmin,'loggedIn'=>true]]);
}

if ($action === 'admin_logout') {
    if (!empty($_SESSION['admin_id'])) {
        $stmt=$pdo->prepare("SELECT id,name,email,role,branch FROM admins WHERE id=?");
        $stmt->execute([$_SESSION['admin_id']]);
        $logoutAdmin=$stmt->fetch();
        if ($logoutAdmin) { audit_event($pdo,$logoutAdmin,'Authentication','Admin Logout','Administrator signed out.'); touch_admin_activity($pdo,(int)$logoutAdmin['id'],false,true); }
    }
    unset($_SESSION['patient_id'],$_SESSION['admin_id'],$_SESSION['pending_admin_id'],$_SESSION['admin_otp_hash'],$_SESSION['admin_otp_expires'],$_SESSION['admin_otp_attempts'],$_SESSION['admin_otp_sent_at']);
    json_out(['ok'=>true]);
}

if ($action === 'admin_login') {
    ensure_admin_activity_columns($pdo);
    $email=strtolower(trim($data['email']??''));
    $pass=(string)($data['password']??'');
    $stmt=$pdo->prepare('SELECT * FROM admins WHERE email=?');
    $stmt->execute([$email]);
    $a=$stmt->fetch();

    if ($a) {
        $remaining=login_lock_remaining_seconds($a['locked_until'] ?? null);
        if ($remaining>0) json_out(['ok'=>false,'message'=>login_lock_message($remaining),'retry_after'=>$remaining],429);
        if (!empty($a['locked_until'])) clear_login_lock($pdo,'admins',(int)$a['id']);
    }
    if (!$a || !password_verify($pass,$a['password_hash'])) {
        if ($a) {
            // A short per-account cooldown protects privileged accounts without blocking the whole RHU.
            // Another authorized staff account can still handle emergency walk-ins.
            $locked=record_failed_login($pdo,'admins',(int)$a['id'],(int)($a['failed_login_attempts'] ?? 0),5);
            if ($locked>0) json_out(['ok'=>false,'message'=>login_lock_message($locked),'retry_after'=>$locked],429);
        }
        json_out(['ok'=>false,'message'=>'Invalid email or password.'],401);
    }
    clear_login_lock($pdo,'admins',(int)$a['id']);
    if (($a['account_status'] ?? 'Active') !== 'Active') {
        json_out(['ok'=>false,'message'=>'This administrator account is disabled. Contact the System Administrator.'],403);
    }

    // role check

    unset($_SESSION['patient_id']);

    $roleText=strtolower(trim((string)($a['role']??'')));
    $isSystemAdmin=(strpos($roleText,'admin')!==false || strpos($roleText,'system')!==false || strpos($roleText,'super')!==false);

    // otp handling
    if (!$isSystemAdmin) {
        session_regenerate_id(true);
        $_SESSION['admin_id']=(int)$a['id'];
        unset($_SESSION['pending_admin_id'],$_SESSION['admin_otp_hash'],$_SESSION['admin_otp_expires'],$_SESSION['admin_otp_attempts'],$_SESSION['admin_otp_sent_at']);
        touch_admin_activity($pdo,(int)$a['id'],true,false);
        audit_event($pdo,$a,'Authentication','Staff Login','Successful RHU staff sign-in.');
        json_out(['ok'=>true,'requiresOtp'=>false,'message'=>'Staff sign-in successful.']);
    }

    $lastSent=(int)($_SESSION['admin_otp_sent_at']??0);
    if ($lastSent && time()-$lastSent<30) {
        json_out(['ok'=>false,'message'=>'Please wait before requesting another verification code.'],429);
    }
    $otp=(string)random_int(100000,999999);
    try { send_admin_otp_email($pdo,$a,$otp); }
    catch (Exception $e) { json_out(['ok'=>false,'message'=>'Unable to send the verification code. Check the SMTP settings.'],503); }

    unset($_SESSION['admin_id']);
    $_SESSION['pending_admin_id']=(int)$a['id'];
    $_SESSION['admin_otp_hash']=password_hash($otp,PASSWORD_DEFAULT);
    $_SESSION['admin_otp_expires']=time()+600;
    $_SESSION['admin_otp_attempts']=0;
    $_SESSION['admin_otp_sent_at']=time();
    json_out(['ok'=>true,'requiresOtp'=>true,'maskedEmail'=>masked_email($a['email']),'message'=>'Verification code sent.']);
}

if ($action === 'admin_resend_otp') {
    if (empty($_SESSION['pending_admin_id'])) json_out(['ok'=>false,'message'=>'Start a new secure sign-in request.'],401);
    $lastSent=(int)($_SESSION['admin_otp_sent_at']??0);
    $remaining=30-(time()-$lastSent);
    if ($lastSent && $remaining>0) json_out(['ok'=>false,'message'=>'Please wait '.$remaining.' seconds before requesting another verification code.','retry_after'=>$remaining],429);

    $stmt=$pdo->prepare("SELECT * FROM admins WHERE id=?");
    $stmt->execute([(int)$_SESSION['pending_admin_id']]);
    $admin=$stmt->fetch();
    if (!$admin || ($admin['account_status'] ?? 'Active') !== 'Active') {
        unset($_SESSION['pending_admin_id'],$_SESSION['admin_otp_hash'],$_SESSION['admin_otp_expires'],$_SESSION['admin_otp_attempts'],$_SESSION['admin_otp_sent_at']);
        json_out(['ok'=>false,'message'=>'This administrator account is unavailable. Sign in again.'],403);
    }

    $otp=(string)random_int(100000,999999);
    try { send_admin_otp_email($pdo,$admin,$otp); }
    catch (Exception $e) { json_out(['ok'=>false,'message'=>'Unable to resend the verification code. Check the SMTP settings.'],503); }

    $_SESSION['admin_otp_hash']=password_hash($otp,PASSWORD_DEFAULT);
    $_SESSION['admin_otp_expires']=time()+600;
    $_SESSION['admin_otp_attempts']=0;
    $_SESSION['admin_otp_sent_at']=time();
    json_out(['ok'=>true,'maskedEmail'=>masked_email($admin['email']),'message'=>'A new verification code was sent.']);
}

if ($action === 'admin_verify_otp') {
    $otp = preg_replace('/\D/', '', (string)($data['otp'] ?? ''));
    if (empty($_SESSION['pending_admin_id']) || empty($_SESSION['admin_otp_hash'])) json_out(['ok'=>false,'message'=>'Start a new secure sign-in request.'],401);
    if (time() > (int)($_SESSION['admin_otp_expires'] ?? 0)) {
        unset($_SESSION['pending_admin_id'],$_SESSION['admin_otp_hash'],$_SESSION['admin_otp_expires'],$_SESSION['admin_otp_attempts']);
        json_out(['ok'=>false,'message'=>'The verification code has expired. Sign in again.'],401);
    }
    $_SESSION['admin_otp_attempts'] = (int)($_SESSION['admin_otp_attempts'] ?? 0) + 1;
    if ($_SESSION['admin_otp_attempts'] > 5) {
        unset($_SESSION['pending_admin_id'],$_SESSION['admin_otp_hash'],$_SESSION['admin_otp_expires'],$_SESSION['admin_otp_attempts']);
        json_out(['ok'=>false,'message'=>'Too many incorrect attempts. Sign in again.'],429);
    }
    if (strlen($otp) !== 6 || !password_verify($otp, $_SESSION['admin_otp_hash'])) json_out(['ok'=>false,'message'=>'Incorrect verification code.'],401);
    ensure_admin_activity_columns($pdo);
    $statusStmt=$pdo->prepare("SELECT account_status FROM admins WHERE id=?");
    $statusStmt->execute([(int)$_SESSION['pending_admin_id']]);
    if ((string)$statusStmt->fetchColumn() !== 'Active') {
        unset($_SESSION['pending_admin_id'],$_SESSION['admin_otp_hash'],$_SESSION['admin_otp_expires'],$_SESSION['admin_otp_attempts'],$_SESSION['admin_otp_sent_at']);
        json_out(['ok'=>false,'message'=>'This administrator account is disabled. Contact the System Administrator.'],403);
    }
    session_regenerate_id(true);
    unset($_SESSION['patient_id']);
    $_SESSION['admin_id'] = (int)$_SESSION['pending_admin_id'];
    $verifiedAdminId=(int)$_SESSION['pending_admin_id'];
    $stmt=$pdo->prepare("SELECT id,name,email,role,branch FROM admins WHERE id=?");
    $stmt->execute([$verifiedAdminId]);
    $verifiedAdmin=$stmt->fetch();
    if ($verifiedAdmin) {
        touch_admin_activity($pdo,$verifiedAdminId,true,false); audit_event($pdo,$verifiedAdmin,'Authentication','Admin Login','Successful password and OTP sign-in.');
    }

    unset($_SESSION['pending_admin_id'],$_SESSION['admin_otp_hash'],$_SESSION['admin_otp_expires'],$_SESSION['admin_otp_attempts'],$_SESSION['admin_otp_sent_at']);
    json_out(['ok'=>true,'message'=>'Secure sign-in verified.']);
}


if ($action === 'admin_reports_data') {
    $admin = require_admin_context($pdo);

    ensure_appointment_arrival_columns($pdo);
    $appointmentSql = "SELECT a.*, CONCAT(p.first_name,' ',p.last_name) AS patient_name,
                              p.barangay AS patient_barangay
                       FROM appointments a
                       JOIN patients p ON p.id=a.patient_id";
    $appointmentParams = [];
    if (!$admin['is_system_admin']) {
        $appointmentSql .= " WHERE a.center=?";
        $appointmentParams[] = $admin['branch'];
    }
    $appointmentSql .= " ORDER BY a.appointment_date DESC, a.appointment_time DESC, a.id DESC";
    $appointmentStmt = $pdo->prepare($appointmentSql);
    $appointmentStmt->execute($appointmentParams);
    $appointments = $appointmentStmt->fetchAll();

    $patientSql = "SELECT * FROM patients";
    $patientParams = [];
    if (!$admin['is_system_admin']) {
        $patientSql .= " WHERE COALESCE(NULLIF(preferred_rhu,''),'')=?";
        $patientParams[] = $admin['branch'];
    }
    $patientSql .= " ORDER BY id DESC";
    $patientStmt = $pdo->prepare($patientSql);
    $patientStmt->execute($patientParams);
    $patients = $patientStmt->fetchAll();

    json_out([
        'ok' => true,
        'appointments' => array_map(fn($row) => appt_payload($row), $appointments),
        'patients' => array_map('patient_payload', $patients),
        'branch' => $admin['branch'],
        'isSystemAdmin' => (bool)$admin['is_system_admin']
    ]);
}

if ($action === 'admin_data') {
    $admin = require_admin_context($pdo);
    ensure_appointment_arrival_columns($pdo);
    ensure_patient_management_columns($pdo);
    if ($admin['is_system_admin']) {
        $patients=$pdo->query('SELECT * FROM patients ORDER BY id DESC')->fetchAll();
        $appts=$pdo->query('SELECT a.*, CONCAT(p.first_name," ",p.last_name) patient_name FROM appointments a JOIN patients p ON p.id=a.patient_id ORDER BY a.id DESC')->fetchAll();
    } else {
        $stmt=$pdo->prepare("SELECT p.* FROM patients p WHERE p.account_status='Active' AND COALESCE(NULLIF(p.preferred_rhu,''),(SELECT a.center FROM appointments a WHERE a.patient_id=p.id ORDER BY a.appointment_date DESC,a.id DESC LIMIT 1),'')=? ORDER BY p.id DESC");
        $stmt->execute([$admin['branch']]);
        $patients=$stmt->fetchAll();
        $stmt=$pdo->prepare('SELECT a.*, CONCAT(p.first_name," ",p.last_name) patient_name FROM appointments a JOIN patients p ON p.id=a.patient_id WHERE a.center=? ORDER BY a.id DESC');
        $stmt->execute([$admin['branch']]);
        $appts=$stmt->fetchAll();
    }
    json_out(['ok'=>true,'patients'=>array_map('patient_payload',$patients),'appointments'=>array_map(fn($r)=>appt_payload($r),$appts)]);
}

if ($action === 'admin_save_patient') {
    $admin=require_admin_context($pdo);ensure_patient_management_columns($pdo);
    $id=(int)($data['id']??0);$creating=$id<=0;$first=trim((string)($data['firstName']??''));$last=trim((string)($data['lastName']??''));$email=strtolower(trim((string)($data['email']??'')));$phone=trim((string)($data['phone']??''));$birth=trim((string)($data['birthdate']??''));$gender=trim((string)($data['gender']??''));$address=trim((string)($data['address']??''));$barangay=trim((string)($data['barangay']??''));$philhealth=trim((string)($data['philhealthNo']??''));$password=(string)($data['password']??'');$preferred=trim((string)($data['preferredRhu']??''));
    if(!$admin['is_system_admin'])$preferred=$admin['branch'];
    if($first===''||$last===''||!filter_var($email,FILTER_VALIDATE_EMAIL)||$phone===''||$barangay==='')json_out(['ok'=>false,'message'=>'First name, last name, valid email, contact number, and barangay are required.'],422);
    if(!in_array($preferred,allowed_rhu_branches(),true))json_out(['ok'=>false,'message'=>'Please select a valid preferred RHU.'],422);
    if($birth!==''&&!preg_match('/^\d{4}-\d{2}-\d{2}$/',$birth))json_out(['ok'=>false,'message'=>'Please enter a valid birthdate.'],422);
    $duplicate=$pdo->prepare('SELECT id FROM patients WHERE email=? AND id<>?');$duplicate->execute([$email,$id]);if($duplicate->fetchColumn())json_out(['ok'=>false,'message'=>'Another patient already uses this email address.'],409);
    $profile=['preferredRhu'=>$preferred,'bloodType'=>trim((string)($data['bloodType']??'')),'conditions'=>trim((string)($data['conditions']??'')),'medications'=>trim((string)($data['medications']??'')),'pwdType'=>trim((string)($data['pwdType']??''))];
    if($id>0){
      require_patient_record_access($pdo,$id);
      $stmt=$pdo->prepare('SELECT profile_json FROM patients WHERE id=?');$stmt->execute([$id]);$existing=json_decode((string)$stmt->fetchColumn(),true);if(!is_array($existing))$existing=[];$profileJson=json_encode(array_merge($existing,$profile),JSON_UNESCAPED_UNICODE);
      if($password!==''&&strlen($password)<8)json_out(['ok'=>false,'message'=>'A new temporary password must be at least 8 characters.'],422);
      if($password!==''){$sql='UPDATE patients SET first_name=?,last_name=?,email=?,phone=?,birthdate=?,gender=?,address=?,barangay=?,philhealth_no=?,is_senior=?,is_pwd=?,is_4ps=?,preferred_rhu=?,profile_json=?,password_hash=? WHERE id=?';$params=[$first,$last,$email,$phone,$birth?:null,$gender,$address,$barangay,$philhealth,!empty($data['isSenior'])?1:0,!empty($data['isPwd'])?1:0,!empty($data['is4ps'])?1:0,$preferred,$profileJson,password_hash($password,PASSWORD_DEFAULT),$id];}
      else{$sql='UPDATE patients SET first_name=?,last_name=?,email=?,phone=?,birthdate=?,gender=?,address=?,barangay=?,philhealth_no=?,is_senior=?,is_pwd=?,is_4ps=?,preferred_rhu=?,profile_json=? WHERE id=?';$params=[$first,$last,$email,$phone,$birth?:null,$gender,$address,$barangay,$philhealth,!empty($data['isSenior'])?1:0,!empty($data['isPwd'])?1:0,!empty($data['is4ps'])?1:0,$preferred,$profileJson,$id];}
      $pdo->prepare($sql)->execute($params);audit_event($pdo,$admin,'Patients','Updated Patient Record',"Patient ID {$id}; {$preferred}");
    }else{
      if(strlen($password)<8)json_out(['ok'=>false,'message'=>'New patient accounts require a temporary password of at least 8 characters.'],422);
      $profileJson=json_encode($profile,JSON_UNESCAPED_UNICODE);$stmt=$pdo->prepare("INSERT INTO patients(first_name,last_name,email,password_hash,phone,birthdate,gender,address,barangay,philhealth_no,is_senior,is_pwd,is_4ps,preferred_rhu,account_status,profile_json) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,'Active',?)");$stmt->execute([$first,$last,$email,password_hash($password,PASSWORD_DEFAULT),$phone,$birth?:null,$gender,$address,$barangay,$philhealth,!empty($data['isSenior'])?1:0,!empty($data['isPwd'])?1:0,!empty($data['is4ps'])?1:0,$preferred,$profileJson]);$id=(int)$pdo->lastInsertId();$code='USR-'.str_pad($id,3,'0',STR_PAD_LEFT);$pdo->prepare('UPDATE patients SET patient_code=? WHERE id=?')->execute([$code,$id]);audit_event($pdo,$admin,'Patients','Created Patient Record',"Patient ID {$id}; {$preferred}");
    }
    $stmt=$pdo->prepare('SELECT * FROM patients WHERE id=?');$stmt->execute([$id]);json_out(['ok'=>true,'patient'=>patient_payload($stmt->fetch()),'message'=>$creating?'Patient account created.':'Patient record updated.']);
}

if ($action === 'admin_archive_patient') {
    $admin=require_admin_context($pdo,true);ensure_patient_management_columns($pdo);$id=(int)($data['id']??0);
    $active=$pdo->prepare("SELECT COUNT(*) FROM appointments WHERE patient_id=? AND LOWER(status) IN ('pending','confirmed','serving','hold','waiting')");$active->execute([$id]);if((int)$active->fetchColumn()>0)json_out(['ok'=>false,'message'=>'Finish or cancel the patient’s active appointment before archiving the account.'],422);
    $stmt=$pdo->prepare("UPDATE patients SET account_status='Archived',archived_at=NOW() WHERE id=? AND account_status<>'Archived'");$stmt->execute([$id]);if(!$stmt->rowCount())json_out(['ok'=>false,'message'=>'Active patient record not found.'],404);audit_event($pdo,$admin,'Patients','Archived Patient Record',"Patient ID {$id}");json_out(['ok'=>true,'message'=>'Patient account archived. It is now visible on the Archive page.']);
}

if ($action === 'admin_restore_patient') {
    $admin=require_admin_context($pdo,true);ensure_patient_management_columns($pdo);$id=(int)($data['id']??0);$stmt=$pdo->prepare("UPDATE patients SET account_status='Active',archived_at=NULL WHERE id=? AND account_status='Archived'");$stmt->execute([$id]);if(!$stmt->rowCount())json_out(['ok'=>false,'message'=>'Archived patient record not found.'],404);audit_event($pdo,$admin,'Patients','Restored Patient Record',"Patient ID {$id}");json_out(['ok'=>true,'message'=>'Patient account restored.']);
}

if ($action === 'mark_appointment_arrived') {
    $admin = require_admin_context($pdo);
    ensure_appointment_arrival_columns($pdo);
    operations_ensure_tables($pdo);
    $id = (int)($data['id'] ?? 0);
    if (!$id) json_out(['ok'=>false,'message'=>'Missing appointment ID.'],422);
    try {
        $pdo->beginTransaction();
        $sql = "SELECT * FROM appointments WHERE id=?" . ($admin['is_system_admin'] ? "" : " AND center=?") . " LIMIT 1 FOR UPDATE";
        $stmt = $pdo->prepare($sql);
        $params = [$id];
        if (!$admin['is_system_admin']) $params[] = $admin['branch'];
        $stmt->execute($params);
        $appointment = $stmt->fetch();
        if (!$appointment) throw new RuntimeException('Appointment not found or outside your assigned RHU.');
        if ($appointment['appointment_date'] !== date('Y-m-d')) throw new RuntimeException('Only appointments scheduled for today can be marked Arrived.');
        if (strtolower(trim($appointment['status'])) !== 'confirmed') throw new RuntimeException('Only confirmed appointments can be marked Arrived.');
        if (strtolower((string)($appointment['arrival_status'] ?? '')) === 'arrived') throw new RuntimeException('This patient has already checked in.');
        $prefix=($appointment['queue_type']??'regular')==='priority'?'P':'A';
        $liveQueue=operations_issue_queue_number($pdo,$appointment['center'],$appointment['appointment_date'],$prefix);
        $pdo->prepare("UPDATE appointments SET queue_number=?,arrival_status='arrived',arrived_at=NOW(),updated_at=NOW() WHERE id=?")->execute([$liveQueue,$id]);
        $appointment['queue_number']=$liveQueue;
        $appointment['arrival_status']='arrived';
        $pdo->commit();
    } catch (RuntimeException $e) {
        if($pdo->inTransaction())$pdo->rollBack();
        json_out(['ok'=>false,'message'=>$e->getMessage()],422);
    } catch (Throwable $e) {
        if($pdo->inTransaction())$pdo->rollBack();
        throw $e;
    }
    $appointmentReference='APT-'.str_pad((string)$appointment['id'],5,'0',STR_PAD_LEFT);
    $patientFullName=patient_display_name($pdo,$appointment['patient_id']);
    audit_event($pdo,$admin,'Appointments','Checked In Patient',
      "{$patientFullName} checked in for {$appointmentReference} at {$appointment['center']}; live queue {$appointment['queue_number']} created.");
    create_patient_notification($pdo,$appointment['patient_id'],$appointment['id'],'queue','Arrival Confirmed',
      "Check-in complete. Your live queue number is {$appointment['queue_number']}. Please wait for your number to be called.",'queue.html');
    innovation_queue_proximity_alerts($pdo,$appointment['center']);
    json_out(['ok'=>true,'message'=>"Patient checked in. Live queue {$appointment['queue_number']} was created.",'appointment'=>appt_payload($appointment),'queueData'=>queue_branch_payload($pdo)]);
}

if ($action === 'update_appointment_status') {
    $admin = require_admin_context($pdo);
    ensure_appointment_arrival_columns($pdo);

    $id = (int)($data['id'] ?? 0);
    $status = trim((string)($data['status'] ?? 'Confirmed'));
    $allowed = ['Pending','Confirmed','Serving','Done','Cancelled','No Show','Hold'];

    if (!in_array($status,$allowed,true)) {
        json_out(['ok'=>false,'message'=>'Invalid appointment status.'],422);
    }

    $lookupSql='SELECT * FROM appointments WHERE id=?'.($admin['is_system_admin']?'':' AND center=?').' LIMIT 1';
    $lookup=$pdo->prepare($lookupSql);
    $lookupParams=[$id];if(!$admin['is_system_admin'])$lookupParams[]=$admin['branch'];
    $lookup->execute($lookupParams);
    $before=$lookup->fetch();
    if(!$before)json_out(['ok'=>false,'message'=>'Appointment not found or outside your assigned RHU.'],404);

    $timingSql='';
    if($status==='Serving')$timingSql=",service_started_at=COALESCE(service_started_at,NOW())";
    if($status==='Done')$timingSql=",completed_at=NOW()";
    $stmt=$pdo->prepare("UPDATE appointments SET status=?{$timingSql},updated_at=NOW() WHERE id=?");
    $stmt->execute([$status,$id]);

    $stmt = $pdo->prepare('SELECT * FROM appointments WHERE id=?');
    $stmt->execute([$id]);
    $appointment = $stmt->fetch();

    $emailResult = null;

    if ($appointment) {
        [$type,$title,$message] = appointment_notification_copy(
            $status,
            $appointment
        );

        create_patient_notification(
            $pdo,
            $appointment['patient_id'],
            $appointment['id'],
            $type,
            $title,
            $message,
            $status === 'Serving' ? 'queue.html' : ('appointments.html?appointment=' . (int)$appointment['id'])
        );

        $emailResult = send_appointment_email(
            $pdo,
            $appointment,
            $status
        );
        $appointmentReference='APT-'.str_pad((string)$appointment['id'],5,'0',STR_PAD_LEFT);
        $actionName=[
          'Confirmed'=>'Confirmed Appointment',
          'Cancelled'=>'Cancelled Appointment',
          'No Show'=>'Marked Appointment No Show',
          'Serving'=>'Called Appointment',
          'Done'=>'Completed Appointment',
          'Hold'=>'Placed Appointment On Hold'
        ][$status]??'Updated Appointment';
        $actor=(string)($admin['name']??'RHU Staff');
        $verb=[
          'Confirmed'=>'confirmed',
          'Cancelled'=>'cancelled',
          'No Show'=>'marked no-show',
          'Serving'=>'called',
          'Done'=>'completed',
          'Hold'=>'placed on hold'
        ][$status]??'updated';
        $patientFullName=patient_display_name($pdo,$appointment['patient_id']);
        $details="{$actor} {$verb} Appointment {$appointmentReference} for {$patientFullName} on ".date('F j, Y',strtotime($appointment['appointment_date']))." at {$appointment['center']} (previous status: {$before['status']})";
        if(!empty($appointment['queue_number'])&&!str_starts_with((string)$appointment['queue_number'],'APT-'))$details.="; queue {$appointment['queue_number']}";
        audit_event($pdo,$admin,'Appointments',$actionName,$details.'.');

    }

    json_out([
        'ok'=>true,
        'email'=>$emailResult
    ]);
}

function queue_branch_payload($pdo) {
    ensure_appointment_arrival_columns($pdo);
    $branches = ['RHU I - Poblacion','RHU II - Cutcot','RHU III - Tinejero','RHU IV - Tibag'];
    $out = [];
    foreach ($branches as $b) {
        $out[$b] = ['name'=>$b, 'served'=>0, 'waitTimes'=>[], 'averageWait'=>null, 'queue'=>[]];
    }

    $servedStmt = $pdo->query("SELECT center,COUNT(*) c,
      ROUND(AVG(CASE WHEN service_started_at IS NOT NULL AND completed_at IS NOT NULL
        THEN TIMESTAMPDIFF(MINUTE,service_started_at,completed_at) END),1) average_wait
      FROM appointments
      WHERE LOWER(TRIM(status)) IN ('done','completed','attended') AND DATE(COALESCE(completed_at,updated_at))=CURDATE()
      GROUP BY center");
    foreach ($servedStmt->fetchAll() as $r) {
        if (!isset($out[$r['center']])) $out[$r['center']] = ['name'=>$r['center'], 'served'=>0, 'waitTimes'=>[], 'averageWait'=>null, 'queue'=>[]];
        $out[$r['center']]['served'] = (int)$r['c'];
        if ($r['average_wait'] !== null) {
            $out[$r['center']]['averageWait']=(float)$r['average_wait'];
            $out[$r['center']]['waitTimes']=[(float)$r['average_wait']];
        }
    }

    $sql = "SELECT a.*, CONCAT(p.first_name,' ',p.last_name) patient_name
            FROM appointments a
            JOIN patients p ON p.id = a.patient_id
           WHERE a.appointment_date = CURDATE()
             AND (
               LOWER(a.status) IN ('serving','hold','waiting')
               OR (LOWER(a.status)='confirmed' AND LOWER(COALESCE(a.arrival_status,'not_arrived'))='arrived')
             )
           ORDER BY a.center,
  CASE WHEN LOWER(a.status)='serving' THEN 0 ELSE 1 END,
  CASE
    WHEN a.queue_number LIKE 'E-%' THEN 0
    WHEN a.queue_number LIKE 'P-%' THEN 1
    ELSE 2
  END,
  CAST(SUBSTRING(a.queue_number, 3) AS UNSIGNED) ASC";
    $rows = $pdo->query($sql)->fetchAll();
    foreach ($rows as $a) {
        $center = $a['center'];
        if (!isset($out[$center])) $out[$center] = ['name'=>$center, 'served'=>0, 'waitTimes'=>[], 'averageWait'=>null, 'queue'=>[]];
        $out[$center]['queue'][] = [
            'dbId' => (int)$a['id'],
            'num' => $a['queue_number'],
            'name' => trim($a['patient_name']) ?: 'Patient',
            'svc' => $a['service'],
            'type' => ($a['queue_type'] === 'emergency' || strpos((string)$a['queue_number'], 'E-') === 0)
                ? 'emergency'
                : ($a['queue_type'] === 'priority' ? 'priority' : 'regular'),
            'reason' => $a['priority_reason'] ?? '',
            'status' => strtolower($a['status']) === 'serving' ? 'serving' : 'waiting',
            'rawStatus' => $a['status'],
            'date' => $a['appointment_date'],
            'time' => $a['appointment_time'],
            'addedAt' => strtotime($a['created_at'] ?? 'now') * 1000,
        ];
    }
    return $out;
}

if ($action === 'tv_queue_data') {

    // email setup
    $allowedBranches = [
        'RHU I - Poblacion',
        'RHU II - Cutcot',
        'RHU III - Tinejero',
        'RHU IV - Tibag'
    ];
    $branch = trim((string)($_GET['branch'] ?? $data['branch'] ?? $allowedBranches[0]));
    if (!in_array($branch, $allowedBranches, true)) {
        json_out(['ok'=>false,'message'=>'Invalid RHU branch.'],422);
    }

    $allQueueData = queue_branch_payload($pdo);
    $branchData = $allQueueData[$branch] ?? ['name'=>$branch,'served'=>0,'queue'=>[]];
    $serving = null;
    $waiting = [];

    foreach (($branchData['queue'] ?? []) as $item) {
        $safeItem = [
            'queue_number'=>(string)($item['num'] ?? '-'),
            'service'=>(string)($item['svc'] ?? '-'),
            'lane'=>in_array(($item['type'] ?? 'regular'), ['regular','priority','emergency'], true)
                ? $item['type']
                : 'regular',
            'status'=>($item['status'] ?? '') === 'serving' ? 'serving' : 'waiting'
        ];
        if ($safeItem['status'] === 'serving' && $serving === null) {
            $serving = $safeItem;
        } else {
            $waiting[] = $safeItem;
        }
    }

    json_out([
        'ok'=>true,
        'branch'=>$branch,
        'branches'=>$allowedBranches,
        'now_serving'=>$serving,
        'next_in_line'=>$waiting[0] ?? null,
        'waiting'=>array_slice($waiting, 0, 3),
        'waiting_count'=>count($waiting),
        'served_today'=>(int)($branchData['served'] ?? 0),
        'updated_at'=>date('c')
    ]);
}

if ($action === 'admin_audit_logs') {
    $admin=require_admin_context($pdo);
    $pdo->exec("CREATE TABLE IF NOT EXISTS audit_logs (id INT AUTO_INCREMENT PRIMARY KEY, user_type VARCHAR(30) NOT NULL DEFAULT 'admin', user_name VARCHAR(150) NOT NULL DEFAULT 'Administrator', email VARCHAR(150) NULL, role VARCHAR(100) NULL, branch VARCHAR(150) NULL, module VARCHAR(100) NULL, action VARCHAR(150) NOT NULL DEFAULT 'Action', details TEXT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    ensure_audit_columns($pdo);
    if($admin['is_system_admin']){
      $rows=$pdo->query("SELECT user_name AS user, COALESCE(email,'') email, COALESCE(role,user_type,'') role, COALESCE(branch,'') branch, COALESCE(module,'System') module, action, COALESCE(details,'') details, created_at AS ts FROM audit_logs ORDER BY id DESC")->fetchAll();
    }else{
      $stmt=$pdo->prepare("SELECT user_name AS user, COALESCE(email,'') email, COALESCE(role,user_type,'') role, COALESCE(branch,'') branch, COALESCE(module,'System') module, action, COALESCE(details,'') details, created_at AS ts FROM audit_logs WHERE email=? ORDER BY id DESC");
      $stmt->execute([$admin['email']]);$rows=$stmt->fetchAll();
    }
    json_out(['ok'=>true,'logs'=>$rows]);
}

if ($action === 'admin_audit_clear') {
    $admin=require_admin_context($pdo, true);
    $pdo->exec("CREATE TABLE IF NOT EXISTS audit_logs (id INT AUTO_INCREMENT PRIMARY KEY, user_type VARCHAR(30) NOT NULL DEFAULT 'admin', user_name VARCHAR(150) NOT NULL DEFAULT 'Administrator', email VARCHAR(150) NULL, role VARCHAR(100) NULL, branch VARCHAR(150) NULL, module VARCHAR(100) NULL, action VARCHAR(150) NOT NULL DEFAULT 'Action', details TEXT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    ensure_audit_columns($pdo);
    $pdo->exec("DELETE FROM audit_logs");
    json_out(['ok'=>true]);
}

if ($action === 'admin_system_users') {
    $admin=require_admin_context($pdo, true);

    $legacyEmails = [
      'ashleyamira955@gmail.com',
      'ashleyamira955+rhu1@gmail.com',
      'ashleyamira955+rhu2@gmail.com',
      'ashleyamira955+rhu3@gmail.com',
      'ashleyamira955+rhu4@gmail.com',
      'admin@healthcenter.local'
    ];
    $marks=implode(',',array_fill(0,count($legacyEmails),'?'));
    $cleanup=$pdo->prepare("DELETE FROM admins WHERE email IN ($marks) AND id<>?");
    $cleanup->execute(array_merge($legacyEmails,[(int)$_SESSION['admin_id']]));
    if ($cleanup->rowCount()>0) {
        audit_event($pdo,$admin,'Users & Staff','Removed Legacy Demo Accounts',
          $cleanup->rowCount().' duplicate/demo account(s) removed.');
    }

    ensure_admin_activity_columns($pdo); $admins=$pdo->query("SELECT id,name,email,role,branch,account_status,created_at,last_login_at,last_activity_at,last_logout_at,last_ip,last_user_agent, CASE WHEN account_status='Active' AND last_activity_at IS NOT NULL AND last_activity_at >= (NOW() - INTERVAL 10 MINUTE) AND (last_logout_at IS NULL OR last_activity_at > last_logout_at) THEN 1 ELSE 0 END AS online FROM admins ORDER BY id DESC")->fetchAll();
    json_out(['ok'=>true,'users'=>$admins]);
}

if ($action === 'admin_save_system_user') {
    $admin=require_admin_context($pdo, true);
    ensure_admin_activity_columns($pdo);
    $id=(int)($data['id']??0); $name=trim($data['name']??''); $email=strtolower(trim($data['email']??'')); $role=trim($data['role']??'RHU Staff'); $branch=trim($data['branch']??'All Branches'); $pass=(string)($data['password']??'');
    if (!$name || !filter_var($email,FILTER_VALIDATE_EMAIL)) json_out(['ok'=>false,'message'=>'Name and valid email are required.'],422);
    if ($id>0) {
        if ($pass) { $hash=password_hash($pass,PASSWORD_DEFAULT); $stmt=$pdo->prepare('UPDATE admins SET name=?, email=?, role=?, branch=?, password_hash=? WHERE id=?'); $stmt->execute([$name,$email,$role,$branch,$hash,$id]); }
        else { $stmt=$pdo->prepare('UPDATE admins SET name=?, email=?, role=?, branch=? WHERE id=?'); $stmt->execute([$name,$email,$role,$branch,$id]); }
    } else {
        if (strlen($pass)<8) json_out(['ok'=>false,'message'=>'New accounts require a password of at least 8 characters.'],422);
        $hash=password_hash($pass,PASSWORD_DEFAULT);
        $stmt=$pdo->prepare('INSERT INTO admins(name,email,role,branch,password_hash) VALUES(?,?,?,?,?)'); $stmt->execute([$name,$email,$role,$branch,$hash]);
    }
    audit_event($pdo,$admin,'Users & Staff',$id>0?'Updated System User':'Created System User',"{$name} ({$email})");
    json_out(['ok'=>true]);
}

if ($action === 'admin_set_system_user_status') {
    $admin=require_admin_context($pdo, true);
    ensure_admin_activity_columns($pdo);
    $id=(int)($data['id']??0);
    $status=ucfirst(strtolower(trim((string)($data['status']??''))));
    if (!in_array($status,['Active','Disabled'],true)) json_out(['ok'=>false,'message'=>'Choose Active or Disabled status.'],422);
    if ($id === (int)$_SESSION['admin_id'] && $status === 'Disabled') json_out(['ok'=>false,'message'=>'You cannot disable your own signed-in account.'],422);
    $stmt=$pdo->prepare('SELECT id,name,email,role,account_status FROM admins WHERE id=?');
    $stmt->execute([$id]);
    $target=$stmt->fetch();
    if (!$target) json_out(['ok'=>false,'message'=>'Administrator or staff account not found.'],404);
    $targetRole=strtolower((string)$target['role']);
    $isTargetAdmin=strpos($targetRole,'admin')!==false || strpos($targetRole,'system')!==false || strpos($targetRole,'super')!==false;
    if ($status === 'Disabled' && $isTargetAdmin) {
        $count=(int)$pdo->query("SELECT COUNT(*) FROM admins WHERE account_status='Active' AND (LOWER(role) LIKE '%admin%' OR LOWER(role) LIKE '%system%' OR LOWER(role) LIKE '%super%')")->fetchColumn();
        if ($count<=1) json_out(['ok'=>false,'message'=>'The final active System Administrator account cannot be disabled.'],422);
    }
    $pdo->prepare('UPDATE admins SET account_status=? WHERE id=?')->execute([$status,$id]);
    audit_event($pdo,$admin,'Users & Staff',$status==='Active'?'Enabled System User':'Disabled System User',$target['name'].' ('.$target['email'].')');
    json_out(['ok'=>true,'message'=>$status==='Active'?'Account enabled.':'Account disabled and future sign-ins are blocked.']);
}

if ($action === 'admin_delete_system_user') {
    $admin=require_admin_context($pdo, true);
    $id=(int)($data['id']??0);
    if ($id === (int)$_SESSION['admin_id']) json_out(['ok'=>false,'message'=>'You cannot delete your own account.'],422);
    $roleStmt=$pdo->prepare("SELECT role FROM admins WHERE id=?");
    $roleStmt->execute([$id]);
    $targetRole=(string)$roleStmt->fetchColumn();
    if (stripos($targetRole,'administrator')!==false || stripos($targetRole,'admin')!==false) {
        ensure_admin_activity_columns($pdo);
        $adminCount=(int)$pdo->query("SELECT COUNT(*) FROM admins WHERE account_status='Active' AND (LOWER(role) LIKE '%admin%' OR LOWER(role) LIKE '%administrator%' OR LOWER(role) LIKE '%system%' OR LOWER(role) LIKE '%super%')")->fetchColumn();
        if ($adminCount<=1) json_out(['ok'=>false,'message'=>'The final System Administrator account cannot be deleted.'],422);
    }
    $stmt=$pdo->prepare('SELECT name,email FROM admins WHERE id=?'); $stmt->execute([$id]); $deletedUser=$stmt->fetch();
    $pdo->prepare('DELETE FROM admins WHERE id=?')->execute([$id]);
    audit_event($pdo,$admin,'Users & Staff','Deleted System User',$deletedUser ? ($deletedUser['name'].' ('.$deletedUser['email'].')') : "User ID {$id}");
    json_out(['ok'=>true]);
}

if ($action === 'admin_restore_archived_appointment') {
    $admin=require_admin_context($pdo, true);
    $id=(int)($data['id']??0);
    $stmt=$pdo->prepare("UPDATE appointments SET status='Confirmed' WHERE id=? AND LOWER(status) IN ('done','completed','cancelled','no show')");
    $stmt->execute([$id]);
    if (!$stmt->rowCount()) json_out(['ok'=>false,'message'=>'Archived appointment was not found.'],404); audit_event($pdo,$admin,'Archive','Restored Appointment','Appointment ID '.$id); json_out(['ok'=>true,'message'=>'Appointment restored as Confirmed.']);
}

if ($action === 'admin_delete_archived_appointment') {
    require_admin_context($pdo, true);
    json_out([
        'ok'=>false,
        'message'=>'Permanent deletion of archived patient and appointment records is disabled. Restore the record when operational access is needed.'
    ],403);
}

if ($action === 'queue_data') {
    $admin = require_admin_context($pdo);
    $queueData = queue_branch_payload($pdo);
    if (!$admin['is_system_admin']) {
        $branch = $admin['branch'];
        $queueData = isset($queueData[$branch]) ? [$branch => $queueData[$branch]] : [];
    }
    json_out(['ok'=>true, 'queueData'=>$queueData]);
}

if ($action === 'patient_queue_data') {
    if (empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);

    $stmt=$pdo->prepare("
        SELECT a.*, CONCAT(p.first_name,' ',p.last_name) patient_name
        FROM appointments a
        JOIN patients p ON p.id=a.patient_id
        WHERE a.patient_id=?
          AND LOWER(a.status) IN ('pending','confirmed','serving','hold','waiting')
        ORDER BY a.appointment_date ASC, a.appointment_time ASC, a.id DESC
        LIMIT 1
    ");
    $stmt->execute([$_SESSION['patient_id']]);
    $appt=$stmt->fetch();

    json_out([
        'ok'=>true,
        'queueData'=>queue_branch_payload($pdo),
        'appointment'=>$appt ? appt_payload($appt, trim($appt['patient_name'] ?? '')) : null
    ]);
}

if ($action === 'admin_create_walkin') {
    $admin = require_admin_context($pdo);
    operations_ensure_tables($pdo);
    ensure_appointment_arrival_columns($pdo);
    $name = trim($data['name'] ?? '');
    $service = trim($data['service'] ?? '');
    $center = trim($data['center'] ?? '');
    require_staff_branch($admin, $center);
    $queueType = trim($data['queueType'] ?? 'regular');
    $reason = trim((string)($data['reason'] ?? ''));
    $phone = trim((string)($data['phone'] ?? ''));
    if (!$name || !$service || !$center) json_out(['ok'=>false,'message'=>'Name, service, and RHU branch are required.'],422);
    if (!in_array($queueType, ['regular','priority','emergency'], true)) $queueType = 'regular';
    if ($queueType==='emergency' && mb_strlen($reason)<5) json_out(['ok'=>false,'message'=>'Enter the emergency reason or presenting concern before adding the patient.'],422);
    if ($queueType==='priority' && mb_strlen($reason)<3) json_out(['ok'=>false,'message'=>'Enter the priority reason, such as Senior Citizen, PWD, or Pregnant.'],422);
    $parts = preg_split('/\s+/', $name, 2);
    $first = trim($parts[0] ?? 'Walk-in') ?: 'Walk-in';
    $last = trim($parts[1] ?? 'Patient') ?: 'Patient';
    $email = 'walkin+' . date('YmdHis') . bin2hex(random_bytes(2)) . '@local.healthcenter';
    $hash = password_hash(bin2hex(random_bytes(16)), PASSWORD_DEFAULT);
    $prefix = $queueType === 'emergency' ? 'E' : ($queueType === 'priority' ? 'P' : 'A');
    try {
        $pdo->beginTransaction();
        $stmt = $pdo->prepare('INSERT INTO patients(first_name,last_name,email,password_hash,phone,preferred_rhu) VALUES(?,?,?,?,?,?)');
        $stmt->execute([$first,$last,$email,$hash,$phone?:null,$center]);
        $patientId = (int)$pdo->lastInsertId();
        $code = 'USR-' . str_pad($patientId, 3, '0', STR_PAD_LEFT);
        $pdo->prepare('UPDATE patients SET patient_code=? WHERE id=?')->execute([$code,$patientId]);
        $queueNo=operations_issue_queue_number($pdo,$center,date('Y-m-d'),$prefix);
        $walkinReason=$reason!==''?$reason:($queueType==='regular'?'Walk-in patient':'Priority walk-in');
        $stmt = $pdo->prepare('INSERT INTO appointments(patient_id,queue_number,center,service,appointment_date,appointment_time,queue_type,priority_reason,status,arrival_status,arrived_at) VALUES(?,?,?,?,CURDATE(),?,?,?,?,?,NOW())');
        $stmt->execute([$patientId,$queueNo,$center,$service,date('H:i'),$queueType,$walkinReason,'Confirmed','arrived']);
        $appointmentId = (int)$pdo->lastInsertId();
        $pdo->commit();
    } catch (Throwable $e) {
        if($pdo->inTransaction())$pdo->rollBack();
        throw $e;
    }
    $fetch = $pdo->prepare('SELECT * FROM appointments WHERE id=?');
    $fetch->execute([$appointmentId]);
    $appointment = $fetch->fetch();

    $emailResult = null;

    if ($appointment) {
        [$type,$title,$message] = appointment_notification_copy(
            'Confirmed',
            $appointment
        );

        create_patient_notification(
            $pdo,
            $appointment['patient_id'],
            $appointment['id'],
            $type,
            $title,
            $message,
            'appointments.html?appointment=' . (int)$appointment['id']
        );

        $emailResult = send_appointment_email(
            $pdo,
            $appointment,
            'Confirmed'
        );
    }
    $actionName=$queueType==='emergency'?'Added Emergency Walk-in':'Added Walk-in';
    $details=(string)($admin['name']??'RHU Staff')." added {$name} as ".($queueType==='emergency'?'an emergency':'a walk-in')." patient to Queue {$queueNo} at {$center}; service {$service}";
    if($reason!=='')$details.="; reason: {$reason}";
    audit_event($pdo,$admin,'Queue Management',$actionName,$details.'.');
    innovation_queue_proximity_alerts($pdo,$center);

    json_out([
        'ok'=>true,
        'message'=>$queueType==='emergency'
          ?"Emergency case recorded as {$queueNo}. Emergency cases are prioritised for immediate assessment."
          :"Walk-in patient added as {$queueNo}.",
        'queueNumber'=>$queueNo,
        'queueData'=>queue_branch_payload($pdo),
        'email'=>$emailResult
    ]);
}

if ($action === 'queue_action') {
    $admin = require_admin_context($pdo);
    ensure_appointment_arrival_columns($pdo);
    $type = trim($data['type'] ?? '');
    $center = trim($data['center'] ?? '');
    $queue = trim($data['queue'] ?? '');
    if (!$type || !$center) json_out(['ok'=>false,'message'=>'Missing queue action data.'],422);
    require_staff_branch($admin, $center);

    if ($type === 'call_next') {
        $appointment=null;$emailResult=null;$newlyCalled=false;
        try {
            $pdo->beginTransaction();
            $cur=$pdo->prepare("SELECT * FROM appointments WHERE center=? AND LOWER(status)='serving' LIMIT 1 FOR UPDATE");
            $cur->execute([$center]);$current=$cur->fetch();
            $emergency=$pdo->prepare("SELECT * FROM appointments WHERE center=? AND appointment_date=CURDATE() AND (queue_type='emergency' OR queue_number LIKE 'E-%') AND (LOWER(status) IN ('hold','waiting') OR (LOWER(status)='confirmed' AND LOWER(COALESCE(arrival_status,'not_arrived'))='arrived')) ORDER BY CAST(SUBSTRING(queue_number,3) AS UNSIGNED) ASC LIMIT 1 FOR UPDATE");
            $emergency->execute([$center]);$urgent=$emergency->fetch();
            if($urgent && (!$current || (($current['queue_type'] ?? 'regular')!=='emergency' && strpos((string)($current['queue_number'] ?? ''),'E-')!==0))){
                if($current){$pdo->prepare("UPDATE appointments SET status='Hold',updated_at=NOW() WHERE id=?")->execute([(int)$current['id']]);}
                $update=$pdo->prepare("UPDATE appointments SET status='Serving',service_started_at=COALESCE(service_started_at,NOW()),updated_at=NOW() WHERE id=?");$update->execute([(int)$urgent['id']]);
                $appointment=$urgent;$appointment['status']='Serving';$newlyCalled=true;
            } elseif($current) {
                $appointment=$current;
            } else {
                $next=$pdo->prepare("SELECT * FROM appointments WHERE center=? AND appointment_date=CURDATE() AND (LOWER(status) IN ('hold','waiting') OR (LOWER(status)='confirmed' AND LOWER(COALESCE(arrival_status,'not_arrived'))='arrived')) ORDER BY CASE WHEN queue_number LIKE 'E-%' THEN 0 WHEN queue_number LIKE 'P-%' THEN 1 ELSE 2 END, CAST(SUBSTRING(queue_number,3) AS UNSIGNED) ASC LIMIT 1 FOR UPDATE");
                $next->execute([$center]);$appointment=$next->fetch();
                if(!$appointment)throw new RuntimeException('__NO_WAITING_PATIENT__');
                $update=$pdo->prepare("UPDATE appointments SET status='Serving',service_started_at=COALESCE(service_started_at,NOW()),updated_at=NOW() WHERE id=? AND LOWER(status)<>'serving'");$update->execute([(int)$appointment['id']]);
                if(!$update->rowCount())throw new RuntimeException('Another staff session already updated this queue. Refresh and try again.');
                $appointment['status']='Serving';$newlyCalled=true;
            }
            $pdo->commit();
        } catch (RuntimeException $e) {
            if($pdo->inTransaction())$pdo->rollBack();
            if($e->getMessage()==='__NO_WAITING_PATIENT__')json_out(['ok'=>false,'message'=>'No waiting patient in this branch.'],404);
            json_out(['ok'=>false,'message'=>$e->getMessage()],409);
        } catch (Throwable $e) {
            if($pdo->inTransaction())$pdo->rollBack();throw $e;
        }
        if($newlyCalled&&$appointment){
            [$ntype,$ntitle,$nmessage]=appointment_notification_copy('Serving',$appointment);
            create_patient_notification($pdo,$appointment['patient_id'],$appointment['id'],$ntype,$ntitle,$nmessage,'queue.html');
            $emailResult=send_appointment_email($pdo,$appointment,'Serving');
        }

        innovation_queue_proximity_alerts($pdo,$center);
        $calledQueue=(string)($appointment['queue_number']??'');
        $isEmergency=($appointment['queue_type']??'')==='emergency'||str_starts_with($calledQueue,'E-');
        $patientFullName=patient_display_name($pdo,$appointment['patient_id']);
        audit_event($pdo,$admin,'Queue Management',$isEmergency?'Called Emergency Queue':'Called Next Queue',
          "Queue {$calledQueue} for {$patientFullName} called at {$center}; service ".($appointment['service']??'Not specified').($isEmergency?'; emergency priority applied.':'.'));

        json_out([
            'ok'=>true,
            'queueData'=>queue_branch_payload($pdo),
            'calledAppointment'=>$appointment ? appt_payload($appointment) : null,
            'email'=>$emailResult ?? null
        ]);
    }

    if ($type === 'call_specific') {
        if (!$queue) json_out(['ok'=>false,'message'=>'Missing queue number.'],422);
        $pdo->prepare("UPDATE appointments SET status='Confirmed', updated_at=NOW() WHERE center=? AND LOWER(status)='serving'")->execute([$center]);
        $stmt=$pdo->prepare("UPDATE appointments SET status='Serving',service_started_at=COALESCE(service_started_at,NOW()),updated_at=NOW() WHERE center=? AND queue_number=? AND appointment_date=CURDATE() AND (LOWER(status) IN ('hold','waiting') OR (LOWER(status)='confirmed' AND LOWER(COALESCE(arrival_status,'not_arrived'))='arrived'))");
        $stmt->execute([$center,$queue]);
        $fetch=$pdo->prepare("SELECT * FROM appointments WHERE center=? AND queue_number=? LIMIT 1");
        $fetch->execute([$center,$queue]);
        $appointment=$fetch->fetch();
        $emailResult = null;

        if ($appointment) {
            [$ntype,$ntitle,$nmessage] = appointment_notification_copy(
                'Serving',
                $appointment
            );

            create_patient_notification(
                $pdo,
                $appointment['patient_id'],
                $appointment['id'],
                $ntype,
                $ntitle,
                $nmessage,
                'queue.html'
            );

            $emailResult = send_appointment_email(
                $pdo,
                $appointment,
                'Serving'
            );
        }

        innovation_queue_proximity_alerts($pdo,$center);
        $patientFullName=$appointment?patient_display_name($pdo,$appointment['patient_id']):'Patient';
        audit_event($pdo,$admin,'Queue Management','Called Specific Queue',"Queue {$queue} for {$patientFullName} called at {$center}; service ".($appointment['service']??'Not specified').'.');

        json_out([
            'ok'=>true,
            'queueData'=>queue_branch_payload($pdo),
            'calledAppointment'=>$appointment ? appt_payload($appointment) : null,
            'email'=>$emailResult
        ]);
    }

    if ($type === 'done' || $type === 'no_show' || $type === 'hold' || $type === 'remove') {
        $map = ['done'=>'Done', 'no_show'=>'No Show', 'hold'=>'Hold', 'remove'=>'Cancelled'];
        $status = $map[$type];
        if ($queue) {
            $timing=$type==='done'?",completed_at=NOW()":'';
            $stmt=$pdo->prepare("UPDATE appointments SET status=?{$timing},updated_at=NOW() WHERE center=? AND queue_number=?");
            $stmt->execute([$status,$center,$queue]);
            $fetch=$pdo->prepare("SELECT * FROM appointments WHERE center=? AND queue_number=? LIMIT 1");
            $fetch->execute([$center,$queue]);
        } else {
            $fetch=$pdo->prepare("SELECT * FROM appointments WHERE center=? AND LOWER(status)='serving' LIMIT 1");
            $fetch->execute([$center]);
            $appointmentBefore=$fetch->fetch();
            $timing=$type==='done'?",completed_at=NOW()":'';
            $stmt=$pdo->prepare("UPDATE appointments SET status=?{$timing},updated_at=NOW() WHERE center=? AND LOWER(status)='serving'");
            $stmt->execute([$status,$center]);
            $fetch=null;
        }
        $appointment = isset($appointmentBefore) ? $appointmentBefore : ($fetch ? $fetch->fetch() : null);
        $emailResult = null;

        if ($appointment) {
            [$ntype,$ntitle,$nmessage] = appointment_notification_copy(
                $status,
                $appointment
            );

            create_patient_notification(
                $pdo,
                $appointment['patient_id'],
                $appointment['id'],
                $ntype,
                $ntitle,
                $nmessage,
                'appointments.html'
            );

            $emailResult = send_appointment_email(
                $pdo,
                $appointment,
                $status
            );
        }

        innovation_queue_proximity_alerts($pdo,$center);
        $eventAction=['done'=>'Completed Queue','no_show'=>'Marked Queue No Show','hold'=>'Placed Queue On Hold','remove'=>'Removed Queue'][$type];
        $actualQueue=$queue?:($appointment['queue_number']??'current queue');
        $patientFullName=$appointment?patient_display_name($pdo,$appointment['patient_id']):'Patient';
        audit_event($pdo,$admin,'Queue Management',$eventAction,"Queue {$actualQueue} for {$patientFullName} at {$center} changed to {$status}.");

        json_out([
            'ok'=>true,
            'queueData'=>queue_branch_payload($pdo),
            'email'=>$emailResult
        ]);
    }

    if ($type === 'reset') {
        $stmt=$pdo->prepare("UPDATE appointments SET status='No Show', updated_at=NOW() WHERE center=? AND LOWER(status) IN ('confirmed','serving','hold','waiting')");
        $stmt->execute([$center]);
        audit_event($pdo,$admin,'Queue Management','Reset Daily Queue',"All active queues at {$center} were marked No Show.");
        json_out(['ok'=>true,'queueData'=>queue_branch_payload($pdo)]);
    }

    json_out(['ok'=>false,'message'=>'Unknown queue action.'],422);
}

if ($action === 'chat_messages') {
    if (empty($_SESSION['patient_id']) && empty($_SESSION['admin_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    $requestedPatientId = (int)($data['patient_id'] ?? $_GET['patient_id'] ?? 0);
    $isAdminRequest = !empty($_SESSION['admin_id']) && $requestedPatientId > 0;
    $patientId = $isAdminRequest
        ? $requestedPatientId
        : (!empty($_SESSION['patient_id']) ? (int)$_SESSION['patient_id'] : $requestedPatientId);
    if (empty($_SESSION['patient_id']) && !$isAdminRequest && $patientId <= 0) {
        json_out(['ok'=>false,'message'=>'Choose a patient conversation first.'],422);
    }
    if ($patientId <= 0) json_out(['ok'=>false,'message'=>'No patient conversation found.'],404);
    ensure_chat_thread_status_table($pdo);
    ensure_help_chat_automation($pdo);
    if ($isAdminRequest) require_admin_patient_access($pdo,$patientId);
    $rhuBranch=chat_thread_branch($pdo,$patientId);
    $stmt = $pdo->prepare("SELECT cm.*, CONCAT(p.first_name,' ',p.last_name) patient_name, a.name admin_name
                           FROM chat_messages cm
                           JOIN patients p ON p.id=cm.patient_id
                           LEFT JOIN admins a ON a.id=cm.admin_id
                           WHERE cm.patient_id=? ORDER BY cm.id ASC LIMIT 200");
    $stmt->execute([$patientId]);
    $messages = [];
    foreach ($stmt->fetchAll() as $m) {
        $messages[] = [
            'id'=>(int)$m['id'],
            'patient_id'=>(int)$m['patient_id'],
            'sender_type'=>$m['sender_type'],
            'is_automated'=>(int)($m['is_automated']??0),
            'message'=>$m['message'],
            'name'=>!empty($m['is_automated']) ? 'Automated Help Reply' : ($m['sender_type']==='admin' ? ($m['admin_name'] ?: 'RHU Staff') : ($m['patient_name'] ?: 'Patient')),
            'created_at'=>$m['created_at']
        ];
    }
    if ($isAdminRequest) {
        $pdo->prepare("UPDATE chat_messages SET is_read=1 WHERE patient_id=? AND sender_type='patient'")->execute([$patientId]);
    } else {
        $pdo->prepare("UPDATE chat_messages SET is_read=1 WHERE patient_id=? AND sender_type='admin'")->execute([$patientId]);
    }
    json_out(['ok'=>true,'patient_id'=>$patientId,'rhu_branch'=>$rhuBranch,'branches'=>allowed_rhu_branches(),'messages'=>$messages]);
}

if ($action === 'chat_send') {
    if (empty($_SESSION['patient_id']) && empty($_SESSION['admin_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    $message = trim((string)($data['message'] ?? ''));
    if ($message === '') json_out(['ok'=>false,'message'=>'Message is required.'],422);
    if (mb_strlen($message) > 1000) $message = mb_substr($message, 0, 1000);
    ensure_chat_thread_status_table($pdo);
    ensure_help_chat_automation($pdo);
    $requestedPatientId = (int)($data['patient_id'] ?? $_GET['patient_id'] ?? 0);
    $isAdminRequest = !empty($_SESSION['admin_id']) && $requestedPatientId > 0;
    if ($isAdminRequest) {
        $patientId = $requestedPatientId;
        if ($patientId <= 0) json_out(['ok'=>false,'message'=>'Choose a patient conversation first.'],422);
        require_admin_patient_access($pdo,$patientId);
        $adminId = (int)$_SESSION['admin_id'];
        $sender = 'admin';
        $rhuBranch = chat_thread_branch($pdo,$patientId);
    } elseif (!empty($_SESSION['patient_id'])) {
        $patientId = (int)$_SESSION['patient_id'];
        $adminId = null;
        $sender = 'patient';
        $requestedBranch=trim((string)($data['rhu_branch']??$_GET['rhu_branch']??''));
        $rhuBranch=$requestedBranch!==''?$requestedBranch:chat_thread_branch($pdo,$patientId);
        if (!in_array($rhuBranch,allowed_rhu_branches(),true)) {
            json_out(['ok'=>false,'message'=>'Please select a valid RHU branch.'],422);
        }
    } else {
        json_out(['ok'=>false,'message'=>'Choose a patient conversation first.'],422);
    }
    $exists = $pdo->prepare('SELECT id FROM patients WHERE id=?');
    $exists->execute([$patientId]);
    if (!$exists->fetch()) json_out(['ok'=>false,'message'=>'Patient conversation not found.'],404);
    $stmt = $pdo->prepare('INSERT INTO chat_messages(patient_id,admin_id,sender_type,message) VALUES(?,?,?,?)');
    $stmt->execute([$patientId,$adminId,$sender,$message]);
    $messageId=(int)$pdo->lastInsertId();
    if ($sender==='patient') {
        $pdo->prepare("INSERT INTO chat_thread_status(patient_id,status,rhu_branch,assigned_admin_id) VALUES(?,'Open',?,NULL)
          ON DUPLICATE KEY UPDATE status='Open',rhu_branch=VALUES(rhu_branch),assigned_admin_id=NULL,updated_at=NOW()")
          ->execute([$patientId,$rhuBranch]);
        $automaticReply=help_chat_automatic_reply($pdo,$message,$rhuBranch,$patientId);
        $auto=$pdo->prepare("INSERT INTO chat_messages(patient_id,admin_id,sender_type,message,is_automated) VALUES(?,NULL,'admin',?,1)");
        $auto->execute([$patientId,$automaticReply]);
    } else {
        $pdo->prepare("INSERT INTO chat_thread_status(patient_id,status,rhu_branch,assigned_admin_id) VALUES(?,'Waiting for Patient',?,?)
          ON DUPLICATE KEY UPDATE status='Waiting for Patient',rhu_branch=VALUES(rhu_branch),assigned_admin_id=VALUES(assigned_admin_id),updated_at=NOW()")
          ->execute([$patientId,$rhuBranch,$adminId]);
        create_patient_notification($pdo,$patientId,null,'info','New Reply to Your Inquiry',
          'Pulilan Health Center staff replied to your message.','messages.html?from=notification&conversation='.$patientId,
          'inquiry-reply:'.$messageId);
        $admin=require_admin_context($pdo);
        audit_event($pdo,$admin,'Patient Inquiries','Replied to Patient Inquiry',"Patient ID {$patientId}; {$rhuBranch}");
    }
    json_out(['ok'=>true,'id'=>$messageId,'rhu_branch'=>$rhuBranch,'automatic_reply'=>$sender==='patient']);
}

if ($action === 'chat_threads') {
    try {
        $admin=require_admin_context($pdo);
        ensure_chat_thread_status_table($pdo);
        $patientIds=$pdo->query("SELECT DISTINCT patient_id FROM chat_messages WHERE patient_id IS NOT NULL AND patient_id>0 ORDER BY patient_id DESC")->fetchAll(PDO::FETCH_COLUMN);
        $patientStmt=$pdo->prepare("SELECT id,CONCAT(COALESCE(first_name,''),' ',COALESCE(last_name,'')) patient_name,email FROM patients WHERE id=? LIMIT 1");
        $lastStmt=$pdo->prepare("SELECT message,created_at FROM chat_messages WHERE patient_id=? AND COALESCE(is_automated,0)=0 ORDER BY id DESC LIMIT 1");
        $unreadStmt=$pdo->prepare("SELECT COUNT(*) FROM chat_messages WHERE patient_id=? AND sender_type='patient' AND COALESCE(is_read,0)=0");
        $statusStmt=$pdo->prepare("SELECT status,rhu_branch,assigned_admin_id FROM chat_thread_status WHERE patient_id=? LIMIT 1");
        $adminNameStmt=$pdo->prepare("SELECT name FROM admins WHERE id=? LIMIT 1");
        $threads=[];
        foreach($patientIds as $patientIdRaw){
            $patientId=(int)$patientIdRaw;
            $patientStmt->execute([$patientId]);
            $patient=$patientStmt->fetch();
            if(!$patient) continue;
            $branch=chat_thread_branch($pdo,$patientId);
            if(!$admin['is_system_admin'] && trim($branch)!==trim((string)$admin['branch'])) continue;
            $lastStmt->execute([$patientId]);
            $last=$lastStmt->fetch()?:[];
            $unreadStmt->execute([$patientId]);
            $unread=(int)$unreadStmt->fetchColumn();
            $statusStmt->execute([$patientId]);
            $statusRow=$statusStmt->fetch()?:[];
            $assignedId=!empty($statusRow['assigned_admin_id'])?(int)$statusRow['assigned_admin_id']:null;
            $assignedName='';
            if($assignedId){$adminNameStmt->execute([$assignedId]);$assignedName=(string)($adminNameStmt->fetchColumn()?:'');}
            $threads[]=[
                'patient_id'=>$patientId,
                'patient_name'=>trim((string)($patient['patient_name']??''))?:'Patient',
                'email'=>(string)($patient['email']??''),
                'last_at'=>$last['created_at']??null,
                'last_message'=>(string)($last['message']??''),
                'unread'=>$unread,
                'status'=>(string)($statusRow['status']??'Open'),
                'rhu_branch'=>$branch,
                'assigned_admin_id'=>$assignedId,
                'assigned_admin_name'=>$assignedName
            ];
        }
        usort($threads,function($a,$b){
            $ar=($a['status']==='Resolved')?1:0;$br=($b['status']==='Resolved')?1:0;
            if($ar!==$br)return $ar<=>$br;
            return strcmp((string)($b['last_at']??''),(string)($a['last_at']??''));
        });
        json_out(['ok'=>true,'threads'=>$threads,'scope'=>$admin['is_system_admin']?'All Branches':$admin['branch']]);
    } catch (Throwable $e) {
        error_log('[chat_threads] '.$e->getMessage());
        json_out(['ok'=>false,'message'=>'Unable to load patient inquiries: '.$e->getMessage()],500);
    }
}

if ($action === 'chat_unread_count') {
    $admin=require_admin_context($pdo);
    ensure_chat_thread_status_table($pdo);
    $sql="SELECT COUNT(*) FROM chat_messages cm
          WHERE cm.sender_type='patient' AND cm.is_read=0" .
          (!$admin['is_system_admin'] ? " AND COALESCE((SELECT NULLIF(cts.rhu_branch,'') FROM chat_thread_status cts WHERE cts.patient_id=cm.patient_id),(SELECT ap.center FROM appointments ap WHERE ap.patient_id=cm.patient_id ORDER BY ap.appointment_date DESC,ap.id DESC LIMIT 1),'RHU I - Poblacion')=?" : "");
    if($admin['is_system_admin']){$count=(int)$pdo->query($sql)->fetchColumn();}
    else{$stmt=$pdo->prepare($sql);$stmt->execute([$admin['branch']]);$count=(int)$stmt->fetchColumn();}
    json_out(['ok'=>true,'unread'=>$count]);
}

if ($action === 'chat_set_status') {
    $admin=require_admin_context($pdo);
    ensure_chat_thread_status_table($pdo);
    $patientId=(int)($data['patient_id']??0);
    $status=trim((string)($data['status']??'Open'));
    if(!in_array($status,['Open','Waiting for Patient','Resolved'],true))
      json_out(['ok'=>false,'message'=>'Invalid inquiry status.'],422);
    require_admin_patient_access($pdo,$patientId);
    $rhuBranch=chat_thread_branch($pdo,$patientId);
    $pdo->prepare("INSERT INTO chat_thread_status(patient_id,status,rhu_branch,assigned_admin_id) VALUES(?,?,?,?)
      ON DUPLICATE KEY UPDATE status=VALUES(status),rhu_branch=VALUES(rhu_branch),assigned_admin_id=VALUES(assigned_admin_id),updated_at=NOW()")
      ->execute([$patientId,$status,$rhuBranch,$admin['id']]);
    audit_event($pdo,$admin,'Patient Inquiries','Updated Inquiry Status',"Patient ID {$patientId}: {$status}");
    json_out(['ok'=>true,'message'=>'Inquiry status updated.']);
}

if ($action === 'patient_announcements') {
    if(empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_announcement_attachment_columns($pdo);
    $patientId=(int)$_SESSION['patient_id'];
    $branch=patient_record_branch($pdo,$patientId);
    $barangayStmt=$pdo->prepare('SELECT barangay FROM patients WHERE id=? LIMIT 1');$barangayStmt->execute([$patientId]);$patientBarangay=trim((string)$barangayStmt->fetchColumn());
    $visibility="an.status='Published' AND (an.publish_at IS NULL OR an.publish_at<=NOW()) AND (an.expires_at IS NULL OR an.expires_at>=NOW()) AND (COALESCE(an.target_barangay,'All Barangays')='All Barangays' OR an.target_barangay=?)";
    if($branch!==''){
      $stmt=$pdo->prepare("SELECT an.*,COALESCE(ad.name,'Pulilan Health Center') created_by_name FROM announcements an LEFT JOIN admins ad ON ad.id=an.created_by WHERE {$visibility} AND an.branch IN ('All Branches',?) ORDER BY COALESCE(an.publish_at,an.created_at) DESC,an.id DESC LIMIT 6");
      $stmt->execute([$patientBarangay,$branch]);$rows=$stmt->fetchAll();
    }else{
      $stmt=$pdo->prepare("SELECT an.*,COALESCE(ad.name,'Pulilan Health Center') created_by_name FROM announcements an LEFT JOIN admins ad ON ad.id=an.created_by WHERE {$visibility} AND an.branch='All Branches' ORDER BY COALESCE(an.publish_at,an.created_at) DESC,an.id DESC LIMIT 6");
      $stmt->execute([$patientBarangay]);$rows=$stmt->fetchAll();
    }
    json_out(['ok'=>true,'branch'=>$branch,'announcements'=>array_map('announcement_payload',$rows)]);
}

if ($action === 'admin_announcements') {
    $admin=require_admin_context($pdo);
    ensure_announcement_attachment_columns($pdo);
    if($admin['is_system_admin']){
      $rows=$pdo->query("SELECT an.*,COALESCE(ad.name,'Unknown') created_by_name FROM announcements an LEFT JOIN admins ad ON ad.id=an.created_by ORDER BY an.created_at DESC")->fetchAll();
    }else{
      $stmt=$pdo->prepare("SELECT an.*,COALESCE(ad.name,'Unknown') created_by_name FROM announcements an LEFT JOIN admins ad ON ad.id=an.created_by WHERE an.branch IN ('All Branches',?) ORDER BY an.created_at DESC");
      $stmt->execute([$admin['branch']]); $rows=$stmt->fetchAll();
    }
    json_out(['ok'=>true,'announcements'=>array_map('announcement_payload',$rows)]);
}
if ($action === 'admin_save_announcement') {
    $admin=require_admin_context($pdo);
    ensure_announcement_attachment_columns($pdo);
    $id=(int)($data['id']??0); $title=trim((string)($data['title']??'')); $message=trim((string)($data['message']??''));
    $branch=trim((string)($data['branch']??'All Branches')); $status=trim((string)($data['status']??'Published'));
    $targetBarangay=trim((string)($data['target_barangay']??'All Barangays')); $priority=strtolower(trim((string)($data['priority']??'normal')));
    $publishAt=trim((string)($data['publish_at']??'')); $expiresAt=trim((string)($data['expires_at']??''));
    $publishAt=$publishAt!==''?date('Y-m-d H:i:s',strtotime($publishAt)):null; $expiresAt=$expiresAt!==''?date('Y-m-d H:i:s',strtotime($expiresAt)):null;
    if($title===''||$message==='') json_out(['ok'=>false,'message'=>'Title and description are required.'],422);
    if(!in_array($status,['Draft','Published','Archived'],true)) json_out(['ok'=>false,'message'=>'Invalid announcement status.'],422);
    if(!$admin['is_system_admin']) $branch=$admin['branch'];
    if(!in_array($branch,array_merge(['All Branches'],allowed_rhu_branches()),true)) json_out(['ok'=>false,'message'=>'Please select a valid announcement branch.'],422);
    if(!in_array($priority,['normal','important','urgent'],true)) json_out(['ok'=>false,'message'=>'Invalid announcement priority.'],422);
    $upload=save_announcement_attachment();$old=null;
    if($id>0){
      $stmt=$pdo->prepare('SELECT * FROM announcements WHERE id=?'); $stmt->execute([$id]); $old=$stmt->fetch();
      if(!$old) json_out(['ok'=>false,'message'=>'Announcement not found.'],404);
      if(!$admin['is_system_admin'] && ($old['branch']??'')!==$admin['branch']) json_out(['ok'=>false,'message'=>'You can edit announcements from your assigned RHU only.'],403);
      $remove=!empty($data['remove_attachment']);
      $path=$upload['path']??($remove?null:($old['attachment_path']??null));
      $name=$upload['name']??($remove?null:($old['attachment_name']??null));
      $mime=$upload['mime']??($remove?null:($old['attachment_mime']??null));
      $pdo->prepare('UPDATE announcements SET title=?,message=?,branch=?,target_barangay=?,priority=?,status=?,publish_at=?,expires_at=?,attachment_path=?,attachment_name=?,attachment_mime=? WHERE id=?')->execute([$title,$message,$branch,$targetBarangay,$priority,$status,$publishAt,$expiresAt,$path,$name,$mime,$id]);
      if(($upload||$remove)&&!empty($old['attachment_path'])) delete_announcement_attachment($old['attachment_path']);
      audit_event($pdo,$admin,'Announcements','Updated Announcement','Announcement ID '.$id);
    }else{
      $pdo->prepare('INSERT INTO announcements(title,message,branch,target_barangay,priority,status,publish_at,expires_at,attachment_path,attachment_name,attachment_mime,created_by) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)')->execute([$title,$message,$branch,$targetBarangay,$priority,$status,$publishAt,$expiresAt,$upload['path']??null,$upload['name']??null,$upload['mime']??null,$admin['id']]);
      $id=(int)$pdo->lastInsertId(); audit_event($pdo,$admin,'Announcements','Created Announcement','Announcement ID '.$id);
    }
    if($status==='Published' && ($publishAt===null || strtotime($publishAt)<=time()) && ($expiresAt===null || strtotime($expiresAt)>=time())){
      $patients=$pdo->query("SELECT id FROM patients WHERE account_status='Active'")->fetchAll();
      if($branch!=='All Branches') $patients=array_values(array_filter($patients,fn($p)=>patient_record_branch($pdo,(int)$p['id'])===$branch));
      foreach($patients as $p) create_patient_notification($pdo,(int)$p['id'],null,'info','New Health Center Announcement',$title.': '.$message,'dashboard.html?announcement='.$id.'#announcements','announcement:'.$id);
    }
    json_out(['ok'=>true,'id'=>$id,'message'=>'Announcement saved.']);
}
if ($action === 'admin_delete_announcement') {
    $admin=require_admin_context($pdo);
    ensure_announcement_attachment_columns($pdo);$id=(int)($data['id']??0);
    $stmt=$pdo->prepare('SELECT title,branch,attachment_path FROM announcements WHERE id=?'); $stmt->execute([$id]); $row=$stmt->fetch();
    if(!$row) json_out(['ok'=>false,'message'=>'Announcement not found.'],404);
    if(!$admin['is_system_admin'] && ($row['branch']??'')!==$admin['branch']) json_out(['ok'=>false,'message'=>'You can delete announcements from your assigned RHU only.'],403);
    $pdo->prepare('DELETE FROM announcements WHERE id=?')->execute([$id]);
    delete_announcement_attachment($row['attachment_path']??'');
    audit_event($pdo,$admin,'Announcements','Deleted Announcement','Announcement ID '.$id);
    json_out(['ok'=>true,'message'=>'Announcement deleted.']);
}

if ($action === 'admin_dashboard_snapshot') {
    $admin=require_admin_context($pdo); $all=queue_branch_payload($pdo); $queue=[];
    foreach($all as $branch=>$bd){
      if(!$admin['is_system_admin']&&$branch!==$admin['branch']) continue;
      $serving=0;$waiting=0; foreach(($bd['queue']??[]) as $q){if(($q['status']??'')==='serving')$serving++;else$waiting++;}
      $queue[$branch]=['totalToday'=>(int)($bd['served']??0)+$serving+$waiting,'serving'=>$serving,'waiting'=>$waiting,'served'=>(int)($bd['served']??0)];
    }
    if($admin['is_system_admin']) $today=(int)$pdo->query('SELECT COUNT(*) FROM appointments WHERE appointment_date=CURDATE()')->fetchColumn();
    else {$s=$pdo->prepare('SELECT COUNT(*) FROM appointments WHERE appointment_date=CURDATE() AND center=?');$s->execute([$admin['branch']]);$today=(int)$s->fetchColumn();}
    $inQueue=0;$nowServing=0;$served=0; foreach($queue as $bd){$inQueue+=$bd['waiting']+$bd['serving'];$nowServing+=$bd['serving'];$served+=$bd['served'];}
    json_out(['ok'=>true,'dataDate'=>date('Y-m-d'),'metrics'=>['todayAppointments'=>$today,'inQueue'=>$inQueue,'nowServing'=>$nowServing,'servedToday'=>$served],'queueData'=>$queue]);
}

if ($action === 'admin_notification_summary') {
    $admin=require_admin_context($pdo);
    ensure_chat_thread_status_table($pdo);
    $pdo->exec("CREATE TABLE IF NOT EXISTS audit_logs (id INT AUTO_INCREMENT PRIMARY KEY, user_type VARCHAR(30) NOT NULL DEFAULT 'admin', user_name VARCHAR(150) NOT NULL DEFAULT 'Administrator', email VARCHAR(150) NULL, role VARCHAR(100) NULL, branch VARCHAR(150) NULL, module VARCHAR(100) NULL, action VARCHAR(150) NOT NULL DEFAULT 'Action', details TEXT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    ensure_audit_columns($pdo);
    $settingRows=$pdo->query("SELECT setting_key,setting_value FROM system_settings WHERE setting_key IN ('inquiryNotifications','inquiryPollingSeconds')")->fetchAll();
    $alertSettings=[];foreach($settingRows as $row)$alertSettings[$row['setting_key']]=$row['setting_value'];
    $alertsEnabled=strtolower(trim((string)($alertSettings['inquiryNotifications']??'Enabled')))!=='disabled';
    $pollingSeconds=(int)($alertSettings['inquiryPollingSeconds']??12);
    if(!in_array($pollingSeconds,[5,10,12,30,60],true))$pollingSeconds=12;

    $lastReadStmt=$pdo->prepare("SELECT last_notification_read_at FROM admins WHERE id=?");
    $lastReadStmt->execute([$admin['id']]);
    $lastRead=(string)$lastReadStmt->fetchColumn();
    if($lastRead===''){
      $lastRead=date('Y-m-d H:i:s');
      $pdo->prepare("UPDATE admins SET last_notification_read_at=? WHERE id=?")->execute([$lastRead,$admin['id']]);
    }

    $activityWhere="COALESCE(module,'') IN ('Appointments','Queue Management','Patient Inquiries','Patients','Announcements','Disease Trends') AND LOWER(COALESCE(action,'')) NOT LIKE 'viewed%' AND LOWER(COALESCE(action,'')) NOT LIKE 'opened%' AND LOWER(COALESCE(action,'')) NOT LIKE 'exported%'";
    $activityParams=[];
    if(!$admin['is_system_admin']){
      $activityWhere.=" AND (COALESCE(branch,'')=? OR COALESCE(details,'') LIKE ?)";
      $activityParams[]=$admin['branch'];
      $activityParams[]='%'.$admin['branch'].'%';
    }
    $unreadActivityStmt=$pdo->prepare("SELECT COUNT(*) FROM audit_logs WHERE {$activityWhere} AND created_at>?");
    $unreadActivityStmt->execute(array_merge($activityParams,[$lastRead]));
    $unreadActivity=(int)$unreadActivityStmt->fetchColumn();
    $activityStmt=$pdo->prepare("SELECT id,user_name,COALESCE(branch,'') branch,COALESCE(module,'System') module,action,COALESCE(details,'') details,created_at FROM audit_logs WHERE {$activityWhere} ORDER BY id DESC LIMIT 12");
    $activityStmt->execute($activityParams);
    $recentNotifications=[];
    foreach($activityStmt->fetchAll() as $event){
      $module=(string)$event['module'];
      $eventBranch=(string)$event['branch'];
      foreach(allowed_rhu_branches() as $knownBranch){
        if(stripos((string)$event['details'],$knownBranch)!==false){$eventBranch=$knownBranch;break;}
      }
      $link='admin-dashboard.html';
      $icon='fa-bell';
      if($module==='Appointments'){
        $link='admin-appointments.html';
        if(preg_match('/Appointment\\s+APT-(\\d+)/i',(string)$event['details'],$match))$link.='?appointment='.(int)$match[1];
        $icon='fa-calendar-check';
      }elseif($module==='Queue Management'){
        $link='admin-queue.html';$icon='fa-list-ol';
      }elseif($module==='Patient Inquiries'){
        $link=$admin['is_system_admin']?'admin-messages.html':'staff-messages.html';
        if(preg_match('/Patient ID\\s+(\\d+)/i',(string)$event['details'],$match))$link.='?patient_id='.(int)$match[1];
        $icon='fa-comment-medical';
      }elseif($module==='Patients'){
        $link='admin-patients.html';$icon='fa-user';
      }elseif($module==='Announcements'){
        $link='admin-announcements.html';$icon='fa-bullhorn';
      }elseif($module==='Disease Trends'&&$admin['is_system_admin']){
        $link='admin-heatmap.html';$icon='fa-map-location-dot';
      }
      $recentNotifications[]=[
        'id'=>'activity-'.(int)$event['id'],
        'kind'=>'activity',
        'title'=>$event['action'],
        'message'=>$event['details'],
        'actor'=>$event['user_name'],
        'branch'=>$eventBranch,
        'module'=>$module,
        'icon'=>$icon,
        'link'=>$link,
        'unread'=>strtotime((string)$event['created_at'])>strtotime($lastRead),
        'created_at'=>$event['created_at']
      ];
    }

    $unread=0;$recent=[];
    $branchExpr="COALESCE(NULLIF(cts.rhu_branch,''),(SELECT ap.center FROM appointments ap WHERE ap.patient_id=cm.patient_id ORDER BY ap.appointment_date DESC,ap.id DESC LIMIT 1),'RHU I - Poblacion')";
    if($alertsEnabled&&$admin['is_system_admin']){
      $unread=(int)$pdo->query("SELECT COUNT(*) FROM chat_messages WHERE sender_type='patient' AND is_read=0")->fetchColumn();
      $recent=$pdo->query("SELECT cm.id,cm.patient_id,CONCAT(p.first_name,' ',p.last_name) patient_name,cm.message,cm.created_at,{$branchExpr} rhu_branch FROM chat_messages cm JOIN patients p ON p.id=cm.patient_id LEFT JOIN chat_thread_status cts ON cts.patient_id=cm.patient_id WHERE cm.sender_type='patient' AND cm.is_read=0 ORDER BY cm.id DESC LIMIT 8")->fetchAll();
    }elseif($alertsEnabled){
      $s=$pdo->prepare("SELECT COUNT(*) FROM chat_messages cm LEFT JOIN chat_thread_status cts ON cts.patient_id=cm.patient_id WHERE cm.sender_type='patient' AND cm.is_read=0 AND {$branchExpr}=?");$s->execute([$admin['branch']]);$unread=(int)$s->fetchColumn();
      $s=$pdo->prepare("SELECT cm.id,cm.patient_id,CONCAT(p.first_name,' ',p.last_name) patient_name,cm.message,cm.created_at,{$branchExpr} rhu_branch FROM chat_messages cm JOIN patients p ON p.id=cm.patient_id LEFT JOIN chat_thread_status cts ON cts.patient_id=cm.patient_id WHERE cm.sender_type='patient' AND cm.is_read=0 AND {$branchExpr}=? ORDER BY cm.id DESC LIMIT 8");$s->execute([$admin['branch']]);$recent=$s->fetchAll();
    }
    foreach($recent as $inquiry){
      $recentNotifications[]=[
        'id'=>'inquiry-'.(int)$inquiry['id'],
        'kind'=>'inquiry',
        'title'=>'New Patient Inquiry',
        'message'=>$inquiry['patient_name'].': '.$inquiry['message'],
        'actor'=>$inquiry['patient_name'],
        'branch'=>$inquiry['rhu_branch'],
        'module'=>'Patient Inquiries',
        'icon'=>'fa-comment-medical',
        'link'=>($admin['is_system_admin']?'admin-messages.html':'staff-messages.html').'?patient_id='.(int)$inquiry['patient_id'],
        'unread'=>true,
        'created_at'=>$inquiry['created_at']
      ];
    }
    usort($recentNotifications,fn($a,$b)=>strtotime((string)$b['created_at'])<=>strtotime((string)$a['created_at']));
    $recentNotifications=array_slice($recentNotifications,0,12);
    json_out([
      'ok'=>true,
      'unread_total'=>$unread+$unreadActivity,
      'unread_inquiries'=>$unread,
      'unread_activity'=>$unreadActivity,
      'recent'=>$recent,
      'recent_notifications'=>$recentNotifications,
      'alerts_enabled'=>$alertsEnabled,
      'polling_seconds'=>$pollingSeconds
    ]);
}

if ($action === 'admin_notifications_read') {
    $admin=require_admin_context($pdo);
    ensure_admin_activity_columns($pdo);
    $pdo->prepare("UPDATE admins SET last_notification_read_at=NOW() WHERE id=?")->execute([$admin['id']]);
    json_out(['ok'=>true,'message'=>'System activity notifications marked as read.']);
}

if ($action === 'admin_settings_get') {
    require_admin_context($pdo,true); $rows=$pdo->query('SELECT setting_key,setting_value FROM system_settings')->fetchAll();
    $settings=[]; foreach($rows as $r)$settings[$r['setting_key']]=$r['setting_value']; json_out(['ok'=>true,'settings'=>$settings]);
}
if ($action === 'admin_settings_save') {
    $admin=require_admin_context($pdo,true);
    if(array_key_exists('supportEmail',$data)&&trim((string)$data['supportEmail'])!==''&&!filter_var(trim((string)$data['supportEmail']),FILTER_VALIDATE_EMAIL))json_out(['ok'=>false,'message'=>'Enter a valid support email address.'],422);
    if(array_key_exists('inquiryNotifications',$data)&&!in_array((string)$data['inquiryNotifications'],['Enabled','Disabled'],true))json_out(['ok'=>false,'message'=>'Select a valid inquiry alert setting.'],422);
    if(array_key_exists('inquiryPollingSeconds',$data)&&!in_array((int)$data['inquiryPollingSeconds'],[5,10,12,30,60],true))json_out(['ok'=>false,'message'=>'Select a valid inquiry refresh interval.'],422);
    $allowed=['facilityName','municipality','supportEmail','supportContact','inquiryNotifications','inquiryPollingSeconds'];
    $s=$pdo->prepare('INSERT INTO system_settings(setting_key,setting_value,updated_by) VALUES(?,?,?) ON DUPLICATE KEY UPDATE setting_value=VALUES(setting_value),updated_by=VALUES(updated_by),updated_at=NOW()');
    foreach($allowed as $key) if(array_key_exists($key,$data)) $s->execute([$key,(string)$data[$key],$admin['id']]);
    audit_event($pdo,$admin,'System Settings','Updated Settings','System settings updated.'); json_out(['ok'=>true,'message'=>'Settings saved.']);
}
json_out(['ok'=>false,'message'=>'Unknown action.'],404);
