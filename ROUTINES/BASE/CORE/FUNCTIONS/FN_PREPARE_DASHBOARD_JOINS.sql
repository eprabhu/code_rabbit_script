CREATE FUNCTION `FN_PREPARE_DASHBOARD_JOINS`(
    DISP_COLUMNS JSON,
    CRITERIA JSON, 
    JOIN_KEY_MAP JSON,
    JOIN_QUERY_MAP JSON,
    MODE VARCHAR(10)
) RETURNS text CHARSET utf8mb4
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE result TEXT DEFAULT '';
    DECLARE merged_keys JSON DEFAULT JSON_ARRAY();

    DECLARE val VARCHAR(100);
    DECLARE join_stmt TEXT;
    DECLARE join_key TEXT;
    DECLARE join_key_values JSON;
    DECLARE custom_join TEXT;

    -- Input validation
    IF DISP_COLUMNS IS NULL OR CRITERIA IS NULL OR 
       JOIN_KEY_MAP IS NULL OR JOIN_QUERY_MAP IS NULL THEN
        RETURN 'ERROR: NULL INPUT';
    END IF;

    -- Normalize input
    SET CRITERIA = CAST(CRITERIA AS JSON);
    SET DISP_COLUMNS = CAST(DISP_COLUMNS AS JSON);

    -- Step 1: Merge keys from CRITERIA (object keys) and DISP_COLUMNS (array values)
    SET @idx = 0;
    WHILE @idx < JSON_LENGTH(JSON_KEYS(CRITERIA)) DO
        SET val = JSON_UNQUOTE(JSON_EXTRACT(JSON_KEYS(CRITERIA), CONCAT('$[', @idx, ']')));
        IF NOT JSON_CONTAINS(merged_keys, JSON_QUOTE(val), '$') THEN
            SET merged_keys = JSON_ARRAY_APPEND(merged_keys, '$', val);
        END IF;
        SET @idx = @idx + 1;
    END WHILE;

    SET @idx = 0;
    WHILE @idx < JSON_LENGTH(DISP_COLUMNS) DO
        SET val = JSON_UNQUOTE(JSON_EXTRACT(DISP_COLUMNS, CONCAT('$[', @idx, ']')));
        IF NOT JSON_CONTAINS(merged_keys, JSON_QUOTE(val), '$') THEN
            SET merged_keys = JSON_ARRAY_APPEND(merged_keys, '$', val);
        END IF;
        SET @idx = @idx + 1;
    END WHILE;

    -- Step 2: Loop through JOIN_KEY_MAP array (preserves order)
    SET @join_idx = 0;
    WHILE @join_idx < JSON_LENGTH(JOIN_KEY_MAP) DO
        SET @join_entry = JSON_EXTRACT(JOIN_KEY_MAP, CONCAT('$[', @join_idx, ']'));

        -- Extract key name (there should only be one key per object)
        SET @key_list = JSON_KEYS(@join_entry);
        SET join_key = JSON_UNQUOTE(JSON_EXTRACT(@key_list, '$[0]'));

        -- Extract array of column keys for this join_key
        SET join_key_values = JSON_EXTRACT(@join_entry, CONCAT('$.', join_key));

        -- key_loop allows us to break out once a match is found
        SET @val_idx = 0;
        key_loop: WHILE @val_idx < JSON_LENGTH(join_key_values) DO
            SET val = JSON_UNQUOTE(JSON_EXTRACT(join_key_values, CONCAT('$[', @val_idx, ']')));
            IF JSON_CONTAINS(merged_keys, JSON_QUOTE(val), '$') THEN
                -- Matching key found, get the corresponding join clause
                SET join_stmt = JSON_UNQUOTE(JSON_EXTRACT(JOIN_QUERY_MAP, CONCAT('$.', join_key)));
                IF join_stmt IS NOT NULL AND join_stmt <> '' THEN
                    SET @SEPERATOR = IF(MODE = 'CTE', ',', ' ');
                    SET result = CONCAT_WS(@SEPERATOR, result, join_stmt);
                END IF;
                LEAVE key_loop;  -- Correct usage of LEAVE inside labeled loop
            END IF;
            SET @val_idx = @val_idx + 1;
        END WHILE;

        SET @join_idx = @join_idx + 1;
    END WHILE;

    -- Handle custom elements
    IF (MODE <> 'CTE') THEN 
        IF EXISTS (
            SELECT 1
            FROM JSON_TABLE(MERGED_KEYS, '$[*]' COLUMNS(val VARCHAR(100) PATH '$')) t
            WHERE t.val LIKE '%CUST_ELEMENTS_ID%'
        ) THEN
            SELECT JSON_UNQUOTE(JSON_EXTRACT(JOIN_QUERY_MAP, '$.JOIN_CUSTOM_DATA'))
            INTO custom_join;
            IF custom_join IS NOT NULL AND custom_join <> '' THEN
                SET result = CONCAT_WS(' ', result, custom_join);
            END IF;
        END IF;
     END IF;

    RETURN IFNULL(result, '');
END
