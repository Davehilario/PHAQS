(function(){
  const current=location.pathname.split('/').pop()||'dashboard.html';
  const mainLinks=[
    ['dashboard.html','fa-solid fa-house','Dashboard'],
    ['book.html','fa-regular fa-calendar-plus','Book Appointment'],
    ['appointments.html','fa-regular fa-calendar-check','My Appointments'],
    ['queue.html','fa-solid fa-list-check','Queue Status']
  ];
  const secondaryLinks=[
    ['profile.html','fas fa-user','Profile'],
    ['messages.html','fa-regular fa-comments','Help Center'],
    ['family.html','fas fa-people-roof','Family Care'],
    ['privacy.html','fas fa-shield-halved','Privacy & Access']
  ];
  const mobileLinks=[
    ...mainLinks,
    ['notifications.html','fa-regular fa-bell','Notifications'],
    ...secondaryLinks
  ];
  function active(href){return href===current?' active':''}
  function link(item,mobile=false){return `<a class="${active(item[0]).trim()}" href="${item[0]}"><i class="${item[1]}${mobile?' me-2':''}"></i><span>${item[2]}</span></a>`}
  function accountLink(item){return `<a class="patient-menu-item${active(item[0])}" href="${item[0]}"><i class="${item[1]}"></i><span>${item[2]}</span></a>`}
  function initials(name){return String(name||'Patient').trim().split(/\s+/).map(part=>part[0]).slice(0,2).join('').toUpperCase()||'P'}
  function ensureStyle(){if(document.querySelector('link[href*="patient_navbar_final.css"]'))return;const style=document.createElement('link');style.rel='stylesheet';style.href='css/patient_navbar_final.css?v=20260721-dashboard-shell';document.head.appendChild(style)}
  function markup(){return `
    <nav class="navbar patient-navbar" data-patient-standard-shell>
      <div class="nav-container">
        <a class="logo-area" href="dashboard.html" aria-label="Patient dashboard">
          <img src="images/mhc-logo.png" class="logo-img" alt="Pulilan Health Center Logo">
          <div class="logo-text"><h5>Pulilan Health Center</h5><span>PHAQS</span></div>
        </a>
        <div class="menu">
          ${mainLinks.map(item=>link(item)).join('')}
          <button class="navbar-notif-btn" type="button" aria-label="Notifications" onclick="location.href='notifications.html'"><i class="fa-regular fa-bell"></i><span class="notif-count">0</span></button>
          <details class="user-menu-wrap patient-account-details">
            <summary class="user-dropdown"><span class="avatar" id="avatarBtn">P</span><span class="user-name" id="userName">Patient</span><i class="fas fa-chevron-down user-chevron"></i></summary>
            <div class="patient-account-menu patient-user-menu">
              ${secondaryLinks.map(item=>accountLink(item)).join('')}
              <div class="dropdown-divider"></div>
              <button class="patient-menu-item logout" type="button" data-patient-logout><i class="fas fa-right-from-bracket"></i><span>Logout</span></button>
            </div>
          </details>
        </div>
        <button class="hamburger-btn" onclick="toggleMobileMenu()" id="hamburgerBtn" type="button" aria-label="Open menu" aria-expanded="false"><i class="fas fa-bars" id="hamburgerIcon"></i></button>
        <div class="mobile-menu" id="mobileMenu">
          <div class="mob-user"><div class="mob-avatar" id="mobAvatar">P</div><span id="mobName">Patient</span></div>
          <div class="mob-divider"></div>
          ${mobileLinks.map(item=>link(item,true)).join('')}
          <div class="mob-divider"></div>
          <button class="mob-logout" data-patient-logout type="button"><i class="fa-solid fa-right-from-bracket me-2"></i><span>Logout</span></button>
        </div>
      </div>
    </nav>`}
  function closeMenu(){const menu=document.getElementById('mobileMenu'),button=document.getElementById('hamburgerBtn'),icon=document.getElementById('hamburgerIcon');menu?.classList.remove('show');button?.setAttribute('aria-expanded','false');icon?.classList.add('fa-bars');icon?.classList.remove('fa-times');document.body.classList.remove('patient-menu-open')}
  window.toggleMobileMenu=function(){const menu=document.getElementById('mobileMenu'),button=document.getElementById('hamburgerBtn'),icon=document.getElementById('hamburgerIcon');if(!menu)return;const open=!menu.classList.contains('show');menu.classList.toggle('show',open);button?.setAttribute('aria-expanded',String(open));icon?.classList.toggle('fa-bars',!open);icon?.classList.toggle('fa-times',open);document.body.classList.toggle('patient-menu-open',open)};
  async function logout(){try{await fetch('../backend/api.php?action=patient_logout',{method:'POST',credentials:'include',headers:{'Content-Type':'application/json'},body:'{}'})}catch(_){}location.href='login.html'}
  async function hydrate(){
    try{const result=await fetch('../backend/api.php?action=patient_me',{credentials:'include',cache:'no-store'}).then(response=>response.json());if(result.ok){const patient=result.patient||{},name=patient.name||`${patient.firstName||''} ${patient.lastName||''}`.trim()||'Patient';document.querySelectorAll('#userName,#mobName').forEach(element=>element.textContent=name);{const photo=patient.profilePhoto||patient.profile_picture||'';if(window.hcApplyPatientPhoto)window.hcApplyPatientPhoto(photo,name);else document.querySelectorAll('#avatarBtn,#mobAvatar').forEach(element=>element.textContent=initials(name))}}}catch(_){}
    try{const result=await fetch('../backend/api.php?action=patient_notifications&limit=1',{credentials:'include',cache:'no-store'}).then(response=>response.json());if(result.ok){const unread=Number(result.unread||0);document.querySelectorAll('.notif-count').forEach(element=>{element.textContent=unread>99?'99+':String(unread);element.style.display=unread>0?'flex':'none'});document.querySelectorAll('.navbar-notif-btn').forEach(element=>element.classList.toggle('has-unread',unread>0))}}catch(_){}
  }
  function install(){
    ensureStyle();
    const existing=document.querySelector('nav.patient-navbar,nav.nav');
    if(!existing)return;
    const complete=existing.classList.contains('patient-navbar')&&existing.querySelector('#mobileMenu')&&existing.querySelector('.navbar-notif-btn');
    if(!complete)existing.outerHTML=markup();
    document.querySelectorAll('[data-patient-logout]').forEach(button=>button.addEventListener('click',event=>{event.preventDefault();window.confirmPatientLogout?window.confirmPatientLogout():logout()}));
    document.querySelectorAll('#mobileMenu a').forEach(anchor=>anchor.addEventListener('click',closeMenu));
    hydrate();
  }
  document.addEventListener('keydown',event=>{if(event.key==='Escape')closeMenu()});
  window.addEventListener('resize',()=>{if(innerWidth>1100)closeMenu()});
  if(document.querySelector('nav.patient-navbar,nav.nav'))install();
  else if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',install);
  else install();
})();
