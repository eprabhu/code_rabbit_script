-- keyperson_timesheet_v;

CREATE VIEW `keyperson_timesheet_v` AS 
select
   `t2`.`PERSON_ID` AS `KEYPERSON_ID`,
   `t2`.`FULL_NAME` AS `KEYPERSON_NAME`,
   `t2`.`PERSON_ROLE_ID` AS `PERSON_ROLE_ID`,
   `t2`.`PERSON_ROLE` AS `PERSON_ROLE`,
   `t2`.`YEAR` AS `TIMESHEET_YEAR`,
   `t2`.`YR_Q1` AS `YR_Q1`,
   `t2`.`YR_Q2` AS `YR_Q2`,
   `t2`.`YR_Q3` AS `YR_Q3`,
   `t2`.`YR_Q4` AS `YR_Q4`,
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `t1`.`TITLE` AS `TITLE`,
   `t1`.`AWARD_STATUS` AS `AWARD_STATUS`,
   `t1`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`,
   `t1`.`AWARD_TYPE` AS `AWARD_TYPE`,
   `t1`.`ACTIVITY_TYPE` AS `ACTIVITY_TYPE`,
   `t1`.`PRIME_SPONSOR_CODE` AS `PRIME_SPONSOR_CODE`,
   `t1`.`PRIME_SPONSOR_NAME` AS `PRIME_SPONSOR_NAME`,
   `t1`.`AWARD_EXECUTION_DATE` AS `AWARD_EXECUTION_DATE`,
   `t1`.`AWARD_EFFECTIVE_DATE` AS `AWARD_EFFECTIVE_DATE`,
   `t1`.`BEGIN_DATE` AS `BEGIN_DATE`,
   `t1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
   `t1`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
   `t1`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
   `t1`.`PI_PERSON_ID` AS `PI_PERSON_ID`,
   `t1`.`PI_NAME` AS `PI_NAME`,
   `t1`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `t1`.`unit_name` AS `unit_name`,
   `t1`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`,
   `t1`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
   `t1`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
   `t1`.`PI_HOME_UNIT_NUMBER` AS `PI_HOME_UNIT_NUMBER`,
   `t1`.`PI_HOME_UNIT` AS `PI_HOME_UNIT`,
   `t1`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`,
   `t1`.`KEY_PERSON_EMAIL` AS `KEY_PERSON_EMAIL`,
   `t1`.`TOTAL_PROJECT_COST` AS `TOTAL_PROJECT_COST`,
   `t1`.`AWARD_CREATE_TIMESTAMP` AS `AWARD_CREATE_TIMESTAMP`,
   `t1`.`ORIGINAL_APPROVED_BUDGET` AS `ORIGINAL_APPROVED_BUDGET`,
   `t1`.`LATEST_APPROVED_BUDGET` AS `LATEST_APPROVED_BUDGET`,
   `t1`.`DURATION` AS `DURATION`,
   `t1`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`,
   `t1`.`TOTAL_COST` AS `TOTAL_COST`,
   `t1`.`TOTAL_DIRECT_COST` AS `TOTAL_DIRECT_COST`,
   `t1`.`TOTAL_INDIRECT_COST` AS `TOTAL_INDIRECT_COST`,
   `t1`.`TOTAL_COST_SHARE` AS `TOTAL_COST_SHARE`,
   `t1`.`TOTAL_COST_IN_CURRENCY` AS `TOTAL_COST_IN_CURRENCY`,
   `t2`.`AWARD_ID` AS `AWARD_ID` 
from
   (
      `award_master_dataset_rt` `t1` 
      join
         (
            select
               `t1`.`AWARD_ID` AS `AWARD_ID`,
               `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
               `t2`.`PERSON_ID` AS `PERSON_ID`,
               `t2`.`FULL_NAME` AS `FULL_NAME`,
               `t1`.`YEAR` AS `YEAR`,
               `t2`.`PERSON_ROLE_ID` AS `PERSON_ROLE_ID`,
               `t3`.`DESCRIPTION` AS `PERSON_ROLE`,
               sum((
               case
                  `t1`.`ORDER_NUMBER` 
                  when
                     1 
                  then
                     `t1`.`VALUE` 
                  else
                     '' 
               end
)) AS `YR_Q1`, sum((
               case
                  `t1`.`ORDER_NUMBER` 
                  when
                     2 
                  then
                     `t1`.`VALUE` 
                  else
                     '' 
               end
)) AS `YR_Q2`, sum((
               case
                  `t1`.`ORDER_NUMBER` 
                  when
                     3 
                  then
                     `t1`.`VALUE` 
                  else
                     '' 
               end
)) AS `YR_Q3`, sum((
               case
                  `t1`.`ORDER_NUMBER` 
                  when
                     4 
                  then
                     `t1`.`VALUE` 
                  else
                     '' 
               end
)) AS `YR_Q4` 
            from
               (
(`award_keyperson_timesheet` `t1` 
                  join
                     `award_persons` `t2` 
                     on((`t1`.`AWARD_PERSON_ID` = `t2`.`AWARD_PERSON_ID`))) 
                  join
                     `eps_prop_person_role` `t3` 
                     on((`t2`.`PERSON_ROLE_ID` = `t3`.`PROP_PERSON_ROLE_ID`))
               )
            group by
               `t1`.`AWARD_ID`, `t1`.`AWARD_NUMBER`, `t2`.`PERSON_ID`, `t2`.`FULL_NAME`, `t1`.`YEAR`
         )
         `t2` 
         on((`t1`.`AWARD_NUMBER` = `t2`.`AWARD_NUMBER`))
   )
where
   (
      `t1`.`PERSON_ROLE_ID` = 3
   )
;

