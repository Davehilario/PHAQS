const selectedAppointmentId = sessionStorage.getItem('selectedAppointmentId');

document.addEventListener('DOMContentLoaded', async()=>{
  const patient=await loadPatientNav();
  const wrap=document.querySelector('.qr-card');
  let result=await api('patient_qr_ticket',{appointment_id:Number(selectedAppointmentId||0)},'POST');
  if(result.ok&&result.token){try{localStorage.setItem('phc_qr_ticket',JSON.stringify({...result,savedAt:Date.now()}))}catch(_){}}
  if(!result.ok&&!navigator.onLine){try{const saved=JSON.parse(localStorage.getItem('phc_qr_ticket')||'null');if(saved?.token&&new Date(String(saved.expires_at).replace(' ','T')).getTime()>Date.now())result=saved}catch(_){}}
  if(!result.ok||!result.token){
    if(wrap)wrap.innerHTML=`<div class="empty-state" style="padding:36px 18px"><i class="fas fa-qrcode" style="font-size:36px;color:#94a3b8"></i><h3>No active QR pass</h3><p>${esc(result.message||'QR code appears after booking.')}</p></div>`;
    return;
  }
  if(typeof qrcode!=='function'){
    document.getElementById('qrImage').innerHTML='<p>QR renderer is unavailable. Reload this page.</p>';
    return;
  }
  const ticket=result.appointment||{};
  const qr=qrcode(0,'M');qr.addData(result.token);qr.make();
  document.getElementById('qrImage').innerHTML=qr.createImgTag(5,8);
  const generatedQrImage = document.querySelector('#qrImage img');
  if (generatedQrImage) {
    generatedQrImage.alt = 'Appointment QR code';
    generatedQrImage.setAttribute('crossorigin', 'anonymous');
  }
  const printButton = document.getElementById('printQrBtn');
  if (printButton) {
    printButton.disabled = false;
    printButton.title = 'Print the QR appointment pass only';
  }
  setText('qrQueueNum',ticket.queue_number||ticket.queue||'--');
  setText('qrService',ticket.service||'Health Center Service');
  setText('qrCenter',ticket.center||ticket.rhu||'--');
  setText('qrDate',fmtDate(ticket.appointment_date||ticket.date));
  setText('qrTime',ticket.appointment_time||ticket.time||'--');
  setText('qrPatient',ticket.patient||patient?.name||'Patient');
  const expiry=document.getElementById('qrExpiry');
  if(expiry)expiry.textContent=`${navigator.onLine?'One-time pass':'Offline saved pass'} • Expires ${new Date(String(result.expires_at).replace(' ','T')).toLocaleString('en-PH')}`;
});

function setText(id,value){const element=document.getElementById(id);if(element)element.textContent=value||'--'}


function printAppointmentPass() {
  const printButton = document.getElementById('printQrBtn');
  const qrImage = document.querySelector('#qrImage img');

  if (!qrImage || !qrImage.src) {
    showQrPrintNotice('QR code is still loading. Please try again in a moment.');
    return;
  }

  const text = (id, fallback = '--') => {
    const element = document.getElementById(id);
    const value = String(element?.textContent || '').trim();
    return value && value !== '-' ? value : fallback;
  };
  const escapeHtml = (value) => String(value).replace(/[&<>'"]/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;'
  }[character]));

  if (printButton) {
    printButton.disabled = true;
    printButton.classList.add('is-printing');
    printButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Preparing...';
  }

  const oldFrame = document.getElementById('qrPrintFrame');
  if (oldFrame) oldFrame.remove();

  const frame = document.createElement('iframe');
  frame.id = 'qrPrintFrame';
  frame.setAttribute('title', 'QR print document');
  frame.style.cssText = 'position:fixed;width:1px;height:1px;right:0;bottom:0;border:0;opacity:0;pointer-events:none;';
  document.body.appendChild(frame);

  const qrSource = qrImage.currentSrc || qrImage.src;
  const html = `<!doctype html>
<html><head><meta charset="utf-8"><title>Appointment QR Pass</title>
<style>
@page{size:A4 portrait;margin:14mm}
*{box-sizing:border-box}html,body{margin:0;background:#fff;color:#14213d;font-family:Arial,Helvetica,sans-serif}
.sheet{width:100%;max-width:680px;margin:0 auto;padding:8px}.pass{border:1.5px solid #cbd5e1;border-radius:16px;overflow:hidden;break-inside:avoid}
.head{background:#173f8f!important;color:#fff!important;padding:22px 26px;display:flex;align-items:center;gap:14px;-webkit-print-color-adjust:exact;print-color-adjust:exact}
.mark{width:46px;height:46px;border:1px solid rgba(255,255,255,.45);border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:17px;font-weight:800}
.org{font-size:10px;letter-spacing:.13em;text-transform:uppercase;color:#dbeafe;margin-bottom:4px}.title{font-size:22px;font-weight:800}.body{padding:26px}
.status{display:inline-block;background:#dcfce7!important;color:#166534!important;border-radius:999px;padding:5px 12px;font-size:12px;font-weight:700;margin-bottom:16px;-webkit-print-color-adjust:exact;print-color-adjust:exact}
.qr{text-align:center;margin:2px auto 16px}.qr img{width:220px;height:220px;image-rendering:pixelated;display:block;margin:auto}.ref{text-align:center;font-size:30px;font-weight:800;color:#173f8f;margin:4px 0}.service{text-align:center;font-size:14px;font-weight:700;margin-bottom:22px}
.grid{display:grid;grid-template-columns:1fr 1fr;border-top:1px solid #e2e8f0;border-left:1px solid #e2e8f0}.item{padding:14px;border-right:1px solid #e2e8f0;border-bottom:1px solid #e2e8f0}.label{font-size:10px;text-transform:uppercase;letter-spacing:.08em;color:#64748b;font-weight:700;margin-bottom:5px}.value{font-size:14px;font-weight:700;color:#0f172a}.note{margin-top:18px;padding:13px 15px;background:#f8fafc!important;border:1px solid #dbe3ef;border-radius:10px;font-size:11.5px;line-height:1.5;color:#334155;-webkit-print-color-adjust:exact;print-color-adjust:exact}.footer{text-align:center;font-size:10px;color:#64748b;margin-top:12px}
</style></head><body><div class="sheet"><div class="pass"><div class="head"><div class="mark">PHC</div><div><div class="org">Pulilan Health Center</div><div class="title">Appointment QR Pass</div></div></div><div class="body"><div class="status">Confirmed Appointment</div><div class="qr"><img id="printQr" src="${qrSource}" alt="Appointment QR code"></div><div class="ref">${escapeHtml(text('qrQueueNum', 'Appointment Pass'))}</div><div class="service">${escapeHtml(text('qrService', 'Health Center Service'))}</div><div class="grid"><div class="item"><div class="label">Health Center</div><div class="value">${escapeHtml(text('qrCenter'))}</div></div><div class="item"><div class="label">Date</div><div class="value">${escapeHtml(text('qrDate'))}</div></div><div class="item"><div class="label">Time</div><div class="value">${escapeHtml(text('qrTime'))}</div></div><div class="item"><div class="label">Patient</div><div class="value">${escapeHtml(text('qrPatient'))}</div></div></div><div class="note">Present this QR pass to the health-center staff upon arrival. The QR code is unique to this appointment and is used for arrival verification.</div></div></div><div class="footer">Pulilan Health Center Appointment and Queueing System</div></div></body></html>`;

  const restoreButton = () => {
    if (printButton) {
      printButton.disabled = false;
      printButton.classList.remove('is-printing');
      printButton.innerHTML = '<i class="fas fa-print"></i> Print QR Pass';
    }
  };

  try {
    const doc = frame.contentWindow.document;
    doc.open();
    doc.write(html);
    doc.close();

    const doPrint = () => {
      try {
        frame.contentWindow.focus();
        frame.contentWindow.print();
      } catch (error) {
        console.error('QR print failed:', error);
        showQrPrintNotice('Printing could not start. Please try again.');
      } finally {
        restoreButton();
        setTimeout(() => frame.remove(), 1500);
      }
    };

    const printImage = doc.getElementById('printQr');
    if (printImage && printImage.complete && printImage.naturalWidth > 0) {
      setTimeout(doPrint, 150);
    } else if (printImage) {
      printImage.onload = () => setTimeout(doPrint, 150);
      printImage.onerror = () => {
        restoreButton();
        frame.remove();
        showQrPrintNotice('QR image could not be prepared for printing. Reload the page and try again.');
      };
    } else {
      restoreButton();
      frame.remove();
      showQrPrintNotice('QR image could not be prepared for printing.');
    }
  } catch (error) {
    console.error('QR print preparation failed:', error);
    restoreButton();
    frame.remove();
    showQrPrintNotice('Printing could not be prepared. Please try again.');
  }
}

function showQrPrintNotice(message) {
  let notice = document.getElementById('qrPrintNotice');
  if (!notice) {
    notice = document.createElement('div');
    notice.id = 'qrPrintNotice';
    notice.setAttribute('role', 'status');
    notice.style.cssText = 'position:fixed;right:22px;bottom:22px;z-index:99999;max-width:360px;padding:14px 16px;border-radius:12px;background:#0f2f68;color:#fff;box-shadow:0 12px 30px rgba(15,47,104,.28);font:600 13px/1.45 Arial,sans-serif;opacity:0;transform:translateY(10px);transition:.2s ease';
    document.body.appendChild(notice);
  }
  notice.textContent = message;
  notice.style.opacity = '1';
  notice.style.transform = 'translateY(0)';
  clearTimeout(window.__qrPrintNoticeTimer);
  window.__qrPrintNoticeTimer = setTimeout(() => {
    notice.style.opacity = '0';
    notice.style.transform = 'translateY(10px)';
  }, 3500);
}


document.addEventListener('DOMContentLoaded', () => {
  const printButton = document.getElementById('printQrBtn');
  if (printButton) {
    printButton.disabled = false;
    printButton.title = 'Print the QR appointment pass only';
  }
});
