# PHAQS — Pulilan Health Center Appointment & Queue System

A web-based appointment booking and queue management system for Rural Health Units (RHUs). Patients book appointments, track their queue position, and communicate with their RHU. Staff and administrators manage schedules, queues, announcements, reports, and disease trends from a single platform.

> **Stack:** HTML / CSS / JavaScript front end · PHP back end · MySQL database · Apache (XAMPP)

---

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Installation (XAMPP on Windows)](#installation-xampp-on-windows)
- [Configuration](#configuration)
- [Accessing the System](#accessing-the-system)
- [Security Notes](#security-notes)
- [Documentation](#documentation)
- [Testing](#testing)
- [Production Deployment](#production-deployment)
- [License](#license)

---

## Features

### Patient Portal
- Appointment booking, cancellation, and consent management
- Live queue tracking with an alert when 3 or fewer people remain ahead
- One-time **QR arrival pass** for check-in
- **Family & Caregiver access**: caregivers request access to a dependent's account; the dependent must approve, and either side can revoke
- **Offline / low-data mode**: installable PWA that caches the app shell and the latest appointment, queue snapshot, and unexpired QR pass (read-only while offline; cleared on logout)
- **Help Center** with an immediate, clearly labeled automated reply, plus staff follow-up in the same thread (emergency keywords trigger a call-911 / nearest-facility warning)

### Staff & Admin
- Queue management with transaction-locked **Call Next** for simultaneous staff sessions
- QR scanner (camera or manual fallback) with server-side checks for expiry, date, one-time use, and RHU assignment
- **Emergency broadcast & reach analytics** with Normal / Important / Urgent priority, RHU and barangay targeting, scheduling, attachments, and read/reach metrics
- **Barangay disease early-warning**: compares the latest 7 days against the previous 4-week average, shown as aggregated barangay totals only (no patient identities)
- Reports and heatmap views
- TV queue display (`tv-display.html`)

### Operations & Compliance (System Administrator)
- Per-RHU opening hours, breaks, and 15/20/30/60-minute slot intervals
- Default and service-specific capacity limits
- Holiday, emergency, maintenance, and special-event closures (all branches, per branch, per service)
- Slot locks and atomic queue-number sequences for concurrent bookings
- Email, SMS, and in-app delivery status monitoring (masked recipients, redacted errors)
- Versioned privacy policies, exact-version consent, withdrawal, and patient-visible access history
- Review-only retention candidates (no automatic deletion of health or audit records)
- Caregiver supporting-document upload and RHU verification (max 5 MB; JPG, PNG, WEBP, PDF)
- Expanded database backup coverage

---

## Project Structure

```
PHAQS-/
├── admin/                  # Admin and staff pages
├── patient/                # Patient portal pages
├── backend/                # PHP API, database.sql, config, helper scripts
├── assets/                 # Images and static assets
├── tests/                  # Test files
├── index.html              # Landing page
├── setup.php / setup.css   # Local setup & safe-upgrade wizard
├── tv-display.html         # Waiting-room queue display
├── shared-data.js          # Shared front-end data
├── ui-utils.js             # UI helpers
├── theme-*.css / .js       # Light/dark theming
├── responsive-all-pages.*  # Responsive layout styles and scripts
├── .env.example            # Environment variable template
├── INNOVATION_FEATURES.md
├── OPERATIONS_AND_COMPLIANCE.md
├── README_DEPLOY.md
├── QA-CM-TEST-CASES.md
└── Pulilan_Health_Center_User_Manual.docx
```

---

## Requirements

- [XAMPP](https://www.apachefriends.org/) (Apache + MySQL/MariaDB + PHP)
- A modern browser (Chrome, Edge, Firefox, Safari)
- An SMTP account (optional, for password reset and email notifications)
- **HTTPS** in deployment (needed for camera scanning, browser notifications, and PWA install; `localhost` works for development)

---

## Installation (XAMPP on Windows)

1. **Clone or extract** the project into `C:\xampp\htdocs\`:
   ```bash
   cd C:\xampp\htdocs
   git clone https://github.com/CharishArtiaga/PHAQS-.git
   ```
2. **Start Apache and MySQL** from the XAMPP Control Panel.
3. **Configure the database and SMTP** (see [Configuration](#configuration)).
4. **Import the schema.** In phpMyAdmin, import `backend/database.sql`, or use the CLI:
   ```bash
   cd C:\xampp\mysql\bin
   mysql -u root -p < "C:\xampp\htdocs\PHAQS-\backend\database.sql"
   ```
   No predictable accounts are seeded.
5. **Run the setup wizard** at `http://localhost/<project-folder>/setup.php` and click **Run Safe Upgrade**. The page is only accessible from the local machine. It preserves existing administrators, patients, appointments, and chat records, and shows the first-administrator form only when no administrator exists.
6. **Create an admin account** (if not created through the setup page), from the CLI:
   ```bash
   cd backend
   php create_admin.php admin@example.com "Admin Name" strongpassword
   ```
   Delete `backend/create_admin.php` afterward.

---

## Configuration

Choose one of the following:

**Option A — local config file (recommended)**
```bash
copy backend\config.local.example.php backend\config.local.php
```
Edit `backend/config.local.php` with your MySQL credentials and SMTP settings.

**Option B — environment variables**
Copy `.env.example` to `.env` and set the values in your Apache config.

Demo accounts are disabled unless `ALLOW_DEMO_ACCOUNTS=1` is explicitly set.

> If you use Gmail for SMTP, enable an App Password or use a dedicated SMTP service.

---

## Accessing the System

Replace `<project-folder>` with your folder name under `htdocs`.

| Area | URL |
|------|-----|
| Patient login | `http://localhost/<project-folder>/patient/login.html` |
| Admin login | `http://localhost/<project-folder>/admin/admin-login.html` |
| Setup wizard | `http://localhost/<project-folder>/setup.php` |
| TV display | `http://localhost/<project-folder>/tv-display.html` |

---

## Security Notes

- Never commit `backend/config.local.php` or `.env` to source control.
- Delete `backend/create_admin.php` after creating your admin account.
- Patient QR passes are random and one-time; only the SHA-256 hash is stored.
- Caregiver documents are not directly web-accessible; admins view them through an authenticated endpoint.
- Disease early-warning data is aggregated and never exposes patient identities.
- Reduce the database account's privileges after running the setup upgrade on a production server.
- Existing patients must accept the current privacy policy version before booking or approving protected Family Care actions.

---

## Documentation

| File | Description |
|------|-------------|
| [`README_DEPLOY.md`](README_DEPLOY.md) | XAMPP deployment guide |
| [`INNOVATION_FEATURES.md`](INNOVATION_FEATURES.md) | Details on the innovation features |
| [`OPERATIONS_AND_COMPLIANCE.md`](OPERATIONS_AND_COMPLIANCE.md) | Operations, privacy, and compliance controls |
| [`QA-CM-TEST-CASES.md`](QA-CM-TEST-CASES.md) | QA test cases |
| [`Pulilan_Health_Center_User_Manual.docx`](Pulilan_Health_Center_User_Manual.docx) | End-user manual |
| `BUILD-*.txt`, `BUGFIXES-*.txt` | Dated build and bug-fix notes |

---

## Testing

Manual QA scenarios are listed in [`QA-CM-TEST-CASES.md`](QA-CM-TEST-CASES.md). Automated tests, if any, are in the [`tests/`](tests) folder.

---

## Production Deployment

- Serve the site over **HTTPS**.
- Keep secrets out of the repository.
- Remove setup helpers (`create_admin.php`) after use.
- Secure and harden your server and database.

---

## License

No license has been specified yet. Add a `LICENSE` file to define how others may use this project.

---

## Author

[CharishArtiaga](https://github.com/CharishArtiaga)
