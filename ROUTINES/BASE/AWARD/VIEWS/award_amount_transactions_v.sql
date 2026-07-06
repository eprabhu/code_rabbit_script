-- award_amount_transactions_v;

CREATE VIEW `award_amount_transactions_v` AS 
select
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`TITLE` AS `TITLE`,
   `t2`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
   `t3`.`unit_name` AS `UNIT_NAME`,
   `t4`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
   `t4`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
   (
      ifnull(`t4`.`ANTICIPATED_TOTAL_AMOUNT`, 0) + ifnull(`t7`.`COST_SHARE_AMT`, 0)
   )
   AS `TOTAL_PROJECT_COST`,
   `t4`.`CURRENT_FUND_EFFECTIVE_DATE` AS `OBLIGATION_START_DATE`,
   `t4`.`OBLIGATION_EXPIRATION_DATE` AS `OBLIGATION_END_DATE`,
   `t6`.`DESCRIPTION` AS `TRANSACTION_TYPE`,
   `t5`.`COMMENTS` AS `TRANSACTION_COMMENT`,
   `t1`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `t1`.`AWARD_ID` AS `AWARD_ID`,
   `t5`.`SOURCE_AWARD_NUMBER` AS `SOURCE_AWARD_NUMBER`,
   `t5`.`DESTINATION_AWARD_NUMBER` AS `DESTINATION_AWARD_NUMBER`,
   `t4`.`ANTICIPATED_CHANGE` AS `ANTICIPATED_CHANGE`,
   `t4`.`OBLIGATED_CHANGE` AS `OBLIGATED_CHANGE`,
   `t5`.`NOTICE_DATE` AS `NOTICE_DATE`,
   `t8`.`DESCRIPTION` AS `AWARD_STATUS`,
   `t1`.`ACCOUNT_NUMBER` AS `FUND_CODE`,
   `t9`.`DESCRIPTION` AS `AWARD_TYPE`,
   `t10`.`FULL_NAME` AS `PI_NAME`,
   `t1`.`BEGIN_DATE` AS `BEGIN_DATE`,
   `t1`.`FUND_CENTER` AS `FUND_CENTRE`,
   `t1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
   `t12`.`DESCRIPTION` AS `GRANT_TYPE`,
   `t4`.`AWARD_AMOUNT_INFO_ID` AS `AWARD_AMOUNT_INFO_ID` 
from
   (
((((((((((`award` `t1` 
      left join
         `sponsor` `t2` 
         on((`t1`.`SPONSOR_CODE` = `t2`.`SPONSOR_CODE`))) 
      left join
         `unit` `t3` 
         on((`t1`.`LEAD_UNIT_NUMBER` = `t3`.`UNIT_NUMBER`))) 
      left join
         `grant_call_header` `t11` 
         on((`t1`.`GRANT_HEADER_ID` = `t11`.`GRANT_HEADER_ID`))) 
      left join
         `grant_call_type` `t12` 
         on((`t11`.`GRANT_TYPE_CODE` = `t12`.`GRANT_TYPE_CODE`))) 
      join
         (
            select
               `s1`.`AWARD_AMOUNT_INFO_ID` AS `AWARD_AMOUNT_INFO_ID`,
               `s1`.`AWARD_ID` AS `AWARD_ID`,
               `s1`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
               `s1`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
               `s1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
               `s1`.`CURRENT_FUND_EFFECTIVE_DATE` AS `CURRENT_FUND_EFFECTIVE_DATE`,
               `s1`.`OBLIGATION_EXPIRATION_DATE` AS `OBLIGATION_EXPIRATION_DATE`,
               `s1`.`TOTAL_COST_IN_CURRENCY` AS `TOTAL_COST_IN_CURRENCY`,
               `s1`.`TRANSACTION_ID` AS `TRANSACTION_ID`,
               `s1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
               `s1`.`ANTICIPATED_CHANGE` AS `ANTICIPATED_CHANGE`,
               `s1`.`OBLIGATED_CHANGE` AS `OBLIGATED_CHANGE` 
            from
               `award_amount_info` `s1`
         )
         `t4` 
         on((`t1`.`AWARD_NUMBER` = `t4`.`AWARD_NUMBER`))) 
      join
         `award_amount_transaction` `t5` 
         on((`t4`.`TRANSACTION_ID` = `t5`.`TRANSACTION_ID`))) 
      join
         `award_transaction_type` `t6` 
         on((`t6`.`AWARD_TRANSACTION_TYPE_CODE` = `t5`.`TRANSACTION_TYPE_CODE`))) 
      left join
         (
            select
               `s5`.`AWARD_ID` AS `AWARD_ID`,
               sum(`s5`.`COMMITMENT_AMOUNT`) AS `COST_SHARE_AMT` 
            from
               `award_cost_share` `s5` 
            group by
               `s5`.`AWARD_ID`
         )
         `t7` 
         on((`t1`.`AWARD_ID` = `t7`.`AWARD_ID`))) 
      left join
         `award_status` `t8` 
         on((`t8`.`STATUS_CODE` = `t1`.`STATUS_CODE`))) 
      left join
         `award_type` `t9` 
         on((`t9`.`AWARD_TYPE_CODE` = `t1`.`AWARD_TYPE_CODE`))) 
      left join
         `award_persons` `t10` 
         on(((`t10`.`AWARD_ID` = `t1`.`AWARD_ID`) 
         and 
         (
            `t10`.`PERSON_ROLE_ID` = 3
         )
))
   )
where
   (
(((`t1`.`AWARD_SEQUENCE_STATUS` = 'PENDING') 
      and 
      (
         `t1`.`AWARD_DOCUMENT_TYPE_CODE` = 1
      )
) 
      or 
      (
         `t1`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'
      )
) 
      and 
      (
         `t5`.`NOTICE_DATE` is not null
      )
   )
group by
   `t4`.`AWARD_NUMBER`,
   cast(`t5`.`NOTICE_DATE` as date) 
having
(`t4`.`AWARD_AMOUNT_INFO_ID` = max(`t4`.`AWARD_AMOUNT_INFO_ID`)) 
union
select
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`TITLE` AS `TITLE`,
   `t2`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
   `t3`.`unit_name` AS `UNIT_NAME`,
   `t4`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
   `t4`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
   (
      ifnull(`t4`.`ANTICIPATED_TOTAL_AMOUNT`, 0) + ifnull(`t7`.`COST_SHARE_AMT`, 0)
   )
   AS `TOTAL_PROJECT_COST`,
   `t4`.`CURRENT_FUND_EFFECTIVE_DATE` AS `OBLIGATION_START_DATE`,
   `t4`.`OBLIGATION_EXPIRATION_DATE` AS `OBLIGATION_END_DATE`,
   `t6`.`DESCRIPTION` AS `TRANSACTION_TYPE`,
   `t5`.`COMMENTS` AS `TRANSACTION_COMMENT`,
   `t1`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `t1`.`AWARD_ID` AS `AWARD_ID`,
   `t5`.`SOURCE_AWARD_NUMBER` AS `SOURCE_AWARD_NUMBER`,
   `t5`.`DESTINATION_AWARD_NUMBER` AS `DESTINATION_AWARD_NUMBER`,
   `t4`.`ANTICIPATED_CHANGE` AS `ANTICIPATED_CHANGE`,
   `t4`.`OBLIGATED_CHANGE` AS `OBLIGATED_CHANGE`,
   `t5`.`NOTICE_DATE` AS `NOTICE_DATE`,
   `t8`.`DESCRIPTION` AS `AWARD_STATUS`,
   `t1`.`ACCOUNT_NUMBER` AS `FUND_CODE`,
   `t1`.`FUND_CENTER` AS `FUND_CENTRE`,
   `t9`.`DESCRIPTION` AS `AWARD_TYPE`,
   `t10`.`FULL_NAME` AS `PI_NAME`,
   `t1`.`BEGIN_DATE` AS `BEGIN_DATE`,
   `t1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
   `t12`.`DESCRIPTION` AS `GRANT_TYPE`,
   `t4`.`AWARD_AMOUNT_INFO_ID` AS `AWARD_AMOUNT_INFO_ID` 
from
   (
((((((((((`award` `t1` 
      left join
         `sponsor` `t2` 
         on((`t1`.`SPONSOR_CODE` = `t2`.`SPONSOR_CODE`))) 
      left join
         `unit` `t3` 
         on((`t1`.`LEAD_UNIT_NUMBER` = `t3`.`UNIT_NUMBER`))) 
      left join
         `grant_call_header` `t11` 
         on((`t1`.`GRANT_HEADER_ID` = `t11`.`GRANT_HEADER_ID`))) 
      left join
         `grant_call_type` `t12` 
         on((`t11`.`GRANT_TYPE_CODE` = `t12`.`GRANT_TYPE_CODE`))) 
      join
         (
            select
               `s1`.`AWARD_AMOUNT_INFO_ID` AS `AWARD_AMOUNT_INFO_ID`,
               `s1`.`AWARD_ID` AS `AWARD_ID`,
               `s1`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
               `s1`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
               `s1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
               `s1`.`CURRENT_FUND_EFFECTIVE_DATE` AS `CURRENT_FUND_EFFECTIVE_DATE`,
               `s1`.`OBLIGATION_EXPIRATION_DATE` AS `OBLIGATION_EXPIRATION_DATE`,
               `s1`.`TOTAL_COST_IN_CURRENCY` AS `TOTAL_COST_IN_CURRENCY`,
               `s1`.`TRANSACTION_ID` AS `TRANSACTION_ID`,
               `s1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
               `s1`.`ANTICIPATED_CHANGE` AS `ANTICIPATED_CHANGE`,
               `s1`.`OBLIGATED_CHANGE` AS `OBLIGATED_CHANGE` 
            from
               `award_amount_info` `s1`
         )
         `t4` 
         on((`t1`.`AWARD_NUMBER` = `t4`.`AWARD_NUMBER`))) 
      join
         `award_amount_transaction` `t5` 
         on((`t4`.`TRANSACTION_ID` = `t5`.`TRANSACTION_ID`))) 
      join
         `award_transaction_type` `t6` 
         on((`t6`.`AWARD_TRANSACTION_TYPE_CODE` = `t5`.`TRANSACTION_TYPE_CODE`))) 
      left join
         (
            select
               `s5`.`AWARD_ID` AS `AWARD_ID`,
               sum(`s5`.`COMMITMENT_AMOUNT`) AS `COST_SHARE_AMT` 
            from
               `award_cost_share` `s5` 
            group by
               `s5`.`AWARD_ID`
         )
         `t7` 
         on((`t1`.`AWARD_ID` = `t7`.`AWARD_ID`))) 
      left join
         `award_status` `t8` 
         on((`t8`.`STATUS_CODE` = `t1`.`STATUS_CODE`))) 
      left join
         `award_type` `t9` 
         on((`t9`.`AWARD_TYPE_CODE` = `t1`.`AWARD_TYPE_CODE`))) 
      left join
         `award_persons` `t10` 
         on(((`t10`.`AWARD_ID` = `t1`.`AWARD_ID`) 
         and 
         (
            `t10`.`PERSON_ROLE_ID` = 3
         )
))
   )
where
   (
(((`t1`.`AWARD_SEQUENCE_STATUS` = 'PENDING') 
      and 
      (
         `t1`.`AWARD_DOCUMENT_TYPE_CODE` = 1
      )
) 
      or 
      (
         `t1`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'
      )
) 
      and 
      (
         `t5`.`NOTICE_DATE` is null
      )
   )
;

