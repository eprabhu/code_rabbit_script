


CREATE PROCEDURE `EVALUATE_PER_ENT_MATRIX`(
    AV_PERSON_ENTITY_ID INT,
    AV_PERSON_ID VARCHAR(60)
)
    DETERMINISTIC
BEGIN

    DECLARE LI_MATRIX_QUESTION_ID INT DEFAULT 0;
    DECLARE LI_ANSWER_COUNT INT DEFAULT 0;
    DECLARE LI_QUESTION_COUNT INT DEFAULT 0;
    DECLARE LI_FIN_REL_COUNT INT DEFAULT 0;
    DECLARE LS_COLUMN_VALUE VARCHAR(500) DEFAULT NULL;
    DECLARE LS_RELATIONSHIP_TYPE_CODE VARCHAR(3) DEFAULT NULL;
    DECLARE LS_COMMENTS VARCHAR(500) DEFAULT NULL;
    DECLARE LS_COLUMN_LABEL VARCHAR(500) DEFAULT NULL;

    DECLARE DONE1 INT DEFAULT FALSE;

    -- Check the answer count
    SELECT COUNT(*) INTO LI_ANSWER_COUNT
    FROM PER_ENT_MATRIX_ANSWER
    WHERE PERSON_ENTITY_ID = AV_PERSON_ENTITY_ID;

    -- IF-ELSE block to handle the new condition
    IF LI_ANSWER_COUNT = 0 THEN
        DELETE FROM PERSON_ENTITY_RELATIONSHIP WHERE PERSON_ENTITY_ID = AV_PERSON_ENTITY_ID AND VALID_PERS_ENTITY_REL_TYP_CODE = 1;
    ELSE
        -- EVALUATION_BLOCK: BEGIN

        SELECT COUNT(*) INTO LI_QUESTION_COUNT 
        FROM PER_ENT_MATRIX_QUESTION;

        IF LI_ANSWER_COUNT > 0 THEN

            SET @relations_set = COALESCE((
                SELECT GROUP_CONCAT(VALID_PERS_ENTITY_REL_TYP_CODE ORDER BY VALID_PERS_ENTITY_REL_TYP_CODE)
                FROM PERSON_ENTITY_RELATIONSHIP
                WHERE PERSON_ENTITY_ID = AV_PERSON_ENTITY_ID
            ), '');

            IF FIND_IN_SET('1', @relations_set) IS NULL OR FIND_IN_SET('1', @relations_set) = 0 THEN

                INSERT INTO PERSON_ENTITY_RELATIONSHIP (PERSON_ENTITY_ID, VALID_PERS_ENTITY_REL_TYP_CODE, UPDATE_TIMESTAMP, UPDATE_USER)
                VALUES (AV_PERSON_ENTITY_ID, '1', utc_timestamp(), 'system');

            END IF;

            SET @after_evaluation_relations_set = COALESCE((
                SELECT GROUP_CONCAT(VALID_PERS_ENTITY_REL_TYP_CODE ORDER BY VALID_PERS_ENTITY_REL_TYP_CODE)
                FROM PERSON_ENTITY_RELATIONSHIP
                WHERE PERSON_ENTITY_ID = AV_PERSON_ENTITY_ID
            ), '');

            IF STRCMP(@relations_set, @after_evaluation_relations_set) != 0 THEN

                SELECT 'New relation added' AS MESSAGE, 
                       T1.DISCLOSURE_ID AS DISCLOSURE_ID, 
                       T1.REVIEW_STATUS_CODE AS REVIEW_STATUS_CODE
                FROM COI_DISCLOSURE T1
                WHERE T1.FCOI_TYPE_CODE IN ('1', '3')
                  AND T1.PERSON_ID = AV_PERSON_ID
                  AND T1.VERSION_STATUS = 'PENDING'

                UNION ALL

                SELECT 'New relation added' AS MESSAGE, 
                       T1.DISCLOSURE_ID AS DISCLOSURE_ID, 
                       T1.REVIEW_STATUS_CODE AS REVIEW_STATUS_CODE
                FROM COI_DISCLOSURE T1
                WHERE T1.FCOI_TYPE_CODE IN ('1', '3')
                  AND T1.PERSON_ID = AV_PERSON_ID
                  AND T1.VERSION_STATUS = 'ACTIVE'
                  AND NOT EXISTS (
                      SELECT 1
                      FROM COI_DISCLOSURE T2
                      WHERE T2.PERSON_ID = AV_PERSON_ID
                        AND T2.FCOI_TYPE_CODE IN ('1', '3')
                        AND T2.VERSION_STATUS = 'PENDING'
                  )

                UNION ALL

                SELECT 'New relation added' AS MESSAGE, 
                       0 AS DISCLOSURE_ID, 
                       0 AS REVIEW_STATUS_CODE
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM COI_DISCLOSURE T1
                    WHERE T1.FCOI_TYPE_CODE IN ('1', '3')
                      AND T1.PERSON_ID = AV_PERSON_ID
                      AND (
                          T1.VERSION_STATUS = 'PENDING' 
                          OR (
                              T1.VERSION_STATUS = 'ACTIVE'
                              AND NOT EXISTS (
                                  SELECT 1
                                  FROM COI_DISCLOSURE T2
                                  WHERE T2.PERSON_ID = AV_PERSON_ID
                                    AND T2.FCOI_TYPE_CODE IN ('1', '3')
                                    AND T2.VERSION_STATUS = 'PENDING'
                              )
                          )
                      )
                );

            ELSE
                SELECT 'No new relation added' AS MESSAGE, 0 AS DISCLOSURE_ID, 0 AS REVIEW_STATUS_CODE;
            END IF;

        END IF;

        -- END EVALUATION_BLOCK;
    END IF;
    
    COMMIT;

END