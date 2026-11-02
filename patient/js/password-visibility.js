(function () {
  'use strict';

  function togglePasswordVisibility(targetId, control) {
    var input = document.getElementById(targetId);
    if (!input) return;

    var showing = input.type === 'text';
    input.type = showing ? 'password' : 'text';

    if (control) {
      control.classList.toggle('fa-eye', !showing);
      control.classList.toggle('fa-eye-slash', showing);
      control.setAttribute('aria-label', showing ? 'Show password' : 'Hide password');
      control.setAttribute('aria-pressed', showing ? 'false' : 'true');
    }

    input.focus({ preventScroll: true });
    try {
      input.setSelectionRange(input.value.length, input.value.length);
    } catch (_) {}
  }

  window.togglePasswordVisibility = togglePasswordVisibility;

  document.addEventListener('click', function (event) {
    var control = event.target.closest('[data-password-toggle]');
    if (!control) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    togglePasswordVisibility(control.getAttribute('data-password-toggle'), control);
  }, true);

  document.addEventListener('keydown', function (event) {
    var control = event.target.closest('[data-password-toggle]');
    if (!control || (event.key !== 'Enter' && event.key !== ' ')) return;
    event.preventDefault();
    togglePasswordVisibility(control.getAttribute('data-password-toggle'), control);
  }, true);
})();
