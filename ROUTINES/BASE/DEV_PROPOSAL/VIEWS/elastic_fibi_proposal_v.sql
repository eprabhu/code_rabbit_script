-- elastic_fibi_proposal_v;

CREATE VIEW `elastic_fibi_proposal_v` AS 
select
   `t1`.`PROPOSAL_ID` AS `PROPOSAL_ID`,
   `t1`.`TITLE` AS `TITLE`,
   `t2`.`FULL_NAME` AS `FULL_NAME`,
   `t5`.`DESCRIPTION` AS `CATEGORY`,
   `t3`.`DESCRIPTION` AS `TYPE`,
   `t4`.`DESCRIPTION` AS `STATUS`,
   `t6`.`SPONSOR_NAME` AS `SPONSOR`,
   `t6`.`DISPLAY_NAME` AS `SPONSOR_DISPLAY_NAME`,
   `t1`.`APPLICATION_ID` AS `APPLICATION_ID`,
   `t1`.`HOME_UNIT_NAME` AS `LEAD_UNIT_NAME`,
   `t1`.`HOME_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `t13`.`SCHEME_NAME` AS `funding_scheme`,
   `t14`.`DISPLAY_NAME` AS `UNIT_DISPLAY_NAME` 
from
   (
((((((((`eps_proposal` `t1` 
      left join
         `eps_proposal_persons` `t2` 
         on(((`t1`.`PROPOSAL_ID` = `t2`.`PROPOSAL_ID`) 
         and 
         (
            `t2`.`PROP_PERSON_ROLE_ID` = 3
         )
))) 
      join
         `eps_proposal_type` `t3` 
         on((`t1`.`TYPE_CODE` = `t3`.`TYPE_CODE`))) 
      join
         `eps_proposal_status` `t4` 
         on((`t1`.`STATUS_CODE` = `t4`.`STATUS_CODE`))) 
      join
         `activity_type` `t5` 
         on((`t1`.`ACTIVITY_TYPE_CODE` = `t5`.`ACTIVITY_TYPE_CODE`))) 
      left join
         `sponsor` `t6` 
         on((`t1`.`SPONSOR_CODE` = `t6`.`SPONSOR_CODE`))) 
      left join
         `unit` `t14` 
         on((`t1`.`HOME_UNIT_NUMBER` = `t14`.`UNIT_NUMBER`))) 
      left join
         `grant_call_header` `t11` 
         on((`t11`.`GRANT_HEADER_ID` = `t1`.`GRANT_HEADER_ID`))) 
      left join
         `sponsor_funding_scheme` `t12` 
         on((`t12`.`FUNDING_SCHEME_ID` = `t11`.`FUNDING_SCHEME_ID`))) 
      left join
         `funding_scheme` `t13` 
         on((`t13`.`FUNDING_SCHEME_CODE` = `t12`.`FUNDING_SCHEME_CODE`))
   )
where
   (
(`t1`.`STATUS_CODE` <> 35) 
      and 
      (
         `t1`.`DOCUMENT_STATUS_CODE` <> '3'
      )
   )
;

