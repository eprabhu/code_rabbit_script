CREATE FUNCTION `FN_DASHBOARD_SELECT_QUERY_BUILDER`(selectJson JSON) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE v_result TEXT DEFAULT '';
    DECLARE v_key VARCHAR(255);
    DECLARE v_val TEXT;
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_cnt INT;

    -- Count keys
    SET v_cnt = JSON_LENGTH(selectJson);

    WHILE v_idx < v_cnt DO
        -- Get key
        SET v_key = JSON_UNQUOTE(JSON_EXTRACT(JSON_KEYS(selectJson), CONCAT('$[', v_idx, ']')));
        -- Get value
        SET v_val = JSON_UNQUOTE(JSON_EXTRACT(selectJson, CONCAT('$.', v_key)));

        -- Append to result
        SET v_result = CONCAT(
            v_result,
            IF(v_result = '', '', ', '),
            v_val, ' AS ', v_key
        );

        SET v_idx = v_idx + 1;
    END WHILE;

    RETURN v_result;
END
