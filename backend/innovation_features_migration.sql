

-- config setup

ALTER TABLE announcements ADD COLUMN IF NOT EXISTS target_barangay VARCHAR(120) NOT NULL DEFAULT 'All Barangays' AFTER branch;
ALTER TABLE announcements ADD COLUMN IF NOT EXISTS priority ENUM('normal','important','urgent') NOT NULL DEFAULT 'normal' AFTER status;
ALTER TABLE announcements ADD COLUMN IF NOT EXISTS publish_at DATETIME NULL AFTER target_barangay;
ALTER TABLE announcements ADD COLUMN IF NOT EXISTS expires_at DATETIME NULL AFTER publish_at;
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS is_automated TINYINT(1) NOT NULL DEFAULT 0 AFTER is_read;

CREATE TABLE IF NOT EXISTS announcement_reads (
  announcement_id INT NOT NULL,
  patient_id INT NOT NULL,
  read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (announcement_id,patient_id),
  INDEX idx_announcement_reads_patient (patient_id,read_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS family_care_links (
  id INT AUTO_INCREMENT PRIMARY KEY,
  caregiver_patient_id INT NOT NULL,
  dependent_patient_id INT NOT NULL,
  relationship VARCHAR(40) NOT NULL,
  status ENUM('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',
  requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  responded_at DATETIME NULL,
  UNIQUE KEY uniq_family_pair (caregiver_patient_id,dependent_patient_id),
  INDEX idx_family_dependent_status (dependent_patient_id,status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS qr_arrival_tokens (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL,
  patient_id INT NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  used_by_admin_id INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_qr_appointment (appointment_id,used_at),
  INDEX idx_qr_recent (used_at,used_by_admin_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS queue_proximity_alerts (
  appointment_id INT PRIMARY KEY,
  patient_id INT NOT NULL,
  people_ahead INT NOT NULL,
  notified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_queue_proximity_patient (patient_id,notified_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
