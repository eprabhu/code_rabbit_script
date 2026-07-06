


CREATE PROCEDURE `ENRICH_ENTITY_INDUSTRY_CATE_JSON`(
    IN AV_ENTITY_ID INT,
    IN AV_PERSON_ID VARCHAR(255),
    IN AV_JSON_DATA JSON  -- JSON array of industry codes
)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total INT;
    DECLARE v_INDUSTRY_CATEGORY_ID INT;
    DECLARE v_INDUSTRY_CATEGORY_CODE VARCHAR(10);
    DECLARE v_CODE_DESCRIPTION VARCHAR(255);
    DECLARE v_TYPE_DESCRIPTION VARCHAR(255);
    DECLARE v_INDUSTRY_CATEGORY_TYPE_CODE VARCHAR(10);

    -- Temporary table to track valid industry categories for this entity
    CREATE TEMPORARY TABLE TempIndustryCategory (
        INDUSTRY_CATEGORY_ID INT PRIMARY KEY
    );

    -- Get the number of elements in the JSON array
    SET total = JSON_LENGTH(AV_JSON_DATA);

    WHILE i < total DO
        -- Extract values from JSON array
        SET v_INDUSTRY_CATEGORY_CODE = JSON_UNQUOTE(JSON_EXTRACT(AV_JSON_DATA, CONCAT('$[', i, '].code')));
        SET v_CODE_DESCRIPTION = JSON_UNQUOTE(JSON_EXTRACT(AV_JSON_DATA, CONCAT('$[', i, '].description')));
        SET v_TYPE_DESCRIPTION = JSON_UNQUOTE(JSON_EXTRACT(AV_JSON_DATA, CONCAT('$[', i, '].typeDescription')));
        SET v_INDUSTRY_CATEGORY_TYPE_CODE = JSON_UNQUOTE(JSON_EXTRACT(AV_JSON_DATA, CONCAT('$[', i, '].typeDnBCode')));

        -- Get INDUSTRY_CATEGORY_ID if it exists
        SELECT INDUSTRY_CATEGORY_ID 
        INTO v_INDUSTRY_CATEGORY_ID 
        FROM industry_category_code
        WHERE INDUSTRY_CATEGORY_TYPE_CODE = v_INDUSTRY_CATEGORY_TYPE_CODE 
        AND INDUSTRY_CATEGORY_CODE = v_INDUSTRY_CATEGORY_CODE;

        -- If INDUSTRY_CATEGORY_ID exists, insert into tracking table
        IF v_INDUSTRY_CATEGORY_ID IS NOT NULL THEN
            INSERT IGNORE INTO TempIndustryCategory VALUES (v_INDUSTRY_CATEGORY_ID);

            -- Insert into entity_industry_classification if not present
            IF NOT EXISTS (
                SELECT 1 
                FROM entity_industry_classification 
                WHERE ENTITY_ID = AV_ENTITY_ID 
                  AND INDUSTRY_CATEGORY_ID = v_INDUSTRY_CATEGORY_ID
            ) THEN
                INSERT INTO entity_industry_classification (ENTITY_ID, INDUSTRY_CATEGORY_ID, IS_PRIMARY, UPDATED_BY, UPDATE_TIMESTAMP)
                VALUES (AV_ENTITY_ID, v_INDUSTRY_CATEGORY_ID, 'N', AV_PERSON_ID, NOW());
            END IF;

        ELSE
            -- If INDUSTRY_CATEGORY_TYPE does not exist, insert it
            IF NOT EXISTS (
                SELECT 1 
                FROM industry_category_type 
                WHERE INDUSTRY_CATEGORY_TYPE_CODE = v_INDUSTRY_CATEGORY_TYPE_CODE
            ) THEN
                INSERT INTO industry_category_type (INDUSTRY_CATEGORY_TYPE_CODE, IS_PRIMARY, DESCRIPTION, IS_ACTIVE, UPDATED_BY, UPDATE_TIMESTAMP)
                VALUES (v_INDUSTRY_CATEGORY_TYPE_CODE, 'N', v_TYPE_DESCRIPTION, 'Y', AV_PERSON_ID, NOW());
            END IF;

            -- Insert new INDUSTRY_CATEGORY_CODE
            INSERT INTO industry_category_code (INDUSTRY_CATEGORY_CODE, INDUSTRY_CATEGORY_TYPE_CODE, DESCRIPTION, IS_ACTIVE, UPDATED_BY, UPDATE_TIMESTAMP)
            VALUES (v_INDUSTRY_CATEGORY_CODE, v_INDUSTRY_CATEGORY_TYPE_CODE, v_CODE_DESCRIPTION, 'Y', AV_PERSON_ID, NOW());

            -- Get the last inserted INDUSTRY_CATEGORY_ID
            SET v_INDUSTRY_CATEGORY_ID = LAST_INSERT_ID();

            -- Insert into tracking table
            INSERT IGNORE INTO TempIndustryCategory VALUES (v_INDUSTRY_CATEGORY_ID);

            -- Insert into entity_industry_classification
            INSERT INTO entity_industry_classification (ENTITY_ID, INDUSTRY_CATEGORY_ID, IS_PRIMARY, UPDATED_BY, UPDATE_TIMESTAMP)
            VALUES (AV_ENTITY_ID, v_INDUSTRY_CATEGORY_ID, 'N', AV_PERSON_ID, NOW());
        END IF;

        -- Increment loop counter
        SET i = i + 1;
    END WHILE;

    -- DELETE: Remove records that are NOT in the TempIndustryCategory table for this entity
    -- Keep records where INDUSTRY_CATEGORY_CODE is NULL in industry_category_code
    DELETE FROM entity_industry_classification
    WHERE ENTITY_ID = AV_ENTITY_ID 
    AND INDUSTRY_CATEGORY_ID NOT IN (
        SELECT INDUSTRY_CATEGORY_ID FROM TempIndustryCategory
    )
    AND INDUSTRY_CATEGORY_ID NOT IN (
        SELECT INDUSTRY_CATEGORY_ID FROM industry_category_code WHERE INDUSTRY_CATEGORY_CODE IS NULL
    );

    -- Drop temporary table after use
    DROP TEMPORARY TABLE TempIndustryCategory;
END