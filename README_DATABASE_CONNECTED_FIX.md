# Health Center System - Database Connected Fix

This build removes static/demo browser data and connects patient/admin business data to MySQL through `backend/api.php`.

## What changed
- Removed hardcoded queue/patient demo data from shared browser layer.
- Removed browser localStorage business-data usage from patient and admin modules.
- Patient dashboard, appointments, booking, profile, QR, and queue now load from database APIs.
- Admin dashboard, appointments, patients, queue, reports, users, audit/logs, archive, backup, and heatmap use database/API data.
- Admin login now uses `admins` table only.
- Admin user management now creates/updates/deletes records in `admins` table.
- Queue actions update `appointments` table and are visible to patient/admin pages.
- Reports and disease trends calculate from current appointment records.

## XAMPP
1. Extract folder under `C:\xampp\htdocs\`.
2. Start Apache and MySQL.
3. Visit `http://localhost/<folder-name>/`.

## Verified credentials from database seed
Default credentials are no longer distributed. Create the first administrator with `backend/create_admin.php`; patients register through the portal.

## Validation run
- PHP lint passed.
- JS file syntax passed.
- Inline HTML script syntax passed.
- Local link/image scan passed.
- Search confirmed no `localStorage`, static demo names, or default queue/user demo arrays remain in admin/patient business code.
