-- award_variation_report_v;

CREATE VIEW `award_variation_report_v` AS 
select distinct
   `t1`.`AWARD_ID` AS `AWARD_ID`,
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `t1`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`,
   `t1`.`TITLE` AS `TITLE`,
   `t2`.`DESCRIPTION` AS `AWARD_STATUS`,
   `t3`.`DESCRIPTION` AS `ACCOUNT_TYPE`,
   `t4`.`DESCRIPTION` AS `AWARD_TYPE`,
   `t5`.`DESCRIPTION` AS `ACTIVITY_TYPE`,
   `t1`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   NULL AS `SUB_LEAD_UNIT`,
   `t6`.`unit_name` AS `LEAD_UNIT`,
   `t1`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
   `t7`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
   `t1`.`PRIME_SPONSOR_CODE` AS `PRIME_SPONSOR_CODE`,
   `t8`.`SPONSOR_NAME` AS `PRIME_SPONSOR_NAME`,
   `t1`.`AWARD_EXECUTION_DATE` AS `AWARD_EXECUTION_DATE`,
   `t1`.`AWARD_EFFECTIVE_DATE` AS `AWARD_EFFECTIVE_DATE`,
   `t1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
   `t1`.`AWARD_SEQUENCE_STATUS` AS `AWARD_SEQUENCE_STATUS`,
   `t1`.`BEGIN_DATE` AS `BEGIN_DATE`,
   `t10`.`CREATE_TIMESTAMP` AS `VARIATION_CREATE_TIMESTAMP`,
   `t1`.`SUBMISSION_DATE` AS `SUBMISSION_DATE`,
   `t18`.`FULL_NAME` AS `SUBMIT_USER`,
   `t12`.`NAME` AS `GRANT_CALL_TITLE`,
   `t13`.`SPONSOR_NAME` AS `GRANT_FUNDING_AGENCY`,
   `t14`.`DESCRIPTION` AS `GRANT_FUNDING_AGENCY_TYPE`,
   `t15`.`DESCRIPTION` AS `SR_TYPE`,
   `t16`.`DESCRIPTION` AS `SR_STATUS`,
   `t17`.`FULL_NAME` AS `VARIATION_REQUEST_APPROVAL_USER`,
   `t1`.`UPDATE_TIMESTAMP` AS `VARIATION_REQUEST_APPROVAL_TIME`,
   `t11`.`FULL_NAME` AS `VARIATION_CREATE_USER`,
   `t1`.`WORKFLOW_AWARD_STATUS_CODE` AS `WORKFLOW_AWARD_STATUS_CODE`,
   `t19`.`DESCRIPTION` AS `AWARD_WORKFLOW_STATUS`,
   `t21`.`DESCRIPTION` AS `FUNDING_SCHEME`,
   `t1`.`DURATION` AS `DURATION`,
   `t22`.`DESCRIPTION` AS `SPONSOR_TYPE`,
   `t7`.`SPONSOR_TYPE_CODE` AS `SPONSOR_TYPE_CODE`,
   `t23`.`DESCRIPTION` AS `PERSON_ROLE`,
   `t25`.`ORGANIZATION_NAME` AS `KEY_PERSON_ORGANIZATION`,
   `t34`.`DESCRIPTION` AS `GRANT_TYPE`,
   ifnull(`t26`.`FULL_NAME`, `t24`.`FULL_NAME`) AS `KEY_PERSON_NAME`,
   ifnull(`t26`.`GENDER`, NULL) AS `KEY_PERSON_GENDER`,
   ifnull(`t24`.`EMAIL_ADDRESS`, `t26`.`EMAIL_ADDRESS`) AS `KEY_PERSON_EMAIL`,
   ifnull(`t28`.`COUNTRY_NAME`, `t29`.`COUNTRY_NAME`) AS `KEY_PERSON_COUNTRY`,
   `t9`.`PERCENTAGE_OF_EFFORT` AS `PERCENTAGE_OF_EFFORT`,
   NULL AS `FEED_STATUS`,
   `t1`.`FUNDER_APPROVAL_DATE` AS `FUNDER_APPROVAL_DATE`,
   ifnull(`t9`.`PERSON_ID`, `t9`.`ROLODEX_ID`) AS `KEY_PERSON_ID`,
   (
      select
         ifnull(`p2`.`FULL_NAME`, `r1`.`FULL_NAME`) 
      from
         (
(`award_persons` `p1` 
            left join
               `person` `p2` 
               on((`p1`.`PERSON_ID` = `p2`.`PERSON_ID`))) 
            left join
               `rolodex` `r1` 
               on((`p1`.`ROLODEX_ID` = `r1`.`ROLODEX_ID`))
         )
      where
         (
(`p1`.`AWARD_ID` = `t1`.`AWARD_ID`) 
            and 
            (
               `p1`.`PI_FLAG` = 'Y'
            )
         )
   )
   AS `PI_NAME`,
   (
      select
         ifnull(`p1`.`PERSON_ID`, `p1`.`ROLODEX_ID`) 
      from
         `award_persons` `p1` 
      where
         (
(`p1`.`AWARD_ID` = `t1`.`AWARD_ID`) 
            and 
            (
               `p1`.`PI_FLAG` = 'Y'
            )
         )
   )
   AS `PI_PERSON_ID`,
   `t30`.`WORKFLOW_END_DATE` AS `WORKFLOW_END_DATE`,
   `t31`.`FULL_NAME` AS `WORKFLOW_END_PERSON`,
   `t33`.`HOME_UNIT_NUMBER` AS `HOME_UNIT_NUMBER`,
   `t36`.`DESCRIPTION` AS `F_AND_A_RATE_TYPE` 
from
   (
((((((((((((((((((((((((((((((((((`award` `t1` 
      join
         `sr_header` `t10` 
         on(((`t10`.`ORIGINATING_MODULE_ITEM_KEY` = `t1`.`AWARD_ID`) 
         and 
         (
            `t10`.`ORIGINATING_MODULE_CODE` = '1'
         )
))) 
      join
         `award_status` `t2` 
         on((`t1`.`STATUS_CODE` = `t2`.`STATUS_CODE`))) 
      left join
         `account_type` `t3` 
         on((`t1`.`ACCOUNT_TYPE_CODE` = `t3`.`ACCOUNT_TYPE_CODE`))) 
      left join
         `award_type` `t4` 
         on((`t4`.`AWARD_TYPE_CODE` = `t1`.`AWARD_TYPE_CODE`))) 
      join
         `activity_type` `t5` 
         on((`t1`.`ACTIVITY_TYPE_CODE` = `t5`.`ACTIVITY_TYPE_CODE`))) 
      join
         `unit` `t6` 
         on((`t1`.`LEAD_UNIT_NUMBER` = `t6`.`UNIT_NUMBER`))) 
      join
         `sponsor` `t7` 
         on((`t1`.`SPONSOR_CODE` = `t7`.`SPONSOR_CODE`))) 
      left join
         `sponsor` `t8` 
         on((`t1`.`PRIME_SPONSOR_CODE` = `t8`.`SPONSOR_CODE`))) 
      join
         `award_persons` `t9` 
         on((`t1`.`AWARD_ID` = `t9`.`AWARD_ID`))) 
      left join
         `person` `t11` 
         on((`t11`.`USER_NAME` = `t10`.`CREATE_USER`))) 
      left join
         `grant_call_header` `t12` 
         on((`t12`.`GRANT_HEADER_ID` = `t1`.`GRANT_HEADER_ID`))) 
      left join
         `sponsor` `t13` 
         on((`t12`.`SPONSOR_CODE` = `t13`.`SPONSOR_CODE`))) 
      left join
         `sponsor_type` `t14` 
         on((`t12`.`SPONSOR_TYPE_CODE` = `t14`.`SPONSOR_TYPE_CODE`))) 
      left join
         `sr_type` `t15` 
         on((`t15`.`TYPE_CODE` = `t1`.`AWARD_VARIATION_TYPE_CODE`))) 
      left join
         `sr_status` `t16` 
         on((`t16`.`STATUS_CODE` = `t10`.`STATUS_CODE`))) 
      left join
         `person` `t17` 
         on((`t17`.`USER_NAME` = `t1`.`DOCUMENT_UPDATE_USER`))) 
      left join
         `person` `t18` 
         on((`t18`.`USER_NAME` = `t1`.`SUBMIT_USER`))) 
      left join
         `award_workflow_status` `t19` 
         on((`t19`.`WORKFLOW_AWARD_STATUS_CODE` = `t1`.`WORKFLOW_AWARD_STATUS_CODE`))) 
      left join
         `sponsor_funding_scheme` `t20` 
         on((`t12`.`FUNDING_SCHEME_ID` = `t20`.`FUNDING_SCHEME_ID`))) 
      left join
         `funding_scheme` `t21` 
         on((`t20`.`FUNDING_SCHEME_CODE` = `t21`.`FUNDING_SCHEME_CODE`))) 
      left join
         `sponsor_type` `t22` 
         on((`t7`.`SPONSOR_TYPE_CODE` = `t22`.`SPONSOR_TYPE_CODE`))) 
      left join
         `eps_prop_person_role` `t23` 
         on((`t9`.`PERSON_ROLE_ID` = `t23`.`PROP_PERSON_ROLE_ID`))) 
      left join
         `rolodex` `t24` 
         on((`t9`.`ROLODEX_ID` = `t24`.`ROLODEX_ID`))) 
      left join
         `organization` `t25` 
         on((`t24`.`ORGANIZATION` = `t25`.`ORGANIZATION_ID`))) 
      left join
         `person` `t26` 
         on((`t9`.`PERSON_ID` = `t26`.`PERSON_ID`))) 
      left join
         `unit` `t27` 
         on((`t26`.`HOME_UNIT` = `t27`.`UNIT_NUMBER`))) 
      left join
         `country` `t28` 
         on((`t26`.`COUNTRY_CODE` = `t28`.`COUNTRY_CODE`))) 
      left join
         `country` `t29` 
         on((`t24`.`COUNTRY_CODE` = `t29`.`COUNTRY_CODE`))) 
      left join
         `grant_call_header` `t33` 
         on((`t1`.`GRANT_HEADER_ID` = `t33`.`GRANT_HEADER_ID`))) 
      left join
         `grant_call_type` `t34` 
         on((`t33`.`GRANT_TYPE_CODE` = `t34`.`GRANT_TYPE_CODE`))) 
      left join
         `workflow` `t30` 
         on(((`t30`.`MODULE_ITEM_ID` = `t1`.`AWARD_ID`) 
         and 
         (
            `t30`.`IS_WORKFLOW_ACTIVE` = 'Y'
         )
         and 
         (
            `t30`.`MODULE_CODE` = 1
         )
))) 
      left join
         `person` `t31` 
         on((`t30`.`WORKFLOW_END_PERSON` = `t31`.`PERSON_ID`))) 
      left join
         (
            select
               `t35`.`AWARD_ID` AS `AWARD_ID`,
               `t35`.`RATE_CLASS_CODE` AS `RATE_CLASS_CODE`,
               `t35`.`RATE_TYPE_CODE` AS `RATE_TYPE_CODE` 
            from
               `award_budget_header` `t35` 
            where
               `t35`.`VERSION_NUMBER` in 
               (
                  select
                     max(`award_budget_header`.`VERSION_NUMBER`) 
                  from
                     `award_budget_header` 
                  where
                     (
                        `award_budget_header`.`AWARD_ID` = `t35`.`AWARD_ID`
                     )
               )
         )
         `t38` 
         on((`t38`.`AWARD_ID` = `t1`.`AWARD_ID`))) 
      left join
         `rate_class` `t37` 
         on((`t37`.`RATE_CLASS_CODE` = `t38`.`RATE_CLASS_CODE`))) 
      left join
         `rate_type` `t36` 
         on(((`t36`.`RATE_TYPE_CODE` = `t38`.`RATE_TYPE_CODE`) 
         and 
         (
            `t36`.`RATE_CLASS_CODE` = `t38`.`RATE_CLASS_CODE`
         )
))
   )
where
   (
      `t1`.`AWARD_DOCUMENT_TYPE_CODE` in 
      (
         '3',
         '2'
      )
   )
;

