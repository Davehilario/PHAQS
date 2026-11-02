let allAppointments = [];
let cancelId = null;

document.addEventListener('DOMContentLoaded', async () => {
  const patient = await loadPatientNav();
  if (!patient) return;

  document.getElementById('confirmCancelBtn')?.addEventListener('click', doCancel);
  document.getElementById('successOkBtn')?.addEventListener('click', () => location.reload());
  await loadAppointments();
});

async function loadAppointments() {
  const result = await api('patient_appointments', null, 'GET');

  if (!result.ok) {
    renderAppointmentsError(result.message || 'Unable to load appointments.');
    return;
  }

  allAppointments = Array.isArray(result.appointments) ? result.appointments : [];
  renderAppointments();
}

function renderAppointments() {
  const activeStatuses = ['pending', 'confirmed', 'serving', 'hold', 'waiting'];
  const completedStatuses = ['completed', 'done'];
  const historyStatuses = ['completed', 'done', 'cancelled', 'no show'];

  const active = allAppointments.filter(item =>
    activeStatuses.includes(String(item.status || '').toLowerCase())
  );
  const completed = allAppointments.filter(item =>
    completedStatuses.includes(String(item.status || '').toLowerCase())
  );
  const history = allAppointments.filter(item =>
    historyStatuses.includes(String(item.status || '').toLowerCase())
  );

  setTextValue('statUpcoming', active.length);
  setTextValue('statCompleted', completed.length);
  setTextValue('statTotal', allAppointments.length);

  const activeContainer = document.getElementById('activeContainer');
  const historyContainer = document.getElementById('historyContainer');

  if (activeContainer) {
    activeContainer.innerHTML = active.length
      ? active.map(activeAppointmentMarkup).join('')
      : `
        <div class="empty-state">
          <i class="fa-regular fa-calendar-plus"></i>
          <h4>No active appointment</h4>
          <p>Your confirmed appointment will appear here after booking.</p>
        </div>`;
  }

  if (historyContainer) {
    historyContainer.innerHTML = history.length
      ? historyTableMarkup(history)
      : `
        <div class="empty-state">
          <i class="fa-regular fa-clock"></i>
          <h4>No appointment history</h4>
          <p>Your completed or cancelled appointments will appear here.</p>
        </div>`;
  }
}

function activeAppointmentMarkup(appointment) {
  const status = String(appointment.status || 'Confirmed');
  const priority = String(appointment.queue || '').startsWith('P-');
  const hasLiveQueue=appointment.arrivalStatus==='arrived'&&/^[APE]-/.test(String(appointment.queue||''));
  const approved=status.toLowerCase()==='confirmed';
  const note = appointment.notes || appointment.concern || 'Please arrive 10–15 minutes before your selected time and bring a valid ID.';

  return `
    <div class="active-body">
      <div class="active-border-accent"></div>

      <div class="doctor-icon-box">
        <i class="fas fa-stethoscope"></i>
      </div>

      <div class="active-info">
        <div class="status-row">
          <h2>${esc(appointment.service || 'Health Center Appointment')}</h2>
          ${appointment.isDependent?`<span class="status-badge" style="background:#eff6ff;color:#1e40af"><i class="fas fa-people-roof"></i> ${esc(appointment.patient||'Dependent')}</span>`:''}
        </div>

        <p class="description">${priority ? 'Priority Queue - Subject to staff verification' : 'Regular Queue'}</p>

        <div class="active-meta">
          <div class="meta-item">
            <i class="fa-regular fa-calendar"></i>
            <span>${fmtDate(appointment.date)}</span>
          </div>
          <div class="meta-item">
            <i class="fa-regular fa-clock"></i>
            <span>${esc(appointment.time || '--')}</span>
          </div>
          <div class="meta-item">
            <i class="fa-solid fa-location-dot"></i>
            <span>${esc(appointment.center || '--')}</span>
          </div>
          <div class="meta-item">
            <i class="fa-solid fa-ticket"></i>
            <span>${hasLiveQueue?'Live Queue':'Appointment Reference'} <strong>${esc(appointment.queue || '--')}</strong></span>
          </div>
        </div>

        <div class="note-strip">
          <i class="fa-solid fa-circle-info"></i>
          <span>${esc(note)}</span>
        </div>
      </div>

      <div class="active-actions">
        <span class="status-badge action-status badge-${statusClass(status)}">${esc(status)}</span>
        <button type="button" class="btn-action btn-view" onclick="viewAppointment(${Number(appointment.id)})">
          <i class="fa-regular fa-eye"></i> View Details
        </button>
        ${approved?`<button type="button" class="btn-action btn-view" onclick="openAppointmentQR(${Number(appointment.id)})">
          <i class="fas fa-qrcode"></i> View QR
        </button>`:''}
        <button type="button" class="btn-action btn-cancel" onclick="askCancel(${Number(appointment.id)})">
          <i class="fa-solid fa-xmark"></i> Cancel
        </button>
      </div>
    </div>`;
}

function historyTableMarkup(history) {
  return `
    <div class="history-header">
      <div>Service</div>
      <div>Date</div>
      <div>Health Center</div>
      <div>Status</div>
      <div>Action</div>
    </div>
    ${history.map(appointment => `
      <div class="history-item">
        <div class="service-meta">
          <div class="service-icon-sm"><i class="fas fa-stethoscope"></i></div>
          <div class="service-text">
            <h4>${esc(appointment.service || 'Health Center Appointment')}</h4>
            <p>${appointment.isDependent?`${esc(appointment.patient||'Dependent')} • `:''}Queue ${esc(appointment.queue || '--')}</p>
          </div>
        </div>
        <div>
          <div class="hist-date">${fmtDate(appointment.date)}</div>
          <div class="hist-time">${esc(appointment.time || '--')}</div>
        </div>
        <div class="hist-date">${esc(appointment.center || '--')}</div>
        <div>
          <span class="status-badge badge-${statusClass(appointment.status)}">${esc(appointment.status || '--')}</span>
        </div>
        <div>
          <button type="button" class="btn-action btn-view" onclick="viewAppointment(${Number(appointment.id)})">
            <i class="fa-regular fa-eye"></i> View
          </button>
        </div>
      </div>`).join('')}`;
}

function viewAppointment(id) {
  const appointment = allAppointments.find(item => Number(item.id) === Number(id));
  if (!appointment) return;

  setTextValue('dCenter', appointment.center || '--');
  setTextValue('dService', appointment.service || '--');
  setTextValue('dDate', fmtDate(appointment.date));
  setTextValue('dTime', appointment.time || '--');
  setTextValue('dQueue', appointment.queue || '--');
  setTextValue('dStatus', appointment.status || '--');

  const note = appointment.notes || appointment.concern || '';
  const noteSection = document.getElementById('dNoteSection');
  if (noteSection) noteSection.style.display = note ? 'block' : 'none';
  setTextValue('dNote', note);

  const qrButton = document.getElementById('dQRBtn');
  if (qrButton) {
    qrButton.style.display = String(appointment.status||'').toLowerCase()==='confirmed' ? 'inline-flex' : 'none';
    qrButton.onclick = () => openAppointmentQR(id);
  }

  bootstrap.Modal.getOrCreateInstance(document.getElementById('detailsModal')).show();
}

function openAppointmentQR(id) {
  const appointment = allAppointments.find(item => Number(item.id) === Number(id));
  if (!appointment) return;
  sessionStorage.setItem('selectedAppointmentId', String(appointment.id));
  window.location.href = 'qr.html';
}

function printQR() {
  window.print();
}

function askCancel(id) {
  cancelId = Number(id);
  bootstrap.Modal.getOrCreateInstance(document.getElementById('cancelModal')).show();
}

async function doCancel() {
  if (!cancelId) return;

  const button = document.getElementById('confirmCancelBtn');
  if (button) button.disabled = true;

  const result = await api('cancel_appointment', { id: cancelId }, 'POST');

  if (button) button.disabled = false;

  if (!result.ok) {
    alert(result.message || 'Unable to cancel appointment.');
    return;
  }

  bootstrap.Modal.getOrCreateInstance(document.getElementById('cancelModal')).hide();
  bootstrap.Modal.getOrCreateInstance(document.getElementById('successModal')).show();
}

function renderAppointmentsError(message) {
  setTextValue('statUpcoming', '--');
  setTextValue('statCompleted', '--');
  setTextValue('statTotal', '--');

  const activeContainer = document.getElementById('activeContainer');
  const historyContainer = document.getElementById('historyContainer');

  if (activeContainer) {
    activeContainer.innerHTML = `<div class="empty-state"><i class="fa-solid fa-triangle-exclamation"></i><h4>Unable to load appointment</h4><p>${esc(message)}</p></div>`;
  }
  if (historyContainer) historyContainer.innerHTML = '';
}

function statusClass(status) {
  return String(status || '').toLowerCase().replace(/\s+/g, '-');
}

function setTextValue(id, value) {
  const element = document.getElementById(id);
  if (element) element.textContent = value;
}
