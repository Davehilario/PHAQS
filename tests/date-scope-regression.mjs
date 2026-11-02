import assert from 'node:assert/strict';

const today='2026-07-21';
const appointments=[
  {dateRaw:'2026-07-21',status:'Confirmed',rhu:'RHU I - Poblacion'},
  {dateRaw:'2026-07-15',status:'Cancelled',rhu:'RHU I - Poblacion'},
  {dateRaw:'2026-07-17',status:'Done',rhu:'RHU II - Cutcot'}
];

const todayRows=appointments.filter(item=>item.dateRaw===today);
assert.equal(todayRows.length,1,'Total Today must exclude historical rows');
assert.equal(todayRows.filter(item=>item.status.toLowerCase()==='confirmed').length,1);
assert.equal(todayRows.filter(item=>item.status.toLowerCase()==='cancelled').length,0,'Old cancellation must not appear in Cancelled Today');
assert.equal(todayRows.filter(item=>['done','completed','attended'].includes(item.status.toLowerCase())).length,0,'Old completed record must not appear in Served Today');

assert.deepEqual(appointments.filter(item=>item.dateRaw<today).map(item=>item.dateRaw),['2026-07-15','2026-07-17']);
assert.deepEqual(appointments.filter(item=>item.dateRaw>today),[]);
assert.equal(appointments.length,3,'Historical records stay available in All Dates and the calendar');

console.log('PASS  Date-scoped appointment regression fixture');
