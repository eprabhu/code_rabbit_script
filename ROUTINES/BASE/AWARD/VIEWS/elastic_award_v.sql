-- elastic_award_v;

CREATE VIEW `elastic_award_v` AS 
select
   `award`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `award`.`AWARD_ID` AS `AWARD_ID`,
   `award`.`TITLE` AS `TITLE`,
   `award`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `award`.`STATUS_CODE` AS `STATUS_CODE`,
   `award_status`.`DESCRIPTION` AS `STATUS`,
   `sponsor`.`SPONSOR_NAME` AS `SPONSOR`,
   `award`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
   `sponsor`.`DISPLAY_NAME` AS `SPONSOR_DISPLAY_NAME`,
   `unit`.`UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `unit`.`unit_name` AS `LEAD_UNIT_NAME`,
   `unit`.`DISPLAY_NAME` AS `UNIT_DISPLAY_NAME`,
   `award_persons`.`FULL_NAME` AS `PI_NAME`,
   `award_persons`.`PERSON_ID` AS `PERSON_ID`,
   `awi`.`OBLIGATION_EXPIRATION_DATE` AS `OBLIGATION_EXPIRATION_DATE`,
   `t1`.`NAME` AS `grant_call_title`,
   `award`.`SPONSOR_AWARD_NUMBER` AS `SP_AWD_NUMBER`,
   `t13`.`SCHEME_NAME` AS `funding_scheme` 
from
   (
(((((((`award` 
      left join
         `award_persons` 
         on(((`award`.`AWARD_ID` = `award_persons`.`AWARD_ID`) 
         and 
         (
            `award_persons`.`PERSON_ROLE_ID` = 3
         )
))) 
      left join
         `award_status` 
         on((`award`.`STATUS_CODE` = `award_status`.`STATUS_CODE`))) 
      left join
         `sponsor` 
         on((`sponsor`.`SPONSOR_CODE` = `award`.`SPONSOR_CODE`))) 
      left join
         `unit` 
         on((`award`.`LEAD_UNIT_NUMBER` = `unit`.`UNIT_NUMBER`))) 
      left join
         (
            select
               `s1`.`AWARD_ID` AS `AWARD_ID`,
               `s1`.`OBLIGATION_EXPIRATION_DATE` AS `OBLIGATION_EXPIRATION_DATE` 
            from
               `award_amount_info` `s1` 
            where
               `s1`.`AWARD_AMOUNT_INFO_ID` in 
               (
                  select
                     max(`s2`.`AWARD_AMOUNT_INFO_ID`) 
                  from
                     `award_amount_info` `s2` 
                  where
                     (
                        `s1`.`AWARD_ID` = `s2`.`AWARD_ID`
                     )
               )
         )
         `awi` 
         on((`awi`.`AWARD_ID` = `award`.`AWARD_ID`))) 
      left join
         `grant_call_header` `t1` 
         on((`t1`.`GRANT_HEADER_ID` = `award`.`GRANT_HEADER_ID`))) 
      left join
         `sponsor_funding_scheme` `t12` 
         on((`t12`.`FUNDING_SCHEME_ID` = `t1`.`FUNDING_SCHEME_ID`))) 
      left join
         `funding_scheme` `t13` 
         on((`t13`.`FUNDING_SCHEME_CODE` = `t12`.`FUNDING_SCHEME_CODE`))
   )
where
   (
(`award`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE') 
      or 
      (
(`award`.`AWARD_DOCUMENT_TYPE_CODE` = 1) 
         and 
         (
            `award`.`AWARD_SEQUENCE_STATUS` = 'PENDING'
         )
      )
   )
;

