
-- award_permission_report_v;

CREATE VIEW `award_permission_report_v` AS with `sgr` as 
(
   select distinct
      `apr`.`AWARD_ID` AS `award_id`,
      `apr`.`PERSON_ID` AS `person_id`,
      `apr`.`ROLE_ID` AS `role_id` 
   from
      `award_person_roles` `apr` 
   where
      (
         `apr`.`IS_SYSTEM_GENERATED` = 'N'
      )
)
,
`pi` as 
(
   select distinct
      `award_persons`.`AWARD_ID` AS `award_id`,
      `award_persons`.`PERSON_ID` AS `person_id` 
   from
      `award_persons` 
   where
      (
         `award_persons`.`PI_FLAG` = 'Y'
      )
)
,
`awd` as 
(
   select distinct
      `award`.`AWARD_ID` AS `award_id`,
      `award`.`AWARD_NUMBER` AS `award_number`,
      `award`.`ACCOUNT_NUMBER` AS `account_number`,
      `award`.`TITLE` AS `title`,
      `award`.`LEAD_UNIT_NUMBER` AS `lead_unit_number`,
      `award`.`UPDATE_TIMESTAMP` AS `update_timestamp`,
      `award`.`STATUS_CODE` AS `STATUS_CODE` 
   from
      `award` 
   where
      (
         `award`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'
      )
)
select distinct
   `a`.`award_id` AS `award_id`,
   `a`.`award_number` AS `award_number`,
   `a`.`account_number` AS `account_number`,
   `a`.`title` AS `title`,
   `pe`.`FULL_NAME` AS `pi_name`,
   `p`.`FULL_NAME` AS `person_name`,
   `a`.`lead_unit_number` AS `lead_unit_number`,
   `u`.`unit_name` AS `unit_name`,
   `p`.`EMAIL_ADDRESS` AS `email_address`,
   `p`.`PERSON_ID` AS `person_id`,
   `a`.`update_timestamp` AS `update_timestamp`,
   `ro`.`ROLE_NAME` AS `ROLE_NAME`,
   `as`.`DESCRIPTION` AS `AWARD_STATUS` 
from
   (
((((((((`awd` `a` 
      left join
         `sgr` `s` 
         on((`a`.`award_id` = `s`.`award_id`))) 
      left join
         `pi` 
         on((`pi`.`award_id` = `a`.`award_id`))) 
      join
         `person` `pe` 
         on((`pe`.`PERSON_ID` = `pi`.`person_id`))) 
      join
         `person` `p` 
         on((`s`.`person_id` = `p`.`PERSON_ID`))) 
      join
         `unit` `u` 
         on((`a`.`lead_unit_number` = `u`.`UNIT_NUMBER`))) 
      join
         `role_rights` `rr` 
         on((`s`.`role_id` = `rr`.`ROLE_ID`))) 
      join
         `role` `ro` 
         on((`rr`.`ROLE_ID` = `ro`.`ROLE_ID`))) 
      join
         `award_status` `as` 
         on((`a`.`STATUS_CODE` = `as`.`STATUS_CODE`))) 
      join
         `rights` `r` 
         on((`rr`.`RIGHT_ID` = `r`.`RIGHT_ID`))
   )
;

