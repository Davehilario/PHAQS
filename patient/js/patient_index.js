let landingMap = null;

window.goLogin = () => { window.location.href = 'login.html'; };
window.goRegister = () => { window.location.href = 'register.html'; };
window.scrollToTop = () => window.scrollTo({ top: 0, behavior: 'smooth' });
window.scrollToSection = (sectionId) => {
  const section = document.getElementById(sectionId);
  if (!section) return;
  const navbar = document.getElementById('mainNavbar');
  const offset = (navbar?.offsetHeight || 84) + 12;
  const top = section.getBoundingClientRect().top + window.scrollY - offset;
  window.scrollTo({ top, behavior: 'smooth' });
};
window.toggleMenu = () => {
  const menu = document.getElementById('mobileMenu');
  const icon = document.getElementById('hamburgerIcon');
  const button = document.getElementById('hamburgerBtn');
  if (!menu) return;
  const isOpen = menu.classList.toggle('show');
  icon?.classList.toggle('fa-bars', !isOpen);
  icon?.classList.toggle('fa-xmark', isOpen);
  button?.setAttribute('aria-expanded', String(isOpen));
  button?.setAttribute('aria-label', isOpen ? 'Close navigation menu' : 'Open navigation menu');
};
window.zoomTo = (latitude, longitude) => {
  window.scrollToSection('map-section');
  if (landingMap) {
    window.setTimeout(() => {
      landingMap.invalidateSize();
      landingMap.setView([latitude, longitude], 16, { animate: true });
    }, 450);
  }
};

const landingServiceGuides = Object.freeze({
  consultation: {
    title: 'General medical consultation',
    description: 'For common health concerns, health assessment, and consultation with an RHU healthcare professional.',
    icon: 'fa-stethoscope',
    requirements: ['Valid ID', 'Current medicines or prescription, if applicable', 'Previous test results or medical records related to your concern']
  },
  vaccination: {
    title: 'Vaccination and immunization',
    description: 'For routine vaccines and immunization services available to eligible children and adults.',
    icon: 'fa-syringe',
    requirements: ['Valid ID', 'Vaccination card or immunization record', 'Child birth record when booking for a minor, if requested']
  },
  prenatal: {
    title: 'Prenatal care',
    description: 'For pregnancy monitoring, prenatal checkups, and maternal-health guidance at the RHU.',
    icon: 'fa-person-pregnant',
    requirements: ['Valid ID', 'Prenatal or maternal record, if available', 'Recent laboratory or ultrasound results related to the visit']
  },
  child: {
    title: 'Child immunization',
    description: 'For childhood vaccines, immunization follow-up, and eligible child-health services.',
    icon: 'fa-baby',
    requirements: ['Parent or guardian valid ID', 'Child immunization record', 'Child birth record, if requested by the RHU']
  },
  family: {
    title: 'Family planning',
    description: 'For family-planning information, counseling, and services available at participating RHU branches.',
    icon: 'fa-people-roof',
    requirements: ['Valid ID', 'Relevant prescription or medical record, if applicable', 'List of questions or concerns you want to discuss']
  }
});

window.selectLandingService = (serviceKey, shouldScroll = false) => {
  const guide = landingServiceGuides[serviceKey] || landingServiceGuides.consultation;
  const title = document.getElementById('visitPlannerResultTitle');
  const description = document.getElementById('visitPlannerResultDescription');
  const icon = document.getElementById('visitPlannerIcon');
  const requirements = document.getElementById('visitPlannerRequirements');
  if (!title || !description || !icon || !requirements) return;

  title.textContent = guide.title;
  description.textContent = guide.description;
  icon.className = `fa-solid ${guide.icon}`;
  requirements.replaceChildren(...guide.requirements.map((item) => {
    const row = document.createElement('li');
    const check = document.createElement('i');
    check.className = 'fa-solid fa-check';
    check.setAttribute('aria-hidden', 'true');
    row.append(check, document.createTextNode(item));
    return row;
  }));

  document.querySelectorAll('[data-service-choice]').forEach((button) => {
    const active = button.dataset.serviceChoice === serviceKey;
    button.classList.toggle('is-active', active);
    button.setAttribute('aria-selected', String(active));
    button.tabIndex = active ? 0 : -1;
  });
  try { window.sessionStorage.setItem('phc-landing-service-guide', serviceKey); } catch (error) {}
  if (shouldScroll) window.requestAnimationFrame(() => window.scrollToSection('visit-planner'));
};

function initializeLandingMap() {
  const mapElement = document.getElementById('map');
  if (!mapElement) return;

  const healthCenters = [
    { name: 'RHU I - Poblacion', coords: [14.9016, 120.8506], detail: 'General consultation and vaccination services' },
    { name: 'RHU II - Cutcot', coords: [14.9077, 120.8568], detail: 'Child immunization and family planning' },
    { name: 'RHU III - Tinejero', coords: [14.8979, 120.8465], detail: 'General consultation and vaccination services' },
    { name: 'RHU IV - Tibag', coords: [14.9142, 120.8421], detail: 'Prenatal and maternal care services' }
  ];
  const barangayStations = [
    { name: 'Longos BHS', coords: [14.9190, 120.8580] },
    { name: 'Paltao BHS', coords: [14.8908, 120.8528] },
    { name: 'Lumbac BHS', coords: [14.9062, 120.8358] }
  ];

  if (typeof window.L === 'undefined') {
    mapElement.classList.add('map-fallback');
    mapElement.innerHTML = `
      <div class="map-fallback-copy">
        <i class="fa-solid fa-map-location-dot"></i>
        <strong>Pulilan Health Center Locations</strong>
        <span>The interactive map is temporarily unavailable. Select a health center card below to view its location when the map connection is restored.</span>
      </div>
      <div class="map-fallback-pins">
        ${healthCenters.map((center, index) => `<span><b>RHU ${['I','II','III','IV'][index]}</b>${center.name}</span>`).join('')}
      </div>`;
    return;
  }

  landingMap = window.L.map(mapElement, { scrollWheelZoom: false }).setView([14.9038, 120.8498], 13);
  window.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(landingMap);

  const rhuLayer = window.L.layerGroup().addTo(landingMap);
  const bhsLayer = window.L.layerGroup().addTo(landingMap);
  const createLocationPin=(type,label)=>window.L.divIcon({
    className:'phc-location-marker-wrap',
    html:`<div class="phc-location-marker ${type}"><i class="fa-solid ${type==='rhu'?'fa-house-medical':'fa-kit-medical'}"></i><span>${label}</span></div>`,
    iconSize:type==='rhu'?[76,46]:[58,42],
    iconAnchor:type==='rhu'?[38,45]:[29,41],
    popupAnchor:[0,-42]
  });
  healthCenters.forEach((center,index) => {
    window.L.marker(center.coords,{icon:createLocationPin('rhu',`RHU ${['I','II','III','IV'][index]}`)})
      .bindPopup(`<strong>${center.name}</strong><br>${center.detail}`).addTo(rhuLayer);
  });
  barangayStations.forEach((station) => {
    window.L.marker(station.coords,{icon:createLocationPin('bhs','BHS')})
      .bindPopup(`<strong>${station.name}</strong><br>Barangay Health Station`).addTo(bhsLayer);
  });

  document.getElementById('rhuToggle')?.addEventListener('change', (event) => {
    if (event.target.checked) rhuLayer.addTo(landingMap); else landingMap.removeLayer(rhuLayer);
  });
  document.getElementById('bhsToggle')?.addEventListener('change', (event) => {
    if (event.target.checked) bhsLayer.addTo(landingMap); else landingMap.removeLayer(bhsLayer);
  });
  window.setTimeout(() => landingMap.invalidateSize(), 100);
}

function renderPublicAdvisory(advisories){
  const panel=document.getElementById('publicAdvisory');
  const title=document.getElementById('publicAdvisoryTitle');
  const message=document.getElementById('publicAdvisoryMessage');
  const label=document.getElementById('publicAdvisoryLabel');
  const close=document.getElementById('publicAdvisoryClose');
  if(!panel||!title||!message||!label)return;
  const item=Array.isArray(advisories)?advisories.find(row=>['urgent','important'].includes(String(row?.priority||'').toLowerCase())):null;
  if(!item){panel.hidden=true;return;}
  const priority=String(item.priority||'important').toLowerCase();
  const key=`${String(item.title||'')}|${String(item.published_at||'')}`;
  try{if(window.sessionStorage.getItem('phc-dismissed-advisory')===key){panel.hidden=true;return;}}catch(error){}
  panel.classList.remove('priority-urgent','priority-important');
  panel.classList.add(`priority-${priority}`);
  label.textContent=priority==='urgent'?'Urgent health advisory':'Important health advisory';
  title.textContent=String(item.title||'Health center update');
  message.textContent=String(item.message||'Please review the latest health center update.');
  panel.hidden=false;
  if(close)close.onclick=()=>{
    panel.hidden=true;
    try{window.sessionStorage.setItem('phc-dismissed-advisory',key);}catch(error){}
  };
}

function renderLandingUpdateBoard(advisories){
  const list=document.getElementById('landingUpdateList');
  if(!list)return;
  const rows=(Array.isArray(advisories)?advisories:[]).slice(0,3);
  if(!rows.length){
    list.innerHTML=`<article class="landing-update-empty compact"><span><i class="fa-solid fa-circle-check"></i></span><div><strong>No active public advisory</strong><p>There are no municipality-wide notices at this time. Check the RHU access board for today’s clinic schedule.</p></div></article>`;
    return;
  }
  const safe=value=>String(value??'').replace(/[&<>"']/g,character=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[character]));
  list.innerHTML=rows.map((item,index)=>{
    const rawPriority=String(item.priority||'normal').toLowerCase();
    const priority=['urgent','important'].includes(rawPriority)?rawPriority:'normal';
    const label=priority==='urgent'?'Urgent advisory':(priority==='important'?'Important update':'Public health update');
    const published=item.published_at?new Date(item.published_at):null;
    const date=published&&!Number.isNaN(published.getTime())?published.toLocaleDateString('en-PH',{month:'short',day:'numeric',year:'numeric'}):'Current notice';
    const attachmentUrl=String(item.attachment_url||'');
    const attachmentName=String(item.attachment_name||'Announcement attachment');
    const attachment=item.is_image&&attachmentUrl
      ? `<a class="landing-update-image" href="${safe(attachmentUrl)}" target="_blank" rel="noopener"><img src="${safe(attachmentUrl)}" alt="${safe(item.title||'Announcement image')}"></a>`
      : (attachmentUrl?`<a class="landing-update-file" href="${safe(attachmentUrl)}" target="_blank" rel="noopener"><i class="fa-solid fa-paperclip"></i> ${safe(attachmentName)}</a>`:'');
    return `<article class="landing-update-item priority-${priority}">
      <div class="landing-update-meta"><span>${safe(label)}</span><time>${safe(date)}</time></div>
      ${attachment}
      <h3>${safe(item.title||'Health center update')}</h3>
      <p>${safe(item.message||'Please review this health center update before your visit.')}</p>
      ${index===0?'<button type="button" onclick="scrollToSection(\'map-section\')">Check RHU access <i class="fa-solid fa-arrow-right"></i></button>':''}
    </article>`;
  }).join('');
}

function initializeLandingNavigation(){
  const buttons=[...document.querySelectorAll('[data-nav-target]')];
  const sections=buttons.map(button=>({button,section:document.getElementById(button.dataset.navTarget)})).filter(item=>item.section);
  let scheduled=false;
  const update=()=>{
    scheduled=false;
    const threshold=(document.getElementById('mainNavbar')?.offsetHeight||80)+120;
    let current='';
    sections.forEach(item=>{if(item.section.getBoundingClientRect().top<=threshold)current=item.section.id;});
    buttons.forEach(button=>{
      const active=button.dataset.navTarget===current;
      button.classList.toggle('is-active',active);
      if(active)button.setAttribute('aria-current','location');else button.removeAttribute('aria-current');
    });
  };
  const schedule=()=>{if(!scheduled){scheduled=true;window.requestAnimationFrame(update);}};
  window.addEventListener('scroll',schedule,{passive:true});
  window.addEventListener('resize',schedule,{passive:true});
  update();
}

async function loadLandingStatus(){
  const summary=document.getElementById('landingOpenSummary');
  const detail=document.getElementById('landingOpenDetail');
  const date=document.getElementById('landingStatusDate');
  const dots=document.getElementById('landingBranchDots');
  if(!summary||!detail||!dots)return;
  try{
    const response=await fetch('../backend/api.php?action=public_landing_status',{credentials:'same-origin',cache:'no-store'});
    const result=await response.json();
    if(!response.ok||result.ok===false)throw new Error(result.message||'Schedule unavailable');
    const open=Number(result.open_now||0),total=Number(result.total_branches||4),scheduled=Number(result.scheduled_today||0);
    summary.textContent=open>0?`${open} of ${total} RHUs open now`:(scheduled>0?'RHU schedules available today':'All RHUs are closed today');
    detail.textContent=open>0?'Choose a branch, service, and live appointment slot.':(scheduled>0?'Clinics may be outside operating hours or on break.':'Check announcements for the next available clinic day.');
    const serverDate=new Date(result.server_time||Date.now());
    if(date&&!Number.isNaN(serverDate.getTime()))date.textContent=serverDate.toLocaleDateString('en-PH',{month:'short',day:'numeric'});
    const branches=result.branches||[];
    const safe=value=>String(value??'').replace(/[&<>"']/g,character=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[character]));
    dots.innerHTML=branches.map((branch,index)=>`<article class="landing-branch-dot ${branch.open_now?'open':'closed'}"><span class="branch-name"><i></i> RHU ${['I','II','III','IV'][index]||index+1}</span><strong>${safe(branch.status||'Schedule unavailable')}</strong><small>${safe(branch.hours||'Closed')}</small></article>`).join('');
    document.querySelectorAll('[data-landing-rhu-hours]').forEach((element)=>{
      const branch=branches[Number(element.dataset.landingRhuHours)];
      if(!branch)return;
      element.innerHTML=`<i class="far fa-clock"></i> Today: ${String(branch.hours||'Closed')} · ${String(branch.status||'Schedule unavailable')}`;
    });
    const facility=result.facility||{};
    renderPublicAdvisory(result.advisories||[]);
    renderLandingUpdateBoard(result.advisories||[]);
    const facilityName=document.getElementById('landingFacilityName');
    if(facilityName&&facility.facilityName)facilityName.textContent=facility.facilityName;
    const municipality=document.getElementById('landingMunicipality');
    if(municipality&&facility.municipality)municipality.textContent=facility.municipality;
    const phone=document.getElementById('landingSupportPhone');
    if(phone&&facility.supportContact){phone.hidden=false;phone.querySelector('span').textContent=facility.supportContact;}
    const email=document.getElementById('landingSupportEmail');
    if(email&&facility.supportEmail){email.hidden=false;email.querySelector('span').textContent=facility.supportEmail;}
  }catch(error){
    summary.textContent='Four RHU branches, one portal';
    detail.textContent='Open the health-center directory for branch details and clinic hours.';
    dots.innerHTML=['I','II','III','IV'].map(label=>`<article class="landing-branch-dot open"><span class="branch-name"><i></i> RHU ${label}</span><strong>Open weekdays</strong><small>8:00 AM - 5:00 PM</small></article>`).join('');
    renderPublicAdvisory([]);
    renderLandingUpdateBoard([]);
  }
}

function initializeLandingReveals(){
  const heroItems=[...document.querySelectorAll('.hero-left > *'),document.querySelector('.hero-visual-frame')].filter(Boolean);
  const contentItems=[...document.querySelectorAll('.landing-live-board,.landing-action-shell,.visit-readiness article,.about-layout,.journey-heading,.care-journey article,.services-heading,.service-showcase .service-card,.visit-planner-shell,.priority-editorial,.locator-heading,.locator-shell,.faq-layout,.cta-section .container')];
  const items=[...heroItems,...contentItems];
  items.forEach((item)=>item.classList.add('landing-reveal'));
  if(window.matchMedia('(prefers-reduced-motion: reduce)').matches){
    items.forEach((item)=>item.classList.add('is-visible'));
    return;
  }
  document.body.classList.add('landing-motion-ready');
  heroItems.forEach((item,index)=>{
    item.classList.add(index%2?'reveal-right':'reveal-left');
    window.setTimeout(()=>item.classList.add('is-visible'),90+(index*70));
  });
  contentItems.forEach((item,index)=>{
    item.classList.add(index%3===1?'reveal-left':(index%3===2?'reveal-right':'reveal-up'));
  });
  if(!('IntersectionObserver' in window)){
    contentItems.forEach((item)=>item.classList.add('is-visible'));
    return;
  }
  const observer=new IntersectionObserver((entries)=>{
    entries.forEach((entry)=>{
      if(!entry.isIntersecting)return;
      entry.target.classList.add('is-visible');
      observer.unobserve(entry.target);
    });
  },{threshold:.12,rootMargin:'0px 0px -8% 0px'});
  contentItems.forEach((item)=>observer.observe(item));
}

function safelyInitialize(name,initializer){
  try{return initializer();}
  catch(error){console.warn(`[Landing] ${name} is temporarily unavailable.`,error);return null;}
}

function initializeFaqFallback(){
  if(window.bootstrap?.Collapse)return;
  document.querySelectorAll('.faq-accordion .accordion-button').forEach((button)=>{
    button.addEventListener('click',()=>{
      const selector=button.getAttribute('data-bs-target');
      const target=selector?document.querySelector(selector):null;
      if(!target)return;
      const accordion=target.closest('.accordion');
      const willOpen=!target.classList.contains('show');
      accordion?.querySelectorAll('.accordion-collapse.show').forEach((panel)=>{
        if(panel===target)return;
        panel.classList.remove('show');
        const otherButton=accordion.querySelector(`[data-bs-target="#${panel.id}"]`);
        otherButton?.classList.add('collapsed');
        otherButton?.setAttribute('aria-expanded','false');
      });
      target.classList.toggle('show',willOpen);
      button.classList.toggle('collapsed',!willOpen);
      button.setAttribute('aria-expanded',String(willOpen));
    });
  });
}

function initializeLandingCarousel(){
  const carousel=document.getElementById('heroCarousel');
  if(!carousel)return;

  const track=carousel.querySelector('.hero-carousel-track');
  const slides=[...carousel.querySelectorAll('.hero-slide')];
  const dots=[...carousel.querySelectorAll('.hero-carousel-dot')];
  if(!track||!slides.length)return;
  const reduceMotion=window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  let currentSlide = 0;
  let autoSlideTimer = null;
  let touchStartX = 0;

  function showSlide(index) {
    currentSlide = (index + slides.length) % slides.length;
    track.style.transform = `translateX(-${currentSlide * 100}%)`;

    slides.forEach((slide, slideIndex) => {
      slide.classList.toggle('active', slideIndex === currentSlide);
    });

    dots.forEach((dot, dotIndex) => {
      const isActive = dotIndex === currentSlide;
      dot.classList.toggle('active', isActive);
      dot.setAttribute('aria-current', isActive ? 'true' : 'false');
    });
  }

  function stopAutoSlide() {
    if (autoSlideTimer) window.clearInterval(autoSlideTimer);
    autoSlideTimer = null;
  }

  function startAutoSlide() {
    stopAutoSlide();
    if (!reduceMotion) {
      autoSlideTimer = window.setInterval(() => showSlide(currentSlide + 1), 7000);
    }
  }

  dots.forEach((dot) => {
    dot.addEventListener('click', () => {
      showSlide(Number(dot.dataset.slide));
      startAutoSlide();
    });
  });

  carousel.addEventListener('touchstart', (event) => {
    touchStartX = event.changedTouches[0].clientX;
    stopAutoSlide();
  }, { passive: true });

  carousel.addEventListener('touchend', (event) => {
    const distance = event.changedTouches[0].clientX - touchStartX;
    if (Math.abs(distance) > 45) showSlide(currentSlide + (distance < 0 ? 1 : -1));
    startAutoSlide();
  }, { passive: true });

  carousel.addEventListener('mouseenter', stopAutoSlide);
  carousel.addEventListener('mouseleave', startAutoSlide);
  carousel.addEventListener('focusin', stopAutoSlide);
  carousel.addEventListener('focusout', startAutoSlide);

  showSlide(0);
  startAutoSlide();
}

document.addEventListener('DOMContentLoaded', () => {
  let initialService='consultation';
  try{initialService=window.sessionStorage.getItem('phc-landing-service-guide')||initialService;}catch(error){}
  safelyInitialize('visit planner',()=>window.selectLandingService(initialService));
  safelyInitialize('map',initializeLandingMap);
  void loadLandingStatus().catch((error)=>console.warn('[Landing] Live RHU status is temporarily unavailable.',error));
  safelyInitialize('content motion',initializeLandingReveals);
  safelyInitialize('FAQ',initializeFaqFallback);
  safelyInitialize('photo carousel',initializeLandingCarousel);
  safelyInitialize('navigation',initializeLandingNavigation);

  document.addEventListener('click', (event) => {
    const menu = document.getElementById('mobileMenu');
    const button = document.getElementById('hamburgerBtn');
    if (menu?.classList.contains('show') && !menu.contains(event.target) && !button?.contains(event.target)) {
      window.toggleMenu();
    }
  });
  document.addEventListener('keydown',(event)=>{
    if(event.key!=='Escape')return;
    const menu=document.getElementById('mobileMenu');
    if(menu?.classList.contains('show'))window.toggleMenu();
  });
});
