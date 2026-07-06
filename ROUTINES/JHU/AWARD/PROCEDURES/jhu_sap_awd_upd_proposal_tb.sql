CREATE  PROCEDURE `jhu_sap_awd_upd_proposal_tb`(av_update_timestamp  DATE
  )
BEGIN
SET SQL_SAFE_UPDATES= 0;



  UPDATE proposal p
  SET p.status_code = 2
	 ,p.update_timestamp = utc_timestamp()
	 ,p.update_user = 'INTRFACE'
  WHERE p.proposal_id IN (SELECT fp.proposal_id
							  FROM award_funding_proposals fp 
							  INNER JOIN award a ON a.award_id = fp.award_id
							  WHERE a.status_code <> 3
							 --  AND   DATE_FORMAT(fp.update_timestamp,'%Y-%m-%d') > TRIM(DATE(UTC_TIMESTAMP()))
							  AND   a.sequence_number in(SELECT MAX(sequence_number)
														 FROM   award
														 WHERE  award_number = a.award_number)
							     )
  AND p.status_code <> 2;




UPDATE award SET STATUS_CODE = 4 WHERE STATUS_CODE = 1 AND FINAL_EXPIRATION_DATE <= utc_timestamp(); 

						   
SET SQL_SAFE_UPDATES= 1;
						   


END
