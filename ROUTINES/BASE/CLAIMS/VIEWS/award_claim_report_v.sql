


-- award_claim_report_v;

CREATE VIEW `award_claim_report_v` AS 
select distinct
   `t1`.`CLAIM_NUMBER` AS `CLAIM_ID`,
   `t1`.`CLAIM_SUBMISSION_DATE` AS `CLAIM_SUBMISSION_DATE`,
   `t1`.`CLAIM_STATUS_CODE` AS `CLAIM_STATUS_CODE`,
   `t2`.`DESCRIPTION` AS `CLAIM_STATUS`,
   `t1`.`START_DATE` AS `START_DATE`,
   `t1`.`END_DATE` AS `END_DATE`,
   `t1`.`DURATION` AS `CLAIM_DURATION`,
   `FN_GET_CLAIM_AMOUNT`(`t3`.`AWARD_NUMBER`, `t1`.`CLAIM_ID`) AS `CLAIM_AMOUNT`,
   `t1`.`CREATE_USER` AS `CREATE_USER`,
   `t4`.`FULL_NAME` AS `PREPARER_FULLNAME`,
   `t3`.`TITLE` AS `TITLE`,
   `t3`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `t3`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t3`.`AWARD_ID` AS `AWARD_ID`,
   `t3`.`PI_PERSON_ID` AS `PI_PERSON_ID`,
   `t3`.`PI_NAME` AS `PI_NAME`,
   `t3`.`AWARD_TYPE` AS `AWARD_TYPE`,
   `t3`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`,
   `t3`.`AWARD_STATUS` AS `AWARD_STATUS`,
   `t3`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
   `t3`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
   `t3`.`SPONSOR_TYPE` AS `SPONSOR_TYPE`,
   `t3`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`,
   `t3`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `t3`.`unit_name` AS `UNIT_NAME`,
   `t3`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`,
   `t3`.`BEGIN_DATE` AS `BEGIN_DATE`,
   `t3`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
   `t3`.`DURATION` AS `AWARD_DURATION`,
   `t3`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
   `t3`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
   `t3`.`TOTAL_COST` AS `TOTAL_COST`,
   `t3`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`,
   `t3`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`,
   `t3`.`BASIS_OF_PAYMENT_DESC` AS `BASIS_OF_PAYMENT_DESC`,
   `t3`.`METHOD_OF_PAYMENT_DESC` AS `METHOD_OF_PAYMENT_DESC` 
from
   (
(((`claim` `t1` 
      left join
         `claim_status` `t2` 
         on((`t2`.`CLAIM_STATUS_CODE` = `t1`.`CLAIM_STATUS_CODE`))) 
      left join
         `award_master_dataset_rt` `t3` 
         on(((`t3`.`AWARD_NUMBER` = `t1`.`AWARD_NUMBER`) 
         and 
         (
            `t3`.`PERSON_ROLE_ID` = 3
         )
))) 
      left join
         `person` `t4` 
         on((`t4`.`USER_NAME` = `t1`.`CREATE_USER`))) 
      left join
         (
            select
               `s1`.`CLAIM_ID` AS `CLAIM_ID`,
               sum(`s1`.`AMOUNT_REQUESTED`) AS `AMOUNT_REQUESTED` 
            from
               `claim_summary` `s1` 
            group by
               `s1`.`CLAIM_ID`
         )
         `t5` 
         on((`t1`.`CLAIM_ID` = `t5`.`CLAIM_ID`))
   )
;

