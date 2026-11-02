
(function(){
  'use strict';

  function forgotTarget(){
    return new URL('./forgot-password.html', window.location.href).href;
  }

  function openForgotPassword(event){
    if(event){
      event.preventDefault();
      event.stopPropagation();
      if(typeof event.stopImmediatePropagation==='function') event.stopImmediatePropagation();
    }
    window.location.assign(forgotTarget());
    return false;
  }

  function setupForgotPassword(){
    const link=document.querySelector('[data-forgot-password-link], a.forgot-link');
    if(!link) return;
    link.setAttribute('href','./forgot-password.html');
    link.setAttribute('id','forgotPasswordLink');
    link.setAttribute('data-forgot-password-link','true');
    link.onclick=openForgotPassword;
    link.addEventListener('click',openForgotPassword,true);
    link.addEventListener('pointerup',function(event){
      if(event.pointerType==='touch') openForgotPassword(event);
    },true);
    link.addEventListener('keydown',function(event){
      if(event.key==='Enter'||event.key===' '){ openForgotPassword(event); }
    },true);
  }

  function removeBootstrapArtifacts(modalEl){
    modalEl.classList.remove('show');
    modalEl.style.display='none';
    modalEl.setAttribute('aria-hidden','true');
    modalEl.removeAttribute('aria-modal');
    document.body.classList.remove('modal-open');
    document.body.style.removeProperty('overflow');
    document.body.style.removeProperty('padding-right');
    document.querySelectorAll('.modal-backdrop').forEach(function(node){node.remove();});
  }

  function hideTermsModal(modalEl){
    try{
      if(window.bootstrap && window.bootstrap.Modal){
        const instance=window.bootstrap.Modal.getOrCreateInstance(modalEl,{backdrop:true,keyboard:true});
        instance.hide();
      }
    }catch(_){ }
    window.setTimeout(function(){removeBootstrapArtifacts(modalEl);},180);
  }

  function setupTerms(){
    const modalEl=document.getElementById('termsModal');
    const agree=document.getElementById('agreeTermsCheckbox');
    const main=document.getElementById('termsCheck');
    if(!modalEl||!agree||!main) return;

    modalEl.setAttribute('data-bs-backdrop','true');
    modalEl.setAttribute('data-bs-keyboard','true');

    function acceptAndClose(event){
      if(event && event.type==='click' && !agree.checked) return;
      if(!agree.checked) return;
      main.checked=true;
      main.dispatchEvent(new Event('input',{bubbles:true}));
      main.dispatchEvent(new Event('change',{bubbles:true}));
      hideTermsModal(modalEl);
    }

    agree.onchange=acceptAndClose;
    agree.addEventListener('change',acceptAndClose,true);
    agree.addEventListener('click',function(){
      if(agree.checked) window.setTimeout(function(){acceptAndClose();},0);
    },true);

    modalEl.querySelectorAll('[data-bs-dismiss="modal"], .terms-back-btn').forEach(function(button){
      button.addEventListener('click',function(event){
        event.preventDefault();
        hideTermsModal(modalEl);
      },true);
    });

    document.addEventListener('keydown',function(event){
      if(event.key==='Escape' && (modalEl.classList.contains('show')||modalEl.style.display==='block')){
        hideTermsModal(modalEl);
      }
    });
  }

  function init(){
    setupForgotPassword();
    setupTerms();
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',init,{once:true});
  else init();
})();
