

CREATE PROCEDURE `MIGRATE_PERSON_TRAINING`(AV_FEED_INFO_ID INT)
BEGIN
DECLARE LS_PERSON_ID                 VARCHAR(40);
DECLARE LI_TRAINING_CODE             INT;
DECLARE LI_COUNT                     INT;
DECLARE LI_COUNT_RCR                 INT DEFAULT 0;
DECLARE LI_COUNT_HUMAN               INT DEFAULT 0;
DECLARE LI_COUNT_GCP                 INT DEFAULT 0;
DECLARE LI_COUNT_COI                 INT DEFAULT 0;
DECLARE LI_COUNT_IACUC               INT DEFAULT 0;
DECLARE LI_COUNT_UFI                 INT DEFAULT 0;
DECLARE LI_COUNT_EXPORT              INT DEFAULT 0;
DECLARE LI_TRAINING_NO               INT;
DECLARE LD_FOLLOWUP_DATE             DATETIME;
DECLARE LI_INSERTS                   INT DEFAULT 0;
DECLARE LI_MODULE_CODE               INT;
DECLARE LI_CITI_DATA_STAGE_NUMBER    VARCHAR(255);
DECLARE LS_GROUP                     VARCHAR(255);
DECLARE LD_DATE_COMPLETED            VARCHAR(255);
DECLARE LI_SCORE                     VARCHAR(1);
DECLARE NOT_FOUND                    INT DEFAULT 0;
DECLARE LS_ERROR_MSG 				 VARCHAR(4000);										

DECLARE CUR_CITI_DATA CURSOR FOR
	SELECT T1.CUSTOM_FIELD_2, T1.GROUP, T1.STAGE_NUMBER, STR_TO_DATE(T1.DATE_COMPLETED, '%m/%d/%Y %r') ,CASE WHEN T1.PASSING_SCORE < T1.EXAM_SCORE THEN 'P' ELSE 'F' END AS SCORE
	FROM CITI_TRAINING_FEED_DETAILS T1
    INNER JOIN PERSON P1 ON P1.PERSON_ID = T1.CUSTOM_FIELD_2
    WHERE T1.CUSTOM_FIELD_2 IS NOT NULL
    ORDER BY T1.CUSTOM_FIELD_2;  
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN	
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			 
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			
			SELECT @full_error INTO LS_ERROR_MSG;
            
			INSERT INTO FIBI_COI_INT_ERROR_LOG (SECTION,ERROR_TYPE,ERROR_MESSAGE,ERROR_DETAILS,MODULE_CODE,MODULE_ITEM_KEY, 
			MODULE_SUB_ITEM_KEY,UPDATE_TIMESTAMP) VALUES ('CITI-INTEGRATION','DATABASE',LS_ERROR_MSG, CONCAT('ERROR IN MIGRATE_PERSON_TRAINING : ',LS_ERROR_MSG,' AT ',LS_PROC_LOC),
			'6',LS_PERSON_ID,NULL,CURRENT_TIMESTAMP);		
	END;
    
DECLARE CONTINUE HANDLER FOR NOT FOUND
	SET NOT_FOUND = 1;
    
SET SQL_SAFE_UPDATES  = 0;

DELETE FROM CITI_TRAINING_FEED_EXCEPTION WHERE ERROR_TYPE = 'MIGRATION';

-- PERSON ID IS NULL:

	INSERT INTO CITI_TRAINING_FEED_EXCEPTION (ERROR_CODE,ERROR_MESSAGE,ERROR_TYPE,ERROR_AT,FEED_INFO_ID,UPDATE_TIMESTAMP,UPDATED_BY)
	SELECT 'DB0002',concat('Person ' , IFnull(LAST_NAME, '') , ', ' , IFnull(FIRST_NAME, '')  , ' is missing person id in CITI_TRAINING_FEED_DETAILS table'),'MIGRATION','PROCEDURE/MIGRATION_PERSON_TRAINING',AV_FEED_INFO_ID,UTC_TIMESTAMP(),'vineeth' FROM CITI_TRAINING_FEED_DETAILS
	WHERE CUSTOM_FIELD_2 IS NULL;

-- PERSON ID IS NOT PRESENT IN PERSON TABLE:

	INSERT INTO CITI_TRAINING_FEED_EXCEPTION (ERROR_CODE,ERROR_MESSAGE,ERROR_TYPE,ERROR_AT,FEED_INFO_ID,UPDATE_TIMESTAMP,UPDATED_BY)                
    SELECT DISTINCT 'DB0002',CONCAT(CUSTOM_FIELD_2,' - Person does not exists in database'),'MIGRATION','PROCEDURE/MIGRATION_PERSON_TRAINING',AV_FEED_INFO_ID,UTC_TIMESTAMP(),'vineeth'
	FROM CITI_TRAINING_FEED_DETAILS T1
    WHERE T1.CUSTOM_FIELD_2 IS NOT NULL
    AND T1.CUSTOM_FIELD_2 NOT IN (SELECT DISTINCT PERSON_ID FROM PERSON); 
    


OPEN CUR_CITI_DATA;
loop_label: LOOP
SET NOT_FOUND = 0;
   FETCH CUR_CITI_DATA
   INTO LS_PERSON_ID, LS_GROUP, LI_CITI_DATA_STAGE_NUMBER, LD_DATE_COMPLETED, LI_SCORE;
   IF NOT_FOUND = 1 THEN LEAVE loop_label;
   END IF;

                        SET LI_COUNT_RCR  = 0;
                        SET LI_COUNT_HUMAN = 0;
                        SET LI_COUNT_GCP = 0;
                        SET LI_COUNT_COI = 0;
                        SET LI_COUNT_IACUC = 0;
                        SET LI_COUNT_UFI = 0;
                        SET LI_COUNT_EXPORT = 0;
						SET LI_COUNT = 0;
                        SET LI_TRAINING_NO = 0;
                        
                        SELECT IFNULL(max(T1.TRAINING_NUMBER),0),count(*)
                        INTO LI_TRAINING_NO,LI_COUNT
                        FROM PERSON_TRAINING T1
                        WHERE PERSON_ID = LS_PERSON_ID;

                    IF (LI_CITI_DATA_STAGE_NUMBER = 2 or LI_CITI_DATA_STAGE_NUMBER = 3) THEN
                    
                        IF (LI_COUNT = 0) THEN

							INSERT INTO CITI_TRAINING_FEED_EXCEPTION (ERROR_CODE,ERROR_MESSAGE,ERROR_TYPE,ERROR_AT,FEED_INFO_ID,UPDATE_TIMESTAMP,UPDATED_BY)
							VALUES('DB0002',CONCAT(LS_PERSON_ID,' - Person does not completed refresher but is missing basic couse'),'MIGRATION','PROCEDURE/MIGRATION_PERSON_TRAINING',AV_FEED_INFO_ID,UTC_TIMESTAMP(),'vineeth');
						END IF;

                    END IF;

                    -- FETCH TRAINING CODE:
                           SELECT 
                                CASE 
                                    WHEN LI_CITI_DATA_STAGE_NUMBER = 1 THEN 
                                        CASE 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('BIOMEDICAL RESEARCH INVESTIGATORS') THEN 15 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('SOCIAL & BEHAVIORAL RESEARCH INVESTIGATORS') THEN 14 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('IRB-SOCIAL-BEHAVIORAL-FRENCH') THEN 14 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('DATA OR SPECIMENS ONLY RESEARCH') THEN 17 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('IRB MEMBERS') THEN 26 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('HUMANITIES RESPONSIBLE CONDUCT OF RESEARCH') THEN 140 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('SOCIAL AND BEHAVIORAL RESPONSIBLE CONDUCT OF RESEARCH') THEN 141 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('RESPONSIBLE CONDUCT OF RESEARCH FOR ENGINEERS') THEN 142 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('PHYSICAL SCIENCE RESPONSIBLE CONDUCT OF RESEARCH') THEN 143 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('BIOMEDICAL RESPONSIBLE CONDUCT OF RESEARCH') THEN 144 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('RESPONSIBLE CONDUCT OF RESEARCH FOR ADMINISTRATORS') THEN 145 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('RECR REFRESHER') THEN 151 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('NIH/PHS CONFLICT OF INTEREST COURSE') THEN 54 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH THE IACUC') THEN 57 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('ASEPTIC SURGERY') THEN 59 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('ANTIBODY PRODUCTION IN ANIMALS') THEN 60 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('ESSENTIALS FOR IACUC MEMBERS') THEN 61 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('IACUC COMMUNITY MEMBER') THEN 62 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('REDUCING PAIN AND DISTRESS IN LABORATORY MICE AND RATS') THEN 63 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WILDLIFE RESEARCH') THEN 64 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH AMPHIBIANS IN RESEARCH SETTINGS.') THEN 65 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH CATS IN RESEARCH SETTINGS') THEN 66 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH DOGS IN RESEARCH SETTINGS') THEN 67 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH FERRETS IN RESEARCH SETTINGS') THEN 68 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH FISH IN RESEARCH SETTINGS') THEN 69 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH GERBILS IN RESEARCH SETTINGS') THEN 70 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH GUINEA PIGS IN RESEARCH SETTINGS') THEN 71 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH HAMSTERS IN RESEARCH SETTINGS') THEN 72 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH MICE IN RESEARCH') THEN 73 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH NON-HUMAN PRIMATES IN RESEARCH SETTINGS') THEN 74 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH RABBITS IN RESEARCH SETTINGS') THEN 75 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH RATS IN RESEARCH SETTINGS') THEN 76  
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH SWINE IN RESEARCH SETTINGS') THEN 77  
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH ZEBRAFISH (DANIO RERIO) IN RESEARCH SETTINGS') THEN 78 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('POST-APPROVAL MONITORING (PAM)') THEN 79  
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('MIT EXPORT CONTROL') THEN 90 
                                            WHEN UPPER(TRIM(substr(LS_GROUP,7))) = (substr('GCP ¿ SOCIAL AND BEHAVIORAL RESEARCH BEST PRACTICES FOR CLINICAL RESEARCH',7)) THEN 100 
                            				WHEN UPPER(TRIM(LS_GROUP)) = ('GCP FOR CLINICAL INVESTIGATIONS OF DEVICES') THEN 102 
                            				WHEN UPPER(TRIM(LS_GROUP)) = ('GCP FOR CLINICAL TRIALS WITH INVESTIGATIONAL DRUGS AND BIOLOGICS (ICH FOCUS)') THEN 104 
                            				WHEN UPPER(TRIM(LS_GROUP)) = ('GCP FOR CLINICAL TRIALS WITH INVESTIGATIONAL DRUGS AND MEDICAL DEVICES (U.S. FDA FOCUS)') THEN 106 
                            				WHEN UPPER(TRIM(LS_GROUP)) = ('UNDUE FOREIGN INFLUENCE: RISKS AND MITIGATIONS') THEN 120 
                                            ELSE NULL
                                        END
                                    ELSE
                                        CASE 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('BIOMEDICAL RESEARCH INVESTIGATORS') THEN 23 
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('SOCIAL & BEHAVIORAL RESEARCH INVESTIGATORS') THEN 25
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('DATA OR SPECIMENS ONLY RESEARCH') THEN 24
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('IRB MEMBERS') THEN 27
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('WORKING WITH THE IACUC - REFRESHER') THEN 58
                                            WHEN UPPER(TRIM(substr(LS_GROUP,7))) = (substr('GCP ¿ SOCIAL AND BEHAVIORAL RESEARCH BEST PRACTICES FOR CLINICAL RESEARCH',7)) THEN 101
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('GCP FOR CLINICAL INVESTIGATIONS OF DEVICES') THEN 103
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('GCP FOR CLINICAL TRIALS WITH INVESTIGATIONAL DRUGS AND BIOLOGICS (ICH FOCUS)') THEN 105
                                            WHEN UPPER(TRIM(LS_GROUP)) = ('GCP FOR CLINICAL TRIALS WITH INVESTIGATIONAL DRUGS AND MEDICAL DEVICES (U.S. FDA FOCUS)') THEN 107
                                            ELSE NULL
                                        END
                                END INTO LI_TRAINING_CODE;
    
                        SELECT IFNULL(T1.MODULE_CODE,0)
                        INTO  LI_MODULE_CODE
                        FROM TRAINING_MODULES T1
                        WHERE T1.TRAINING_CODE = LI_TRAINING_CODE;

                    IF (LI_MODULE_CODE = 0) THEN

						INSERT INTO CITI_TRAINING_FEED_EXCEPTION (ERROR_CODE,ERROR_MESSAGE,ERROR_TYPE,ERROR_AT,FEED_INFO_ID,UPDATE_TIMESTAMP,UPDATED_BY)
						VALUES('DB0002',CONCAT(LS_PERSON_ID,' - Module code is invalid'),'MIGRATION','PROCEDURE/MIGRATION_PERSON_TRAINING',AV_FEED_INFO_ID,UTC_TIMESTAMP(),'vineeth');

                    ELSE

                        IF (LI_MODULE_CODE = 7) THEN
							SET LD_FOLLOWUP_DATE = TIMESTAMPADD(MONTH, 36, LD_DATE_COMPLETED) - INTERVAL 1 DAY;

                            SELECT count(*)
                            INTO   LI_COUNT_HUMAN
                            FROM  PERSON_TRAINING p
                            where  p.PERSON_ID = LS_PERSON_ID
                            and    p.TRAINING_CODE = LI_TRAINING_CODE
                            and    DATE_FORMAT(p.DATE_SUBMITTED,'%m/%d/%Y') = DATE_FORMAT(LD_DATE_COMPLETED,'%m/%d/%Y')
                            and    DATE_FORMAT(p.FOLLOWUP_DATE,'%m/%d/%Y') = DATE_FORMAT(LD_FOLLOWUP_DATE,'%m/%d/%Y')
                            and    p.score = 'P';

                        ELSEIF (LI_MODULE_CODE = 103 ) THEN
							SET LD_FOLLOWUP_DATE = TIMESTAMPADD(MONTH, 36, LD_DATE_COMPLETED) - INTERVAL 1 DAY;

                            SELECT count(*)
                            INTO   LI_COUNT_GCP
                            FROM  PERSON_TRAINING p
                            where  p.PERSON_ID = LS_PERSON_ID
                            and    p.TRAINING_CODE = LI_TRAINING_CODE
                            and    DATE_FORMAT(p.DATE_SUBMITTED,'%m/%d/%Y') = DATE_FORMAT(LD_DATE_COMPLETED,'%m/%d/%Y')
                            and    DATE_FORMAT(p.FOLLOWUP_DATE,'%m/%d/%Y') = DATE_FORMAT(LD_FOLLOWUP_DATE,'%m/%d/%Y')
                            and    p.score = 'P';

                        ELSEIF (LI_MODULE_CODE = 100 ) THEN

                            SELECT count(*)
                            INTO   LI_COUNT_RCR
                            FROM   PERSON_TRAINING p
                            where  p.PERSON_ID = LS_PERSON_ID
                            and   ( (p.TRAINING_CODE = LI_TRAINING_CODE - 100 and truncate(LD_DATE_COMPLETED, 0) < str_to_date('07/01/2023','%m/%d/%Y'))
                                    or (p.TRAINING_CODE = LI_TRAINING_CODE and truncate(LD_DATE_COMPLETED, 0) > str_to_date('06/30/2023','%m/%d/%Y')))
                            and     DATE_FORMAT(p.DATE_SUBMITTED,'%m/%d/%Y') = DATE_FORMAT(LD_DATE_COMPLETED,'%m/%d/%Y')
                            and    p.score = 'P';

                       ELSEIF (LI_MODULE_CODE = 8) THEN               
     						SET LD_FOLLOWUP_DATE = TIMESTAMPADD(MONTH, 48, LD_DATE_COMPLETED) - INTERVAL 1 DAY;
                             
                            SELECT count(*)
                            INTO   LI_COUNT_COI
                            FROM  PERSON_TRAINING p
                            where  p.PERSON_ID = LS_PERSON_ID
                            and    p.TRAINING_CODE = LI_TRAINING_CODE
                            and    DATE_FORMAT(p.DATE_SUBMITTED,'%m/%d/%Y') = DATE_FORMAT(LD_DATE_COMPLETED,'%m/%d/%Y')
                            and    DATE_FORMAT(p.FOLLOWUP_DATE,'%m/%d/%Y') = DATE_FORMAT(LD_FOLLOWUP_DATE,'%m/%d/%Y')
                            and    p.score = 'P';
  
                       ELSEIF (LI_MODULE_CODE = 9) THEN
                            SELECT count(*)
                            INTO   LI_COUNT_IACUC
                            FROM  PERSON_TRAINING p
                            where  p.PERSON_ID = LS_PERSON_ID
                            and    p.TRAINING_CODE = LI_TRAINING_CODE
                            and    DATE_FORMAT(p.DATE_SUBMITTED,'%m/%d/%Y') = DATE_FORMAT(LD_DATE_COMPLETED,'%m/%d/%Y')
                            and    p.score = 'P';

                       ELSEIF (LI_MODULE_CODE = 104) THEN
							SET LD_FOLLOWUP_DATE = TIMESTAMPADD(MONTH, 36, LD_DATE_COMPLETED) - INTERVAL 1 DAY;

                            SELECT count(*)
                            INTO   LI_COUNT_UFI
                            FROM  PERSON_TRAINING p
                            where  p.PERSON_ID = LS_PERSON_ID
                            and    p.TRAINING_CODE = LI_TRAINING_CODE
                            and    DATE_FORMAT(p.DATE_SUBMITTED,'%m/%d/%Y') = DATE_FORMAT(LD_DATE_COMPLETED,'%m/%d/%Y')
                            and    DATE_FORMAT(p.FOLLOWUP_DATE,'%m/%d/%Y') = DATE_FORMAT(LD_FOLLOWUP_DATE,'%m/%d/%Y')
                            and    p.score = 'P';

                        ELSEIF (LI_MODULE_CODE = 200 ) THEN

                            SELECT count(*)
                            INTO   LI_COUNT_EXPORT
                            FROM  PERSON_TRAINING p
                            where  p.PERSON_ID = LS_PERSON_ID
                            and    p.TRAINING_CODE = LI_TRAINING_CODE
                            and    DATE_FORMAT(p.DATE_SUBMITTED,'%m/%d/%Y') = DATE_FORMAT(LD_DATE_COMPLETED,'%m/%d/%Y')
                            and    p.score = 'P';

                        END IF;

                        IF (LI_COUNT_HUMAN = 0) and (LI_COUNT_GCP = 0) and (LI_COUNT_RCR = 0) and (LI_COUNT_COI = 0) and (LI_COUNT_UFI = 0) and (LI_COUNT_IACUC = 0 and LI_COUNT_EXPORT = 0 ) THEN

                                IF (LI_MODULE_CODE = 7) THEN
									INSERT INTO PERSON_TRAINING (PERSON_ID, TRAINING_NUMBER, TRAINING_CODE, DATE_SUBMITTED, DATE_ACKNOWLEDGED, FOLLOWUP_DATE, SCORE, UPDATE_TIMESTAMP, UPDATE_USER,ACTIVE_FLAG)
									VALUES (LS_PERSON_ID, LI_TRAINING_NO + 1,  LI_TRAINING_CODE, LD_DATE_COMPLETED, LD_DATE_COMPLETED, LD_FOLLOWUP_DATE, NULL, UTC_TIMESTAMP(), 'vineeth','Y');

                                ELSEIF (LI_MODULE_CODE = 103) THEN
									INSERT INTO PERSON_TRAINING (PERSON_ID, TRAINING_NUMBER, TRAINING_CODE, DATE_SUBMITTED, DATE_ACKNOWLEDGED, FOLLOWUP_DATE, SCORE, UPDATE_TIMESTAMP, UPDATE_USER,ACTIVE_FLAG)
									VALUES (LS_PERSON_ID, LI_TRAINING_NO + 1,  LI_TRAINING_CODE, LD_DATE_COMPLETED, LD_DATE_COMPLETED, LD_FOLLOWUP_DATE, NULL, UTC_TIMESTAMP(), 'vineeth','Y');

                                ELSEIF (LI_MODULE_CODE = 100) THEN
									INSERT INTO PERSON_TRAINING (PERSON_ID, TRAINING_NUMBER, TRAINING_CODE, DATE_SUBMITTED, DATE_ACKNOWLEDGED, FOLLOWUP_DATE, SCORE, UPDATE_TIMESTAMP, UPDATE_USER,ACTIVE_FLAG)
									VALUES (LS_PERSON_ID, LI_TRAINING_NO + 1,  LI_TRAINING_CODE, LD_DATE_COMPLETED, LD_DATE_COMPLETED, LD_FOLLOWUP_DATE, NULL, UTC_TIMESTAMP(), 'vineeth','Y');

                                ELSEIF (LI_MODULE_CODE = 8) THEN
									INSERT INTO PERSON_TRAINING (PERSON_ID, TRAINING_NUMBER, TRAINING_CODE, DATE_SUBMITTED, DATE_ACKNOWLEDGED, FOLLOWUP_DATE, SCORE, UPDATE_TIMESTAMP, UPDATE_USER,ACTIVE_FLAG)
									VALUES (LS_PERSON_ID, LI_TRAINING_NO + 1,  LI_TRAINING_CODE, LD_DATE_COMPLETED, LD_DATE_COMPLETED, LD_FOLLOWUP_DATE, NULL, UTC_TIMESTAMP(), 'vineeth','Y');
							
                                ELSEIF (LI_MODULE_CODE = 9) THEN
									INSERT INTO PERSON_TRAINING (PERSON_ID, TRAINING_NUMBER, TRAINING_CODE, DATE_SUBMITTED, DATE_ACKNOWLEDGED, FOLLOWUP_DATE, SCORE, UPDATE_TIMESTAMP, UPDATE_USER,ACTIVE_FLAG)
									VALUES (LS_PERSON_ID, LI_TRAINING_NO + 1,  LI_TRAINING_CODE, LD_DATE_COMPLETED, LD_DATE_COMPLETED, LD_FOLLOWUP_DATE, NULL, UTC_TIMESTAMP(), 'vineeth','Y');

                                ELSEIF (LI_MODULE_CODE = 104) THEN
									INSERT INTO PERSON_TRAINING (PERSON_ID, TRAINING_NUMBER, TRAINING_CODE, DATE_SUBMITTED, DATE_ACKNOWLEDGED, FOLLOWUP_DATE, SCORE, UPDATE_TIMESTAMP, UPDATE_USER,ACTIVE_FLAG)
									VALUES (LS_PERSON_ID, LI_TRAINING_NO + 1,  LI_TRAINING_CODE, LD_DATE_COMPLETED, LD_DATE_COMPLETED, LD_FOLLOWUP_DATE, NULL, UTC_TIMESTAMP(), 'vineeth','Y');

                                ELSEIF (LI_MODULE_CODE = 200) THEN
									INSERT INTO PERSON_TRAINING (PERSON_ID, TRAINING_NUMBER, TRAINING_CODE, DATE_SUBMITTED, DATE_ACKNOWLEDGED, FOLLOWUP_DATE, SCORE, UPDATE_TIMESTAMP, UPDATE_USER,ACTIVE_FLAG)
									VALUES (LS_PERSON_ID, LI_TRAINING_NO + 1,  LI_TRAINING_CODE, LD_DATE_COMPLETED, LD_DATE_COMPLETED, LD_FOLLOWUP_DATE, NULL, UTC_TIMESTAMP(), 'vineeth','Y');

                                END IF;                            
                        END IF;
                    END IF;
    END loop;
    CLOSE CUR_CITI_DATA;

    SELECT COUNT(1) INTO LI_INSERTS FROM CITI_TRAINING_FEED_EXCEPTION WHERE ERROR_TYPE = 'MIGRATION';
    
	UPDATE CITI_TRAINING_FEED_INFO
	SET
	NO_OF_FAILED_RECORDS = LI_INSERTS,
    FEED_STATUS = 'Person Training Updated Successfully',
	UPDATED_TIMESTAMP = UTC_TIMESTAMP(),
	UPDATED_BY = 'vineeth'
	WHERE FEED_INFO_ID = AV_FEED_INFO_ID;

SET SQL_SAFE_UPDATES  = 1;
 SELECT 'SUCCESS' AS STATUS, '' AS ERROR_MSG;
END
