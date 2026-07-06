-- salary_discrepancy_report_v;

CREATE VIEW `salary_discrepancy_report_v` AS 
select
   `t2`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`PERSON_ID` AS `PERSON_ID`,
   `t1`.`POSITION_ID` AS `POSITION_ID`,
   `t4`.`FULL_NAME` AS `FULL_NAME`,
   `t2`.`PI_NAME` AS `PI_NAME`,
   `t2`.`unit_name` AS `UNIT_NAME`,
   `t2`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER` 
from
   (
((`manpower_workday_resource` `t1` 
      join
         `award_master_dataset_rt` `t2` 
         on(((substring_index(`t1`.`WBS_NUMBER`, 'EOM', 1) = `t2`.`ACCOUNT_NUMBER`) 
         and 
         (
            `t2`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'
         )
         and 
         (
            `t2`.`PERSON_ROLE_ID` = 3
         )
))) 
      join
         `manpower` `t3` 
         on((`t3`.`PERSON_ID` = `t1`.`PERSON_ID`))) 
      join
         `person` `t4` 
         on((`t4`.`PERSON_ID` = `t1`.`PERSON_ID`))
   )
where
   (
(`t1`.`POSITION_STATUS_CODE` not in 
      (
         4,
         5
      )
) 
      and 
      (
         `t1`.`BASE_SALARY_USED` is not null
      )
      and 
      (
         `t1`.`BASE_SALARY_USED` <> `t3`.`BASE_SALARY`
      )
   )
;

