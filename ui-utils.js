(function () {
  function ensureDialogStyles() {
    if (document.getElementById("plainDialogInlineStyles")) return;
    const style = document.createElement("style");
    style.id = "plainDialogInlineStyles";
    style.textContent = ".plain-dialog-backdrop{position:fixed;inset:0;z-index:5000;display:flex;align-items:center;justify-content:center;padding:18px;background:rgba(15,23,42,.38)}.plain-dialog{width:min(420px,100%);background:#fff;border:1px solid #dfe7f1;border-radius:10px;box-shadow:0 18px 40px rgba(15,23,42,.18);font-family:Inter,system-ui,sans-serif;overflow:hidden}.plain-dialog-head{padding:18px 20px;border-bottom:1px solid #dfe7f1;font-weight:700;color:#0f172a}.plain-dialog.tone-danger .plain-dialog-head{background:#dc2626;border-bottom-color:#dc2626;color:#fff}.plain-dialog.tone-success .plain-dialog-head{background:#15803d;border-bottom-color:#15803d;color:#fff}.plain-dialog.tone-primary .plain-dialog-head{background:#1e40af;border-bottom-color:#1e40af;color:#fff}.plain-dialog-body{padding:18px 20px;color:#334155;font-size:14.5px;line-height:1.55}.plain-dialog-actions{display:flex;justify-content:flex-end;gap:10px;padding:14px 20px 18px;border-top:1px solid #edf2f7}.plain-dialog-btn{border:1px solid #dfe7f1;background:#fff;color:#0f172a;border-radius:8px;padding:9px 15px;font:600 14px Inter,system-ui,sans-serif;cursor:pointer}.plain-dialog-btn.primary{background:#1e40af;border-color:#1e40af;color:#fff}.plain-dialog-btn.danger{background:#dc2626;border-color:#dc2626;color:#fff}.plain-dialog-btn.success{background:#15803d;border-color:#15803d;color:#fff}";
    document.head.appendChild(style);
  }

  function closeDialog(backdrop) {
    if (backdrop && backdrop.parentNode) backdrop.parentNode.removeChild(backdrop);
  }

  function createDialog(options) {
    ensureDialogStyles();
    const settings = Object.assign({
      title: "Notice",
      message: "",
      confirmText: "OK",
      cancelText: "Cancel",
      showCancel: false,
      tone: "primary",
      onConfirm: null,
      onCancel: null
    }, options || {});

    const backdrop = document.createElement("div");
    backdrop.className = "plain-dialog-backdrop";
    backdrop.setAttribute("role", "dialog");
    backdrop.setAttribute("aria-modal", "true");

    const dialog = document.createElement("div");
    dialog.className = "plain-dialog tone-" + settings.tone;

    const head = document.createElement("div");
    head.className = "plain-dialog-head";
    head.textContent = settings.title;

    const body = document.createElement("div");
    body.className = "plain-dialog-body";
    body.textContent = String(settings.message || "");

    const actions = document.createElement("div");
    actions.className = "plain-dialog-actions";

    if (settings.showCancel) {
      const cancel = document.createElement("button");
      cancel.type = "button";
      cancel.className = "plain-dialog-btn";
      cancel.textContent = settings.cancelText;
      cancel.addEventListener("click", function () {
        closeDialog(backdrop);
        if (typeof settings.onCancel === "function") settings.onCancel();
      });
      actions.appendChild(cancel);
    }

    const confirm = document.createElement("button");
    confirm.type = "button";
    confirm.className = "plain-dialog-btn " + (settings.tone === "danger" ? "danger" : settings.tone === "success" ? "success" : "primary");
    confirm.textContent = settings.confirmText;
    confirm.addEventListener("click", function () {
      closeDialog(backdrop);
      if (typeof settings.onConfirm === "function") settings.onConfirm();
    });
    actions.appendChild(confirm);

    dialog.appendChild(head);
    dialog.appendChild(body);
    dialog.appendChild(actions);
    backdrop.appendChild(dialog);
    document.body.appendChild(backdrop);
    confirm.focus();
    return backdrop;
  }

  window.showPlainAlert = function (message, options) {
    return createDialog(Object.assign({
      title: "Notice",
      message: message,
      confirmText: "OK"
    }, options || {}));
  };

  window.showPlainConfirm = function (message, onConfirm, options) {
    return createDialog(Object.assign({
      title: "Confirm",
      message: message,
      confirmText: "Confirm",
      cancelText: "Cancel",
      showCancel: true,
      onConfirm: onConfirm
    }, options || {}));
  };

  window.confirmAdminLogout = function () {
    showPlainConfirm("Are you sure you want to log out?", function () {
      try { sessionStorage.removeItem("phc-admin-shell-role"); } catch (_) {}
      if (typeof auditLog === "function") {
        auditLog("Logout", "Admin logged out", "Login");
      }
      fetch("../backend/api.php?action=admin_logout", {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: "{}"
      }).finally(function () {
        window.location.replace("../index.html");
      });
    }, { title: "Confirm Logout", confirmText: "Logout", tone: "danger" });
  };

  window.clearPatientLoginStorage = function () {
  };

  window.confirmPatientLogout = function () {
    showPlainConfirm("Are you sure you want to log out?", function () {
      if (window.clearPatientLoginStorage) window.clearPatientLoginStorage();
      fetch("../backend/api.php?action=patient_logout", {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: "{}"
      }).finally(function () {
        window.location.replace("../index.html");
      });
    }, { title: "Confirm Logout", confirmText: "Logout", tone: "danger" });
  };

  function initHealthCenterChat(){
    const path = location.pathname.replace(/\\/g,'/');
    const isAdmin = /\/admin\//.test(path) && !/admin-login\.html$/.test(path);
    const isPatient = /\/patient\//.test(path) && !/(login|register|reset-password|index)\.html$/.test(path);
    if(!isAdmin && !isPatient) return;

    if(isPatient)return;
    if(document.getElementById('hcChatLauncher') || document.getElementById('helpChatPanel') || document.getElementById('adminChatPanel') || document.getElementById('adminChatButton') || /messages\.html$/.test(path)) return;
    const style=document.createElement('style');
    style.id='hcChatStyles';
    style.textContent='.hc-chat-launcher{position:fixed;right:20px;bottom:20px;z-index:4500;border:0;border-radius:999px;background:#0b3d91;color:#fff;width:56px;height:56px;box-shadow:0 10px 25px rgba(11,61,145,.28);font-size:21px;cursor:pointer}.hc-chat-panel{position:fixed;right:20px;bottom:86px;z-index:4500;width:min(380px,calc(100vw - 28px));height:520px;background:#fff;border:1px solid #dbe5f1;border-radius:11px;box-shadow:0 18px 42px rgba(15,23,42,.2);display:none;overflow:hidden;font-family:Inter,system-ui,sans-serif}.hc-chat-panel.open{display:flex;flex-direction:column}.hc-chat-head{background:#0f2f67;color:white;padding:14px 16px;font-weight:800;display:flex;align-items:center;justify-content:space-between}.hc-chat-head small{display:block;font-weight:500;opacity:.85}.hc-chat-close{background:transparent;border:0;color:white;font-size:18px;cursor:pointer}.hc-chat-route{display:grid;grid-template-columns:auto 1fr;align-items:center;gap:8px;padding:9px 11px;border-bottom:1px solid #dbe5f1;background:#f4f8ff}.hc-chat-route label{font-size:10px;font-weight:750;color:#334155}.hc-chat-route select{min-width:0;height:32px;border:1px solid #cbd5e1;border-radius:6px;background:#fff;color:#10213f;padding:0 7px;font-size:10px}.hc-chat-threads{border-bottom:1px solid #e5e7eb;max-height:125px;overflow:auto;padding:8px;background:#f8fafc}.hc-chat-thread{width:100%;text-align:left;background:white;border:1px solid #dbe5f1;border-radius:8px;padding:8px 10px;margin-bottom:6px;cursor:pointer;font:600 12px Inter}.hc-chat-thread.active{border-color:#2563eb;background:#eff6ff}.hc-thread-branch{float:right;color:#0b3d91;font-size:9px}.hc-chat-body{flex:1;overflow:auto;padding:12px;background:#f8fafc}.hc-msg{max-width:82%;margin:0 0 9px;padding:9px 11px;border-radius:10px;font-size:13px;line-height:1.35;white-space:pre-wrap}.hc-msg.me{margin-left:auto;background:#0b3d91;color:white;border-bottom-right-radius:3px}.hc-msg.them{background:white;color:#0f172a;border:1px solid #e2e8f0;border-bottom-left-radius:3px}.hc-msg-meta{font-size:10px;opacity:.72;margin-top:3px}.hc-chat-form{display:flex;gap:8px;padding:11px;border-top:1px solid #e5e7eb;background:white}.hc-chat-input{flex:1;border:1px solid #cbd5e1;border-radius:7px;padding:10px;font:14px Inter}.hc-chat-send{border:0;background:#0b3d91;color:white;border-radius:7px;padding:0 14px;font-weight:800;cursor:pointer}.hc-chat-empty{color:#64748b;text-align:center;font-size:13px;margin-top:30px}';
    document.head.appendChild(style);
    const btn=document.createElement('button'); btn.id='hcChatLauncher'; btn.className='hc-chat-launcher'; btn.innerHTML='<i class="fa-regular fa-comments"></i>'; btn.title='Chat';
    const panel=document.createElement('div'); panel.id='hcChatPanel'; panel.className='hc-chat-panel';
    panel.innerHTML='<div class="hc-chat-head"><div>Health Center Chat<small>'+(isAdmin?'RHU patient inquiries':'Message your selected RHU')+'</small></div><button class="hc-chat-close" type="button">×</button></div>'+(isPatient?'<div class="hc-chat-route"><label for="hcChatRhu">Send to RHU</label><select id="hcChatRhu"><option>RHU I - Poblacion</option><option>RHU II - Cutcot</option><option>RHU III - Tinejero</option><option>RHU IV - Tibag</option></select></div>':'')+(isAdmin?'<div class="hc-chat-threads" id="hcChatThreads"><div class="hc-chat-empty" style="margin:8px 0">Loading conversations...</div></div>':'')+'<div class="hc-chat-body" id="hcChatBody"><div class="hc-chat-empty">Open chat to load messages.</div></div><form class="hc-chat-form" id="hcChatForm"><input class="hc-chat-input" id="hcChatInput" placeholder="Type your message..." maxlength="1000"><button class="hc-chat-send" type="submit">Send</button></form>';
    document.body.appendChild(panel); document.body.appendChild(btn);
    let currentPatientId=0,branchInitialized=false;
    async function api(action,payload){ const res=await fetch((isAdmin?'../':'../')+'backend/api.php?action='+action,{method:'POST',credentials:'include',headers:{'Content-Type':'application/json'},body:JSON.stringify(payload||{})}); return res.json().catch(()=>({ok:false,message:'Invalid server response'})); }
    function esc(v){return String(v||'').replace(/[&<>"']/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));}
    async function loadThreads(){ if(!isAdmin) return; const wrap=document.getElementById('hcChatThreads'); const r=await api('chat_threads',{}); if(!r.ok){wrap.innerHTML='<div class="hc-chat-empty" style="margin:8px 0">'+esc(r.message||'Unable to load chats')+'</div>'; return;} if(!r.threads.length){wrap.innerHTML='<div class="hc-chat-empty" style="margin:8px 0">No patient messages yet</div>'; return;} wrap.innerHTML=r.threads.map(t=>'<button type="button" class="hc-chat-thread '+(t.patient_id===currentPatientId?'active':'')+'" data-id="'+t.patient_id+'">'+esc(t.patient_name)+' '+(t.unread?'<strong style="color:#dc2626">('+t.unread+')</strong>':'')+'<span class="hc-thread-branch">'+esc(String(t.rhu_branch||'RHU').split(' - ')[0])+'</span><br><span style="font-weight:500;color:#64748b">'+esc(t.last_message||'')+'</span></button>').join(''); wrap.querySelectorAll('.hc-chat-thread').forEach(x=>x.onclick=()=>{currentPatientId=Number(x.dataset.id); loadMessages(); loadThreads();}); if(!currentPatientId && r.threads[0]){currentPatientId=r.threads[0].patient_id; loadMessages(); loadThreads();} }
    async function loadMessages(){ const body=document.getElementById('hcChatBody'); body.innerHTML='<div class="hc-chat-empty">Loading messages...</div>'; const r=await api('chat_messages', isAdmin?{patient_id:currentPatientId}:{}); if(!r.ok){body.innerHTML='<div class="hc-chat-empty">'+esc(r.message||'Unable to load chat')+'</div>'; return;} if(isAdmin && !currentPatientId) currentPatientId=r.patient_id||0; if(isPatient&&!branchInitialized){const select=document.getElementById('hcChatRhu');if(select){select.value=r.rhu_branch||select.value;branchInitialized=true}} if(!r.messages.length){body.innerHTML='<div class="hc-chat-empty">No messages yet. Choose an RHU and start the conversation.</div>'; return;} body.innerHTML=r.messages.map(m=>{const me=(isAdmin&&m.sender_type==='admin')||(isPatient&&m.sender_type==='patient'); return '<div class="hc-msg '+(me?'me':'them')+'"><div>'+esc(m.message)+'</div><div class="hc-msg-meta">'+esc(m.name)+' • '+esc(m.created_at||'')+'</div></div>';}).join(''); body.scrollTop=body.scrollHeight; }
    btn.onclick=async()=>{ panel.classList.toggle('open'); if(panel.classList.contains('open')){ if(isAdmin) await loadThreads(); await loadMessages(); }};
    panel.querySelector('.hc-chat-close').onclick=()=>panel.classList.remove('open');
    document.getElementById('hcChatForm').onsubmit=async(e)=>{ e.preventDefault(); const input=document.getElementById('hcChatInput'); const msg=input.value.trim(); if(!msg) return; const r=await api('chat_send', isAdmin?{patient_id:currentPatientId,message:msg}:{message:msg,rhu_branch:document.getElementById('hcChatRhu')?.value||'RHU I - Poblacion'}); if(!r.ok){ alert(r.message||'Message not sent.'); return;} input.value=''; await loadMessages(); if(isAdmin) await loadThreads(); };
    let chatPollTimer=null;
    async function pollChat(){clearTimeout(chatPollTimer);if(!document.hidden&&panel.classList.contains('open')){if(isAdmin)await loadThreads();await loadMessages()}chatPollTimer=setTimeout(pollChat,15000)}
    chatPollTimer=setTimeout(pollChat,15000);
    document.addEventListener('visibilitychange',()=>{if(!document.hidden&&panel.classList.contains('open'))pollChat().catch(()=>{})});
  }

  async function initRoleHelpTips(){
    const path=location.pathname.replace(/\\/g,'/');
    const page=path.split('/').pop().toLowerCase();
    const patientCopy={
      'dashboard.html':'This dashboard summarizes your next appointment, current queue status, notifications, and shortcuts to common patient services.',
      'book.html':'Use this page to choose an RHU, health service, date, and available time. Review all requirements before confirming.',
      'appointments.html':'This page lists your pending, confirmed, completed, cancelled, and rescheduled appointments.',
      'queue.html':'Queue Status shows who is currently being served and your place in line. Your actual queue updates after staff marks you as arrived.',
      'profile.html':'Keep your contact, health, priority, and preferred RHU information accurate so staff can assist you correctly.',
      'qr.html':'Present this QR code at your assigned RHU so staff can locate your appointment and mark your arrival faster.',
      'messages.html':'Choose the RHU that should receive your concern. Only that RHU staff and the System Administrator can view and reply.',
      'notifications.html':'Notifications contain appointment, queue, announcement, and Help Center updates from Pulilan Health Center.'
    };
    const staffCopy={
      'admin-dashboard.html':'This RHU Staff Dashboard shows only your assigned branch workload, appointments, queue, and patient activity.',
      'admin-appointments.html':'Review and update appointments for your assigned RHU. Status changes are recorded in the Audit Trail.',
      'admin-queue.html':'Manage arrived patients for your assigned RHU. Emergency, priority, and regular queue rules are applied automatically.',
      'admin-patients.html':'Patient records shown here are limited to your assigned RHU. Staff can add, view, and update records; only the System Administrator can archive or restore an account.',
      'staff-messages.html':'Only inquiries routed by patients to your assigned RHU appear here. Replies are recorded under your staff account.',
      'admin-announcements.html':'RHU staff can view announcements relevant to their assigned branch and all-branch notices.',
      'admin-reports.html':'Reports summarize appointment and queue activity for your assigned RHU and help staff review daily service performance.',
      'admin-heatmap.html':'Disease Trends helps authorized RHU staff review recorded case patterns for their assigned branch without exposing data from other RHUs.'
    };
    let copy='';
    if(/\/patient\//.test(path)&&patientCopy[page]) copy=patientCopy[page];
    else if(/\/admin\//.test(path)&&staffCopy[page]){
      try{
        const response=await fetch('../backend/api.php?action=admin_me',{credentials:'include',cache:'no-store'});
        const result=await response.json();
        const role=String(result.admin?.role||'').toLowerCase();
        if(result.ok&&!/administrator|system admin|super/.test(role)) copy=staffCopy[page];
      }catch(_){return;}
    }
    if(!copy||document.querySelector('.hc-context-tip'))return;
    const heading=document.querySelector('.page-header h2,.page-header h1,.dashboard-header h1,.dashboard-header h2,main h1,main h2');
    if(!heading)return;
    if(!document.getElementById('hcContextTipStyles')){
      const style=document.createElement('style');
      style.id='hcContextTipStyles';
      style.textContent='.hc-context-tip{position:relative;display:inline-flex;align-items:center;vertical-align:middle;margin-left:8px;top:-1px;line-height:1}.hc-context-tip-button{box-sizing:border-box;display:inline-grid;place-items:center;flex:0 0 22px;width:22px;min-width:22px;max-width:22px;height:22px;min-height:22px;max-height:22px;aspect-ratio:1/1;margin:0;padding:0;border:1.5px solid #8da7ca;border-radius:50%;background:#fff;color:#0b3d91;font:700 11px/1 Inter,system-ui,-apple-system,"Segoe UI",Arial,sans-serif;cursor:help;box-shadow:none}.hc-context-tip-button i{display:block;width:auto;height:auto;font-size:10px;line-height:1}.hc-context-tip-text{position:absolute;z-index:4800;left:0;right:auto;top:calc(100% + 10px);bottom:auto;width:min(320px,calc(100vw - 32px));transform:translateY(4px);padding:11px 12px;border-radius:7px;background:#102b58;color:#fff;font:500 11px/1.5 Inter,system-ui,-apple-system,"Segoe UI",Arial,sans-serif;letter-spacing:0;text-align:left;box-shadow:0 10px 24px rgba(15,39,79,.22);opacity:0;visibility:hidden;transition:.15s;pointer-events:none}.hc-context-tip-text:after{content:"";position:absolute;left:11px;bottom:100%;top:auto;transform:none;border:6px solid transparent;border-bottom-color:#102b58}.hc-context-tip:hover .hc-context-tip-text,.hc-context-tip:focus-within .hc-context-tip-text,.hc-context-tip.is-open .hc-context-tip-text{opacity:1;visibility:visible;transform:translateY(0)}@media(max-width:600px){.hc-context-tip{position:static;margin-left:6px;top:0}.hc-context-tip-button{flex-basis:22px;width:22px;min-width:22px;max-width:22px;height:22px;min-height:22px;max-height:22px}.hc-context-tip-text{position:fixed;z-index:9999;left:12px;right:12px;top:88px;bottom:auto;width:auto;max-width:none;max-height:38vh;overflow:auto;transform:translateY(12px);font-size:12px;line-height:1.55;padding:14px 16px;border-radius:10px;box-shadow:0 16px 40px rgba(15,39,79,.28)}.hc-context-tip:hover .hc-context-tip-text{opacity:0;visibility:hidden}.hc-context-tip:focus-within .hc-context-tip-text,.hc-context-tip.is-open .hc-context-tip-text{opacity:1;visibility:visible;transform:translateY(0)}.hc-context-tip-text:after{display:none}}';
      document.head.appendChild(style);
    }
    const tip=document.createElement('span');
    tip.className='hc-context-tip';
    tip.innerHTML='<button class="hc-context-tip-button" type="button" aria-label="What is this page for?" aria-expanded="false"><i class="fas fa-info" aria-hidden="true"></i></button><span class="hc-context-tip-text" role="tooltip"></span>';
    tip.querySelector('.hc-context-tip-text').textContent=copy;
    tip.querySelector('button').addEventListener('click',event=>{event.stopPropagation();const open=tip.classList.toggle('is-open');event.currentTarget.setAttribute('aria-expanded',String(open))});
    document.addEventListener('click',()=>{tip.classList.remove('is-open');tip.querySelector('button').setAttribute('aria-expanded','false')});
    heading.appendChild(tip);
  }

  function initRoleUtilities(){initHealthCenterChat();initRoleHelpTips();}
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', initRoleUtilities); else initRoleUtilities();

  window.alert = function (message) {
    showPlainAlert(message);
  };
})();
