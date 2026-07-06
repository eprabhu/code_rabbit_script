-- grant_call_report_v;

CREATE VIEW `grant_call_report_v` AS 
select
   `t1`.`GRANT_HEADER_ID` AS `GRANT_HEADER_ID`,
   `t1`.`NAME` AS `NAME`,
   `t1`.`HOME_UNIT_NAME` AS `HOME_UNIT_NAME`,
   `t2`.`DESCRIPTION` AS `GRANT_STATUS`,
   `t3`.`DESCRIPTION` AS `GRANT_TYPE`,
   cast(`t1`.`OPENING_DATE` as date) AS `OPENING_DATE`,
   cast(`t1`.`CLOSING_DATE` as date) AS `CLOSING_DATE`,
   date_format(`t1`.`CLOSING_DATE`, '%h:%i:%s') AS `CLOSING_TIME`,
   `t4`.`SPONSOR_NAME` AS `SPONSOR`,
   `t5`.`DESCRIPTION` AS `SPONSOR_TYPE`,
   `t9`.`SCHEME_NAME` AS `FUNDING_SCHEME`,
   `t8`.`DESCRIPTION` AS `RELEVANT_FIELD`,
   `t1`.`HOME_UNIT_NUMBER` AS `HOME_UNIT_NUMBER` 
from
   (
(((((((`grant_call_header` `t1` 
      left join
         `grant_call_status` `t2` 
         on((`t1`.`GRANT_STATUS_CODE` = `t2`.`GRANT_STATUS_CODE`))) 
      left join
         `grant_call_type` `t3` 
         on((`t1`.`GRANT_TYPE_CODE` = `t3`.`GRANT_TYPE_CODE`))) 
      left join
         `sponsor` `t4` 
         on((`t1`.`SPONSOR_CODE` = `t4`.`SPONSOR_CODE`))) 
      left join
         `sponsor_type` `t5` 
         on((`t1`.`SPONSOR_TYPE_CODE` = `t5`.`SPONSOR_TYPE_CODE`))) 
      left join
         `sponsor_funding_scheme` `t6` 
         on((`t1`.`FUNDING_SCHEME_ID` = `t6`.`FUNDING_SCHEME_ID`))) 
      left join
         `grant_call_relevant_field` `t7` 
         on((`t1`.`GRANT_HEADER_ID` = `t7`.`GRANT_HEADER_ID`))) 
      left join
         `relevant_field` `t8` 
         on((`t7`.`RELEVANT_FIELD_CODE` = `t8`.`RELEVANT_FIELD_CODE`))) 
      left join
         `funding_scheme` `t9` 
         on((`t9`.`FUNDING_SCHEME_CODE` = `t6`.`FUNDING_SCHEME_CODE`))
   )
;

