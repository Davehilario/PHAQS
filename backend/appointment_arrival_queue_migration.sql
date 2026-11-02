USE health_center_system;

ALTER TABLE appointments
  ADD COLUMN IF NOT EXISTS arrival_status VARCHAR(20) NOT NULL DEFAULT 'not_arrived' AFTER status,
  ADD COLUMN IF NOT EXISTS arrived_at DATETIME NULL AFTER arrival_status;

UPDATE appointments
SET arrival_status = 'not_arrived'
WHERE arrival_status IS NULL OR arrival_status = '';
