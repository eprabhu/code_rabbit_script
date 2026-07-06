-- `GET_UNIT_ORGANIZATION`; 

CREATE PROCEDURE `GET_UNIT_ORGANIZATION`(AV_UNIT_NUMBER VARCHAR(50))
    DETERMINISTIC
BEGIN
DECLARE LS_UNIT_NUMBER LONGTEXT;
DECLARE LS_CURRENT_PARENT LONGTEXT;
declare li_count int;
SET LS_UNIT_NUMBER = AV_UNIT_NUMBER; 
SET li_count = 0;
			select count(*) into li_count 
			from unit 
            WHERE UNIT_NUMBER = LS_UNIT_NUMBER 
            and trim(ORGANIZATION_ID) <> '' and ORGANIZATION_ID is not null;
            IF li_count > 0 THEN
						select ORGANIZATION_ID
						from unit 
						where UNIT_NUMBER = LS_UNIT_NUMBER
						and trim(ORGANIZATION_ID) <> '' and ORGANIZATION_ID is not null
						limit 1;
            ELSE
					  REPEAT
							SELECT GROUP_CONCAT(parent_UNIT_NUMBER SEPARATOR ',') INTO LS_CURRENT_PARENT FROM UNIT WHERE FIND_IN_SET(UNIT_NUMBER, LS_UNIT_NUMBER);
								select count(*) into li_count 
								from unit 
								where FIND_IN_SET(UNIT_NUMBER,LS_CURRENT_PARENT)
								and trim(ORGANIZATION_ID) <> '' and ORGANIZATION_ID is not null;
								IF (LS_CURRENT_PARENT IS NOT NULL) and (li_count =0 ) THEN 
									SET LS_UNIT_NUMBER = LS_CURRENT_PARENT ;
								END IF;
						   UNTIL (LS_CURRENT_PARENT IS NULL ) or (li_count > 0) END REPEAT;
							select ORGANIZATION_ID
							from unit 
							where FIND_IN_SET(UNIT_NUMBER,LS_CURRENT_PARENT)
							and trim(ORGANIZATION_ID) <> '' and ORGANIZATION_ID is not null
							limit 1;
            END IF;
END
