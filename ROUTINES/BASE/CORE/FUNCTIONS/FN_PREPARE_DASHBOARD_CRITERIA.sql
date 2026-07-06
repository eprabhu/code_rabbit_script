CREATE FUNCTION `FN_PREPARE_DASHBOARD_CRITERIA`(
    AV_CRITERIA_JSON JSON,
    AV_CRITERIA_MAP JSON
) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_key_name VARCHAR(100);
    DECLARE criteria_value TEXT;
    DECLARE FILTER_QUERY TEXT DEFAULT '';

 
    DECLARE cur CURSOR FOR
        SELECT  jt.key_name
        FROM JSON_TABLE(
            JSON_KEYS(AV_CRITERIA_JSON),
            '$[*]' COLUMNS (
                key_name VARCHAR(100) PATH '$'
            )
        ) AS jt;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_key_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET criteria_value = JSON_UNQUOTE(JSON_EXTRACT(AV_CRITERIA_MAP, CONCAT('$.',v_key_name)));
        IF criteria_value IS NOT NULL THEN
        SET FILTER_QUERY = CONCAT(
            FILTER_QUERY,
            ' ',
            criteria_value, 
            ' AND'
        );
        END IF;

    END LOOP;

    CLOSE cur;

    IF RIGHT(FILTER_QUERY, 4) = ' AND' THEN
        SET FILTER_QUERY = LEFT(FILTER_QUERY, LENGTH(FILTER_QUERY) - 4);
    END IF;

    RETURN FILTER_QUERY;
END
