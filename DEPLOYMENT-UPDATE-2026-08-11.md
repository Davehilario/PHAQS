# PHAQS deployment update — August 11, 2026

## Included fixes

- Patient login, registration, password recovery, and personnel login now hide the image/left information panel at phone widths. Desktop keeps the existing two-panel layout.
- Added one final responsive design layer for patient, staff, and administrator pages, including safer card grids, tables, buttons, and mobile spacing.
- Refined the appointment date/time section with clearer panels, fields, slot states, focus states, and touch targets.
- Tightened the patient notification page so content starts higher and reads like a compact inbox.
- Replaced the profile-photo and Family Care browser confirmations with an in-system confirmation dialog.
- Replaced the queue reset browser confirmation with an in-system destructive-action dialog.
- Reinforced announcement editor exit behavior: Cancel, close button, Escape, and clicking the backdrop all close the form.
- Kept report changes pending until Apply is selected, retained direct PDF download, isolated printable report content, and retained downloadable heatmap CSV output.
- Added final print rules that exclude navigation, sidebars, chat, buttons, and other application controls.

## Automated checks completed

- 62 project static checks passed.
- All JavaScript files passed `node --check`.
- Inline JavaScript in patient/admin HTML passed syntax checks.
- No missing local HTML asset references were found.
- No duplicate HTML IDs were found.

## Required XAMPP checks before public deployment

The current build environment does not include PHP or MySQL, so run the included `tests/FINAL_TEST_CHECKLIST.html` and `tests/MULTI_DEVICE_TEST_GUIDE.md` in the real XAMPP installation. At minimum, verify one patient phone, one staff session, one admin session, and the TV display together. Run `php -l` through XAMPP PHP for the backend files before uploading to production.
