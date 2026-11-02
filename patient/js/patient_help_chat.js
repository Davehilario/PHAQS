(function(){
  if(window.__patientHelpChatUnifiedLoaded)return;
  window.__patientHelpChatUnifiedLoaded=true;

  const POLL_MS=15000;
  let pollTimer=null;
  let branchInitialized=false;
  let lastFingerprint='';
  let loading=false;
  let sending=false;

  function ensureStyles(){
    if(document.getElementById('helpChatUnifiedStyles'))return;
    const link=document.createElement('link');
    link.id='helpChatUnifiedStyles';
    link.rel='stylesheet';
    link.href='css/help-chat.css?v=20260721-dashboard-chat-exact';
    document.head.appendChild(link);
  }

  function installShell(){
    ensureStyles();
    document.getElementById('hcChatPanel')?.remove();
    document.getElementById('hcChatLauncher')?.remove();
    document.getElementById('hcChatStyles')?.remove();

    let chatPanel=document.getElementById('helpChatPanel');
    if(!chatPanel){
      chatPanel=document.createElement('section');
      chatPanel.id='helpChatPanel';
      document.body.appendChild(chatPanel);
    }
    chatPanel.className='help-chat-panel';
    chatPanel.setAttribute('aria-label','RHU Help Center');
    chatPanel.innerHTML=`
      <header class="help-chat-head">
        <div class="help-chat-brand">
          <span class="help-chat-brand-icon"><i class="fa-regular fa-comments"></i></span>
          <div><strong>RHU Help Center</strong><span><i></i> Automatic answers and staff support</span></div>
        </div>
        <button class="help-chat-close" type="button" aria-label="Close help chat"><i class="fa-solid fa-xmark"></i></button>
      </header>
      <div class="help-chat-routing">
        <label for="helpChatRhuBranch">Send inquiry to</label>
        <select id="helpChatRhuBranch" aria-label="RHU branch">
          <option>RHU I - Poblacion</option><option>RHU II - Cutcot</option><option>RHU III - Tinejero</option><option>RHU IV - Tibag</option>
        </select>
      </div>
      <div class="help-chat-messages" id="helpChatMessages" aria-live="polite"><div class="help-chat-empty"><i class="fa-regular fa-comments"></i><strong>How can we help?</strong><span>Ask about RHU hours, appointments, queue status, or requirements.</span></div></div>
      <div class="help-chat-suggestions" aria-label="Suggested questions">
        <button type="button" data-chat-suggestion="Kailan bukas ang RHU?">Clinic hours</button>
        <button type="button" data-chat-suggestion="Kailan ang appointment ko?">My appointment</button>
        <button type="button" data-chat-suggestion="Ano ang queue status ko?">Queue status</button>
        <button type="button" data-chat-suggestion="Ano ang requirements?">Requirements</button>
      </div>
      <form class="help-chat-form" id="helpChatForm">
        <input id="helpChatInput" maxlength="1000" autocomplete="off" placeholder="Type your question…" required>
        <button id="helpChatSend" type="submit" aria-label="Send message"><i class="fa-solid fa-paper-plane"></i></button>
      </form>`;

    document.querySelectorAll('.chat-button,.help-chat-launcher').forEach(button=>button.remove());
    const launcher=document.createElement('button');
    launcher.id='helpChatLauncher';
    launcher.className='help-chat-launcher';
    launcher.type='button';
    launcher.setAttribute('aria-label','Open RHU Help Center');
    launcher.setAttribute('aria-expanded','false');
    launcher.innerHTML='<i class="fa-regular fa-comments"></i><span>Help</span>';
    document.body.appendChild(launcher);

    launcher.addEventListener('click',()=>window.toggleHelpChat());
    chatPanel.querySelector('.help-chat-close').addEventListener('click',()=>closeChat());
    chatPanel.querySelector('#helpChatForm').addEventListener('submit',window.sendHelpMessage);
    chatPanel.querySelectorAll('[data-chat-suggestion]').forEach(button=>button.addEventListener('click',()=>{
      const input=document.getElementById('helpChatInput');
      input.value=button.dataset.chatSuggestion||'';
      input.focus();
    }));
    document.addEventListener('keydown',event=>{if(event.key==='Escape'&&chatPanel.classList.contains('show'))closeChat()});
    document.addEventListener('visibilitychange',()=>{
      if(document.hidden)stopPolling();
      else if(chatPanel.classList.contains('show'))schedulePoll(800);
    });
  }

  const panel=()=>document.getElementById('helpChatPanel');
  const messages=()=>document.getElementById('helpChatMessages');
  const branchSelect=()=>document.getElementById('helpChatRhuBranch');
  const esc=value=>String(value??'').replace(/[&<>"']/g,char=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[char]));
  const apiCall=async(action,data=null,method='POST')=>{
    if(typeof window.api==='function')return window.api(action,data,method);
    const options={method:data===null?'GET':method,credentials:'include',cache:'no-store',headers:{}};
    if(data!==null){options.headers['Content-Type']='application/json';options.body=JSON.stringify(data)}
    const response=await fetch('../backend/api.php?action='+encodeURIComponent(action),options);
    return response.json();
  };

  function fingerprint(list){
    return (list||[]).map(item=>[item.id,item.sender_type,item.created_at,item.is_automated,item.message].join('|')).join('||');
  }

  function renderMessages(list,{forceScroll=false}={}){
    const box=messages();
    if(!box)return;
    const nearBottom=box.scrollHeight-box.scrollTop-box.clientHeight<72;
    box.innerHTML=list.length?list.map(message=>{
      const fromPatient=message.sender_type==='patient';
      const automated=Number(message.is_automated)===1;
      const role=fromPatient?'patient':(automated?'automated':'staff');
      const label=automated?'<span class="help-auto-tag"><i class="fa-solid fa-bolt"></i> Instant answer</span>':'';
      return `<article class="help-msg ${role}">${label}<p>${esc(message.message)}</p><small>${esc(message.name)} · ${esc(message.created_at)}</small></article>`;
    }).join(''):'<div class="help-chat-empty"><i class="fa-regular fa-comments"></i><strong>How can we help?</strong><span>Ask about RHU hours, appointments, queue status, or requirements.</span></div>';
    if(forceScroll||nearBottom)requestAnimationFrame(()=>{box.scrollTop=box.scrollHeight});
  }

  async function loadChat({force=false,forceScroll=false}={}){
    if(loading)return;
    loading=true;
    try{
      const result=await apiCall('chat_messages',null,'GET');
      if(!result.ok)return;
      const select=branchSelect();
      if(select&&!branchInitialized){
        if(Array.isArray(result.branches)&&result.branches.length)select.innerHTML=result.branches.map(branch=>`<option>${esc(branch)}</option>`).join('');
        select.value=result.rhu_branch||select.value;
        branchInitialized=true;
      }
      const list=Array.isArray(result.messages)?result.messages:[];
      const nextFingerprint=fingerprint(list);
      if(force||nextFingerprint!==lastFingerprint){
        renderMessages(list,{forceScroll});
        lastFingerprint=nextFingerprint;
      }
    }catch(_){

    }finally{loading=false}
  }

  function stopPolling(){if(pollTimer)clearTimeout(pollTimer);pollTimer=null}
  function schedulePoll(delay=POLL_MS){
    stopPolling();
    pollTimer=setTimeout(async()=>{
      if(panel()?.classList.contains('show')&&!document.hidden){await loadChat();schedulePoll()}
    },delay);
  }
  function closeChat(){
    panel()?.classList.remove('show');
    document.getElementById('helpChatLauncher')?.setAttribute('aria-expanded','false');
    stopPolling();
  }

  window.toggleHelpChat=async function(){
    const chatPanel=panel();
    if(!chatPanel)return;
    const opening=!chatPanel.classList.contains('show');
    chatPanel.classList.toggle('show',opening);
    document.getElementById('helpChatLauncher')?.setAttribute('aria-expanded',String(opening));
    if(opening){await loadChat({force:true,forceScroll:true});schedulePoll();document.getElementById('helpChatInput')?.focus()}
    else stopPolling();
  };

  window.sendHelpMessage=async function(event){
    event?.preventDefault();
    if(sending)return;
    const input=document.getElementById('helpChatInput');
    const button=document.getElementById('helpChatSend');
    const text=String(input?.value||'').trim();
    if(!text)return;
    sending=true;
    if(button){button.disabled=true;button.classList.add('sending')}
    try{
      const result=await apiCall('chat_send',{message:text,rhu_branch:branchSelect()?.value||'RHU I - Poblacion'});
      if(result.ok){input.value='';lastFingerprint='';await loadChat({force:true,forceScroll:true})}
      else if(typeof window.showPlainAlert==='function')window.showPlainAlert(result.message||'Unable to send message.');
    }catch(_){if(typeof window.showPlainAlert==='function')window.showPlainAlert('Unable to send message. Please check your connection.')}
    finally{sending=false;if(button){button.disabled=false;button.classList.remove('sending')}input?.focus();schedulePoll()}
  };

  installShell();
})();
