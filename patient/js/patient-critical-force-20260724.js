
(function(){
  'use strict';
  const page=String(location.pathname.split('/').pop()||'').toLowerCase();
  const directForgotUrl=()=>new URL('forgot-password.html?force=20260724-v1',location.href).href;

  function forceForgot(){
    const old=document.querySelector('.forgot-link,#forgotPasswordDirect,[data-forgot-password]');
    if(!old)return;
    old.setAttribute('href','forgot-password.html?force=20260724-v1');
    old.id='forgotPasswordDirect';
    old.removeAttribute('onclick');
    const go=function(event){
      if(event){event.preventDefault();event.stopPropagation();if(event.stopImmediatePropagation)event.stopImmediatePropagation();}
      location.assign(directForgotUrl());
      return false;
    };
    old.onclick=go;
    old.addEventListener('pointerup',go,true);
    old.addEventListener('touchend',go,{capture:true,passive:false});
    old.addEventListener('keydown',function(e){if(e.key==='Enter'||e.key===' '){go(e);}},true);
  }

  function rebuildMobileMenu(){
    const menu=document.getElementById('mobileMenu');
    if(!menu)return;
    const items=[
      ['dashboard.html','fa-solid fa-house','Dashboard'],
      ['book.html','fa-regular fa-calendar-plus','Book Appointment'],
      ['appointments.html','fa-regular fa-calendar-check','My Appointments'],
      ['queue.html','fa-solid fa-list-check','Queue Status'],
      ['notifications.html','fa-regular fa-bell','Notifications'],
      ['profile.html','fa-solid fa-user','Profile'],
      ['messages.html','fa-regular fa-comments','Help Center'],
      ['family.html','fa-solid fa-people-roof','Family Care'],
      ['privacy.html','fa-solid fa-shield-halved','Privacy & Access']
    ];
    const userName=document.getElementById('mobName')?.textContent||'Patient';
    const avatar=document.getElementById('mobAvatar');
    const avatarHTML=avatar?.innerHTML||'P';
    menu.innerHTML=`<div class="mob-user"><div class="mob-avatar" id="mobAvatar">${avatarHTML}</div><span id="mobName">${userName}</span></div><div class="mob-divider"></div>`+
      items.map(([href,icon,label])=>`<a class="${page===href?'active':''}" href="${href}"><i class="${icon}"></i><span>${label}</span></a>`).join('')+
      `<div class="mob-divider"></div><button class="mob-logout" type="button" data-patient-logout><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></button>`;
    menu.querySelector('[data-patient-logout]')?.addEventListener('click',function(e){e.preventDefault();window.confirmPatientLogout?.();});
    menu.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>{menu.classList.remove('show');document.body.classList.remove('patient-menu-open');}));
    if(typeof window.loadPatientNav==='function')window.loadPatientNav().catch(()=>{});
  }

  function forceTerms(){
    const modalEl=document.getElementById('termsModal');
    const agree=document.getElementById('agreeTermsCheckbox');
    const main=document.getElementById('termsCheck');
    if(!modalEl||!agree||!main)return;
    agree.disabled=false;
    modalEl.setAttribute('data-bs-backdrop','true');
    modalEl.setAttribute('data-bs-keyboard','true');
    const clean=function(){
      modalEl.classList.remove('show');modalEl.style.display='none';modalEl.setAttribute('aria-hidden','true');modalEl.removeAttribute('aria-modal');
      document.body.classList.remove('modal-open');document.body.style.removeProperty('overflow');document.body.style.removeProperty('padding-right');
      document.querySelectorAll('.modal-backdrop').forEach(x=>x.remove());
    };
    const hide=function(){try{window.bootstrap?.Modal.getOrCreateInstance(modalEl).hide();}catch(_){clean();}setTimeout(clean,80);};
    agree.addEventListener('change',function(){
      if(!agree.checked)return;
      main.checked=true;main.dispatchEvent(new Event('change',{bubbles:true}));hide();
    },true);
    agree.addEventListener('click',function(){if(agree.checked){main.checked=true;setTimeout(hide,20);}},true);
    modalEl.querySelectorAll('[data-bs-dismiss="modal"],.btn-close').forEach(btn=>btn.addEventListener('click',hide,true));
    document.addEventListener('keydown',e=>{if(e.key==='Escape'&&modalEl.classList.contains('show'))hide();});
    const body=document.getElementById('termsModalBody');
    if(body)body.addEventListener('scroll',()=>{agree.disabled=false;},{passive:true});
  }

  function init(){forceForgot();rebuildMobileMenu();forceTerms();}
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init,{once:true});else init();
  window.addEventListener('pageshow',()=>{forceForgot();});
})();
