-- award_master_dataset_rt_v;

CREATE VIEW `award_master_dataset_rt_v` AS 
select distinct
   `master_data`.`AWARD_ID` AS `AWARD_ID`,
   `master_data`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `master_data`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `master_data`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`,
   `master_data`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`,
   `master_data`.`TITLE` AS `TITLE`,
   `master_data`.`BEGIN_DATE` AS `BEGIN_DATE`,
   `master_data`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
   `master_data`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
   `master_data`.`PRIME_SPONSOR_NAME` AS `PRIME_SPONSOR_NAME`,
   `master_data`.`PI_NAME` AS `PI_NAME`,
   `master_data`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
   `master_data`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
   `master_data`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `master_data`.`AWARD_EFFECTIVE_DATE` AS `AWARD_EFFECTIVE_DATE`,
   `master_data`.`AWARD_TYPE` AS `AWARD_TYPE`,
   `master_data`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`,
   `master_data`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`,
   `master_data`.`unit_name` AS `UNIT_NAME`,
   `master_data`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`,
   `master_data`.`TOTAL_COST_IN_CURRENCY` AS `TOTAL_COST_IN_CURRENCY`,
   `master_data`.`FEED_STATUS` AS `FEED_STATUS`,
   `master_data`.`AWARD_SEQUENCE_STATUS` AS `AWARD_SEQUENCE_STATUS`,
   `master_data`.`AWARD_STATUS` AS `AWARD_STATUS`,
   `master_data`.`ACTIVITY_TYPE` AS `ACTIVITY_TYPE`,
   `master_data`.`DURATION` AS `DURATION`,
   `master_data`.`AWARD_CREATE_TIMESTAMP` AS `AWARD_CREATE_TIMESTAMP`,
   timestampdiff(MONTH, `master_data`.`BEGIN_DATE`, 
   (
      `master_data`.`FINAL_EXPIRATION_DATE` + interval 1 day
   )
) AS `NUM_OF_MONTHS`,
   `master_data`.`GRANT_PER_MONTH` AS `GRANT_PER_MONTH`,
   `master_data`.`ORIGINAL_APPROVED_BUDGET` AS `ORIGINAL_APPROVED_BUDGET`,
   `master_data`.`LATEST_APPROVED_BUDGET` AS `LATEST_APPROVED_BUDGET`,
   `master_data`.`CUMULATIVE_ACTUAL_EXPENSE` AS `CUMULATIVE_ACTUAL_EXPENSE`,
   `master_data`.`CUMULATIVE_COMMITTED_EXPENSE` AS `CUMULATIVE_COMMITTED_EXPENSE`,
   `master_data`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
   `master_data`.`PERSON_ROLE_ID` AS `PERSON_ROLE_ID`,
   `master_data`.`KEY_PERSON_EMAIL` AS `KEY_PERSON_EMAIL`,
   `master_data`.`F_AND_A_RATE_TYPE` AS `F_AND_A_RATE_TYPE` 
from
   `award_master_dataset_rt` `master_data` 
where
   (
      `master_data`.`PERSON_ROLE_ID` = 3
   )
;

