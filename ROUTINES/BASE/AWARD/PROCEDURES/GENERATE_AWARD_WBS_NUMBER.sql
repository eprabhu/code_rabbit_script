CREATE PROCEDURE `GENERATE_AWARD_WBS_NUMBER`(
    AV_AWARD_ID INT,
    AV_BUDGET_DETAIL_ID INT(12),
    AV_BUDGET_CATEGORY_CODE VARCHAR(3),
    AV_TYPE VARCHAR(1)
)
    DETERMINISTIC
BEGIN

    DECLARE DONE1 INT DEFAULT FALSE;

    DECLARE LS_AWARD_WBS_NUMBER VARCHAR(20);
    DECLARE LS_SPONSOR_TYPE_CODE VARCHAR(3);
    DECLARE LS_INPUT_GST_CATEGORY VARCHAR(30);
    DECLARE LS_WBS_CODE VARCHAR(1);
    DECLARE LI_NEXT_NUMBER INT(6);
    DECLARE LS_LEAD_UNIT_NUMBER VARCHAR(50);
    DECLARE LS_INCR_NEXT_NUMBER VARCHAR(6);
    DECLARE LS_ACCOUNT_NUMBER VARCHAR(20);
    DECLARE LS_LINE_ITEM_NEW_SEQ VARCHAR(2);
    DECLARE LI_LINE_ITEM_SEQ INT;
    DECLARE LS_BUDGET_CATEGORY_TYPE_CODE VARCHAR(3);
    DECLARE LI_BUDGET_PERIOD_ID INT(12);
    DECLARE LS_BUDGET_CATEGORY_CODE VARCHAR(3);
    DECLARE LS_COST_ELEMENT VARCHAR(50);
    DECLARE LI_BUDGET_DETAILS_ID INT(12);
    DECLARE LI_COUNT INT;
    DECLARE LI_BUDGET_HEADER_ID INT(12);
    DECLARE LS_BA_CODE VARCHAR(4);
    DECLARE LS_INTERNAL_ORDER_CODE VARCHAR(100);
    DECLARE LI_TASK_COUNT INT;

    DECLARE LS_CODE CHAR(5) DEFAULT '00000';
    DECLARE LS_MSG TEXT;
    DECLARE LS_ERROR VARCHAR(2000);
    DECLARE LS_WBS_PREFIX VARCHAR(2);
    DECLARE LI_LOCK_ACQUIRED INT DEFAULT 0;
    DECLARE LS_CONDITION TEXT ;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;

    START TRANSACTION;
    SELECT GET_LOCK('generate_award_wbs_number_lock', 30) INTO LI_LOCK_ACQUIRED;
    IF LI_LOCK_ACQUIRED = 1 THEN

        WBS_LABEL :
        BEGIN
            SELECT ACCOUNT_NUMBER
            INTO LS_ACCOUNT_NUMBER
            FROM AWARD
            WHERE AWARD_ID = AV_AWARD_ID;

            SELECT MAX(BUDGET_HEADER_ID)
            INTO LI_BUDGET_HEADER_ID
            FROM AWARD_BUDGET_HEADER
            WHERE AWARD_ID = AV_AWARD_ID
              AND IS_LATEST_VERSION = 'Y';


            IF AV_TYPE = 'Y' THEN
                IF (LS_ACCOUNT_NUMBER = 0) OR (LS_ACCOUNT_NUMBER IS NULL) THEN


                    SELECT COUNT(*)
                    INTO LI_COUNT
                    FROM SPONSOR
                    WHERE SPONSOR_CODE = (SELECT SPONSOR_CODE
                                          FROM AWARD
                                          WHERE AWARD_ID = AV_AWARD_ID);

                    IF LI_COUNT > 0 THEN

                        SELECT SPONSOR_TYPE_CODE
                        INTO LS_SPONSOR_TYPE_CODE
                        FROM SPONSOR
                        WHERE SPONSOR_CODE = (SELECT SPONSOR_CODE
                                              FROM AWARD
                                              WHERE AWARD_ID = AV_AWARD_ID);

                    ELSE

                        SET LS_SPONSOR_TYPE_CODE = NULL;

                    END IF;

                    IF LS_SPONSOR_TYPE_CODE IS NULL THEN
                        SET LS_CONDITION =  'Error Occurred while create WBS Number: Please select a "Sponsor". ';
                        LEAVE WBS_LABEL;

                    END IF;


                    SELECT COUNT(NEXT_NUMBER)
                    INTO LI_COUNT
                    FROM WBS_GEN_NEXTNUM_FOR_SPONS_TYPE
                    WHERE SPONSOR_TYPE_CODE = LS_SPONSOR_TYPE_CODE;

                    IF LI_COUNT = 0 THEN

                        INSERT INTO WBS_GEN_NEXTNUM_FOR_SPONS_TYPE (SPONSOR_TYPE_CODE, NEXT_NUMBER, UPDATE_TIMESTAMP, UPDATE_USER)
                        VALUES (LS_SPONSOR_TYPE_CODE, 1, NOW(), 'admin');

                        SET LI_NEXT_NUMBER = 1;
                    ELSE

                        SELECT NEXT_NUMBER
                        INTO LI_NEXT_NUMBER
                        FROM WBS_GEN_NEXTNUM_FOR_SPONS_TYPE
                        WHERE SPONSOR_TYPE_CODE = LS_SPONSOR_TYPE_CODE;

                    END IF;

                    UPDATE WBS_GEN_NEXTNUM_FOR_SPONS_TYPE
                    SET NEXT_NUMBER = LI_NEXT_NUMBER + 1
                    WHERE SPONSOR_TYPE_CODE = LS_SPONSOR_TYPE_CODE;


                    SELECT COUNT(*)
                    INTO LI_COUNT
                    FROM CUSTOM_DATA T1
                    WHERE T1.MODULE_ITEM_CODE = 1
                      AND T1.MODULE_SUB_ITEM_CODE = 0
                      AND T1.MODULE_ITEM_KEY = AV_AWARD_ID
                      AND T1.MODULE_SUB_ITEM_KEY = 0
                      AND T1.CUSTOM_DATA_ELEMENTS_ID = (SELECT CUSTOM_DATA_ELEMENTS_ID
                                          FROM CUSTOM_DATA_ELEMENTS
                                          WHERE CUSTOM_ELEMENT_NAME = 'INPUT GST CATEGORY');

                    IF LI_COUNT > 0 THEN


                        SELECT T1.VALUE
                        INTO LS_INPUT_GST_CATEGORY
                        FROM CUSTOM_DATA T1
                        WHERE T1.MODULE_ITEM_CODE = 1
                          AND T1.MODULE_SUB_ITEM_CODE = 0
                          AND T1.MODULE_ITEM_KEY = AV_AWARD_ID
                          AND T1.MODULE_SUB_ITEM_KEY = 0
                          AND T1.CUSTOM_DATA_ELEMENTS_ID = (SELECT CUSTOM_DATA_ELEMENTS_ID
                                              FROM CUSTOM_DATA_ELEMENTS
                                              WHERE CUSTOM_ELEMENT_NAME = 'INPUT GST CATEGORY');
                    ELSE

                        SET LS_INPUT_GST_CATEGORY = NULL;

                    END IF;

                    IF LS_INPUT_GST_CATEGORY IS NULL THEN

                        SET LS_CONDITION =  'Error Occurred while create WBS Number: Please select "INPUT GST CATEGORY" ';
                        LEAVE WBS_LABEL;

                    END IF;


                    SELECT COUNT(*)
                    INTO LI_COUNT
                    FROM WBS_GEN_INPUT_GST_MAPPING
                    WHERE GST_CATEGORY = LS_INPUT_GST_CATEGORY;

                    IF LI_COUNT > 0 THEN

                        SELECT WBS_CODE
                        INTO LS_WBS_CODE
                        FROM WBS_GEN_INPUT_GST_MAPPING
                        WHERE GST_CATEGORY = LS_INPUT_GST_CATEGORY;

                    ELSE

                        SET LS_WBS_CODE = NULL;

                    END IF;

                    IF LS_WBS_CODE IS NULL THEN

                        SET LS_CONDITION =  'Error Occurred while create WBS Number: No code defined for INPUT GST CATEGORY';
                        LEAVE WBS_LABEL;

                    END IF;

                    SELECT LPAD(LI_NEXT_NUMBER, 6, "0") INTO LS_INCR_NEXT_NUMBER;


                    SELECT COUNT(*)
                    INTO LI_COUNT
                    FROM AWARD
                    WHERE AWARD_ID = AV_AWARD_ID;

                    IF LI_COUNT > 0 THEN

                        SELECT LEAD_UNIT_NUMBER
                        INTO LS_LEAD_UNIT_NUMBER
                        FROM AWARD
                        WHERE AWARD_ID = AV_AWARD_ID;

                    ELSE

                        SET LS_LEAD_UNIT_NUMBER = NULL;

                    END IF;

                    IF LS_LEAD_UNIT_NUMBER IS NULL THEN
                        SET LS_CONDITION =  'Please select Lead Unit';
                        LEAVE WBS_LABEL;
                    END IF;

                    SELECT COUNT(*)
                    INTO LI_COUNT
                    FROM SAP_FEED_UNIT_MAPPING
                    WHERE UNIT_NUMBER = LS_LEAD_UNIT_NUMBER;

                    IF LI_COUNT > 0 THEN

                        SELECT BA_CODE
                        INTO LS_BA_CODE
                        FROM SAP_FEED_UNIT_MAPPING
                        WHERE UNIT_NUMBER = LS_LEAD_UNIT_NUMBER;

                    ELSE

                        SET LS_BA_CODE = NULL;

                    END IF;

                    IF LS_BA_CODE IS NULL THEN
                        SET LS_CONDITION =  'Error Occurred while create WBS Number: BA Code not is unavailable for the lead unit number. ';
                        LEAVE WBS_LABEL;
                    END IF;

                    -- ------------------- Logic for WBS Prefix -------------------------------------------------------------------
                    SELECT COUNT(*)
                    INTO LI_COUNT
                    FROM AWARD
                    WHERE AWARD_ID = AV_AWARD_ID
                      AND ACCOUNT_TYPE_CODE IS NULL;

                    IF LI_COUNT > 0 THEN

                        SET LS_CONDITION =  'Error Occurred while create WBS Number: Please choose an "Account Type". ';
                        LEAVE WBS_LABEL;

                    END IF;

                    select count(*)
                    into LI_COUNT
                    from award
                    where AWARD_DOCUMENT_TYPE_CODE = (select AWARD_DOCUMENT_TYPE_CODE
                                                      from award_task_type_mapping
                                                      where TASK_TYPE_CODE = 7)
                      and AWARD_ID = AV_AWARD_ID;

                    IF LI_COUNT > 0 THEN
                        SELECT COUNT(*)
                        INTO LI_TASK_COUNT
                        FROM task
                        WHERE TASK_TYPE_CODE = 7
                          and TASK_STATUS_CODE = 5
                          and MODULE_ITEM_ID = AV_AWARD_ID;

                        IF LI_TASK_COUNT = 0 THEN
                            SET LS_CONDITION =  'WBS number will be generated only after completion of the Finance Account Task.';
                            LEAVE WBS_LABEL;
                        END IF;

                    END IF;

                    SELECT COUNT(*)
                    INTO LI_COUNT
                    FROM AWARD
                    WHERE AWARD_ID = AV_AWARD_ID
                      AND ACCOUNT_TYPE_CODE IN (1, 2, 4, 6, 7); -- External / Internal Funding (Co-Funding)

                    IF LI_COUNT > 0 THEN -- External / Internal Funding (Co-Funding)

                        SET LS_WBS_PREFIX = '04';

                    ELSE

                        SELECT COUNT(*)
                        INTO LI_COUNT
                        FROM AWARD
                        WHERE AWARD_ID = AV_AWARD_ID
                          AND ACCOUNT_TYPE_CODE IN (3, 5)
                          AND substring(award_number, 8) = '00001';

                        IF LI_COUNT > 0 THEN -- This Internal Award is root award.
                            SET LS_WBS_PREFIX = '03';

                        ELSE -- Check if Parent of root Award is Internal

                            select COUNT(*)
                            INTO LI_COUNT
                            from award t1
                            where t1.award_number in (select CONCAT(substring(award_number, 1, 6), '-00001')
                                                      from award
                                                      where award_id = AV_AWARD_ID)
                              and t1.SEQUENCE_NUMBER =
                                  (select max(s1.SEQUENCE_NUMBER) from award s1 where s1.AWARD_NUMBER = t1.AWARD_NUMBER)
                              AND t1.ACCOUNT_TYPE_CODE IN (3, 5);

                            IF LI_COUNT > 0 THEN -- Parent of root Award is Internal
                                SET LS_WBS_PREFIX = '03';

                            ELSE
                                SET LS_WBS_PREFIX = '04';

                            END IF;

                        END IF;


                    END IF;

                    -- --------------------- Logic for WBS Prefix ----------------------------------------------------------------

                    SELECT CONCAT(LS_WBS_PREFIX, LS_SPONSOR_TYPE_CODE, LS_WBS_CODE, LS_INCR_NEXT_NUMBER, LS_BA_CODE)
                    INTO LS_ACCOUNT_NUMBER;

                    -- ---------------------Logic for new account number if exists--------------------------------------------------
                    SELECT COUNT(*)
                    INTO LI_COUNT
                    FROM AWARD
                    WHERE ACCOUNT_NUMBER = LS_ACCOUNT_NUMBER;

                    WHILE LI_COUNT > 0
                        DO

                            SELECT NEXT_NUMBER
                            INTO LI_NEXT_NUMBER
                            FROM WBS_GEN_NEXTNUM_FOR_SPONS_TYPE
                            WHERE SPONSOR_TYPE_CODE = LS_SPONSOR_TYPE_CODE;

                            UPDATE WBS_GEN_NEXTNUM_FOR_SPONS_TYPE
                            SET NEXT_NUMBER = LI_NEXT_NUMBER + 1
                            WHERE SPONSOR_TYPE_CODE = LS_SPONSOR_TYPE_CODE;
                            SELECT LPAD(LI_NEXT_NUMBER, 6, "0") INTO LS_INCR_NEXT_NUMBER;

                            SELECT CONCAT(LS_WBS_PREFIX, LS_SPONSOR_TYPE_CODE, LS_WBS_CODE, LS_INCR_NEXT_NUMBER,
                                          LS_BA_CODE)
                            INTO LS_ACCOUNT_NUMBER;

                            SELECT COUNT(*)
                            INTO LI_COUNT
                            FROM AWARD
                            WHERE ACCOUNT_NUMBER = LS_ACCOUNT_NUMBER;
                        END WHILE;
                    -- ---------------------Logic for new account number if exists--------------------------------------------------
                    UPDATE AWARD SET ACCOUNT_NUMBER = LS_ACCOUNT_NUMBER WHERE AWARD_ID = AV_AWARD_ID;

                    SET LS_CONDITION = 1;
                ELSE
                    SET LS_CONDITION = 0;
                    LEAVE WBS_LABEL;
                END IF;


                BEGIN

                    DECLARE BUDGET_DETAIL_CURSOR CURSOR FOR
                        SELECT BUDGET_CATEGORY_CODE, COST_ELEMENT, BUDGET_DETAILS_ID
                        FROM AWARD_BUDGET_DETAIL
                        WHERE BUDGET_HEADER_ID = LI_BUDGET_HEADER_ID;

                    DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;

                    OPEN BUDGET_DETAIL_CURSOR;

                    BUDGET_DETAIL_CURSOR_LOOP :
                    LOOP

                        FETCH BUDGET_DETAIL_CURSOR INTO LS_BUDGET_CATEGORY_CODE,LS_COST_ELEMENT,LI_BUDGET_DETAILS_ID;
                        IF DONE1 THEN
                            LEAVE BUDGET_DETAIL_CURSOR_LOOP;
                        END IF;


                        SELECT COUNT(T1.INTERNAL_ORDER_CODE)
                        INTO LI_COUNT
                        FROM AWARD_BUDGET_DETAIL T1
                        WHERE T1.BUDGET_HEADER_ID = LI_BUDGET_HEADER_ID
                          AND T1.BUDGET_CATEGORY_CODE = LS_BUDGET_CATEGORY_CODE
                          AND T1.INTERNAL_ORDER_CODE IS NOT NULL;

                        IF LI_COUNT = 0 THEN

                            SET LI_LINE_ITEM_SEQ = 1;

                        ELSE

                            SELECT MAX(SUBSTRING(INTERNAL_ORDER_CODE, -2) + 1)
                            INTO LI_LINE_ITEM_SEQ
                            FROM AWARD_BUDGET_DETAIL T1
                            WHERE T1.BUDGET_HEADER_ID = LI_BUDGET_HEADER_ID
                              AND T1.BUDGET_CATEGORY_CODE = LS_BUDGET_CATEGORY_CODE
                              AND T1.INTERNAL_ORDER_CODE IS NOT NULL;

                        END IF;


                        SELECT LPAD(LI_LINE_ITEM_SEQ, 2, "0") INTO LS_LINE_ITEM_NEW_SEQ;

                        UPDATE AWARD_BUDGET_DETAIL
                        SET INTERNAL_ORDER_CODE = CONCAT(LS_ACCOUNT_NUMBER, LS_BUDGET_CATEGORY_CODE,
                                                         LS_LINE_ITEM_NEW_SEQ)
                        WHERE BUDGET_DETAILS_ID = LI_BUDGET_DETAILS_ID
                          AND INTERNAL_ORDER_CODE IS NULL;


                        SELECT COUNT(*)
                        INTO LI_COUNT
                        FROM AWARD_MANPOWER
                        WHERE BUDGET_REFERENCE_TYPE_CODE = 2
                          AND BUDGET_REFERENCE_NUMBER = LI_BUDGET_DETAILS_ID;

                        IF LI_COUNT > 0 THEN

                            UPDATE AWARD_MANPOWER
                            SET BUDGET_REFERENCE_NUMBER    = CONCAT(LS_ACCOUNT_NUMBER, LS_BUDGET_CATEGORY_CODE,
                                                                    LS_LINE_ITEM_NEW_SEQ),
                                BUDGET_REFERENCE_TYPE_CODE = 1
                            WHERE BUDGET_REFERENCE_TYPE_CODE = 2
                              AND BUDGET_REFERENCE_NUMBER = concat('',LI_BUDGET_DETAILS_ID,'');


                        END IF;
                    END LOOP;

                    CLOSE BUDGET_DETAIL_CURSOR;
                END;

            ELSE
                IF LS_ACCOUNT_NUMBER IS NULL THEN
                     SET LS_CONDITION = 'Please Create Account Number';
                    LEAVE WBS_LABEL;
                END IF;


                IF AV_BUDGET_CATEGORY_CODE IS NULL THEN
                     SET LS_CONDITION = 'Please select Budget Category';
                    LEAVE WBS_LABEL;
                END IF;


                SELECT COUNT(BUDGET_HEADER_ID)
                INTO LI_COUNT
                FROM AWARD_BUDGET_DETAIL
                WHERE SUBSTRING(INTERNAL_ORDER_CODE, 1, LENGTH(INTERNAL_ORDER_CODE) - 2) =
                      CONCAT(LS_ACCOUNT_NUMBER, AV_BUDGET_CATEGORY_CODE)
                  AND BUDGET_HEADER_ID = LI_BUDGET_HEADER_ID;

                IF LI_COUNT = 0 THEN

                    SET LI_LINE_ITEM_SEQ = 1;

                ELSE

                    SELECT MAX(SUBSTRING(INTERNAL_ORDER_CODE, -2) + 1)
                    INTO LI_LINE_ITEM_SEQ
                    FROM AWARD_BUDGET_DETAIL T1
                    WHERE T1.BUDGET_HEADER_ID = LI_BUDGET_HEADER_ID
                      AND T1.BUDGET_CATEGORY_CODE = AV_BUDGET_CATEGORY_CODE
                      AND T1.INTERNAL_ORDER_CODE IS NOT NULL;

                END IF;
                SELECT LPAD(LI_LINE_ITEM_SEQ, 2, "0") INTO LS_LINE_ITEM_NEW_SEQ;

                UPDATE AWARD_BUDGET_DETAIL
                SET INTERNAL_ORDER_CODE = CONCAT(LS_ACCOUNT_NUMBER, AV_BUDGET_CATEGORY_CODE, LS_LINE_ITEM_NEW_SEQ)
                WHERE BUDGET_DETAILS_ID = AV_BUDGET_DETAIL_ID;
            END IF;
        END;
        COMMIT;
        SET LI_LOCK_ACQUIRED = RELEASE_LOCK('generate_award_wbs_number_lock');
      
    ELSE
         SET LS_CONDITION = 'Unable to acquire lock. Another process may be generating the WBS number.';

    END IF;
    SELECT LS_CONDITION;
END
