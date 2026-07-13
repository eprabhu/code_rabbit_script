-- Intentionally broken SQL file for testing the validator

SELET id, name FORM users WHERE status = 'active';

INSTERT INTO orders (id, total) VALUES (1, 100);

DROP TABLE old_logs;

ALTER TABLE users ADD COLUMN last_login DATETIME;

SET @QUERY_STATEMENT = 'SELECT 1';
