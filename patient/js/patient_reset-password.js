document.addEventListener('DOMContentLoaded',()=>document.querySelector('form')?.addEventListener('submit',resetPassword));
async function resetPassword(e){
  e.preventDefault();
  const params=new URLSearchParams(location.search);
  const token=params.get('token')||document.getElementById('token')?.value||'';
  const password=document.getElementById('password')?.value||'';
  const confirmation=document.getElementById('confirmPassword')?.value||'';
  const message=document.getElementById('message');
  if(password!==confirmation){
    if(message){message.textContent='Passwords do not match.';message.style.color='#dc2626';}
    return;
  }
  const r=await api('patient_reset_password',{token,password});
  if(message){message.textContent=r.message||(r.ok?'Password reset.':'Reset failed.');message.style.color=r.ok?'#15803d':'#dc2626';}
  if(r.ok)setTimeout(()=>location.href='login.html',900);
}
