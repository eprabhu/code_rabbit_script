-- `FN_WORKFLOW_HANDLE_DELEGATIONS`; 

CREATE FUNCTION `FN_WORKFLOW_HANDLE_DELEGATIONS`(
AV_WORKFLOW_ID               INT(12),
AV_MAP_NUMBER                            INT(3),
AV_APPROVAL_STOP_NUMBER      INT(3),
AV_APPROVAL_STATUS           VARCHAR(1),
AV_LOGGIN_PERSON_ID          VARCHAR(40),
AV_UPDATE_USER               VARCHAR(200)
) RETURNS int(11)
    DETERMINISTIC
BEGIN
DECLARE LI_APPROVAL_STOP_NUMBER INT(3) ;
DECLARE LI_APPROVER_NUMBER INT(3);
DECLARE LS_APPROVER_PERSON_ID VARCHAR(40);
DECLARE LS_FULL_NAME    VARCHAR(90);
DECLARE LS_EMAIL_ADDRESS        VARCHAR(60);
DECLARE LI_MAP_ID       INT(6);
declare LI_COUNT INT(11);
DECLARE LS_DELEGATED_TO VARCHAR(40);
DECLARE	LS_STOP_NAME	 VARCHAR(200);
DECLARE	LS_MAP_NAME	VARCHAR(200);
DECLARE	LS_MAP_DESCRIPTION VARCHAR(200);
BEGIN
                DECLARE LS_ERROR VARCHAR(2000);
        DECLARE DONE1 INT DEFAULT FALSE;
                DECLARE WORKFLOW_DELEGATION_CURSOR CURSOR FOR
                SELECT APPROVER_NUMBER,APPROVER_PERSON_ID,MAP_ID,STOP_NAME,MAP_NAME,MAP_DESCRIPTION
                FROM WORKFLOW_DETAIL
                WHERE WORKFLOW_ID = AV_WORKFLOW_ID
                AND MAP_NUMBER = AV_MAP_NUMBER
                AND APPROVAL_STOP_NUMBER = AV_APPROVAL_STOP_NUMBER
                AND APPROVAL_STATUS = AV_APPROVAL_STATUS
                AND (ROLE_TYPE_CODE IS NULL OR ROLE_TYPE_CODE <> 5)
                ORDER BY APPROVAL_STOP_NUMBER,APPROVER_NUMBER;
                DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
                DECLARE EXIT HANDLER FOR SQLEXCEPTION
                BEGIN
                        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
                         @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
                        SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
                        SELECT @full_error INTO LS_ERROR;
                        RETURN 0;
                END;
                OPEN WORKFLOW_DELEGATION_CURSOR;
                WORKFLOW_DELEGATION_CURSOR_LOOP : LOOP
                                FETCH WORKFLOW_DELEGATION_CURSOR INTO LI_APPROVER_NUMBER,LS_APPROVER_PERSON_ID,LI_MAP_ID,LS_STOP_NAME,LS_MAP_NAME,LS_MAP_DESCRIPTION;
                                IF DONE1 THEN
                                        LEAVE WORKFLOW_DELEGATION_CURSOR_LOOP;
                                END IF;
                                SELECT COUNT(*) INTO LI_COUNT
                                FROM DELEGATIONS
                                WHERE DELEGATED_BY = LS_APPROVER_PERSON_ID
                                AND DELEGATION_STATUS_CODE = 'A'
                                AND DATE(EFFECTIVE_DATE) <= DATE(NOW())
                                AND (DATE(END_DATE) IS NULL or DATE(END_DATE) >= DATE(NOW()));
                                IF LI_COUNT > 0 THEN
                                                SELECT DELEGATED_TO INTO LS_DELEGATED_TO
                                                FROM DELEGATIONS
                                                WHERE DELEGATED_BY = LS_APPROVER_PERSON_ID
                                                AND DELEGATION_STATUS_CODE = 'A'
                                                AND DATE(EFFECTIVE_DATE) <= DATE(NOW())
                                                AND (DATE(END_DATE) IS NULL or DATE(END_DATE) >= DATE(NOW()));
                                                IF IFNULL(TRIM(LS_DELEGATED_TO),'') <> '' THEN
                                                        SELECT COUNT(*) INTO LI_COUNT
                                                        FROM WORKFLOW_DETAIL
                                                        WHERE WORKFLOW_ID = AV_WORKFLOW_ID
                                                        AND MAP_NUMBER = AV_MAP_NUMBER
                                                        AND APPROVAL_STOP_NUMBER = AV_APPROVAL_STOP_NUMBER
                                                        AND APPROVER_NUMBER = LI_APPROVER_NUMBER
                                                        AND APPROVER_PERSON_ID = LS_DELEGATED_TO
                                                        AND APPROVAL_STATUS = AV_APPROVAL_STATUS;
                                                        IF LI_COUNT = 0   THEN
                                                                        SELECT FULL_NAME,EMAIL_ADDRESS INTO LS_FULL_NAME,LS_EMAIL_ADDRESS
                                                                        FROM PERSON WHERE PERSON_ID = LS_DELEGATED_TO;
                                                                        INSERT INTO WORKFLOW_DETAIL(
                                                                                WORKFLOW_ID,
                                                                                MAP_ID,
                                                                                MAP_NUMBER,
                                                                                APPROVAL_STOP_NUMBER,
                                                                                APPROVER_NUMBER,
                                                                                PRIMARY_APPROVER_FLAG,
                                                                                APPROVER_PERSON_ID,
                                                                                APPROVER_PERSON_NAME,
                                                                                APPROVAL_STATUS,
                                                                                APPROVAL_COMMENT,
                                                                                APPROVAL_DATE,
                                                                                UPDATE_USER,
                                                                                UPDATE_TIMESTAMP,
                                                                                UNIT_NUMBER,
                                                                                ROLE_TYPE_CODE,
                                                                                EMAIL_ADDRESS,
                                                                                DELEGATED_BY_PERSON_ID,
                                                                                STOP_NAME,
                                                                                MAP_NAME,
                                                                                MAP_DESCRIPTION)
                                                                                VALUES(
                                                                                AV_WORKFLOW_ID,
                                                                                LI_MAP_ID,
                                                                                AV_MAP_NUMBER,
                                                                                AV_APPROVAL_STOP_NUMBER,
                                                                                LI_APPROVER_NUMBER,
                                                                                'N',
                                                                                LS_DELEGATED_TO,
                                                                                LS_FULL_NAME,
                                                                                'W',
                                                                                NULL,
                                                                                NULL,
                                                                                AV_UPDATE_USER,
                                                                                UTC_TIMESTAMP(),
                                                                                NULL,
                                                                                NULL,
                                                                                LS_EMAIL_ADDRESS,
                                                                                LS_APPROVER_PERSON_ID,
                                                                                LS_STOP_NAME,
                                                                                LS_MAP_NAME,
                                                                                LS_MAP_DESCRIPTION
                                                                                );
                                                        END IF;
                                                END IF;
                                END IF;
                END LOOP;
                CLOSE WORKFLOW_DELEGATION_CURSOR;
END;
RETURN 1;
END
