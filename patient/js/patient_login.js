let GOOGLE_CLIENT_ID='';
document.addEventListener('DOMContentLoaded',()=>{
 document.getElementById('togglePassword')?.addEventListener('click',function(){const p=document.getElementById('password');p.type=p.type==='password'?'text':'password';this.classList.toggle('fa-eye');this.classList.toggle('fa-eye-slash');});
 document.getElementById('password')?.addEventListener('keyup',e=>{const w=document.getElementById('capsWarning'); if(w)w.style.display=e.getModifierState('CapsLock')?'block':'none';});
 document.getElementById('loginForm')?.addEventListener('submit',login);
 document.getElementById('forgotLink')?.addEventListener('click',e=>{e.preventDefault(); document.getElementById('forgotModal').style.display='flex';});
 document.getElementById('googleBtn')?.addEventListener('click',startGoogleLogin);
 loadGoogleScript();
 loadPublicAuthConfig();
});
function showLoginMessage(type,text){const m=document.getElementById('loginMessage'); if(!m)return; m.style.visibility='visible'; m.className=type; m.innerHTML=text;}
function hideLoginMessage(){const m=document.getElementById('loginMessage'); if(!m)return; m.style.visibility='hidden'; m.className=''; m.innerHTML='';}
async function verifyPatientSessionAndOpen(source='password'){
  showLoginMessage('success-msg',source==='google'?'Google account verified. Opening your patient dashboard…':'Account verified. Opening your patient dashboard…');
  const session=await api('patient_me',null,'GET');
  if(!session.ok){showLoginMessage('error-msg','Your account was verified, but this browser did not retain the session. Allow cookies for this site, then sign in again.');return false;}
  setTimeout(()=>location.replace('dashboard.html'),350);return true;
}
async function login(e){e.preventDefault(); hideLoginMessage(); const email=document.getElementById('email').value.trim(); const password=document.getElementById('password').value; const btn=document.getElementById('loginBtn'); btn.disabled=true; btn.innerHTML='Checking...'; const r=await api('patient_login',{email,password}); if(r.ok){await verifyPatientSessionAndOpen('password');} else {btn.disabled=false; btn.innerHTML='<i class="fa-regular fa-user"></i> Login'; showLoginMessage('error-msg',r.message||'Invalid email or password.');}}
function loadGoogleScript(){ if(window.google) return; const s=document.createElement('script'); s.src='https://accounts.google.com/gsi/client'; s.async=true; s.defer=true; document.head.appendChild(s); }
async function loadPublicAuthConfig(){try{const r=await api('public_auth_config',null,'GET');GOOGLE_CLIENT_ID=r.ok&&r.googleEnabled?String(r.googleClientId||''):'';const button=document.getElementById('googleBtn');if(button&&!GOOGLE_CLIENT_ID){button.disabled=true;button.title='Google Sign-In is not configured for this deployment.'}}catch(_){}}
function startGoogleLogin(){ if(!GOOGLE_CLIENT_ID){showLoginMessage('error-msg','Google Sign-In is not configured for this website. You can still sign in using your email and password.');return;} if(!window.google?.accounts?.oauth2){showLoginMessage('error-msg','Google library is still loading. Try again.'); loadGoogleScript(); return;} const client=google.accounts.oauth2.initTokenClient({client_id:GOOGLE_CLIENT_ID,scope:'openid email profile',callback:async(resp)=>{ if(!resp.access_token){showLoginMessage('error-msg','Google sign-in was cancelled. No changes were made to your account.'); return;} const r=await api('patient_google_access_login',{accessToken:resp.access_token}); if(r.ok){await verifyPatientSessionAndOpen('google');} else showLoginMessage('error-msg',r.message||'We could not verify this Google account. Please try again.'); }}); client.requestAccessToken();}
function closeModal(){document.getElementById('forgotModal').style.display='none';}
async function sendReset(){
  const btn=document.querySelector('#forgotForm .auth-primary-btn');
  const email=document.getElementById('resetEmail').value.trim();
  const m=document.getElementById('resetMessage');
  if(btn){btn.disabled=true;}
  m.textContent='Sending...'; m.style.color='#64748b';
  const r=await api('patient_request_password_reset',{email});
  m.textContent=r.message||(r.ok?'Reset link created.':'Unable to send reset.');
  m.style.color=r.ok?'green':'red';
  if(r.ok && r.resetToken){
    setTimeout(()=>{ window.location.href='reset-password.html?token='+encodeURIComponent(r.resetToken); }, r.mailSent?1200:400);
  } else if(btn){
    btn.disabled=false;
  }
}
