USE health_center_system;

ALTER TABLE patients ADD COLUMN IF NOT EXISTS archived_at DATETIME NULL AFTER account_status;
UPDATE patients SET archived_at=NOW() WHERE account_status='Archived' AND archived_at IS NULL;
ALTER TABLE admins ADD COLUMN IF NOT EXISTS last_notification_read_at DATETIME NULL AFTER account_status;

ALTER TABLE appointments ADD COLUMN IF NOT EXISTS service_started_at DATETIME NULL AFTER arrived_at;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS completed_at DATETIME NULL AFTER service_started_at;
ALTER TABLE appointments MODIFY status ENUM('Pending','Confirmed','Serving','Done','Cancelled','No Show','Hold') DEFAULT 'Confirmed';
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS dedupe_key VARCHAR(190) NULL AFTER link;

CREATE TABLE IF NOT EXISTS clinic_capacity_rules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  branch VARCHAR(120) NOT NULL,
  service VARCHAR(120) NOT NULL DEFAULT 'All Services',
  capacity_per_slot SMALLINT NOT NULL DEFAULT 25,
  daily_capacity SMALLINT NOT NULL DEFAULT 200,
  updated_by INT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_capacity_rule (branch,service)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
ALTER TABLE clinic_capacity_rules ADD COLUMN IF NOT EXISTS daily_capacity SMALLINT NOT NULL DEFAULT 200 AFTER capacity_per_slot;

ALTER TABLE disease_cases ADD COLUMN IF NOT EXISTS verification_status ENUM('Verified','Pending','Rejected') NOT NULL DEFAULT 'Verified' AFTER case_status;
ALTER TABLE disease_cases ADD COLUMN IF NOT EXISTS record_source VARCHAR(120) NOT NULL DEFAULT 'RHU Consultation' AFTER verification_status;
ALTER TABLE disease_cases ADD COLUMN IF NOT EXISTS verified_by INT NULL AFTER recorded_by;
ALTER TABLE disease_cases ADD COLUMN IF NOT EXISTS verified_at DATETIME NULL AFTER verified_by;
UPDATE disease_cases SET verified_at=COALESCE(verified_at,created_at) WHERE verification_status='Verified';

SET @notification_index_exists = (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'notifications'
    AND index_name = 'uniq_notification_dedupe'
);
SET @notification_index_sql = IF(
  @notification_index_exists = 0,
  'ALTER TABLE notifications ADD UNIQUE KEY uniq_notification_dedupe (patient_id,dedupe_key)',
  'SELECT 1'
);
PREPARE notification_index_statement FROM @notification_index_sql;
EXECUTE notification_index_statement;
DEALLOCATE PREPARE notification_index_statement;
