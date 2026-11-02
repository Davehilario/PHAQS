# Google Login + Chat Fix

Applied fixes:

1. Google Client ID configured in:
   - backend/config.php
   - backend/config.local.php
   - patient/login.html
   - patient/register.html

2. Patient login page Google error alert was removed from the visible red login notification area. Google failures are logged to browser console while the button is re-enabled.

3. Empty patient dashboard notification card was removed until real notification content is implemented.

4. Database-backed chat was added:
   - backend creates `chat_messages` table automatically.
   - patient pages show a floating chat button.
   - admin pages show a floating chat button and patient conversation list.
   - chat messages are saved in MySQL, not localStorage.

Required Google Cloud Console setting for XAMPP:
- Authorized JavaScript origin: `http://localhost`
- Open the app using localhost, not `file:///`.

