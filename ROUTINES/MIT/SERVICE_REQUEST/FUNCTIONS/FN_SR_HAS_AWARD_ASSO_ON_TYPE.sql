CREATE FUNCTION `FN_SR_HAS_AWARD_ASSO_ON_TYPE`(
    AV_SR_HEADER_ID INT
) RETURNS varchar(10) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE LI_FLAG INT DEFAULT 0;
    DECLARE LS_PROC_LOC VARCHAR(200) DEFAULT '';
    DECLARE LS_ERROR_MSG VARCHAR(4000);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno    = MYSQL_ERRNO,
            @msg      = MESSAGE_TEXT;

        SET @full_error = CONCAT(@msg,'/',LS_PROC_LOC);
        SET LS_ERROR_MSG = @full_error;
        RESIGNAL SET MESSAGE_TEXT = LS_ERROR_MSG;
    END;

    /* Validate SR type */
    SET LS_PROC_LOC = 'CHK_SR_TYPE';

    SELECT COUNT(1)
      INTO LI_FLAG
      FROM SR_HEADER
     WHERE SR_HEADER_ID = AV_SR_HEADER_ID
       AND TYPE_CODE  in ('2','4','6','12','43','45','46','55');

    IF LI_FLAG = 0 THEN
        RETURN 'TRUE';
    END IF;

    /* Check if Award association exists */
    SET LS_PROC_LOC = 'CHK_ASSOC_AWARD';

    IF EXISTS (
        SELECT 1
          FROM ASSOC_SR
         WHERE SR_HEADER_ID = AV_SR_HEADER_ID
           AND MODULE_CODE  = 1
         LIMIT 1
    ) THEN
        RETURN 'TRUE';
    END IF;

    RETURN 'FALSE';

END
