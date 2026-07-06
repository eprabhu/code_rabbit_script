CREATE PROCEDURE `GET_PROGRESS_REPORT_DASHBOARD`(
AV_AWARD_NUMBER         VARCHAR(20),
AV_PROGRESS_REPORT_NUMBER     VARCHAR(20),
AV_RESEARCH_PERSON_ID   VARCHAR(200),
AV_LEAD_UNIT_NUMBER     VARCHAR(200),
AV_PERSON_ID                             VARCHAR(200),
AV_DUE_DATE                            VARCHAR(20),
AV_SORT_TYPE                             VARCHAR(500),
AV_PAGED                                         INT(10),
AV_LIMIT                                         INT(10),
AV_TAB_TYPE                                  VARCHAR(30),
AV_UNLIMITED                     BOOLEAN,
AV_TYPE                          VARCHAR(1),
AV_TITLE                          VARCHAR(1000)

)
BEGIN
DECLARE LS_DYN_SQL LONGTEXT;
DECLARE LS_FILTER_CONDITION LONGTEXT;
DECLARE LS_OFFSET_CONDITION VARCHAR(600);
DECLARE LS_OFFSET INT(11);
DECLARE TAB_QUERY LONGTEXT;
DECLARE TAB_QUERY1 LONGTEXT;
DECLARE JOIN_CONDITION LONGTEXT;
DECLARE SELECTED_FIELD_LIST LONGTEXT;

SET LS_OFFSET = (AV_LIMIT * AV_PAGED);

SET LS_FILTER_CONDITION ='';
SET LS_DYN_SQL ='';
SET JOIN_CONDITION = '';
SET SELECTED_FIELD_LIST= '';
SET TAB_QUERY ='';



IF AV_TYPE = 'A'   THEN



                        IF AV_LEAD_UNIT_NUMBER IS NOT NULL  AND AV_LEAD_UNIT_NUMBER <> '' THEN
                         SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION,' T.LEAD_UNIT_NUMBER LIKE ''%',AV_LEAD_UNIT_NUMBER,'%'' AND ');
                        END IF;


						IF AV_AWARD_NUMBER IS NOT NULL  AND AV_AWARD_NUMBER <> '' THEN
                         SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION,' T.AWARD_NUMBER LIKE ''%',AV_AWARD_NUMBER,'%'' AND ');
                        END IF;
                        
                         IF AV_PROGRESS_REPORT_NUMBER IS NOT NULL  AND AV_PROGRESS_REPORT_NUMBER <> '' THEN
                         SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION,' T.PROGRESS_REPORT_NUMBER LIKE ''%',AV_PROGRESS_REPORT_NUMBER,'%'' AND ');
                        END IF;
                        
                        
                         IF (AV_RESEARCH_PERSON_ID IS NOT NULL AND AV_RESEARCH_PERSON_ID <> '') THEN


						SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION,' T.PI_PERSON_ID LIKE ''%',AV_RESEARCH_PERSON_ID,'%'' AND ');
                        END IF;
                        
                        IF (AV_DUE_DATE IS NOT NULL AND AV_DUE_DATE <> '') THEN


						SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION,' T.DUE_DATE = ''',STR_TO_DATE(AV_DUE_DATE,'%Y-%m-%d'),'''AND ');
                        END IF;
                        
                        IF AV_TITLE IS NOT NULL  AND AV_TITLE <> '' THEN
                         SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION,' T.TITLE LIKE ',QUOTE(CONCAT('%',AV_TITLE,'%')),' AND ');
						END IF;

END IF;

IF AV_SORT_TYPE IS NOT NULL THEN
       -- SET AV_SORT_TYPE =  CONCAT(' ORDER BY T.UPDATE_TIMESTAMP DESC ');
-- ELSE
    SET AV_SORT_TYPE = CONCAT(' ORDER BY ',AV_SORT_TYPE);
END IF;


IF AV_TAB_TYPE = 'PENDING_PR' THEN

		SET JOIN_CONDITION = CONCAT('LEFT JOIN AWARD_PROGRESS_REPORT T24 ON T24.AWARD_ID = T1.AWARD_ID 
                                    INNER JOIN PROGRESS_REPORT_STATUS T27 ON T24.PROGRESS_REPORT_STATUS_CODE = T27.PROGRESS_REPORT_STATUS_CODE
                                    INNER JOIN PERSON T25 ON T25.USER_NAME = T24.CREATE_USER
									INNER JOIN PERSON T26 ON T26.USER_NAME = T24.UPDATE_USER
                                    INNER JOIN REPORT_CLASS RE ON T24.REPORT_CLASS_CODE =  RE.REPORT_CLASS_CODE');
					
		SET SELECTED_FIELD_LIST =  CONCAT(',T24.PROGRESS_REPORT_ID,
															T24.PROGRESS_REPORT_NUMBER,
                                                            T24.TITLE AS PROGRESS_REPORT_TITLE,
															T24.PROGRESS_REPORT_STATUS_CODE,
															T25.FULL_NAME AS CREATE_USERNAME,
															T26.FULL_NAME AS UPDATE_USERNAME,
															T27.DESCRIPTION AS PROGRESS_REPORT_STATUS,
                                                            T24.UPDATE_TIMESTAMP AS PR_UPDATE_TIMESTAMP,
                                                            T24.REPORT_CLASS_CODE,T24.DUE_DATE, NULL AS AWARD_REPORT_TRACKING_ID, RE.DESCRIPTION AS REPORT_CLASS_DESCRIPTION,
                                                            T24.REPORT_TYPE_CODE AS REPORT_CODE ,
                                                            NULL AS WORKFLOW_START_DATE, NULL AS REPORT_TYPE');

		
		SET TAB_QUERY = CONCAT(' WHERE T24.PROGRESS_REPORT_STATUS_CODE <> 4 AND T24.PROGRESS_REPORT_STATUS_CODE <> 7  AND T1.AWARD_SEQUENCE_STATUS IN (''ACTIVE'',''ARCHIVE'')
					AND ((T1.LEAD_UNIT_NUMBER IN(SELECT DISTINCT UNIT_NUMBER FROM ACCESS_TMP)) 
					OR T7.HOME_UNIT_NUMBER IN(SELECT DISTINCT UNIT_NUMBER FROM ACCESS_TMP_GM)
					OR (T1.AWARD_ID IN(SELECT DISTINCT AWARD_ID FROM AWARD_TEMP)))' );	
		
		IF AV_SORT_TYPE IS  NULL THEN
			SET AV_SORT_TYPE =  CONCAT(' ORDER BY T.PR_UPDATE_TIMESTAMP DESC ');
		END IF;
        
  ELSEIF AV_TAB_TYPE = 'COMPLETED_PR' THEN
  
					SET JOIN_CONDITION = CONCAT('LEFT JOIN AWARD_PROGRESS_REPORT T24 ON T24.AWARD_ID = T1.AWARD_ID 
                                    INNER JOIN PROGRESS_REPORT_STATUS T27 ON T24.PROGRESS_REPORT_STATUS_CODE = T27.PROGRESS_REPORT_STATUS_CODE
                                    INNER JOIN PERSON T25 ON T25.USER_NAME = T24.CREATE_USER
									INNER JOIN PERSON T26 ON T26.USER_NAME = T24.UPDATE_USER
                                    INNER JOIN REPORT_CLASS RE ON T24.REPORT_CLASS_CODE =  RE.REPORT_CLASS_CODE
                                    LEFT JOIN WORKFLOW W1 ON W1.MODULE_ITEM_ID = T24.PROGRESS_REPORT_ID AND W1.IS_WORKFLOW_ACTIVE = ''Y'' AND W1.MODULE_CODE = 16 ');
					
					SET SELECTED_FIELD_LIST =  CONCAT(',T24.PROGRESS_REPORT_ID,
																		T24.PROGRESS_REPORT_NUMBER,
                                                                        T24.TITLE AS PROGRESS_REPORT_TITLE,
																		T24.PROGRESS_REPORT_STATUS_CODE,
																		T25.FULL_NAME AS CREATE_USERNAME,
																		T26.FULL_NAME AS UPDATE_USERNAME,
                                                                        T27.DESCRIPTION AS PROGRESS_REPORT_STATUS,
                                                                        T24.UPDATE_TIMESTAMP AS PR_UPDATE_TIMESTAMP,
                                                                        T24.REPORT_CLASS_CODE, T24.DUE_DATE, NULL AS AWARD_REPORT_TRACKING_ID, 
                                                                        T24.REPORT_TYPE_CODE AS REPORT_CODE ,
                                                                        RE.DESCRIPTION AS REPORT_CLASS_DESCRIPTION,
                                                                        W1.WORKFLOW_START_DATE, NULL AS REPORT_TYPE');  
					
					SET TAB_QUERY = CONCAT(' WHERE T24.PROGRESS_REPORT_STATUS_CODE = 4 AND  T24.PROGRESS_REPORT_STATUS_CODE <> 7 AND T1.AWARD_SEQUENCE_STATUS IN (''ACTIVE'',''ARCHIVE'')
					AND ((T1.LEAD_UNIT_NUMBER IN(SELECT DISTINCT UNIT_NUMBER FROM ACCESS_TMP))
					OR T7.HOME_UNIT_NUMBER IN(SELECT DISTINCT UNIT_NUMBER FROM ACCESS_TMP_GM)
					OR (T1.AWARD_ID IN(SELECT DISTINCT AWARD_ID FROM AWARD_TEMP)))' );	
		
					IF AV_SORT_TYPE IS  NULL THEN
                    SET AV_SORT_TYPE =  CONCAT(' ORDER BY T.PR_UPDATE_TIMESTAMP DESC ');
					END IF;
                    
	ELSEIF AV_TAB_TYPE = 'AWARD_QUALIFIED' THEN
					
					SET JOIN_CONDITION = CONCAT('
                    INNER JOIN REPORTING_REQUIREMENT_AWARDS ST ON T1.AWARD_NUMBER = ST.AWARD_NUMBER 
                    ');
					
					SET SELECTED_FIELD_LIST =  CONCAT(', NULL AS REPORT_CLASS_CODE , NULL AS DUE_DATE , NULL AS AWARD_REPORT_TRACKING_ID ,NULL AS  PR_UPDATE_TIMESTAMP, NULL AS PROGRESS_REPORT_ID,
																		NULL AS PROGRESS_REPORT_NUMBER,
                                                                        NULL AS PROGRESS_REPORT_TITLE,
																		NULL AS PROGRESS_REPORT_STATUS_CODE,
																		NULL AS  CREATE_USERNAME,
																		NULL AS UPDATE_USERNAME,
                                                                        NULL AS PROGRESS_REPORT_STATUS,
                                                                        NULL AS REPORT_CLASS_DESCRIPTION, NULL AS WORKFLOW_START_DATE, NULL AS REPORT_CODE,  NULL AS REPORT_TYPE ');             
					
					SET TAB_QUERY = CONCAT(' WHERE T1.AWARD_SEQUENCE_STATUS IN (''ACTIVE'')
					AND
					((T1.LEAD_UNIT_NUMBER IN(SELECT DISTINCT UNIT_NUMBER FROM ACCESS_TMP_PR)) 
					OR T7.HOME_UNIT_NUMBER IN(SELECT DISTINCT UNIT_NUMBER FROM ACCESS_TMP_PR_GM)
					OR (T1.AWARD_ID IN(SELECT DISTINCT AWARD_ID FROM AWARD_CREATE_TEMP)))
');	
					IF AV_SORT_TYPE IS  NULL THEN
                    SET AV_SORT_TYPE =  CONCAT(' ORDER BY T.UPDATE_TIMESTAMP DESC ');
					END IF;
END IF;



IF AV_UNLIMITED = TRUE THEN
        SET LS_OFFSET_CONDITION = '';
ELSE
        SET LS_OFFSET_CONDITION = CONCAT(' LIMIT ',AV_LIMIT,' OFFSET ',LS_OFFSET);
END IF;

IF LS_FILTER_CONDITION <>'' THEN

SET LS_FILTER_CONDITION = CONCAT(' WHERE T.AWARD_SEQUENCE_STATUS NOT IN (''CANCELLED'') AND ',LS_FILTER_CONDITION);
SELECT TRIM(TRAILING 'AND ' FROM LS_FILTER_CONDITION) into LS_FILTER_CONDITION from dual;

END IF;

     SET LS_DYN_SQL = CONCAT('WITH ACCESS_TMP 
							AS
							(
							SELECT UNIT_NUMBER
							FROM PERSON_ROLES T1
							INNER JOIN ROLE_RIGHTS T2 ON T1.ROLE_ID = T2.ROLE_ID
							INNER JOIN RIGHTS T3 ON T2.RIGHT_ID = T3.RIGHT_ID 
							WHERE T1.DESCEND_FLAG = ''N'' AND T1.PERSON_ID = ''',AV_PERSON_ID,'''
							AND RIGHT_NAME IN (''VIEW_PROGRESS_REPORT'',''MODIFY_PROGRESS_REPORT'',''CREATE_PROGRESS_REPORT'') 							
							UNION
							SELECT CHILD_UNIT_NUMBER FROM UNIT_WITH_CHILDREN 
							WHERE UNIT_NUMBER IN (
							SELECT UNIT_NUMBER
							FROM PERSON_ROLES T1
							INNER JOIN ROLE_RIGHTS T2 ON T1.ROLE_ID = T2.ROLE_ID
							INNER JOIN RIGHTS T3 ON T2.RIGHT_ID = T3.RIGHT_ID 
							WHERE T1.DESCEND_FLAG = ''Y'' AND T1.PERSON_ID = ''',AV_PERSON_ID,'''
							AND RIGHT_NAME IN (''VIEW_PROGRESS_REPORT'',''MODIFY_PROGRESS_REPORT'',''CREATE_PROGRESS_REPORT'') 
                            )),
							ACCESS_TMP_GM 
							AS
							(
							SELECT UNIT_NUMBER
							FROM PERSON_ROLES T1
							INNER JOIN ROLE_RIGHTS T2 ON T1.ROLE_ID = T2.ROLE_ID
							INNER JOIN RIGHTS T3 ON T2.RIGHT_ID = T3.RIGHT_ID 
							WHERE T1.DESCEND_FLAG = ''N'' AND T1.PERSON_ID = ''',AV_PERSON_ID,'''
							AND RIGHT_NAME IN (''VIEW_PROGRESS_REPORT'',''MODIFY_PROGRESS_REPORT'',''CREATE_PROGRESS_REPORT'') AND T1.ROLE_ID=''100'' 							
							UNION
							SELECT CHILD_UNIT_NUMBER FROM UNIT_WITH_CHILDREN 
							WHERE UNIT_NUMBER IN (
							SELECT UNIT_NUMBER
							FROM PERSON_ROLES T1
							INNER JOIN ROLE_RIGHTS T2 ON T1.ROLE_ID = T2.ROLE_ID
							INNER JOIN RIGHTS T3 ON T2.RIGHT_ID = T3.RIGHT_ID 
							WHERE T1.DESCEND_FLAG = ''Y'' AND T1.PERSON_ID = ''',AV_PERSON_ID,'''
							AND RIGHT_NAME IN (''VIEW_PROGRESS_REPORT'',''MODIFY_PROGRESS_REPORT'',''CREATE_PROGRESS_REPORT'') AND T1.ROLE_ID=''100''
                            )),
							ACCESS_TMP_PR 
							AS
							(
							SELECT UNIT_NUMBER
							FROM PERSON_ROLES T1
							INNER JOIN ROLE_RIGHTS T2 ON T1.ROLE_ID = T2.ROLE_ID
							INNER JOIN RIGHTS T3 ON T2.RIGHT_ID = T3.RIGHT_ID 
							WHERE T1.DESCEND_FLAG = ''N'' AND T1.PERSON_ID = ''',AV_PERSON_ID,'''
							AND RIGHT_NAME IN (''CREATE_PROGRESS_REPORT'') 							
							UNION
							SELECT CHILD_UNIT_NUMBER FROM UNIT_WITH_CHILDREN 
							WHERE UNIT_NUMBER IN (
							SELECT UNIT_NUMBER
							FROM PERSON_ROLES T1
							INNER JOIN ROLE_RIGHTS T2 ON T1.ROLE_ID = T2.ROLE_ID
							INNER JOIN RIGHTS T3 ON T2.RIGHT_ID = T3.RIGHT_ID 
							WHERE T1.DESCEND_FLAG = ''Y'' AND T1.PERSON_ID = ''',AV_PERSON_ID,'''
							AND RIGHT_NAME IN (''CREATE_PROGRESS_REPORT'')
                            )),
							ACCESS_TMP_PR_GM 
							AS
							(
							SELECT UNIT_NUMBER
							FROM PERSON_ROLES T1
							INNER JOIN ROLE_RIGHTS T2 ON T1.ROLE_ID = T2.ROLE_ID
							INNER JOIN RIGHTS T3 ON T2.RIGHT_ID = T3.RIGHT_ID 
							WHERE T1.DESCEND_FLAG = ''N'' AND T1.PERSON_ID = ''',AV_PERSON_ID,'''
							AND RIGHT_NAME IN (''CREATE_PROGRESS_REPORT'') AND T1.ROLE_ID=''100'' 							
							UNION
							SELECT CHILD_UNIT_NUMBER FROM UNIT_WITH_CHILDREN 
							WHERE UNIT_NUMBER IN (
							SELECT UNIT_NUMBER
							FROM PERSON_ROLES T1
							INNER JOIN ROLE_RIGHTS T2 ON T1.ROLE_ID = T2.ROLE_ID
							INNER JOIN RIGHTS T3 ON T2.RIGHT_ID = T3.RIGHT_ID 
							WHERE T1.DESCEND_FLAG = ''Y'' AND T1.PERSON_ID = ''',AV_PERSON_ID,'''
							AND RIGHT_NAME IN (''CREATE_PROGRESS_REPORT'') AND T1.ROLE_ID=''100''
                            )),
							AWARD_TEMP AS (
							SELECT DISTINCT S1.AWARD_ID FROM AWARD_PERSON_ROLES S1
											INNER JOIN ROLE R1 ON R1.ROLE_ID = S1.ROLE_ID
											INNER JOIN ROLE_RIGHTS R2 ON R2.ROLE_ID = R1.ROLE_ID
											INNER JOIN RIGHTS R3 ON R3.RIGHT_ID = R2.RIGHT_ID AND R3.RIGHT_NAME IN (''VIEW_PROGRESS_REPORT'',''MODIFY_PROGRESS_REPORT'',''CREATE_PROGRESS_REPORT'') WHERE S1.PERSON_ID=''',AV_PERSON_ID,''' ),
							AWARD_CREATE_TEMP AS (
							SELECT DISTINCT S1.AWARD_ID FROM AWARD_PERSON_ROLES S1
											INNER JOIN ROLE R1 ON R1.ROLE_ID = S1.ROLE_ID
											INNER JOIN ROLE_RIGHTS R2 ON R2.ROLE_ID = R1.ROLE_ID
											INNER JOIN RIGHTS R3 ON R3.RIGHT_ID = R2.RIGHT_ID AND R3.RIGHT_NAME IN (''CREATE_PROGRESS_REPORT'') WHERE S1.PERSON_ID=''',AV_PERSON_ID,'''),
                                              
                            REPORTING_REQUIREMENT_AWARDS AS
                            	( select distinct  MAIN.AWARD_NUMBER
                        from ( 
                                (
                                    SELECT
                                    SUB1.AWARD_NUMBER,
                                    SUB1.AWARD_ID
                                    FROM
                                    (
                                        SELECT
                                        SUB2.AWARD_ID,
                                        SUB2.AWARD_NUMBER,
                                        SUB2.AWARD_REPORT_TRACKING_ID,
                                        SUB2.SEQUENCE,
                                        SUB2.DUE_DATE,
                                        SUB2.REPORT_CLASS_CODE,
                                        SUB2.REPORT_CODE,
                                        SUB2.PREVIOUS_PROGRESS_REPORT_STATUS,
                                        SUB2.PROGRESS_REPORT_ID,
                                        MAX(SEQUENCE) OVER (
                                        PARTITION BY SUB2.AWARD_ID, IFNULL (SUB2.REPORT_CLASS_CODE, 0),IFNULL (SUB2.REPORT_CODE, 0) ORDER BY SUB2.DUE_DATE DESC ) AS MAX_RANK
                                        FROM
                                        (
                                            SELECT
                                            AW.AWARD_ID,
                                            ART.AWARD_REPORT_TRACKING_ID,
                                            TR.REPORT_CLASS_CODE,
                                            TR.REPORT_CODE,
                                            ART.DUE_DATE,
                                            ART.PROGRESS_REPORT_ID,
                                            AW.AWARD_NUMBER,
                                            LAG (APR.PROGRESS_REPORT_STATUS_CODE, 1) OVER ( PARTITION BY AW.AWARD_ID, IFNULL (TR.REPORT_CLASS_CODE, 0), IFNULL (TR.REPORT_CODE, 0) ORDER BY AW.AWARD_ID, TR.REPORT_CLASS_CODE, TR.REPORT_CODE, ART.DUE_DATE asc ) AS PREVIOUS_PROGRESS_REPORT_STATUS,
                                            LAG (ART.AWARD_REPORT_TRACKING_ID, 1) OVER (PARTITION BY AW.AWARD_ID, IFNULL (TR.REPORT_CLASS_CODE, 0), IFNULL (TR.REPORT_CODE, 0) ORDER BY AW.AWARD_ID, TR.REPORT_CLASS_CODE, TR.REPORT_CODE, ART.DUE_DATE asc ) AS PREVIOUS_TRACKING_ID,
                                            RANK() OVER ( PARTITION BY AW.AWARD_ID, IFNULL (TR.REPORT_CLASS_CODE, 0), IFNULL (TR.REPORT_CODE, 0) ORDER BY AW.AWARD_ID, TR.REPORT_CLASS_CODE, TR.REPORT_CODE, ART.DUE_DATE asc ) AS SEQUENCE
                                            FROM
                                            AWARD AW
                                            left join AWARD_REPORT_TRACKING ART on ART.AWARD_ID = AW.AWARD_ID
                                            left JOIN AWARD_REPORT_TERMS TR ON ART.AWARD_REPORT_TERMS_ID = TR.AWARD_REPORT_TERMS_ID
                                            left JOIN AWARD_REPORT_TRACKING_FILE ARTF ON ARTF.AWARD_REPORT_TRACKING_ID = ART.AWARD_REPORT_TRACKING_ID
                                            left JOIN REPORT_CLASS RC ON RC.REPORT_CLASS_CODE = TR.REPORT_CLASS_CODE
                                            LEFT JOIN AWARD_PROGRESS_REPORT APR ON APR.PROGRESS_REPORT_ID = ART.PROGRESS_REPORT_ID
                                            WHERE
                                             AW.AWARD_SEQUENCE_STATUS = ''ACTIVE'' AND
                                            ARTF.FILE_ID IS NULL
                                            AND ART.IS_ADHOC = ''N''
                                            AND RC.COPY_REPORT = ''Y''
                                            AND ART.STATUS_CODE = ''1''
                                            AND ( RC.IS_ATTACHMENT_OR_REPORT = ''R'' OR RC.IS_ATTACHMENT_OR_REPORT = ''E'')
                                            ORDER BY AW.AWARD_ID, REPORT_CLASS_CODE, REPORT_CODE, DUE_DATE asc
                                        ) SUB2
                                       WHERE 
                                       (
                                            CASE
                                            WHEN SUB2.PREVIOUS_TRACKING_ID IS NULL 
                                            THEN SUB2.PREVIOUS_TRACKING_ID IS NULL 
                                            ELSE SUB2.PREVIOUS_PROGRESS_REPORT_STATUS IS NOT NULL 
                                            END
                                        )
                                    ) SUB1
                                    WHERE
                                    SUB1.SEQUENCE = SUB1.MAX_RANK 
                                    AND (
                                            CASE
                                            WHEN SUB1.PREVIOUS_PROGRESS_REPORT_STATUS IS NULL 
                                            THEN SUB1.PREVIOUS_PROGRESS_REPORT_STATUS IS NULL 
                                            ELSE SUB1.PREVIOUS_PROGRESS_REPORT_STATUS = ''4'' AND SUB1.PROGRESS_REPORT_ID IS NULL
                                            END
										)
                                    AND SUB1.PROGRESS_REPORT_ID IS NULL
                                )
                                UNION
                                (
                                    SELECT
                                     ART2.AWARD_NUMBER,
                                     ART2.AWARD_ID
                                    FROM
                                    AWARD_REPORT_TRACKING ART2
                                    LEFT JOIN AWARD_REPORT_TERMS TR2 ON ART2.AWARD_REPORT_TERMS_ID = TR2.AWARD_REPORT_TERMS_ID
                                    LEFT JOIN AWARD_REPORT_TRACKING_FILE ARTF2 ON ARTF2.AWARD_REPORT_TRACKING_ID = ART2.AWARD_REPORT_TRACKING_ID
                                    LEFT JOIN REPORT_CLASS RC2 ON RC2.REPORT_CLASS_CODE = TR2.REPORT_CLASS_CODE
                                    LEFT JOIN AWARD AW2 ON AW2.AWARD_ID = ART2.AWARD_ID
                                    WHERE
                                    AW2.AWARD_SEQUENCE_STATUS = ''ACTIVE'' AND
                                    ART2.PROGRESS_REPORT_ID IS NULL
                                    AND RC2.COPY_REPORT = ''N''
                                    AND ART2.STATUS_CODE = ''1''
                                    AND ( RC2.IS_ATTACHMENT_OR_REPORT = ''R'' OR RC2.IS_ATTACHMENT_OR_REPORT = ''E'')
                                )
                            ) MAIN 
                        )
							');
     SET LS_DYN_SQL = CONCAT(LS_DYN_SQL,'SELECT DISTINCT *  FROM(SELECT T1.AWARD_ID,
                                                                        T1.AWARD_NUMBER,
                                                                        T1.ACCOUNT_NUMBER,
                                                                        T1.TITLE,
                                                                        T2.FULL_NAME,
																		COALESCE(T2.PERSON_ID,T2.ROLODEX_ID) AS PI_PERSON_ID,
                                                                        T1.LEAD_UNIT_NUMBER,
                                                                        T3.SPONSOR_CODE,
                                                                        T3.DISPLAY_NAME AS SPONSOR_NAME,                                                                        T3.ACRONYM,
																		T1.STATUS_CODE,
                                                                        T1.GRANT_HEADER_ID,
																		T1.UPDATE_TIMESTAMP,
																		T8.DISPLAY_NAME AS UNIT_NAME,
																		T8.UNIT_NUMBER,
																		T1.AWARD_DOCUMENT_TYPE_CODE AS AWARD_DOCUMENT_TYPE,
																		T1.AWARD_SEQUENCE_STATUS,
																		T1.WORKFLOW_AWARD_STATUS_CODE,
																		T1.SPONSOR_AWARD_NUMBER,                                                                       
                                                                        T1.BEGIN_DATE AS AWARD_START_DATE,
                                                                        T1.FINAL_EXPIRATION_DATE AS AWARD_END_DATE
                                                                        ',SELECTED_FIELD_LIST,
                                    ' FROM AWARD T1
									INNER JOIN AWARD_PERSONS T2 ON T1.AWARD_ID = T2.AWARD_ID AND T2.PERSON_ROLE_ID = 3 
									INNER JOIN SPONSOR T3 ON T3.SPONSOR_CODE = T1.SPONSOR_CODE
                                    INNER JOIN UNIT T8 ON T8.UNIT_NUMBER = T1.LEAD_UNIT_NUMBER	
									LEFT JOIN GRANT_CALL_HEADER T7 ON T7.GRANT_HEADER_ID = T1.GRANT_HEADER_ID								
                                    ',JOIN_CONDITION,TAB_QUERY,
                                     ')T ',LS_FILTER_CONDITION,' ',AV_SORT_TYPE,' ',LS_OFFSET_CONDITION );

SET @QUERY_STATEMENT = LS_DYN_SQL;
PREPARE EXECUTABLE_STAEMENT FROM @QUERY_STATEMENT;
EXECUTE EXECUTABLE_STAEMENT;

END
