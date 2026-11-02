(function () {
  'use strict';

  // Shared by many pages: do not initialize twice when a cached page or a
  // duplicate script tag is restored by the browser.
  if (window.__phaqsFeedbackLoaded) return;
  window.__phaqsFeedbackLoaded = true;
  var activeDialogResolve = null;

  function ensureStyles() {
    if (document.getElementById('phaqs-feedback-style')) return;
    var style = document.createElement('style');
    style.id = 'phaqs-feedback-style';
    style.textContent = `
      #phaqs-toast-region{position:fixed;top:18px;right:18px;z-index:2147483647;display:flex;flex-direction:column;gap:10px;width:min(390px,calc(100vw - 28px));pointer-events:none}
      .phaqs-toast{pointer-events:auto;display:grid;grid-template-columns:42px 1fr auto;align-items:start;gap:12px;background:#fff;border:1px solid #d9e2ec;border-left:5px solid #0b3d91;border-radius:10px;box-shadow:0 14px 38px rgba(15,35,60,.18);padding:14px 14px 14px 12px;color:#172b4d;font-family:Inter,Arial,sans-serif;animation:phaqsToastIn .18s ease-out}
      .phaqs-toast.is-error{border-left-color:#b42318}.phaqs-toast.is-warning{border-left-color:#b54708}.phaqs-toast.is-success{border-left-color:#067647}
      .phaqs-toast-icon{width:38px;height:38px;border-radius:50%;display:grid;place-items:center;background:#eaf1fb;color:#0b3d91;font-weight:800;font-size:18px}
      .phaqs-toast.is-error .phaqs-toast-icon{background:#feeceb;color:#b42318}.phaqs-toast.is-warning .phaqs-toast-icon{background:#fff3e8;color:#b54708}.phaqs-toast.is-success .phaqs-toast-icon{background:#e8f7ef;color:#067647}
      .phaqs-toast-title{font-size:14px;font-weight:800;line-height:1.3;margin:1px 0 3px}.phaqs-toast-message{font-size:13px;line-height:1.5;color:#425466;overflow-wrap:anywhere}
      .phaqs-toast-close{border:0;background:transparent;color:#667085;font-size:20px;line-height:1;cursor:pointer;padding:1px 2px;border-radius:5px}.phaqs-toast-close:hover{background:#f2f4f7;color:#101828}
      .phaqs-toast.is-leaving{animation:phaqsToastOut .16s ease-in forwards}
      @keyframes phaqsToastIn{from{opacity:0;transform:translateY(-8px) scale(.98)}to{opacity:1;transform:none}}
      @keyframes phaqsToastOut{to{opacity:0;transform:translateY(-6px) scale(.98)}}
      @media(max-width:600px){#phaqs-toast-region{top:10px;right:10px;width:calc(100vw - 20px)}.phaqs-toast{grid-template-columns:36px 1fr auto;padding:12px 11px}.phaqs-toast-icon{width:34px;height:34px}}
      @media print{#phaqs-toast-region{display:none!important}}
      .phaqs-dialog-backdrop{position:fixed;inset:0;z-index:2147483646;display:grid;place-items:center;padding:20px;background:rgba(2,18,46,.58);backdrop-filter:blur(3px);animation:phaqsFadeIn .16s ease-out}
      .phaqs-dialog{display:block!important;width:min(430px,100%)!important;height:auto!important;min-height:0!important;max-height:calc(100vh - 40px)!important;margin:0!important;padding:0!important;overflow:auto;border:1px solid #d6e0ed;border-radius:16px;background:#fff;box-shadow:0 28px 80px rgba(2,18,46,.3);color:#0b1f3a;font-family:Inter,Arial,sans-serif}
      html.phaqs-dialog-open{overflow:hidden}.phaqs-dialog-copy{min-height:0!important;margin:0!important;padding:24px 24px 20px!important}.phaqs-dialog-symbol{width:48px;height:48px;margin:0 0 16px;border-radius:12px;display:grid;place-items:center;background:#fff1f2;color:#c62828;font-size:20px;font-weight:900}.phaqs-dialog-kicker{margin:0 0 8px;color:#1d4ed8;font-size:11px;font-weight:800;letter-spacing:.08em;text-transform:uppercase}.phaqs-dialog-title{margin:0 0 8px;font-size:20px;font-weight:800;line-height:1.25}.phaqs-dialog-message{margin:0;color:#52647b;font-size:14px;line-height:1.6;white-space:pre-line}
      .phaqs-dialog-actions{display:flex;justify-content:flex-end;gap:10px;padding:15px 24px;border-top:1px solid #e6edf5;background:#f7f9fc}.phaqs-dialog-actions button{min-width:102px;min-height:42px;padding:9px 16px;border-radius:9px;font:750 13px Inter,Arial,sans-serif;cursor:pointer}.phaqs-dialog-cancel{border:1px solid #cbd7e6;background:#fff;color:#31445d}.phaqs-dialog-confirm{border:1px solid #123b78;background:#123b78;color:#fff}.phaqs-dialog-confirm.is-danger{border-color:#c92a2a;background:#c92a2a}
      @keyframes phaqsFadeIn{from{opacity:0}to{opacity:1}}
      @media(max-width:600px){.phaqs-dialog-backdrop{align-items:end;padding:12px}.phaqs-dialog{border-radius:16px}.phaqs-dialog-copy{padding:21px 19px 17px}.phaqs-dialog-actions{padding:13px 19px}.phaqs-dialog-actions button{flex:1}}
      @media print{.phaqs-dialog-backdrop{display:none!important}}
    `;
    (document.head || document.documentElement).appendChild(style);
  }

  function region() {
    ensureStyles();
    var el = document.getElementById('phaqs-toast-region');
    if (!el) {
      el = document.createElement('div');
      el.id = 'phaqs-toast-region';
      el.setAttribute('aria-live', 'polite');
      el.setAttribute('aria-atomic', 'false');
      (document.body || document.documentElement).appendChild(el);
    }
    return el;
  }

  function classify(message, requestedType) {
    if (requestedType) return requestedType;
    var text = String(message || '').toLowerCase();
    if (/success|saved|created|updated|sent|completed|checked in|restored|published|booked/.test(text)) return 'success';
    if (/fail|error|unable|invalid|cannot|can't|not sent|denied/.test(text)) return 'error';
    if (/required|please|before|only|no .* to|choose|complete all/.test(text)) return 'warning';
    return 'info';
  }

  function titleFor(type) {
    return type === 'success' ? 'Successful' : type === 'error' ? 'Action unsuccessful' : type === 'warning' ? 'Please check' : 'PHAQS Notice';
  }

  function iconFor(type) {
    return type === 'success' ? '✓' : type === 'error' ? '!' : type === 'warning' ? '!' : 'i';
  }

  function closeToast(toast) {
    if (!toast || toast.classList.contains('is-leaving')) return;
    toast.classList.add('is-leaving');
    window.setTimeout(function () { toast.remove(); }, 180);
  }

  window.phaqsNotify = function (message, options) {
    options = options || {};
    var text = message == null ? '' : String(message);
    var type = classify(text, options.type);
    var toast = document.createElement('div');
    toast.className = 'phaqs-toast is-' + type;
    toast.setAttribute('role', type === 'error' ? 'alert' : 'status');

    var icon = document.createElement('div');
    icon.className = 'phaqs-toast-icon';
    icon.textContent = iconFor(type);

    var body = document.createElement('div');
    var title = document.createElement('div');
    title.className = 'phaqs-toast-title';
    title.textContent = options.title || titleFor(type);
    var msg = document.createElement('div');
    msg.className = 'phaqs-toast-message';
    msg.textContent = text;
    body.appendChild(title);
    body.appendChild(msg);

    var close = document.createElement('button');
    close.type = 'button';
    close.className = 'phaqs-toast-close';
    close.setAttribute('aria-label', 'Close notification');
    close.innerHTML = '&times;';
    close.addEventListener('click', function () { closeToast(toast); });

    toast.appendChild(icon);
    toast.appendChild(body);
    toast.appendChild(close);
    region().appendChild(toast);

    var duration = Number(options.duration || (type === 'error' ? 6500 : 4300));
    if (duration > 0) window.setTimeout(function () { closeToast(toast); }, duration);
    return toast;
  };

  window.phaqsConfirm = function (message, options) {
    options = options || {};
    return new Promise(function (resolve) {
      ensureStyles();

      // Only one confirmation may exist at a time. This removes stale copies
      // that previously appeared as plain content below the profile form.
      document.querySelectorAll('.phaqs-dialog-backdrop').forEach(function (node) {
        if (node.parentNode) node.parentNode.removeChild(node);
      });
      if (activeDialogResolve) activeDialogResolve(false);
      activeDialogResolve = resolve;

      var backdrop = document.createElement('div');
      backdrop.className = 'phaqs-dialog-backdrop';
      backdrop.setAttribute('data-phaqs-dialog-root', 'true');
      backdrop.setAttribute('role', 'presentation');
      // Critical positioning is inline as a cache-safe fallback. Even if an
      // old stylesheet is served, this cannot fall back into normal page flow.
      backdrop.style.cssText = 'position:fixed;inset:0;z-index:2147483646;display:flex;align-items:center;justify-content:center;padding:20px;background:rgba(2,18,46,.58);backdrop-filter:blur(3px);';
      // Use a div so global page-level `section` spacing cannot enlarge the dialog.
      var dialog = document.createElement('div');
      dialog.className = 'phaqs-dialog';
      dialog.setAttribute('role', 'dialog');
      dialog.setAttribute('aria-modal', 'true');
      dialog.setAttribute('aria-labelledby', 'phaqs-dialog-title');
      dialog.style.cssText = 'width:min(430px,100%);overflow:hidden;border:1px solid #d6e0ed;border-radius:16px;background:#fff;box-shadow:0 28px 80px rgba(2,18,46,.30);color:#0b1f3a;font-family:Inter,Arial,sans-serif;';
      dialog.innerHTML = '<div class="phaqs-dialog-copy"><div class="phaqs-dialog-symbol" aria-hidden="true">!</div><p class="phaqs-dialog-kicker">Confirmation</p><h2 class="phaqs-dialog-title" id="phaqs-dialog-title"></h2><p class="phaqs-dialog-message"></p></div><div class="phaqs-dialog-actions"><button type="button" class="phaqs-dialog-cancel"></button><button type="button" class="phaqs-dialog-confirm"></button></div>';
      dialog.querySelector('.phaqs-dialog-title').textContent = options.title || 'Please confirm';
      dialog.querySelector('.phaqs-dialog-message').textContent = String(message || 'Continue with this action?');
      var cancel = dialog.querySelector('.phaqs-dialog-cancel');
      var confirmButton = dialog.querySelector('.phaqs-dialog-confirm');
      cancel.textContent = options.cancelText || 'Cancel';
      confirmButton.textContent = options.confirmText || 'Continue';
      if (options.danger) confirmButton.classList.add('is-danger');
      function finish(value) {
        document.removeEventListener('keydown', onKey);
        if (backdrop.parentNode) backdrop.parentNode.removeChild(backdrop);
        document.documentElement.classList.remove('phaqs-dialog-open');
        var done = activeDialogResolve;
        activeDialogResolve = null;
        if (done) done(value);
      }
      function onKey(event) { if (event.key === 'Escape') finish(false); }
      cancel.addEventListener('click', function () { finish(false); });
      confirmButton.addEventListener('click', function () { finish(true); });
      backdrop.addEventListener('click', function (event) { if (event.target === backdrop) finish(false); });
      document.addEventListener('keydown', onKey);
      backdrop.appendChild(dialog);
      (document.body || document.documentElement).appendChild(backdrop);
      document.documentElement.classList.add('phaqs-dialog-open');
      window.setTimeout(function () { cancel.focus(); }, 0);
    });
  };

  // Replace plain browser alert boxes throughout PHAQS without changing existing actions.
  window.alert = function (message) {
    window.phaqsNotify(message);
  };
})();
