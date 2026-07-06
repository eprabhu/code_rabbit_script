CREATE PROCEDURE `UPD_MYLEARN_PERSON_TRAINING`(AV_USER_ID VARCHAR(60)
,AV_MYLEARNING_TRAINING_CODE  VARCHAR(10)
,AV_ACKNOWLED_DATE  varchar(30)
,AV_UPDATE_USER  varchar(30)
,AV_FOLLOWUP_DATE  varchar(30)
,AV_DATE_REQUESTED  varchar(30)
,AV_DATE_SUBMITTED  varchar(30)
)
BEGIN
DECLARE LI_TRAINING_COUNT INT(3) DEFAULT NULL;
DECLARE LS_LOCAL_COEUS_TRAINING_CODE VARCHAR(10)  DEFAULT 0;
DECLARE LI_PERSON_TRAINING_ID INT(11) DEFAULT NULL;
DECLARE LS_PERSON_ID VARCHAR(40);

	BEGIN
	SELECT COUNT(*) INTO LI_TRAINING_COUNT
	FROM MYLEARNING_TRAINING_CODE
	WHERE MYLEARNING_TRAINING_CODE = AV_MYLEARNING_TRAINING_CODE;
	select AV_ACKNOWLED_DATE;
	IF(LI_TRAINING_COUNT > 0) THEN
		
		SELECT IFNULL(COEUS_TRAINING_CODE, -1) INTO LS_LOCAL_COEUS_TRAINING_CODE
		FROM MYLEARNING_TRAINING_CODE
		WHERE MYLEARNING_TRAINING_CODE = AV_MYLEARNING_TRAINING_CODE;
					
		IF(LS_LOCAL_COEUS_TRAINING_CODE > 0) THEN
								
			SET LI_TRAINING_COUNT = NULL;
			SELECT COUNT(*)	INTO LI_TRAINING_COUNT
			FROM PERSON_TRAINING PT
			,PERSON P
			WHERE UPPER(P.USER_NAME) = UPPER(AV_USER_ID)
			AND PT.TRAINING_CODE = LS_LOCAL_COEUS_TRAINING_CODE
			AND P.PERSON_ID = PT.PERSON_ID;
								
			IF(LI_TRAINING_COUNT > 0) THEN
				UPDATE PERSON_TRAINING
				SET DATE_ACKNOWLEDGED = str_to_date(AV_ACKNOWLED_DATE, '%m/%d/%Y %h:%i:%s')
				,UPDATE_TIMESTAMP = NOW()
				,UPDATE_USER = AV_UPDATE_USER
				WHERE PERSON_ID = (SELECT PERSON_ID
									FROM PERSON
									WHERE USER_NAME = UPPER(AV_USER_ID))
				AND TRAINING_CODE = LS_LOCAL_COEUS_TRAINING_CODE
				AND TRIM(DATE_ACKNOWLEDGED) < TRIM(str_to_date(AV_ACKNOWLED_DATE,'%m/%d/%Y %h:%i:%s'));
			ELSEIF LI_TRAINING_COUNT = 0 then
                                        
				SELECT (IFNULL(MAX(PERSON_TRAINING_ID), 0) + 1)  INTO LI_PERSON_TRAINING_ID FROM PERSON_TRAINING;
				SELECT PERSON_ID INTO LS_PERSON_ID FROM PERSON WHERE USER_NAME = UPPER(AV_USER_ID);
				INSERT INTO PERSON_TRAINING (
												PERSON_ID
												,PERSON_TRAINING_ID 
												,TRAINING_CODE
												,DATE_REQUESTED
												,DATE_SUBMITTED
												,DATE_ACKNOWLEDGED
												,FOLLOWUP_DATE
												,SCORE
												,COMMENTS
												,UPDATE_TIMESTAMP
												,UPDATE_USER
												,IS_NON_EMPLOYEE
												)
												VALUES (
												LS_PERSON_ID
												,LI_PERSON_TRAINING_ID
												,LS_LOCAL_COEUS_TRAINING_CODE
												,str_to_date(AV_DATE_REQUESTED, '%m/%d/%Y %h:%i:%s')
												,str_to_date(AV_DATE_SUBMITTED, '%m/%d/%Y %h:%i:%s')
												,str_to_date(AV_ACKNOWLED_DATE, '%m/%d/%Y %h:%i:%s')
												,str_to_date(AV_FOLLOWUP_DATE, '%m/%d/%Y %h:%i:%s')
												,NULL
												,NULL
												,now()
												,AV_UPDATE_USER
												,'N'
												);
					insert into person_training_ext (
												PERSON_TRAINING_ID
                                                , UPDATE_TIMESTAMP
                                                , UPDATE_USER
                                                , SOURCE_TYPE_CODE
                                                , STATUS
                                                )values(
                                                  LI_PERSON_TRAINING_ID
                                                , now()
                                                , 'admin'
                                                , 3
                                                , 'A' 
                                                );
								   commit; 
			END IF;
		END IF;
	END IF;
	END;
END
