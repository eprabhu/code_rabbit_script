-- award_test_view;

CREATE VIEW `award_test_view` AS 
select
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `t1`.`AWARD_ID` AS `AWARD_ID`,
   `t1`.`TITLE` AS `TITLE`,
   `t2`.`DESCRIPTION` AS `AWARD_STATUS`,
   `t3`.`DESCRIPTION` AS `ACCOUNT_TYPE`,
   `t4`.`DESCRIPTION` AS `AWARD_TYPE`,
   `t5`.`DESCRIPTION` AS `ACTIVITY_TYPE`,
   `t1`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `t6`.`unit_name` AS `LEAD_UNIT`,
   `t1`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
   `t7`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
   `t1`.`PRIME_SPONSOR_CODE` AS `PRIME_SPONSOR_CODE`,
   `t8`.`SPONSOR_NAME` AS `PRIME_SPONSOR_NAME`,
   `t1`.`AWARD_EXECUTION_DATE` AS `AWARD_EXECUTION_DATE`,
   `t1`.`AWARD_EFFECTIVE_DATE` AS `AWARD_EFFECTIVE_DATE`,
   `t1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
   `t1`.`AWARD_SEQUENCE_STATUS` AS `AWARD_SEQUENCE_STATUS`,
   `t9`.`FULL_NAME` AS `PI_NAME`,
   `t9`.`PERSON_ID` AS `PI_PERSON_ID`,
   `t10`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
   `t10`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
   `t10`.`CURRENT_FUND_EFFECTIVE_DATE` AS `CURRENT_FUND_EFFECTIVE_DATE`,
   `t10`.`OBLIGATION_EXPIRATION_DATE` AS `OBLIGATION_EXPIRATION_DATE`,
   `t1`.`BEGIN_DATE` AS `BEGIN_DATE`,
   `t11`.`GRANT_CODE` AS `GRANT_CODE`,
   `t11`.`INPUT_GST_CATEGORY` AS `INPUT_GST_CATEGORY`,
   `t11`.`OUTPUT_GST_CATEGORY` AS `OUTPUT_GST_CATEGORY`,
   `t11`.`RIE_DOMAIN` AS `RIE_Domain`,
   `t11`.`COST_CENTER` AS `COST_CENTER`,
   `t11`.`PROFIT_CENTER` AS `PROFIT_CENTER`,
   `t11`.`PROFIT_CENTER` AS `FUND_CENTER` 
from
   (
(((((((((`award` `t1` 
      join
         `award_status` `t2` 
         on((`t1`.`STATUS_CODE` = `t2`.`STATUS_CODE`))) 
      left join
         `account_type` `t3` 
         on((`t1`.`ACCOUNT_TYPE_CODE` = `t3`.`ACCOUNT_TYPE_CODE`))) 
      left join
         `award_type` `t4` 
         on((`t4`.`AWARD_TYPE_CODE` = `t1`.`AWARD_TYPE_CODE`))) 
      join
         `activity_type` `t5` 
         on((`t1`.`ACTIVITY_TYPE_CODE` = `t5`.`ACTIVITY_TYPE_CODE`))) 
      join
         `unit` `t6` 
         on((`t1`.`LEAD_UNIT_NUMBER` = `t6`.`UNIT_NUMBER`))) 
      join
         `sponsor` `t7` 
         on((`t1`.`SPONSOR_CODE` = `t7`.`SPONSOR_CODE`))) 
      left join
         `sponsor` `t8` 
         on((`t1`.`PRIME_SPONSOR_CODE` = `t8`.`SPONSOR_CODE`))) 
      join
         `award_persons` `t9` 
         on((`t1`.`AWARD_ID` = `t9`.`AWARD_ID`))) 
      left join
         `custom_data_view` `t11` 
         on((`t11`.`MODULE_ITEM_KEY` = `t1`.`AWARD_ID`))) 
      left join
         (
            select
               `s1`.`AWARD_ID` AS `AWARD_ID`,
               `s1`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
               `s1`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
               `s1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
               `s1`.`CURRENT_FUND_EFFECTIVE_DATE` AS `CURRENT_FUND_EFFECTIVE_DATE`,
               `s1`.`OBLIGATION_EXPIRATION_DATE` AS `OBLIGATION_EXPIRATION_DATE` 
            from
               `award_amount_info` `s1` 
            where
               (
                  `s1`.`AWARD_AMOUNT_INFO_ID` = 
                  (
                     select
                        max(`s2`.`AWARD_AMOUNT_INFO_ID`) 
                     from
                        `award_amount_info` `s2` 
                     where
                        (
                           `s1`.`AWARD_ID` = `s2`.`AWARD_ID`
                        )
                  )
               )
         )
         `t10` 
         on((`t1`.`AWARD_ID` = `t10`.`AWARD_ID`))
   )
where
   (
(`t9`.`PI_FLAG` = 'Y') 
      and 
      (
(`t1`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE') 
         or 
         (
(`t1`.`AWARD_SEQUENCE_STATUS` = 'PENDING') 
            and 
            (
               `t1`.`AWARD_DOCUMENT_TYPE_CODE` = 1
            )
         )
      )
   )
;

