const API = '../backend/api.php?action=';

function resolvePatientNotificationLink(item) {
  const rawLink = String(item?.link || '').trim();
  const title = String(item?.title || '').toLowerCase();
  const message = String(item?.message || '').toLowerCase();
  const type = String(item?.type || '').toLowerCase();
  const appointmentId = Number(item?.appointment_id || 0);

  if (
    title.includes('reply') ||
    title.includes('inquiry') ||
    message.includes('replied to your message') ||
    rawLink.includes('messages.html')
  ) {
    return 'messages.html?from=notification';
  }

  if (
    type === 'queue' ||
    title.includes('queue') ||
    title.includes('being called') ||
    rawLink.includes('queue.html')
  ) {
    return 'queue.html';
  }

  if (
    title.includes('announcement') ||
    rawLink.includes('#announcements')
  ) {
    return 'dashboard.html#announcements';
  }

  if (
    title.includes('qr') ||
    rawLink.includes('qr.html')
  ) {
    return 'qr.html';
  }

  if (
    appointmentId > 0 ||
    title.includes('appointment') ||
    rawLink.includes('appointments.html')
  ) {
    return appointmentId > 0
      ? `appointments.html?appointment=${appointmentId}`
      : 'appointments.html';
  }

  if (
    title.includes('profile') ||
    rawLink.includes('profile.html')
  ) {
    return 'profile.html';
  }

  return rawLink || 'notifications.html';
}

(function loadUnifiedPatientHelpChat(){
  const page=location.pathname.split('/').pop().toLowerCase();
  const pages=new Set(['dashboard.html','book.html','appointments.html','queue.html','profile.html','qr.html','notifications.html','family.html','privacy.html']);
  if(!pages.has(page)||document.querySelector('script[data-unified-patient-chat]'))return;
  const script=document.createElement('script');
  script.src='js/patient_help_chat.js?v=20260721-dashboard-chat-exact';
  script.dataset.unifiedPatientChat='';
  document.head.appendChild(script);
})();
async function api(action, data=null, method='POST'){
  const write=data!==null && String(method||'POST').toUpperCase()!=='GET';
  if(write && !navigator.onLine) return {ok:false,offline:true,message:'This action needs an internet connection. Your offline copy is still available.'};
  const opts={credentials:'include', headers:{}};
  if(data!==null){opts.method=method; opts.headers['Content-Type']='application/json'; opts.body=JSON.stringify(data);} else opts.method='GET';
  try{
    const res=await fetch(API+encodeURIComponent(action), opts);
    let json={}; try{json=await res.json();}catch(e){json={ok:false,message:'Invalid server response'};}
    const publicPage=/\/(login|register|forgot-password|reset-password|privacy|index)\.html$/.test(location.pathname);
    if(res.status===401 && !publicPage) location.href='login.html';
    return json;
  }catch(_){return {ok:false,offline:!navigator.onLine,message:navigator.onLine?'The server could not be reached. Please try again.':'You are offline. Showing the last saved information when available.'}}
}
function esc(v){return String(v??'').replace(/[&<>'"]/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[m]));}
function fmtDate(d){ if(!d) return '--'; const x=new Date(d+'T00:00:00'); return isNaN(x)?d:x.toLocaleDateString('en-US',{month:'short',day:'numeric',year:'numeric'});}
function getInitials(n){return (n||'Patient').trim().split(/\s+/).map(x=>x[0]).slice(0,2).join('').toUpperCase()||'P';}
async function loadPatientNav(){
  const r=await api('patient_me', null, 'GET');
  if(!r.ok) return null;
  const p=r.patient||{}; const name=p.name||`${p.firstName||''} ${p.lastName||''}`.trim()||'Patient';
  ['userName','mobName','headerName'].forEach(id=>{const el=document.getElementById(id); if(el) el.textContent=name;});
  ['avatarBtn','mobAvatar'].forEach(id=>{const el=document.getElementById(id);if(!el)return;const photo=p.profilePhoto||p.profile_picture||'';if(window.hcApplyPatientPhoto)window.hcApplyPatientPhoto(photo,name);else el.textContent=getInitials(name);});
  return {...p,name};
}

function positionMobileMenu(){
  const m=document.getElementById('mobileMenu');
  const btn=document.getElementById('hamburgerBtn');
  if(!m||!btn||!m.classList.contains('show'))return;
  const rect=btn.getBoundingClientRect();
  const width=Math.min(360, window.innerWidth-24);
  const right=Math.max(12, window.innerWidth-rect.right);
  m.style.setProperty('position','fixed','important');
  m.style.setProperty('top',Math.round(rect.bottom+10)+'px','important');
  m.style.setProperty('right',Math.round(right)+'px','important');
  m.style.setProperty('left','auto','important');
  m.style.setProperty('width',width+'px','important');
  m.style.setProperty('max-width','calc(100vw - 24px)','important');
  m.style.setProperty('z-index','10050','important');
  m.style.setProperty('max-height','calc(100dvh - '+Math.round(rect.bottom+24)+'px)','important');
  m.style.setProperty('overflow-y','auto','important');
}
function toggleMobileMenu(){
  const m=document.getElementById('mobileMenu'); const i=document.getElementById('hamburgerIcon');
  if(!m)return;
  const opening=!m.classList.contains('show');
  m.classList.toggle('show',opening);
  if(i){i.classList.toggle('fa-bars',!opening); i.classList.toggle('fa-times',opening);}
  if(opening){ positionMobileMenu(); }
  else { m.style.cssText=''; }
}
window.addEventListener('resize',positionMobileMenu);
window.addEventListener('scroll',positionMobileMenu,true);
document.addEventListener('click',function(event){
  const m=document.getElementById('mobileMenu'); const btn=document.getElementById('hamburgerBtn');
  if(!m||!m.classList.contains('show'))return;
  if(m.contains(event.target)||btn?.contains(event.target))return;
  m.classList.remove('show'); m.style.cssText='';
  const i=document.getElementById('hamburgerIcon'); if(i){i.classList.add('fa-bars');i.classList.remove('fa-times');}
});
async function confirmPatientLogout(){ await api('patient_logout',{},'POST');['phc_queue_snapshot','phc_appointment_snapshot','phc_qr_ticket'].forEach(key=>localStorage.removeItem(key));location.href='login.html'; }
function openNotifications(){ location.href='notifications.html'; }

function updateNotificationBadge(count) {
  const unread = Number(count || 0);

  document.querySelectorAll('.navbar-notif-btn').forEach(button => {
    button.classList.toggle('has-unread', unread > 0);
    button.setAttribute(
      'aria-label',
      unread > 0 ? `${unread} unread notifications` : 'Notifications'
    );
  });

  document.querySelectorAll('.notif-count').forEach(badge => {
    badge.textContent = unread > 99 ? '99+' : String(unread);
    badge.style.display = unread > 0 ? 'flex' : 'none';
  });
}

async function refreshNotificationBadge() {
  try {
    const response = await fetch(
      '../backend/api.php?action=patient_notifications&limit=1',
      {
        credentials: 'include',
        cache: 'no-store'
      }
    );

    const result = await response.json();

    if (result.ok) {
      updateNotificationBadge(Number(result.unread || 0));
    }
  } catch (_) {

  }
}

window.addEventListener('focus', refreshNotificationBadge);

document.addEventListener('visibilitychange', () => {
  if (!document.hidden) {
    refreshNotificationBadge();
  }
});

let notificationPopoverItems = [];

async function loadNotificationPopover() {
  const list = document.getElementById('notificationPopoverList');
  if (!list) return;

  list.innerHTML = `
    <div class="notification-popover-loading">
      <i class="fa-solid fa-spinner fa-spin"></i>
      Loading...
    </div>`;

  try {
    const response = await fetch(
      '../backend/api.php?action=patient_notifications&limit=5',
      { credentials:'include', cache:'no-store' }
    );
    const result = await response.json();

    if (!result.ok) {
      list.innerHTML = '<div class="notification-popover-empty">Unable to load notifications.</div>';
      return;
    }

    notificationPopoverItems = Array.isArray(result.notifications)
      ? result.notifications
      : [];

    const unread = Number(result.unread || 0);
    updateNotificationBadge(unread);

    const unreadText = document.getElementById('popoverUnreadText');
    if (unreadText) unreadText.textContent = `${unread} unread`;

    if (!notificationPopoverItems.length) {
      list.innerHTML = '<div class="notification-popover-empty"><i class="fa-regular fa-bell-slash"></i><br>No notifications yet.</div>';
      return;
    }

    list.innerHTML = notificationPopoverItems.map(item => `
      <article class="notification-popover-item ${Number(item.is_read) ? '' : 'unread'}"
               data-notification-id="${Number(item.id)}">
        <div class="notification-popover-icon ${esc(item.type || 'info')}">
          <i class="${notificationPopoverIcon(item.type)}"></i>
        </div>
        <div class="notification-popover-body">
          <h4>${esc(item.title || 'Notification')}</h4>
          <p>${esc(item.message || '')}</p>
          <time>${formatPopoverTime(item.created_at)}</time>
        </div>
      </article>`).join('');

    list.querySelectorAll('.notification-popover-item').forEach(element => {
      element.addEventListener('click', () => {
        openNotificationFromPopover(Number(element.dataset.notificationId));
      });
    });
  } catch (_) {
    list.innerHTML = '<div class="notification-popover-empty">Unable to load notifications.</div>';
  }
}

async function openNotificationFromPopover(id) {
  const item = notificationPopoverItems.find(entry => Number(entry.id) === Number(id));
  if (!item) return;

  if (!Number(item.is_read)) {
    await fetch('../backend/api.php?action=patient_notification_read', {
      method:'POST',
      credentials:'include',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({ id })
    });
  }

  window.location.href = resolvePatientNotificationLink(item);
}

async function markAllPopoverNotificationsRead() {
  try {
    const response = await fetch('../backend/api.php?action=patient_notifications_read_all', {
      method:'POST',
      credentials:'include',
      headers:{'Content-Type':'application/json'},
      body:'{}'
    });
    const result = await response.json();

    if (result.ok) {
      updateNotificationBadge(0);
      await loadNotificationPopover();
    }
  } catch (_) {}
}

function notificationPopoverIcon(type) {
  return ({
    success:'fa-solid fa-circle-check',
    danger:'fa-solid fa-circle-xmark',
    warning:'fa-solid fa-triangle-exclamation',
    queue:'fa-solid fa-bullhorn',
    info:'fa-solid fa-circle-info'
  })[type] || 'fa-solid fa-bell';
}

function formatPopoverTime(value) {
  const date = new Date(String(value || '').replace(' ', 'T'));
  if (Number.isNaN(date.getTime())) return value || '';

  return date.toLocaleString('en-US', {
    month:'short',
    day:'numeric',
    hour:'numeric',
    minute:'2-digit'
  });
}

function positionNotificationPopover() {
  const bell = document.querySelector('.navbar-notif-btn');
  const popover = document.getElementById('notificationPopover');
  if (!bell || !popover || popover.hidden || window.innerWidth <= 700) return;

  const rect = bell.getBoundingClientRect();
  const width = 360;
  const viewportPadding = 14;
  const right = Math.max(viewportPadding, window.innerWidth - rect.right - 8);
  popover.style.setProperty('top', `${Math.round(rect.bottom + 10)}px`, 'important');
  popover.style.setProperty('right', `${Math.round(right)}px`, 'important');
  popover.style.setProperty('left', 'auto', 'important');
}

document.addEventListener('DOMContentLoaded', () => {
  const bell = document.querySelector('.navbar-notif-btn');
  const popover = document.getElementById('notificationPopover');
  const markAll = document.getElementById('popoverMarkAll');

  if (bell && popover) {
    bell.addEventListener('click', event => {
      event.stopPropagation();
      const willOpen = popover.hidden;
      popover.hidden = !willOpen;

      if (willOpen) {
        positionNotificationPopover();
        loadNotificationPopover();
      }
    });

    popover.addEventListener('click', event => {
      event.stopPropagation();
    });

    document.addEventListener('click', () => {
      popover.hidden = true;
    });
  }

  markAll?.addEventListener('click', markAllPopoverNotificationsRead);

  window.addEventListener('resize', positionNotificationPopover);
  window.addEventListener('scroll', positionNotificationPopover, true);

  refreshNotificationBadge();
  window.setInterval(refreshNotificationBadge, 15000);
});

const BROWSER_NOTIFICATION_SEEN_KEY = 'pulilan_browser_notification_seen_ids';

function browserNotificationsSupported() {
  return 'Notification' in window;
}

function browserNotificationIcon() {
  // patient_common.js is used by pages inside /patient/, so keep this page-relative.
  return 'images/mhc-logo.png';
}

function getBrowserNotificationSeenIds() {
  try {
    const value = JSON.parse(localStorage.getItem(BROWSER_NOTIFICATION_SEEN_KEY) || '[]');
    return Array.isArray(value) ? value.map(Number) : [];
  } catch (_) {
    return [];
  }
}

function saveBrowserNotificationSeenIds(ids) {
  localStorage.setItem(
    BROWSER_NOTIFICATION_SEEN_KEY,
    JSON.stringify(Array.from(new Set(ids.map(Number))).slice(-100))
  );
}

function setBrowserNotificationButtonState(button) {
  if (!button) return;

  let state = 'default';
  let iconClass = 'fa-regular fa-bell';
  let label = 'Enable browser notifications';
  let title = 'Enable browser notifications';

  if (!browserNotificationsSupported()) {
    state = 'unsupported';
    iconClass = 'fa-regular fa-bell-slash';
    label = 'Browser notifications unavailable';
    title = 'Browser notifications are not supported by this browser.';
  } else if (Notification.permission === 'granted') {
    state = 'granted';
    iconClass = 'fa-solid fa-bell';
    label = 'Browser notifications enabled';
    title = 'Browser notifications are enabled.';
  } else if (Notification.permission === 'denied') {
    state = 'denied';
    iconClass = 'fa-regular fa-bell-slash';
    label = 'Browser notifications blocked';
    title = 'Notifications are blocked in browser site settings.';
  }

  button.dataset.notificationState = state;
  button.title = title;
  button.disabled = state === 'unsupported';
  button.toggleAttribute('aria-disabled', state === 'unsupported');

  // Rebuild the contents so the popover never shows duplicate/leftover labels.
  button.replaceChildren();
  const icon = document.createElement('i');
  icon.className = iconClass;
  icon.setAttribute('aria-hidden', 'true');
  const text = document.createElement('span');
  text.className = 'browser-notification-label';
  text.textContent = label;
  button.append(icon, text);
}

function updateBrowserNotificationButtons() {
  document.querySelectorAll('[data-enable-browser-notifications]').forEach(setBrowserNotificationButtonState);
}

function showLocalBrowserNotificationFeedback(message, type = 'success') {
  if (typeof showToast === 'function') {
    showToast(message, type);
    return;
  }

  let toast = document.getElementById('browserNotificationFeedback');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'browserNotificationFeedback';
    toast.setAttribute('role', 'status');
    toast.setAttribute('aria-live', 'polite');
    toast.style.cssText = 'position:fixed;right:22px;bottom:86px;z-index:3000;max-width:340px;padding:11px 14px;border:1px solid #bfdbfe;border-radius:10px;background:#fff;color:#0f172a;font:700 12px Inter,Arial,sans-serif;box-shadow:0 12px 30px rgba(15,23,42,.16);opacity:0;transform:translateY(8px);transition:.18s ease;pointer-events:none';
    document.body.appendChild(toast);
  }
  toast.textContent = message;
  toast.style.opacity = '1';
  toast.style.transform = 'translateY(0)';
  clearTimeout(toast._hideTimer);
  toast._hideTimer = setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(8px)';
  }, 3200);
}

async function showBrowserNotificationConfirmation() {
  const options = {
    body:'Browser notifications are working for PHAQS.',
    icon:browserNotificationIcon(),
    badge:browserNotificationIcon(),
    tag:'pulilan-browser-notifications-enabled',
    renotify:false
  };

  try {
    // Prefer the service-worker notification path when available. It is more
    // consistent across Chromium browsers than constructing Notification directly.
    if ('serviceWorker' in navigator) {
      try {
        const registration = await navigator.serviceWorker.ready;
        if (registration && typeof registration.showNotification === 'function') {
          await registration.showNotification('Pulilan Health Center', options);
          return true;
        }
      } catch (_) {}
    }

    const confirmation = new Notification('Pulilan Health Center', options);
    window.setTimeout(() => confirmation.close(), 4500);
    return true;
  } catch (error) {
    console.error('Browser notification failed:', error);
    return false;
  }
}

async function requestBrowserNotificationPermission() {
  if (!browserNotificationsSupported()) {
    if (typeof showToast === 'function') showToast('Browser notifications are not supported on this browser.', 'error');
    return false;
  }

  if (!window.isSecureContext && !['localhost', '127.0.0.1', '[::1]'].includes(location.hostname)) {
    alert('Browser notifications require HTTPS. Please open PHAQS using HTTPS, then try again.');
    return false;
  }

  // If permission already exists, keep the control active without changing its enabled label.
  if (Notification.permission === 'granted') {
    updateBrowserNotificationButtons();
    const sent = await showBrowserNotificationConfirmation();
    showLocalBrowserNotificationFeedback(
      sent ? 'Browser notifications are enabled.' : 'Notifications are allowed, but the browser could not display a notification.',
      sent ? 'success' : 'error'
    );
    checkBrowserNotifications();
    return sent;
  }

  if (Notification.permission === 'denied') {
    updateBrowserNotificationButtons();
    alert('Browser notifications are blocked for this site. Click the site/lock icon beside the address bar, open Site settings, set Notifications to Allow, then reload the page.');
    return false;
  }

  try {
    const permission = await Notification.requestPermission();
    updateBrowserNotificationButtons();

    if (permission === 'granted') {
      const sent = await showBrowserNotificationConfirmation();
      showLocalBrowserNotificationFeedback(
        sent ? 'Browser notifications enabled.' : 'Browser notifications enabled, but a notification could not be displayed.',
        sent ? 'success' : 'error'
      );
      checkBrowserNotifications();
      return true;
    }

    showLocalBrowserNotificationFeedback('Browser notification permission was not allowed.', 'error');
    return false;
  } catch (error) {
    console.error('Unable to enable browser notifications:', error);
    if (typeof showToast === 'function') showToast('Unable to enable browser notifications.', 'error');
    return false;
  }
}

async function checkBrowserNotifications() {
  if (!browserNotificationsSupported() || Notification.permission !== 'granted') {
    return;
  }

  try {
    const response = await fetch(
      '../backend/api.php?action=patient_notifications&limit=10',
      { credentials:'include', cache:'no-store' }
    );
    const result = await response.json();

    if (!result.ok || !Array.isArray(result.notifications)) return;

    const seen = getBrowserNotificationSeenIds();
    const seenSet = new Set(seen);

    const newUnread = result.notifications
      .filter(item => !Number(item.is_read))
      .filter(item => !seenSet.has(Number(item.id)))
      .reverse();

    for (const item of newUnread) {
      const notification = new Notification(item.title || 'Pulilan Health Center', {
        body:item.message || 'You have a new patient update.',
        icon:browserNotificationIcon(),
        badge:browserNotificationIcon(),
        tag:'pulilan-notification-' + item.id,
        renotify:false
      });

      notification.onclick = () => {
        window.focus();
        window.location.href = resolvePatientNotificationLink(item);
        notification.close();
      };

      seenSet.add(Number(item.id));
    }

    saveBrowserNotificationSeenIds(Array.from(seenSet));
  } catch (error) {
    console.error('Browser notification check failed:', error);
  }
}

// Capture phase is intentional: the notification popover stops normal bubbling.
// This keeps the browser-notification control clickable on every patient page.
document.addEventListener('click', event => {
  const button = event.target.closest?.('[data-enable-browser-notifications]');
  if (!button) return;
  event.preventDefault();
  event.stopPropagation();
  requestBrowserNotificationPermission();
}, true);

document.addEventListener('DOMContentLoaded', () => {
  updateBrowserNotificationButtons();

  if (browserNotificationsSupported() && Notification.permission === 'granted') {
    checkBrowserNotifications();
    window.setInterval(checkBrowserNotifications, 15000);
  }
});

window.addEventListener('pageshow', updateBrowserNotificationButtons);
window.addEventListener('focus', () => {
  updateBrowserNotificationButtons();
  checkBrowserNotifications();
});

function installPatientOfflineSupport(){
  if(!document.querySelector('link[rel="manifest"]')){const link=document.createElement('link');link.rel='manifest';link.href='manifest.webmanifest';document.head.appendChild(link)}
  if('serviceWorker'in navigator)navigator.serviceWorker.register('./service-worker.js').catch(()=>{});
  const bar=document.createElement('div');bar.id='patientConnectivityBar';bar.setAttribute('role','status');bar.style.cssText='position:fixed;left:50%;bottom:12px;z-index:1090;transform:translateX(-50%);max-width:calc(100% - 24px);padding:8px 12px;border:1px solid #f59e0b;border-left:4px solid #d97706;border-radius:7px;background:#fffbeb;color:#854d0e;font:700 10px Inter,Arial,sans-serif;box-shadow:0 8px 24px rgba(15,23,42,.15);display:none';document.body.appendChild(bar);
  const update=()=>{if(navigator.onLine){bar.style.display='none';document.dispatchEvent(new CustomEvent('phc:online'))}else{const times=['phc_queue_snapshot','phc_appointment_snapshot'].map(k=>{try{return JSON.parse(localStorage.getItem(k)||'null')?.savedAt||0}catch(_){return 0}}).filter(Boolean);const last=times.length?new Date(Math.max(...times)).toLocaleString('en-PH'):'not yet available';bar.textContent=`Offline mode • Read-only saved copy • Last updated: ${last}`;bar.style.display='block'}};
  window.addEventListener('online',update);window.addEventListener('offline',update);update();
}

function injectFamilyCareLinks(){
  const current=(location.pathname.split('/').pop()||'dashboard.html').toLowerCase();
  const accountLinks=[
    ['profile.html','fas fa-user','Profile'],
    ['messages.html','fa-regular fa-comments','Help Center'],
    ['family.html','fas fa-people-roof','Family Care'],
    ['privacy.html','fas fa-shield-halved','Privacy & Access']
  ];
  const mobileLinks=[
    ['dashboard.html','fa-solid fa-house','Dashboard'],
    ['book.html','fa-regular fa-calendar-plus','Book Appointment'],
    ['appointments.html','fa-regular fa-calendar-check','My Appointments'],
    ['queue.html','fa-solid fa-list-check','Queue Status'],
    ['notifications.html','fa-regular fa-bell','Notifications'],
    ...accountLinks
  ];
  const active=href=>href===current?' active':'';

  document.querySelectorAll('.patient-user-menu').forEach(menu=>{
    const isList=menu.tagName==='UL';
    if(isList){
      menu.innerHTML=accountLinks.map(item=>`<li><a class="dropdown-item patient-menu-item${active(item[0])}" href="${item[0]}"><i class="${item[1]}"></i><span>${item[2]}</span></a></li>`).join('')+
        '<li><hr class="dropdown-divider"></li><li><button class="dropdown-item patient-menu-item logout" type="button" onclick="confirmPatientLogout();"><i class="fas fa-right-from-bracket"></i><span>Logout</span></button></li>';
    }else{
      menu.innerHTML=accountLinks.map(item=>`<a class="patient-menu-item${active(item[0])}" href="${item[0]}"><i class="${item[1]}"></i><span>${item[2]}</span></a>`).join('')+
        '<div class="dropdown-divider"></div><button class="patient-menu-item logout" type="button" onclick="confirmPatientLogout();"><i class="fas fa-right-from-bracket"></i><span>Logout</span></button>';
    }
    menu.dataset.patientMenuCanonical='true';
  });

  document.querySelectorAll('.mobile-menu').forEach(menu=>{
    const name=menu.querySelector('#mobName')?.textContent?.trim()||document.getElementById('userName')?.textContent?.trim()||'Patient';
    const avatar=menu.querySelector('#mobAvatar')?.textContent?.trim()||getInitials(name);
    menu.innerHTML=`<div class="mob-user"><div class="mob-avatar" id="mobAvatar">${esc(avatar)}</div><span id="mobName">${esc(name)}</span></div><div class="mob-divider"></div>`+
      mobileLinks.map(item=>`<a class="${active(item[0]).trim()}" href="${item[0]}"><i class="${item[1]} me-2"></i><span>${item[2]}</span></a>`).join('')+
      '<div class="mob-divider"></div><button class="mob-logout" onclick="confirmPatientLogout();" type="button"><i class="fa-solid fa-right-from-bracket me-2"></i><span>Logout</span></button>';
    menu.dataset.patientMenuCanonical='true';
  });
}
async function showPrivacyRequirement(){if(/\/(login|register|privacy|forgot-password|reset-password|index)\.html$/.test(location.pathname))return;try{const r=await api('patient_privacy_status',null,'GET');if(!r.ok||r.has_current_consent||document.getElementById('privacyRequirement'))return;const bar=document.createElement('div');bar.id='privacyRequirement';bar.style.cssText='position:relative;z-index:980;padding:10px 18px;border-bottom:1px solid #fcd34d;background:#fffbeb;color:#854d0e;font:700 11px Inter,Arial,sans-serif;text-align:center';bar.innerHTML='<i class="fas fa-shield-halved"></i> Review the current Privacy and Data Retention Policy to continue using protected portal actions. <a href="privacy.html" style="color:#1e40af;margin-left:8px">Review policy</a>';document.body.insertBefore(bar,document.body.firstChild)}catch(_){}}
document.addEventListener('DOMContentLoaded',()=>{installPatientOfflineSupport();injectFamilyCareLinks();showPrivacyRequirement()});
