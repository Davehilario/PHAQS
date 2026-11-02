(function () {
  'use strict';

  const STORAGE_KEY = 'pulilanPatientTextSize';
  const LARGE_CLASS = 'patient-text-large';

  function getPreference() {
    try {
      return localStorage.getItem(STORAGE_KEY) === 'large' ? 'large' : 'normal';
    } catch (_) {
      return 'normal';
    }
  }

  function applyPreference(value) {
    const size = value === 'large' ? 'large' : 'normal';
    document.documentElement.classList.toggle(LARGE_CLASS, size === 'large');

    try {
      localStorage.setItem(STORAGE_KEY, size);
    } catch (_) {}

    document.querySelectorAll('[data-patient-text-size]').forEach(function (button) {
      const active = button.dataset.patientTextSize === size;
      button.classList.toggle('is-active', active);
      button.setAttribute('aria-pressed', active ? 'true' : 'false');
    });

    document.querySelectorAll('[data-text-size-current]').forEach(function (label) {
      label.textContent = size === 'large' ? 'Large' : 'Normal';
    });
  }

  function createFloatingControl() {
    document.querySelectorAll('.patient-text-size-control, .patient-text-size-mobile-row').forEach(function (item) {
      item.remove();
    });

    const control = document.createElement('div');
    control.className = 'patient-text-size-control patient-text-size-floating';
    control.innerHTML = [
      '<div class="patient-text-size-popover" hidden>',
      '  <div class="patient-text-size-popover-head">',
      '    <strong>Text size</strong>',
      '    <span>Current: <b data-text-size-current>Normal</b></span>',
      '  </div>',
      '  <div class="patient-text-size-options" role="group" aria-label="Choose text size">',
      '    <button class="patient-text-size-option" type="button" data-patient-text-size="normal" aria-pressed="false">Normal</button>',
      '    <button class="patient-text-size-option" type="button" data-patient-text-size="large" aria-pressed="false">Large</button>',
      '  </div>',
      '</div>',
      '<button class="patient-text-size-trigger" type="button" aria-label="Change text size" aria-haspopup="true" aria-expanded="false">',
      '  <span class="patient-text-size-aa" aria-hidden="true">AA</span>',
      '  <span class="patient-text-size-trigger-label">Text size</span>',
      '</button>'
    ].join('');

    document.body.appendChild(control);
    return control;
  }

  function closePopover() {
    const popover = document.querySelector('.patient-text-size-floating .patient-text-size-popover');
    const trigger = document.querySelector('.patient-text-size-floating .patient-text-size-trigger');
    if (popover) popover.hidden = true;
    if (trigger) trigger.setAttribute('aria-expanded', 'false');
  }

  function bind() {
    const control = createFloatingControl();
    const trigger = control.querySelector('.patient-text-size-trigger');
    const popover = control.querySelector('.patient-text-size-popover');

    trigger.addEventListener('click', function (event) {
      event.preventDefault();
      event.stopPropagation();
      const willOpen = popover.hidden;
      popover.hidden = !willOpen;
      trigger.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
    });

    control.querySelectorAll('[data-patient-text-size]').forEach(function (button) {
      button.addEventListener('click', function (event) {
        event.preventDefault();
        event.stopPropagation();
        applyPreference(button.dataset.patientTextSize);
        closePopover();
      });
    });

    applyPreference(getPreference());
  }

  applyPreference(getPreference());

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bind);
  } else {
    bind();
  }

  document.addEventListener('click', function (event) {
    if (!event.target.closest('.patient-text-size-floating')) closePopover();
  });

  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') closePopover();
  });
})();
