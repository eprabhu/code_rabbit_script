CREATE FUNCTION `FN_PREPARE_DASHBOARD_JSON`(p_json JSON) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE v_result TEXT DEFAULT '';
    DECLARE v_key VARCHAR(255);
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_cnt INT;

    -- Count keys in input JSON
    SET v_cnt = JSON_LENGTH(p_json);

    -- Loop over all keys
    WHILE v_idx < v_cnt DO
        SET v_key = JSON_UNQUOTE(JSON_EXTRACT(JSON_KEYS(p_json), CONCAT('$[', v_idx, ']')));

        SET v_result = CONCAT(
            v_result,
            IF(v_result = '', '', ', '),
            "'", v_key, "', T.", v_key
        );

        SET v_idx = v_idx + 1;
    END WHILE;

        SET v_result = CONCAT(
        'JSON_ARRAYAGG(JSON_OBJECT(',
        v_result,
        ')) AS widget_data'
    );

    RETURN v_result;
END
