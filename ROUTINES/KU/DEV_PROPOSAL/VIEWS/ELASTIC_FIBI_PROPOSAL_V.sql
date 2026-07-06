CREATE VIEW `ELASTIC_FIBI_PROPOSAL_V` AS 
SELECT
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
   `t14`.`DISPLAY_NAME` AS `UNIT_DISPLAY_NAME`,
   `t1`.`EXTERNAL_FUNDING_AGENCY_ID` AS `EXTERNAL_FUNDING_AGENCY_ID`
FROM
   (
((((((((`eps_proposal` `t1` 
      LEFT JOIN
         `eps_proposal_persons` `t2` 
         ON(((`t1`.`PROPOSAL_ID` = `t2`.`PROPOSAL_ID`) 
         and 
         (
            `t2`.`PROP_PERSON_ROLE_ID` = 3
         )
))) 
      JOIN
         `eps_proposal_type` `t3` 
         ON((`t1`.`TYPE_CODE` = `t3`.`TYPE_CODE`))) 
      JOIN
         `eps_proposal_status` `t4` 
         ON((`t1`.`STATUS_CODE` = `t4`.`STATUS_CODE`))) 
      JOIN
         `activity_type` `t5` 
         ON((`t1`.`ACTIVITY_TYPE_CODE` = `t5`.`ACTIVITY_TYPE_CODE`))) 
      LEFT JOIN
         `sponsor` `t6` 
         ON((`t1`.`SPONSOR_CODE` = `t6`.`SPONSOR_CODE`))) 
      LEFT JOIN
         `unit` `t14` 
         ON((`t1`.`HOME_UNIT_NUMBER` = `t14`.`UNIT_NUMBER`))) 
      LEFT JOIN
         `grant_call_header` `t11` 
         ON((`t11`.`GRANT_HEADER_ID` = `t1`.`GRANT_HEADER_ID`))) 
      LEFT JOIN
         `sponsor_funding_scheme` `t12` 
         ON((`t12`.`FUNDING_SCHEME_ID` = `t11`.`FUNDING_SCHEME_ID`))) 
      LEFT JOIN
         `funding_scheme` `t13` 
         ON((`t13`.`FUNDING_SCHEME_CODE` = `t12`.`FUNDING_SCHEME_CODE`))
   )
WHERE
   (
(`t1`.`STATUS_CODE` <> 35) 
      AND
      (
         `t1`.`DOCUMENT_STATUS_CODE` <> '3'
      )
   )
;

