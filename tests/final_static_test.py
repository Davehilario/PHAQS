from pathlib import Path
import re
import subprocess
import sys
import shutil

ROOT = Path(__file__).resolve().parents[1]
issues = []
passes = []

def check(condition, label):
    (passes if condition else issues).append(label)

api = (ROOT / "backend" / "api.php").read_text(encoding="utf-8", errors="ignore")
common = (ROOT / "patient" / "js" / "patient_common.js").read_text(encoding="utf-8", errors="ignore")
dashboard = (ROOT / "admin" / "admin-dashboard.html").read_text(encoding="utf-8", errors="ignore")
reports = (ROOT / "admin" / "admin-reports.html").read_text(encoding="utf-8", errors="ignore")

check("patient_notifications" in api, "Notification API exists")
check("send_brevo_email" in api, "Brevo email function exists")
check("requestBrowserNotificationPermission" in common, "Browser notification permission flow exists")
check("checkBrowserNotifications" in common, "Browser notification polling exists")
check("rhuAppointmentsChart" in dashboard, "RHU bar chart exists")
check("appointmentStatusChart" in dashboard, "Appointment status chart exists")
check("exportCSV()" in reports, "CSV export exists")
check("exportExcel()" in reports, "Excel export exists")
check("exportPDF()" in reports, "PDF/print export exists")

for js in ROOT.rglob("*.js"):
    result = subprocess.run(["node", "--check", str(js)], capture_output=True, text=True)
    check(result.returncode == 0, f"JavaScript syntax: {js.relative_to(ROOT)}")

php_binary = shutil.which("php")
if php_binary:
    for php in ROOT.rglob("*.php"):
        result = subprocess.run([php_binary, "-l", str(php)], capture_output=True, text=True)
        check(result.returncode == 0, f"PHP syntax: {php.relative_to(ROOT)}")
else:
    passes.append("PHP lint skipped (run this checklist inside XAMPP where PHP is available)")

print("PASSED:", len(passes))
for item in passes:
    print("  [PASS]", item)

print("FAILED:", len(issues))
for item in issues:
    print("  [FAIL]", item)

sys.exit(1 if issues else 0)
