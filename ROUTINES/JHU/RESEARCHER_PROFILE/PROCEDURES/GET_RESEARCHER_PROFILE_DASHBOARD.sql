CREATE PROCEDURE `GET_RESEARCHER_PROFILE_DASHBOARD`(
    AV_LEAD_UNIT_NAME     VARCHAR(200),
    AV_PERSON_ID            VARCHAR(40),
    AV_FIRST_NAME           VARCHAR(50),
    AV_LAST_NAME            VARCHAR(50),
    AV_PUBLICATION          VARCHAR(255),
    AV_CERTIFICATION        VARCHAR(600),
	AV_DEGREE_CODE           VARCHAR(10),
    AV_PAGED                INT(10),
    AV_LIMIT                INT(10),
    AV_KEYWORD            VARCHAR(1000)
)
BEGIN
    DECLARE LS_FILTER_CONDITION VARCHAR(4000);
    DECLARE LS_OFFSET INT;
    DECLARE LS_DYN_SQL LONGTEXT;
    DECLARE LS_SORT_TYPE VARCHAR(100);
    SET LS_OFFSET = (AV_LIMIT * AV_PAGED);
    SET LS_FILTER_CONDITION = '';
    SET LS_DYN_SQL ='';

    IF AV_LEAD_UNIT_NAME IS NOT NULL AND AV_LEAD_UNIT_NAME <> '' THEN
        SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION, ' U.DISPLAY_NAME LIKE \'%', AV_LEAD_UNIT_NAME, '%\' AND ');
    END IF;

    IF AV_PERSON_ID IS NOT NULL AND AV_PERSON_ID <> '' THEN
        SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION, ' P.PERSON_ID = ', AV_PERSON_ID, ' AND ');
    END IF;
    
    IF AV_FIRST_NAME IS NOT NULL AND AV_FIRST_NAME <> '' THEN
        SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION, ' P.FIRST_NAME LIKE \'%', AV_FIRST_NAME, '%\' AND ');
    END IF;
    
    IF AV_LAST_NAME IS NOT NULL AND AV_LAST_NAME <> '' THEN
        SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION, ' P.LAST_NAME LIKE \'%', AV_LAST_NAME, '%\' AND ');
    END IF;
    
    IF AV_PUBLICATION IS NOT NULL AND AV_PUBLICATION <> '' THEN
         SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION, ' ( T9.TITLE LIKE \'%', AV_PUBLICATION, '%\' OR  T8.TITLE LIKE \'%', AV_PUBLICATION, '%\' ) AND');
    END IF;
    
    IF AV_CERTIFICATION IS NOT NULL AND AV_CERTIFICATION <> '' THEN
        SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION, ' ( T12.CERTIFICATION_NAME LIKE \'%', AV_CERTIFICATION, '%\' OR  T11.DESCRIPTION LIKE \'%', AV_CERTIFICATION, '%\' ) AND');
    END IF;
    
	IF AV_DEGREE_CODE IS NOT NULL AND AV_DEGREE_CODE <> '' THEN
        SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION, ' T13.DEGREE_CODE = ''', AV_DEGREE_CODE, ''' AND ');
    END IF;

    IF AV_KEYWORD IS NOT NULL AND AV_KEYWORD <> '' THEN
        SET LS_FILTER_CONDITION = CONCAT(LS_FILTER_CONDITION, ' EXISTS (SELECT 1
                FROM RESEARCHER_KEYWORD RK
                WHERE RK.PERSON_ID = P.PERSON_ID
                  AND (
                        EXISTS (
                            SELECT 1
                            FROM (
                                SELECT SK.SCIENCE_KEYWORD_CODE AS CODE
                                FROM SCIENCE_KEYWORD SK
                                WHERE SK.DESCRIPTION LIKE \'%', AV_KEYWORD, '%\'
                                UNION
                                SELECT RTA.RESRCH_TYPE_AREA_CODE AS CODE
                                FROM RESEARCH_TYPE_AREA RTA
                                WHERE RTA.DESCRIPTION LIKE \'%', AV_KEYWORD, '%\'
                                UNION
                                SELECT RTSA.RESRCH_TYPE_SUB_AREA_CODE AS CODE
                                FROM RESEARCH_TYPE_SUB_AREA RTSA
                                WHERE RTSA.DESCRIPTION LIKE \'%', AV_KEYWORD, '%\'
                            ) AS COMBINEDKEYWORDS
                            WHERE COMBINEDKEYWORDS.CODE = RK.SCIENCE_KEYWORD_CODE
                               OR COMBINEDKEYWORDS.CODE = RK.RESRCH_TYPE_AREA_CODE
                               OR COMBINEDKEYWORDS.CODE = RK.RESRCH_TYPE_SUB_AREA_CODE
                        )
                  )
            ) AND ');
    END IF;

	SET LS_SORT_TYPE = 'P.LAST_NAME ASC';

   SET LS_DYN_SQL =CONCAT('
        SELECT DISTINCT 
            P.PERSON_ID,
            P.FULL_NAME,
            P.ALIAS_NAME,
            TRIM(P.FIRST_NAME) as FIRST_NAME,
            TRIM(P.LAST_NAME) as LAST_NAME,
            U.DISPLAY_NAME AS DEPARTMENT,
            (
                SELECT GROUP_CONCAT(TITLE ORDER BY SORT_ORDER SEPARATOR " | ") 
                FROM (
                    SELECT DISTINCT T1.TITLE, T1.SORT_ORDER
                    FROM RESEARCHER_AFFILIATION T1 
                    WHERE P.PERSON_ID = T1.PERSON_ID 
                    LIMIT 3
                ) AS T3
            ) AS AFFILIATIONS,
            T5.FILE_DATA_ID ,
			(
			  SELECT GROUP_CONCAT(IFNULL(T.ORCID_TITLE,T.RESEARCHER_TITLE) SEPARATOR ", ") 
                FROM (
                    SELECT 
                        EXT.SORT_ORDER,
                        EXT.UPDATE_TIMESTAMP,
                        ORCID.TITLE AS ORCID_TITLE,
                        RESEARCHER.TITLE AS RESEARCHER_TITLE,
                        IFNULL(
                            RESEARCHER.PUBLICATION_DATE , 
                            IF(orcid.PUBLICATION_MONTH REGEXP ''^[0-9]+$'',
                                STR_TO_DATE(
                                    CONCAT(orcid.PUBLICATION_YEAR,''-'',LPAD(orcid.PUBLICATION_MONTH, 2, ''0''), ''-'', orcid.PUBLICATION_DAY),
                                    ''%Y-%m-%d''
                                ),
                                STR_TO_DATE(
                                    CONCAT(orcid.PUBLICATION_DAY,'', '', orcid.PUBLICATION_MONTH,'', '', orcid.PUBLICATION_YEAR),
                                    ''%d, %M, %Y''
                                )
                            )
                        ) AS PUBLICATION_DATE
                    FROM 
                        PUBLICATION_EXT EXT
                    LEFT JOIN 
                        ORCID_WORK ORCID ON EXT.PUBLICATION_TYPE_ID = ORCID.PUT_CODE AND PUBLICATION_TYPE_CODE = 1
                    LEFT JOIN  
                        RESEARCHER_PUBLICATION RESEARCHER ON EXT.PUBLICATION_TYPE_ID = RESEARCHER.RESEARCHER_PUBLICATION_ID AND PUBLICATION_TYPE_CODE = 2
                    WHERE 
                        PERSON_ID = P.PERSON_ID 
					ORDER BY 
                    EXT.SORT_ORDER DESC, 
                    PUBLICATION_DATE DESC, 
                    EXT.UPDATE_TIMESTAMP DESC 
                    LIMIT 5
                ) T
            ) AS PUBLICATION,
            p.SALUTATION
        FROM 
            PERSON P  
        INNER JOIN 
            UNIT U ON P.HOME_UNIT = U.UNIT_NUMBER 
		LEFT JOIN 
			RESEARCHER_ATTACHMENT T5 ON P.PERSON_ID = T5.PERSON_ID AND RESEARCHER_ATTACH_TYPE_CODE = 1
		LEFT JOIN PUBLICATION_EXT T7 ON P.PERSON_ID = T7.PERSON_ID  
        LEFT JOIN ORCID_WORK T8 ON T7.PUBLICATION_TYPE_ID  = T8.PUT_CODE
        LEFT JOIN RESEARCHER_PUBLICATION T9 ON T7.PUBLICATION_TYPE_ID  = T9.RESEARCHER_PUBLICATION_ID
        LEFT JOIN PERSON_TRAINING T10 ON P.PERSON_ID = T10.PERSON_ID
        LEFT JOIN TRAINING T11 ON T10.TRAINING_CODE = T11.TRAINING_CODE
        LEFT JOIN PERSON_TRAINING_EXT  T12 ON T12.PERSON_TRAINING_ID =  T10.PERSON_TRAINING_ID  
        LEFT JOIN PERSON_DEGREE T13 ON P.PERSON_ID = T13.PERSON_ID
        WHERE ', LS_FILTER_CONDITION, ' 1 = 1 and P.FULL_NAME IS NOT NULL
        GROUP BY 
            P.PERSON_ID
        ORDER BY ', LS_SORT_TYPE  , ' LIMIT ', AV_LIMIT, ' OFFSET ', LS_OFFSET
    );

      SET @QUERY_STATEMENT = LS_DYN_SQL;
      PREPARE EXECUTABLE_STAEMENT FROM @QUERY_STATEMENT;
      EXECUTE EXECUTABLE_STAEMENT;
END
