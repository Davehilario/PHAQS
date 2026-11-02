(function(){
  function closeSidebar(){document.body.classList.remove('sidebar-open');document.querySelectorAll('.sidebar').forEach(s=>s.classList.remove('open','show'));}
  document.addEventListener('click',function(e){
    const btn=e.target.closest('.hamburger-btn,.mobile-menu-btn,[data-sidebar-toggle]');
    if(btn){e.preventDefault();document.body.classList.toggle('sidebar-open');const s=document.querySelector('.sidebar');if(s)s.classList.toggle('open');return;}
    if(innerWidth<=768 && e.target.closest('.sidebar a')) closeSidebar();
  });
  addEventListener('resize',()=>{if(innerWidth>768)closeSidebar();});
})();
