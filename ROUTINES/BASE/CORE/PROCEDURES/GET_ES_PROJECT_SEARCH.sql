-- `GET_ES_PROJECT_SEARCH`; 

CREATE PROCEDURE `GET_ES_PROJECT_SEARCH`(
AV_MODULE_CODE   INT,
AV_SEARCH_TEXT   VARCHAR(4000)
)
BEGIN
IF AV_MODULE_CODE = 1 THEN 
			SELECT award_id, award_number, status, pi_name, sponsor, account_number, lead_unit_number, 
			lead_unit_name, title,status_code,obligation_expiration_date FROM ELASTIC_AWARD_V
			WHERE award_id LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR award_number LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR status LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR pi_name LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR sponsor LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR account_number LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR lead_unit_number LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR lead_unit_name LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR title LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR status_code LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR obligation_expiration_date LIKE CONCAT(AV_SEARCH_TEXT,'%')
            limit 10;
ELSEIF AV_MODULE_CODE = 2  THEN  
			SELECT convert(proposal_id, char(20)) as proposal_id,proposal_number,title,home_unit_number as lead_unit_number,
			status,lead_unit as lead_unit_name,sponsor,status_code FROM ELASTIC_INSTITUTE_PROPOSAL_V
			WHERE proposal_id   LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR proposal_number    LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR title   LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR home_unit_number    LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR status    LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR lead_unit   LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR sponsor    LIKE CONCAT(AV_SEARCH_TEXT,'%')
			OR status_code  LIKE CONCAT(AV_SEARCH_TEXT,'%')
            limit 10;
ELSEIF AV_MODULE_CODE = 3  THEN  
		SELECT cast(t1.proposal_id as char(10)) as proposal_id,t1.title,t1.full_name,t1.category,
		t1.type,t1.status,t1.sponsor FROM ELASTIC_FIBI_PROPOSAL_V t1 
		WHERE   t1.proposal_id LIKE CONCAT(AV_SEARCH_TEXT,'%')
		OR t1.title LIKE CONCAT(AV_SEARCH_TEXT,'%')
		OR t1.full_name LIKE CONCAT(AV_SEARCH_TEXT,'%')
		OR t1.category LIKE CONCAT(AV_SEARCH_TEXT,'%')
		OR t1.type LIKE CONCAT(AV_SEARCH_TEXT,'%')
		OR t1.status LIKE CONCAT(AV_SEARCH_TEXT,'%')
		OR t1.sponsor LIKE CONCAT(AV_SEARCH_TEXT,'%')
        limit 10;
END IF;
END
