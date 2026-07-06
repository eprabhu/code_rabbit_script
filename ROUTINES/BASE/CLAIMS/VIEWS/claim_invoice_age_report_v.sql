-- claim_invoice_age_report_v;

CREATE VIEW `claim_invoice_age_report_v` AS 
select distinct
   `claim_master_dataset_rt`.`CLAIM_NUMBER` AS `CLAIM_NUMBER`,
   `claim_master_dataset_rt`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `claim_master_dataset_rt`.`CLAIM_SUBMISSION_DATE` AS `CLAIM_SUBMISSION_DATE`,
   `claim_master_dataset_rt`.`CLAIM_STATUS` AS `CLAIM_STATUS`,
   `claim_master_dataset_rt`.`START_DATE` AS `START_DATE`,
   `claim_master_dataset_rt`.`END_DATE` AS `END_DATE`,
   `claim_master_dataset_rt`.`CLAIM_AMOUNT` AS `CLAIM_AMOUNT`,
   `claim_master_dataset_rt`.`CLAIM_PREPARER` AS `CLAIM_PREPARER`,
   `claim_master_dataset_rt`.`BANK_CLEARANCE_DATE` AS `BANK_CLEARANCE_DATE`,
   `claim_master_dataset_rt`.`INVOICE_NUMBER` AS `INVOICE_NUMBER`,
   `claim_master_dataset_rt`.`INVOICE_DATE` AS `INVOICE_DATE`,
   `claim_master_dataset_rt`.`INVOICE_AMOUNT` AS `INVOICE_AMOUNT`,
   `claim_master_dataset_rt`.`ACTUAL_REVENUE` AS `ACTUAL_REVENUE`,
   `claim_master_dataset_rt`.`ACTUAL_EXPENSE` AS `ACTUAL_EXPENSE`,
   `claim_master_dataset_rt`.`TOTAL_CUM_CLAIM_AMOUNT_UPTO_CLAIM` AS `TOTAL_CUM_CLAIM_AMOUNT_UPTO_CLAIM`,
   `claim_master_dataset_rt`.`REFERENCE_DOC_NUMBER` AS `REFERENCE_DOC_NUMBER`,
   `claim_master_dataset_rt`.`FM_POSTING_DATE` AS `FM_POSTING_DATE`,
   (
      to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`CLAIM_SUBMISSION_DATE`)
   )
   AS `BASIS_OF_CLAIM_SUBMISSION_DATE`,
   (
      to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`INVOICE_DATE`)
   )
   AS `BASIS_OF_CLAIM_INVOICE_DATE`,
   (
      case
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`CLAIM_SUBMISSION_DATE`)) between 1 and 30
            )
         then
            '<= 30 Days' 
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`CLAIM_SUBMISSION_DATE`)) between 31 and 60
            )
         then
            '31 - 60 Days' 
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`CLAIM_SUBMISSION_DATE`)) between 61 and 90
            )
         then
            '61 - 90 Days' 
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`CLAIM_SUBMISSION_DATE`)) between 91 and 120
            )
         then
            '91 - 120 Days' 
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`CLAIM_SUBMISSION_DATE`)) between 121 and 180
            )
         then
            '121 - 180 Days' 
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`CLAIM_SUBMISSION_DATE`)) > 180
            )
         then
            '> 180 Days' 
         else
            'NA' 
      end
   )
   AS `AGE_CATEGORY`, 
   (
      case
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`INVOICE_DATE`)) between 1 and 30
            )
         then
            '<= 30 Days' 
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`INVOICE_DATE`)) between 31 and 60
            )
         then
            '31 - 60 Days' 
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`INVOICE_DATE`)) between 61 and 90
            )
         then
            '61 - 90 Days' 
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`INVOICE_DATE`)) between 91 and 120
            )
         then
            '91 - 120 Days' 
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`INVOICE_DATE`)) between 121 and 180
            )
         then
            '121 - 180 Days' 
         when
            (
(to_days(utc_timestamp()) - to_days(`claim_master_dataset_rt`.`INVOICE_DATE`)) > 180
            )
         then
            '> 180 Days' 
         else
            'NA' 
      end
   )
   AS `INVOICE_AGE_CATEGORY` 
from
   `claim_master_dataset_rt` 
where
   (
(`claim_master_dataset_rt`.`BANK_CLEARANCE_DATE` is null) 
      and 
      (
         `claim_master_dataset_rt`.`INVOICE_NUMBER` is not null
      )
   )
;

