USE health_center_system;
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
