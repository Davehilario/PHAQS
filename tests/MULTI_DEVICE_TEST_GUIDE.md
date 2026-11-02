# Multi-device end-to-end acceptance test

Use a disposable database first. Do not run concurrency tests against real patient appointments.

## Test setup

- Laptop/PC 1: RHU staff account A, Queue Management page.
- Laptop/PC 2 or incognito browser: RHU staff account B assigned to the same RHU.
- Patient phone: connected to the same network using the laptop's LAN IP, not `localhost`.
- TV: connected as an extended display (`Win + P` → `Extend`) with `tv-display.html` full-screen.
- Deployment test: use HTTPS for phone camera, browser notifications, and installable PWA behavior.

## Required scenarios

1. In **Operations & Compliance**, change one branch's clinic hours and a service capacity. Confirm the patient booking page immediately shows only those slots and the configured capacity.
2. Create a future holiday closure. Confirm the selected date shows no slots. Cancel the closure and confirm slots return.
3. Activate an emergency closure for one RHU. Confirm other branches remain bookable.
4. On two patient sessions, submit the same service/date/time at the same moment. Both queue numbers must be unique, and capacity must never be exceeded.
5. Mark both test patients Arrived. On two staff devices, press **Call Next Patient** at the same moment. Exactly one patient must be `Serving`; the other remains waiting.
6. Confirm the phone Queue Status and TV display show the same current queue within the polling delay.
7. Stop or misconfigure the test email provider. Trigger an appointment update and confirm **Delivery Health** records `Failed` or `Skipped` without exposing the credential.
8. Register a test patient after reviewing the current policy. Confirm the policy version and acceptance appear in the patient's **Privacy & Access History** page.
9. Open that patient's record as an administrator. Confirm a new access-history entry names the actor, action, purpose, RHU, and time.
10. Request caregiver access for a minor/senior/PWD. Verify that no booking is allowed until both patient consent and RHU document verification are complete. Reject a second request and confirm the rejection is shown.
11. Put the patient phone offline. Confirm cached appointments/queue/QR remain read-only and that booking or caregiver-document uploads are blocked.
12. Test at widths 360 px, 390 px, 768 px, 1024 px, and desktop. No horizontal page overflow should hide required actions.

## Automated concurrency runner

From the project folder, set the environment variables documented at the top of `xampp-multi-session-e2e.mjs`, then run:

```powershell
$env:ALLOW_MUTATION_TEST="YES"
node tests/xampp-multi-session-e2e.mjs
```

The runner creates two concurrent bookings, verifies distinct queue numbers, simulates two staff sessions pressing Call Next, checks the TV API, and marks the test appointments Cancelled afterward.
