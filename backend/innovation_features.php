<?php

function ensure_innovation_tables(PDO $pdo): void {
    ensure_appointment_arrival_columns($pdo);
    ensure_announcement_attachment_columns($pdo);

    hc_add_column($pdo, 'announcements', 'priority', "ENUM('normal','important','urgent') NOT NULL DEFAULT 'normal' AFTER status");
    hc_add_column($pdo, 'announcements', 'target_barangay', "VARCHAR(120) NOT NULL DEFAULT 'All Barangays' AFTER branch");
    hc_add_column($pdo, 'announcements', 'publish_at', 'DATETIME NULL AFTER target_barangay');
    hc_add_column($pdo, 'announcements', 'expires_at', 'DATETIME NULL AFTER publish_at');

    $pdo->exec("CREATE TABLE IF NOT EXISTS announcement_reads (
      announcement_id INT NOT NULL,
      patient_id INT NOT NULL,
      read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (announcement_id,patient_id),
      INDEX idx_announcement_reads_patient (patient_id,read_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS family_care_links (
      id INT AUTO_INCREMENT PRIMARY KEY,
      caregiver_patient_id INT NOT NULL,
      dependent_patient_id INT NOT NULL,
      relationship VARCHAR(40) NOT NULL,
      status ENUM('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',
      requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      responded_at DATETIME NULL,
      UNIQUE KEY uniq_family_pair (caregiver_patient_id,dependent_patient_id),
      INDEX idx_family_dependent_status (dependent_patient_id,status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    hc_add_column($pdo,'family_care_links','verification_required','TINYINT(1) NOT NULL DEFAULT 0 AFTER relationship');
    hc_add_column($pdo,'family_care_links','verification_status',"ENUM('Not Required','Pending','Verified','Rejected') NOT NULL DEFAULT 'Not Required' AFTER verification_required");
    hc_add_column($pdo,'family_care_links','verification_method','VARCHAR(80) NULL AFTER verification_status');
    hc_add_column($pdo,'family_care_links','verification_notes','TEXT NULL AFTER verification_method');
    hc_add_column($pdo,'family_care_links','verification_path','VARCHAR(255) NULL AFTER verification_notes');
    hc_add_column($pdo,'family_care_links','verification_name','VARCHAR(255) NULL AFTER verification_path');
    hc_add_column($pdo,'family_care_links','verification_mime','VARCHAR(100) NULL AFTER verification_name');
    hc_add_column($pdo,'family_care_links','verified_by_admin_id','INT NULL AFTER verification_mime');
    hc_add_column($pdo,'family_care_links','verified_at','DATETIME NULL AFTER verified_by_admin_id');
    hc_add_column($pdo,'family_care_links','consent_scope',"VARCHAR(120) NOT NULL DEFAULT 'appointments_only' AFTER verified_at");

    $pdo->exec("CREATE TABLE IF NOT EXISTS qr_arrival_tokens (
      id BIGINT AUTO_INCREMENT PRIMARY KEY,
      appointment_id INT NOT NULL,
      patient_id INT NOT NULL,
      token_hash CHAR(64) NOT NULL UNIQUE,
      expires_at DATETIME NOT NULL,
      used_at DATETIME NULL,
      used_by_admin_id INT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_qr_appointment (appointment_id,used_at),
      INDEX idx_qr_recent (used_at,used_by_admin_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS queue_proximity_alerts (
      appointment_id INT PRIMARY KEY,
      patient_id INT NOT NULL,
      people_ahead INT NOT NULL,
      notified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_queue_proximity_patient (patient_id,notified_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}

function ensure_help_chat_automation(PDO $pdo): void {
    hc_add_column($pdo,'chat_messages','is_automated','TINYINT(1) NOT NULL DEFAULT 0 AFTER is_read');
}

function help_chat_has_any(string $text, array $keywords): bool {
    foreach($keywords as $keyword)if(mb_strpos($text,$keyword)!==false)return true;
    return false;
}

function help_chat_time_label($value): string {
    $value=trim((string)$value);if($value==='')return '';
    $timestamp=strtotime($value);return $timestamp?date('g:i A',$timestamp):$value;
}

function help_chat_active_appointment(PDO $pdo, int $patientId): ?array {
    $stmt=$pdo->prepare("SELECT queue_number,center,service,appointment_date,appointment_time,status FROM appointments WHERE patient_id=? AND appointment_date>=CURDATE() AND LOWER(status) IN ('pending','confirmed','waiting','hold','serving') ORDER BY appointment_date ASC,STR_TO_DATE(appointment_time,'%h:%i %p') ASC,id ASC LIMIT 1");
    $stmt->execute([$patientId]);$row=$stmt->fetch();return $row?:null;
}

function help_chat_appointment_reply(PDO $pdo, int $patientId, string $branch): string {
    $appointment=help_chat_active_appointment($pdo,$patientId);
    if(!$appointment)return "Automated appointment check: You do not have an upcoming active appointment. You can choose an available RHU, service, date, and time in Book Appointment.";
    $dateTimestamp=strtotime((string)$appointment['appointment_date']);
    $dateLabel=$dateTimestamp?date('l, F j, Y',$dateTimestamp):(string)$appointment['appointment_date'];
    return 'Automated appointment check: Your next appointment is '.$appointment['service'].' on '.$dateLabel.' at '.help_chat_time_label($appointment['appointment_time']).', '.$appointment['center'].'. Queue number: '.$appointment['queue_number'].'. Status: '.$appointment['status'].'.';
}

function help_chat_queue_reply(PDO $pdo, int $patientId): string {
    $appointment=help_chat_active_appointment($pdo,$patientId);
    if(!$appointment)return 'Automated queue check: You do not have an active appointment or queue ticket.';
    return 'Automated queue check: Your queue number is '.$appointment['queue_number'].' for '.$appointment['service'].' at '.$appointment['center'].'. Current status: '.$appointment['status'].'. Open Queue Status for the live number being served and people ahead.';
}

function help_chat_schedule_text(array $schedule): string {
    if(empty($schedule)||(int)($schedule['is_open']??0)!==1||empty($schedule['open_time'])||empty($schedule['close_time']))return 'Closed';
    $hours=help_chat_time_label($schedule['open_time']).'–'.help_chat_time_label($schedule['close_time']);
    if(!empty($schedule['break_start'])&&!empty($schedule['break_end']))$hours.='; break '.help_chat_time_label($schedule['break_start']).'–'.help_chat_time_label($schedule['break_end']);
    return $hours;
}

function help_chat_clinic_schedule_reply(PDO $pdo, string $branch, string $text): string {
    operations_ensure_tables($pdo);
    if(!in_array($branch,allowed_rhu_branches(),true))$branch=allowed_rhu_branches()[0];
    $dayNames=['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    $asksToday=help_chat_has_any($text,['today','ngayon','ngayong araw']);
    $asksWhenOpen=help_chat_has_any($text,['kailan bukas','kelan bukas','anong araw bukas','what days are you open']);
    $asksTomorrow=help_chat_has_any($text,['tomorrow']) || (help_chat_has_any($text,['bukas']) && !$asksWhenOpen);
    if($asksToday||$asksTomorrow){
        $date=date('Y-m-d',strtotime($asksTomorrow?'+1 day':'today'));
        $day=(int)date('w',strtotime($date));
        $schedule=operations_schedule_for($pdo,$branch,$day);
        $closure=$pdo->prepare("SELECT title,details,closed_all_day,start_time,end_time FROM clinic_closures WHERE closure_date=? AND status='Active' AND branch IN ('All Branches',?) AND service='All Services' ORDER BY FIELD(closure_type,'Emergency','Holiday','Maintenance','Special Event'),id DESC LIMIT 1");
        $closure->execute([$date,$branch]);$closed=$closure->fetch();
        $dateLabel=$dayNames[$day].', '.date('F j, Y',strtotime($date));
        if($closed&&(int)$closed['closed_all_day'])return 'Automated clinic schedule for '.$branch.': Closed on '.$dateLabel.' — '.$closed['title'].(!empty($closed['details'])?' ('.$closed['details'].')':'').'.';
        $reply='Automated clinic schedule for '.$branch.': '.$dateLabel.' — '.help_chat_schedule_text($schedule).'.';
        if($closed&&!empty($closed['start_time'])&&!empty($closed['end_time']))$reply.=' Partial closure: '.$closed['title'].' from '.help_chat_time_label($closed['start_time']).' to '.help_chat_time_label($closed['end_time']).'.';
        return $reply.' Available appointment slots still depend on the selected service and remaining capacity in Book Appointment.';
    }
    $stmt=$pdo->prepare('SELECT day_of_week,is_open,open_time,close_time,break_start,break_end FROM clinic_schedules WHERE branch=? ORDER BY day_of_week');
    $stmt->execute([$branch]);$byDay=[];foreach($stmt->fetchAll() as $row)$byDay[(int)$row['day_of_week']]=$row;
    $groups=[];foreach([1,2,3,4,5,6,0] as $day){$hours=help_chat_schedule_text($byDay[$day]??[]);$groups[$hours][]=$dayNames[$day];}
    $parts=[];foreach($groups as $hours=>$days)$parts[]=implode(', ',$days).': '.$hours;
    $closure=$pdo->prepare("SELECT closure_date,title FROM clinic_closures WHERE status='Active' AND branch IN ('All Branches',?) AND service='All Services' AND closure_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(),INTERVAL 14 DAY) ORDER BY closure_date,id LIMIT 1");
    $closure->execute([$branch]);$nextClosure=$closure->fetch();
    $reply='Automated clinic hours for '.$branch.': '.implode('; ',$parts).'.';
    if($nextClosure)$reply.=' Upcoming closure: '.$nextClosure['title'].' on '.date('F j, Y',strtotime($nextClosure['closure_date'])).'.';
    return $reply.' Service-specific available slots are shown live in Book Appointment.';
}

function help_chat_next_open_dates_reply(PDO $pdo, string $branch): string {
    operations_ensure_tables($pdo);
    if(!in_array($branch,allowed_rhu_branches(),true))$branch=allowed_rhu_branches()[0];
    $closure=$pdo->prepare("SELECT 1 FROM clinic_closures WHERE closure_date=? AND status='Active' AND closed_all_day=1 AND branch IN ('All Branches',?) AND service='All Services' LIMIT 1");
    $dates=[];
    for($offset=0;$offset<=21&&count($dates)<3;$offset++){
        $date=date('Y-m-d',strtotime('+'.$offset.' day'));
        $schedule=operations_schedule_for($pdo,$branch,(int)date('w',strtotime($date)));
        if(empty($schedule)||(int)($schedule['is_open']??0)!==1)continue;
        if($offset===0&&!empty($schedule['close_time'])&&time()>=strtotime($date.' '.$schedule['close_time']))continue;
        $closure->execute([$date,$branch]);
        if($closure->fetchColumn())continue;
        $dates[]=date('D, M j',strtotime($date)).' ('.help_chat_schedule_text($schedule).')';
    }
    if(!$dates)return 'Automated available-date check for '.$branch.': No open clinic day was found in the next 21 days. Please check the latest announcement or wait for RHU staff assistance.';
    return 'Automated available-date check for '.$branch.': The next clinic days are '.implode('; ',$dates).'. Choose your service and one of these dates in Book Appointment to see the exact remaining time slots. Sending a preferred date in chat does not create a booking.';
}

function help_chat_support_suffix(PDO $pdo): string {
    try{
        $stmt=$pdo->query("SELECT setting_key,setting_value FROM system_settings WHERE setting_key IN ('supportEmail','supportContact')");
        $settings=[];foreach($stmt->fetchAll() as $row)$settings[$row['setting_key']]=trim((string)$row['setting_value']);
        $contact=$settings['supportContact']??'';$email=$settings['supportEmail']??'';
        if($contact!==''&&$email!=='')return ' You may also contact '.$contact.' or email '.$email.'.';
        if($contact!=='')return ' You may also contact '.$contact.'.';
        if($email!=='')return ' You may also email '.$email.'.';
        return '';
    }catch(Throwable $error){return '';}
}

function help_chat_automatic_reply(PDO $pdo, string $message, string $branch, int $patientId): string {
    $text=mb_strtolower(trim($message));
    $normalized=trim((string)preg_replace('/[^\p{L}\p{N}]+/u',' ',$text));
    $prefix="Automated guidance for {$branch}: ";
    $emergency=['hirap huminga','difficulty breathing','chest pain','sakit sa dibdib','unconscious','walang malay','severe bleeding','malakas na pagdurugo','seizure','kombulsyon','emergency'];
    foreach($emergency as $keyword){
        if(mb_strpos($text,$keyword)!==false)return $prefix.'This may need urgent care. Please call 911 or go to the nearest emergency facility now. Do not wait for a chat reply. RHU staff will still be able to review your message.';
    }
    $asksPersonalSchedule=(bool)preg_match('/(?:appointment|schedule|sched)\s*(?:ko|my|akin)|(?:kailan|kelan|when).*(?:appointment|schedule|sched).*(?:ko|my|akin)/u',$normalized);
    if($asksPersonalSchedule)return help_chat_appointment_reply($pdo,$patientId,$branch);
    $asksPreferredDate=help_chat_has_any($normalized,['preferred date','preferred time','available date','date available','available time','time available','anong date','what date','what time available','anong oras available','available schedule','schedule available','available slot','slot available','may slot']);
    if($asksPreferredDate)return help_chat_next_open_dates_reply($pdo,$branch);
    $asksGeneralSchedule=(bool)preg_match('/^(?:kailan|kelan|when)(?:\s+ang)?\s+(?:schedule|sched)$/u',$normalized);
    if($asksGeneralSchedule)return help_chat_active_appointment($pdo,$patientId)?help_chat_appointment_reply($pdo,$patientId,$branch):help_chat_next_open_dates_reply($pdo,$branch);
    if(help_chat_has_any($text,['queue number ko','number ko','pila ko','turn ko','queue ko']))return help_chat_queue_reply($pdo,$patientId);
    if(help_chat_has_any($text,['clinic hours','clinic hour','anong oras','what time','open ba','bukas ba','kailan bukas','kelan bukas','anong araw bukas','oras ng rhu','oras ng clinic','schedule ng rhu','sched ng rhu','today','tomorrow','ngayon','bukas']))return help_chat_clinic_schedule_reply($pdo,$branch,$text);
    $rules=[
      [['appointment','book','booking','schedule','reschedule','cancel','kansel'],'For appointments, open Book Appointment or My Appointments. Include the patient name, preferred date, service, and concern so RHU staff can assist. Changes are confirmed only when reflected in My Appointments.'],
      [['queue','number','pila','waiting','wait','turn'],'Open Queue Status for the live queue number and estimated wait. If you are already at the RHU, present your QR to staff. You will also receive an alert when three or fewer patients are ahead.'],
      [['requirement','requirements','document','documents','valid id','dalhin','kailangan'],'Please bring a valid ID and your appointment QR. Requirements can vary by service, so tell us which service you selected and RHU staff will confirm any additional records or documents.'],
      [['qr','scan','check in','check-in','arrival'],'Show the one-time QR pass on your phone when you arrive. Staff must verify it at the assigned RHU on the appointment date; a used or expired pass cannot be reused.'],
      [['vaccine','vaccination','immunization','bakuna'],'Please state the vaccine or immunization service, patient age, and any existing immunization record. RHU staff must confirm eligibility, supply, schedule, and required documents.'],
      [['open','hours','oras','clinic hour'],'Open Book Appointment and select your RHU, service, and date to see the live available times.'],
      [['result','laboratory','lab result','medical record','record'],'For privacy, laboratory results and medical records are not interpreted by the automated reply. Please provide the appointment date and service; authorized RHU staff will assist you.']
    ];
    foreach($rules as [$keywords,$reply])foreach($keywords as $keyword)if(mb_strpos($text,$keyword)!==false)return $prefix.$reply;
    if(help_chat_has_any($normalized,['hello','hi','good morning','good afternoon','magandang umaga','magandang hapon']))return $prefix.'Hello! I can instantly check your appointment, queue number, clinic hours, and next open clinic dates. Try “Kailan schedule ko?”, “Kailan bukas ang RHU?”, “Preferred date”, or “Ano queue number ko?”.';
    return $prefix.'I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.'.help_chat_support_suffix($pdo);
}

function innovation_datetime($value, string $label): ?string {
    $value = trim((string)$value);
    if ($value === '') return null;
    $timestamp = strtotime($value);
    if (!$timestamp) json_out(['ok'=>false,'message'=>"Enter a valid {$label}."],422);
    return date('Y-m-d H:i:s',$timestamp);
}

function innovation_patient_can_manage(PDO $pdo, int $caregiverId, int $patientId): bool {
    if ($caregiverId === $patientId) return true;
    ensure_innovation_tables($pdo);
    $stmt=$pdo->prepare("SELECT 1 FROM family_care_links WHERE caregiver_patient_id=? AND dependent_patient_id=? AND status='Approved' AND (verification_required=0 OR verification_status='Verified') LIMIT 1");
    $stmt->execute([$caregiverId,$patientId]);
    return (bool)$stmt->fetchColumn();
}

function innovation_managed_patient_ids(PDO $pdo, int $caregiverId): array {
    ensure_innovation_tables($pdo);
    $stmt=$pdo->prepare("SELECT dependent_patient_id FROM family_care_links WHERE caregiver_patient_id=? AND status='Approved' AND (verification_required=0 OR verification_status='Verified')");
    $stmt->execute([$caregiverId]);
    return array_values(array_unique(array_merge([$caregiverId],array_map('intval',$stmt->fetchAll(PDO::FETCH_COLUMN)))));
}

function caregiver_verification_upload(): ?array {
    if(empty($_FILES['verification_document'])||(int)($_FILES['verification_document']['error']??UPLOAD_ERR_NO_FILE)===UPLOAD_ERR_NO_FILE)return null;
    $file=$_FILES['verification_document'];$error=(int)($file['error']??UPLOAD_ERR_NO_FILE);
    if($error!==UPLOAD_ERR_OK)json_out(['ok'=>false,'message'=>'The caregiver verification file could not be uploaded.'],422);
    if((int)($file['size']??0)>5*1024*1024)json_out(['ok'=>false,'message'=>'Verification documents must be 5 MB or smaller.'],422);
    $finfo=new finfo(FILEINFO_MIME_TYPE);$mime=(string)$finfo->file($file['tmp_name']);$allowed=['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp','application/pdf'=>'pdf'];
    if(!isset($allowed[$mime]))json_out(['ok'=>false,'message'=>'Upload a JPG, PNG, WEBP, or PDF verification document.'],422);
    $directory=__DIR__.'/uploads/caregiver';if(!is_dir($directory)&&!mkdir($directory,0750,true)&&!is_dir($directory))json_out(['ok'=>false,'message'=>'Unable to prepare the protected caregiver upload folder.'],500);
    $stored=bin2hex(random_bytes(24)).'.'.$allowed[$mime];if(!move_uploaded_file($file['tmp_name'],$directory.'/'.$stored))json_out(['ok'=>false,'message'=>'Unable to save the verification document.'],500);
    $name=preg_replace('/[^A-Za-z0-9._ -]/','_',basename((string)($file['name']??'verification-document')));
    return ['path'=>'uploads/caregiver/'.$stored,'name'=>mb_substr($name,0,255),'mime'=>$mime];
}

function delete_caregiver_verification_file($path): void {
    $path=ltrim((string)$path,'/');if($path===''||strpos($path,'uploads/caregiver/')!==0)return;$full=__DIR__.'/'.$path;if(is_file($full))@unlink($full);
}

function patient_requires_caregiver_verification(array $patient): bool {
    $minor=false;if(!empty($patient['birthdate'])){$born=strtotime($patient['birthdate']);if($born)$minor=(int)date('Y')-(int)date('Y',$born)-((date('md')<date('md',$born))?1:0)<18;}
    return $minor||!empty($patient['is_senior'])||!empty($patient['is_pwd']);
}

function innovation_announcement_recipient_ids(PDO $pdo, array $announcement): array {
    ensure_patient_management_columns($pdo);
    $rows=$pdo->query("SELECT id,barangay FROM patients WHERE account_status='Active'")->fetchAll();
    $branch=(string)($announcement['branch']??'All Branches');
    $barangay=(string)($announcement['target_barangay']??'All Barangays');
    $ids=[];
    foreach($rows as $patient){
        if($branch!=='All Branches' && patient_record_branch($pdo,(int)$patient['id'])!==$branch) continue;
        if($barangay!=='All Barangays' && strcasecmp(trim((string)$patient['barangay']),$barangay)!==0) continue;
        $ids[]=(int)$patient['id'];
    }
    return $ids;
}

function innovation_announcement_metrics(PDO $pdo, array $row): array {
    $recipients=innovation_announcement_recipient_ids($pdo,$row);
    $recipientCount=count($recipients);$readCount=0;
    if($recipientCount){
        $marks=implode(',',array_fill(0,$recipientCount,'?'));
        $params=array_merge([(int)$row['id']],$recipients);
        $stmt=$pdo->prepare("SELECT COUNT(*) FROM announcement_reads WHERE announcement_id=? AND patient_id IN ({$marks})");
        $stmt->execute($params);$readCount=(int)$stmt->fetchColumn();
    }
    $now=time();$publish=!empty($row['publish_at'])?strtotime($row['publish_at']):strtotime($row['created_at']??'now');
    $expires=!empty($row['expires_at'])?strtotime($row['expires_at']):null;
    $state=($row['status']??'Draft');
    if($state==='Published'&&$publish>$now)$state='Scheduled';
    elseif($state==='Published'&&$expires&&$expires<=$now)$state='Expired';
    return ['recipient_count'=>$recipientCount,'read_count'=>$readCount,'reach_percent'=>$recipientCount?(int)round(($readCount/$recipientCount)*100):0,'schedule_state'=>$state];
}

function innovation_announcement_row(array $row): array {
    $row=announcement_payload($row);
    $row['priority']=$row['priority']??'normal';
    $row['target_barangay']=$row['target_barangay']??'All Barangays';
    $row['is_read']=!empty($row['is_read']);
    return $row;
}

function innovation_notify_announcement(PDO $pdo, array $announcement): void {
    $type=($announcement['priority']??'normal')==='urgent'?'danger':(($announcement['priority']??'normal')==='important'?'warning':'info');
    $prefix=$type==='danger'?'URGENT: ':($type==='warning'?'Important: ':'');
    foreach(innovation_announcement_recipient_ids($pdo,$announcement) as $patientId){
        $announcementId=(int)($announcement['id']??0);
        create_patient_notification(
          $pdo,$patientId,null,$type,$prefix.'Health Center Announcement',
          (string)$announcement['title'],
          'dashboard.html?announcement='.$announcementId.'#announcements',
          'announcement:'.$announcementId
        );
    }
}

function innovation_queue_proximity_alerts(PDO $pdo, string $center): void {
    ensure_innovation_tables($pdo);
    $stmt=$pdo->prepare("SELECT id,patient_id,queue_number,service FROM appointments
      WHERE center=? AND appointment_date=CURDATE()
        AND (LOWER(status) IN ('hold','waiting') OR (LOWER(status)='confirmed' AND LOWER(COALESCE(arrival_status,'not_arrived'))='arrived'))
      ORDER BY CASE WHEN queue_number LIKE 'E-%' THEN 0 WHEN queue_number LIKE 'P-%' THEN 1 ELSE 2 END,
               CAST(SUBSTRING(queue_number,3) AS UNSIGNED)");
    $stmt->execute([$center]);$waiting=$stmt->fetchAll();
    foreach($waiting as $index=>$appointment){
        $ahead=(int)$index;
        if($ahead>3) continue;
        $insert=$pdo->prepare("INSERT IGNORE INTO queue_proximity_alerts(appointment_id,patient_id,people_ahead) VALUES(?,?,?)");
        $insert->execute([(int)$appointment['id'],(int)$appointment['patient_id'],$ahead]);
        if(!$insert->rowCount()) continue;
        $message=$ahead===0
          ? "You are next in line at {$center}. Please stay near the service area."
          : ($ahead===3
            ? "Your queue number is approaching. Please proceed to the waiting area. Three patients are ahead of {$appointment['queue_number']} at {$center}."
            : "Only {$ahead} patient".($ahead===1?' is':'s are')." ahead of queue {$appointment['queue_number']} at {$center}.");
        create_patient_notification($pdo,(int)$appointment['patient_id'],(int)$appointment['id'],'queue','Your Turn Is Getting Close',$message,'queue.html');
    }
}

if ($action === 'patient_announcements') {
    if(empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_innovation_tables($pdo);
    $patientId=(int)$_SESSION['patient_id'];
    $pstmt=$pdo->prepare('SELECT barangay FROM patients WHERE id=?');$pstmt->execute([$patientId]);$patient=$pstmt->fetch()?:[];
    $branch=patient_record_branch($pdo,$patientId);$barangay=trim((string)($patient['barangay']??''));
    $sql="SELECT an.*,COALESCE(ad.name,'Pulilan Health Center') created_by_name,
                 CASE WHEN ar.patient_id IS NULL THEN 0 ELSE 1 END is_read
          FROM announcements an
          LEFT JOIN admins ad ON ad.id=an.created_by
          LEFT JOIN announcement_reads ar ON ar.announcement_id=an.id AND ar.patient_id=?
          WHERE an.status='Published'
            AND (an.publish_at IS NULL OR an.publish_at<=NOW())
            AND (an.expires_at IS NULL OR an.expires_at>NOW())
            AND an.branch IN ('All Branches',?)
            AND (an.target_barangay='All Barangays' OR an.target_barangay=?)
          ORDER BY FIELD(an.priority,'urgent','important','normal'),COALESCE(an.publish_at,an.created_at) DESC
          LIMIT 6";
    $stmt=$pdo->prepare($sql);$stmt->execute([$patientId,$branch?:'__none__',$barangay?:'__none__']);
    json_out(['ok'=>true,'branch'=>$branch,'barangay'=>$barangay,'announcements'=>array_map('innovation_announcement_row',$stmt->fetchAll())]);
}

if ($action === 'patient_mark_announcement_read') {
    if(empty($_SESSION['patient_id'])) json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_innovation_tables($pdo);$id=(int)($data['id']??0);
    if($id<=0)json_out(['ok'=>false,'message'=>'Announcement ID is required.'],422);
    $patientId=(int)$_SESSION['patient_id'];$pstmt=$pdo->prepare('SELECT barangay FROM patients WHERE id=?');$pstmt->execute([$patientId]);$patient=$pstmt->fetch()?:[];$branch=patient_record_branch($pdo,$patientId);
    $valid=$pdo->prepare("SELECT 1 FROM announcements WHERE id=? AND status='Published' AND (publish_at IS NULL OR publish_at<=NOW()) AND (expires_at IS NULL OR expires_at>NOW()) AND branch IN ('All Branches',?) AND (target_barangay='All Barangays' OR target_barangay=?)");
    $valid->execute([$id,$branch?:'__none__',trim((string)($patient['barangay']??''))?:'__none__']);if(!$valid->fetchColumn())json_out(['ok'=>false,'message'=>'Announcement is not available to this patient.'],404);
    $pdo->prepare('INSERT IGNORE INTO announcement_reads(announcement_id,patient_id) VALUES(?,?)')->execute([$id,$patientId]);
    json_out(['ok'=>true]);
}

if ($action === 'admin_announcements') {
    $admin=require_admin_context($pdo);ensure_innovation_tables($pdo);
    if($admin['is_system_admin']){
        $rows=$pdo->query("SELECT an.*,COALESCE(ad.name,'Unknown') created_by_name FROM announcements an LEFT JOIN admins ad ON ad.id=an.created_by ORDER BY an.created_at DESC")->fetchAll();
    }else{
        $stmt=$pdo->prepare("SELECT an.*,COALESCE(ad.name,'Unknown') created_by_name FROM announcements an LEFT JOIN admins ad ON ad.id=an.created_by WHERE an.branch IN ('All Branches',?) ORDER BY an.created_at DESC");
        $stmt->execute([$admin['branch']]);$rows=$stmt->fetchAll();
    }
    $out=[];foreach($rows as $row)$out[]=array_merge(innovation_announcement_row($row),innovation_announcement_metrics($pdo,$row));
    json_out(['ok'=>true,'announcements'=>$out]);
}

if ($action === 'admin_save_announcement') {
    $admin=require_admin_context($pdo);ensure_innovation_tables($pdo);
    $id=(int)($data['id']??0);$title=trim((string)($data['title']??''));$message=trim((string)($data['message']??''));
    $branch=trim((string)($data['branch']??'All Branches'));$status=trim((string)($data['status']??'Published'));
    $priority=strtolower(trim((string)($data['priority']??'normal')));$barangay=trim((string)($data['target_barangay']??'All Barangays'));
    $publishAt=innovation_datetime($data['publish_at']??null,'publishing date');$expiresAt=innovation_datetime($data['expires_at']??null,'expiration date');
    if($title===''||$message==='')json_out(['ok'=>false,'message'=>'Title and description are required.'],422);
    if(!in_array($status,['Draft','Published','Archived'],true))json_out(['ok'=>false,'message'=>'Invalid announcement status.'],422);
    if(!in_array($priority,['normal','important','urgent'],true))json_out(['ok'=>false,'message'=>'Invalid announcement priority.'],422);
    // RHU staff are always locked to their assigned RHU on the server.
    // Do not trust a branch value submitted by the browser. System Administrators retain All Branches access.
    if(!$admin['is_system_admin']) $branch=$admin['branch'];
    if(!in_array($branch,array_merge(['All Branches'],allowed_rhu_branches()),true))json_out(['ok'=>false,'message'=>'Select a valid RHU branch.'],422);
    if($barangay!=='All Barangays'&&!in_array($barangay,pulilan_barangays(),true))json_out(['ok'=>false,'message'=>'Select a valid target barangay.'],422);
    if($publishAt&&$expiresAt&&strtotime($expiresAt)<=strtotime($publishAt))json_out(['ok'=>false,'message'=>'Expiration must be later than publishing time.'],422);
    $upload=save_announcement_attachment();$old=null;$isNew=$id<=0;
    if(!$isNew){
        $stmt=$pdo->prepare('SELECT * FROM announcements WHERE id=?');$stmt->execute([$id]);$old=$stmt->fetch();
        if(!$old)json_out(['ok'=>false,'message'=>'Announcement not found.'],404);
        if(!$admin['is_system_admin'] && ($old['branch']??'')!==$admin['branch']) json_out(['ok'=>false,'message'=>'You can edit announcements from your assigned RHU only.'],403);
        $remove=!empty($data['remove_attachment']);
        $path=$upload['path']??($remove?null:($old['attachment_path']??null));$name=$upload['name']??($remove?null:($old['attachment_name']??null));$mime=$upload['mime']??($remove?null:($old['attachment_mime']??null));
        $pdo->prepare('UPDATE announcements SET title=?,message=?,branch=?,target_barangay=?,status=?,priority=?,publish_at=?,expires_at=?,attachment_path=?,attachment_name=?,attachment_mime=? WHERE id=?')
            ->execute([$title,$message,$branch,$barangay,$status,$priority,$publishAt,$expiresAt,$path,$name,$mime,$id]);
        if(($upload||$remove)&&!empty($old['attachment_path']))delete_announcement_attachment($old['attachment_path']);
        audit_event($pdo,$admin,'Announcements','Updated Announcement','Announcement ID '.$id);
    }else{
        $pdo->prepare('INSERT INTO announcements(title,message,branch,target_barangay,status,priority,publish_at,expires_at,attachment_path,attachment_name,attachment_mime,created_by) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)')
            ->execute([$title,$message,$branch,$barangay,$status,$priority,$publishAt,$expiresAt,$upload['path']??null,$upload['name']??null,$upload['mime']??null,$admin['id']]);
        $id=(int)$pdo->lastInsertId();audit_event($pdo,$admin,'Announcements','Created Announcement','Announcement ID '.$id);
    }
    $stmt=$pdo->prepare('SELECT * FROM announcements WHERE id=?');$stmt->execute([$id]);$saved=$stmt->fetch();
    $immediate=$status==='Published'&&(!$publishAt||strtotime($publishAt)<=time())&&(!$expiresAt||strtotime($expiresAt)>time());
    $becamePublished=$isNew||(($old['status']??'')!=='Published');
    if($immediate&&$becamePublished)innovation_notify_announcement($pdo,$saved);
    json_out(['ok'=>true,'id'=>$id,'message'=>$publishAt&&strtotime($publishAt)>time()?'Announcement scheduled.':'Announcement saved.']);
}

if ($action === 'admin_delete_announcement') {
    $admin=require_admin_context($pdo);ensure_innovation_tables($pdo);$id=(int)($data['id']??0);
    $stmt=$pdo->prepare('SELECT title,branch,attachment_path FROM announcements WHERE id=?');$stmt->execute([$id]);$row=$stmt->fetch();
    if(!$row)json_out(['ok'=>false,'message'=>'Announcement not found.'],404);
    if(!$admin['is_system_admin'] && ($row['branch']??'')!==$admin['branch']) json_out(['ok'=>false,'message'=>'You can delete announcements from your assigned RHU only.'],403);
    $pdo->beginTransaction();
    try{$pdo->prepare('DELETE FROM announcement_reads WHERE announcement_id=?')->execute([$id]);$pdo->prepare('DELETE FROM announcements WHERE id=?')->execute([$id]);$pdo->commit();}
    catch(Throwable $e){if($pdo->inTransaction())$pdo->rollBack();throw $e;}
    delete_announcement_attachment($row['attachment_path']??'');audit_event($pdo,$admin,'Announcements','Deleted Announcement','Announcement ID '.$id);
    json_out(['ok'=>true,'message'=>'Announcement deleted.']);
}

if ($action === 'disease_early_warning') {
    $admin=require_admin_context($pdo);ensure_disease_cases_table($pdo);
    $where="case_date>=DATE_SUB(CURDATE(),INTERVAL 34 DAY) AND verification_status='Verified'";$params=[];
    if(!$admin['is_system_admin']){$where.=' AND rhu_branch=?';$params[]=$admin['branch'];}
    $stmt=$pdo->prepare("SELECT disease_category,barangay,rhu_branch,case_date FROM disease_cases WHERE {$where}");$stmt->execute($params);$rows=$stmt->fetchAll();
    $groups=[];$today=strtotime(date('Y-m-d'));
    foreach($rows as $row){
        $key=$row['disease_category'].'|'.$row['barangay'].'|'.$row['rhu_branch'];
        if(!isset($groups[$key]))$groups[$key]=['disease'=>$row['disease_category'],'barangay'=>$row['barangay'],'rhu'=>$row['rhu_branch'],'current'=>0,'baseline_total'=>0];
        $days=(int)floor(($today-strtotime($row['case_date']))/86400);
        if($days>=0&&$days<=6)$groups[$key]['current']++;elseif($days>=7&&$days<=34)$groups[$key]['baseline_total']++;
    }
    $alerts=[];$barangayRisk=[];
    foreach($groups as $group){
        $baseline=round($group['baseline_total']/4,2);$ratio=$baseline>0?round($group['current']/$baseline,2):($group['current']>0?99:0);
        $level='normal';if($group['current']>=5&&($baseline==0||$ratio>=2))$level='high';elseif($group['current']>=3&&($baseline==0||$ratio>=1.5))$level='watch';
        $item=array_merge($group,['baseline_weekly'=>$baseline,'ratio'=>$ratio,'level'=>$level]);
        if($level!=='normal')$alerts[]=$item;
        $bar=$group['barangay'];if(!isset($barangayRisk[$bar]))$barangayRisk[$bar]=['barangay'=>$bar,'current_cases'=>0,'high_alerts'=>0,'watch_alerts'=>0,'level'=>'normal'];
        $barangayRisk[$bar]['current_cases']+=$group['current'];
        if($level==='high'){$barangayRisk[$bar]['high_alerts']++;$barangayRisk[$bar]['level']='high';}
        elseif($level==='watch'){$barangayRisk[$bar]['watch_alerts']++;if($barangayRisk[$bar]['level']!=='high')$barangayRisk[$bar]['level']='watch';}
    }
    usort($alerts,fn($a,$b)=>($b['level']==='high'?2:1)<=>($a['level']==='high'?2:1)?:$b['current']<=>$a['current']);
    usort($barangayRisk,fn($a,$b)=>$b['current_cases']<=>$a['current_cases']);
    json_out([
      'ok'=>true,
      'generated_at'=>date(DATE_ATOM),
      'date_range'=>['current_from'=>date('Y-m-d',strtotime('-6 days')),'current_to'=>date('Y-m-d'),'baseline_from'=>date('Y-m-d',strtotime('-34 days')),'baseline_to'=>date('Y-m-d',strtotime('-7 days'))],
      'rule'=>'Verified cases from the current 7 days are compared with the weekly average of the previous 4 weeks.',
      'levels'=>[
        'normal'=>'Within the expected recent count.',
        'watch'=>'Count increased above the recent baseline.',
        'high'=>'Count significantly exceeded the recent baseline.'
      ],
      'privacy'=>'Barangay totals only; patient names are excluded.',
      'alerts'=>$alerts,
      'barangay_risk'=>array_values($barangayRisk)
    ]);
}

if ($action === 'patient_qr_ticket') {
    if(empty($_SESSION['patient_id']))json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_innovation_tables($pdo);$caregiver=(int)$_SESSION['patient_id'];$appointmentId=(int)($data['appointment_id']??$_GET['appointment_id']??0);
    if($appointmentId>0){$stmt=$pdo->prepare("SELECT a.*,CONCAT(p.first_name,' ',p.last_name) patient_name FROM appointments a JOIN patients p ON p.id=a.patient_id WHERE a.id=?");$stmt->execute([$appointmentId]);}
    else{$stmt=$pdo->prepare("SELECT a.*,CONCAT(p.first_name,' ',p.last_name) patient_name FROM appointments a JOIN patients p ON p.id=a.patient_id WHERE a.patient_id=? AND LOWER(a.status)='confirmed' ORDER BY a.appointment_date,a.id LIMIT 1");$stmt->execute([$caregiver]);}
    $appointment=$stmt->fetch();
    if(!$appointment||!innovation_patient_can_manage($pdo,$caregiver,(int)$appointment['patient_id']))json_out(['ok'=>false,'message'=>'Active appointment was not found or is outside your Family Care access.'],404);
    if(strtolower((string)$appointment['status'])!=='confirmed')json_out(['ok'=>false,'message'=>'QR check-in is available once the appointment is confirmed.'],409);
    if(strtotime($appointment['appointment_date'])<strtotime(date('Y-m-d')))json_out(['ok'=>false,'message'=>'This appointment QR has expired.'],410);
    $raw='PHC1-'.bin2hex(random_bytes(24));$hash=hash('sha256',$raw);$expires=$appointment['appointment_date'].' 23:59:59';
    $pdo->prepare('DELETE FROM qr_arrival_tokens WHERE appointment_id=? AND used_at IS NULL')->execute([(int)$appointment['id']]);
    $pdo->prepare('INSERT INTO qr_arrival_tokens(appointment_id,patient_id,token_hash,expires_at) VALUES(?,?,?,?)')->execute([(int)$appointment['id'],(int)$appointment['patient_id'],$hash,$expires]);
    json_out(['ok'=>true,'token'=>$raw,'expires_at'=>$expires,'appointment'=>appt_payload($appointment,$appointment['patient_name'])]);
}

if ($action === 'admin_scan_qr_arrival') {
    $admin=require_admin_context($pdo);ensure_innovation_tables($pdo);ensure_appointment_arrival_columns($pdo);operations_ensure_tables($pdo);$token=trim((string)($data['token']??''));
    if(!preg_match('/^PHC1-[a-f0-9]{48}$/',$token))json_out(['ok'=>false,'message'=>'Invalid Pulilan Health Center QR ticket.'],422);
    $stmt=$pdo->prepare("SELECT qt.id token_id,qt.appointment_id,qt.expires_at token_expires_at,qt.used_at token_used_at,a.*,CONCAT(p.first_name,' ',p.last_name) patient_name FROM qr_arrival_tokens qt JOIN appointments a ON a.id=qt.appointment_id JOIN patients p ON p.id=a.patient_id WHERE qt.token_hash=? LIMIT 1");
    $stmt->execute([hash('sha256',$token)]);$row=$stmt->fetch();
    if(!$row)json_out(['ok'=>false,'message'=>'QR ticket was not found.'],404);
    if(!empty($row['token_used_at']))json_out(['ok'=>false,'message'=>'This QR ticket was already used.'],409);
    if(strtotime($row['token_expires_at'])<time())json_out(['ok'=>false,'message'=>'This QR ticket has expired.'],410);
    if($row['appointment_date']!==date('Y-m-d'))json_out(['ok'=>false,'message'=>'QR arrival is available only on the appointment date.'],422);
    require_staff_branch($admin,$row['center']);
    $pdo->beginTransaction();
    try{
        $use=$pdo->prepare('UPDATE qr_arrival_tokens SET used_at=NOW(),used_by_admin_id=? WHERE id=? AND used_at IS NULL');$use->execute([$admin['id'],$row['token_id']]);
        if(!$use->rowCount())throw new RuntimeException('QR ticket was already used.');
        if(strtolower((string)$row['status'])!=='confirmed')throw new RuntimeException('This appointment must be confirmed before QR check-in.');
        if(strtolower((string)($row['arrival_status']??''))==='arrived')throw new RuntimeException('This patient has already checked in.');
        $prefix=($row['queue_type']??'regular')==='priority'?'P':'A';
        $liveQueue=operations_issue_queue_number($pdo,$row['center'],$row['appointment_date'],$prefix);
        $pdo->prepare("UPDATE appointments SET queue_number=?,arrival_status='arrived',arrived_at=NOW(),updated_at=NOW() WHERE id=?")->execute([$liveQueue,(int)$row['appointment_id']]);
        $row['queue_number']=$liveQueue;
        $pdo->commit();
    }catch(Throwable $e){if($pdo->inTransaction())$pdo->rollBack();json_out(['ok'=>false,'message'=>$e->getMessage()],409);}
    create_patient_notification($pdo,(int)$row['patient_id'],(int)$row['appointment_id'],'success','Arrival Confirmed',
      'Your QR was verified. Live queue '.$row['queue_number'].' was created at '.$row['center'].'.','queue.html');
    innovation_queue_proximity_alerts($pdo,$row['center']);
    $appointmentReference='APT-'.str_pad((string)$row['appointment_id'],5,'0',STR_PAD_LEFT);
    audit_event($pdo,$admin,'Queue Management','QR Check-in',
      "{$appointmentReference} checked in by QR at {$row['center']}; live queue {$row['queue_number']} created.");
    $fetch=$pdo->prepare("SELECT a.*,CONCAT(p.first_name,' ',p.last_name) patient_name FROM appointments a JOIN patients p ON p.id=a.patient_id WHERE a.id=?");$fetch->execute([$row['appointment_id']]);$appointment=$fetch->fetch();
    json_out(['ok'=>true,'message'=>'Arrival confirmed and patient added to the live queue.','appointment'=>appt_payload($appointment,$appointment['patient_name'])]);
}

if ($action === 'admin_qr_recent') {
    $admin=require_admin_context($pdo);ensure_innovation_tables($pdo);
    $sql="SELECT qt.used_at,a.queue_number,a.center,a.service,CONCAT(p.first_name,' ',p.last_name) patient_name,ad.name verified_by FROM qr_arrival_tokens qt JOIN appointments a ON a.id=qt.appointment_id JOIN patients p ON p.id=a.patient_id LEFT JOIN admins ad ON ad.id=qt.used_by_admin_id WHERE qt.used_at IS NOT NULL";
    $params=[];if(!$admin['is_system_admin']){$sql.=' AND a.center=?';$params[]=$admin['branch'];}$sql.=' ORDER BY qt.used_at DESC LIMIT 12';
    $stmt=$pdo->prepare($sql);$stmt->execute($params);json_out(['ok'=>true,'scans'=>$stmt->fetchAll()]);
}

if ($action === 'patient_family_list') {
    if(empty($_SESSION['patient_id']))json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_innovation_tables($pdo);$id=(int)$_SESSION['patient_id'];
    $stmt=$pdo->prepare("SELECT f.id,f.relationship,f.status,f.verification_required,f.verification_status,f.verification_method,f.verification_notes,f.consent_scope,f.requested_at,f.responded_at,p.id patient_db_id,p.patient_code,p.first_name,p.last_name,p.email,p.phone,p.address,p.birthdate,p.gender,p.barangay,p.preferred_rhu FROM family_care_links f JOIN patients p ON p.id=f.dependent_patient_id WHERE f.caregiver_patient_id=? ORDER BY f.requested_at DESC");$stmt->execute([$id]);$outgoing=$stmt->fetchAll();
    $stmt=$pdo->prepare("SELECT f.id,f.relationship,f.status,f.verification_required,f.verification_status,f.verification_method,f.verification_notes,f.consent_scope,f.requested_at,p.id caregiver_db_id,p.patient_code,p.first_name,p.last_name,p.email FROM family_care_links f JOIN patients p ON p.id=f.caregiver_patient_id WHERE f.dependent_patient_id=? ORDER BY f.requested_at DESC");$stmt->execute([$id]);$incoming=$stmt->fetchAll();
    foreach($outgoing as &$item)$item['can_manage']=$item['status']==='Approved'&&(!(int)$item['verification_required']||$item['verification_status']==='Verified');unset($item);
    $dependentIds=array_map(fn($x)=>(int)$x['patient_db_id'],array_filter($outgoing,fn($x)=>!empty($x['can_manage'])));
    $appointments=[];if($dependentIds){$marks=implode(',',array_fill(0,count($dependentIds),'?'));$stmt=$pdo->prepare("SELECT a.*,CONCAT(p.first_name,' ',p.last_name) patient_name FROM appointments a JOIN patients p ON p.id=a.patient_id WHERE a.patient_id IN ({$marks}) ORDER BY a.id DESC");$stmt->execute($dependentIds);$appointments=array_map(fn($r)=>appt_payload($r,$r['patient_name']),$stmt->fetchAll());}
    json_out(['ok'=>true,'outgoing'=>$outgoing,'incoming'=>$incoming,'dependent_appointments'=>$appointments]);
}

if ($action === 'patient_family_request') {
    if(empty($_SESSION['patient_id']))json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_innovation_tables($pdo);$caregiver=(int)$_SESSION['patient_id'];operations_require_patient_consent($pdo,$caregiver);$identifier=trim((string)($data['identifier']??''));$relationship=trim((string)($data['relationship']??''));$method=trim((string)($data['verification_method']??''));
    $allowed=['Parent','Guardian','Spouse','Adult Child','Sibling','Other'];if(!in_array($relationship,$allowed,true))json_out(['ok'=>false,'message'=>'Select a valid relationship.'],422);
    $stmt=$pdo->prepare('SELECT id,first_name,last_name,birthdate,is_senior,is_pwd FROM patients WHERE (LOWER(email)=LOWER(?) OR patient_code=?) AND account_status=\'Active\' LIMIT 1');$stmt->execute([$identifier,$identifier]);$dependent=$stmt->fetch();
    if(!$dependent)json_out(['ok'=>false,'message'=>'No active patient matches that email or patient ID.'],404);
    if((int)$dependent['id']===$caregiver)json_out(['ok'=>false,'message'=>'You cannot add your own account as a dependent.'],422);
    $upload=caregiver_verification_upload();$required=patient_requires_caregiver_verification($dependent)||$upload!==null;
    if($required&&!$upload)json_out(['ok'=>false,'message'=>'This dependent is a minor, senior citizen, or PWD. Upload a supporting document for RHU verification.'],422);
    if($required&&!in_array($method,['Birth Certificate','Guardian ID / Authorization','Senior Citizen ID','PWD ID','Other Supporting Document'],true))json_out(['ok'=>false,'message'=>'Select the supporting-document type.'],422);
    $old=$pdo->prepare("SELECT verification_path FROM family_care_links WHERE caregiver_patient_id=? AND dependent_patient_id=?");$old->execute([$caregiver,(int)$dependent['id']]);$oldPath=$old->fetchColumn();
    $pdo->prepare("INSERT INTO family_care_links(caregiver_patient_id,dependent_patient_id,relationship,verification_required,verification_status,verification_method,verification_path,verification_name,verification_mime,status) VALUES(?,?,?,?,?,?,?,?,?,'Pending') ON DUPLICATE KEY UPDATE relationship=VALUES(relationship),verification_required=VALUES(verification_required),verification_status=VALUES(verification_status),verification_method=VALUES(verification_method),verification_notes=NULL,verification_path=VALUES(verification_path),verification_name=VALUES(verification_name),verification_mime=VALUES(verification_mime),verified_by_admin_id=NULL,verified_at=NULL,status='Pending',requested_at=NOW(),responded_at=NULL")
        ->execute([$caregiver,(int)$dependent['id'],$relationship,$required?1:0,$required?'Pending':'Not Required',$required?$method:null,$upload['path']??null,$upload['name']??null,$upload['mime']??null]);
    if($oldPath&&$upload)delete_caregiver_verification_file($oldPath);
    $me=$pdo->prepare("SELECT CONCAT(first_name,' ',last_name) FROM patients WHERE id=?");$me->execute([$caregiver]);
    create_patient_notification($pdo,(int)$dependent['id'],null,'info','Family Care Request',trim((string)$me->fetchColumn()).' requested caregiver access. Review and approve it from Family Care.','family.html');
    json_out(['ok'=>true,'message'=>$required?'Family Care request sent. Access requires both patient consent and RHU document verification.':'Family Care request sent for patient consent.']);
}

if ($action === 'patient_family_respond') {
    if(empty($_SESSION['patient_id']))json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_innovation_tables($pdo);operations_require_patient_consent($pdo,(int)$_SESSION['patient_id']);$id=(int)($data['id']??0);$decision=trim((string)($data['decision']??''));
    if(!in_array($decision,['Approved','Rejected'],true))json_out(['ok'=>false,'message'=>'Invalid consent decision.'],422);
    $stmt=$pdo->prepare("UPDATE family_care_links SET status=?,responded_at=NOW() WHERE id=? AND dependent_patient_id=? AND status='Pending'");$stmt->execute([$decision,$id,(int)$_SESSION['patient_id']]);
    if(!$stmt->rowCount())json_out(['ok'=>false,'message'=>'Pending request was not found.'],404);
    json_out(['ok'=>true,'message'=>$decision==='Approved'?'Caregiver access approved.':'Caregiver request rejected.']);
}

if ($action === 'patient_family_remove') {
    if(empty($_SESSION['patient_id']))json_out(['ok'=>false,'message'=>'Login required.'],401);
    ensure_innovation_tables($pdo);$id=(int)($data['id']??0);$patient=(int)$_SESSION['patient_id'];
    $stmt=$pdo->prepare('DELETE FROM family_care_links WHERE id=? AND (caregiver_patient_id=? OR dependent_patient_id=?)');$stmt->execute([$id,$patient,$patient]);
    if(!$stmt->rowCount())json_out(['ok'=>false,'message'=>'Family Care link was not found.'],404);
    json_out(['ok'=>true,'message'=>'Family Care access removed.']);
}
