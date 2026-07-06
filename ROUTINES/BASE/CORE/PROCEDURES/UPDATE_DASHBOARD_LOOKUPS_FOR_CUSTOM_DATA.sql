CREATE PROCEDURE `UPDATE_DASHBOARD_LOOKUPS_FOR_CUSTOM_DATA`(
    IN AV_CUSTOM_DATA_ELEMENTS_ID INT,
    IN AV_MODULE_CODE INT,
    IN AV_ACTYPE VARCHAR(1), 
    IN AV_DATA_TYPE_CODE VARCHAR(3)
)
PROC:BEGIN
    DECLARE LS_COLUMN_KEY VARCHAR(350);
    DECLARE LS_CRITERIA_KEY VARCHAR(350);
    DECLARE LS_COLUMN_NAME VARCHAR(300);
    DECLARE LI_COLUMN_CONF_ID INT;
    DECLARE LS_DISPLAY_NAME VARCHAR(500);
    DECLARE LS_ELEMENT_NAME VARCHAR(500);
    DECLARE LI_DEF_SORT_ORDER_COL INT;
    DECLARE LI_DEF_SORT_ORDER_CRT INT;
    DECLARE LI_ADVANCE_SEARCH_REQUIRED INT DEFAULT 0;
    DECLARE LS_MODULE VARCHAR(3);
    DECLARE LS_IS_MULTI VARCHAR(1);

    SET @MODULE_MAP = JSON_OBJECT(
        20, 'SR',
        13, 'AG',
		1, 'AWD'
        );
    SELECT JSON_UNQUOTE(JSON_EXTRACT(@MODULE_MAP, CONCAT('$."', AV_MODULE_CODE, '"'))) INTO LS_MODULE;
    
    SET LS_COLUMN_NAME = CONCAT('CUST_ELEMENTS_ID_', AV_CUSTOM_DATA_ELEMENTS_ID);
    SET LS_COLUMN_KEY = CONCAT('COL_',LS_MODULE,'_', LS_COLUMN_NAME);
    SET LS_CRITERIA_KEY = CONCAT('CRT_',LS_MODULE,'_', LS_COLUMN_NAME);
    
     IF AV_ACTYPE IN ('I', 'U') THEN
        -- Check if this custom element requires advance search for the given module
        SELECT COUNT(1) INTO LI_ADVANCE_SEARCH_REQUIRED
        FROM CUSTOM_DATA_ELEMENTS CDE
        INNER JOIN CUSTOM_DATA_ELEMENT_USAGE CDEU ON CDEU.CUSTOM_DATA_ELEMENTS_ID = CDE.CUSTOM_DATA_ELEMENTS_ID
        WHERE CDEU.MODULE_CODE = AV_MODULE_CODE 
          AND CDE.IS_ACTIVE = 'Y' 
          AND CDEU.IS_REQ_ADVANCE_SEARCH = 'Y' 
          AND CDE.CUSTOM_DATA_ELEMENTS_ID = AV_CUSTOM_DATA_ELEMENTS_ID;
        
        IF LI_ADVANCE_SEARCH_REQUIRED > 0 THEN
            -- Get element details
            SELECT COLUMN_LABEL, CUSTOM_ELEMENT_NAME, IS_MULTI_SELECT_LOOKUP
            INTO LS_DISPLAY_NAME, LS_ELEMENT_NAME, LS_IS_MULTI
            FROM CUSTOM_DATA_ELEMENTS 
            WHERE CUSTOM_DATA_ELEMENTS_ID = AV_CUSTOM_DATA_ELEMENTS_ID;
            
            -- Get next sort order values
            SELECT
                COALESCE(MAX(DEFAULT_SORT_ORDER), 0) + 1,
                (SELECT COALESCE(MAX(DEFAULT_SORT_ORDER), 0) + 1 
                 FROM DASHBOARD_CRITERIA_LOOKUP 
                 WHERE MODULE_CODE = AV_MODULE_CODE)
            INTO LI_DEF_SORT_ORDER_COL, LI_DEF_SORT_ORDER_CRT
            FROM DASHBOARD_COLUMN_LOOKUP 
            WHERE MODULE_CODE = AV_MODULE_CODE;
            
            -- Determine column configuration ID based on data type
            IF AV_DATA_TYPE_CODE IN ('1', '10', '5', '6', '7') THEN
                SET LI_COLUMN_CONF_ID = 1; -- Text types
            ELSEIF AV_DATA_TYPE_CODE = '2' THEN
                SET LI_COLUMN_CONF_ID = 2; -- Numeric types
            ELSEIF AV_DATA_TYPE_CODE = '3' THEN
                SET LI_COLUMN_CONF_ID = 3; -- Date types
            ELSEIF AV_DATA_TYPE_CODE = '4' THEN
                  SET LI_COLUMN_CONF_ID = 15;
            ELSEIF AV_DATA_TYPE_CODE IN ('8', '9') THEN
                IF LS_IS_MULTI = 'Y' THEN
                    SET LI_COLUMN_CONF_ID = 15; -- Multi-select lookup
                ELSE
                    SET LI_COLUMN_CONF_ID = 1;  -- Single-select lookup
                END IF;
            ELSE
                SET LI_COLUMN_CONF_ID = 1; -- Default to text
            END IF;
            
            -- Handle dashboard column lookup
            IF NOT EXISTS(
                SELECT 1 FROM DASHBOARD_COLUMN_LOOKUP 
                WHERE MODULE_CODE = AV_MODULE_CODE AND COLUMN_KEY = LS_COLUMN_KEY
            ) THEN
                -- Insert new column lookup entry
                INSERT INTO DASHBOARD_COLUMN_LOOKUP 
                (COLUMN_KEY, DESCRIPTION, DISPLAY_NAME, MODULE_CODE, COLUMN_CONF_ID, 
                 IS_ACTIVE, DEFAULT_SORT_ORDER, CUSTOM_DATA_ELEMENTS_ID, UPDATE_TIMESTAMP, UPDATE_USER)
                VALUES
                (LS_COLUMN_KEY, LS_ELEMENT_NAME, LS_DISPLAY_NAME, AV_MODULE_CODE, LI_COLUMN_CONF_ID, 
                 'Y', LI_DEF_SORT_ORDER_COL, AV_CUSTOM_DATA_ELEMENTS_ID, UTC_TIMESTAMP(), 'admin');
            ELSE
                -- Update existing column lookup entry
                SET SQL_SAFE_UPDATES = 0;
                UPDATE DASHBOARD_COLUMN_LOOKUP 
                SET IS_ACTIVE = 'Y', 
                    DISPLAY_NAME = LS_DISPLAY_NAME, 
                    COLUMN_CONF_ID = LI_COLUMN_CONF_ID, 
                    DEFAULT_SORT_ORDER = LI_DEF_SORT_ORDER_COL,
                    UPDATE_TIMESTAMP = UTC_TIMESTAMP(),
                    UPDATE_USER = 'admin'
                WHERE COLUMN_KEY = LS_COLUMN_KEY 
                  AND MODULE_CODE = AV_MODULE_CODE
                  AND CUSTOM_DATA_ELEMENTS_ID = AV_CUSTOM_DATA_ELEMENTS_ID;
                SET SQL_SAFE_UPDATES = 1;
            END IF;
            
            -- Handle dashboard criteria lookup
            IF NOT EXISTS(
                SELECT 1 FROM DASHBOARD_CRITERIA_LOOKUP 
                WHERE MODULE_CODE = AV_MODULE_CODE AND CRITERIA_KEY = LS_CRITERIA_KEY
            ) THEN
                -- Insert new criteria lookup entry
                INSERT INTO DASHBOARD_CRITERIA_LOOKUP 
                (CRITERIA_KEY, DESCRIPTION, DISPLAY_NAME, MODULE_CODE, CRITERIA_CONF_ID, 
                 IS_ACTIVE, DEFAULT_SORT_ORDER, CUSTOM_DATA_ELEMENTS_ID, UPDATE_TIMESTAMP, UPDATE_USER)
                VALUES
                (LS_CRITERIA_KEY, LS_ELEMENT_NAME, LS_DISPLAY_NAME, AV_MODULE_CODE, 18, 
                 'Y', LI_DEF_SORT_ORDER_CRT, AV_CUSTOM_DATA_ELEMENTS_ID, UTC_TIMESTAMP(), 'admin');
            ELSE
                -- Update existing criteria lookup entry
                SET SQL_SAFE_UPDATES = 0;
                UPDATE DASHBOARD_CRITERIA_LOOKUP 
                SET IS_ACTIVE = 'Y', 
                    DISPLAY_NAME = LS_DISPLAY_NAME, 
                    DESCRIPTION = LS_ELEMENT_NAME, 
                    DEFAULT_SORT_ORDER = LI_DEF_SORT_ORDER_CRT,
                    UPDATE_TIMESTAMP = UTC_TIMESTAMP(),
                    UPDATE_USER = 'admin'
                WHERE CRITERIA_KEY = LS_CRITERIA_KEY 
                  AND MODULE_CODE = AV_MODULE_CODE
                  AND CUSTOM_DATA_ELEMENTS_ID = AV_CUSTOM_DATA_ELEMENTS_ID;
                SET SQL_SAFE_UPDATES = 1;
            END IF;
        ELSE
            -- Element doesn't require advance search - deactivate any existing entries
            SET SQL_SAFE_UPDATES = 0;
            UPDATE DASHBOARD_COLUMN_LOOKUP 
            SET IS_ACTIVE = 'N',
                UPDATE_TIMESTAMP = UTC_TIMESTAMP(),
                UPDATE_USER = 'admin'
            WHERE MODULE_CODE = AV_MODULE_CODE 
              AND COLUMN_KEY = LS_COLUMN_KEY 
              AND CUSTOM_DATA_ELEMENTS_ID = AV_CUSTOM_DATA_ELEMENTS_ID;
              
            UPDATE DASHBOARD_CRITERIA_LOOKUP 
            SET IS_ACTIVE = 'N',
                UPDATE_TIMESTAMP = UTC_TIMESTAMP(),
                UPDATE_USER = 'admin'
            WHERE MODULE_CODE = AV_MODULE_CODE 
              AND CRITERIA_KEY = LS_CRITERIA_KEY 
              AND CUSTOM_DATA_ELEMENTS_ID = AV_CUSTOM_DATA_ELEMENTS_ID;
            SET SQL_SAFE_UPDATES = 1;
        END IF;
        
    ELSEIF AV_ACTYPE = 'D' THEN
        -- Deactivate dashboard lookup entries for delete operation
        SET SQL_SAFE_UPDATES = 0;
        UPDATE DASHBOARD_COLUMN_LOOKUP 
        SET IS_ACTIVE = 'N',
            UPDATE_TIMESTAMP = UTC_TIMESTAMP(),
            UPDATE_USER = 'admin'
        WHERE MODULE_CODE = AV_MODULE_CODE 
          AND COLUMN_KEY = LS_COLUMN_KEY 
          AND CUSTOM_DATA_ELEMENTS_ID = AV_CUSTOM_DATA_ELEMENTS_ID;
          
        UPDATE DASHBOARD_CRITERIA_LOOKUP 
        SET IS_ACTIVE = 'N',
            UPDATE_TIMESTAMP = UTC_TIMESTAMP(),
            UPDATE_USER = 'admin'
        WHERE MODULE_CODE = AV_MODULE_CODE 
          AND CRITERIA_KEY = LS_CRITERIA_KEY 
          AND CUSTOM_DATA_ELEMENTS_ID = AV_CUSTOM_DATA_ELEMENTS_ID;
        SET SQL_SAFE_UPDATES = 1;
    END IF;
    
END PROC
