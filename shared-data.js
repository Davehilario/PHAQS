/* database setup */
function getQueueData(){ return window.__HC_QUEUE_DATA__ || {}; }
function saveQueueData(data){ window.__HC_QUEUE_DATA__ = data || {}; }
function calcAvgWait(branch){ const wt=(branch&&branch.waitTimes)||[]; if(!wt.length) return '-'; return Math.round(wt.reduce((a,b)=>a+b,0)/wt.length)+' min'; }
function getRegisteredUsers(){ return window.__HC_PATIENTS__ || []; }
function saveRegisteredUsers(users){ window.__HC_PATIENTS__ = Array.isArray(users) ? users : []; }
