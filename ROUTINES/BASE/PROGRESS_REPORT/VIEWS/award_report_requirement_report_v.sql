-- award_report_requirement_report_v;

CREATE VIEW `award_report_requirement_report_v` AS 
select distinct
(
   case
      `t11`.`STATUS` 
      when
         'A' 
      then
         'Active' 
      when
         'I' 
      then
         'Inactive' 
   end
) AS `PERSON_STATUS`, `t11`.`EMAIL_ADDRESS` AS `PERSON_EMAIL`, `t2`.`TITLE` AS `TITLE`, `t2`.`PI_PERSON_ID` AS `PI_PERSON_ID`, `t2`.`PI_NAME` AS `PI_NAME`, `t2`.`AWARD_TYPE` AS `AWARD_TYPE`, `t2`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`, `t2`.`AWARD_STATUS` AS `AWARD_STATUS`, `t2`.`SPONSOR_NAME` AS `SPONSOR_NAME`, `t2`.`SPONSOR_TYPE` AS `SPONSOR_TYPE`, `t2`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`, `t2`.`unit_name` AS `UNIT_NAME`, `t2`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`, `t2`.`BEGIN_DATE` AS `BEGIN_DATE`, `t2`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`, `t2`.`DURATION` AS `DURATION`, `t2`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`, `t2`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`, `t2`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`, `t2`.`TOTAL_COST` AS `TOTAL_COST`, `t2`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`, `t2`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`, `t2`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`, `t2`.`AWARD_SEQUENCE_STATUS` AS `AWARD_SEQUENCE_STATUS`, `t1`.`AWARD_ID` AS `AWARD_ID`, `t2`.`AWARD_NUMBER` AS `AWARD_NUMBER`, `t2`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`, `t1`.`DUE_DATE` AS `AWARD_REPORT_TERMS_DUE_DATE`, `t1`.`BASE_DATE` AS `AWARD_REPORT_TERMS_BASE_DATE`, `t3`.`DESCRIPTION` AS `REPORT_CLASS`, `t4`.`DESCRIPTION` AS `FREQUENCY`, `t5`.`DESCRIPTION` AS `FREQUENCY_BASE`, `t6`.`DESCRIPTION` AS `DISTRIBUTION`, if((`t12`.`PROGRESS_REPORT_ID` is null), `t9`.`DESCRIPTION`, `t13`.`DESCRIPTION`) AS `REPORT_STATUS`, `t11`.`FULL_NAME` AS `RECIPIENT_NAME`, `t8`.`ACTIVITY_DATE` AS `ACTIVITY_DATE`, `t8`.`COMMENTS` AS `COMMENTS`, `t8`.`DUE_DATE` AS `AWARD_REPORT_TRACKING_DUE_DATE`, `t2`.`F_AND_A_RATE_TYPE` AS `F_AND_A_RATE_TYPE`, `t8`.`NOTE` AS `NOTE` 
from
   (
(((((((((((`award_report_terms` `t1` 
      join
         `award_master_dataset_rt` `t2` 
         on((`t2`.`AWARD_ID` = `t1`.`AWARD_ID`))) 
      left join
         `report_class` `t3` 
         on((`t3`.`REPORT_CLASS_CODE` = `t1`.`REPORT_CLASS_CODE`))) 
      left join
         `frequency` `t4` 
         on((`t4`.`FREQUENCY_CODE` = `t1`.`FREQUENCY_CODE`))) 
      left join
         `frequency_base` `t5` 
         on((`t5`.`FREQUENCY_BASE_CODE` = `t1`.`FREQUENCY_BASE_CODE`))) 
      left join
         `distribution` `t6` 
         on((`t6`.`OSP_DISTRIBUTION_CODE` = `t1`.`OSP_DISTRIBUTION_CODE`))) 
      left join
         `award_report_term_recipient` `t7` 
         on((`t7`.`AWARD_REPORT_TERMS_ID` = `t1`.`AWARD_REPORT_TERMS_ID`))) 
      left join
         `award_report_tracking` `t8` 
         on((`t8`.`AWARD_REPORT_TERMS_ID` = `t1`.`AWARD_REPORT_TERMS_ID`))) 
      left join
         `report_status` `t9` 
         on((`t9`.`REPORT_STATUS_CODE` = `t8`.`STATUS_CODE`))) 
      left join
         `award_report_tracking_file` `t10` 
         on((`t10`.`AWARD_REPORT_TERMS_ID` = `t1`.`AWARD_REPORT_TERMS_ID`))) 
      left join
         `person` `t11` 
         on((`t11`.`PERSON_ID` = `t7`.`RECIPIENT_ID`))) 
      left join
         `award_progress_report` `t12` 
         on((`t12`.`PROGRESS_REPORT_ID` = `t8`.`PROGRESS_REPORT_ID`))) 
      left join
         `progress_report_status` `t13` 
         on((`t13`.`PROGRESS_REPORT_STATUS_CODE` = `t12`.`PROGRESS_REPORT_STATUS_CODE`))
   )
;

