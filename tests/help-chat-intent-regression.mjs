import assert from 'node:assert/strict';

function intent(message){
  const text=message.toLocaleLowerCase('en').replace(/[^\p{L}\p{N}]+/gu,' ').trim();
  if(/(?:appointment|schedule|sched)\s*(?:ko|my|akin)|(?:kailan|kelan|when).*(?:appointment|schedule|sched).*(?:ko|my|akin)/u.test(text))return 'personal-appointment';
  if(['preferred date','preferred time','available date','date available','available time','time available','anong date','what date','what time available','anong oras available','available schedule','schedule available','available slot','slot available','may slot'].some(word=>text.includes(word)))return 'next-open-dates';
  if(/^(?:kailan|kelan|when)(?:\s+ang)?\s+(?:schedule|sched)$/u.test(text))return 'general-schedule';
  if(['queue number ko','number ko','pila ko','turn ko','queue ko'].some(word=>text.includes(word)))return 'queue';
  if(['clinic hours','anong oras','open ba','kailan bukas','kelan bukas','oras ng rhu','bukas'].some(word=>text.includes(word)))return 'clinic-hours';
  if(['hello','hi','magandang umaga'].some(word=>text.includes(word)))return 'greeting';
  return 'unknown';
}

assert.equal(intent('PREFERRED DATE'),'next-open-dates');
assert.equal(intent('PREFERRED TIME'),'next-open-dates');
assert.equal(intent('Kailan schedule ko?'),'personal-appointment');
assert.equal(intent('kailan sched'),'general-schedule');
assert.equal(intent('Kailan bukas ang RHU?'),'clinic-hours');
assert.equal(intent('Ano queue number ko?'),'queue');
assert.equal(intent('Hello po'),'greeting');
console.log('PASS  Help-chat simple-question intent regression fixture');
