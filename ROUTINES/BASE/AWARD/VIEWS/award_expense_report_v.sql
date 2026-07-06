-- award_expense_report_v;

CREATE VIEW `award_expense_report_v` AS 
select
   `t1`.`AWARD_ID` AS `AWARD_ID`,
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `t1`.`TITLE` AS `TITLE`,
   `t1`.`AWARD_STATUS` AS `AWARD_STATUS`,
   `t1`.`AWARD_TYPE` AS `AWARD_TYPE`,
   `t1`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `t1`.`LEAD_UNIT` AS `LEAD_UNIT`,
   `t1`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
   `t1`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
   `t1`.`AWARD_EFFECTIVE_DATE` AS `AWARD_EFFECTIVE_DATE`,
   `t1`.`BEGIN_DATE` AS `PROJECT_START_DATE`,
   `t1`.`FINAL_EXPIRATION_DATE` AS `PROJECT_END_DATE`,
   `t1`.`PI_NAME` AS `PI_NAME`,
   `t2`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE`,
   `t2`.`FI_GL_ACCOUNT` AS `FI_GL_ACCOUNT`,
   `t2`.`FI_GL_DESCRIPTION` AS `FI_GL_DESCRIPTION`,
   `t2`.`FM_POSTING_DATE` AS `FM_POSTING_DATE`,
   `t2`.`REFERENCE_DOC_NUMBER` AS `REFERENCE_DOC_NUMBER`,
   `t2`.`DOCUMENT_DATE` AS `DOCUMENT_DATE`,
   `t2`.`PREDECESSOR_DOC_NUMBER` AS `PREDECESSOR_DOC_NUMBER`,
   `t2`.`FI_POSTING_DATE` AS `FI_POSTING_DATE`,
   `t2`.`VENDOR_NAME` AS `VENDOR_NAME`,
   `t2`.`REMARKS` AS `REMARKS`,
   `t2`.`AMOUNT_IN_FMA_CURRENCY` AS `AMOUNT_IN_FMA_CURRENCY`,
   `t6`.`DESCRIPTION` AS `DESCRIPTION`,
   `t7`.`DESCRIPTION` AS `BUDGET_LINE_ITEM`,
   `t2`.`BANK_CLEARING_DATE` AS `BANK_CLEARANCE_DATE`,
   `t5`.`BUDGET_CATEGORY_CODE` AS `BUDGET_CATEGORY_CODE`,
   `t1`.`GRANT_TYPE` AS `GRANT_TYPE` 
from
   (
(((((`award_v` `t1` 
      left join
         `award_expense_transactions` `t2` 
         on(((`t1`.`AWARD_NUMBER` = `t2`.`AWARD_NUMBER`) 
         and 
         (
            `t1`.`ACCOUNT_NUMBER` = `t2`.`ACCOUNT_NUMBER`
         )
))) 
      left join
         `award_budget_header` `t3` 
         on((`t1`.`AWARD_ID` = `t3`.`AWARD_ID`))) 
      left join
         `award_budget_period` `t4` 
         on((`t3`.`BUDGET_HEADER_ID` = `t4`.`BUDGET_HEADER_ID`))) 
      left join
         `award_budget_detail` `t5` 
         on(((`t5`.`BUDGET_PERIOD_ID` = `t4`.`BUDGET_PERIOD_ID`) 
         and 
         (
            `t2`.`INTERNAL_ORDER_CODE` = `t5`.`INTERNAL_ORDER_CODE`
         )
))) 
      left join
         `budget_category` `t6` 
         on((`t5`.`BUDGET_CATEGORY_CODE` = `t6`.`BUDGET_CATEGORY_CODE`))) 
      left join
         `cost_element` `t7` 
         on((`t5`.`COST_ELEMENT` = `t7`.`COST_ELEMENT`))
   )
where
   (
      `t3`.`VERSION_NUMBER` in 
      (
         select
            max(`ab1`.`VERSION_NUMBER`) 
         from
            `award_budget_header` `ab1` 
         where
            (
(`ab1`.`AWARD_NUMBER` = `t3`.`AWARD_NUMBER`) 
               and 
               (
                  `ab1`.`AWARD_ID` = `t3`.`AWARD_ID`
               )
            )
      )
      and `t4`.`BUDGET_PERIOD_ID` in 
      (
         select
            min(`bp2`.`BUDGET_PERIOD_ID`) 
         from
            `award_budget_period` `bp2` 
         where
            (
               `bp2`.`BUDGET_HEADER_ID` = `t4`.`BUDGET_HEADER_ID`
            )
      )
   )
;

