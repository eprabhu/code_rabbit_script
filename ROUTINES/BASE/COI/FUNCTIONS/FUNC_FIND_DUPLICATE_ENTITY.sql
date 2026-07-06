

CREATE FUNCTION `FUNC_FIND_DUPLICATE_ENTITY`(
    AV_PRIMARY_NAME VARCHAR(500),
    AV_COUNTRY_CODE VARCHAR(3),
    AV_DUNS_NUMBER VARCHAR(20),
    AV_UEI_NUMBER VARCHAR(20),
    AV_CAGE_NUMBER VARCHAR(20),
    AV_HUMAN_SUB_ASSURANCE VARCHAR(50),
    AV_ANIMAL_WELFARE_ASSURANCE VARCHAR(50)
) RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE LS_FOUND_ENTITY_ID INT DEFAULT NULL;

    
    SELECT ENTITY_ID INTO LS_FOUND_ENTITY_ID
    FROM entity
    WHERE 
        DUNS_NUMBER = AV_DUNS_NUMBER
        OR UEI_NUMBER = AV_UEI_NUMBER
        OR CAGE_NUMBER = AV_CAGE_NUMBER
        OR HUMAN_SUB_ASSURANCE = AV_HUMAN_SUB_ASSURANCE
        OR ANIMAL_WELFARE_ASSURANCE = AV_ANIMAL_WELFARE_ASSURANCE
        OR ANIMAL_ACCREDITATION = AV_ANIMAL_WELFARE_ASSURANCE
    ORDER BY
        CASE
            -- Highest weight if both DUNS_NUMBER and UEI_NUMBER match
            WHEN DUNS_NUMBER = AV_DUNS_NUMBER AND UEI_NUMBER = AV_UEI_NUMBER THEN 0
            -- Next highest if both CAGE_NUMBER and HUMAN_SUB_ASSURANCE match
            WHEN CAGE_NUMBER = AV_CAGE_NUMBER AND HUMAN_SUB_ASSURANCE = AV_HUMAN_SUB_ASSURANCE THEN 1
            -- Assign weights for individual matches
            WHEN DUNS_NUMBER = AV_DUNS_NUMBER THEN 2
            WHEN UEI_NUMBER = AV_UEI_NUMBER THEN 3
            WHEN CAGE_NUMBER = AV_CAGE_NUMBER THEN 4
            WHEN HUMAN_SUB_ASSURANCE = AV_HUMAN_SUB_ASSURANCE THEN 5
            WHEN ANIMAL_WELFARE_ASSURANCE = AV_ANIMAL_WELFARE_ASSURANCE THEN 6
            WHEN ANIMAL_ACCREDITATION = AV_ANIMAL_WELFARE_ASSURANCE THEN 7
            ELSE 8
        END
    LIMIT 1;

    
    IF LS_FOUND_ENTITY_ID IS NOT NULL THEN
        RETURN LS_FOUND_ENTITY_ID;
    END IF;

   
   
    SELECT ENTITY_ID INTO LS_FOUND_ENTITY_ID
    FROM entity
    WHERE 
        TRIM(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(LOWER(PRIMARY_NAME), ',', ''),
                        '.', ''),
                    '-', ''),
                '/', ''),
            ' ', '')
        ) = TRIM(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(LOWER(AV_PRIMARY_NAME), ',', ''),
                        '.', ''),
                    '-', ''),
                '/', ''),
            ' ', '')
        )
        AND COUNTRY_CODE = AV_COUNTRY_CODE;

   
    RETURN LS_FOUND_ENTITY_ID;
END
