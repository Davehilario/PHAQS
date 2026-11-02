USE health_center_system;

CREATE TABLE IF NOT EXISTS disease_cases (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NULL,
  appointment_id INT NULL,
  disease_category VARCHAR(150) NOT NULL,
  diagnosis VARCHAR(255) NULL,
  symptoms TEXT NULL,
  barangay VARCHAR(120) NOT NULL,
  rhu_branch VARCHAR(150) NOT NULL,
  case_date DATE NOT NULL,
  onset_date DATE NULL,
  age_group VARCHAR(50) NOT NULL DEFAULT 'Unknown',
  case_status VARCHAR(50) NOT NULL DEFAULT 'Recorded',
  verification_status ENUM('Verified','Pending','Rejected') NOT NULL DEFAULT 'Verified',
  record_source VARCHAR(120) NOT NULL DEFAULT 'RHU Consultation',
  recorded_by INT NULL,
  verified_by INT NULL,
  verified_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_disease_date (case_date),
  INDEX idx_disease_category (disease_category),
  INDEX idx_disease_barangay (barangay),
  INDEX idx_disease_rhu (rhu_branch),
  UNIQUE KEY uniq_disease_appointment_date (appointment_id,disease_category,case_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE disease_cases ADD COLUMN IF NOT EXISTS verification_status ENUM('Verified','Pending','Rejected') NOT NULL DEFAULT 'Verified' AFTER case_status;
ALTER TABLE disease_cases ADD COLUMN IF NOT EXISTS record_source VARCHAR(120) NOT NULL DEFAULT 'RHU Consultation' AFTER verification_status;
ALTER TABLE disease_cases ADD COLUMN IF NOT EXISTS verified_by INT NULL AFTER recorded_by;
ALTER TABLE disease_cases ADD COLUMN IF NOT EXISTS verified_at DATETIME NULL AFTER verified_by;
UPDATE disease_cases SET verified_at=COALESCE(verified_at,created_at) WHERE verification_status='Verified';
