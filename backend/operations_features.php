<?php

function operations_services(): array {
    return ['All Services','General Consultation','Vaccination','Prenatal Care','Child Immunization','Family Planning'];
}

function operations_ensure_tables(PDO $pdo): void {
    static $ready=false;
    if($ready)return;
    $pdo->exec("CREATE TABLE IF NOT EXISTS clinic_schedules (
      id INT AUTO_INCREMENT PRIMARY KEY,
      branch VARCHAR(120) NOT NULL,
      day_of_week TINYINT NOT NULL,
      is_open TINYINT(1) NOT NULL DEFAULT 1,
      open_time TIME NULL,
      close_time TIME NULL,
      break_start TIME NULL,
      break_end TIME NULL,
      slot_interval_minutes SMALLINT NOT NULL DEFAULT 30,
      updated_by INT NULL,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      UNIQUE KEY uniq_clinic_schedule (branch,day_of_week)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS clinic_capacity_rules (
      id INT AUTO_INCREMENT PRIMARY KEY,
      branch VARCHAR(120) NOT NULL,
      service VARCHAR(120) NOT NULL DEFAULT 'All Services',
      capacity_per_slot SMALLINT NOT NULL DEFAULT 25,
      daily_capacity SMALLINT NOT NULL DEFAULT 200,
      updated_by INT NULL,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      UNIQUE KEY uniq_capacity_rule (branch,service)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    $capacityColumns=$pdo->query("SHOW COLUMNS FROM clinic_capacity_rules")->fetchAll(PDO::FETCH_COLUMN);
    if(!in_array('daily_capacity',$capacityColumns,true))$pdo->exec("ALTER TABLE clinic_capacity_rules ADD COLUMN daily_capacity SMALLINT NOT NULL DEFAULT 200 AFTER capacity_per_slot");

    $pdo->exec("CREATE TABLE IF NOT EXISTS clinic_closures (
      id INT AUTO_INCREMENT PRIMARY KEY,
      branch VARCHAR(120) NOT NULL DEFAULT 'All Branches',
      service VARCHAR(120) NOT NULL DEFAULT 'All Services',
      closure_date DATE NOT NULL,
      closure_type ENUM('Holiday','Emergency','Maintenance','Special Event') NOT NULL DEFAULT 'Holiday',
      title VARCHAR(160) NOT NULL,
      details TEXT NULL,
      closed_all_day TINYINT(1) NOT NULL DEFAULT 1,
      start_time TIME NULL,
      end_time TIME NULL,
      status ENUM('Active','Cancelled') NOT NULL DEFAULT 'Active',
      created_by INT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_clinic_closure_lookup (closure_date,status,branch,service)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS notification_delivery_logs (
      id BIGINT AUTO_INCREMENT PRIMARY KEY,
      channel ENUM('in_app','browser','email','sms') NOT NULL DEFAULT 'in_app',
      patient_id INT NULL,
      appointment_id INT NULL,
      recipient VARCHAR(190) NULL,
      event_type VARCHAR(60) NOT NULL DEFAULT 'notification',
      title VARCHAR(190) NOT NULL,
      message TEXT NULL,
      link VARCHAR(255) NULL,
      status ENUM('delivered','failed','skipped') NOT NULL,
      provider_record_id VARCHAR(190) NULL,
      error_message TEXT NULL,
      attempts SMALLINT NOT NULL DEFAULT 1,
      last_attempt_at DATETIME NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_delivery_health (status,channel,created_at),
      INDEX idx_delivery_patient (patient_id,created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS privacy_policy_versions (
      id INT AUTO_INCREMENT PRIMARY KEY,
      version_label VARCHAR(40) NOT NULL UNIQUE,
      title VARCHAR(160) NOT NULL,
      content MEDIUMTEXT NOT NULL,
      retention_days INT NOT NULL DEFAULT 1825,
      status ENUM('Draft','Published','Archived') NOT NULL DEFAULT 'Draft',
      effective_at DATETIME NULL,
      created_by INT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_privacy_current (status,effective_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS patient_consents (
      id BIGINT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT NOT NULL,
      policy_id INT NOT NULL,
      status ENUM('Accepted','Withdrawn') NOT NULL DEFAULT 'Accepted',
      source VARCHAR(40) NOT NULL DEFAULT 'patient_portal',
      accepted_at DATETIME NULL,
      withdrawn_at DATETIME NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uniq_patient_policy_consent (patient_id,policy_id),
      INDEX idx_consent_current (patient_id,status,accepted_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS patient_access_history (
      id BIGINT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT NOT NULL,
      actor_type ENUM('patient','admin','caregiver','system') NOT NULL,
      actor_id INT NULL,
      actor_name VARCHAR(160) NOT NULL,
      action VARCHAR(100) NOT NULL,
      resource VARCHAR(100) NOT NULL,
      purpose VARCHAR(190) NOT NULL,
      branch VARCHAR(120) NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_access_patient (patient_id,created_at),
      INDEX idx_access_actor (actor_type,actor_id,created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS booking_slot_locks (
      branch VARCHAR(120) NOT NULL,
      service VARCHAR(120) NOT NULL,
      appointment_date DATE NOT NULL,
      appointment_time VARCHAR(30) NOT NULL,
      touched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (branch,service,appointment_date,appointment_time)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS appointment_queue_sequences (
      branch VARCHAR(120) NOT NULL,
      appointment_date DATE NOT NULL,
      prefix CHAR(1) NOT NULL,
      next_number INT NOT NULL DEFAULT 1,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (branch,appointment_date,prefix)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $scheduleInsert=$pdo->prepare("INSERT IGNORE INTO clinic_schedules(branch,day_of_week,is_open,open_time,close_time,break_start,break_end,slot_interval_minutes) VALUES(?,?,?,?,?,?,?,30)");
    $capacityInsert=$pdo->prepare("INSERT IGNORE INTO clinic_capacity_rules(branch,service,capacity_per_slot,daily_capacity) VALUES(?,'All Services',25,200)");
    foreach (allowed_rhu_branches() as $branch) {
        for ($day=0;$day<=6;$day++) {
            if ($day===0) $scheduleInsert->execute([$branch,$day,0,null,null,null,null]);
            elseif ($day===6) $scheduleInsert->execute([$branch,$day,1,'08:00:00','12:00:00',null,null]);
            else $scheduleInsert->execute([$branch,$day,1,'08:00:00','17:00:00','12:00:00','13:00:00']);
        }
        $capacityInsert->execute([$branch]);
    }

    $policyCount=(int)$pdo->query("SELECT COUNT(*) FROM privacy_policy_versions")->fetchColumn();
    if ($policyCount===0) {
        $content="Pulilan Health Center collects identity, contact, appointment, queue, caregiver, and relevant health-classification information to provide RHU services, communicate schedule and queue updates, protect patient safety, and meet lawful public-health reporting duties. Access is limited to authorized personnel and approved caregivers for a stated purpose. Records are retained according to the published retention period, then reviewed for secure archival or lawful disposal. Patients may review their consent and access history, correct inaccurate profile information, withdraw optional portal consent, and contact the health center about privacy concerns. Withdrawal does not require deletion of records that must be kept for care, safety, audit, or legal obligations.";
        $stmt=$pdo->prepare("INSERT INTO privacy_policy_versions(version_label,title,content,retention_days,status,effective_at) VALUES('1.0','Patient Privacy and Data Retention Policy',?,1825,'Published',NOW())");
        $stmt->execute([$content]);
    }
    $ready=true;
}

function operations_current_policy(PDO $pdo): ?array {
    operations_ensure_tables($pdo);
    $row=$pdo->query("SELECT * FROM privacy_policy_versions WHERE status='Published' AND (effective_at IS NULL OR effective_at<=NOW()) ORDER BY COALESCE(effective_at,created_at) DESC,id DESC LIMIT 1")->fetch();
    return $row ?: null;
}

function operations_record_consent(PDO $pdo, int $patientId, string $source='patient_portal'): bool {
    $policy=operations_current_policy($pdo);
    if (!$policy) return false;
    $stmt=$pdo->prepare("INSERT INTO patient_consents(patient_id,policy_id,status,source,accepted_at,withdrawn_at) VALUES(?,?,'Accepted',?,NOW(),NULL) ON DUPLICATE KEY UPDATE status='Accepted',source=VALUES(source),accepted_at=NOW(),withdrawn_at=NULL");
    $stmt->execute([$patientId,(int)$policy['id'],$source]);
    operations_log_patient_access($pdo,$patientId,'patient',$patientId,'Patient','Accepted privacy policy','Privacy consent','Patient authorized portal processing under policy '.$policy['version_label'],null);
    return true;
}

function operations_patient_has_current_consent(PDO $pdo, int $patientId): bool {
    $policy=operations_current_policy($pdo);
    if (!$policy) return true;
    $stmt=$pdo->prepare("SELECT 1 FROM patient_consents WHERE patient_id=? AND policy_id=? AND status='Accepted' LIMIT 1");
    $stmt->execute([$patientId,(int)$policy['id']]);
    return (bool)$stmt->fetchColumn();
}

function operations_require_patient_consent(PDO $pdo, int $patientId): void {
    if (!operations_patient_has_current_consent($pdo,$patientId)) {
        json_out(['ok'=>false,'message'=>'Please review and accept the current Privacy and Data Retention Policy before using this feature.','privacy_required'=>true,'privacy_url'=>'privacy.html'],428);
    }
}

function operations_log_patient_access(PDO $pdo, int $patientId, string $actorType, ?int $actorId, string $actorName, string $actionName, string $resource, string $purpose, ?string $branch): void {
    try {
        operations_ensure_tables($pdo);
        $allowed=['patient','admin','caregiver','system'];
        if (!in_array($actorType,$allowed,true)) $actorType='system';
        $stmt=$pdo->prepare("INSERT INTO patient_access_history(patient_id,actor_type,actor_id,actor_name,action,resource,purpose,branch) VALUES(?,?,?,?,?,?,?,?)");
        $stmt->execute([$patientId,$actorType,$actorId,$actorName,$actionName,$resource,$purpose,$branch]);
    } catch (Throwable $e) {
        error_log('[patient-access-history] '.$e->getMessage());
    }
}

function operations_log_delivery(PDO $pdo, array $event): void {
    try {
        operations_ensure_tables($pdo);
        $stmt=$pdo->prepare("INSERT INTO notification_delivery_logs(channel,patient_id,appointment_id,recipient,event_type,title,message,link,status,provider_record_id,error_message,attempts,last_attempt_at) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,NOW())");
        $stmt->execute([
            $event['channel']??'in_app',$event['patient_id']??null,$event['appointment_id']??null,$event['recipient']??null,
            $event['event_type']??'notification',mb_substr((string)($event['title']??'Notification'),0,190),$event['message']??null,$event['link']??null,
            $event['status']??'delivered',$event['provider_record_id']??null,$event['error_message']??null,max(1,(int)($event['attempts']??1))
        ]);
    } catch (Throwable $e) {
        error_log('[delivery-monitor] '.$e->getMessage());
    }
}

function operations_capacity_for(PDO $pdo, string $branch, string $service): int {
    operations_ensure_tables($pdo);
    $stmt=$pdo->prepare("SELECT capacity_per_slot FROM clinic_capacity_rules WHERE branch=? AND service IN (?, 'All Services') ORDER BY CASE WHEN service=? THEN 0 ELSE 1 END LIMIT 1");
    $stmt->execute([$branch,$service,$service]);
    return max(1,(int)($stmt->fetchColumn() ?: 25));
}

function operations_daily_capacity_for(PDO $pdo, string $branch): int {
    operations_ensure_tables($pdo);
    $stmt=$pdo->prepare("SELECT daily_capacity FROM clinic_capacity_rules WHERE branch=? AND service='All Services' LIMIT 1");
    $stmt->execute([$branch]);
    return max(1,(int)($stmt->fetchColumn() ?: 200));
}

function operations_schedule_for(PDO $pdo, string $branch, int $day): ?array {
    operations_ensure_tables($pdo);
    $stmt=$pdo->prepare("SELECT * FROM clinic_schedules WHERE branch=? AND day_of_week=? LIMIT 1");
    $stmt->execute([$branch,$day]);
    $row=$stmt->fetch();
    return $row ?: null;
}

function operations_booking_plan(PDO $pdo, string $branch, string $service, string $date): array {
    operations_ensure_tables($pdo);
    if (!in_array($branch,allowed_rhu_branches(),true)) return ['open'=>false,'message'=>'Select a valid RHU branch.','times'=>[],'slots'=>[],'slotStatus'=>[],'capacity'=>0];
    if (!in_array($service,operations_services(),true) || $service==='All Services') return ['open'=>false,'message'=>'Select a valid health service.','times'=>[],'slots'=>[],'slotStatus'=>[],'capacity'=>0];
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/',$date) || !strtotime($date)) return ['open'=>false,'message'=>'Select a valid appointment date.','times'=>[],'slots'=>[],'slotStatus'=>[],'capacity'=>0];

    $day=(int)date('w',strtotime($date));
    $schedule=operations_schedule_for($pdo,$branch,$day);
    $capacity=operations_capacity_for($pdo,$branch,$service);
    $dailyCapacity=operations_daily_capacity_for($pdo,$branch);
    $dailyStmt=$pdo->prepare("SELECT COUNT(*) FROM appointments WHERE center=? AND appointment_date=? AND LOWER(status) IN ('pending','confirmed','serving','hold','waiting')");
    $dailyStmt->execute([$branch,$date]);
    $dailyBooked=(int)$dailyStmt->fetchColumn();
    $dailyRemaining=max(0,$dailyCapacity-$dailyBooked);
    $base=['open'=>false,'message'=>'This RHU is closed on the selected day.','times'=>[],'slots'=>[],'slotStatus'=>[],'capacity'=>$capacity,'dailyCapacity'=>$dailyCapacity,'dailyRemaining'=>$dailyRemaining,'clinicHours'=>'Closed','closures'=>[]];
    if (!$schedule || !(int)$schedule['is_open'] || empty($schedule['open_time']) || empty($schedule['close_time'])) return $base;
    if($dailyRemaining<=0)return array_merge($base,['message'=>"This RHU has reached its daily capacity of {$dailyCapacity} patients. Please choose another date."]);

    $closureStmt=$pdo->prepare("SELECT * FROM clinic_closures WHERE closure_date=? AND status='Active' AND branch IN ('All Branches',?) AND service IN ('All Services',?) ORDER BY FIELD(closure_type,'Emergency','Holiday','Maintenance','Special Event'),id DESC");
    $closureStmt->execute([$date,$branch,$service]);
    $closures=$closureStmt->fetchAll();
    foreach ($closures as $closure) {
        if ((int)$closure['closed_all_day']) {
            return array_merge($base,['message'=>$closure['title'].(!empty($closure['details'])?' — '.$closure['details']:''),'closures'=>$closures]);
        }
    }

    $openTs=strtotime($date.' '.$schedule['open_time']);
    $closeTs=strtotime($date.' '.$schedule['close_time']);
    $interval=max(5,min(120,(int)$schedule['slot_interval_minutes']));
    $breakStart=!empty($schedule['break_start'])?strtotime($date.' '.$schedule['break_start']):null;
    $breakEnd=!empty($schedule['break_end'])?strtotime($date.' '.$schedule['break_end']):null;
    $times=[];
    for ($cursor=$openTs;$cursor<$closeTs;$cursor+=($interval*60)) {
        $slotEnd=$cursor+($interval*60);
        if ($breakStart && $breakEnd && $cursor<$breakEnd && $slotEnd>$breakStart) continue;
        $blocked=false;
        foreach ($closures as $closure) {
            if ((int)$closure['closed_all_day']) {$blocked=true;break;}
            $start=!empty($closure['start_time'])?strtotime($date.' '.$closure['start_time']):null;
            $end=!empty($closure['end_time'])?strtotime($date.' '.$closure['end_time']):null;
            if ($start && $end && $cursor<$end && $slotEnd>$start) {$blocked=true;break;}
        }
        if (!$blocked) $times[]=date('h:i A',$cursor);
    }

    $countStmt=$pdo->prepare("SELECT appointment_time,COUNT(*) total FROM appointments WHERE center=? AND service=? AND appointment_date=? AND LOWER(status) IN ('pending','confirmed','serving','hold','waiting') GROUP BY appointment_time");
    $countStmt->execute([$branch,$service,$date]);
    $counts=[];foreach($countStmt->fetchAll() as $row)$counts[$row['appointment_time']]=(int)$row['total'];
    $slots=[];$status=[];$today=date('Y-m-d');
    foreach($times as $time){
        $remaining=max(0,$capacity-(int)($counts[$time]??0));

        $isPast=$date===$today && strtotime($date.' '.$time)<=time();
        $slots[$time]=$isPast?0:$remaining;
        $status[$time]=$isPast?'past':($remaining>0?'available':'full');
    }
    $hours=date('g:i A',$openTs).' – '.date('g:i A',$closeTs);
    if($breakStart&&$breakEnd)$hours.=' (break '.date('g:i A',$breakStart).' – '.date('g:i A',$breakEnd).')';
    return ['open'=>true,'message'=>'','times'=>$times,'slots'=>$slots,'slotStatus'=>$status,'capacity'=>$capacity,'dailyCapacity'=>$dailyCapacity,'dailyRemaining'=>$dailyRemaining,'clinicHours'=>$hours,'closures'=>$closures,'intervalMinutes'=>$interval];
}

function operations_issue_queue_number(PDO $pdo, string $branch, string $date, string $prefix): string {
    $stmt=$pdo->prepare("SELECT next_number FROM appointment_queue_sequences WHERE branch=? AND appointment_date=? AND prefix=? FOR UPDATE");
    $stmt->execute([$branch,$date,$prefix]);
    $current=$stmt->fetchColumn();
    if ($current===false) {
        $existing=$pdo->prepare("SELECT COALESCE(MAX(CAST(SUBSTRING(queue_number,3) AS UNSIGNED)),0) FROM appointments WHERE center=? AND appointment_date=? AND queue_number LIKE ?");
        $existing->execute([$branch,$date,$prefix.'-%']);
        $num=((int)$existing->fetchColumn())+1;
        $insert=$pdo->prepare("INSERT INTO appointment_queue_sequences(branch,appointment_date,prefix,next_number) VALUES(?,?,?,?)");
        $insert->execute([$branch,$date,$prefix,$num+1]);
    } else {
        $num=max(1,(int)$current);
        $update=$pdo->prepare("UPDATE appointment_queue_sequences SET next_number=? WHERE branch=? AND appointment_date=? AND prefix=?");
        $update->execute([$num+1,$branch,$date,$prefix]);
    }
    return $prefix.'-'.str_pad((string)$num,3,'0',STR_PAD_LEFT);
}

function operations_admin_scope(PDO $pdo, array $admin): array {
    operations_ensure_tables($pdo);
    if ($admin['is_system_admin']) return [null,[]];
    return [' WHERE branch=?',[$admin['branch']]];
}

function operations_delivery_payload(PDO $pdo, array $admin): array {
    operations_ensure_tables($pdo);
    ensure_email_logs_table($pdo);
    ensure_sms_logs_table($pdo);
    $emailRows=$pdo->query("SELECT id,'email' channel,recipient,event_type,subject title,status,provider_response error_message,created_at FROM email_logs ORDER BY id DESC LIMIT 80")->fetchAll();
    $smsRows=$pdo->query("SELECT id,'sms' channel,recipient,event_type,LEFT(message,190) title,status,provider_response error_message,created_at FROM sms_logs ORDER BY id DESC LIMIT 80")->fetchAll();
    $inAppRows=$pdo->query("SELECT id,channel,COALESCE(recipient,CONCAT('Patient #',patient_id)) recipient,event_type,title,status,error_message,created_at FROM notification_delivery_logs ORDER BY id DESC LIMIT 80")->fetchAll();
    $rows=array_merge($emailRows,$smsRows,$inAppRows);
    usort($rows,fn($a,$b)=>strcmp((string)$b['created_at'],(string)$a['created_at']));
    $rows=array_slice($rows,0,100);
    $stats=['delivered'=>0,'failed'=>0,'skipped'=>0,'pending'=>0];
    foreach($rows as $row){$state=strtolower((string)$row['status']);if(in_array($state,['sent','delivered'],true))$stats['delivered']++;elseif($state==='failed')$stats['failed']++;elseif($state==='skipped')$stats['skipped']++;else$stats['pending']++;}
    return ['stats'=>$stats,'rows'=>$rows];
}

function operations_route(string $action, PDO $pdo, array $data): void {
    if ($action==='public_privacy_policy') {
        $policy=operations_current_policy($pdo);json_out(['ok'=>true,'policy'=>$policy]);
    }
    if ($action==='admin_caregiver_document') {
        require_admin_context($pdo,true);ensure_innovation_tables($pdo);$id=(int)($_GET['id']??0);
        $stmt=$pdo->prepare("SELECT verification_path,verification_name,verification_mime FROM family_care_links WHERE id=? AND verification_required=1 LIMIT 1");$stmt->execute([$id]);$row=$stmt->fetch();
        $relative=ltrim((string)($row['verification_path']??''),'/');$full=__DIR__.'/'.$relative;
        if(!$row||strpos($relative,'uploads/caregiver/')!==0||!is_file($full))json_out(['ok'=>false,'message'=>'Protected verification document not found.'],404);
        header_remove('Content-Type');header('Content-Type: '.($row['verification_mime']?:'application/octet-stream'));header('Content-Disposition: inline; filename="'.str_replace('"','',(string)($row['verification_name']?:'verification-document')).'"');header('X-Content-Type-Options: nosniff');header('Cache-Control: private, no-store');readfile($full);exit;
    }
    if ($action==='patient_privacy_status') {
        if(empty($_SESSION['patient_id']))json_out(['ok'=>false,'message'=>'Login required.'],401);
        operations_ensure_tables($pdo);$patientId=(int)$_SESSION['patient_id'];$policy=operations_current_policy($pdo);
        $consent=null;if($policy){$stmt=$pdo->prepare("SELECT * FROM patient_consents WHERE patient_id=? AND policy_id=? LIMIT 1");$stmt->execute([$patientId,(int)$policy['id']]);$consent=$stmt->fetch()?:null;}
        $stmt=$pdo->prepare("SELECT actor_type,actor_name,action,resource,purpose,branch,created_at FROM patient_access_history WHERE patient_id=? ORDER BY id DESC LIMIT 60");$stmt->execute([$patientId]);
        json_out(['ok'=>true,'policy'=>$policy,'consent'=>$consent,'has_current_consent'=>$policy?($consent&&$consent['status']==='Accepted'):true,'access_history'=>$stmt->fetchAll()]);
    }
    if ($action==='patient_privacy_accept') {
        if(empty($_SESSION['patient_id']))json_out(['ok'=>false,'message'=>'Login required.'],401);
        if(empty($data['accepted']))json_out(['ok'=>false,'message'=>'Confirm that you reviewed and accept the current policy.'],422);
        operations_record_consent($pdo,(int)$_SESSION['patient_id'],'patient_portal');json_out(['ok'=>true,'message'=>'Privacy consent recorded with the current policy version.']);
    }
    if ($action==='patient_privacy_withdraw') {
        if(empty($_SESSION['patient_id']))json_out(['ok'=>false,'message'=>'Login required.'],401);
        $patientId=(int)$_SESSION['patient_id'];$policy=operations_current_policy($pdo);if(!$policy)json_out(['ok'=>false,'message'=>'No active policy was found.'],404);
        $stmt=$pdo->prepare("UPDATE patient_consents SET status='Withdrawn',withdrawn_at=NOW() WHERE patient_id=? AND policy_id=? AND status='Accepted'");$stmt->execute([$patientId,(int)$policy['id']]);
        operations_log_patient_access($pdo,$patientId,'patient',$patientId,'Patient','Withdrew optional portal consent','Privacy consent','Portal consent withdrawn; legally required care and audit records remain retained.',null);
        json_out(['ok'=>true,'message'=>'Optional portal consent withdrawn. Existing records required for care, safety, audit, or law are not automatically deleted.']);
    }
    if ($action==='admin_operations_overview') {
        $admin=require_admin_context($pdo,true);operations_ensure_tables($pdo);ensure_innovation_tables($pdo);
        $schedules=$pdo->query("SELECT * FROM clinic_schedules ORDER BY branch,day_of_week")->fetchAll();
        $capacities=$pdo->query("SELECT * FROM clinic_capacity_rules ORDER BY branch,service")->fetchAll();
        $closures=$pdo->query("SELECT c.*,COALESCE(a.name,'System') created_by_name FROM clinic_closures c LEFT JOIN admins a ON a.id=c.created_by WHERE c.closure_date>=DATE_SUB(CURDATE(),INTERVAL 30 DAY) ORDER BY c.closure_date DESC,c.id DESC LIMIT 120")->fetchAll();
        $delivery=operations_delivery_payload($pdo,$admin);$policy=operations_current_policy($pdo);
        $patientCount=(int)$pdo->query("SELECT COUNT(*) FROM patients WHERE account_status='Active'")->fetchColumn();
        $accepted=0;if($policy){$stmt=$pdo->prepare("SELECT COUNT(*) FROM patient_consents pc JOIN patients p ON p.id=pc.patient_id WHERE pc.policy_id=? AND pc.status='Accepted' AND p.account_status='Active'");$stmt->execute([(int)$policy['id']]);$accepted=(int)$stmt->fetchColumn();}
        $pending=$pdo->query("SELECT f.id,f.relationship,f.requested_at,f.verification_status,f.verification_method,f.verification_notes,f.verification_path,f.verification_name,CONCAT(c.first_name,' ',c.last_name) caregiver_name,CONCAT(d.first_name,' ',d.last_name) dependent_name,d.patient_code,d.birthdate,d.is_senior,d.is_pwd FROM family_care_links f JOIN patients c ON c.id=f.caregiver_patient_id JOIN patients d ON d.id=f.dependent_patient_id WHERE f.verification_required=1 AND f.verification_status='Pending' ORDER BY f.requested_at ASC")->fetchAll();
        $retentionDays=(int)($policy['retention_days']??1825);$cutoff=date('Y-m-d',strtotime('-'.$retentionDays.' days'));
        $stmt=$pdo->prepare("SELECT COUNT(*) FROM appointments WHERE appointment_date<?");$stmt->execute([$cutoff]);$retentionCandidates=(int)$stmt->fetchColumn();
        $access=$pdo->query("SELECT h.actor_type,h.actor_name,h.action,h.resource,h.purpose,h.branch,h.created_at,p.patient_code,CONCAT(p.first_name,' ',p.last_name) patient_name FROM patient_access_history h JOIN patients p ON p.id=h.patient_id ORDER BY h.id DESC LIMIT 100")->fetchAll();
        json_out(['ok'=>true,'branches'=>allowed_rhu_branches(),'services'=>operations_services(),'schedules'=>$schedules,'capacities'=>$capacities,'closures'=>$closures,'delivery'=>$delivery,'policy'=>$policy,'privacy'=>['active_patients'=>$patientCount,'accepted'=>$accepted,'coverage_percent'=>$patientCount?(int)round($accepted/$patientCount*100):0,'retention_cutoff'=>$cutoff,'review_candidates'=>$retentionCandidates],'caregiver_verifications'=>$pending,'access_history'=>$access]);
    }
    if ($action==='admin_save_clinic_schedule') {
        $admin=require_admin_context($pdo,true);operations_ensure_tables($pdo);$branch=trim((string)($data['branch']??''));$day=(int)($data['day_of_week']??-1);$open=!empty($data['is_open']);
        if(!in_array($branch,allowed_rhu_branches(),true)||$day<0||$day>6)json_out(['ok'=>false,'message'=>'Select a valid RHU branch and weekday.'],422);
        $openTime=$open?trim((string)($data['open_time']??'')):null;$closeTime=$open?trim((string)($data['close_time']??'')):null;$breakStart=trim((string)($data['break_start']??''))?:null;$breakEnd=trim((string)($data['break_end']??''))?:null;$interval=(int)($data['slot_interval_minutes']??30);
        if($open&&(!$openTime||!$closeTime||strtotime($openTime)>=strtotime($closeTime)))json_out(['ok'=>false,'message'=>'Opening time must be earlier than closing time.'],422);
        if(($breakStart&&!$breakEnd)||(!$breakStart&&$breakEnd)||($breakStart&&strtotime($breakStart)>=strtotime($breakEnd)))json_out(['ok'=>false,'message'=>'Enter a valid break start and end time.'],422);
        if(!in_array($interval,[15,20,30,60],true))json_out(['ok'=>false,'message'=>'Slot interval must be 15, 20, 30, or 60 minutes.'],422);
        $stmt=$pdo->prepare("INSERT INTO clinic_schedules(branch,day_of_week,is_open,open_time,close_time,break_start,break_end,slot_interval_minutes,updated_by) VALUES(?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE is_open=VALUES(is_open),open_time=VALUES(open_time),close_time=VALUES(close_time),break_start=VALUES(break_start),break_end=VALUES(break_end),slot_interval_minutes=VALUES(slot_interval_minutes),updated_by=VALUES(updated_by)");
        $stmt->execute([$branch,$day,$open?1:0,$openTime,$closeTime,$breakStart,$breakEnd,$interval,$admin['id']]);
        $dayName=['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'][$day];
        $details=$open
          ?"{$branch} {$dayName} hours set to ".date('g:i A',strtotime($openTime)).'–'.date('g:i A',strtotime($closeTime))."."
          :"{$branch} marked closed every {$dayName}.";
        audit_event($pdo,$admin,'Operations','Updated Clinic Schedule',$details);json_out(['ok'=>true,'message'=>'Clinic schedule saved.']);
    }
    if ($action==='admin_save_capacity_rule') {
        $admin=require_admin_context($pdo,true);operations_ensure_tables($pdo);$branch=trim((string)($data['branch']??''));$service=trim((string)($data['service']??''));$capacity=(int)($data['capacity_per_slot']??0);$daily=(int)($data['daily_capacity']??0);
        if(!in_array($branch,allowed_rhu_branches(),true)||!in_array($service,operations_services(),true)||$capacity<1||$capacity>200||$daily<1||$daily>1000)json_out(['ok'=>false,'message'=>'Enter a valid RHU, service, per-slot capacity (1–200), and daily capacity (1–1000).'],422);
        $oldDaily=operations_daily_capacity_for($pdo,$branch);$oldStmt=$pdo->prepare("SELECT capacity_per_slot,daily_capacity FROM clinic_capacity_rules WHERE branch=? AND service=? LIMIT 1");$oldStmt->execute([$branch,$service]);$old=$oldStmt->fetch()?:['capacity_per_slot'=>0,'daily_capacity'=>$oldDaily];
        $stmt=$pdo->prepare("INSERT INTO clinic_capacity_rules(branch,service,capacity_per_slot,daily_capacity,updated_by) VALUES(?,?,?,?,?) ON DUPLICATE KEY UPDATE capacity_per_slot=VALUES(capacity_per_slot),daily_capacity=VALUES(daily_capacity),updated_by=VALUES(updated_by)");
        $stmt->execute([$branch,$service,$capacity,$daily,$admin['id']]);
        if($service!=='All Services')$pdo->prepare("UPDATE clinic_capacity_rules SET daily_capacity=?,updated_by=? WHERE branch=? AND service='All Services'")->execute([$daily,$admin['id'],$branch]);
        $actor=(string)($admin['name']??'System Administrator');$details=$service==='All Services'
          ?"{$actor} changed {$branch} daily capacity from {$oldDaily} to {$daily}; default per-slot capacity changed from ".(int)$old['capacity_per_slot']." to {$capacity}."
          :"{$actor} changed {$branch} {$service} capacity from ".(int)$old['capacity_per_slot']." to {$capacity} per slot; branch daily capacity changed from {$oldDaily} to {$daily}.";
        audit_event($pdo,$admin,'Operations','Changed Capacity Rule',$details);json_out(['ok'=>true,'message'=>'Capacity rule saved and is now active in patient booking.']);
    }
    if ($action==='admin_delete_capacity_rule') {
        $admin=require_admin_context($pdo,true);operations_ensure_tables($pdo);$id=(int)($data['id']??0);$stmt=$pdo->prepare("DELETE FROM clinic_capacity_rules WHERE id=? AND service<>'All Services'");$stmt->execute([$id]);if(!$stmt->rowCount())json_out(['ok'=>false,'message'=>'Only service-specific overrides can be removed.'],422);audit_event($pdo,$admin,'Operations','Removed Capacity Rule','Rule ID '.$id);json_out(['ok'=>true,'message'=>'Capacity override removed.']);
    }
    if ($action==='admin_save_closure') {
        $admin=require_admin_context($pdo,true);operations_ensure_tables($pdo);$branch=trim((string)($data['branch']??'All Branches'));$service=trim((string)($data['service']??'All Services'));$date=trim((string)($data['closure_date']??''));$type=trim((string)($data['closure_type']??'Holiday'));$title=trim((string)($data['title']??''));$details=trim((string)($data['details']??''));$allDay=!empty($data['closed_all_day']);$start=trim((string)($data['start_time']??''))?:null;$end=trim((string)($data['end_time']??''))?:null;
        if(!in_array($branch,array_merge(['All Branches'],allowed_rhu_branches()),true)||!in_array($service,operations_services(),true)||!preg_match('/^\d{4}-\d{2}-\d{2}$/',$date)||!in_array($type,['Holiday','Emergency','Maintenance','Special Event'],true)||$title==='')json_out(['ok'=>false,'message'=>'Complete the closure branch, service, date, type, and title.'],422);
        if(!$allDay&&(!$start||!$end||strtotime($start)>=strtotime($end)))json_out(['ok'=>false,'message'=>'Enter a valid partial-closure start and end time.'],422);
        $stmt=$pdo->prepare("INSERT INTO clinic_closures(branch,service,closure_date,closure_type,title,details,closed_all_day,start_time,end_time,created_by) VALUES(?,?,?,?,?,?,?,?,?,?)");$stmt->execute([$branch,$service,$date,$type,$title,$details,$allDay?1:0,$allDay?null:$start,$allDay?null:$end,$admin['id']]);$closureId=(int)$pdo->lastInsertId();
        $sql="SELECT id,patient_id,center,service,appointment_time FROM appointments WHERE appointment_date=? AND LOWER(status) IN ('pending','confirmed','waiting','hold')";$params=[$date];
        if($branch!=='All Branches'){$sql.=' AND center=?';$params[]=$branch;}if($service!=='All Services'){$sql.=' AND service=?';$params[]=$service;}
        $affected=0;$appts=$pdo->prepare($sql);$appts->execute($params);foreach($appts->fetchAll() as $appt){if(!$allDay){$when=strtotime($date.' '.$appt['appointment_time']);if($when<strtotime($date.' '.$start)||$when>=strtotime($date.' '.$end))continue;}$notice=($type==='Emergency'?'URGENT: ':'').$title.'. Your '.$appt['service'].' appointment schedule may be affected. '.($details?:'Please wait for RHU staff instructions or contact the health center before travelling.');create_patient_notification($pdo,(int)$appt['patient_id'],(int)$appt['id'],$type==='Emergency'?'danger':'warning','Clinic Schedule Advisory',$notice,'appointments.html?appointment='.(int)$appt['id'],'closure:'.$closureId.':appointment:'.(int)$appt['id']);$affected++;}
        audit_event($pdo,$admin,'Operations','Created Clinic Closure',$type.'; '.$date.'; '.$branch.'; affected appointments '.$affected);json_out(['ok'=>true,'message'=>($type==='Emergency'?'Emergency closure activated.':'Closure saved.').' '.$affected.' affected appointment'.($affected===1?' was':'s were').' notified.']);
    }
    if ($action==='admin_cancel_closure') {
        $admin=require_admin_context($pdo,true);operations_ensure_tables($pdo);$id=(int)($data['id']??0);$stmt=$pdo->prepare("UPDATE clinic_closures SET status='Cancelled' WHERE id=? AND status='Active'");$stmt->execute([$id]);if(!$stmt->rowCount())json_out(['ok'=>false,'message'=>'Active closure not found.'],404);audit_event($pdo,$admin,'Operations','Cancelled Clinic Closure','Closure ID '.$id);json_out(['ok'=>true,'message'=>'Closure cancelled and booking reopened under the regular schedule.']);
    }
    if ($action==='admin_save_privacy_policy') {
        $admin=require_admin_context($pdo,true);operations_ensure_tables($pdo);$version=trim((string)($data['version_label']??''));$title=trim((string)($data['title']??''));$content=trim((string)($data['content']??''));$days=(int)($data['retention_days']??0);$publish=!empty($data['publish']);
        if(!preg_match('/^[A-Za-z0-9._-]{1,40}$/',$version)||$title===''||mb_strlen($content)<120||$days<365||$days>7300)json_out(['ok'=>false,'message'=>'Enter a version, policy text of at least 120 characters, and retention from 365 to 7300 days.'],422);
        $pdo->beginTransaction();try{if($publish)$pdo->exec("UPDATE privacy_policy_versions SET status='Archived' WHERE status='Published'");$stmt=$pdo->prepare("INSERT INTO privacy_policy_versions(version_label,title,content,retention_days,status,effective_at,created_by) VALUES(?,?,?,?,?,?,?)");$stmt->execute([$version,$title,$content,$days,$publish?'Published':'Draft',$publish?date('Y-m-d H:i:s'):null,$admin['id']]);$pdo->commit();}catch(Throwable $e){if($pdo->inTransaction())$pdo->rollBack();if(stripos($e->getMessage(),'Duplicate')!==false)json_out(['ok'=>false,'message'=>'That policy version already exists. Use a new version label.'],409);throw $e;}
        audit_event($pdo,$admin,'Privacy','Created Privacy Policy','Version '.$version.'; '.($publish?'Published':'Draft'));json_out(['ok'=>true,'message'=>$publish?'New privacy policy published. Patients must accept this version for protected portal actions.':'Privacy policy draft saved.']);
    }
    if ($action==='admin_verify_caregiver') {
        $admin=require_admin_context($pdo,true);ensure_innovation_tables($pdo);$id=(int)($data['id']??0);$decision=trim((string)($data['decision']??''));$notes=trim((string)($data['notes']??''));
        if(!in_array($decision,['Verified','Rejected'],true))json_out(['ok'=>false,'message'=>'Select Verify or Reject.'],422);
        $stmt=$pdo->prepare("SELECT f.*,CONCAT(d.first_name,' ',d.last_name) dependent_name FROM family_care_links f JOIN patients d ON d.id=f.dependent_patient_id WHERE f.id=? AND f.verification_required=1 LIMIT 1");$stmt->execute([$id]);$link=$stmt->fetch();if(!$link)json_out(['ok'=>false,'message'=>'Caregiver verification request not found.'],404);
        $pdo->prepare("UPDATE family_care_links SET verification_status=?,verification_notes=?,verified_by_admin_id=?,verified_at=NOW() WHERE id=?")->execute([$decision,$notes,$admin['id'],$id]);
        $message=$decision==='Verified'?'RHU verification is complete. Caregiver access becomes active after patient consent is approved.':'RHU verification was rejected. Contact the health center if you need clarification.';
        create_patient_notification($pdo,(int)$link['caregiver_patient_id'],null,$decision==='Verified'?'success':'danger','Family Care Verification '.$decision,$message,'family.html');
        audit_event($pdo,$admin,'Family Care','Caregiver Verification '.$decision,'Family link ID '.$id);json_out(['ok'=>true,'message'=>'Caregiver verification marked '.$decision.'.']);
    }
    if ($action==='admin_log_patient_access') {
        $admin=require_admin_context($pdo);$patientId=(int)($data['patient_id']??0);if($patientId<1)json_out(['ok'=>false,'message'=>'Patient ID is required.'],422);require_patient_record_access($pdo,$patientId);
        operations_log_patient_access($pdo,$patientId,'admin',(int)$admin['id'],$admin['name'],'Viewed patient record','Patient profile','Appointment or patient-service administration',$admin['branch']);json_out(['ok'=>true]);
    }
}
