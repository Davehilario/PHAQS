(function(){
  'use strict';
  const MAX_SOURCE=5*1024*1024;
  function initials(name){return String(name||'Patient').trim().split(/\s+/).map(x=>x[0]).slice(0,2).join('').toUpperCase()||'P'}
  function validPhoto(v){return typeof v==='string'&&(/^data:image\/(jpeg|jpg|png|webp);base64,/i.test(v)||/^blob:/i.test(v)||/^https?:\/\//i.test(v))&&v.length<2500000}
  function applyOne(el,photo,name){
    if(!el)return;
    el.querySelectorAll('img.patient-avatar-photo').forEach(img=>img.remove());
    el.style.removeProperty('background-image');
    if(validPhoto(photo)){
      el.classList.add('has-photo');
      el.textContent='';
      const img=document.createElement('img');
      img.className='patient-avatar-photo';
      img.alt=(name||'Patient')+' profile photo';
      img.decoding='async';
      img.onload=()=>el.classList.add('photo-loaded');
      img.onerror=()=>{
        img.remove();
        el.classList.remove('has-photo','photo-loaded');
        el.textContent=initials(name);
      };
      img.src=photo;
      el.appendChild(img);
      el.setAttribute('aria-label',img.alt);
    }else{
      el.classList.remove('has-photo','photo-loaded');
      el.textContent=initials(name);
    }
  }
  function applyPhoto(photo,name){document.querySelectorAll('#avatarBtn,#mobAvatar,#avatarBig').forEach(el=>applyOne(el,photo,name));}
  async function me(){try{const r=await fetch('../backend/api.php?action=patient_me',{credentials:'include',cache:'no-store'});return await r.json()}catch(_){return {ok:false}}}
  function resize(file){return new Promise((resolve,reject)=>{const reader=new FileReader();reader.onerror=()=>reject(new Error('Unable to read the selected image.'));reader.onload=()=>{const img=new Image();img.onerror=()=>reject(new Error('The selected image could not be opened.'));img.onload=()=>{const side=Math.min(img.naturalWidth,img.naturalHeight),sx=(img.naturalWidth-side)/2,sy=(img.naturalHeight-side)/2;const c=document.createElement('canvas');c.width=360;c.height=360;const ctx=c.getContext('2d');ctx.fillStyle='#ffffff';ctx.fillRect(0,0,c.width,c.height);ctx.drawImage(img,sx,sy,side,side,0,0,360,360);resolve(c.toDataURL('image/jpeg',.76))};img.src=reader.result};reader.readAsDataURL(file)})}
  function addUploader(patient){const big=document.getElementById('avatarBig');if(!big||document.getElementById('patientProfilePhotoInput'))return;const wrap=document.createElement('div');wrap.className='profile-photo-actions';wrap.innerHTML='<input id="patientProfilePhotoInput" type="file" accept="image/jpeg,image/png,image/webp" hidden><button type="button" class="profile-photo-btn primary" id="patientProfilePhotoChoose"><i class="fas fa-camera"></i> Change photo</button><button type="button" class="profile-photo-btn danger" id="patientProfilePhotoRemove"><i class="fas fa-trash"></i> Remove</button><span class="profile-photo-note">Clear face photo only. JPEG, PNG or WebP, up to 5 MB.</span>';
    const info=big.closest('.profile-header-top')?.querySelector('.profile-header-info');(info||big.parentElement).appendChild(wrap);
    const input=wrap.querySelector('input'),choose=wrap.querySelector('#patientProfilePhotoChoose'),remove=wrap.querySelector('#patientProfilePhotoRemove');choose.onclick=()=>input.click();
    async function savePhoto(photo){const latest=(await me()).patient||patient||{};const payload=(typeof window.collectProfileData==='function'?window.collectProfileData():{...latest});Object.assign(payload,latest,{profilePhoto:photo,profile_picture:photo});const res=await fetch('../backend/api.php?action=profile_save',{method:'POST',credentials:'include',headers:{'Content-Type':'application/json'},body:JSON.stringify(payload)});const out=await res.json();if(!out.ok)throw new Error(out.message||'Unable to save photo.');patient=out.patient||payload;const saved=patient.profilePhoto||patient.profile_picture||photo;applyPhoto(saved,patient.name);window.dispatchEvent(new CustomEvent('patient-photo-updated',{detail:{photo:saved,name:patient.name}}));return out}
    input.onchange=async()=>{const f=input.files?.[0];if(!f)return;if(!/^image\/(jpeg|png|webp)$/i.test(f.type)||f.size>MAX_SOURCE){alert('Choose a JPEG, PNG or WebP image that is 5 MB or smaller.');input.value='';return}choose.disabled=true;choose.innerHTML='<i class="fas fa-spinner fa-spin"></i> Saving...';try{const photo=await resize(f);applyPhoto(photo,patient.name);await savePhoto(photo)}catch(e){applyPhoto(patient.profilePhoto||patient.profile_picture||'',patient.name);alert(e.message||'Unable to save photo.')}finally{choose.disabled=false;choose.innerHTML='<i class="fas fa-camera"></i> Change photo';input.value=''}};
    remove.onclick=async()=>{const approved=window.phaqsConfirm?await window.phaqsConfirm('Your photo will be removed and your initials will be shown instead.',{title:'Remove profile photo?',confirmText:'Remove photo',danger:true}):confirm('Remove your profile photo? Staff will see your initials instead.');if(!approved)return;remove.disabled=true;try{await savePhoto('')}catch(e){alert(e.message||'Unable to remove photo.')}finally{remove.disabled=false}};
  }
  async function init(){const r=await me();if(!r.ok)return;const p=r.patient||{},name=p.name||`${p.firstName||''} ${p.lastName||''}`.trim()||'Patient';applyPhoto(p.profilePhoto||p.profile_picture||'',name);addUploader(p)}
  window.hcApplyPatientPhoto=applyPhoto;
  window.addEventListener('patient-photo-updated',e=>applyPhoto(e.detail?.photo||'',e.detail?.name||'Patient'));
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init();
})();
