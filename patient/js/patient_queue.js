const queueCenters = ['RHU I - Poblacion', 'RHU II - Cutcot', 'RHU III - Tinejero', 'RHU IV - Tibag'];
let selectedCenterIndex = 0;
let patientQueueAppointment = null;
let allQueueData = {};
let selectedCenterInitialized = false;

document.addEventListener('DOMContentLoaded', async () => {
  const patient = await loadPatientNav();
  if (!patient) return;

  await refreshQueue();
  window.setInterval(refreshQueue, 15000);
});

async function refreshQueue() {
  const button = document.getElementById('refreshBtn');
  if (button) button.disabled = true;

  let result = await api('patient_queue_data', null, 'GET');

  if (button) button.disabled = false;

  if (!result.ok) {
    if(!navigator.onLine){
      try{const saved=JSON.parse(localStorage.getItem('phc_queue_snapshot')||'null');if(saved?.data){result=saved.data;setQueueText('lastUpdated',`Offline copy • ${new Date(saved.savedAt).toLocaleString('en-PH')}`)}else throw new Error('none')}catch(_){renderQueueError('No saved queue copy is available on this device yet.');return}
    }else{
    renderQueueError(result.message || 'Unable to load queue data.');
    return;
    }
  }else{
    try{localStorage.setItem('phc_queue_snapshot',JSON.stringify({savedAt:Date.now(),data:{ok:true,appointment:result.appointment||null,queueData:result.queueData||{}}}))}catch(_){}
  }

  patientQueueAppointment = result.appointment || null;
  allQueueData = result.queueData || {};

  if (!selectedCenterInitialized && patientQueueAppointment?.center) {
    const index = queueCenters.indexOf(patientQueueAppointment.center);
    if (index >= 0) selectedCenterIndex = index;
  }
  selectedCenterInitialized = true;

  syncActiveCenterTab();
  renderQueue();
  if(navigator.onLine)setQueueText('lastUpdated', new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }));
}

function selectCenter(index, button) {
  selectedCenterIndex = Number(index) || 0;
  document.querySelectorAll('.center-tab').forEach(tab => tab.classList.remove('active'));
  button?.classList.add('active');
  renderQueue();
}

function syncActiveCenterTab() {
  document.querySelectorAll('.center-tab').forEach((tab, index) => {
    tab.classList.toggle('active', index === selectedCenterIndex);
  });
}

function renderQueue() {
  const center = queueCenters[selectedCenterIndex];
  const branch = allQueueData[center] || { served: 0, waitTimes: [], queue: [] };
  const queue = Array.isArray(branch.queue) ? branch.queue : [];
  const serving = queue.find(item => item.status === 'serving') || null;
  const waiting = queue.filter(item => item.status !== 'serving');

  const average = Number.isFinite(Number(branch.averageWait))
    ? Math.round(Number(branch.averageWait))
    : (Array.isArray(branch.waitTimes) && branch.waitTimes.length
      ? Math.round(branch.waitTimes.reduce((sum, value) => sum + Number(value || 0), 0) / branch.waitTimes.length)
      : null);

  setQueueText('infoTotal', waiting.length);
  setQueueText('infoServed', branch.served || 0);
  setQueueText('infoWait', average === null ? '--' : `${average} min`);
  setQueueText('nowNumber', serving?.num || '--');

  const nowService = document.getElementById('nowService');
  if (nowService) {
    nowService.innerHTML = `
      <i class="fas fa-stethoscope" style="color:#9ca3af;font-size:12px;"></i>
      <span>${esc(serving?.svc || 'No patient is being served')}</span>`;
  }

  const served = Number(branch.served || 0);
  const total = served + queue.length;
  const percent = total ? Math.round((served / total) * 100) : 0;

  setQueueText('progressLabel', `${served} / ${total}`);
  const progressFill = document.getElementById('progressFill');
  if (progressFill) progressFill.style.width = `${percent}%`;

  renderYourQueue(center, queue, average);
  renderQueueTable(queue);
  setQueueText('queueMeta', `${queue.length} active queue entr${queue.length === 1 ? 'y' : 'ies'}`);
}

function renderYourQueue(center, queue, average) {
  const box = document.getElementById('yourQueueWrap');
  const noticeBox = document.getElementById('noticeBox');
  const noticeText = document.getElementById('noticeText');

  if (!box) return;

  if (!patientQueueAppointment) {
    box.innerHTML = `
      <div class="yq-empty">
        <div class="yq-empty-icon"><i class="fa-regular fa-calendar-plus"></i></div>
        <h6>No active queue</h6>
        <p>Book an available schedule. Your appointment will be confirmed automatically, then you can check in on the scheduled date.</p>
      </div>`;
    if (noticeBox) noticeBox.style.display = 'none';
    return;
  }

  if (patientQueueAppointment.center !== center) {
    const ownIndex = queueCenters.indexOf(patientQueueAppointment.center);
    const appointmentCode = `APT-${String(patientQueueAppointment.id || 0).padStart(5, '0')}`;
    const hasOwnLiveQueue = patientQueueAppointment.arrivalStatus === 'arrived' && /^[APE]-/.test(String(patientQueueAppointment.queue || ''));
    box.innerHTML = `
      <div class="appointment-ready-card cross-branch-card">
        <div class="appointment-ready-top">
          <div class="appointment-ready-icon"><i class="fa-solid fa-hospital-user"></i></div>
          <div class="appointment-ready-copy">
            <span>Your Appointment</span>
            <h6>${hasOwnLiveQueue ? esc(patientQueueAppointment.queue) : esc(appointmentCode)}</h6>
            <p>Your appointment remains assigned to <strong>${esc(patientQueueAppointment.center || '--')}</strong>. You may continue viewing the public queue for ${esc(center)}.</p>
          </div>
        </div>
        <div class="appointment-ready-details">
          <div class="appointment-ready-detail"><i class="fa-regular fa-calendar"></i><span>Date<strong>${esc(formatQueueAppointmentDate(patientQueueAppointment.date))}</strong></span></div>
          <div class="appointment-ready-detail"><i class="fa-regular fa-clock"></i><span>Time<strong>${esc(formatQueueAppointmentTime(patientQueueAppointment.time))}</strong></span></div>
          <div class="appointment-ready-detail"><i class="fa-solid fa-stethoscope"></i><span>Service<strong>${esc(patientQueueAppointment.service || '--')}</strong></span></div>
          <div class="appointment-ready-detail"><i class="fa-solid fa-building"></i><span>Assigned RHU<strong>${esc(patientQueueAppointment.center || '--')}</strong></span></div>
        </div>
        <div class="appointment-ready-actions">
          <button type="button" class="yq-qr-link" onclick="selectMyRhu(${ownIndex})"><i class="fa-solid fa-arrow-right"></i> View My RHU Queue</button>
          <a class="yq-secondary-link" href="${hasOwnLiveQueue ? 'qr.html' : 'appointments.html'}"><i class="fa-solid ${hasOwnLiveQueue ? 'fa-qrcode' : 'fa-calendar-check'}"></i>${hasOwnLiveQueue ? 'Show QR' : 'View Appointment'}</a>
        </div>
      </div>`;
    if (noticeBox) {
      noticeBox.style.display = 'flex';
      if (noticeText) noticeText.textContent = `Showing public queue information for ${center}. Your personal queue position is available under ${patientQueueAppointment.center}.`;
    }
    return;
  }

  const hasLiveQueue=patientQueueAppointment.arrivalStatus==='arrived'&&/^[APE]-/.test(String(patientQueueAppointment.queue||''));
  if(!hasLiveQueue){
    const confirmed=String(patientQueueAppointment.status||'').toLowerCase()==='confirmed';
    if(confirmed){
      const appointmentCode=`APT-${String(patientQueueAppointment.id||0).padStart(5,'0')}`;
      const queueType=String(patientQueueAppointment.queueType||'regular').toLowerCase()==='priority'?'Priority Queue':'Regular Queue';
      const appointmentDate=patientQueueAppointment.date
        ? new Date(`${patientQueueAppointment.date}T00:00:00`).toLocaleDateString('en-US',{month:'short',day:'numeric',year:'numeric'})
        : '--';
      const appointmentTime=patientQueueAppointment.time||'--';
      box.innerHTML=`
        <div class="yq-block">
          <div class="yq-label">Upcoming Appointment</div>
          <div class="yq-number">${esc(appointmentCode)}</div>
          <div class="yq-ahead-pill" style="background:#dcfce7;color:#166534;">
            <i class="fa-solid fa-circle-check"></i>
            Awaiting Check-in
          </div>
          <div class="yq-wait"><strong>${esc(appointmentDate)}</strong> • <strong>${esc(appointmentTime)}</strong></div>
          <div class="yq-center-name">
            ${esc(patientQueueAppointment.service||'--')} • ${esc(queueType)}
          </div>
          <a class="yq-qr-link" href="qr.html">
            <i class="fa-solid fa-qrcode"></i>
            Show Check-in QR
          </a>
        </div>`;
      if(noticeBox){noticeBox.style.display='flex';if(noticeText)noticeText.textContent='APT is your appointment reference only. Your live queue number will be assigned after QR or manual check-in.'}
    }else{
      box.innerHTML=`
        <div class="appointment-review-card">
          <div class="appointment-review-icon"><i class="fa-solid fa-clock-rotate-left"></i></div>
          <div><h6>Appointment Under Manual Review</h6><p>This status is used only for exceptional or older requests. The assigned RHU will update the appointment.</p></div>
        </div>`;
      if(noticeBox){noticeBox.style.display='flex';if(noticeText)noticeText.textContent='Normal bookings are automatically confirmed. This appointment requires a manual staff update.'}
    }
    return;
  }

  const index = queue.findIndex(item => item.num === patientQueueAppointment.queue);
  const ahead = index >= 0
    ? queue.slice(0, index).filter(item => item.status !== 'serving').length
    : 0;

  const estimateMinutes = average === null ? 10 : average;
  const wait = Math.max(0, ahead * estimateMinutes);
  const priority = String(patientQueueAppointment.queue || '').startsWith('P-');
  maybeNotifyQueueProximity(ahead,patientQueueAppointment);

  box.innerHTML = `
    <div class="yq-block">
      <div class="yq-label">Your Queue Number</div>
      <div class="yq-number">${esc(patientQueueAppointment.queue || '--')}</div>
      <div class="yq-ahead-pill">
        <i class="fa-solid fa-users"></i>
        ${ahead} ${ahead === 1 ? 'person' : 'people'} ahead
      </div>
      <div class="yq-wait">Estimated waiting time: <strong>${wait} minutes</strong>${average === null ? ' <span class="estimate-note">(default estimate)</span>' : ''}</div>
      <div class="yq-center-name">
        ${esc(patientQueueAppointment.service || '')} •
        ${priority ? 'Priority Queue' : 'Regular Queue'}
      </div>
      <a class="yq-qr-link" href="qr.html">
        <i class="fa-solid fa-qrcode"></i>
        Show QR
      </a>
    </div>`;

  if (noticeBox) {
    noticeBox.style.display = 'flex';
    if (noticeText) {
      noticeText.textContent = priority
        ? 'Priority status is subject to staff verification. Bring a valid supporting ID or document.'
        : 'Please arrive 10–15 minutes before your appointment and bring a valid ID.';
    }
  }
}

function selectMyRhu(index) {
  if (index < 0) return;
  selectedCenterIndex = index;
  syncActiveCenterTab();
  renderQueue();
  document.querySelector('.center-tabs')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function setupAverageInfo() {
  const trigger = document.getElementById('averageInfoTrigger');
  const tip = document.getElementById('averageInfoTip');
  if (!trigger || !tip) return;
  const close = () => { tip.hidden = true; trigger.setAttribute('aria-expanded', 'false'); };
  trigger.addEventListener('click', (event) => {
    event.stopPropagation();
    const opening = tip.hidden;
    tip.hidden = !opening;
    trigger.setAttribute('aria-expanded', opening ? 'true' : 'false');
  });
  trigger.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') close();
  });
  document.addEventListener('click', (event) => {
    if (!tip.contains(event.target) && event.target !== trigger) close();
  });
}

document.addEventListener('DOMContentLoaded', setupAverageInfo);

function maybeNotifyQueueProximity(ahead,appointment){
  if(ahead<0||ahead>3||!appointment?.queue||!('Notification'in window)||Notification.permission!=='granted')return;
  const key=`phc-near-${appointment.queue}-${appointment.date||''}`;if(localStorage.getItem(key))return;
  const notification=new Notification('Your turn is getting close',{body:ahead===0?`Queue ${appointment.queue}: please proceed to the service area.`:`Only ${ahead} patient${ahead===1?'':'s'} ahead of queue ${appointment.queue}. Please stay nearby.`,tag:key,icon:'images/mhc-logo.png'});
  notification.onclick=()=>{window.focus();notification.close()};localStorage.setItem(key,String(Date.now()));
}

function renderQueueTable(queue) {
  const box = document.getElementById('queueList');
  if (!box) return;

  if (!queue.length) {
    box.innerHTML = `
      <div class="yq-empty" style="padding:28px 16px;">
        <div class="yq-empty-icon"><i class="fa-solid fa-list-ol"></i></div>
        <h6>No active queue</h6>
        <p>This branch currently has no waiting patients.</p>
      </div>`;
    return;
  }

  box.innerHTML = `
    <table class="queue-table">
      <thead>
        <tr>
          <th>Queue No.</th>
          <th>Service</th>
          <th>Queue Type</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        ${queue.map(item => {
          const mine = patientQueueAppointment && item.num === patientQueueAppointment.queue;
          const serving = item.status === 'serving';
          return `
            <tr class="${serving ? 'is-serving' : ''} ${mine ? 'is-mine' : ''}">
              <td>
                <span class="q-num ${serving ? 'serving' : ''} ${mine ? 'mine' : ''}">
                  ${esc(item.num || '--')}
                </span>
              </td>
              <td>${esc(item.svc || '--')}</td>
              <td>${item.type === 'priority' ? 'Priority' : 'Regular'}</td>
              <td>
                <span class="q-badge ${mine ? 'badge-mine' : (serving ? 'badge-serving' : 'badge-waiting')}">
                  ${mine ? 'Your Queue' : (serving ? 'Now Serving' : 'Waiting')}
                </span>
              </td>
            </tr>`;
        }).join('')}
      </tbody>
    </table>`;
}

function renderQueueError(message) {
  setQueueText('infoTotal', '--');
  setQueueText('infoServed', '--');
  setQueueText('infoWait', '--');
  setQueueText('nowNumber', '--');

  const yourQueue = document.getElementById('yourQueueWrap');
  if (yourQueue) {
    yourQueue.innerHTML = `<div class="yq-empty"><div class="yq-empty-icon"><i class="fa-solid fa-triangle-exclamation"></i></div><h6>Unable to load queue</h6><p>${esc(message)}</p></div>`;
  }

  const list = document.getElementById('queueList');
  if (list) list.innerHTML = '';
}

function formatQueueAppointmentDate(value) {
  if (!value) return '--';
  const date = new Date(`${value}T00:00:00`);
  if (Number.isNaN(date.getTime())) return String(value);
  return date.toLocaleDateString('en-PH', { month: 'short', day: 'numeric', year: 'numeric' });
}

function formatQueueAppointmentTime(value) {
  if (!value) return '--';
  const match = String(value).match(/^(\d{1,2}):(\d{2})/);
  if (!match) return String(value);
  const date = new Date();
  date.setHours(Number(match[1]), Number(match[2]), 0, 0);
  return date.toLocaleTimeString('en-PH', { hour: 'numeric', minute: '2-digit' });
}

function setQueueText(id, value) {
  const element = document.getElementById(id);
  if (element) element.textContent = value;
}
