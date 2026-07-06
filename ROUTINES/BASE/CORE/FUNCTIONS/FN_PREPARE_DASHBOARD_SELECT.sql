CREATE FUNCTION `FN_PREPARE_DASHBOARD_SELECT`(p_json JSON) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE v_result TEXT DEFAULT '';
    DECLARE v_key VARCHAR(255);
    DECLARE v_val TEXT;
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_cnt INT;

    SET v_cnt = JSON_LENGTH(p_json);

    WHILE v_idx < v_cnt DO
        SET v_key = JSON_UNQUOTE(JSON_EXTRACT(JSON_KEYS(p_json), CONCAT('$[', v_idx, ']')));
        SET v_val = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.', v_key)));

        SET v_result = CONCAT(
            v_result,
            IF(v_result = '', '', ', '),
            v_val, ' AS ', v_key
        );

        SET v_idx = v_idx + 1;
    END WHILE;

    RETURN v_result;
END
