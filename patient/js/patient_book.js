let booking = { service: '', center: '', time: '' };
let currentStep = 1;
let patientRecord = null;
let selectedBookingPatientId = 0;
let familyDependents = [];

document.addEventListener('DOMContentLoaded', async () => {
  patientRecord = await loadPatientNav();
  if (!patientRecord) return;
  fillPatientDetails(patientRecord);
  initBooking();
  await initFamilyBooking();
  showStep(1);
});

async function initFamilyBooking(){
  const result=await api('patient_family_list',null,'GET');
  if(!result.ok)return;
  familyDependents=(result.outgoing||[]).filter(x=>x.status==='Approved'&&x.can_manage);
  if(!familyDependents.length)return;
  const bar=document.getElementById('familyBookingBar'),select=document.getElementById('bookingForPatient');
  bar.style.display='flex';
  select.innerHTML=`<option value="0">Myself — ${esc(patientRecord.name||'Patient')}</option>`+familyDependents.map(x=>`<option value="${Number(x.patient_db_id)}">${esc(x.first_name+' '+x.last_name)} — ${esc(x.relationship)}</option>`).join('');
  select.addEventListener('change',()=>selectBookingPatient(Number(select.value||0)));
  const requested=Number(new URLSearchParams(location.search).get('for')||0);
  if(familyDependents.some(x=>Number(x.patient_db_id)===requested)){select.value=String(requested);selectBookingPatient(requested)}
}

function selectBookingPatient(id){
  selectedBookingPatientId=Number(id||0);
  if(!selectedBookingPatientId){fillPatientDetails(patientRecord);return}
  const p=familyDependents.find(x=>Number(x.patient_db_id)===selectedBookingPatientId);if(!p)return;
  fillPatientDetails({name:`${p.first_name||''} ${p.last_name||''}`.trim(),email:p.email||'',birthdate:p.birthdate||'',gender:p.gender||'',barangay:p.barangay||'',phone:p.phone||'',address:p.address||''});
}

function initBooking() {
  document.querySelectorAll('.service-card').forEach(card => {
    card.addEventListener('click', async () => {
      booking.service = card.dataset.service || '';
      document.getElementById('service').value = booking.service;
      document.querySelectorAll('.service-card').forEach(c => c.classList.remove('active', 'selected'));
      card.classList.add('active', 'selected');
      setText('summaryServiceName', booking.service);
      setText('summaryServiceDesc', card.dataset.description || '');
      if(value('date')) await refreshBranchRecommendations();
      if(value('healthCenter')&&value('date'))await refreshBookingInfo();
      updateReview();
    });
  });

  document.querySelectorAll('.time-slot').forEach(bindTimeSlot);

  document.getElementById('healthCenter')?.addEventListener('change', async e => {
    booking.center = e.target.value;
    booking.time = '';
    document.querySelectorAll('.time-slot').forEach(x => x.classList.remove('active', 'selected'));
    if(value('date')&&value('service')) await refreshBranchRecommendations();
    await refreshBookingInfo();
    updateReview();
  });

  const date = document.getElementById('date');
  if (date && window.flatpickr) {
    const min = new Date();
    min.setHours(0,0,0,0);
    flatpickr(date, {
      minDate: min,
      disableMobile: true,
      dateFormat: 'Y-m-d',
      onChange: async () => {
        booking.time = '';
        document.querySelectorAll('.time-slot').forEach(x => x.classList.remove('active', 'selected'));
        await refreshBranchRecommendations();
        await refreshBookingInfo();
        updateReview();
      }
    });
  }

  document.querySelectorAll('input[name="queueCategory"]').forEach(radio => {
    radio.addEventListener('change', async () => {
      updateQueueCategoryUI();
      await refreshBookingInfo();
      updateReview();
    });
  });

  ['patientName','patientContact','patientEmail','patientAge','patientDob','patientSex','patientBarangay','patientAddress','patientConcern'].forEach(id => {
    const field = document.getElementById(id);
    if (!field) return;
    field.readOnly = false;
    field.disabled = false;
    field.addEventListener('input', updateReview);
    field.addEventListener('change', updateReview);
  });

  document.getElementById('patientDob')?.addEventListener('change', calculateAge);
  document.getElementById('appointmentForm')?.addEventListener('submit', e => e.preventDefault());
  document.getElementById('bookBtn')?.addEventListener('click', openConfirmationModal);
  document.getElementById('confirmBooking')?.addEventListener('click', confirmBooking);
  document.getElementById('successOkBtn')?.addEventListener('click', () => location.href = 'dashboard.html');

  updateQueueCategoryUI();
  bindSmartWaitlistHelp();
  refreshWaitlistStatus();
}

function bindTimeSlot(slot){
  slot.addEventListener('click',async()=>{
    if(slot.dataset.waitlist==='1'){
      const result=await api('join_waitlist',{center:value('healthCenter'),service:value('service'),date:value('date'),time:slot.dataset.time},'POST');
      if(result.ok){showError(`Waitlist joined. Your current position is ${result.position||1}.`);await refreshWaitlistStatus();}
      else showError(result.message||'Unable to join the waitlist.');
      return;
    }
    if(slot.classList.contains('disabled')||slot.disabled)return;
    document.querySelectorAll('.time-slot').forEach(x=>x.classList.remove('active','selected'));
    slot.classList.add('active','selected');
    booking.time=slot.dataset.time||slot.querySelector('.slot-time')?.textContent.trim()||'';
    setText('summarySlotsText',slot.dataset.remaining?`${slot.dataset.remaining} / ${slot.dataset.capacity||'--'}`:'--');
    updateReview();
  });
}

function renderTimeSlots(times){
  const grid=document.getElementById('timeGrid');
  if(!grid)return;
  if(!Array.isArray(times)||!times.length){grid.innerHTML='<div class="booking-schedule-empty"><i class="fas fa-calendar-xmark"></i><strong>No bookable time slots</strong><span>Check the closure notice or select another date.</span></div>';return;}
  grid.innerHTML=times.map(time=>`<button type="button" class="time-slot" data-time="${esc(time)}"><span class="slot-time">${esc(time)}</span><span class="slot-availability">Checking availability…</span></button>`).join('');
  grid.querySelectorAll('.time-slot').forEach(bindTimeSlot);
}

function fillPatientDetails(p) {
  const fullName = p.name || [p.firstName, p.lastName].filter(Boolean).join(' ');
  setValue('patientName', fullName);
  setValue('patientContact', p.phone || p.mobile || '');
  setValue('patientEmail', p.email || '');
  setValue('patientDob', p.dob || p.birthdate || '');
  setValue('patientSex', p.sex || p.gender || '');
  setValue('patientBarangay', p.barangay || '');
  setValue('patientAddress', p.address || '');
  calculateAge();
  updateReview();
}

function getQueueCategory() {
  return document.querySelector('input[name="queueCategory"]:checked')?.value || 'regular';
}

function priorityReason() {
  return ({ senior: 'Senior Citizen', pwd: 'PWD', pregnant: 'Pregnant' })[getQueueCategory()] || '';
}

function isPriority() {
  return getQueueCategory() !== 'regular';
}

function updateQueueCategoryUI() {
  document.querySelectorAll('.priority-choice').forEach(label => {
    label.classList.toggle('selected-priority', !!label.querySelector('input:checked'));
  });
  const notice = document.getElementById('priorityNotice');
  if (notice) notice.style.display = isPriority() ? 'flex' : 'none';
  setText('priorityNoticeText', isPriority() ? `${priorityReason()} selected. A P- priority queue number will be assigned after staff verifies the priority document during check-in.` : '');
  setText('summaryQueueTypeText', isPriority() ? `Priority Queue - ${priorityReason()}` : 'Regular Queue');
}


function bindBranchInfoPopover() {
  const button=document.getElementById('branchInfoButton');
  const popover=document.getElementById('branchInfoPopover');
  if(!button||!popover||button.dataset.bound)return;
  button.dataset.bound='1';
  const close=()=>{popover.hidden=true;button.setAttribute('aria-expanded','false');};
  button.addEventListener('click',(event)=>{
    event.stopPropagation();
    const willOpen=popover.hidden;
    popover.hidden=!willOpen;
    button.setAttribute('aria-expanded',String(willOpen));
  });
  popover.addEventListener('click',(event)=>event.stopPropagation());
  document.addEventListener('click',close);
  document.addEventListener('keydown',(event)=>{if(event.key==='Escape')close();});
}

async function refreshBranchRecommendations() {
  const service=value('service');
  const date=value('date');
  const panel=document.getElementById('branchRecommendation');
  const grid=document.getElementById('branchComparisonGrid');
  const message=document.getElementById('branchRecommendationMessage');
  const optionsToggle=document.getElementById('branchOptionsToggle');
  if(!panel||!grid)return;
  if(!service||!date){panel.hidden=true;grid.innerHTML='';return;}

  panel.hidden=false;
  bindBranchInfoPopover();
  grid.innerHTML='<div class="branch-recommendation-loading"><i class="fas fa-spinner fa-spin"></i> Comparing RHUs…</div>';
  const result=await api('patient_branch_recommendations',{service,date},'POST');
  if(!result.ok){
    grid.innerHTML=`<div class="branch-recommendation-empty"><i class="fas fa-circle-exclamation"></i>${esc(result.message||'Branch comparison is unavailable.')}</div>`;
    if(message)message.textContent='Comparison is temporarily unavailable.';
    if(optionsToggle)optionsToggle.hidden=true;
    return;
  }

  const branches=Array.isArray(result.branches)?result.branches:[];
  const selected=value('healthCenter');
  const recommended=branches.find(item=>item.recommended)||branches.find(item=>item.open)||null;
  if(message){
    message.textContent=recommended
      ? `${recommended.branch} currently has the best available capacity.`
      : 'No RHU is currently available for the selected date.';
  }

  grid.classList.add('mobile-collapsed');
  if(optionsToggle){
    optionsToggle.hidden=branches.length<=1;
    optionsToggle.setAttribute('aria-expanded','false');
    const label=optionsToggle.querySelector('span');
    if(label)label.textContent='Compare other RHUs';
  }

  const ordered=[...branches].sort((a,b)=>Number(Boolean(b.recommended))-Number(Boolean(a.recommended)));
  grid.innerHTML=ordered.map(item=>{
    const branch=esc(item.branch||'');
    const isSelected=selected===(item.branch||'');
    const statusClass=item.open?'available':'unavailable';
    const wait=item.open?(Number(item.projectedWait||0)>0?`${Number(item.projectedWait)} min wait`:'No active delay'):'Unavailable';
    const slots=item.open?`${Number(item.availableSlots||0)} appointment slots available`:(item.message||'Closed or full');
    const queue=`${Number(item.activeQueue||0)} waiting`;
    return `<button type="button" class="branch-comparison-card ${statusClass} ${item.recommended?'recommended':''} ${isSelected?'selected':''}" data-branch="${branch}" ${item.open?'':'disabled'}>
      <span class="branch-card-top">
        <span class="branch-card-name">${branch}</span>
        ${item.recommended?'<span class="recommendation-badge"><i class="fas fa-star"></i> Recommended</span>':''}
      </span>
      <span class="branch-compact-summary">
        <span class="branch-load ${statusClass}"><i class="fas ${item.open?'fa-circle-check':'fa-circle-xmark'}"></i>${esc(item.load||'')}</span>
        <span class="branch-summary-metrics">${esc(slots)} <b>•</b> ${esc(queue)} <b>•</b> ${esc(wait)}</span>
      </span>
      <span class="branch-card-action">${isSelected?'Selected':'Use this branch'} <i class="fas fa-arrow-right"></i></span>
    </button>`;
  }).join('')||'<div class="branch-recommendation-empty">No branch information is available.</div>';

  grid.querySelectorAll('.branch-comparison-card:not(:disabled)').forEach(card=>card.addEventListener('click',async()=>{
    const select=document.getElementById('healthCenter');
    if(!select)return;
    select.value=card.dataset.branch||'';
    booking.center=select.value;
    booking.time='';
    document.querySelectorAll('.time-slot').forEach(x=>x.classList.remove('active','selected'));
    await refreshBranchRecommendations();
    await refreshBookingInfo();
    updateReview();
  }));

  if(optionsToggle&&!optionsToggle.dataset.bound){
    optionsToggle.dataset.bound='1';
    optionsToggle.addEventListener('click',()=>{
      const expanded=optionsToggle.getAttribute('aria-expanded')==='true';
      optionsToggle.setAttribute('aria-expanded',String(!expanded));
      grid.classList.toggle('mobile-collapsed',expanded);
      const label=optionsToggle.querySelector('span');
      if(label)label.textContent=expanded?'Compare other RHUs':'Show recommended only';
    });
  }
}

async function refreshBookingInfo() {
  const center = value('healthCenter');
  const date = value('date');
  const service=value('service');
  if (!center || !date || !service) {
    setText('queuePreview', '--');
    setText('reviewQueue', '--');
    setText('slotLeft', '--');
    return;
  }
  const result = await api('patient_booking_info', { center, service, date, queueType: isPriority() ? 'priority' : 'regular' });
  if (!result.ok) {
    showError(result.message || 'Unable to load available slots.');
    return;
  }
  setText('queuePreview', result.queuePreview || '--');
  setText('reviewQueue', result.queuePreview || '--');
  renderTimeSlots(result.availableTimes||[]);
  const slots = result.slots || {};
  const slotStatus = result.slotStatus || {};
  const capacity=Number(result.capacity||0);
  let total = 0;
  document.querySelectorAll('.time-slot').forEach(slot => {
    const time = slot.dataset.time || slot.querySelector('.slot-time')?.textContent.trim() || '';
    const remaining = Number(slots[time] || 0);
    const status = slotStatus[time] || (remaining > 0 ? 'available' : 'full');
    const isUnavailable = status !== 'available' || remaining <= 0;
    if (!isUnavailable) total += remaining;
    slot.dataset.remaining = String(remaining);
    slot.dataset.capacity=String(capacity);
    const canWaitlist=status === 'full';
    slot.dataset.waitlist=canWaitlist?'1':'0';
    slot.disabled = isUnavailable && !canWaitlist;
    slot.classList.toggle('disabled', isUnavailable && !canWaitlist);
    slot.classList.toggle('waitlist-slot', canWaitlist);
    slot.classList.toggle('full', status === 'full');
    slot.classList.toggle('closed', status === 'closed');
    slot.classList.toggle('past', status === 'past');
    slot.classList.toggle('low-slots', status === 'available' && remaining > 0 && remaining <= 2);
    slot.setAttribute('aria-disabled', isUnavailable ? 'true' : 'false');
    const availability = slot.querySelector('.slot-availability');
    if (availability) {
      availability.textContent = status === 'past' ? 'Time passed' : status === 'closed' ? 'Closed' : status === 'full' ? 'FULL — Join waitlist' : `${remaining} of ${capacity} slots left`;
    }
  });
  const dateAvailable=Math.min(total,Number(result.dailyRemaining??total));
  setText('slotLeft', `${dateAvailable} available`);
  setText('summarySlotsText', booking.time && slots[booking.time] !== undefined ? `${slots[booking.time]} / ${capacity}` : '--');
  setText('waitBadge', result.estimatedWait ? `Est. wait: ${result.estimatedWait} min` : 'Est. wait: --');
  setText('selectedDateLabel', formatDate(date));
  const context=document.getElementById('waitBadge');
  if(context&&!result.isOpen)context.textContent=result.message||'RHU closed';
}


async function refreshWaitlistStatus(){
  const status=document.getElementById('smartWaitlistStatus');
  if(!status)return;
  const result=await api('patient_waitlist_status',{},'GET');
  if(!result.ok){status.textContent='Waitlist status is temporarily unavailable';return;}
  const offered=(result.items||[]).find(x=>x.status==='offered');
  const waiting=(result.items||[]).find(x=>x.status==='waiting');
  if(offered){
    status.innerHTML=`<strong>Slot offer available:</strong> ${esc(offered.center)} • ${esc(offered.appointment_date)} • ${esc(offered.appointment_time)} <button type="button" class="accept-waitlist-offer" data-id="${Number(offered.id)}">Accept slot</button>`;
    status.querySelector('.accept-waitlist-offer')?.addEventListener('click',async e=>{const r=await api('accept_waitlist_offer',{id:Number(e.currentTarget.dataset.id)},'POST');if(r.ok)location.href='appointments.html';else showError(r.message||'Unable to accept the slot.');});
  }else if(waiting){status.textContent=`Waiting for ${waiting.center} • ${waiting.appointment_date} • ${waiting.appointment_time}`;}
  else status.textContent=`No active waitlist request • ${Number(result.recoveredToday||0)} slot${Number(result.recoveredToday||0)===1?'':'s'} recovered today`;
}

function bindSmartWaitlistHelp(){
  const helpButton=document.getElementById('smartWaitlistHelp');
  const modalElement=document.getElementById('waitlistInfoModal');
  if(!helpButton||!modalElement)return;
  helpButton.addEventListener('click',()=>{
    bootstrap.Modal.getOrCreateInstance(modalElement).show();
  });
}

function validatePatientDetails() {
  const required = [
    ['patientName','Full Name'],['patientContact','Contact Number'],['patientEmail','Email Address'],
    ['patientAge','Age'],['patientDob','Date of Birth'],['patientSex','Sex'],
    ['patientBarangay','Barangay'],['patientAddress','Complete Address']
  ];
  const missing = required.filter(([id]) => !value(id)).map(([,label]) => label);
  if (missing.length) {
    showError('Please complete: ' + missing.join(', ') + '.');
    return false;
  }
  return true;
}

function validateStep(step) {
  if (step === 1 && !value('service')) { showError('Please select a health service.'); return false; }
  if (step === 2) {
    if (!value('healthCenter')) { showError('Please select a health center.'); return false; }
    if (!value('date')) { showError('Please select an appointment date.'); return false; }
    if (!booking.time) { showError('Please select an available time slot.'); return false; }
  }
  if (step === 3 && !validatePatientDetails()) return false;
  return true;
}

function nextStep() { if (validateStep(currentStep)) showStep(currentStep + 1); }
function prevStep() { showStep(currentStep - 1); }

function showStep(step) {
  currentStep = Math.max(1, Math.min(4, step));
  document.querySelectorAll('.step-panel').forEach(panel => panel.classList.toggle('active', Number(panel.dataset.step) === currentStep));
  document.querySelectorAll('.step-item').forEach((item, index) => {
    item.classList.toggle('active', index + 1 === currentStep);
    item.classList.toggle('done', index + 1 < currentStep);
  });
  document.getElementById('prevBtn').style.visibility = currentStep === 1 ? 'hidden' : 'visible';
  document.getElementById('nextBtn').style.display = currentStep === 4 ? 'none' : 'inline-flex';
  document.getElementById('bookBtn').style.display = currentStep === 4 ? 'inline-flex' : 'none';
  updateReview();
}

function openConfirmationModal(event) {
  event?.preventDefault();
  if (!validatePatientDetails()) return;
  if (!value('service') || !value('healthCenter') || !value('date') || !booking.time) {
    showError('Please complete the service, health center, date, and time.');
    return;
  }
  updateReview();
  setText('sumCenter', value('healthCenter'));
  setText('sumService', value('service'));
  setText('sumDate', formatDate(value('date')));
  setText('sumTime', booking.time);
  setText('sumQueueType', isPriority() ? `Priority Queue - ${priorityReason()}` : 'Regular Queue');
  const row = document.getElementById('priorityRowModal');
  if (row) row.style.display = isPriority() ? 'flex' : 'none';
  bootstrap.Modal.getOrCreateInstance(document.getElementById('summaryModal')).show();
}

async function confirmBooking(event) {
  event?.preventDefault();
  const button = document.getElementById('confirmBooking');
  if (button) button.disabled = true;
  try {
    const names = splitName(value('patientName'));
    if(!selectedBookingPatientId){
      const profileResult = await api('profile_save', {
        firstName: names.firstName,lastName: names.lastName,phone: value('patientContact'),dob: value('patientDob'),sex: value('patientSex'),barangay: value('patientBarangay'),address: value('patientAddress'),isSenior: getQueueCategory() === 'senior',isPwd: getQueueCategory() === 'pwd',is4ps: false
      });
      if (!profileResult.ok) throw new Error(profileResult.message || 'Unable to save patient details.');
    }

    const bookingPayload={
      service: value('service'), center: value('healthCenter'), date: value('date'), time: booking.time,
      queueType: isPriority() ? 'priority' : 'regular',
      isPriority: isPriority(), priorityReason: priorityReason(),
      concern: value('patientConcern'),
      birthdate: value('patientDob'), gender: value('patientSex'), barangay: value('patientBarangay')
    };
    if(selectedBookingPatientId>0)bookingPayload.for_patient_id=selectedBookingPatientId;
    const result = await api('book_appointment',bookingPayload);
    if (!result.ok) throw new Error(result.message || 'Booking failed.');

    bootstrap.Modal.getOrCreateInstance(document.getElementById('summaryModal')).hide();
    setText('successMessage', `${selectedBookingPatientId?'The dependent appointment':'Your appointment'} is confirmed at ${result.appointment?.center||'the selected RHU'}. Present the check-in QR on the scheduled date; the live queue number will be assigned upon arrival.`);
    bootstrap.Modal.getOrCreateInstance(document.getElementById('successModal')).show();
  } catch (error) {
    showError(error.message);
  } finally {
    if (button) button.disabled = false;
  }
}

function updateReview() {
  const center = value('healthCenter') || '--';
  const date = value('date');
  const time = booking.time || '--';
  setText('reviewService', value('service') || '--');
  setText('reviewCenter', center);
  setText('reviewDate', date ? formatDate(date) : '--');
  setText('reviewTime', time);
  setText('reviewPatient', value('patientName') || '--');
  setText('reviewConcern', value('patientConcern') || 'No note provided');
  setText('summaryDateText', date ? formatDate(date) : '--');
  setText('summaryTimeText', time);
  setText('summaryCenterText', center === '--' ? 'No health center selected' : center);
  updateQueueCategoryUI();
}

function calculateAge() {
  const dob = value('patientDob');
  if (!dob) return;
  const birth = new Date(dob + 'T00:00:00');
  const today = new Date();
  let age = today.getFullYear() - birth.getFullYear();
  const m = today.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) age--;
  setValue('patientAge', age >= 0 ? age : '');
}

function splitName(fullName) {
  const parts = fullName.trim().split(/\s+/);
  if (parts.length === 1) return { firstName: parts[0], lastName: '.' };
  return { firstName: parts.slice(0, -1).join(' '), lastName: parts.at(-1) };
}

function showError(message) {
  setText('errorMessage', message);
  bootstrap.Modal.getOrCreateInstance(document.getElementById('errorModal')).show();
}
function setText(id, valueToSet) { const el = document.getElementById(id); if (el) el.textContent = valueToSet; }
function setValue(id, valueToSet) { const el = document.getElementById(id); if (el) { el.value = valueToSet ?? ''; el.readOnly = false; el.disabled = false; } }
function value(id) { return document.getElementById(id)?.value?.trim() || ''; }
function formatDate(date) { const d = new Date(date + 'T00:00:00'); return Number.isNaN(d.getTime()) ? date : d.toLocaleDateString('en-US', { month:'short', day:'numeric', year:'numeric' }); }
