const profileSectionSnapshots = new Map();

 document.addEventListener('DOMContentLoaded', async () => {
  bindProfileTabs();
  bindRhuCards();
  bindProfileDirtyTracking();
  const patient = await loadPatientNav();
  if (!patient) return;
  fillProfile(patient);
  captureAllSectionSnapshots();
});

function bindProfileTabs() {
  document.querySelectorAll('.tab-btn').forEach((button) => {
    button.addEventListener('click', () => {
      const match = button.getAttribute('onclick')?.match(/show\(['\"]([^'\"]+)/);
      if (match) show(match[1], button);
    });
  });
}

function show(section, button) {
  document.querySelectorAll('.section-card[id^="sec-"]').forEach((card) => {
    card.style.display = 'none';
  });
  document.querySelectorAll('.tab-btn').forEach((tab) => tab.classList.remove('active'));

  const target = document.getElementById('sec-' + section);
  if (target) target.style.display = 'block';
  if (button) button.classList.add('active');
}

function fillProfile(patient) {
  const data = patient.profile || patient.profileData || patient;
  const mapping = {
    firstName: data.firstName || data.first_name,
    lastName: data.lastName || data.last_name,
    middleName: data.middleName,
    suffix: data.suffix,
    dob: data.dob || data.birthdate,
    sex: data.sex || data.gender,
    civilStatus: data.civilStatus,
    nationality: data.nationality,
    religion: data.religion,
    occupation: data.occupation,
    mobile: data.mobile || data.phone,
    email: data.email,
    barangay: data.barangay,
    street: data.street || data.address,
    zip: data.zip,
    bloodType: data.bloodType,
    height: data.height,
    weight: data.weight,
    allergies: data.allergies,
    conditions: data.conditions,
    medications: data.medications,
    smoking: data.smoking,
    alcohol: data.alcohol,
    vaccination: data.vaccination,
    obgyn: data.obgyn,
    preferredRhu: data.preferredRhu || data.preferred_rhu || data.rhuPreference || '',
    preferredTime: data.preferredTime,
    philhealthNum: data.philhealthNum || data.philhealthNo,
    philhealthType: data.philhealthType,
    philhealthStatus: data.philhealthStatus,
    philhealthEmployer: data.philhealthEmployer,
    philhealthDependents: data.philhealthDependents,
    scId: data.scId,
    pwdType: data.pwdType,
    pwdId: data.pwdId,
    fourPsNum: data.fourPsNum,
    soloParentId: data.soloParentId,
    ecName: data.ecName,
    ecRelationship: data.ecRelationship,
    ecMobile: data.ecMobile,
    ecAlt: data.ecAlt,
    ecAddress: data.ecAddress,
    accountEmail: data.email
  };

  Object.entries(mapping).forEach(([id, value]) => {
    const element = document.getElementById(id);
    if (element && value !== undefined && value !== null) element.value = value;
  });

  const checks = {
    isSenior: data.isSenior || data.seniorCitizen,
    isPwd: data.isPwd,
    toggle4ps: data.toggle4ps || data.is4ps,
    toggleNhts: data.toggleNhts,
    toggleMalasakit: data.toggleMalasakit,
    toggleSoloParent: data.toggleSoloParent
  };
  Object.entries(checks).forEach(([id, value]) => {
    const element = document.getElementById(id);
    if (element) element.checked = Boolean(Number(value) || value === true);
  });

  const fullName = patient.name || [mapping.firstName, mapping.lastName].filter(Boolean).join(' ');
  ['profileName', 'displayName', 'headerName'].forEach((id) => {
    const element = document.getElementById(id);
    if (element && fullName) element.textContent = fullName;
  });

  syncSelectedRhu(mapping.preferredRhu || '');
  restoreCardPreviews(data);
  if(window.hcApplyPatientPhoto) window.hcApplyPatientPhoto(data.profilePhoto || data.profile_picture || '', fullName);
  updateHeader();
}

function collectProfileData() {
  const data = {};
  document.querySelectorAll('.section-card input, .section-card select, .section-card textarea').forEach((element) => {
    if (!element.id || ['currentPass', 'newPass', 'confirmPass'].includes(element.id)) return;
    data[element.id] = element.type === 'checkbox' ? element.checked : element.value.trim();
  });
  data.phone = data.mobile || '';
  data.birthdate = data.dob || '';
  data.gender = data.sex || '';
  data.address = data.street || '';
  data.philhealthNo = data.philhealthNum || '';
  return data;
}

function sectionState(section) {
  const card = document.getElementById('sec-' + section);
  if (!card) return '';
  const state = {};
  card.querySelectorAll('input, select, textarea').forEach((element) => {
    if (!element.id) return;
    if (section === 'account' && element.id === 'accountEmail') return;
    state[element.id] = element.type === 'checkbox' ? Boolean(element.checked) : String(element.value || '').trim();
  });
  return JSON.stringify(state);
}

function captureSectionSnapshot(section) {
  profileSectionSnapshots.set(section, sectionState(section));
  updateSectionSaveButton(section);
}

function captureAllSectionSnapshots() {
  document.querySelectorAll('.section-card[id^="sec-"]').forEach((card) => {
    captureSectionSnapshot(card.id.replace('sec-', ''));
  });
}

function sectionHasChanges(section) {
  return profileSectionSnapshots.has(section) && profileSectionSnapshots.get(section) !== sectionState(section);
}

function updateSectionSaveButton(section) {
  const button = document.querySelector(`#sec-${section} .btn-save`);
  if (!button) return;
  const dirty = sectionHasChanges(section);
  button.classList.toggle('has-changes', dirty);
  button.setAttribute('aria-disabled', dirty ? 'false' : 'true');
  button.title = dirty ? 'Save your changes' : 'No changes to save';
}

function bindProfileDirtyTracking() {
  document.addEventListener('input', (event) => {
    const card = event.target.closest('.section-card[id^="sec-"]');
    if (card) updateSectionSaveButton(card.id.replace('sec-', ''));
  });
  document.addEventListener('change', (event) => {
    const card = event.target.closest('.section-card[id^="sec-"]');
    if (card) updateSectionSaveButton(card.id.replace('sec-', ''));
  });
}

async function save(section) {
  if (!sectionHasChanges(section)) {
    showProfileNotice('No changes to save', 'You have not changed any information in this section.', 'info');
    return;
  }

  if (section === 'rhu') {
    const selectedRhu = document.getElementById('preferredRhu')?.value?.trim() || '';
    if (!selectedRhu) {
      showProfileNotice('Select an RHU', 'Please select one RHU branch before saving.', 'warning');
      return;
    }
  }

  if (section === 'account') {
    const currentPass = document.getElementById('currentPass')?.value || '';
    const newPass = document.getElementById('newPass')?.value || '';
    const confirmPass = document.getElementById('confirmPass')?.value || '';
    if (!currentPass || !newPass || !confirmPass) {
      showProfileNotice('Complete password fields', 'Enter your current password, new password, and password confirmation.', 'warning');
      return;
    }
    if (newPass.length < 8) {
      showProfileNotice('Password is too short', 'Your new password must be at least 8 characters.', 'warning');
      return;
    }
    if (newPass !== confirmPass) {
      showProfileNotice('Passwords do not match', 'The new password and confirmation must be the same.', 'warning');
      return;
    }
  }

  const button = document.querySelector(`#sec-${section} .btn-save`);
  const original = button ? button.innerHTML : '';
  if (button) {
    button.disabled = true;
    button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
  }
  try {
    const response = section === 'account'
      ? await api('patient_change_password', {
          currentPassword: document.getElementById('currentPass')?.value || '',
          newPassword: document.getElementById('newPass')?.value || ''
        })
      : await api('profile_save', collectProfileData());
    if (!response.ok) {
      showProfileNotice('Unable to save', response.message || 'Please review your information and try again.', 'error');
      return;
    }
    if (response.patient) fillProfile(response.patient);
    if (section === 'account') {
      ['currentPass', 'newPass', 'confirmPass'].forEach((id) => {
        const field = document.getElementById(id);
        if (field) field.value = '';
      });
    }
    captureAllSectionSnapshots();
    const message = section === 'rhu'
      ? 'Your preferred RHU has been updated.'
      : section === 'account'
        ? 'Your password has been updated securely.'
        : 'Your changes have been saved successfully.';
    showProfileNotice('Changes saved', message, 'success');
  } catch (error) {
    showProfileNotice('Unable to save', 'Please check your connection and try again.', 'error');
  } finally {
    if (button) {
      button.disabled = false;
      button.innerHTML = original;
      updateSectionSaveButton(section);
    }
  }
}
function showSuccess(message, title = 'Saved') {
  showProfileNotice(title, message, 'success');
}

function showProfileNotice(title, message, type = 'success') {
  const modalElement = document.getElementById('successModal');
  if (!modalElement) return;
  const titleElement = modalElement.querySelector('[data-profile-modal-title]');
  const messageElement = modalElement.querySelector('[data-profile-modal-message]');
  const icon = modalElement.querySelector('[data-profile-modal-icon]');
  const dialog = modalElement.querySelector('.profile-feedback-card');
  if (titleElement) titleElement.textContent = title;
  if (messageElement) messageElement.textContent = message;
  if (dialog) dialog.dataset.type = type;
  if (icon) {
    const classes = {
      success: 'fa-check',
      info: 'fa-circle-info',
      warning: 'fa-triangle-exclamation',
      error: 'fa-xmark'
    };
    icon.className = `fas ${classes[type] || classes.info}`;
  }
  if (window.bootstrap) bootstrap.Modal.getOrCreateInstance(modalElement).show();
}
const profileCameraStreams = {};

function profileCardElements(type) {
  return {
    video: document.getElementById(type + 'Video'),
    canvas: document.getElementById(type + 'Canvas'),
    preview: document.getElementById(type + 'Preview'),
    empty: document.getElementById(type + 'Empty'),
    hidden: document.getElementById(type + 'CardImage'),
    capture: document.getElementById(type + 'CaptureBtn'),
    clear: document.getElementById(type + 'ClearBtn'),
    status: document.getElementById(type + 'OcrStatus')
  };
}

async function openCardCamera(type) {
  const elements = profileCardElements(type);
  const fileInput = document.getElementById(type + 'File');

  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    if (elements.status) {
      elements.status.innerHTML = '<i class="fas fa-image"></i> Camera is unavailable. Select a card image from your device.';
    }
    return;
  }

  try {
    stopCardCamera(type);

    const stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: { ideal: 'environment' } },
      audio: false
    });

    profileCameraStreams[type] = stream;

    if (elements.video) {
      elements.video.srcObject = stream;
      elements.video.style.display = 'block';
      await elements.video.play().catch(() => {});
    }

    if (elements.preview) elements.preview.style.display = 'none';
    if (elements.empty) elements.empty.style.display = 'none';
    if (elements.capture) elements.capture.style.display = 'inline-flex';
    if (elements.clear) elements.clear.style.display = 'inline-flex';
    if (elements.status) {
      elements.status.innerHTML = '<i class="fas fa-camera"></i> Camera is ready. Position the card clearly, then press Capture.';
    }
  } catch (error) {
    if (elements.status) {
      elements.status.innerHTML = '<i class="fas fa-triangle-exclamation"></i> Camera permission was blocked. Select an image from your device instead.';
    }

  }
}

function stopCardCamera(type) {
  const stream = profileCameraStreams[type];
  if (stream) {
    stream.getTracks().forEach(track => track.stop());
    delete profileCameraStreams[type];
  }

  const video = document.getElementById(type + 'Video');
  if (video) {
    video.pause();
    video.srcObject = null;
    video.style.display = 'none';
  }
}

function captureCardPhoto(type) {
  const elements = profileCardElements(type);
  if (!elements.video || !elements.canvas || !elements.preview) return;

  const width = elements.video.videoWidth || 1280;
  const height = elements.video.videoHeight || 720;
  elements.canvas.width = width;
  elements.canvas.height = height;

  const context = elements.canvas.getContext('2d');
  context.drawImage(elements.video, 0, 0, width, height);

  const dataUrl = elements.canvas.toDataURL('image/jpeg', 0.82);
  applyCardImage(type, dataUrl);
  stopCardCamera(type);
}

function loadCardImage(event, type) {
  const file = event?.target?.files?.[0];
  if (!file) return;

  if (!file.type.startsWith('image/')) {
    showSuccess('Please choose a valid image file.', 'Invalid Image');
    event.target.value = '';
    return;
  }

  if (file.size > 5 * 1024 * 1024) {
    showSuccess('The image must be 5 MB or smaller.', 'Image Too Large');
    event.target.value = '';
    return;
  }

  const reader = new FileReader();
  reader.onload = () => applyCardImage(type, reader.result);
  reader.onerror = () => showSuccess('Unable to read the selected image.', 'Upload Error');
  reader.readAsDataURL(file);
}

function applyCardImage(type, dataUrl) {
  const elements = profileCardElements(type);

  if (elements.hidden) elements.hidden.value = dataUrl || '';
  if (elements.preview) {
    elements.preview.src = dataUrl || '';
    elements.preview.style.display = dataUrl ? 'block' : 'none';
  }
  if (elements.empty) elements.empty.style.display = dataUrl ? 'none' : '';
  if (elements.video) elements.video.style.display = 'none';
  if (elements.capture) elements.capture.style.display = 'none';
  if (elements.clear) elements.clear.style.display = dataUrl ? 'inline-flex' : 'none';
  if (elements.status) {
    elements.status.innerHTML = dataUrl
      ? '<i class="fas fa-circle-check"></i> Card image is ready and will be saved with your profile.'
      : '<i class="fas fa-wand-magic-sparkles"></i> Upload or capture a clear card photo for verification. Enter the card details manually below.';
  }

  updateHeader();
  const section = elements.hidden?.closest('.section-card[id^="sec-"]')?.id?.replace('sec-', '');
  if (section) updateSectionSaveButton(section);
}

function clearCardPhoto(type) {
  stopCardCamera(type);

  const elements = profileCardElements(type);
  if (elements.hidden) elements.hidden.value = '';
  if (elements.preview) {
    elements.preview.removeAttribute('src');
    elements.preview.style.display = 'none';
  }
  if (elements.empty) elements.empty.style.display = '';
  if (elements.capture) elements.capture.style.display = 'none';
  if (elements.clear) elements.clear.style.display = 'none';

  const file = document.getElementById(type + 'File');
  if (file) file.value = '';

  if (elements.status) {
    elements.status.innerHTML = '<i class="fas fa-wand-magic-sparkles"></i> Upload or capture a clear card photo for verification. Enter the card details manually below.';
  }
  const section = elements.hidden?.closest('.section-card[id^="sec-"]')?.id?.replace('sec-', '');
  if (section) updateSectionSaveButton(section);
}

function normalizeRhuValue(value) {
  return String(value || '').replace(/\s+/g, ' ').trim();
}

function syncSelectedRhu(value) {
  const normalized = normalizeRhuValue(value);
  document.querySelectorAll('.rhu-card[data-rhu]').forEach((card) => {
    const selected = normalizeRhuValue(card.dataset.rhu) === normalized;
    card.classList.toggle('selected', selected);
    card.classList.toggle('active', selected);
    card.setAttribute('aria-checked', selected ? 'true' : 'false');
  });
}

function selectRhu(elementOrValue, valueOrElement) {
  const element = elementOrValue instanceof HTMLElement
    ? elementOrValue
    : (valueOrElement instanceof HTMLElement ? valueOrElement : null);
  const value = normalizeRhuValue(
    typeof elementOrValue === 'string'
      ? elementOrValue
      : (typeof valueOrElement === 'string' ? valueOrElement : element?.dataset?.rhu)
  );

  if (!value) {
    showSuccess('Unable to read the selected RHU. Please select the branch again.', 'Selection issue');
    return;
  }

  const field = document.getElementById('preferredRhu');
  if (field) field.value = value;
  syncSelectedRhu(value);

  const selectedLabel = document.getElementById('selectedRhuLabel');
  if (selectedLabel) selectedLabel.textContent = value;

  updateHeader();
  updateSectionSaveButton('rhu');
}

function bindRhuCards() {
  document.querySelectorAll('.rhu-card[data-rhu]').forEach((card) => {
    card.addEventListener('click', () => selectRhu(card, card.dataset.rhu));
    card.addEventListener('keydown', (event) => {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        selectRhu(card, card.dataset.rhu);
      }
    });
  });
}

function updatePh() {
  const number = document.getElementById('philhealthNum')?.value?.trim() || '';
  const status = document.getElementById('philhealthStatus')?.value?.trim() || '';
  const header = document.getElementById('hPhilhealth');

  if (header) {
    header.textContent = number ? (status || 'Registered') : '-';
  }

  updateHeader();
}

function updateHeader() {
  const value = id => document.getElementById(id)?.value?.trim() || '';
  const checked = id => Boolean(document.getElementById(id)?.checked);

  const firstName = value('firstName');
  const lastName = value('lastName');
  const fullName = [firstName, lastName].filter(Boolean).join(' ') || 'Patient';

  ['profileName', 'displayName', 'headerName'].forEach(id => {
    const element = document.getElementById(id);
    if (element) element.textContent = fullName;
  });

  const headerValues = {
    hBlood: value('bloodType') || '-',
    hRhu: value('preferredRhu') || '-',
    h4ps: checked('toggle4ps') ? 'Yes' : 'No',
    hSenior: checked('isSenior') ? 'Yes' : 'No'
  };

  Object.entries(headerValues).forEach(([id, text]) => {
    const element = document.getElementById(id);
    if (element) element.textContent = text;
  });

  const fields = Array.from(document.querySelectorAll(
    '.section-card input:not([type="hidden"]):not([type="file"]), .section-card select, .section-card textarea'
  )).filter(element => !['currentPass', 'newPass', 'confirmPass'].includes(element.id));

  const completed = fields.filter(element => {
    if (element.type === 'checkbox') return element.checked;
    return String(element.value || '').trim() !== '';
  }).length;

  const percentage = fields.length ? Math.round((completed / fields.length) * 100) : 0;
  const fill = document.getElementById('pctFill');
  const label = document.getElementById('pctLabel');

  if (fill) fill.style.width = percentage + '%';
  if (label) label.textContent = percentage + '%';
}

function restoreCardPreviews(data) {
  ['philhealth', 'pwd', 'fourPs', 'senior', 'soloParent'].forEach(type => {
    const key = type + 'CardImage';
    if (data && data[key]) applyCardImage(type, data[key]);
  });
}

document.addEventListener('input', event => {
  if (event.target.closest('.section-card')) updateHeader();
});

document.addEventListener('change', event => {
  if (event.target.closest('.section-card')) updateHeader();
});

window.addEventListener('beforeunload', () => {
  Object.keys(profileCameraStreams).forEach(stopCardCamera);
});

