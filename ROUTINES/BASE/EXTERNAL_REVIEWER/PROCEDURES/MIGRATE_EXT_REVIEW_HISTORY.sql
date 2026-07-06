CREATE PROCEDURE `MIGRATE_EXT_REVIEW_HISTORY`()
BEGIN
    DECLARE LI_DONE INT DEFAULT FALSE;
    DECLARE LI_HISTORY_ID INT;
    DECLARE LI_ACTION_TYPE_CODE INT;
    DECLARE LI_REVIEW_ID INT;
    DECLARE LI_REVIEWER_ID INT;
    DECLARE LS_DESCRIPTION LONGTEXT;
    DECLARE LS_UPDATE_USER VARCHAR(60);
    DECLARE LT_UPDATE_TIMESTAMP TIMESTAMP;
    
    DECLARE LI_ACTION_LOG_ID INT;
    DECLARE LS_SUB_MESSAGE JSON;
    DECLARE LS_KEYS JSON;
    DECLARE LS_KEY VARCHAR(100);
    DECLARE LS_VAL VARCHAR(2000);
    DECLARE i INT DEFAULT 0;
    DECLARE LI_NUM_KEYS INT DEFAULT 0;

    DECLARE cur_history CURSOR FOR 
        SELECT 
            EXT_REVIEW_HISTORY_ID,
            EXT_REVIEW_ACTION_TYPE_CODE,
            EXT_REVIEW_ID,
            REVIEW_REVIEWER_ID,
            DESCRIPTION,
            UPDATE_USER,
            UPDATE_TIMESTAMP
        FROM EXT_REVIEW_HISTORY
        ORDER BY UPDATE_TIMESTAMP ASC;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET LI_DONE = TRUE;

    OPEN cur_history;

    read_loop: LOOP
        FETCH cur_history INTO 
            LI_HISTORY_ID, LI_ACTION_TYPE_CODE, LI_REVIEW_ID, 
            LI_REVIEWER_ID, LS_DESCRIPTION, LS_UPDATE_USER, LT_UPDATE_TIMESTAMP;

        IF LI_DONE THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO EXT_REVIEW_ACTION_LOG (
            EXT_REVIEW_ID,
            REVIEW_REVIEWER_ID,
            EXT_REVIEW_ACTION_TYPE_CODE,
            COMMENT,
            UPDATE_USER,
            UPDATE_TIMESTAMP
        ) VALUES (
            LI_REVIEW_ID,
            LI_REVIEWER_ID,
            LI_ACTION_TYPE_CODE,
            NULL, -- (old table had no comment column)
            LS_UPDATE_USER,
            LT_UPDATE_TIMESTAMP
        );

        SET LI_ACTION_LOG_ID = LAST_INSERT_ID();

        IF LS_DESCRIPTION IS NOT NULL AND JSON_VALID(LS_DESCRIPTION) THEN
            
            SET LS_SUB_MESSAGE = JSON_EXTRACT(LS_DESCRIPTION, '$.subMessage');
            
            IF LS_SUB_MESSAGE IS NOT NULL AND JSON_TYPE(LS_SUB_MESSAGE) = 'OBJECT' THEN
                
                SET LS_KEYS = JSON_KEYS(LS_SUB_MESSAGE);
                
                IF LS_KEYS IS NOT NULL THEN
                    SET LI_NUM_KEYS = JSON_LENGTH(LS_KEYS);
                    SET i = 0;
                    
                    WHILE i < LI_NUM_KEYS DO
                        SET LS_KEY = JSON_UNQUOTE(JSON_EXTRACT(LS_KEYS, CONCAT('$[', i, ']')));
                        
                        SET LS_VAL = JSON_UNQUOTE(JSON_EXTRACT(LS_SUB_MESSAGE, CONCAT('$."', LS_KEY, '"')));
                        
                        INSERT INTO EXT_REVIEW_CHANGE_HISTORY (
                            ACTION_LOG_ID,
                            FIELD_NAME,
                            OLD_VALUE,
                            NEW_VALUE
                        ) VALUES (
                            LI_ACTION_LOG_ID,
                            LS_KEY,
                            NULL, -- (old system did not track previous values)
                            LS_VAL
                        );
                        
                        SET i = i + 1;
                    END WHILE;
                END IF;
            END IF;
        END IF;

    END LOOP;

    CLOSE cur_history;
    
END
