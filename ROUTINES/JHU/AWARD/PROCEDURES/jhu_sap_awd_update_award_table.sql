CREATE PROCEDURE `jhu_sap_awd_update_award_table`( av_award_number  VARCHAR(12)
      ,av_sequence_number  INT(4)
      ,av_sponsored_program_number  VARCHAR(8)
      ,av_sponsor_award_number  VARCHAR(22)
      ,av_status  VARCHAR(3)
      ,av_template_code  INT(1)
      ,av_start_date  VARCHAR(10)
      ,av_end_date  VARCHAR(10)
      ,av_sponsor_code  VARCHAR(10)
      ,av_coeus_update_timestamp DATE	  
      ,av_proposal_number  varchar(10)
      ,av_project_title  VARCHAR(150)
      ,av_award_type VARCHAR(3)
      ,av_obligated  DECIMAL(12,2)
      ,av_validity_start_date  VARCHAR(10)
      ,av_cfda_number VARCHAR(8)
      ,av_sub_award_flag VARCHAR(1)
      ,av_prime_sponsor_code VARCHAR(10)
      ,av_billing_rule  VARCHAR(4)
      ,av_payment_code VARCHAR(4)
      ,av_fa_function  VARCHAR(25)
      ,av_spon_prog_type VARCHAR(15) )
BEGIN
   DECLARE ls_coeus_account_number VARCHAR(100) DEFAULT av_sponsored_program_number;
   DECLARE li_award_row_count INT(3) DEFAULT NULL;
   DECLARE  li_update_timestamp INT(3) DEFAULT NULL;
   DECLARE  li_coeus_award_type INT(3) DEFAULT NULL;
   DECLARE  li_coeus_pre_award_auth_amount DECIMAL(12,2) DEFAULT 0;
   DECLARE  ld_coeus_pre_award_auth_amount DATE DEFAULT NULL;
   DECLARE  ls_coeus_pre_award_auth_amount VARCHAR(1) DEFAULT 'U';
   DECLARE  li_coeus_basis_of_payment INT(3) DEFAULT NULL;
   DECLARE  li_coeus_method_of_payment INT(3) DEFAULT NULL;
   DECLARE  li_coeus_activity_type INT(3) DEFAULT NULL;
   DECLARE  li_coeus_account_type INT(3) DEFAULT NULL;
  
   DECLARE LS_ERROR_MSG varchar(4000);   
    
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
	
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			 
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD', concat(LS_ERROR_MSG,av_sponsor_code), av_award_number, av_sequence_number);
		
		END;



   SET SQL_SAFE_UPDATES= 0; 
  BEGIN
	
	
	
	SELECT count(*)
	INTO  li_award_row_count
	FROM award
	WHERE award_number = av_award_number
	AND   sequence_number = av_sequence_number;

	SELECT coeus_award_type_code
	INTO  li_coeus_award_type
	FROM sap_award_type
	WHERE sap_award_type_code = av_award_type;

	IF av_status = 3 THEN
	 SET li_coeus_pre_award_auth_amount = CAST(av_obligated AS DECIMAL(12,2));
	 SET ld_coeus_pre_award_auth_amount = DATE_FORMAT(av_start_date, '%Y-%m-%d');
	END IF;

	SELECT coeus_basis_of_payment_code
	INTO  li_coeus_basis_of_payment
	FROM sap_billing_rule
	WHERE sap_billing_rule_code = av_billing_rule;
	SELECT coeus_method_of_payment_code
	INTO  li_coeus_method_of_payment
	FROM sap_payment_method
	WHERE sap_payment_method_code = av_payment_code;

	SELECT coeus_activity_type_code
	INTO  li_coeus_activity_type
	FROM sap_fa_function
	WHERE sap_fa_function_description = av_fa_function;

	IF av_spon_prog_type = 'GR' THEN
	  SET li_coeus_account_type = 800;
	ELSEIF av_spon_prog_type = 'PM'  THEN
	  SET li_coeus_account_type = 801;
	ELSEIF av_spon_prog_type = 'OT'  THEN
	  SET li_coeus_account_type = 802;
	ELSEIF av_spon_prog_type = 'SU' THEN
		IF li_coeus_award_type IN (3, 14, 15, 17) THEN
			SET li_coeus_account_type = 804;
		ELSE
			SET li_coeus_account_type = 803;
		END IF;
	END IF;

	IF li_award_row_count = 0 THEN
	  INSERT INTO award (award_number
							,sequence_number
							,sponsor_award_number
							,status_code
							,award_effective_date
							,begin_date
                            ,FINAL_EXPIRATION_DATE
                            , duration
							,sponsor_code
							,account_number
							,update_timestamp
							,update_user
							,title
						   ,award_type_code
						   ,pre_award_authorized_amount
						   ,pre_award_effective_date
						   ,cfda_number
						   ,prime_sponsor_code
						   ,basis_of_payment_code
						   ,method_of_payment_code
						   ,activity_type_code
						   ,account_type_code
							,IS_LATEST
							,CREATE_TIMESTAMP
							,CREATE_USER
                             ,WORKFLOW_AWARD_STATUS_CODE
							,AWARD_DOCUMENT_TYPE_CODE
                            ,AWARD_SEQUENCE_STATUS
							,DOCUMENT_UPDATE_USER
							,DOCUMENT_UPDATE_TIMESTAMP
							,AWARD_VARIATION_TYPE_CODE
                            )
	  VALUES (av_award_number
			 ,av_sequence_number
			 ,av_sponsor_award_number
			 ,av_status
			 ,DATE_FORMAT(av_start_date, '%Y-%m-%d')
			 ,DATE_FORMAT(av_start_date, '%Y-%m-%d')
             ,DATE_FORMAT(av_end_date, '%Y-%m-%d')
             , concat(TIMESTAMPDIFF( YEAR, av_start_date, av_end_date ),' year(s), '
						, TIMESTAMPDIFF( MONTH, av_start_date, av_end_date )%12, ' month(s) & '
						, FLOOR( TIMESTAMPDIFF( DAY, av_start_date, av_end_date ) % 30.4375 ) ,' day(s)')
			 ,av_sponsor_code
			 ,ls_coeus_account_number
			 ,av_coeus_update_timestamp
			 ,'INTRFACE'
			 ,av_project_title
			 ,li_coeus_award_type
			 ,li_coeus_pre_award_auth_amount
			 ,ld_coeus_pre_award_auth_amount
			 ,av_cfda_number
			 ,av_prime_sponsor_code
			 ,li_coeus_basis_of_payment
			 ,li_coeus_method_of_payment
			 ,li_coeus_activity_type
			 ,li_coeus_account_type
             ,CASE av_sequence_number WHEN 0 THEN 'Y' ELSE 'N' END
             ,av_coeus_update_timestamp
			 ,'INTRFACE'
             ,3
             ,case av_sequence_number when 0 then 0 else 1 end
             ,case av_sequence_number when 0 then 'ACTIVE' else 'ARCHIVE' end
             ,'INTRFACE'
			 ,utc_timestamp()
			 , case when av_sequence_number > 0 then 2 else NULL end
			 );
              COMMIT;
	ELSE
	  UPDATE award SET sponsor_award_number = av_sponsor_award_number,
							status_code = av_status,
							award_effective_date = DATE_FORMAT(av_start_date, '%Y-%m-%d'),
							begin_date = DATE_FORMAT(av_start_date,  '%Y-%m-%d'),
							sponsor_code = av_sponsor_code,
							account_number = ls_coeus_account_number,
							update_timestamp = av_coeus_update_timestamp,
							update_user = 'INTRFACE',
							title = av_project_title,
							award_type_code = li_coeus_award_type,
							pre_award_authorized_amount = li_coeus_pre_award_auth_amount,
							pre_award_effective_date = ld_coeus_pre_award_auth_amount,
							cfda_number = av_cfda_number,
							prime_sponsor_code = av_prime_sponsor_code,
							basis_of_payment_code = li_coeus_basis_of_payment,
							method_of_payment_code = li_coeus_method_of_payment,
							activity_type_code = li_coeus_activity_type,
							account_type_code = li_coeus_account_type,
							DOCUMENT_UPDATE_USER = 'INTRFACE',
							DOCUMENT_UPDATE_TIMESTAMP = utc_timestamp(),
							AWARD_VARIATION_TYPE_CODE = (case when av_sequence_number > 0 then 2 else NULL end), 
                            FINAL_EXPIRATION_DATE = DATE_FORMAT(av_end_date, '%Y-%m-%d'), -- Added as per the discussion with Bob 
                            duration = concat(TIMESTAMPDIFF( YEAR, av_start_date, av_end_date ),' year(s), '
										, TIMESTAMPDIFF( MONTH, av_start_date, av_end_date )%12, ' month(s) & '
										, FLOOR( TIMESTAMPDIFF( DAY, av_start_date, av_end_date ) % 30.4375 ) ,' day(s)')
	  WHERE award_number = av_award_number
	  AND   sequence_number = av_sequence_number;
      COMMIT;
	END IF;
 
		
  END;
COMMIT;
END
