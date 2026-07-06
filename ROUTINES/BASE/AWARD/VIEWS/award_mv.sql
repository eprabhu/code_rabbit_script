-- award_mv;

CREATE VIEW `award_mv` AS 
select
   `t1`.`AWARD_ID` AS `DOCUMENT_NUMBER`,
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`AWARD_ID` AS `AWARD_ID`,
   `t1`.`TITLE` AS `TITLE`,
   `t1`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `t1`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`,
   `t2`.`DESCRIPTION` AS `STATUS`,
   `t3`.`SPONSOR_NAME` AS `SPONSOR`,
   `t1`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
   `t4`.`UNIT_NUMBER` AS `UNIT_NUMBER`,
   `t4`.`unit_name` AS `UNIT_NAME`,
   `award_persons`.`FULL_NAME` AS `FULL_NAME`,
   `award_persons`.`PERSON_ID` AS `PERSON_ID`,
   `t1`.`UPDATE_TIMESTAMP` AS `UPDATE_TIMESTAMP`,
   `t1`.`UPDATE_USER` AS `UPDATE_USER` 
from
   (
(((`award` `t1` 
      left join
         `award_persons` 
         on(((`t1`.`AWARD_ID` = `award_persons`.`AWARD_ID`) 
         and 
         (
            `award_persons`.`PERSON_ROLE_ID` = 3
         )
))) 
      left join
         `award_status` `t2` 
         on((`t1`.`STATUS_CODE` = `t2`.`STATUS_CODE`))) 
      left join
         `sponsor` `t3` 
         on((`t3`.`SPONSOR_CODE` = `t1`.`SPONSOR_CODE`))) 
      left join
         `unit` `t4` 
         on((`t1`.`LEAD_UNIT_NUMBER` = `t4`.`UNIT_NUMBER`))
   )
where
   `t1`.`SEQUENCE_NUMBER` in 
   (
      select
         max(`t5`.`SEQUENCE_NUMBER`) 
      from
         `award` `t5` 
      where
         (
            `t5`.`AWARD_NUMBER` = `t1`.`AWARD_NUMBER`
         )
   )
;

