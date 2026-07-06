


-- award_orcid_report_v;

CREATE VIEW `award_orcid_report_v` AS 
select
   `t2`.`ORCID_ID` AS `ORCID_ID`,
   `t8`.`FULL_NAME` AS `ORCID_PERSON_NAME`,
   `t1`.`PUT_CODE` AS `PUT_CODE`,
   `t1`.`TITLE` AS `ORCID_TITLE`,
   `t4`.`DESCRIPTION` AS `WORK_CATEGORY`,
   `t5`.`DESCRIPTION` AS `WORK_TYPE`,
   trim(both '-' 
from
   concat(ifnull(`t1`.`PUBLICATION_YEAR`, ''), convert((
   case
      when
         (
(`t1`.`PUBLICATION_MONTH` is not null) 
            and 
            (
               trim(`t1`.`PUBLICATION_MONTH`) <> ''
            )
         )
      then
         '-' 
      else
         '' 
   end
) using utf8mb4), ifnull(`t1`.`PUBLICATION_MONTH`, ''), convert((
   case
      when
         (
(`t1`.`PUBLICATION_DAY` is not null) 
            and 
            (
               trim(`t1`.`PUBLICATION_DAY`) <> ''
            )
         )
      then
         '-' 
      else
         '' 
   end
) using utf8mb4), ifnull(`t1`.`PUBLICATION_DAY`, ''))) AS `PUBLICATION_DATE`, `t1`.`JOURNAL_TITLE` AS `PUBLISHER`, `t1`.`CITATION_VALUE` AS `CITATION`, `t1`.`LAST_MODIFIED_DATE` AS `LAST_MODIFIED_DATE`, `t9`.`CONTRIBUTOR` AS `CONTRIBUTOR`, `t1`.`URL` AS `URL`, `t6`.`COUNTRY_NAME` AS `COUNTRY`, `t1`.`TRANSLATED_TITLE` AS `TRANSLATED_TITLE`, `t7`.`DESCRIPTION` AS `LANGUAGE`, `t1`.`SUB_TITLE` AS `SUB_TITLE`, `t1`.`SOURCE` AS `SOURCE`, `t10`.`AWARD_ID` AS `AWARD_ID`, `t10`.`TITLE` AS `TITLE`, `t10`.`PI_NAME` AS `PI_NAME`, `t10`.`AWARD_TYPE` AS `AWARD_TYPE`, `t10`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`, `t10`.`AWARD_STATUS` AS `AWARD_STATUS`, `t10`.`SPONSOR_NAME` AS `SPONSOR_NAME`, `t10`.`SPONSOR_TYPE` AS `SPONSOR_TYPE`, `t10`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`, `t10`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`, `t10`.`AWARD_UNIT_NAME` AS `AWARD_UNIT_NAME`, `t10`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`, `t10`.`AWARD_EFFECTIVE_DATE` AS `AWARD_EFFECTIVE_DATE`, `t10`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`, `t10`.`DURATION` AS `DURATION`, `t10`.`AWARD_NUMBER` AS `AWARD_NUMBER`, `t10`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`, `t10`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`, `t10`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`, `t10`.`TOTAL_PROJECT_COST` AS `TOTAL_PROJECT_COST`, `t10`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`, `t10`.`ABBREVIATION` AS `ABBREVIATION`, `t10`.`GRANTCALL_UNIT_NAME` AS `GRANTCALL_UNIT_NAME`, `t10`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`, `t10`.`FUNDING_AGENCY` AS `FUNDING_AGENCY`, `t10`.`FUNDING_AGENCY_TYPE` AS `FUNDING_AGENCY_TYPE`, `t8`.`HOME_UNIT` AS `PERSON_HOME_UNIT_NUMBER`, `t11`.`unit_name` AS `PERSON_HOME_UNIT`, `t8`.`EMAIL_ADDRESS` AS `PERSON_EMAIL`, `t8`.`PERSON_ID` AS `PERSON_ID`, `t10`.`F_AND_A_RATE_TYPE` AS `F_AND_A_RATE_TYPE` 
from
   (
(((((((((`orcid_work` `t1` 
      left join
         `person_orcid_work` `t2` 
         on((`t1`.`PUT_CODE` = `t2`.`PUT_CODE`))) 
      left join
         `award_person_orcid_work` `t3` 
         on((`t2`.`PERSON_ORCID_WORK_ID` = `t3`.`PERSON_ORCID_WORK_ID`))) 
      left join
         `orcid_work_category` `t4` 
         on((`t1`.`ORCID_WORK_CATEGORY_CODE` = `t4`.`ORCID_WORK_CATEGORY_CODE`))) 
      left join
         `orcid_work_type` `t5` 
         on((`t1`.`ORCID_WORK_TYPE_CODE` = `t5`.`ORCID_WORK_TYPE_CODE`))) 
      left join
         `country` `t6` 
         on((`t1`.`COUNTRY_CODE` = `t6`.`COUNTRY_CODE_ISO2`))) 
      left join
         `locale` `t7` 
         on((`t1`.`LOCALE_CODE` = `t7`.`LOCALE_CODE`))) 
      left join
         `person` `t8` 
         on((`t2`.`PERSON_ID` = `t8`.`PERSON_ID`))) 
      left join
         `unit` `t11` 
         on((`t11`.`UNIT_NUMBER` = `t8`.`HOME_UNIT`))) 
      left join
         (
            select
               `orcid_work_contributor`.`PUT_CODE` AS `PUT_CODE`,
               group_concat(`orcid_work_contributor`.`CREDIT_NAME` separator '||') AS `CONTRIBUTOR` 
            from
               `orcid_work_contributor` 
            group by
               `orcid_work_contributor`.`PUT_CODE`
         )
         `t9` 
         on((`t1`.`PUT_CODE` = `t9`.`PUT_CODE`))) 
      left join
         (
            select
               `s1`.`AWARD_ID` AS `AWARD_ID`,
               `s1`.`TITLE` AS `TITLE`,
               `s1`.`PI_NAME` AS `PI_NAME`,
               `s1`.`AWARD_TYPE` AS `AWARD_TYPE`,
               `s1`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`,
               `s1`.`AWARD_STATUS` AS `AWARD_STATUS`,
               `s1`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
               `s1`.`SPONSOR_TYPE` AS `SPONSOR_TYPE`,
               `s1`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`,
               `s1`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
               `s1`.`unit_name` AS `AWARD_UNIT_NAME`,
               `s1`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`,
               `s1`.`BEGIN_DATE` AS `AWARD_EFFECTIVE_DATE`,
               `s1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
               `s1`.`DURATION` AS `DURATION`,
               `s1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
               `s1`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
               `s1`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
               `s1`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
               `s1`.`TOTAL_PROJECT_COST` AS `TOTAL_PROJECT_COST`,
               `s1`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`,
               `s1`.`ABBREVIATION` AS `ABBREVIATION`,
               `s1`.`unit_name` AS `GRANTCALL_UNIT_NAME`,
               `s1`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`,
               `s1`.`GRANT_FUNDING_AGENCY` AS `FUNDING_AGENCY`,
               `s1`.`GRANT_FUNDING_AGENCY_TYPE` AS `FUNDING_AGENCY_TYPE`,
               `s1`.`KEY_PERSON_DEPARTMENT_NUMBER` AS `PERSON_HOME_UNIT_NUMBER`,
               `s1`.`KEY_PERSON_DEPARTMENT` AS `PERSON_HOME_UNIT`,
               `s1`.`F_AND_A_RATE_TYPE` AS `F_AND_A_RATE_TYPE` 
            from
               `award_master_dataset_rt` `s1` 
            where
               (
                  `s1`.`PERSON_ROLE_ID` = 3
               )
         )
         `t10` 
         on((`t3`.`AWARD_NUMBER` = `t10`.`AWARD_NUMBER`))
   )
;

