CREATE PROCEDURE `GET_KEY_PERSONS_DISCLOSURE_DETAILS`(
    IN AV_MODULE_CODE INT(3),
    IN AV_MODULE_ITEM_ID VARCHAR(20)
)
    DETERMINISTIC
BEGIN
    DECLARE TIME_INTERVAL_IN_DAYS INT DEFAULT 90;

    -- Temporary table to fetch key persons
    CREATE TEMPORARY TABLE IF NOT EXISTS TMP_KEY_PERSONS (PERSON_ID VARCHAR(20));

    -- Only handling DEV PROPOSAL (module code = 3)
    IF AV_MODULE_CODE = 3 THEN
        INSERT INTO TMP_KEY_PERSONS (PERSON_ID)
        SELECT PERSON_ID
        FROM EPS_PROPOSAL_PERSONS
        WHERE PROPOSAL_ID = AV_MODULE_ITEM_ID
          AND PERSON_ID IS NOT NULL;
    END IF;

    -- To select disclosure per person in order such that
    -- if latest certified else latest pending else null
    WITH ranked_disclosures AS (
        SELECT *,
		ROW_NUMBER() OVER (
                PARTITION BY PERSON_ID 
                ORDER BY 
                   CASE WHEN CERTIFIED_AT IS NOT NULL THEN 0 ELSE 1 END,
                    CERTIFIED_AT DESC,
                    CREATE_TIMESTAMP DESC
        ) as rn
        FROM COI_DISCLOSURE
        WHERE VERSION_STATUS IN ('ACTIVE', 'PENDING')
        AND (FCOI_TYPE_CODE <> '2' 
             OR (FCOI_TYPE_CODE = '2' AND COI_PROJECT_TYPE_CODE IN (1, 3)))
        AND (CERTIFIED_AT IS NULL OR CERTIFIED_AT >= DATE_SUB(NOW(), INTERVAL TIME_INTERVAL_IN_DAYS DAY))
    ),
    filtered_disclosures AS (
        SELECT * FROM ranked_disclosures WHERE rn = 1
    )

    -- Final select with LEFT JOIN to include persons without disclosures
    SELECT 
        kp.PERSON_ID,
        epp.FULL_NAME AS PERSON_FULL_NAME,
        epr.DESCRIPTION AS PERSON_ROLE,
        cd.DISCLOSURE_ID,
        cd.DISCLOSURE_NUMBER,
        cd.VERSION_NUMBER,
        cd.VERSION_STATUS,
        cd.FCOI_TYPE_CODE,
        cd.REVIEW_STATUS_CODE AS DISCLOSURE_REVIEW_STATUS_CODE,
        crst.DESCRIPTION AS DISCLOSURE_REVIEW_STATUS,
        cd.EXPIRATION_DATE,
        cd.CERTIFIED_BY,
        cd.CERTIFIED_AT,
        CASE 
            WHEN cd.REVIEW_STATUS_CODE IS NULL THEN 'Yet to Disclose'
            WHEN cd.REVIEW_STATUS_CODE IN ('1', '5', '6') THEN 'Pending'
            WHEN cd.REVIEW_STATUS_CODE IN ('2', '3', '4', '7', '8') THEN 'Completed'
            ELSE 'Not Applicable'
        END AS DISCLOSURE_STATE
    FROM TMP_KEY_PERSONS kp
    LEFT JOIN filtered_disclosures cd
        ON cd.PERSON_ID = kp.PERSON_ID
    LEFT JOIN EPS_PROPOSAL_PERSONS epp 
        ON epp.PERSON_ID = kp.PERSON_ID 
       AND epp.PROPOSAL_ID = AV_MODULE_ITEM_ID
    LEFT JOIN EPS_PROP_PERSON_ROLE epr 
        ON epp.PROP_PERSON_ROLE_ID = epr.PROP_PERSON_ROLE_ID
    LEFT JOIN COI_REVIEW_STATUS_TYPE crst 
        ON cd.REVIEW_STATUS_CODE = crst.REVIEW_STATUS_CODE;

    SET SQL_SAFE_UPDATES = 0;
    DELETE FROM TMP_KEY_PERSONS;
    SET SQL_SAFE_UPDATES = 1;

    DROP TEMPORARY TABLE IF EXISTS TMP_KEY_PERSONS;
END
