-- elastic_institute_proposal_v;

CREATE VIEW `elastic_institute_proposal_v` AS 
select
   `t1`.`PROPOSAL_ID` AS `PROPOSAL_ID`,
   `t1`.`PROPOSAL_NUMBER` AS `PROPOSAL_NUMBER`,
   `t1`.`TITLE` AS `TITLE`,
   `t1`.`HOME_UNIT_NUMBER` AS `HOME_UNIT_NUMBER`,
   `t1`.`HOME_UNIT_NAME` AS `LEAD_UNIT`,
   `t14`.`DISPLAY_NAME` AS `UNIT_DISPLAY_NAME`,
   `t1`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
   `t10`.`SPONSOR_NAME` AS `SPONSOR`,
   `t10`.`DISPLAY_NAME` AS `SPONSOR_DISPLAY_NAME`,
   `t1`.`INTERNAL_DEADLINE_DATE` AS `DEADLINE_DATE`,
   `t1`.`STATUS_CODE` AS `STATUS_CODE`,
   `t4`.`DESCRIPTION` AS `STATUS`,
   `t1`.`UPDATE_TIMESTAMP` AS `UPDATE_TIMESTAMP`,
   `t1`.`UPDATE_USER` AS `UPDATE_USER`,
   `t7`.`FULL_NAME` AS `PI_FULL_NAME`,
   `t5`.`TYPE_CODE` AS `PROPOSAL_TYPE_CODE`,
   `t5`.`DESCRIPTION` AS `PROPOSAL_TYPE`,
   `t6`.`ACTIVITY_TYPE_CODE` AS `ACTIVITY_TYPE_CODE`,
   `t6`.`DESCRIPTION` AS `ACTIVITY_TYPE`,
   `t1`.`PROPOSAL_SEQUENCE_STATUS` AS `PROPOSAL_SEQUENCE_STATUS`,
   ifnull(`t9`.`TOTAL_COST`, 0) AS `TOTAL_COST`,
   `t13`.`SCHEME_NAME` AS `funding_scheme` 
from
   (
((((((((((`proposal` `t1` 
      left join
         `proposal_status` `t4` 
         on((`t1`.`STATUS_CODE` = `t4`.`STATUS_CODE`))) 
      left join
         `proposal_type` `t5` 
         on((`t1`.`TYPE_CODE` = `t5`.`TYPE_CODE`))) 
      left join
         `activity_type` `t6` 
         on((`t6`.`ACTIVITY_TYPE_CODE` = `t1`.`ACTIVITY_TYPE_CODE`))) 
      left join
         `proposal_persons` `t7` 
         on(((`t7`.`PROPOSAL_ID` = `t1`.`PROPOSAL_ID`) 
         and 
         (
            `t7`.`PROP_PERSON_ROLE_ID` = 3
         )
))) 
      left join
         `proposal_admin_details` `t8` 
         on((`t8`.`INST_PROPOSAL_ID` = `t1`.`PROPOSAL_ID`))) 
      left join
         `budget_header` `t9` 
         on((`t9`.`PROPOSAL_ID` = `t8`.`DEV_PROPOSAL_ID`))) 
      left join
         `sponsor` `t10` 
         on((`t10`.`SPONSOR_CODE` = `t1`.`SPONSOR_CODE`))) 
      left join
         `unit` `t14` 
         on((`t14`.`UNIT_NUMBER` = `t1`.`HOME_UNIT_NUMBER`))) 
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
      `t1`.`PROPOSAL_SEQUENCE_STATUS` = 'ACTIVE'
   )
;

