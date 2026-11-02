# Operations & Compliance upgrade

The System Administrator can open **Operations & Compliance** from the admin sidebar.

## Included controls

- Per-RHU Sunday-to-Saturday opening hours, breaks, and 15/20/30/60-minute slot intervals.
- Default branch capacity plus service-specific capacity overrides.
- All-branch, per-branch, all-service, or per-service holiday, emergency, maintenance, and special-event closures.
- Booking transactions with slot locks and atomic queue-number sequences for simultaneous patient submissions.
- Transaction-locked `Call Next` behavior for simultaneous staff sessions.
- Email, SMS, and in-app delivery status monitoring with masked recipients and redacted error summaries in the UI.
- Versioned privacy policies, exact-version consent, withdrawal, retention-review counts, and patient-visible access history.
- Supporting-document upload and RHU verification for minor, senior-citizen, and PWD caregiver relationships.
- Expanded database backup coverage for operational, privacy, caregiver, chat, announcement, and communication records.

## Deployment notes

1. On the XAMPP laptop, open `http://localhost/health-center-system/setup.php` and click **Run Safe Upgrade**. The page is blocked from phones and remote computers.
2. The setup page preserves existing administrators, patients, appointments, and chat records. It shows the first-administrator form only when zero administrators exist.
3. If custom MySQL credentials are required, the same local setup page can test and save them into the private `backend/config.local.php` file.
4. Never include a real `backend/config.local.php` in a shared ZIP or repository. The distributed ZIP contains only the example file.
5. The database account needs migration privileges while running the setup upgrade; reduce its privileges after setup on a production server.
6. Existing patients must accept the current policy version before booking or approving protected Family Care actions.
7. Retention candidates are review-only. The system does not automatically delete health or audit records.
8. Caregiver documents are limited to 5 MB and JPG, PNG, WEBP, or PDF. Direct web access is denied; administrators view them through an authenticated endpoint.
9. Use HTTPS for deployed camera scanning, browser notifications, and PWA installation.
10. `backend/create_admin.php` is retained only as an advanced CLI fallback. Demo accounts remain disabled unless `ALLOW_DEMO_ACCOUNTS=1` is explicitly set.
