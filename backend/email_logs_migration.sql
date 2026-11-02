USE health_center_system;

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
