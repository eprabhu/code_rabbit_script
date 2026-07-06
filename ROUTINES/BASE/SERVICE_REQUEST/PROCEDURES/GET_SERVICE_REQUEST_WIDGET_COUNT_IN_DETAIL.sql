CREATE PROCEDURE `GET_SERVICE_REQUEST_WIDGET_COUNT_IN_DETAIL`(
      AV_WIDGET VARCHAR(200),
      AV_PERSON_ID VARCHAR(40),
      AV_UNIT_NUMBER VARCHAR(50),
      AV_TYPE_CODES VARCHAR(2000),
      AV_STATUS_CODES VARCHAR(200),
      AV_ASSIGNEE_PERSON_ID VARCHAR(40),
      AV_REPORTER_PERSON_ID VARCHAR(40),
      AV_START_DATE VARCHAR(30),
      AV_END_DATE VARCHAR(30),
	  AV_PRIORITIES VARCHAR(10),
      AV_SEARCH VARCHAR(10),
	  AV_DESCENT_FLAG VARCHAR(1)
)
BEGIN
    DECLARE LS_DYN_SQL LONGTEXT DEFAULT '';
    DECLARE LS_FILTER_CONDITIONS LONGTEXT DEFAULT '';
    
    SET LS_DYN_SQL = CONCAT('WITH ACCESS_TMP AS 
                            (
                                SELECT UNIT_NUMBER
                                FROM PERSON_ROLES T1
                                INNER JOIN ROLE_RIGHTS T2 ON T1.ROLE_ID = T2.ROLE_ID
                                INNER JOIN RIGHTS T3 ON T2.RIGHT_ID = T3.RIGHT_ID 
                                WHERE T1.DESCEND_FLAG = ''N'' AND T1.PERSON_ID = ''', AV_PERSON_ID ,'''
                                AND T3.RIGHT_NAME IN (''SERVICE_REQUEST_ADMINISTRATOR'', ''MODIFY_SERVICE_REQUEST'', ''VIEW_SERVICE_REQUEST'')
                                UNION
                                SELECT CHILD_UNIT_NUMBER FROM UNIT_WITH_CHILDREN 
                                WHERE UNIT_NUMBER IN 
                                (
                                    SELECT UNIT_NUMBER
                                    FROM PERSON_ROLES T1
                                    INNER JOIN ROLE_RIGHTS T2 ON T1.ROLE_ID = T2.ROLE_ID
                                    INNER JOIN RIGHTS T3 ON T2.RIGHT_ID = T3.RIGHT_ID 
                                    WHERE T1.DESCEND_FLAG = ''Y'' AND T1.PERSON_ID = ''', AV_PERSON_ID ,'''
                                    AND T3.RIGHT_NAME IN (''SERVICE_REQUEST_ADMINISTRATOR'', ''MODIFY_SERVICE_REQUEST'', ''VIEW_SERVICE_REQUEST'')
                                )
                            ),
                            SR_TEMP AS 
                            (
                                SELECT s.SR_HEADER_ID 
                                FROM SR_HEADER s 
                                INNER JOIN WORKFLOW T9 ON T9.MODULE_ITEM_ID = s.SR_HEADER_ID
                                INNER JOIN WORKFLOW_DETAIL T10 ON T9.WORKFLOW_ID = T10.WORKFLOW_ID
                                WHERE T10.APPROVER_PERSON_ID = ''', AV_PERSON_ID ,'''
                                AND T9.MODULE_CODE = 20 
                                AND T9.IS_WORKFLOW_ACTIVE = ''Y'' 
                                AND T10.APPROVAL_STATUS = ''W''
                            ),
                            SR_HEADER_IDS AS 
                            (
                                SELECT DISTINCT SR_HEADER_ID 
                                FROM SR_PERSON_ROLES T5
                                INNER JOIN ROLE_RIGHTS rr ON rr.ROLE_ID = T5.ROLE_ID
                                INNER JOIN RIGHTS r ON r.RIGHT_ID = rr.RIGHT_ID 
                                WHERE r.RIGHT_NAME IN (''SERVICE_REQUEST_WATCHER'', ''MODIFY_SERVICE_REQUEST'', ''VIEW_SERVICE_REQUEST'')
                                AND T5.PERSON_ID = ''', AV_PERSON_ID ,'''
                            ),
                            SR_VIEW_ASSIGNEE AS
                            (
                                SELECT AG.ADMIN_GROUP_ID
                                FROM ADMIN_GROUP AG
                                INNER JOIN ROLE_RIGHTS RR ON AG.ROLE_ID = RR.ROLE_ID
                                INNER JOIN RIGHTS R ON RR.RIGHT_ID = R.RIGHT_ID
                                INNER JOIN PERSON_ROLES PR ON RR.ROLE_ID = PR.ROLE_ID
                                WHERE PR.PERSON_ID = ''', AV_PERSON_ID ,'''
                                AND R.RIGHT_NAME = ''VIEW_SR_ADMIN_GROUP''
                            ) ');
	
	IF AV_UNIT_NUMBER IS NOT NULL AND AV_UNIT_NUMBER != '' THEN

          IF AV_DESCENT_FLAG = 'Y' THEN
	       SET LS_FILTER_CONDITIONS = CONCAT(' AND (( EXISTS (SELECT 1 FROM UNIT_WITH_CHILDREN WHERE UNIT_NUMBER = ''',AV_UNIT_NUMBER,''' AND CHILD_UNIT_NUMBER = T1.UNIT_NUMBER)) OR  (T1.UNIT_NUMBER =''',AV_UNIT_NUMBER,''' ) )');	

        ELSE
           SET LS_FILTER_CONDITIONS = CONCAT(' AND (T1.UNIT_NUMBER =''',AV_UNIT_NUMBER,''' )')	;

        END IF;

    END IF;

    IF AV_TYPE_CODES IS NOT NULL AND AV_TYPE_CODES != '' THEN
        SET LS_FILTER_CONDITIONS = CONCAT(LS_FILTER_CONDITIONS, ' AND T1.TYPE_CODE IN (', AV_TYPE_CODES ,')');
    END IF;

    IF AV_STATUS_CODES IS NOT NULL AND AV_STATUS_CODES != '' THEN
        SET LS_FILTER_CONDITIONS = CONCAT(LS_FILTER_CONDITIONS, ' AND T1.STATUS_CODE IN (', AV_STATUS_CODES ,')');
    END IF;

    IF AV_ASSIGNEE_PERSON_ID IS NOT NULL AND AV_ASSIGNEE_PERSON_ID != '' THEN
        SET LS_FILTER_CONDITIONS = CONCAT(LS_FILTER_CONDITIONS, ' AND T1.ASSIGNEE_PERSON_ID = ''', AV_ASSIGNEE_PERSON_ID ,'''');
    END IF;

    IF AV_REPORTER_PERSON_ID IS NOT NULL AND AV_REPORTER_PERSON_ID != '' THEN
        SET LS_FILTER_CONDITIONS = CONCAT(LS_FILTER_CONDITIONS, ' AND T1.REPORTER_PERSON_ID = ''', AV_REPORTER_PERSON_ID ,'''');
    END IF;

    IF AV_START_DATE IS NOT NULL AND AV_START_DATE != '' THEN
        SET LS_FILTER_CONDITIONS = CONCAT(LS_FILTER_CONDITIONS, ' AND T1.CREATE_TIMESTAMP >= ''', AV_START_DATE ,'''');
    END IF;

    IF AV_END_DATE IS NOT NULL AND AV_END_DATE != '' THEN
        SET LS_FILTER_CONDITIONS = CONCAT(LS_FILTER_CONDITIONS, ' AND T1.CREATE_TIMESTAMP <= ''', AV_END_DATE ,'''');
    END IF;

    IF AV_WIDGET = 'PRIORITY_BREAKDOWN_OF_SERVICE_REQUEST' THEN
        SET LS_DYN_SQL = CONCAT(LS_DYN_SQL, 
            'SELECT COUNT(T1.SR_HEADER_ID) AS TOTAL_COUNT 
                FROM SR_HEADER T1
                WHERE(
                    (T1.REPORTER_PERSON_ID =  ''', AV_PERSON_ID ,''')
                    OR (T1.ASSIGNEE_PERSON_ID = ''', AV_PERSON_ID ,''')
                    OR T1.UNIT_NUMBER IN (SELECT DISTINCT UNIT_NUMBER FROM ACCESS_TMP)
                    OR T1.SR_HEADER_ID IN (SELECT DISTINCT SR_HEADER_ID FROM SR_HEADER_IDS)
                    OR T1.SR_HEADER_ID IN (SELECT DISTINCT SR_HEADER_ID FROM SR_TEMP)
                    OR T1.ADMIN_GROUP_ID IN (SELECT DISTINCT ADMIN_GROUP_ID FROM SR_VIEW_ASSIGNEE)    
                )
                AND T1.IS_SYSTEM_GENERATED = ''N'' 
                AND T1.TYPE_CODE IS NOT NULL 
                AND T1.STATUS_CODE IS NOT NULL
                AND T1.PRIORITY_ID  = ''', AV_SEARCH ,'''
            ');
		SET LS_DYN_SQL = CONCAT(LS_DYN_SQL, LS_FILTER_CONDITIONS);
		
            
			
    ELSEIF AV_WIDGET = 'CATEGORY_BREAKDOWN_OF_SERVICE_REQUEST' THEN

        SET LS_DYN_SQL = CONCAT(LS_DYN_SQL, 
            '
                SELECT COUNT(T1.SR_HEADER_ID) AS TOTAL_COUNT  
                FROM SR_HEADER T1
                WHERE(
                    (T1.REPORTER_PERSON_ID = ''', AV_PERSON_ID ,''')
                    OR (T1.ASSIGNEE_PERSON_ID = ''', AV_PERSON_ID ,''')
                    OR T1.UNIT_NUMBER IN (SELECT DISTINCT UNIT_NUMBER FROM ACCESS_TMP)
                    OR T1.SR_HEADER_ID IN (SELECT DISTINCT SR_HEADER_ID FROM SR_HEADER_IDS)
                    OR T1.SR_HEADER_ID IN (SELECT DISTINCT SR_HEADER_ID FROM SR_TEMP)
                    OR T1.ADMIN_GROUP_ID IN (SELECT DISTINCT ADMIN_GROUP_ID FROM SR_VIEW_ASSIGNEE)
                )
                AND T1.IS_SYSTEM_GENERATED = ''N'' 
                AND T1.TYPE_CODE IS NOT NULL 
                AND T1.STATUS_CODE IS NOT NULL
				AND T1.CATEGORY_CODE = ''', AV_SEARCH ,'''
            ');
			
			IF AV_PRIORITIES IS NOT NULL AND AV_PRIORITIES != '' THEN
			SET LS_FILTER_CONDITIONS = CONCAT(LS_FILTER_CONDITIONS, 'AND T1.PRIORITY_ID IN (',AV_PRIORITIES,')');
			END IF;

		SET LS_DYN_SQL = CONCAT(LS_DYN_SQL, LS_FILTER_CONDITIONS);
		
 
END IF;		
    SET @QUERY_STATEMENT = LS_DYN_SQL;
    PREPARE EXECUTABLE_STATEMENT FROM @QUERY_STATEMENT;
    EXECUTE EXECUTABLE_STATEMENT;
END
