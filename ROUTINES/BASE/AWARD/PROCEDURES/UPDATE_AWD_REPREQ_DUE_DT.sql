CREATE  PROCEDURE `UPDATE_AWD_REPREQ_DUE_DT`(AV_AWARD_ID INT)
BEGIN
	DECLARE LI_AWARD_ID INT(11);	
	DECLARE LS_AWARD_NUMBER	VARCHAR(12);
	DECLARE LI_SEQUENCE_NUMBER INT;
	DECLARE LS_FREQUENCY_CODE VARCHAR(3);
	DECLARE LS_AWD_END_DATE DATETIME;

	DECLARE LI_COUNT INT;
	DECLARE LI_AWD_REP_TERMS_ID INT;
	DECLARE LD_REP_START_DATE DATE;
	DECLARE LD_REP_END_DATE DATE;
	DECLARE	LS_FREQ_MONTHS VARCHAR(20);
	DECLARE	LS_FREQ_DAYS VARCHAR(20);
	DECLARE LD_NEW_DUE_DATE DATETIME;
	DECLARE LI_MAX_UNIQUE_ID INT;
	DECLARE DONE1 BOOLEAN DEFAULT FALSE;
	DECLARE LS_ERROR VARCHAR(2000);
	DECLARE LD_TERM_END_DATE DATETIME;
	DECLARE LI_OCCURRENCES INT;
	DECLARE LD_BASE_DATE DATETIME;

	DECLARE AWD_RPT_TERMS_CURSOR CURSOR FOR 			
		SELECT  AR.AWARD_ID,
				AR.AWARD_NUMBER, 
				AR.SEQUENCE_NUMBER, 
				AR.FREQUENCY_CODE, 
				AR.AWARD_REPORT_TERMS_ID,
			   AR.END_DATE,
			   AR.OCCURRENCES,
			   AR.BASE_DATE
		  FROM AWARD_REPORT_TERMS AR
		 WHERE AR.AWARD_ID = AV_AWARD_ID
		   AND AR.FREQUENCY_BASE_CODE = "4" -- project end date
		   AND EXISTS (SELECT 1 FROM AWARD_REPORT_TRACKING ART
						LEFT JOIN award_report_tracking_file artf ON ART.AWARD_REPORT_TRACKING_ID = artf.AWARD_REPORT_TRACKING_ID
						   WHERE ART.AWARD_REPORT_TERMS_ID = AR.AWARD_REPORT_TERMS_ID
						   AND artf.AWARD_REPORT_TRACKING_FILE_ID IS NULL
						   AND ART.AWARD_ID = AR.AWARD_ID
						   AND ART.STATUS_CODE = 1 -- pending status code
						   AND ART.PROGRESS_REPORT_ID IS NULL
						)
			AND NOT EXISTS (SELECT 1 
							  FROM FREQUENCY FR 
							 WHERE FR.FREQUENCY_CODE = AR.FREQUENCY_CODE
							   AND UPPER(FR.DESCRIPTION) = UPPER('As required')	
							) ;
		

	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
	BEGIN

		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
	 
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
	
		SELECT @full_error INTO LS_ERROR;
		
		INSERT INTO AWD_REPREQ_DUEDT_LOG 
			(AWARD_ID,AWARD_REPORT_TERMS_ID,ERROR_MESSAGE,UPDATE_TIMESTAMP,UPDATE_USER)
		VALUES  (LI_AWARD_ID,LI_AWD_REP_TERMS_ID,CONCAT(LS_ERROR),UTC_TIMESTAMP(),'quickstart');		
	
		COMMIT;	
		SET DONE1 = TRUE;
	END;	
	SELECT UNIQUE_ID INTO LI_MAX_UNIQUE_ID FROM award_report_tracking ORDER BY UNIQUE_ID DESC LIMIT 1 ;

	
	IF DONE1 = FALSE THEN

		OPEN AWD_RPT_TERMS_CURSOR;
		AWD_RPT_TERMS_CURSOR_LOOP : LOOP
			FETCH AWD_RPT_TERMS_CURSOR INTO LI_AWARD_ID,
											LS_AWARD_NUMBER, 
											LI_SEQUENCE_NUMBER, 
											LS_FREQUENCY_CODE,
											LI_AWD_REP_TERMS_ID,
											LD_TERM_END_DATE,
											LI_OCCURRENCES,
											LD_BASE_DATE;
		
				IF DONE1 THEN				
					LEAVE AWD_RPT_TERMS_CURSOR_LOOP;
				END IF;

					SELECT FINAL_EXPIRATION_DATE INTO LS_AWD_END_DATE FROM AWARD WHERE AWARD_ID = LI_AWARD_ID;
					SET LD_REP_START_DATE = DATE(LS_AWD_END_DATE);

					-- To avoid regeneration if project end date is not changed.
					IF LD_REP_START_DATE = DATE(LD_BASE_DATE) THEN				
					LEAVE AWD_RPT_TERMS_CURSOR_LOOP;
					END IF;
					
					SELECT NUMBER_OF_MONTHS, NUMBER_OF_DAYS INTO LS_FREQ_MONTHS, LS_FREQ_DAYS
					FROM FREQUENCY
					WHERE FREQUENCY_CODE = LS_FREQUENCY_CODE;					                  

					-- Below logic is to make due dates before revamp compatible with new rep req due date generation
					-- Before rep req revamp, we didnt have END_DATE AND OCCURRENCES field,so OCCURRENCES is 0 and END_DATE is NULL for already existing due date, 
					-- also by default reporting end date used to be award end date for due date generation.
					-- after revamp, either END_DATE or OCCURRENCES always will have a value, these value will be used as reporting end date.(reporting end date can be calculated from OCCURRENCES)
					-- on old rep req, when 'project end date' is selected as frequency base, only one due date is generated, to achive same result we are setting OCCURRENCES to 1 for old reporting requirement generated due dates.
					IF LD_TERM_END_DATE IS NULL AND LI_OCCURRENCES = 0 THEN
					SET LI_OCCURRENCES = 1;
					END IF;
					
					-- Below 'if else' block sets reporting end date, reporting start date is always project end date for this case.
					IF (LS_FREQ_MONTHS IS NOT NULL AND LS_FREQ_MONTHS > 0 ) OR (LS_FREQ_DAYS IS NOT NULL AND LS_FREQ_DAYS > 0 ) THEN
						IF LD_TERM_END_DATE IS NOT NULL THEN
							SET LD_REP_END_DATE =  DATE(LD_TERM_END_DATE);
						ELSEIF LI_OCCURRENCES <> 0 THEN
							-- Code for calculating reporting end date with OCCURRENCES.
							IF LS_FREQ_MONTHS IS NOT NULL THEN
								SET LD_REP_END_DATE = DATE_ADD(LD_REP_START_DATE, INTERVAL (LS_FREQ_MONTHS * LI_OCCURRENCES) MONTH);
							ELSEIF LS_FREQ_DAYS IS NOT NULL THEN
								SET LD_REP_END_DATE = DATE_ADD(LD_REP_START_DATE, INTERVAL (LS_FREQ_DAYS * LI_OCCURRENCES) DAY);
							END IF;
						END IF;
					ELSE
					 	SET LD_REP_END_DATE = LD_REP_START_DATE;
					END IF;

				-- if frequency is null or negative values -> single due date is generated.
				-- if frequency is positive -> due dates from reporting start date to reporting end date is generated in respective frequency.				
				
				IF LD_REP_START_DATE IS NOT NULL AND LD_REP_END_DATE IS NOT NULL THEN
					IF LD_REP_START_DATE > LD_REP_END_DATE THEN
					LEAVE AWD_RPT_TERMS_CURSOR_LOOP;
					END IF;			
						UPDATE AWARD_REPORT_TERMS SET BASE_DATE = LD_REP_START_DATE where AWARD_REPORT_TERMS_ID = LI_AWD_REP_TERMS_ID;
						DELETE art FROM award_report_tracking art
						LEFT JOIN award_report_tracking_file artf ON art.AWARD_REPORT_TRACKING_ID = artf.AWARD_REPORT_TRACKING_ID
						WHERE art.AWARD_REPORT_TERMS_ID = LI_AWD_REP_TERMS_ID AND artf.AWARD_REPORT_TRACKING_FILE_ID IS NULL AND art.STATUS_CODE = 1 AND art.PROGRESS_REPORT_ID IS NULL;
					-- temp_tracking table is used by DATE_GENERATOR to insert generated due dates.
						DROP TEMPORARY TABLE IF EXISTS temp_tracking;
						CREATE TEMPORARY TABLE temp_tracking (DUE_DATE DATE);
						CALL DATE_GENERATOR(DATE(LD_REP_START_DATE), DATE(LD_REP_END_DATE), LS_FREQ_MONTHS, LS_FREQ_DAYS); 
                     DUE_DATE_INSERT_BLOCK: BEGIN
						DECLARE done BOOLEAN DEFAULT FALSE;
						DECLARE temp_tracking_cur CURSOR FOR SELECT DUE_DATE FROM temp_tracking;
						DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
        				OPEN temp_tracking_cur; 
        				temp_tracking_cur_loop: LOOP
        					FETCH FROM temp_tracking_cur INTO LD_NEW_DUE_DATE;   
							IF done THEN
        						LEAVE temp_tracking_cur_loop;
    						END IF;
                            SELECT COUNT(*) into LI_COUNT FROM award_report_tracking  WHERE  AWARD_REPORT_TERMS_ID = LI_AWD_REP_TERMS_ID AND DATE(DUE_DATE) = LD_NEW_DUE_DATE;
                            IF LI_COUNT = 0 THEN
							SET LI_MAX_UNIQUE_ID = LI_MAX_UNIQUE_ID + 1;
								INSERT INTO award_report_tracking (`AWARD_REPORT_TERMS_ID`, `AWARD_ID`, `AWARD_NUMBER`, `SEQUENCE_NUMBER`, `STATUS_CODE`, `UPDATE_TIMESTAMP`, `UPDATE_USER`, `DUE_DATE`, `UNIQUE_ID`, `IS_ADHOC`) 
								VALUES(
								LI_AWD_REP_TERMS_ID,
								LI_AWARD_ID,
								LS_AWARD_NUMBER,
								LI_SEQUENCE_NUMBER,
								'1',
								UTC_TIMESTAMP(),
								'quickstart',
								LD_NEW_DUE_DATE,
								LI_MAX_UNIQUE_ID,
								'N');
                            END IF;
							
						END LOOP temp_tracking_cur_loop;
						CLOSE temp_tracking_cur;
					END DUE_DATE_INSERT_BLOCK; 
					DROP TEMPORARY TABLE IF EXISTS temp_tracking;
				END IF;
					
		END LOOP;
		CLOSE AWD_RPT_TERMS_CURSOR;
	END IF;	
END
