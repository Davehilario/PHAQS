document.addEventListener('DOMContentLoaded',()=>{document.getElementById('registerForm')?.addEventListener('submit',register);initPolicyReview()});
async function initPolicyReview(){
  const modalEl=document.getElementById('termsModal'),body=document.getElementById('termsModalBody'),agree=document.getElementById('agreeTermsCheckbox'),main=document.getElementById('termsCheck');
  if(!modalEl||!body||!agree||!main)return;
  const modal=bootstrap.Modal.getOrCreateInstance(modalEl);
  ['openTermsLink','openPrivacyLink'].forEach(id=>document.getElementById(id)?.addEventListener('click',e=>{e.preventDefault();modal.show()}));
  const updateScroll=()=>{const reached=body.scrollTop+body.clientHeight>=body.scrollHeight-12;agree.disabled=!reached;const note=document.getElementById('scrollTermsNotice');if(note)note.textContent=reached?'You may now confirm that you reviewed the policy.':'Please scroll to the bottom before agreeing.'};
  body.addEventListener('scroll',updateScroll);agree.addEventListener('change',()=>{main.checked=agree.checked;if(agree.checked){setTimeout(()=>modal.hide(),350)}});main.addEventListener('click',e=>{if(!agree.checked){e.preventDefault();modal.show()}});
  try{const r=await api('public_privacy_policy',null,'GET'),p=r.policy||{};if(p.id){const box=document.createElement('section');box.style.cssText='padding:14px;margin-bottom:18px;border:1px solid #bfdbfe;border-left:4px solid #2563eb;border-radius:8px;background:#eff6ff';const title=document.createElement('h6');title.textContent=`Current published policy — version ${p.version_label}`;const text=document.createElement('p');text.style.whiteSpace='pre-line';text.textContent=p.content||'';const retention=document.createElement('p');retention.innerHTML=`<strong>Retention period:</strong> ${Number(p.retention_days)} days`;box.append(title,text,retention);body.prepend(box)}}catch(_){}
  modalEl.addEventListener('shown.bs.modal',()=>{body.scrollTop=0;agree.checked=main.checked;agree.disabled=true;updateScroll()});
}
async function register(e){
  e.preventDefault();
  const password=val('password');
  const confirmation=val('confirmPassword');
  const matchError=document.getElementById('matchError');
  if(password!==confirmation){
    if(matchError)matchError.textContent='Passwords do not match.';
    return;
  }
  if(matchError)matchError.textContent='';
  const data={
    firstName:val('firstName')||val('fname'),
    lastName:val('lastName')||val('lname'),
    email:val('email'),
    mobile:val('mobile'),
    address:val('address'),
    password,
    privacyConsent:Boolean(document.getElementById('termsCheck')?.checked)
  };
  const r=await api('patient_register',data);
  alert(r.message||(r.ok?'Registered successfully.':'Registration failed.'));
  if(r.ok)location.href='login.html';
}
function val(id){return document.getElementById(id)?.value?.trim()||'';}
