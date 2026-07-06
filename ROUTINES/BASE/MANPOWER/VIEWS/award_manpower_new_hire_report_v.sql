-- award_manpower_new_hire_report_v;

CREATE VIEW `award_manpower_new_hire_report_v` AS 
select
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`AWARD_ID` AS `AWARD_ID`,
   `t10`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `t2`.`POSITION_ID` AS `POSITION_ID`,
   `t4`.`DESCRIPTION` AS `POSITION_STATUS`,
   `t5`.`DESCRIPTION` AS `PLAN_JOB_PROFILE_TYPE`,
   `t2`.`PLANNED_BASE_SALARY` AS `PLANNED_BASE_SALARY`,
   `t2`.`COST_ALLOCATION` AS `COST_ALLOCATION`,
   `t2`.`PLAN_START_DATE` AS `PLAN_START_DATE`,
   `t2`.`PLAN_END_DATE` AS `PLAN_END_DATE`,
   `t2`.`PLAN_DURATION` AS `PLAN_DURATION`,
   `t2`.`PLANNED_SALARY` AS `PLANNED_SALARY`,
   `t2`.`DESCRIPTION` AS `COMMENTS`,
   `t1`.`MANPOWER_TYPE_CODE` AS `MANPOWER_TYPE_CODE`,
   `t10`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `t10`.`TITLE` AS `AWARD_TITLE`,
   `t10`.`PI_NAME` AS `PI_NAME`,
   `t10`.`KEY_PERSON_EMAIL` AS `PERSON_EMAIL`,
   `t10`.`unit_name` AS `UNIT_NAME`,
   `t10`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
   `t10`.`SPONSOR_TYPE` AS `SPONSOR_TYPE`,
   `t10`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`,
   `t10`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`,
   `t10`.`BEGIN_DATE` AS `AWARD_EFFECTIVE_DATE`,
   `t10`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
   `t10`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`,
   `t10`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`,
   `t10`.`ACTIVITY_TYPE` AS `ACTIVITY_TYPE`,
   `t10`.`AMOUNT_OBLIGATED_TO_DATE` AS `OBLIGATED_TOTAL_AMOUNT`,
   `t10`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
   `t10`.`TOTAL_PROJECT_COST` AS `TOTAL_COST`,
   `t10`.`F_AND_A_RATE_TYPE` AS `F_AND_A_RATE_TYPE`,
   `t10`.`AWARD_STATUS` AS `AWARD_STATUS`,
   (
      case
         `t2`.`IS_MULTI_ACCOUNT` 
         when
            'Y' 
         then
            'Yes' 
         when
            'N' 
         then
            'No' 
      end
   )
   AS `IS_MULTI_ACCOUNT`, 
   (
      case
         `t2`.`IS_MAIN_ACCOUNT` 
         when
            'Y' 
         then
            'Yes' 
         when
            'N' 
         then
            'No' 
      end
   )
   AS `IS_MAIN_ACCOUNT`, `t18`.`DESCRIPTION` AS `COST_ELEMENT`, `t9`.`LINE_ITEM_COST` AS `LINE_ITEM_COST`, `t7`.`JOB_REQUISITION_STATUS` AS `JOB_REQUISITION_STATUS`, `t7`.`JOB_REQUISITION_ID` AS `JOB_REQUISITION_ID`, cast(`t9`.`QUANTITY` as unsigned) AS `QUANTITY`, `t9`.`LINE_ITEM_DESCRIPTION` AS `LINE_ITEM_DESCRIPTION`, 
   (
      case
         when
            (
               `t1`.`BUDGET_REFERENCE_TYPE_CODE` = 1
            )
         then
            `t1`.`BUDGET_REFERENCE_NUMBER` 
         else
            NULL 
      end
   )
   AS `BUDGET_REFERENCE_NUMBER`, 
   (
      `t9`.`LINE_ITEM_COST` - ifnull(`t15`.`COMMITTED_AMOUNT`, 0)
   )
   AS `UNCOMMITTED_AMOUNT`, ifnull(`t16`.`EXPENSE_AMOUNT`, 0) AS `EXPENSE_AMOUNT`, ifnull(`t17`.`ACTUAL_HEAD_COUNT`, 0) AS `ACTUAL_HEAD_COUNT`, ifnull(`t15`.`COMMITTED_AMOUNT`, 0) AS `COMMITTED_AMOUNT` 
from
   (
((((((((((`award_manpower` `t1` 
      join
         `award_manpower_resource` `t2` 
         on(((`t1`.`AWARD_MANPOWER_ID` = `t2`.`AWARD_MANPOWER_ID`) 
         and 
         (
            `t1`.`MANPOWER_TYPE_CODE` = 1
         )
))) 
      left join
         `manpower_job_profile_type` `t5` 
         on((`t5`.`JOB_PROFILE_TYPE_CODE` = `t2`.`PLAN_JOB_PROFILE_TYPE_CODE`))) 
      left join
         `manpower_position_status` `t4` 
         on((`t4`.`POSITION_STATUS_CODE` = `t2`.`POSITION_STATUS_CODE`))) 
      left join
         `workday_position_requisition` `t7` 
         on((`t7`.`POSITION_ID` = `t2`.`POSITION_ID`))) 
      join
         `award_master_dataset_rt` `t10` 
         on(((`t10`.`AWARD_ID` = `t1`.`AWARD_ID`) 
         and 
         (
(`t10`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE') 
            or 
            (
               `t10`.`AWARD_SEQUENCE_STATUS` = 'PENDING'
            )
         )
         and 
         (
            `t10`.`PERSON_ROLE_ID` = 3
         )
))) 
      join
         `award_budget_header` `t8` 
         on(((`t8`.`AWARD_ID` = `t10`.`AWARD_ID`) 
         and 
         (
            `t8`.`VERSION_NUMBER` = 
            (
               select
                  max(`award_budget_header`.`VERSION_NUMBER`) 
               from
                  `award_budget_header` 
               where
                  (
                     `award_budget_header`.`AWARD_ID` = `t10`.`AWARD_ID`
                  )
            )
         )
))) 
      join
         `award_budget_detail` `t9` 
         on(((`t9`.`BUDGET_HEADER_ID` = `t8`.`BUDGET_HEADER_ID`) 
         and 
         (
(`t9`.`INTERNAL_ORDER_CODE` = `t1`.`BUDGET_REFERENCE_NUMBER`) 
            or 
            (
               `t9`.`BUDGET_DETAILS_ID` = `t1`.`BUDGET_REFERENCE_NUMBER`
            )
         )
))) 
      join
         `cost_element` `t18` 
         on((`t18`.`COST_ELEMENT` = `t9`.`COST_ELEMENT`))) 
      left join
         (
            select
               ifnull(sum(`sub_query`.`amount`), 0) AS `COMMITTED_AMOUNT`,
               `sub_query`.`WBS_NUMBER` AS `WBS_NUMBER` 
            from
               (
                  select
                     ifnull(sum(coalesce(`ta1`.`COMMITTED_COST`, `ta1`.`PLANNED_SALARY`, 0)), 0) AS `amount`,
                     `ta2`.`BUDGET_REFERENCE_NUMBER` AS `WBS_NUMBER` 
                  from
                     (
((`award_manpower_resource` `ta1` 
                        join
                           `award_manpower` `ta2` 
                           on((`ta1`.`AWARD_MANPOWER_ID` = `ta2`.`AWARD_MANPOWER_ID`))) 
                        left join
                           `workday_position_requisition` `ta3` 
                           on((`ta1`.`POSITION_ID` = `ta3`.`POSITION_ID`))) 
                        join
                           `award` `ta4` 
                           on(((`ta2`.`AWARD_ID` = `ta4`.`AWARD_ID`) 
                           and 
                           (
(`ta4`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE') 
                              or 
                              (
(`ta4`.`AWARD_SEQUENCE_STATUS` = 'PENDING') 
                                 and 
                                 (
                                    `ta4`.`AWARD_DOCUMENT_TYPE_CODE` = 1
                                 )
                              )
                           )
))
                     )
                  where
                     (
((`ta2`.`MANPOWER_TYPE_CODE` = 1) 
                        and 
                        (
(`ta1`.`POSITION_ID` is null) 
                           or 
                           (
                              `ta3`.`JOB_REQUISITION_STATUS` is null
                           )
                           or 
                           (
                              `ta3`.`JOB_REQUISITION_STATUS` = 'Open'
                           )
                        )
) 
                        or 
                        (
                           `ta2`.`MANPOWER_TYPE_CODE` <> 1
                        )
                     )
                  group by
                     `ta2`.`BUDGET_REFERENCE_NUMBER` 
                  union
                  select
                     sum(coalesce(`manpower_workday_resource`.`ADJUSTED_COMMITTED_COST`, `manpower_workday_resource`.`COMMITTED_COST`, 0)) AS `amount`,
                     `manpower_workday_resource`.`WBS_NUMBER` AS `WBS_NUMBER` 
                  from
                     `manpower_workday_resource` 
                  group by
                     `manpower_workday_resource`.`WBS_NUMBER`
               )
               `sub_query` 
            group by
               `sub_query`.`WBS_NUMBER`
         )
         `t15` 
         on((`t1`.`BUDGET_REFERENCE_NUMBER` = `t15`.`WBS_NUMBER`))) 
      left join
         (
            select
               ifnull(sum(`award_expense_details`.`TOTAL_EXPENSE_AMOUNT`), 0) AS `EXPENSE_AMOUNT`,
               `award_expense_details`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE` 
            from
               `award_expense_details` 
            group by
               `award_expense_details`.`INTERNAL_ORDER_CODE`
         )
         `t16` 
         on((`t1`.`BUDGET_REFERENCE_NUMBER` = `t16`.`INTERNAL_ORDER_CODE`))) 
      left join
         (
            select
               ifnull(count(distinct `manpower_workday_resource`.`PERSON_ID`), 0) AS `ACTUAL_HEAD_COUNT`,
               `manpower_workday_resource`.`WBS_NUMBER` AS `WBS_NUMBER` 
            from
               `manpower_workday_resource` 
            where
               (
(`manpower_workday_resource`.`PERSON_ID` is not null) 
                  and 
                  (
                     `manpower_workday_resource`.`PERSON_ID` <> '999999999100'
                  )
                  and 
                  (
                     `manpower_workday_resource`.`POSITION_STATUS_CODE` not in 
                     (
                        '8',
                        '5'
                     )
                  )
                  and 
                  (
                     cast(utc_timestamp() as date) between cast(`manpower_workday_resource`.`CHARGE_START_DATE` as date) and cast(`manpower_workday_resource`.`CHARGE_END_DATE` as date)
                  )
               )
            group by
               `manpower_workday_resource`.`WBS_NUMBER`
         )
         `t17` 
         on((`t1`.`BUDGET_REFERENCE_NUMBER` = `t17`.`WBS_NUMBER`))
   )
;

