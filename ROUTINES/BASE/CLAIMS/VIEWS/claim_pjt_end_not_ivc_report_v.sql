-- claim_pjt_end_not_ivc_report_v;

CREATE VIEW `claim_pjt_end_not_ivc_report_v` AS 
select distinct
   `t0`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t0`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `t1`.`CLAIM_ID` AS `CLAIM_ID`,
   `t1`.`CLAIM_NUMBER` AS `CLAIM_NUMBER`,
   `t1`.`CLAIM_TITLE` AS `CLAIM_TITLE`,
   `t1`.`CLAIM_STATUS_CODE` AS `CLAIM_STATUS_CODE`,
   `t1`.`CLAIM_STATUS` AS `CLAIM_STATUS`,
   `t1`.`CLAIM_SUBMISSION_DATE` AS `CLAIM_SUBMISSION_DATE`,
   `t1`.`START_DATE` AS `START_DATE`,
   `t1`.`END_DATE` AS `END_DATE`,
   `t1`.`CLAIM_DURATION` AS `CLAIM_DURATION`,
   `t1`.`CLAIM_AMOUNT` AS `CLAIM_AMOUNT`,
   `t1`.`CREATE_USER` AS `CREATE_USER`,
   `t1`.`CLAIM_PREPARER` AS `CLAIM_PREPARER`,
   `t1`.`BANK_CLEARANCE_DATE` AS `BANK_CLEARANCE_DATE`,
   `t1`.`INVOICE_NUMBER` AS `INVOICE_NUMBER`,
   `t1`.`INVOICE_DATE` AS `INVOICE_DATE`,
   `t1`.`INVOICE_AMOUNT` AS `INVOICE_AMOUNT`,
   `t1`.`ACTUAL_REVENUE` AS `ACTUAL_REVENUE`,
   `t1`.`ACTUAL_EXPENSE` AS `ACTUAL_EXPENSE` 
from
   (
      `award` `t0` 
      left join
         `claim_master_dataset_rt` `t1` 
         on((`t1`.`AWARD_NUMBER` = `t0`.`AWARD_NUMBER`))
   )
where
   (
(`t1`.`AWARD_NUMBER` is null) 
      and 
      (
         `t0`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'
      )
      and 
      (
         `t0`.`STATUS_CODE` = 14
      )
   )
union
select distinct
   `t0`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t0`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `t1`.`CLAIM_ID` AS `CLAIM_ID`,
   `t1`.`CLAIM_NUMBER` AS `CLAIM_NUMBER`,
   `t1`.`CLAIM_TITLE` AS `CLAIM_TITLE`,
   `t1`.`CLAIM_STATUS_CODE` AS `CLAIM_STATUS_CODE`,
   `t1`.`CLAIM_STATUS` AS `CLAIM_STATUS`,
   `t1`.`CLAIM_SUBMISSION_DATE` AS `CLAIM_SUBMISSION_DATE`,
   `t1`.`START_DATE` AS `START_DATE`,
   `t1`.`END_DATE` AS `END_DATE`,
   `t1`.`CLAIM_DURATION` AS `CLAIM_DURATION`,
   `t1`.`CLAIM_AMOUNT` AS `CLAIM_AMOUNT`,
   `t1`.`CREATE_USER` AS `CREATE_USER`,
   `t1`.`CLAIM_PREPARER` AS `CLAIM_PREPARER`,
   `t1`.`BANK_CLEARANCE_DATE` AS `BANK_CLEARANCE_DATE`,
   `t1`.`INVOICE_NUMBER` AS `INVOICE_NUMBER`,
   `t1`.`INVOICE_DATE` AS `INVOICE_DATE`,
   `t1`.`INVOICE_AMOUNT` AS `INVOICE_AMOUNT`,
   `t1`.`ACTUAL_REVENUE` AS `ACTUAL_REVENUE`,
   `t1`.`ACTUAL_EXPENSE` AS `ACTUAL_EXPENSE` 
from
   (
      `award` `t0` 
      join
         (
            select distinct
               `s1`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
               `s1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
               `s1`.`AWARD_ID` AS `AWARD_ID`,
               `s1`.`CLAIM_ID` AS `CLAIM_ID`,
               `s1`.`CLAIM_NUMBER` AS `CLAIM_NUMBER`,
               `s1`.`CLAIM_TITLE` AS `CLAIM_TITLE`,
               `s1`.`CLAIM_STATUS_CODE` AS `CLAIM_STATUS_CODE`,
               `s1`.`CLAIM_STATUS` AS `CLAIM_STATUS`,
               `s1`.`CLAIM_SUBMISSION_DATE` AS `CLAIM_SUBMISSION_DATE`,
               `s1`.`START_DATE` AS `START_DATE`,
               `s1`.`END_DATE` AS `END_DATE`,
               `s1`.`CLAIM_DURATION` AS `CLAIM_DURATION`,
               `s1`.`CLAIM_AMOUNT` AS `CLAIM_AMOUNT`,
               `s1`.`CREATE_USER` AS `CREATE_USER`,
               `s1`.`CLAIM_PREPARER` AS `CLAIM_PREPARER`,
               `s1`.`BANK_CLEARANCE_DATE` AS `BANK_CLEARANCE_DATE`,
               `s1`.`INVOICE_NUMBER` AS `INVOICE_NUMBER`,
               `s1`.`INVOICE_DATE` AS `INVOICE_DATE`,
               `s1`.`INVOICE_AMOUNT` AS `INVOICE_AMOUNT`,
               `s1`.`ACTUAL_REVENUE` AS `ACTUAL_REVENUE`,
               `s1`.`ACTUAL_EXPENSE` AS `ACTUAL_EXPENSE` 
            from
               `claim_master_dataset_rt` `s1` 
            where
               (
                  `s1`.`CLAIM_STATUS_CODE` <> 4
               )
         )
         `t1` 
         on((`t1`.`AWARD_NUMBER` = `t0`.`AWARD_NUMBER`))
   )
where
   (
(`t0`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE') 
      and 
      (
         `t0`.`STATUS_CODE` = 14
      )
   )
;

