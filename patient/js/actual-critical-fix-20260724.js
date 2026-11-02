
(function(){
  function setupForgotPassword(){
    const link=document.querySelector('a.forgot-link');
    if(!link)return;
    link.href='forgot-password.html';
    link.onclick=function(event){
      event.preventDefault();
      event.stopPropagation();
      if(event.stopImmediatePropagation)event.stopImmediatePropagation();
      window.location.href='forgot-password.html';
      return false;
    };
  }

  function setupTermsAutoClose(){
    const modalEl=document.getElementById('termsModal');
    const agree=document.getElementById('agreeTermsCheckbox');
    const main=document.getElementById('termsCheck');
    if(!modalEl||!agree||!main||!window.bootstrap)return;

    modalEl.setAttribute('data-bs-backdrop','true');
    modalEl.setAttribute('data-bs-keyboard','true');
    const modal=bootstrap.Modal.getOrCreateInstance(modalEl,{backdrop:true,keyboard:true});

    agree.addEventListener('change',function(){
      if(!agree.checked)return;
      main.checked=true;
      main.dispatchEvent(new Event('change',{bubbles:true}));
      window.setTimeout(function(){modal.hide();},120);
    },true);

    modalEl.querySelectorAll('[data-bs-dismiss="modal"]').forEach(function(button){
      button.addEventListener('click',function(){modal.hide();},true);
    });
  }

  function init(){
    setupForgotPassword();
    setupTermsAutoClose();
  }
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init,{once:true});
  else init();
})();
