(function(){
  const API = (location.pathname.includes('/admin/') || location.pathname.includes('/patient/')) ? '../backend/api.php' : 'backend/api.php';
  const $ = (id)=>document.getElementById(id);
  async function api(action, data={}){
    const res = await fetch(API+'?action='+encodeURIComponent(action), { method:'POST', credentials:'include', cache:'no-store', headers:{'Content-Type':'application/json','Accept':'application/json'}, body:JSON.stringify(data) });
    const raw = await res.text();
    let json;
    try { json = raw ? JSON.parse(raw) : {ok:false,message:'The server returned an empty response.'}; }
    catch (_) { json={ok:false,message:'Server error: '+String(raw||'Invalid response').replace(/<[^>]*>/g,' ').replace(/\s+/g,' ').trim().slice(0,300)}; }
    json._httpStatus=res.status;
    if(!res.ok && !json.message) json.message='Request failed.';
    return json;
  }
  function msg(id, cls, text){ const el=$(id); if(!el) return; el.style.display='block'; el.style.visibility='visible'; el.className=cls; el.innerHTML=text; }
  function activeAppt(appts){ return (appts||[]).find(a=>['Pending','Confirmed','Serving','Hold','waiting','confirmed','serving','hold'].includes(String(a.status||''))) || null; }
  function setPatientUi(p){
    if(!p) return;
    window.__HC_PATIENT__ = p;
    const name=p.name||'Patient', initial=name.charAt(0).toUpperCase();
    ['welcomeName'].forEach(id=>{const e=$(id); if(e) e.innerText='Welcome, '+name+'!';});
    ['avatarBtn','mobAvatar'].forEach(id=>{const e=$(id); if(e) e.innerText=initial;});
    ['userName','mobName','headerName'].forEach(id=>{const e=$(id); if(e) e.innerText=name;});
  }
  function setAdminUi(a){
    if(!a) return; window.__HC_ADMIN__=a;
    document.querySelectorAll('.admin-name,#adminName').forEach(e=>e.textContent=a.name||'System Administrator');
    document.querySelectorAll('.admin-role,#adminRole').forEach(e=>e.textContent=a.role||'System Administrator');
    const roleText=String(a.role||'').toLowerCase();
    const branchText=String(a.branch||'').toLowerCase();
    const isStaff=roleText.includes('staff') || roleText.includes('rhu') || (!roleText.includes('admin') && branchText && !branchText.includes('all'));
    document.body.classList.toggle('staff-role',isStaff);
    document.querySelectorAll('.logo-area small').forEach(e=>e.textContent=isStaff?'RHU Staff Panel':'Admin Panel');
    applyAdminAccess(a);
  }
  const STAFF_ALLOWED_PAGES = new Set(['admin-dashboard.html','admin-appointments.html','admin-queue.html','admin-qr-scanner.html','admin-patients.html','inquiries-router.html','staff-messages.html','admin-announcements.html','admin-heatmap.html','admin-disease-cases.html']);
  const ADMIN_ONLY_PAGES = new Set(['admin-reports.html','admin-users.html','admin-logs.html','admin-archive.html','admin-backup.html']);
  function isSystemAdministrator(a){
    const role=String(a?.role||'').trim().toLowerCase();
    const branch=String(a?.branch||'').trim().toLowerCase();
    return ['system administrator','super administrator','super admin'].includes(role) || ['all branches','all rhu branches','all branch','all rhu'].includes(branch);
  }
  function adminPageName(){ return location.pathname.split('/').pop().toLowerCase(); }
  function applyAdminAccess(a){
    const isAdmin=isSystemAdministrator(a);
    document.body.classList.toggle('rhu-staff-session',!isAdmin);
    document.body.classList.toggle('system-admin-session',isAdmin);
    if(isAdmin) return;

    document.querySelectorAll('a[href]').forEach(link=>{
      const page=(link.getAttribute('href')||'').split(/[?#]/)[0].split('/').pop().toLowerCase();
      if(ADMIN_ONLY_PAGES.has(page)) link.remove();
    });
    document.querySelectorAll('.sidebar-section-label').forEach(label=>{
      if(label.textContent.trim().toLowerCase()!=='main') label.remove();
    });
    document.querySelectorAll('.sidebar-section-label').forEach(label=>{
      let next=label.nextElementSibling, hasItem=false;
      while(next && !next.classList.contains('sidebar-section-label')){
        if(next.matches('a,button')) hasItem=true;
        next=next.nextElementSibling;
      }
      if(!hasItem) label.remove();
    });
    if(ADMIN_ONLY_PAGES.has(adminPageName()) || !STAFF_ALLOWED_PAGES.has(adminPageName())){
      location.replace('admin-dashboard.html?access=staff-limited');
    }
  }
  async function requirePatient(){ const me=await api('patient_me'); if(!me.ok){ location.href='login.html'; return null;} setPatientUi(me.patient); return me.patient; }
  async function requireAdmin(){ const me=await api('admin_me'); if(!me.ok){ if(Number(me._httpStatus)===401) location.replace('admin-login.html?reason=session-expired'); else console.error(me.message||'Unable to verify staff session.'); return null;} setAdminUi(me.admin); return me.admin; }
  async function syncPatient(){
    const me = await api('patient_me'); if(me.ok) setPatientUi(me.patient);
    const ap = await api('patient_appointments'); if(ap.ok){ window.__HC_APPOINTMENTS__=ap.appointments||[]; window.__HC_ACTIVE_APPOINTMENT__=activeAppt(ap.appointments); window.dispatchEvent(new CustomEvent('hc:patientAppointments',{detail:ap})); }
    const q = await api('patient_queue_data'); if(q.ok){ window.__HC_QUEUE_DATA__=q.queueData||{}; window.__HC_ACTIVE_APPOINTMENT__=q.appointment||window.__HC_ACTIVE_APPOINTMENT__||null; window.dispatchEvent(new CustomEvent('hc:queueData',{detail:q})); }
  }
  async function syncAdmin(){
    const data = await api('admin_data'); if(data.ok){ window.__HC_PATIENTS__=data.patients||[]; window.__HC_APPOINTMENTS__=data.appointments||[]; window.dispatchEvent(new CustomEvent('hc:adminData',{detail:data})); }
    const q = await api('queue_data'); if(q.ok){ window.__HC_QUEUE_DATA__=q.queueData||{}; window.dispatchEvent(new CustomEvent('hc:queueData',{detail:q})); }
  }
  document.addEventListener('submit', async function(e){
    const form=e.target; if(!form || !form.id) return;
    if(form.id==='loginForm' && location.pathname.includes('/patient/')){
      e.preventDefault(); e.stopImmediatePropagation();
      const email=$('email')?.value.trim()||'', password=$('password')?.value||'';
      const btn=$('loginBtn'); if(btn){btn.innerHTML='Checking...'; btn.disabled=true;}
      const r=await api('patient_login',{email,password});
      if(r.ok){ setPatientUi(r.patient); msg('loginMessage','success-msg','Account verified. Opening your patient dashboard…'); setTimeout(()=>location.replace('dashboard.html'),500); }
      else { if(btn){btn.innerHTML='<i class="fa-regular fa-user"></i> Login'; btn.disabled=false;} msg('loginMessage','error-msg',r.message||'Invalid email or password.'); }
    }
    if(form.id==='registerForm'){
      e.preventDefault(); e.stopImmediatePropagation();
      const firstName=$('firstName')?.value.trim()||'', lastName=$('lastName')?.value.trim()||'', email=$('email')?.value.trim()||'', password=$('password')?.value||'', confirmPassword=$('confirmPassword')?.value||'';
      if(password!==confirmPassword){ const el=$('matchError'); if(el) el.innerHTML='Passwords do not match'; return; }
      const r=await api('patient_register',{firstName,lastName,email,password});
      if(r.ok){ const sn=$('successNotice'); if(sn) sn.style.display='flex'; setTimeout(()=>location.href='login.html',900); }
      else { const el=$('emailError')||$('successText'); if(el) el.innerHTML=r.message||'Registration failed.'; }
    }
    if(form.id==='appointmentForm'){
      e.preventDefault(); e.stopImmediatePropagation();
      const center=$('healthCenter')?.value||'', service=$('service')?.value||'', date=$('date')?.value||'';
      const time=(window.selectedTime)||document.querySelector('.time-slot.active, .time-slot.selected')?.innerText?.split('\n')[0]?.trim()||'';
      if(!center||!service||!date||!time){ alert('Please complete all booking fields.'); return; }
      const r=await api('book_appointment',{center,service,date,time,isPriority:!!window.isPriority,priorityReason:window.isSenior?'Senior Citizen':(window.isPwd?'PWD':'')});
      if(r.ok){ alert('Appointment booked successfully! Your queue number: '+r.appointment.queue); location.href='dashboard.html'; }
      else alert(r.message||'Booking failed.');
    }
  }, true);
  function activeAdminBranch(){
    const admin=window.__HC_ADMIN__;
    if(admin && !isSystemAdministrator(admin) && admin.branch) return admin.branch;
    const t=document.querySelector('.branch-tab.active');
    const label=(t?t.textContent:'').replace(/\s+/g,' ').trim();
    const match=Object.keys(window.__HC_QUEUE_DATA__||{}).find(name=>name===label||name.startsWith(label+' -'));
    return match||label||'RHU I - Poblacion';
  }
  async function queueAction(type, queue){ const r=await api('queue_action',{type,center:activeAdminBranch(),queue:queue||''}); if(!r.ok){alert(r.message||'Queue action failed.'); return;} await syncAdmin(); location.reload(); }
  window.callNext=()=>queueAction('call_next'); window.callSpecific=(n)=>queueAction('call_specific',n); window.markDone=(n)=>queueAction('done',n); window.markNoShow=(n)=>queueAction('no_show',n); window.holdCurrent=()=>queueAction('hold'); window.removeQ=(n)=>queueAction('remove',n); window.doRemoveQ=(n)=>queueAction('remove',n); window.confirmReset=async()=>{const approved=window.phaqsConfirm?await window.phaqsConfirm('All active queue entries for this branch will be cleared.',{title:'Reset this branch queue?',confirmText:'Reset queue',danger:true}):confirm('Clear active queue for this branch?');if(approved)queueAction('reset');};
  window.hcApi=api; window.backendSyncPatient=syncPatient; window.backendSyncAdmin=syncAdmin; window.backendRequirePatient=requirePatient; window.backendRequireAdmin=requireAdmin;
  document.addEventListener('DOMContentLoaded', async function(){
    const p=location.pathname;
    if(p.includes('/patient/') && !/login|register|index|reset-password/.test(p)) syncPatient();
    if(p.includes('/admin/') && !p.includes('admin-login')){
      const admin=await requireAdmin();
      if(admin && !ADMIN_ONLY_PAGES.has(adminPageName())) await syncAdmin();
    }
  });
})();
