USE pulilan_health_center;

SET @has_concern := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'appointments'
    AND COLUMN_NAME = 'concern'
);

SET @sql := IF(
  @has_concern = 0,
  'ALTER TABLE appointments ADD COLUMN concern TEXT NULL AFTER priority_reason',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
