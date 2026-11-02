let withdrawReturnFocus=null;
document.addEventListener('DOMContentLoaded',async()=>{
  const patient=await loadPatientNav();if(!patient)return;
  document.getElementById('acceptBtn').onclick=acceptPolicy;
  document.getElementById('withdrawBtn').onclick=openWithdrawModal;
  document.getElementById('withdrawCancelBtn').onclick=closeWithdrawModal;
  document.getElementById('withdrawConfirmBtn').onclick=withdrawPolicy;
  document.querySelector('[data-close-withdraw]')?.addEventListener('click',closeWithdrawModal);
  document.addEventListener('keydown',event=>{if(event.key==='Escape'&&!document.getElementById('withdrawModal').hidden)closeWithdrawModal()});
  await loadPrivacy();
});
async function loadPrivacy(){const r=await api('patient_privacy_status',null,'GET');if(!r.ok){notice(r.message||'Unable to load privacy information.');return}const p=r.policy||{};document.getElementById('policyVersion').textContent=p.version_label||'—';document.getElementById('policyTitle').textContent=p.title||'Patient Privacy Policy';document.getElementById('policyContent').textContent=p.content||'No published privacy policy is available.';document.getElementById('retentionPeriod').textContent=p.retention_days?`${Math.round(Number(p.retention_days)/365*10)/10} years`:'—';document.getElementById('effectiveDate').textContent=p.effective_at?`Effective ${formatDateTime(p.effective_at)}`:'';document.getElementById('consentStatus').textContent=r.has_current_consent?'Accepted':'Action required';document.getElementById('consentStatus').style.color=r.has_current_consent?'#15803d':'#b45309';renderAccess(r.access_history||[])}
function renderAccess(rows){const box=document.getElementById('accessList');box.innerHTML=rows.length?rows.map(x=>`<article class="access"><i class="fas ${x.actor_type==='admin'?'fa-user-shield':x.actor_type==='caregiver'?'fa-people-roof':'fa-user'}"></i><div><strong>${esc(x.action||'Patient record activity')}</strong><span>${esc(x.actor_name||'System')} • ${esc(x.resource||'Record')}</span><span>${esc(x.purpose||'Authorized health-center operation')}${x.branch?' • '+esc(x.branch):''}</span><time>${esc(formatDateTime(x.created_at))}</time></div></article>`).join(''):'<div class="empty">No access-history events have been recorded yet.</div>'}
async function acceptPolicy(){if(!document.getElementById('acceptCheck').checked){notice('Check the confirmation after reviewing the policy.');return}const r=await api('patient_privacy_accept',{accepted:true},'POST');notice(r.message,r.ok);if(r.ok)await loadPrivacy()}
function openWithdrawModal(){
  const modal=document.getElementById('withdrawModal');
  withdrawReturnFocus=document.activeElement;
  modal.hidden=false;
  document.body.classList.add('privacy-modal-open');
  requestAnimationFrame(()=>document.getElementById('withdrawCancelBtn')?.focus());
}
function closeWithdrawModal(){
  const modal=document.getElementById('withdrawModal');
  modal.hidden=true;
  document.body.classList.remove('privacy-modal-open');
  withdrawReturnFocus?.focus?.();
}
async function withdrawPolicy(){
  const button=document.getElementById('withdrawConfirmBtn');
  const original=button.innerHTML;
  button.disabled=true;
  button.innerHTML='<i class="fas fa-spinner fa-spin"></i> Withdrawing…';
  const r=await api('patient_privacy_withdraw',{},'POST');
  button.disabled=false;
  button.innerHTML=original;
  notice(r.message||'Unable to update your consent.',r.ok);
  if(r.ok){closeWithdrawModal();await loadPrivacy()}
}
function formatDateTime(v){const d=new Date(String(v||'').replace(' ','T'));return Number.isNaN(d.getTime())?(v||''):d.toLocaleString('en-PH',{dateStyle:'medium',timeStyle:'short'})}
function notice(message,ok=false){const box=document.getElementById('toast');box.textContent=message||'Done.';box.style.background=ok?'#166534':'#991b1b';box.hidden=false;setTimeout(()=>box.hidden=true,4200)}
