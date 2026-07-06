CREATE FUNCTION FN_VALIDATE_AUTO_AWARD_CREATION(
    AV_PERSON_ID VARCHAR(40),
	AV_UNIT_NUMBER VARCHAR(50)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE LI_COUNT INT;
    -- Get the role count for the person with the right and unit validation
   SELECT COUNT(1) INTO LI_COUNT FROM PERSON_ROLES PR,
        (SELECT ROLE_ID,RT.RIGHT_NAME 
           FROM ROLE_RIGHTS RR,
                RIGHTS RT
            WHERE RR.RIGHT_ID = RT.RIGHT_ID
              AND RT.RIGHT_NAME IN ('CREATE_AWARD')
        ) RLE
       WHERE PR.PERSON_ID = AV_PERSON_ID
        AND
          (( PR. DESCEND_FLAG = 'Y' AND AV_UNIT_NUMBER IN (SELECT CHILD_UNIT_NUMBER
                                                                 FROM UNIT_WITH_CHILDREN 
                                                                                  WHERE UNIT_NUMBER = PR.UNIT_NUMBER
             ))OR ( PR. DESCEND_FLAG = 'N' AND PR.UNIT_NUMBER = AV_UNIT_NUMBER )
            )
         AND RLE.ROLE_ID = PR.ROLE_ID;

    IF LI_COUNT > 0 THEN
        RETURN 'TRUE';
    ELSE
        RETURN 'FALSE';
    END IF;
END
