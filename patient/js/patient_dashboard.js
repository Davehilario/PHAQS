document.addEventListener('DOMContentLoaded', initDashboard);

let dashboardAnnouncementTimer = null;

async function initDashboard() {
  const patient = await loadPatientNav();
  if (!patient) return;

  const firstName = patient.firstName || (patient.name || '').trim().split(/\s+/)[0] || 'Patient';
  const welcome = document.getElementById('welcomeName');
  if (welcome) welcome.textContent = `Welcome back, ${firstName}!`;

  const now = new Date();
  setDashText('todayDate', now.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }));
  setDashText('todayDay', now.toLocaleDateString('en-US', { weekday: 'long' }));

  await refreshDashboard();
}

async function refreshDashboard() {
  const announcementsPromise=loadDashboardAnnouncements();
  const [appointmentsResult, queueResult] = await Promise.all([
    api('patient_appointments', null, 'GET'),
    api('patient_queue_data', null, 'GET')
  ]);

  if (!appointmentsResult.ok || !queueResult.ok) {
    renderDashboardError(appointmentsResult.message || queueResult.message || 'Unable to load your appointment data.');
    await announcementsPromise;
    return;
  }

  try{localStorage.setItem('phc_appointment_snapshot',JSON.stringify({savedAt:Date.now(),appointments:appointmentsResult.appointments||[],appointment:queueResult.appointment||null}))}catch(_){}

  const appointments = Array.isArray(appointmentsResult.appointments) ? appointmentsResult.appointments : [];
  const activeStatuses = ['pending', 'confirmed', 'serving', 'hold', 'waiting'];
  const upcoming = appointments.filter(item => activeStatuses.includes(String(item.status || '').toLowerCase()));
  const active = queueResult.appointment || upcoming[0] || null;
  const queueData = queueResult.queueData || {};
  const branch = active ? (queueData[active.center] || {}) : {};
  const branchQueue = Array.isArray(branch.queue) ? branch.queue : [];
  const serving = branchQueue.find(item => item.status === 'serving') || null;
  const hasLiveQueue=Boolean(active&&active.arrivalStatus==='arrived'&&/^[APE]-/.test(String(active.queue||'')));
  const yourIndex = hasLiveQueue ? branchQueue.findIndex(item => item.num === active.queue) : -1;
  const ahead = yourIndex >= 0 ? branchQueue.slice(0, yourIndex).filter(item => item.status !== 'serving').length : 0;
  const estimatedWait = hasLiveQueue ? `${Math.max(0, ahead * 10)}–${Math.max(10, ahead * 15)} min` : '--';

  setDashText('upcomingCount', upcoming.length);
  setDashText('queueNumber', hasLiveQueue ? active.queue : '--');
  const queueChip = document.querySelector('.stat-chip');
  if (queueChip) queueChip.textContent = hasLiveQueue ? (String(active.queue || '').startsWith('P-') ? 'Priority Queue' : 'Regular Queue') : (active?'Awaiting Check-in':'No Queue');
  setDashText('queueStatus', active?.status || 'No Queue');
  setDashText('nowServing', serving?.num || '--');
  setDashText('peopleAhead', hasLiveQueue ? ahead : '--');
  setDashText('waitTime', estimatedWait);

  const statusSub = document.querySelector('#queueStatus + .stat-sub');
  if (statusSub) {
    statusSub.textContent = active
      ? `${active.service || 'Appointment'} • ${fmtDate(active.date)} ${active.time || ''}`
      : 'No active appointment';
  }

  const note = document.querySelector('.dash-queue-note');
  if (note) {
    note.innerHTML = hasLiveQueue
      ? `<i class="fa-solid fa-circle-info"></i> Your live queue number is <strong>${esc(active.queue || '--')}</strong> at ${esc(active.center || '--')}.`
      : active
        ? `<i class="fa-solid fa-circle-info"></i> ${String(active.status||'').toLowerCase()==='pending'?'This appointment requires manual review.':'Your appointment is confirmed. Your live queue number will be created when you check in.'}`
      : '<i class="fa-solid fa-circle-info"></i> Queue details will appear once you have an active appointment.';
  }

  renderDashboardAppointment(active);
  await announcementsPromise;
}

function announcementAttachmentUrl(item) {
  const raw=String(item&&item.attachment_url||'').trim().replace(/\\/g,'/');
  if(!raw)return '';
  try{return new URL(raw,window.location.href).href;}catch(_){return raw;}
}

function announcementIsImage(item) {
  if(item&&item.is_image)return true;
  const candidate=String((item&&item.attachment_name)||announcementAttachmentUrl(item)).split('?')[0].toLowerCase();
  return /\.(jpg|jpeg|png|webp)$/.test(candidate);
}

function announcementImageFailed(image) {
  const button=image&&image.closest('.patient-announcement-image-button');
  if(!button)return;
  const media=button.parentElement;
  const title=button.getAttribute('data-title')||'Community Notice';
  media.innerHTML=`<div class="patient-announcement-media patient-announcement-media-fallback" aria-label="Announcement image unavailable"><div class="patient-announcement-visual"><span class="patient-announcement-visual-icon"><i class="fa-solid fa-image"></i></span><strong>${esc(title)}</strong><span>Image unavailable. The announcement details remain visible.</span></div></div>`;
}

async function loadDashboardAnnouncements() {
  const box = document.getElementById('dashboardAnnouncements');
  if (!box) return;

  if (dashboardAnnouncementTimer) {
    clearInterval(dashboardAnnouncementTimer);
    dashboardAnnouncementTimer = null;
  }

  try {
    const result = await api('patient_announcements', null, 'GET');
    if (!result.ok) throw new Error(result.message || 'Unable to load announcements.');

    const scope = document.getElementById('announcementScope');
    if (scope) scope.textContent = result.branch ? `${result.branch} + All Branches` : 'All Branches';

    const rows = Array.isArray(result.announcements) ? result.announcements.slice(0, 5) : [];
    box.dataset.count = String(rows.length);
    box.innerHTML = rows.length
      ? `
          <div class="patient-announcement-track">
            ${rows.map((item, index) => {
              const priority=String(item.priority||'normal').toLowerCase();
              const priorityLabel=priority==='urgent'?'Urgent health advisory':priority==='important'?'Important health update':'Official health update';
              return `
              <article class="patient-announcement-card priority-${esc(priority)}${index === 0 ? ' is-active' : ''}" data-announcement-slide="${index}" data-announcement-id="${Number(item.id||0)}" ${index === 0 ? '' : 'hidden'}>
                <div class="patient-announcement-content">
                  <div class="patient-announcement-eyebrow">
                    <span class="patient-announcement-kicker">${esc(priorityLabel)}</span>
                    ${isRecentAnnouncement(item.created_at) ? '<span class="patient-announcement-new">New</span>' : ''}
                  </div>
                  <h4>${esc(item.title || 'Health Center Announcement')}</h4>
                  <p class="patient-announcement-message" data-announcement-message>${esc(announcementPreview(item.message || 'Please check this official health-center update for important information.'))}</p>
                  ${String(item.message||'').length > 220 ? `<button type="button" class="patient-announcement-readmore" data-full-message="${esc(item.message||'')}" onclick="toggleAnnouncementMessage(this)">Read more</button>` : ''}
                  <div class="patient-announcement-meta">
                    <span><i class="fa-solid fa-location-dot"></i>${esc([item.branch || 'All Branches',item.target_barangay&&item.target_barangay!=='All Barangays'?item.target_barangay:''].filter(Boolean).join(' • '))}</span>
                    <span><i class="fa-regular fa-calendar"></i>${formatAnnouncementDate(item.publish_at || item.created_at) || 'Recent update'}</span>
                  </div>
                  ${announcementAttachmentUrl(item) && !announcementIsImage(item)
                    ? `<a class="patient-announcement-file" href="${esc(announcementAttachmentUrl(item))}" target="_blank" rel="noopener"><i class="fa-solid fa-paperclip"></i>View attached document</a>`
                    : ''}
                </div>
                ${renderAnnouncementMedia(item, index)}
              </article>`}).join('')}
          </div>
          ${rows.length > 1 ? `
            <div class="patient-announcement-controls" aria-label="Announcement carousel controls">
              <button class="patient-announcement-arrow" type="button" data-announcement-direction="-1" aria-label="Previous announcement"><i class="fa-solid fa-chevron-left"></i></button>
              <div class="patient-announcement-dots">
                ${rows.map((_, index) => `<button class="patient-announcement-dot${index === 0 ? ' is-active' : ''}" type="button" data-announcement-dot="${index}" aria-label="Show announcement ${index + 1}" aria-current="${index === 0 ? 'true' : 'false'}"></button>`).join('')}
              </div>
              <span class="patient-announcement-position" data-announcement-position>1 / ${rows.length}</span>
              <button class="patient-announcement-arrow" type="button" data-announcement-direction="1" aria-label="Next announcement"><i class="fa-solid fa-chevron-right"></i></button>
            </div>` : ''}`
      : '<div class="patient-announcement-empty"><i class="fa-regular fa-bell"></i><br>No active announcements right now.</div>';

    if (rows.length > 1) setupDashboardAnnouncementCarousel(box, rows.length);
    else if(rows.length) markDashboardAnnouncementRead(Number(rows[0].id||0));
  } catch (error) {
    box.dataset.count = '0';
    box.innerHTML = `<div class="patient-announcement-empty"><i class="fa-solid fa-circle-exclamation"></i><br>${esc(error.message)}</div>`;
  }
}


function announcementPreview(value) {
  const text=String(value||'').trim();
  return text.length>220 ? text.slice(0,217).trimEnd()+'…' : text;
}
function toggleAnnouncementMessage(button) {
  const paragraph=button?.previousElementSibling;
  if(!paragraph)return;
  const expanded=button.dataset.expanded==='true';
  const full=button.getAttribute('data-full-message')||'';
  paragraph.textContent=expanded?announcementPreview(full):full;
  button.dataset.expanded=expanded?'false':'true';
  button.textContent=expanded?'Read more':'Show less';
}

function formatAnnouncementDate(value){const date=new Date(value);return Number.isNaN(date.getTime())?'':date.toLocaleDateString('en-PH',{month:'short',day:'numeric',year:'numeric'})}

function isRecentAnnouncement(value) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return false;
  const age = Date.now() - date.getTime();
  return age >= 0 && age <= 7 * 24 * 60 * 60 * 1000;
}

function renderAnnouncementMedia(item, index) {
  const url=announcementAttachmentUrl(item);
  const title=String(item.title||'Health center announcement');
  if (announcementIsImage(item) && url) {
    return `<div class="patient-announcement-media"><button type="button" class="patient-announcement-image-button" data-title="${esc(title)}" onclick="openAnnouncementImage(decodeURIComponent('${encodeURIComponent(url)}'),decodeURIComponent('${encodeURIComponent(title)}'))" aria-label="View announcement image"><img src="${esc(url)}" alt="${esc(title)}" loading="${index === 0 ? 'eager' : 'lazy'}" onerror="announcementImageFailed(this)"><span class="patient-announcement-image-hint"><i class="fa-solid fa-expand"></i> View image</span></button></div>`;
  }

  const hasFile = Boolean(url);
  return `
    <div class="patient-announcement-media" aria-hidden="true">
      <div class="patient-announcement-visual">
        <span class="patient-announcement-visual-icon"><i class="fa-solid ${hasFile ? 'fa-file-medical' : 'fa-bullhorn'}"></i></span>
        <strong>${hasFile ? 'Health Document' : 'Community Notice'}</strong>
        <span>Pulilan Health Center</span>
      </div>
    </div>`;
}


function openAnnouncementImage(url,title){
 let modal=document.getElementById('announcementImageModal');
 if(!modal){modal=document.createElement('div');modal.id='announcementImageModal';modal.className='announcement-image-modal';modal.innerHTML='<div class="announcement-image-dialog" role="dialog" aria-modal="true"><button type="button" class="announcement-image-close" aria-label="Close image">&times;</button><img alt=""><p></p></div>';document.body.appendChild(modal);modal.addEventListener('click',event=>{if(event.target===modal||event.target.closest('.announcement-image-close'))modal.classList.remove('show')});}
 modal.querySelector('img').src=url;modal.querySelector('img').alt=title;modal.querySelector('p').textContent=title;modal.classList.add('show');
}

const dashboardAnnouncementReads=new Set();
function markDashboardAnnouncementRead(id){
  if(!id||dashboardAnnouncementReads.has(id))return;
  dashboardAnnouncementReads.add(id);
  api('patient_mark_announcement_read',{id},'POST').catch(()=>dashboardAnnouncementReads.delete(id));
}

function setupDashboardAnnouncementCarousel(box, count) {
  const slides = Array.from(box.querySelectorAll('[data-announcement-slide]'));
  const dots = Array.from(box.querySelectorAll('[data-announcement-dot]'));
  const position = box.querySelector('[data-announcement-position]');
  const track = box.querySelector('.patient-announcement-track');
  let activeIndex = 0;
  let touchStartX = null;

  const showSlide = nextIndex => {
    activeIndex = (nextIndex + count) % count;
    slides.forEach((slide, index) => {
      const active = index === activeIndex;
      slide.hidden = !active;
      slide.classList.toggle('is-active', active);
      slide.setAttribute('aria-hidden', String(!active));
    });
    dots.forEach((dot, index) => {
      const active = index === activeIndex;
      dot.classList.toggle('is-active', active);
      dot.setAttribute('aria-current', String(active));
    });
    if (position) position.textContent = `${activeIndex + 1} / ${count}`;
    markDashboardAnnouncementRead(Number(slides[activeIndex]?.dataset.announcementId||0));
  };

  const stopTimer = () => {
    if (!dashboardAnnouncementTimer) return;
    clearInterval(dashboardAnnouncementTimer);
    dashboardAnnouncementTimer = null;
  };

  const startTimer = () => {
    stopTimer();
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    dashboardAnnouncementTimer = setInterval(() => showSlide(activeIndex + 1), 7000);
  };

  box.querySelectorAll('[data-announcement-direction]').forEach(button => {
    button.addEventListener('click', () => {
      showSlide(activeIndex + Number(button.dataset.announcementDirection || 1));
      startTimer();
    });
  });

  dots.forEach(dot => {
    dot.addEventListener('click', () => {
      showSlide(Number(dot.dataset.announcementDot || 0));
      startTimer();
    });
  });

  if (track) {
    track.addEventListener('touchstart', event => {
      touchStartX = event.changedTouches[0]?.clientX ?? null;
      stopTimer();
    }, { passive: true });
    track.addEventListener('touchend', event => {
      const touchEndX = event.changedTouches[0]?.clientX ?? null;
      if (touchStartX !== null && touchEndX !== null && Math.abs(touchEndX - touchStartX) > 45) {
        showSlide(activeIndex + (touchEndX < touchStartX ? 1 : -1));
      }
      touchStartX = null;
      startTimer();
    }, { passive: true });
  }

  box.addEventListener('mouseenter', stopTimer);
  box.addEventListener('mouseleave', startTimer);
  box.addEventListener('focusin', stopTimer);
  box.addEventListener('focusout', startTimer);
  showSlide(0);
  startTimer();
}

function renderDashboardAppointment(appointment) {
  const box = document.getElementById('appointmentCard');
  if (!box) return;

  if (!appointment) {
    box.innerHTML = `
      <div class="appt-empty">
        <div class="appt-empty-icon"><i class="fa-regular fa-calendar"></i></div>
        <div class="appt-empty-copy"><h6>No upcoming appointments</h6><p>Book a visit to see your schedule here.</p></div>
      </div>`;
    return;
  }

  const date = new Date((appointment.date || '') + 'T00:00:00');
  const day = Number.isNaN(date.getTime()) ? '--' : date.getDate();
  const month = Number.isNaN(date.getTime()) ? '--' : date.toLocaleDateString('en-US', { month: 'short' }).toUpperCase();
  const weekday = Number.isNaN(date.getTime()) ? '--' : date.toLocaleDateString('en-US', { weekday: 'short' }).toUpperCase();
  const priority = String(appointment.queue || '').startsWith('P-');
  const hasLiveQueue = appointment.arrivalStatus === 'arrived' && /^[APE]-/.test(String(appointment.queue || ''));

  box.innerHTML = `
    <div class="clean-appt-card">
      <div class="clean-date-box">
        <span class="clean-month">${month}</span>
        <strong>${day}</strong>
        <span class="clean-weekday">${weekday}</span>
      </div>

      <div class="clean-appt-details">
        <div class="clean-title-row">
          <div>
            <span class="clean-status">${esc(appointment.status || 'Confirmed')}</span>
            <h3>${esc(appointment.service || 'Health Center Appointment')}</h3>
          </div>
          <span class="clean-queue-type">${priority ? 'Priority' : 'Regular'}</span>
        </div>

        <div class="clean-meta">
          <span><i class="fa-regular fa-clock"></i>${esc(appointment.time || '--')}</span>
          <span><i class="fa-solid fa-location-dot"></i>${esc(appointment.center || '--')}</span>
          <span><i class="fa-solid fa-hospital"></i>Pulilan Health Center</span>
        </div>
      </div>

      <div class="clean-queue-box">
        <small>${hasLiveQueue ? 'Live Queue No.' : 'Appointment Ref.'}</small>
        <strong>${esc(appointment.queue || '--')}</strong>
        <span>${hasLiveQueue ? (priority ? 'Priority Queue' : 'Regular Queue') : 'Awaiting Check-in'}</span>
      </div>

      <div class="clean-card-footer">
        <a href="appointments.html" class="clean-manage-btn">
          <i class="fa-regular fa-calendar-check"></i>
          Manage Appointment
        </a>
      </div>
    </div>`;
}

function renderDashboardError(message) {
  setDashText('upcomingCount', '--');
  setDashText('queueNumber', '--');
  setDashText('queueStatus', 'Unavailable');
  setDashText('nowServing', '--');
  setDashText('peopleAhead', '--');
  setDashText('waitTime', '--');
  const box = document.getElementById('appointmentCard');
  if (box) {
    box.innerHTML = `<div class="appt-empty"><div class="appt-empty-icon"><i class="fa-solid fa-triangle-exclamation"></i></div><div class="appt-empty-copy"><h6>Unable to load appointment</h6><p>${esc(message)}</p></div></div>`;
  }
}

function setDashText(id, value) {
  const element = document.getElementById(id);
  if (element) element.textContent = value;
}
