-- person_v;

CREATE VIEW `person_v` AS 
select
   `t1`.`PERSON_ID` AS `PERSON_ID`,
   `t1`.`LAST_NAME` AS `LAST_NAME`,
   `t1`.`FIRST_NAME` AS `FIRST_NAME`,
   `t1`.`MIDDLE_NAME` AS `MIDDLE_NAME`,
   `t1`.`FULL_NAME` AS `FULL_NAME`,
   `t1`.`USER_NAME` AS `USER_NAME`,
   `t1`.`EMAIL_ADDRESS` AS `EMAIL_ADDRESS`,
   `t1`.`PRIMARY_TITLE` AS `PRIMARY_TITLE`,
   `t1`.`DIRECTORY_TITLE` AS `DIRECTORY_TITLE`,
   `t1`.`HOME_UNIT` AS `HOME_UNIT`,
   `t2`.`unit_name` AS `HOME_UNIT_NAME`,
   `t1`.`ADDRESS_LINE_1` AS `ADDRESS_LINE_1`,
   `t1`.`ADDRESS_LINE_2` AS `ADDRESS_LINE_2`,
   `t1`.`ADDRESS_LINE_3` AS `ADDRESS_LINE_3`,
   `t1`.`MOBILE_PHONE_NUMBER` AS `MOBILE_PHONE_NUMBER`,
   `t1`.`STATUS` AS `STATUS`,
   `t1`.`IS_FACULTY` AS `IS_FACULTY`,
   `t1`.`IS_RESEARCH_STAFF` AS `IS_RESEARCH_STAFF` 
from
   (
      `person` `t1` 
      left join
         `unit` `t2` 
         on((`t1`.`HOME_UNIT` = `t2`.`UNIT_NUMBER`))
   )
where
   (
      `t1`.`STATUS` = 'A'
   )
;

