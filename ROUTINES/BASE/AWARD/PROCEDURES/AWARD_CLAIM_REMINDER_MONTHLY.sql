-- `AWARD_CLAIM_REMINDER_MONTHLY`; 

CREATE PROCEDURE `AWARD_CLAIM_REMINDER_MONTHLY`( AV_DAYS INT )
BEGIN
		select 0 AS SUB_MODULE_ITEM_KEY, t1.AWARD_ID AS MODULE_ITEM_KEY, 1 AS MODULE_CODE, 0 AS SUB_MODULE_CODE, t1.FINAL_EXPIRATION_DATE as EXP
		from award t1
		where t1.AWARD_SEQUENCE_STATUS = 'ACTIVE'
		and t1.STATUS_CODE in (1,14) 
		and t1.PAYMENT_INVOICE_FREQ_CODE = 11 
        AND t1.BEGIN_DATE <= utc_timestamp()
		AND (DAY(date(DATE_ADD(utc_timestamp(),INTERVAL AV_DAYS DAY))) = '1')
		AND 0 = (
					select count(s2.AWARD_REPORT_TRACKING_ID) from award_report_terms s1
					inner join award_report_tracking s2 on s1.AWARD_REPORT_TERMS_ID = s2.AWARD_REPORT_TERMS_ID
					where s1.REPORT_CLASS_CODE = 20 
					and s2.award_number = t1.award_number
					and s2.SEQUENCE_NUMBER  = 0
					and s2.DUE_DATE > date(utc_timestamp())
				);
END
