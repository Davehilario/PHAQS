/* otp handling */
let submittedEmail='';
let verifiedOtp='';

document.addEventListener('DOMContentLoaded',()=>{
  document.getElementById('forgotForm')?.addEventListener('submit',requestCode);
  document.getElementById('otpForm')?.addEventListener('submit',verifyCode);
  document.getElementById('newPasswordForm')?.addEventListener('submit',confirmReset);
  document.getElementById('resendCodeBtn')?.addEventListener('click',resendCode);
  document.getElementById('otpCode')?.addEventListener('input',event=>{
    event.target.value=event.target.value.replace(/\D/g,'').slice(0,6);
  });
  showStep('email');
});

function api(action,payload){
  return fetch('../backend/api.php?action='+encodeURIComponent(action),{
    method:'POST',credentials:'include',cache:'no-store',
    headers:{'Content-Type':'application/json','Accept':'application/json'},
    body:JSON.stringify(payload||{})
  }).then(async response=>{
    const raw=await response.text();
    let result={};
    try{result=raw?JSON.parse(raw):{}}
    catch(_){return {ok:false,message:'The server returned an invalid response.'}}
    if(!response.ok&&result.ok!==false)result.ok=false;
    return result;
  }).catch(()=>({ok:false,message:'Unable to reach the server. Check Apache, MySQL, and your connection.'}));
}

function setMessage(id,text,ok){
  const el=document.getElementById(id);
  if(!el)return;
  el.textContent=text||'';
  el.style.color=ok?'#15803d':'#dc2626';
}

function showStep(step){
  const map={email:'forgotForm',otp:'otpForm',password:'newPasswordForm'};
  Object.entries(map).forEach(([key,id])=>{
    const form=document.getElementById(id);
    if(!form)return;
    const active=key===step;
    form.hidden=!active;
    form.classList.toggle('is-active',active);
  });
  const titles={
    email:['Forgot Password','Enter your email address and we’ll send a 6-digit verification code.'],
    otp:['Enter Verification Code',submittedEmail?`We sent a 6-digit code to ${maskEmail(submittedEmail)}. It expires in 10 minutes.`:'Enter the 6-digit code sent to your email.'],
    password:['Create New Password','Code verified. Choose a secure new password for your account.']
  };
  document.getElementById('forgotTitle').textContent=titles[step][0];
  document.getElementById('forgotSubtitle').textContent=titles[step][1];
  document.querySelectorAll('.recovery-progress span').forEach((bar,index)=>{
    const activeCount={email:1,otp:2,password:3}[step];
    bar.classList.toggle('active',index<activeCount);
  });
  if(step==='otp')document.getElementById('otpCode')?.focus();
  if(step==='password')document.getElementById('newPassword')?.focus();
}

function maskEmail(email){
  const parts=String(email).split('@');
  if(parts.length!==2)return email;
  const name=parts[0],domain=parts[1];
  return (name.slice(0,2)||'*')+'*'.repeat(Math.max(3,name.length-2))+'@'+domain;
}

async function requestCode(event){
  event.preventDefault();
  const email=document.getElementById('resetEmail').value.trim();
  const btn=document.getElementById('sendCodeBtn');
  if(!email){setMessage('resetMessage','Please enter your registered email address.',false);return}
  setMessage('resetMessage','',true);
  btn.disabled=true;btn.innerHTML='<i class="fa-solid fa-spinner fa-spin"></i> Sending code...';
  const result=await api('patient_request_password_reset',{email});
  btn.disabled=false;btn.innerHTML='<i class="fa-regular fa-paper-plane"></i> Send Verification Code';
  if(!result.ok){setMessage('resetMessage',result.message||'Unable to send the code.',false);return}
  submittedEmail=email;
  showStep('otp');
  setMessage('otpMessage','Verification code sent. Check your email inbox and spam folder.',true);
}

async function resendCode(){
  if(!submittedEmail){showStep('email');return}
  const btn=document.getElementById('resendCodeBtn');
  btn.disabled=true;btn.textContent='Sending...';
  const result=await api('patient_request_password_reset',{email:submittedEmail});
  btn.disabled=false;btn.textContent="Didn't get a code? Send again";
  setMessage('otpMessage',result.ok?'A new verification code has been sent.':(result.message||'Unable to resend right now.'),!!result.ok);
}

async function verifyCode(event){
  event.preventDefault();
  const otp=document.getElementById('otpCode').value.trim();
  const btn=document.getElementById('verifyOtpBtn');
  if(otp.length!==6){setMessage('otpMessage','Enter the complete 6-digit verification code.',false);return}
  btn.disabled=true;btn.innerHTML='<i class="fa-solid fa-spinner fa-spin"></i> Verifying...';
  const result=await api('patient_verify_reset_otp',{email:submittedEmail,otp});
  btn.disabled=false;btn.innerHTML='<i class="fa-solid fa-circle-check"></i> Verify Code';
  if(!result.ok){setMessage('otpMessage',result.message||'Incorrect verification code.',false);return}
  verifiedOtp=otp;
  showStep('password');
}

async function confirmReset(event){
  event.preventDefault();
  const password=document.getElementById('newPassword').value;
  const confirmation=document.getElementById('confirmNewPassword').value;
  const btn=document.getElementById('confirmResetBtn');
  if(password.length<8){setMessage('newPasswordMessage','Password must contain at least 8 characters.',false);return}
  if(password!==confirmation){setMessage('newPasswordMessage','Passwords do not match.',false);return}
  btn.disabled=true;btn.innerHTML='<i class="fa-solid fa-spinner fa-spin"></i> Changing password...';
  const result=await api('patient_reset_password_otp',{email:submittedEmail,otp:verifiedOtp,password});
  btn.disabled=false;btn.innerHTML='<i class="fa-solid fa-key"></i> Change Password';
  if(!result.ok){setMessage('newPasswordMessage',result.message||'Unable to reset your password.',false);return}
  setMessage('newPasswordMessage','Password changed successfully. Redirecting to login…',true);
  setTimeout(()=>location.replace('login.html'),1200);
}
