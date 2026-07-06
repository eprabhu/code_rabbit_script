-- `FN_CHK_AWARD_CUSTOM_ELEMENTS`; 


CREATE FUNCTION `FN_CHK_AWARD_CUSTOM_ELEMENTS`(
AV_AWARD_ID    DECIMAL(22)
) RETURNS varchar(6) 
    DETERMINISTIC
BEGIN
DECLARE LI_CUSTOM_DATA_ELEMENTS_ID INT(10);
DECLARE ls_value VARCHAR(4000);
DECLARE LI_FLAG INT;
DECLARE LI_COUNT INT(3);
DECLARE LI_CHECK_GRANT_CODE INT(3);
                SELECT COUNT(*) INTO LI_COUNT
                FROM AWARD
                WHERE AWARD_ID = AV_AWARD_ID
                AND AWARD_DOCUMENT_TYPE_CODE = 1;
                IF LI_COUNT = 0 THEN
                        RETURN 'TRUE';
                END IF;
        SELECT COUNT(1) INTO LI_FLAG FROM CUSTOM_DATA_ELEMENTS
        WHERE CUSTOM_ELEMENT_NAME ='STEM/Non-STEM';
        IF LI_FLAG > 0 THEN
                SELECT CUSTOM_DATA_ELEMENTS_ID INTO LI_CUSTOM_DATA_ELEMENTS_ID FROM CUSTOM_DATA_ELEMENTS
                WHERE CUSTOM_ELEMENT_NAME ='STEM/Non-STEM' and IS_LATEST_VERSION ='Y';
                SELECT COUNT(VALUE) into ls_value FROM CUSTOM_DATA
                WHERE MODULE_ITEM_CODE = 1
                AND MODULE_SUB_ITEM_CODE = 0
                AND CUSTOM_DATA_ELEMENTS_ID = LI_CUSTOM_DATA_ELEMENTS_ID
                AND MODULE_ITEM_KEY = AV_AWARD_ID;
                IF ls_value = 0 THEN
                        RETURN 'FALSE';
                END IF;
        END IF;
        SELECT COUNT(1) INTO LI_FLAG FROM CUSTOM_DATA_ELEMENTS
        WHERE CUSTOM_ELEMENT_NAME = 'Display at Acad Profile?';
        IF LI_FLAG > 0 THEN
                SELECT CUSTOM_DATA_ELEMENTS_ID INTO LI_CUSTOM_DATA_ELEMENTS_ID FROM CUSTOM_DATA_ELEMENTS
                WHERE CUSTOM_ELEMENT_NAME = 'Display at Acad Profile?' and IS_LATEST_VERSION ='Y';
                SELECT COUNT(VALUE) into ls_value  FROM CUSTOM_DATA
                WHERE MODULE_ITEM_CODE = 1
                AND MODULE_SUB_ITEM_CODE = 0
                AND CUSTOM_DATA_ELEMENTS_ID = LI_CUSTOM_DATA_ELEMENTS_ID
                AND MODULE_ITEM_KEY = AV_AWARD_ID;
                IF ls_value = 0 THEN
                        RETURN 'FALSE';
                END IF;
        END IF;
        SELECT COUNT(1) INTO LI_FLAG FROM CUSTOM_DATA_ELEMENTS
        WHERE CUSTOM_ELEMENT_NAME = 'RIE Domain';
        IF LI_FLAG > 0 THEN
                SELECT CUSTOM_DATA_ELEMENTS_ID INTO LI_CUSTOM_DATA_ELEMENTS_ID FROM CUSTOM_DATA_ELEMENTS
                WHERE CUSTOM_ELEMENT_NAME = 'RIE Domain' and IS_LATEST_VERSION ='Y';
                SELECT COUNT(VALUE) into ls_value FROM CUSTOM_DATA
                WHERE MODULE_ITEM_CODE = 1
                AND MODULE_SUB_ITEM_CODE = 0
                AND CUSTOM_DATA_ELEMENTS_ID = LI_CUSTOM_DATA_ELEMENTS_ID
                AND MODULE_ITEM_KEY = AV_AWARD_ID;
                IF ls_value = 0 THEN
                        RETURN 'FALSE';
                END IF;
        END IF;
        SELECT COUNT(1) INTO LI_FLAG FROM CUSTOM_DATA_ELEMENTS
        WHERE CUSTOM_ELEMENT_NAME = 'Input GST Category';
        IF LI_FLAG > 0 THEN
                SELECT CUSTOM_DATA_ELEMENTS_ID INTO LI_CUSTOM_DATA_ELEMENTS_ID FROM CUSTOM_DATA_ELEMENTS
                WHERE CUSTOM_ELEMENT_NAME = 'Input GST Category' and IS_LATEST_VERSION ='Y';
                SELECT COUNT(VALUE) into ls_value FROM CUSTOM_DATA
                WHERE MODULE_ITEM_CODE = 1
                AND MODULE_SUB_ITEM_CODE = 0
                AND CUSTOM_DATA_ELEMENTS_ID = LI_CUSTOM_DATA_ELEMENTS_ID
                AND MODULE_ITEM_KEY = AV_AWARD_ID;
                IF ls_value = 0 THEN
                        RETURN 'FALSE';
                END IF;
        END IF;
        SELECT COUNT(1) INTO LI_FLAG FROM CUSTOM_DATA_ELEMENTS
        WHERE CUSTOM_ELEMENT_NAME = 'Output GST Category';
        IF LI_FLAG > 0 THEN
                SELECT CUSTOM_DATA_ELEMENTS_ID INTO LI_CUSTOM_DATA_ELEMENTS_ID FROM CUSTOM_DATA_ELEMENTS
                WHERE CUSTOM_ELEMENT_NAME = 'Output GST Category' and IS_LATEST_VERSION ='Y';
                SELECT COUNT(VALUE) into ls_value FROM CUSTOM_DATA
                WHERE MODULE_ITEM_CODE = 1
                AND MODULE_SUB_ITEM_CODE = 0
                AND CUSTOM_DATA_ELEMENTS_ID = LI_CUSTOM_DATA_ELEMENTS_ID
                AND MODULE_ITEM_KEY = AV_AWARD_ID;
                IF ls_value = 0 THEN
                        RETURN 'FALSE';
                END IF;
        END IF;
        SELECT COUNT(1) INTO LI_FLAG FROM CUSTOM_DATA_ELEMENTS
        WHERE CUSTOM_ELEMENT_NAME = 'GRANT CODE';
                SELECT COUNT(*) INTO LI_COUNT
                FROM AWARD
                WHERE AWARD_ID = AV_AWARD_ID
                AND ACCOUNT_TYPE_CODE IN (1,2,4,6,7);
                IF LI_COUNT = 0 THEN
                        SET LI_CHECK_GRANT_CODE = 0;
                        SELECT COUNT(*) INTO LI_COUNT
                        FROM AWARD
                        WHERE AWARD_ID = AV_AWARD_ID
                        AND ACCOUNT_TYPE_CODE IN (3,5)
                        AND substring(award_number,8) = '00001';
                                IF LI_COUNT = 0 THEN
                                        select COUNT(*) INTO LI_COUNT
                                        from award t1
                                        where t1.award_number in (select CONCAT(substring(award_number,1,6),'-00001') from award where award_id = AV_AWARD_ID)
                                        and t1.SEQUENCE_NUMBER  = (select max(s1.SEQUENCE_NUMBER) from award s1 where s1.AWARD_NUMBER = t1.AWARD_NUMBER)
                                        AND t1.ACCOUNT_TYPE_CODE IN (1,2,4,6,7);
                                        IF LI_COUNT > 0 THEN
                                                SET LI_CHECK_GRANT_CODE = 1;
                                        END IF;
                                END IF;
                ELSE
                        SET LI_CHECK_GRANT_CODE = 1;
                END IF;
        IF LI_FLAG > 0  AND LI_CHECK_GRANT_CODE = 1 THEN
                SELECT CUSTOM_DATA_ELEMENTS_ID INTO LI_CUSTOM_DATA_ELEMENTS_ID FROM CUSTOM_DATA_ELEMENTS
                WHERE CUSTOM_ELEMENT_NAME = 'GRANT CODE' and IS_LATEST_VERSION ='Y';
                SELECT COUNT(1) INTO LI_COUNT FROM CUSTOM_DATA
                WHERE MODULE_ITEM_CODE = 1
                AND MODULE_SUB_ITEM_CODE = 0
                AND CUSTOM_DATA_ELEMENTS_ID = LI_CUSTOM_DATA_ELEMENTS_ID
                AND MODULE_ITEM_KEY = AV_AWARD_ID;
				
				IF LI_COUNT = 0 THEN
				
					RETURN 'FALSE';
					
				END IF;
				
		SELECT IFNULL(TRIM(VALUE),'') INTO LS_VALUE  FROM CUSTOM_DATA
                WHERE MODULE_ITEM_CODE = 1
                AND MODULE_SUB_ITEM_CODE = 0
                AND CUSTOM_DATA_ELEMENTS_ID = LI_CUSTOM_DATA_ELEMENTS_ID
                AND MODULE_ITEM_KEY = AV_AWARD_ID;
                IF ls_value = '' THEN
                        RETURN 'FALSE';
						
                END IF;
        END IF;
        SELECT COUNT(1) INTO LI_FLAG FROM CUSTOM_DATA_ELEMENTS
        WHERE CUSTOM_ELEMENT_NAME = 'PROFIT CENTER';
        IF LI_FLAG > 0 THEN
                SELECT CUSTOM_DATA_ELEMENTS_ID INTO LI_CUSTOM_DATA_ELEMENTS_ID FROM CUSTOM_DATA_ELEMENTS
                WHERE CUSTOM_ELEMENT_NAME = 'PROFIT CENTER' and IS_LATEST_VERSION ='Y';
                SELECT count(VALUE) into LI_COUNT FROM CUSTOM_DATA
                WHERE MODULE_ITEM_CODE = 1
                AND MODULE_SUB_ITEM_CODE = 0
                AND CUSTOM_DATA_ELEMENTS_ID = LI_CUSTOM_DATA_ELEMENTS_ID
                AND MODULE_ITEM_KEY = AV_AWARD_ID;
				
				if LI_COUNT = 0 then
					RETURN 'FALSE';
				end if;
		SELECT IFNULL(TRIM(VALUE),'') INTO LS_VALUE  FROM CUSTOM_DATA
                WHERE MODULE_ITEM_CODE = 1
                AND MODULE_SUB_ITEM_CODE = 0
                AND CUSTOM_DATA_ELEMENTS_ID = LI_CUSTOM_DATA_ELEMENTS_ID
                AND MODULE_ITEM_KEY = AV_AWARD_ID;
				
                IF ls_value = ''  THEN
                        RETURN 'FALSE';
                END IF;
        END IF;
        RETURN 'TRUE';
END
