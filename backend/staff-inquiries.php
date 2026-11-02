<?php
ini_set('display_errors','0');
ini_set('log_errors','1');
ob_start();
register_shutdown_function(function () {
    $error = error_get_last();
    if (!$error || !in_array($error['type'], array(E_ERROR,E_PARSE,E_CORE_ERROR,E_COMPILE_ERROR,E_USER_ERROR), true)) return;
    while (ob_get_level() > 0) ob_end_clean();
    if (!headers_sent()) {
        http_response_code(500);
        header('Content-Type: application/json; charset=utf-8');
        header('Cache-Control: no-store');
    }
    echo json_encode(array('ok'=>false,'message'=>'Patient Inquiries server error: '.$error['message']));
});

require __DIR__ . '/config.php';

function si_json($payload, $status = 200) {
    while (ob_get_level() > 0) ob_end_clean();
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit;
}
function si_input() {
    $raw = file_get_contents('php://input');
    $json = json_decode($raw, true);
    return is_array($json) ? $json : $_POST;
}
function si_columns($pdo, $table) {
    try { return $pdo->query("SHOW COLUMNS FROM `".$table."`")->fetchAll(PDO::FETCH_COLUMN); }
    catch (Throwable $e) { return array(); }
}
function si_allowed_branches() {
    return array('RHU I - Poblacion','RHU II - Cutcot','RHU III - Tinejero','RHU IV - Tibag');
}
function si_admin($pdo) {
    if (empty($_SESSION['admin_id'])) si_json(array('ok'=>false,'message'=>'Staff login required.'), 401);
    $stmt = $pdo->prepare('SELECT id,name,email,role,branch,account_status FROM admins WHERE id=? LIMIT 1');
    $stmt->execute(array((int)$_SESSION['admin_id']));
    $admin = $stmt->fetch();
    if (!$admin) si_json(array('ok'=>false,'message'=>'Staff account not found.'), 401);
    if (isset($admin['account_status']) && $admin['account_status'] !== 'Active') si_json(array('ok'=>false,'message'=>'This staff account is disabled.'), 403);
    $role = strtolower(trim((string)$admin['role']));
    $branch = strtolower(trim((string)$admin['branch']));
    $admin['is_system_admin'] = in_array($role, array('system administrator','super administrator','super admin'), true)
        || in_array($branch, array('all branches','all rhu branches','all branch','all rhu'), true);
    if ($admin['is_system_admin']) $admin['branch'] = 'All Branches';
    return $admin;
}
function si_patient_branch($pdo, $patientId, $fallback = '') {
    $allowed = si_allowed_branches();
    $statusColumns = si_columns($pdo, 'chat_thread_status');
    if (in_array('rhu_branch', $statusColumns, true)) {
        $stmt = $pdo->prepare('SELECT rhu_branch FROM chat_thread_status WHERE patient_id=? LIMIT 1');
        $stmt->execute(array($patientId));
        $branch = trim((string)$stmt->fetchColumn());
        if (in_array($branch, $allowed, true)) return $branch;
    }
    $appointmentColumns = si_columns($pdo, 'appointments');
    if (in_array('center', $appointmentColumns, true) && in_array('patient_id', $appointmentColumns, true)) {
        $stmt = $pdo->prepare('SELECT center FROM appointments WHERE patient_id=? ORDER BY appointment_date DESC,id DESC LIMIT 1');
        $stmt->execute(array($patientId));
        $branch = trim((string)$stmt->fetchColumn());
        if (in_array($branch, $allowed, true)) return $branch;
    }
    $patientColumns = si_columns($pdo, 'patients');
    if (in_array('preferred_rhu', $patientColumns, true)) {
        $stmt = $pdo->prepare('SELECT preferred_rhu FROM patients WHERE id=? LIMIT 1');
        $stmt->execute(array($patientId));
        $branch = trim((string)$stmt->fetchColumn());
        if (in_array($branch, $allowed, true)) return $branch;
    }
    return in_array($fallback, $allowed, true) ? $fallback : '';
}
function si_require_patient_access($pdo, $admin, $patientId) {
    if ($admin['is_system_admin']) return si_patient_branch($pdo, $patientId, 'RHU I - Poblacion');
    $branch = si_patient_branch($pdo, $patientId, (string)$admin['branch']);
    if ($branch !== (string)$admin['branch']) si_json(array('ok'=>false,'message'=>'This inquiry belongs to another RHU branch.'), 403);
    return $branch;
}
function si_thread_status($pdo, $patientId) {
    $columns = si_columns($pdo, 'chat_thread_status');
    if (!$columns) return array('status'=>'Open','rhu_branch'=>'','assigned_admin_id'=>null);
    $select = array('status');
    if (in_array('rhu_branch',$columns,true)) $select[]='rhu_branch';
    if (in_array('assigned_admin_id',$columns,true)) $select[]='assigned_admin_id';
    $stmt=$pdo->prepare('SELECT '.implode(',',$select).' FROM chat_thread_status WHERE patient_id=? LIMIT 1');
    $stmt->execute(array($patientId));
    $row=$stmt->fetch();
    return $row ?: array('status'=>'Open','rhu_branch'=>'','assigned_admin_id'=>null);
}
function si_upsert_status($pdo, $patientId, $status, $branch, $adminId) {
    $columns=si_columns($pdo,'chat_thread_status');
    if (!$columns) return;
    $fields=array('patient_id','status');$values=array($patientId,$status);$updates=array('status=VALUES(status)');
    if(in_array('rhu_branch',$columns,true)){$fields[]='rhu_branch';$values[]=$branch;$updates[]='rhu_branch=VALUES(rhu_branch)';}
    if(in_array('assigned_admin_id',$columns,true)){$fields[]='assigned_admin_id';$values[]=$adminId;$updates[]='assigned_admin_id=VALUES(assigned_admin_id)';}
    if(in_array('updated_at',$columns,true))$updates[]='updated_at=NOW()';
    $marks=implode(',',array_fill(0,count($fields),'?'));
    $sql='INSERT INTO chat_thread_status('.implode(',',$fields).') VALUES('.$marks.') ON DUPLICATE KEY UPDATE '.implode(',',$updates);
    $pdo->prepare($sql)->execute($values);
}

$action = isset($_GET['action']) ? (string)$_GET['action'] : '';
$data = si_input();

try {
    $admin = si_admin($pdo);

    if ($action === 'admin_me' || $action === 'session') {
        si_json(array('ok'=>true,'admin'=>array(
            'id'=>(int)$admin['id'],'name'=>$admin['name'],'email'=>$admin['email'],'role'=>$admin['role'],
            'branch'=>$admin['branch'],'is_system_admin'=>(bool)$admin['is_system_admin'],'loggedIn'=>true
        )));
    }

    if ($action === 'chat_threads') {
        $messageColumns = si_columns($pdo, 'chat_messages');
        if (!in_array('patient_id',$messageColumns,true)) si_json(array('ok'=>true,'threads'=>array(),'scope'=>$admin['branch']));
        $patientIds = $pdo->query('SELECT DISTINCT patient_id FROM chat_messages WHERE patient_id IS NOT NULL AND patient_id>0 ORDER BY patient_id DESC')->fetchAll(PDO::FETCH_COLUMN);
        $threads=array();
        $patientStmt=$pdo->prepare("SELECT id,CONCAT(COALESCE(first_name,''),' ',COALESCE(last_name,'')) AS patient_name,email FROM patients WHERE id=? LIMIT 1");
        $autoFilter=in_array('is_automated',$messageColumns,true)?' AND COALESCE(is_automated,0)=0':'';
        $lastStmt=$pdo->prepare('SELECT message,created_at FROM chat_messages WHERE patient_id=?'.$autoFilter.' ORDER BY id DESC LIMIT 1');
        $unreadSql=in_array('is_read',$messageColumns,true)?"SELECT COUNT(*) FROM chat_messages WHERE patient_id=? AND sender_type='patient' AND COALESCE(is_read,0)=0":"SELECT 0";
        $unreadStmt=$pdo->prepare($unreadSql);
        foreach($patientIds as $rawId){
            $patientId=(int)$rawId;
            $branch=si_patient_branch($pdo,$patientId,(string)$admin['branch']);
            if(!$admin['is_system_admin'] && $branch!==(string)$admin['branch']) continue;
            $patientStmt->execute(array($patientId));$patient=$patientStmt->fetch();if(!$patient)continue;
            $lastStmt->execute(array($patientId));$last=$lastStmt->fetch()?:array();
            if(strpos($unreadSql,'?')!==false){$unreadStmt->execute(array($patientId));$unread=(int)$unreadStmt->fetchColumn();}else{$unread=0;}
            $statusRow=si_thread_status($pdo,$patientId);
            $threads[]=array(
                'patient_id'=>$patientId,'patient_name'=>trim((string)$patient['patient_name']) ?: 'Patient','email'=>(string)$patient['email'],
                'last_at'=>isset($last['created_at'])?$last['created_at']:null,'last_message'=>isset($last['message'])?(string)$last['message']:'',
                'unread'=>$unread,'status'=>isset($statusRow['status'])?(string)$statusRow['status']:'Open','rhu_branch'=>$branch,
                'assigned_admin_id'=>!empty($statusRow['assigned_admin_id'])?(int)$statusRow['assigned_admin_id']:null
            );
        }
        usort($threads,function($a,$b){return strcmp((string)$b['last_at'],(string)$a['last_at']);});
        si_json(array('ok'=>true,'threads'=>$threads,'scope'=>$admin['is_system_admin']?'All Branches':$admin['branch']));
    }

    if ($action === 'chat_messages') {
        $patientId=(int)(isset($data['patient_id'])?$data['patient_id']:(isset($_GET['patient_id'])?$_GET['patient_id']:0));
        if($patientId<=0)si_json(array('ok'=>false,'message'=>'Choose a patient conversation first.'),422);
        $branch=si_require_patient_access($pdo,$admin,$patientId);
        $columns=si_columns($pdo,'chat_messages');
        $adminName=in_array('admin_id',$columns,true)?"LEFT JOIN admins a ON a.id=cm.admin_id":"";
        $adminSelect=in_array('admin_id',$columns,true)?",a.name AS admin_name":",NULL AS admin_name";
        $autoSelect=in_array('is_automated',$columns,true)?",cm.is_automated":",0 AS is_automated";
        $sql="SELECT cm.id,cm.patient_id,cm.sender_type,cm.message,cm.created_at{$autoSelect},CONCAT(p.first_name,' ',p.last_name) AS patient_name{$adminSelect} FROM chat_messages cm JOIN patients p ON p.id=cm.patient_id {$adminName} WHERE cm.patient_id=? ORDER BY cm.id ASC LIMIT 250";
        $stmt=$pdo->prepare($sql);$stmt->execute(array($patientId));$messages=array();
        foreach($stmt->fetchAll() as $row){$messages[]=array(
            'id'=>(int)$row['id'],'patient_id'=>(int)$row['patient_id'],'sender_type'=>$row['sender_type'],'message'=>$row['message'],
            'is_automated'=>(int)$row['is_automated'],'name'=>$row['sender_type']==='admin'?((string)$row['admin_name']?:'RHU Staff'):((string)$row['patient_name']?:'Patient'),'created_at'=>$row['created_at']
        );}
        if(in_array('is_read',$columns,true))$pdo->prepare("UPDATE chat_messages SET is_read=1 WHERE patient_id=? AND sender_type='patient'")->execute(array($patientId));
        si_json(array('ok'=>true,'patient_id'=>$patientId,'rhu_branch'=>$branch,'messages'=>$messages));
    }

    if ($action === 'chat_send') {
        $patientId=(int)(isset($data['patient_id'])?$data['patient_id']:0);
        $message=trim((string)(isset($data['message'])?$data['message']:''));
        if($patientId<=0)si_json(array('ok'=>false,'message'=>'Choose a patient conversation first.'),422);
        if($message==='')si_json(array('ok'=>false,'message'=>'Reply message is required.'),422);
        if(function_exists('mb_substr'))$message=mb_substr($message,0,1000);else$message=substr($message,0,1000);
        $branch=si_require_patient_access($pdo,$admin,$patientId);
        $columns=si_columns($pdo,'chat_messages');
        $fields=array('patient_id','sender_type','message');$values=array($patientId,'admin',$message);
        if(in_array('admin_id',$columns,true)){$fields[]='admin_id';$values[]=(int)$admin['id'];}
        if(in_array('is_read',$columns,true)){$fields[]='is_read';$values[]=0;}
        $marks=implode(',',array_fill(0,count($fields),'?'));
        $pdo->prepare('INSERT INTO chat_messages('.implode(',',$fields).') VALUES('.$marks.')')->execute($values);
        si_upsert_status($pdo,$patientId,'Waiting for Patient',$branch,(int)$admin['id']);
        si_json(array('ok'=>true,'id'=>(int)$pdo->lastInsertId(),'rhu_branch'=>$branch));
    }

    if ($action === 'chat_set_status') {
        $patientId=(int)(isset($data['patient_id'])?$data['patient_id']:0);
        $status=trim((string)(isset($data['status'])?$data['status']:'Open'));
        if(!in_array($status,array('Open','Waiting for Patient','Resolved'),true))si_json(array('ok'=>false,'message'=>'Invalid inquiry status.'),422);
        $branch=si_require_patient_access($pdo,$admin,$patientId);
        si_upsert_status($pdo,$patientId,$status,$branch,(int)$admin['id']);
        si_json(array('ok'=>true,'message'=>'Inquiry status updated.'));
    }

    si_json(array('ok'=>false,'message'=>'Unknown Patient Inquiries action.'),404);
} catch (Throwable $e) {
    error_log('[staff-inquiries] '.$e->getMessage());
    si_json(array('ok'=>false,'message'=>'Unable to load Patient Inquiries: '.$e->getMessage()),500);
}
