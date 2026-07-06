-- `FN_GET_CHILD_NODES`; 

CREATE FUNCTION `FN_GET_CHILD_NODES`(VALUE INT) RETURNS int(11)
    DETERMINISTIC
BEGIN
        DECLARE _ID INT;
        DECLARE _PARENT INT;
        DECLARE _NEXT INT;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET @ID = NULL;
        SET _PARENT = @ID;
        SET _ID = -1;
        IF @ID IS NULL THEN
                RETURN NULL;
        END IF;
        LOOP
                SELECT  MIN(ID)
                INTO    @ID
                FROM    UNIT_TMP
                WHERE   PARENT_ID = _PARENT
                         AND ID > _ID;
                IF @ID IS NOT NULL OR _PARENT = @START_WITH THEN
                        SET @LEVEL = @LEVEL + 1;
                        RETURN @ID;
                END IF;
                SET @LEVEL := @LEVEL - 1;
                SELECT  ID, PARENT_ID
                INTO    _ID, _PARENT
                FROM    UNIT_TMP
                WHERE   ID = _PARENT;
        END LOOP;
END
