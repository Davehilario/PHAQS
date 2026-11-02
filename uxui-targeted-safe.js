(()=>{
'use strict';

const isInsideExistingDialog = el => !!el.closest('[role="dialog"],dialog,.modal,.swal2-container');

document.addEventListener('click', event => {
  const el = event.target.closest('a,button');
  if (!el || isInsideExistingDialog(el) || el.hasAttribute('data-no-confirm')) return;

  const text = (el.textContent || '').trim().toLowerCase();
  const href = (el.getAttribute('href') || '').toLowerCase();
  const action = (el.dataset.action || '').toLowerCase();
  const isLogout = text === 'logout' || text.includes('log out') || href.includes('logout');
  const isDelete = action === 'delete' || text === 'delete' || text.startsWith('delete ');

  if (!isLogout && !isDelete) return;
  if (el.dataset.confirmHandled === 'true' || el.dataset.confirmBound === 'true') return;

  const message = isLogout
    ? 'Are you sure you want to log out?'
    : 'Are you sure you want to delete this item? This action cannot be undone.';
  if (!window.confirm(message)) {
    event.preventDefault();
    event.stopImmediatePropagation();
  }
}, true);

document.querySelectorAll('button:not([aria-label]),a:not([aria-label])').forEach(el => {
  if (!(el.textContent || '').trim() && el.title) el.setAttribute('aria-label', el.title);
});
})();
