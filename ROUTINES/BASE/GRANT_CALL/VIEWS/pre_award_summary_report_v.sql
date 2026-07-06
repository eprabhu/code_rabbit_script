-- pre_award_summary_report_v;

CREATE VIEW `pre_award_summary_report_v` AS 
select
   concat(`s`.`SPONSOR_CODE`, '-', `s`.`SPONSOR_NAME`) AS `SPONSOR`,
   `gch`.`NAME` AS `GRANT_CALL_TITLE`,
   `gch`.`GRANT_HEADER_ID` AS `GRANT_HEADER_ID`,
   `t4`.`DESCRIPTION` AS `GRANT_CALL_TYPE` 
from
   (
(`grant_call_header` `gch` 
      join
         `grant_call_type` `t4` 
         on((`gch`.`GRANT_TYPE_CODE` = `t4`.`GRANT_TYPE_CODE`))) 
      join
         `sponsor` `s` 
         on((`gch`.`SPONSOR_CODE` = `s`.`SPONSOR_CODE`))
   )
;

