-- Clean, valid SQL file for testing

SELECT id, name FROM users WHERE status = 'active';

INSERT INTO orders (id, total) VALUES (1, 100);

SET @QUERY_STATEMENT = 'SELECT 1';
