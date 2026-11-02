Deployment guide — XAMPP (Windows)

This repository is ready to run on XAMPP/Apache + MySQL. Follow the steps below to deploy the site at `http://localhost/`.

1) Extract the ZIP into `C:\xampp\htdocs\` so the project folder path is for example:
   C:\xampp\htdocs\health-center-system-backend-queue-working-v8-patient-session-fixed

2) Create a local config override (recommended):
   - Copy `backend/config.local.example.php` to `backend/config.local.php` on the server.
   - Edit values inside `backend/config.local.php` to match your MySQL credentials and SMTP settings.

   Alternatively, you may create a `.env` file at the project root from `.env.example` and set environment variables in Apache config.

3) Start XAMPP and enable Apache and MySQL.

4) Import the database schema (no predictable accounts are seeded):
   - Open `phpMyAdmin` or use the MySQL CLI and import `backend/database.sql`.

   CLI example:

   ```bash
   cd C:\xampp\mysql\bin
   mysql -u root -p < "C:\xampp\htdocs\health-center-system-backend-queue-working-v8-patient-session-fixed\backend\database.sql"
   ```

5) Create an admin account (recommended) using the helper script:
   - From CLI:
     ```bash
     cd C:\xampp\htdocs\health-center-system-backend-queue-working-v8-patient-session-fixed\backend
     php create_admin.php admin@example.com "Admin Name" strongpassword
     ```
   - Or open in a browser once (then delete the file):
     `http://localhost/health-center-system-backend-queue-working-v8-patient-session-fixed/backend/create_admin.php`

   IMPORTANT: Delete `backend/create_admin.php` after you finish creating the admin account.

6) Access the site:
   - Patient area: `http://localhost/health-center-system-backend-queue-working-v8-patient-session-fixed/patient/login.html`
   - Admin area: `http://localhost/health-center-system-backend-queue-working-v8-patient-session-fixed/admin/admin-login.html`

7) SMTP / Password reset (optional):
   - Configure SMTP settings in `backend/config.local.php` or environment variables.
   - Use a real SMTP account. If using Gmail, enable App Passwords or use a dedicated SMTP service.

8) Production notes:
   - Do NOT keep `config.local.php` or other secrets in source control.
   - Remove `create_admin.php` after use.
   - Secure your server and enable HTTPS in production.

If you want, I can now:
- Prepare a ZIP of the repository with the above changes (no secrets inside), or
- Attempt to run import & basic smoke-tests here (I will need DB credentials or permission to create local DB). 

Tell me which you prefer and whether to create a default admin for you in the ZIP or leave creation to you.
