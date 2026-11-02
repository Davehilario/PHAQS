import fs from 'node:fs';
import path from 'node:path';

const root=path.resolve(new URL('..',import.meta.url).pathname);
const read=file=>fs.readFileSync(path.join(root,file),'utf8');
const api=read('backend/api.php');
const operations=read('backend/operations_features.php');
const innovation=read('backend/innovation_features.php');
const database=read('backend/database.sql');
const queue=read('admin/admin-queue.html');
const reports=read('admin/admin-reports.html');
const heatmap=read('admin/admin-heatmap.html');
const logs=read('admin/admin-logs.html');
const archive=read('admin/admin-archive.html');
const shell=read('admin/admin-shell.js');
const shellLock=read('admin/management-shell-lock.js');
const responsive=read('admin/management-responsive-final.css');
const notifications=read('patient/js/patient_notifications.js');
const patientBook=read('patient/js/patient_book.js');
const patientQueue=read('patient/js/patient_queue.js');
const tv=read('tv-display.html');

const checks=[
  ['Bookings are automatically confirmed',api.includes("VALUES(?,?,?,?,?,?,?,?, 'Confirmed')")&&api.includes('automatically confirmed and added to the RHU schedule')],
  ['Patient UI explains automatic confirmation and check-in',patientBook.includes('is confirmed at')&&patientQueue.includes('Appointment Confirmed')&&patientQueue.includes('live queue number will be created')],
  ['Booking creates an appointment reference, not a live queue',api.includes("queuePreview'=>'Assigned at check-in'")],
  ['Manual arrival creates the live queue number',api.includes('operations_issue_queue_number($pdo')&&api.includes("'Checked In Patient'")],
  ['QR arrival is restricted to confirmed appointments',innovation.includes('QR check-in is available once the appointment is confirmed')],
  ['Emergency walk-in requires a reason',api.includes('Enter the emergency reason or presenting concern')],
  ['Emergency queue uses E prefix',api.includes("$queueType === 'emergency' ? 'E'")],
  ['Emergency is sorted before priority and regular',queue.includes('(rank[a.type] ?? 2)')&&queue.includes('Add Emergency Walk-in')],
  ['Emergency confirmation explains immediate assessment',api.includes('Emergency cases are prioritised for immediate assessment')],
  ['Completed workflow timestamps are persisted',database.includes('service_started_at DATETIME')&&database.includes('completed_at DATETIME')],
  ['Daily RHU capacity is connected to booking',operations.includes('operations_daily_capacity_for')&&operations.includes('dailyRemaining')],
  ['Reports include operational KPIs',reports.includes('Average Waiting Time')&&reports.includes('Emergency Cases Handled')&&reports.includes('Previous-period Change')],
  ['Reports include busiest RHU and service insight',reports.includes('received the highest number of appointments')&&reports.includes('busiest service')],
  ['Reports no longer receive dashboard-only inquiry card',shell.includes("if(current!=='admin-dashboard.html')return")],
  ['Heatmap uses verified cases only',api.includes("dc.verification_status='Verified'")&&innovation.includes("verification_status='Verified'")],
  ['Heatmap explains warning levels',heatmap.includes('Within the expected recent count')&&heatmap.includes('significantly exceeded the recent baseline')],
  ['Heatmap detail excludes linked patient name',!heatmap.includes('<span>Linked Patient</span>')],
  ['Notification links preserve exact announcement destination',notifications.includes("rawLink.includes('dashboard.html') ? rawLink")],
  ['Notification dedupe is database-backed',database.includes('uniq_notification_dedupe')&&api.includes('INSERT IGNORE INTO notifications')],
  ['Audit Trail has user, branch, and date filters',logs.includes('id="filterUser"')&&logs.includes('id="filterBranch"')&&logs.includes('id="filterDateFrom"')],
  ['TV display limits upcoming list to the next three',api.includes("'waiting'=>array_slice($waiting, 0, 3)")&&tv.includes('Next 3 Queue Numbers')],
  ['Admin/Staff final responsive stylesheet loads everywhere',shellLock.includes('management-responsive-final.css')],
  ['Patient modal fits inside the viewport above the navbar',responsive.includes('z-index:2050!important')&&responsive.includes('max-height:calc(100dvh - 24px)')],
  ['Admin/Staff mobile reports stack cleanly',responsive.includes('.operations-kpi-grid')&&responsive.includes('grid-template-columns:1fr!important')],
  ['Browser confirmations use designed modal flow',!read('admin/admin-operations.js').includes('confirm(')&&read('admin/management-feedback.js').includes('window.hcConfirm')]
  ,['Archived patient accounts appear in Archive',archive.includes('r.patients || []')&&archive.includes('Patient Archived')&&api.includes("archived_at=NOW()")]
  ,['Archive page defines its table helpers',archive.includes('const PAGE_SIZE = 12')&&archive.includes('function statusBadge')&&archive.includes('function fmtDate')]
  ,['Admin and staff bell shows live system activity',api.includes("'recent_notifications'=>$recentNotifications")&&api.includes("if ($action === 'admin_notifications_read')")&&shell.includes('r.recent_notifications||[]')]
  ,['Staff activity notifications remain RHU-specific',api.includes("COALESCE(details,'') LIKE ?")&&api.includes("$activityParams[]='%'.$admin['branch'].'%'")]
  ,['New booking notification identifies the patient',api.includes("{$patientFullName} booked Appointment")&&api.includes("'name'=>$patientFullName")]
  ,['Notification panel uses compact top-aligned layout',read('admin/admin-shell.css').includes('align-items:flex-start!important')&&read('admin/admin-shell.css').includes('flex:0 1 auto!important')]
  ,['Admin notification destinations open exact records',read('admin/admin-appointments.html').includes("get('appointment')")&&read('admin/admin-messages.html').includes("get('patient_id')")&&read('admin/staff-messages.html').includes("get('patient_id')")]
];

let passed=0;
for(const [label,ok] of checks){
  console.log(`${ok?'PASS':'FAIL'}  ${label}`);
  if(ok)passed++;
}
console.log(`\n${passed}/${checks.length} live workflow checks passed.`);
if(passed!==checks.length)process.exitCode=1;
