UPDATE appointments
SET status='Confirmed', updated_at=NOW()
WHERE LOWER(TRIM(status))='pending'
  AND appointment_date>=CURDATE();

ALTER TABLE appointments
MODIFY status ENUM('Pending','Confirmed','Serving','Done','Cancelled','No Show','Hold') DEFAULT 'Confirmed';
