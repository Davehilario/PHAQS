CREATE DATABASE IF NOT EXISTS health_center_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE health_center_system;

CREATE TABLE IF NOT EXISTS patients (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_code VARCHAR(20) UNIQUE,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(30) NULL,
  birthdate DATE NULL,
  gender VARCHAR(30) NULL,
  address TEXT NULL,
  barangay VARCHAR(100) NULL,
  philhealth_no VARCHAR(80) NULL,
  is_senior TINYINT(1) DEFAULT 0,
  is_pwd TINYINT(1) DEFAULT 0,
  is_4ps TINYINT(1) DEFAULT 0,
  preferred_rhu VARCHAR(150) NULL,
  account_status ENUM('Active','Archived') NOT NULL DEFAULT 'Active',
  archived_at DATETIME NULL,
  profile_json LONGTEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(60) NOT NULL DEFAULT 'RHU Staff',
  branch VARCHAR(120) NOT NULL DEFAULT 'All Branches',
  account_status ENUM('Active','Disabled') NOT NULL DEFAULT 'Active',
  last_notification_read_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  queue_number VARCHAR(20) NOT NULL,
  center VARCHAR(120) NOT NULL,
  service VARCHAR(120) NOT NULL,
  appointment_date DATE NOT NULL,
  appointment_time VARCHAR(30) NOT NULL,
  queue_type ENUM('regular','priority','emergency') DEFAULT 'regular',
  priority_reason VARCHAR(120) NULL,
  concern TEXT NULL,
  status ENUM('Pending','Confirmed','Serving','Done','Cancelled','No Show','Hold') DEFAULT 'Confirmed',
  arrival_status VARCHAR(20) NOT NULL DEFAULT 'not_arrived',
  arrived_at DATETIME NULL,
  service_started_at DATETIME NULL,
  completed_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  appointment_id INT NULL,
  type VARCHAR(40) NOT NULL DEFAULT 'info',
  title VARCHAR(150) NOT NULL,
  message TEXT NOT NULL,
  link VARCHAR(255) NULL,
  dedupe_key VARCHAR(190) NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_notifications_patient (patient_id, is_read, created_at),
  UNIQUE KEY uniq_notification_dedupe (patient_id,dedupe_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS password_resets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  email VARCHAR(150) NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_token_hash (token_hash),
  INDEX idx_email (email),
  FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_type VARCHAR(30) NOT NULL,
  user_name VARCHAR(120) NOT NULL,
  action VARCHAR(150) NOT NULL,
  details TEXT NULL,
  module VARCHAR(80) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- password handling

CREATE TABLE IF NOT EXISTS sms_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NULL,
  appointment_id INT NULL,
  recipient VARCHAR(30) NOT NULL,
  event_type VARCHAR(50) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending',
  provider_message_id VARCHAR(150) NULL,
  provider_response TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_sms_patient (patient_id, created_at),
  INDEX idx_sms_appointment (appointment_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS email_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NULL,
  appointment_id INT NULL,
  recipient VARCHAR(190) NOT NULL,
  event_type VARCHAR(50) NOT NULL,
  subject VARCHAR(190) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending',
  provider_message_id VARCHAR(190) NULL,
  provider_response TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_email_patient (patient_id, created_at),
  INDEX idx_email_appointment (appointment_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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

CREATE TABLE IF NOT EXISTS chat_thread_status (
  patient_id INT PRIMARY KEY,
  status ENUM('Open','Waiting for Patient','Resolved') NOT NULL DEFAULT 'Open',
  rhu_branch VARCHAR(150) NULL,
  assigned_admin_id INT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_chat_thread_status (status,updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS chat_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  admin_id INT NULL,
  sender_type ENUM('patient','admin') NOT NULL,
  message TEXT NOT NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  is_automated TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_chat_patient_created (patient_id,created_at),
  INDEX idx_chat_unread (sender_type,is_read,created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS announcements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(180) NOT NULL,
  message TEXT NOT NULL,
  branch VARCHAR(150) NOT NULL DEFAULT 'All Branches',
  status ENUM('Draft','Published','Archived') NOT NULL DEFAULT 'Published',
  attachment_path VARCHAR(255) NULL,
  attachment_name VARCHAR(255) NULL,
  attachment_mime VARCHAR(100) NULL,
  created_by INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_announcements_branch_status (branch,status,created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS system_settings (
  setting_key VARCHAR(100) PRIMARY KEY,
  setting_value TEXT NULL,
  updated_by INT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
