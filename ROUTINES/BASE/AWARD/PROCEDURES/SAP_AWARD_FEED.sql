-- `SAP_AWARD_FEED`; 

CREATE PROCEDURE `SAP_AWARD_FEED`(
        AV_AWARD_ID             INT,
        AV_AWARD_NUMBER         VARCHAR(12),
        AV_SEQUENCE_NUMBER      INT,
        AV_UPDATE_USER          VARCHAR(60)
)
BEGIN
DECLARE LI_FLAG                  INT;
DECLARE LS_FEED_TYPE            VARCHAR(1);
DECLARE LI_SEQ_ERROR_LOG_ID INT;
DECLARE LS_ERROR_MSG            VARCHAR(1000);
DECLARE LI_WRITE_FLAG           INT;
DECLARE LS_FEED_STATUS          VARCHAR(1);
DECLARE LS_SYSTEM_COMMENT       VARCHAR(500);
DECLARE LI_BUDGET_HEADER_ID     INT;
DECLARE LS_BA_CODE                      VARCHAR(4);
DECLARE LS_LEAD_UNIT_NUMBER     VARCHAR(50);
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
                GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
                 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
                SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
                SELECT @full_error INTO LS_ERROR_MSG;
                SELECT IFNULL(MAX(BATCH_ERROR_ID),0)+1 INTO LI_SEQ_ERROR_LOG_ID FROM SAP_AWARD_FEED_BATCH_ERROR_LOG;
                RESIGNAL SET MESSAGE_TEXT = LS_ERROR_MSG;
        END;
                        IF AV_SEQUENCE_NUMBER = 1 THEN
                                SET LS_FEED_TYPE = 'N';
                        ELSE
                                SET LS_FEED_TYPE = 'C';
                        END IF;
                        SELECT COUNT(1) INTO LI_FLAG FROM AWARD_BUDGET_HEADER T1
                        WHERE T1.AWARD_ID = AV_AWARD_ID;
                        IF LI_FLAG = 0 THEN
                                SET LS_FEED_STATUS = 'N';
                                SET LS_SYSTEM_COMMENT = 'AWARD HAS NO BUDGET';
                                UPDATE AWARD_BUDGET_HEADER t1 set t1.AWARD_BUDGET_STATUS_CODE = 9 WHERE t1.AWARD_NUMBER = AV_AWARD_NUMBER AND t1.AWARD_BUDGET_STATUS_CODE = 10;
                        ELSE
                                SELECT BUDGET_HEADER_ID INTO LI_BUDGET_HEADER_ID FROM AWARD_BUDGET_HEADER T1
                                WHERE T1.AWARD_ID = AV_AWARD_ID
                                AND T1.VERSION_NUMBER IN (SELECT MAX(T2.VERSION_NUMBER) FROM AWARD_BUDGET_HEADER T2
                                                          WHERE T1.AWARD_ID = T2.AWARD_ID);
                                SELECT COUNT(1) INTO LI_FLAG
                                FROM AWARD_BUDGET_DETAIL
                                WHERE BUDGET_HEADER_ID = LI_BUDGET_HEADER_ID;
                                IF LI_FLAG = 0 THEN
                                        SET LS_FEED_STATUS = 'N';
                                        SET LS_SYSTEM_COMMENT = 'AWARD HAS NO BUDGET';
                                        UPDATE AWARD_BUDGET_HEADER t1 set t1.AWARD_BUDGET_STATUS_CODE = 9 WHERE t1.AWARD_NUMBER = AV_AWARD_NUMBER AND t1.AWARD_BUDGET_STATUS_CODE = 10;
                                ELSE
                                        SELECT COUNT(1) INTO LI_FLAG
                                        FROM AWARD
                                        WHERE AWARD_ID = AV_AWARD_ID
                                        AND STATUS_CODE = 3 AND AWARD_DOCUMENT_TYPE_CODE = 2;
                                        IF LI_FLAG > 0 THEN
                                                SET LS_FEED_STATUS = 'N';
                                                SET LS_SYSTEM_COMMENT = 'AWARD STATUS IS DRAFT IN ADMIN CORRECTION';
                                        ELSE
                                                SET LS_FEED_STATUS = 'P';
                                        END IF;
                                END IF;
                        END IF;
                                SELECT
                                        IF(TRIM(LEAD_UNIT_NUMBER) = '',NULL,TRIM(LEAD_UNIT_NUMBER))
                                INTO
                                        LS_LEAD_UNIT_NUMBER
                                FROM AWARD
                                WHERE AWARD_ID = AV_AWARD_ID;
                                BEGIN
                                        GET_BA_CODE_LOOP:WHILE (LS_BA_CODE IS NULL OR LS_BA_CODE = '') DO
                                                SELECT
                                                        BA_CODE
                                                INTO
                                                        LS_BA_CODE
                                                FROM SAP_FEED_UNIT_MAPPING
                                                WHERE UNIT_NUMBER = LS_LEAD_UNIT_NUMBER;
                                                IF (LS_BA_CODE IS NULL OR LS_BA_CODE = '') THEN
                                                        SELECT PARENT_UNIT_NUMBER
                                                        INTO LS_LEAD_UNIT_NUMBER
                                                        FROM UNIT
                                                        WHERE UNIT_NUMBER = LS_LEAD_UNIT_NUMBER;
                                                END IF;
                                                IF LS_LEAD_UNIT_NUMBER = NULL THEN
                                                        LEAVE GET_BA_CODE_LOOP;
                                                END IF;
                                        END WHILE GET_BA_CODE_LOOP;
                                END;
                                SET SQL_SAFE_UPDATES=0;
                                SELECT COUNT(1) INTO LI_FLAG FROM AWARD WHERE AWARD_ID = AV_AWARD_ID
                                AND AWARD_VARIATION_TYPE_CODE IN ('15','14','8','11','10','9','13','2','5','21','22','18','17');
                                IF LI_FLAG > 0 THEN
                                        SET LS_FEED_STATUS = 'N';
                                        SET LS_SYSTEM_COMMENT = 'THIS_VR_NOT_REQUIRED_TO_FEED_SAP';
                                END IF;
                INSERT INTO SAP_AWARD_FEED
                (
                        AWARD_ID,
                        AWARD_NUMBER,
                        SEQUENCE_NUMBER,
                        FEED_TYPE,
                        FEED_STATUS,
                        SYSTEM_COMMENT,
                        CREATE_USER,
                        CREATE_TIMESTAMP,
                        UPDATE_USER,
                        UPDATE_TIMESTAMP,
                                                BUSINESS_AREA,
                        NO_FEED_REPORT_FLAG
                )
                VALUES
                (
                        AV_AWARD_ID,
                        AV_AWARD_NUMBER,
                        AV_SEQUENCE_NUMBER,
                        LS_FEED_TYPE,
                        LS_FEED_STATUS,
                        LS_SYSTEM_COMMENT,
                        AV_UPDATE_USER,
                        UTC_TIMESTAMP(),
                        AV_UPDATE_USER,
                        UTC_TIMESTAMP(),
                                                LS_BA_CODE,
                        CASE when LS_FEED_STATUS = 'N' THEN 'N' ELSE NULL END
                );
                                 UPDATE SAP_AWARD_FEED
                                 SET FEED_STATUS = 'C'
                                 WHERE FEED_ID NOT IN(SELECT S1.FEED_ID FROM(SELECT MAX(FEED_ID) AS FEED_ID
                                 FROM SAP_AWARD_FEED
                                 WHERE  AWARD_NUMBER = AV_AWARD_NUMBER AND FEED_STATUS = 'P'
                                 GROUP BY AWARD_NUMBER) S1
								 )
                                 AND AWARD_NUMBER = AV_AWARD_NUMBER
                                 AND BATCH_ID IS NULL
								AND FEED_STATUS NOT IN ('N','H','CH','X','CX');
END
