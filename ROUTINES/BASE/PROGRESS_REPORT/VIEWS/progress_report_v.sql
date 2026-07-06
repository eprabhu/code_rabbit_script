-- progress_report_v;

CREATE VIEW `progress_report_v` AS 
select distinct
   `t22`.`DESCRIPTION` AS `REPORT_TYPE`,
   `t0`.`PROGRESS_REPORT_ID` AS `PROGRESS_REPORT_ID`,
   `t0`.`PROGRESS_REPORT_NUMBER` AS `PROGRESS_REPORT_NUMBER`,
   `t`.`DESCRIPTION` AS `REPORT_STATUS`,
   `t0`.`REPORT_START_DATE` AS `REPORTING_START_DATE`,
   `t0`.`REPORT_END_DATE` AS `REPORTING_END_DATE`,
   `t0`.`DUE_DATE` AS `DUE_DATE`,
   `t4`.`KPI_SUMMARY_ID` AS `kpi_summary_id`,
   `p`.`FULL_NAME` AS `REPORT_CREATED_BY`,
   date_format(`t0`.`CREATE_TIMESTAMP`, '%d/%m/%Y') AS `REPORT_CREATED_TIMESTAMP`,
   `t34`.`UPDATE_USER` AS `REPORT_LAST_UPDATED_BY`,
   `t0`.`FUNDER_APPROVAL_DATE` AS `FUNDER_APPROVAL_DATE`,
   (
      select
         `award_progress_report_achievement`.`DESCRIPTION` AS `PROJECT_ACHIEVEMENT` 
      from
         `award_progress_report_achievement` 
      where
         (
(`award_progress_report_achievement`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`) 
            and 
            (
               `award_progress_report_achievement`.`ACHIEVEMENT_TYPE_CODE` = 1
            )
         )
   )
   AS `PROJECT_ACHIEVEMENT`,
   (
      select
         `award_progress_report_achievement`.`DESCRIPTION` AS `PROJECT_ACHIEVEMENT` 
      from
         `award_progress_report_achievement` 
      where
         (
(`award_progress_report_achievement`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`) 
            and 
            (
               `award_progress_report_achievement`.`ACHIEVEMENT_TYPE_CODE` = 2
            )
         )
   )
   AS `KEY_INFORMATION`,
   (
      select
         `award_progress_report_achievement`.`DESCRIPTION` AS `Project_Achievement` 
      from
         `award_progress_report_achievement` 
      where
         (
(`award_progress_report_achievement`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`) 
            and 
            (
               `award_progress_report_achievement`.`ACHIEVEMENT_TYPE_CODE` = 3
            )
         )
   )
   AS `CAPABILITIES_DEVELOPED`,
   (
      select
         `award_progress_report_achievement`.`DESCRIPTION` AS `PROJECT_ACHIEVEMENT` 
      from
         `award_progress_report_achievement` 
      where
         (
(`award_progress_report_achievement`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`) 
            and 
            (
               `award_progress_report_achievement`.`ACHIEVEMENT_TYPE_CODE` = 4
            )
         )
   )
   AS `MEDIA_EXPOSURE`,
   (
      select
         `award_progress_report_achievement`.`DESCRIPTION` AS `PROJECT_ACHIEVEMENT` 
      from
         `award_progress_report_achievement` 
      where
         (
(`award_progress_report_achievement`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`) 
            and 
            (
               `award_progress_report_achievement`.`ACHIEVEMENT_TYPE_CODE` = 5
            )
         )
   )
   AS `FUTURE_ACHIEVEMENT`,
   (
      select
         `award_progress_report_achievement`.`DESCRIPTION` AS `PROJECT_ACHIEVEMENT` 
      from
         `award_progress_report_achievement` 
      where
         (
(`award_progress_report_achievement`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`) 
            and 
            (
               `award_progress_report_achievement`.`ACHIEVEMENT_TYPE_CODE` = 6
            )
         )
   )
   AS `FUTURE_PLANS_IN_SINGAPORE`,
   (
      select
         `award_progress_report_achievement`.`DESCRIPTION` AS `PROJECT_ACHIEVEMENT` 
      from
         `award_progress_report_achievement` 
      where
         (
(`award_progress_report_achievement`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`) 
            and 
            (
               `award_progress_report_achievement`.`ACHIEVEMENT_TYPE_CODE` = 7
            )
         )
   )
   AS `FUTURE_CAPABILITIES_DEVELOPED`,
   (
      select
         `award_progress_report_achievement`.`DESCRIPTION` AS `PROJECT_ACHIEVEMENT` 
      from
         `award_progress_report_achievement` 
      where
         (
(`award_progress_report_achievement`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`) 
            and 
            (
               `award_progress_report_achievement`.`ACHIEVEMENT_TYPE_CODE` = 8
            )
         )
   )
   AS `FUTURE_FURTHER_DEVELOPMENT`,
   (
      select
         `award_progress_report_achievement`.`DESCRIPTION` AS `PROJECT_ACHIEVEMENT` 
      from
         `award_progress_report_achievement` 
      where
         (
(`award_progress_report_achievement`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`) 
            and 
            (
               `award_progress_report_achievement`.`ACHIEVEMENT_TYPE_CODE` = 9
            )
         )
   )
   AS `ACHIEVEMENT_PROJECT_OBJECTIVE`,
   `t20`.`DESCRIPTION` AS `KPI_CATEGORY`,
   `t21`.`DESCRIPTION` AS `KPI_CRITERIA`,
   `t4`.`TARGET` AS `TARGET`,
   `t23`.`DESCRIPTION` AS `PUBLICATIONS_STATUS`,
   `t5`.`AUTHOR_NAME` AS `PUBLICATIONS_AUTHOR_NAMES`,
   `t5`.`TITLE_OF_ARTICLE` AS `PUBLICATIONS_TITLE_OF_ARTICLE`,
   `t5`.`JOURNAL_NAME` AS `PUBLICATIONS_JOURNAL_NAME`,
   `t5`.`PUBLISHER` AS `PUBLICATIONS_PUBLISHER`,
   `t5`.`YEAR` AS `PUBLICATIONS_YEAR_ISSUENO`,
   `t5`.`PAGE_NO` AS `PUBLICATIONS_PAGE_NO`,
   `t5`.`IMPACT_FACTOR` AS `PUBLICATIONS_IMPACT_FACTOR`,
   `t5`.`FUNDING_ACKNOWLEDGEMENT` AS `PUBLICATIONS_ACKNOWLEDGEMENT_FUNDING`,
   `t5`.`COMMENTS` AS `PUBLICATIONS_COMMENTS`,
   `t5`.`PUBLICATION_DATE` AS `PUBLICATIONS_PUBLICATION_DATE`,
   `t6`.`PROJECT_TITLE` AS `COLLABORATION_PROJECT_TITLE`,
   `t6`.`PROJECT_DESCRIPTION` AS `COLLABORATION_PROJECT_DESCRIPTION`,
   `t6`.`PROJECT_START_DATE` AS `COLLABORATION_PROJECT_START_DATE`,
   `t6`.`PROJECT_END_DATE` AS `COLLABORATION_PROJECT_END_DATE`,
   `t6`.`COLLABORATING_ORGANIZATION` AS `COLLABORATION_NAME_OF_COLLABORATING_ORGANIZATION`,
   `t24`.`COUNTRY_NAME` AS `COLLABORATION_COUNTRY`,
   `t6`.`COMPANY_UEN` AS `COLLABORATION_COMPANY_UEN`,
   `t6`.`COMMENTS` AS `COLLABORATION_COMMENTS`,
   `t25`.`DESCRIPTION` AS `TECHNOLOGY_DISCLOSURES_STATUS`,
   `t7`.`AUTHOR_NAME` AS `TECHNOLOGY_DISCLOSURES_AUTHOR_NAMES`,
   `t7`.`TITLE_OF_PATENT` AS `TECHNOLOGY_DISCLOSURES_TITLE_PATENT`,
   `t7`.`COVERING_COUNTRIES` AS `TECHNOLOGY_DISCLOSURES_COVERING_COUNTRIES`,
   `t7`.`FILING_OFFICE` AS `TECHNOLOGY_DISCLOSURES_FILING_OFFICE`,
   `t7`.`DATE_OF_FILING` AS `TECHNOLOGY_DISCLOSURES_DATE_FILING`,
   `t7`.`DATE_OF_AWARD` AS `TECHNOLOGY_DISCLOSURES_DATE_AWARD`,
   `t7`.`COMMENTS` AS `TECHNOLOGY_DISCLOSURES_COMMENTS`,
   `t8`.`NAME_OF_STUDENT` AS `MANPOWER_NAME_STUDENT`,
   `t8`.`CITIZENSHIP` AS `MANPOWER_CITIZENSHIP`,
   `t26`.`DESCRIPTION` AS `MANPOWER_CURRENT_STATUS`,
   `t8`.`DATE_ENROLLED` AS `MANPOWER_DATE_ENROLLED`,
   `t8`.`DATE_GRADUATED` AS `MANPOWER_DATE_GRADUATED_RESIGNED`,
   `t8`.`DATE_OF_JOINING` AS `MANPOWER_DATE_JOINING_PROJECT`,
   `t8`.`DATE_OF_LEAVING` AS `MANPOWER_DATE_LEAVING_PROJECT`,
   `t8`.`COMMENTS` AS `MANPOWER_COMMENTS`,
   `t9`.`NAME_OF_STUDENT` AS `UG_STUDENTS_NAME_STUDENT`,
   `t9`.`CITIZENSHIP` AS `UG_STUDENTS_CITIZENSHIP`,
   `t27`.`DESCRIPTION` AS `UG_STUDENTS_CURRENT_STATUS`,
   `t9`.`DATE_OF_JOINING` AS `UG_STUDENTS_DATE_JOINING_PROJECT`,
   `t9`.`DATE_OF_LEAVING` AS `UG_STUDENTS_DATE_LEAVING_PROJECT`,
   `t9`.`COMMENTS` AS `UG_STUDENTS_COMMENTS`,
   `t10`.`NAME_OF_PRESENTER` AS `CONFERENCE_NAME_PRESENTER_RESEARCHER`,
   `t10`.`TITLE` AS `CONFERENCE_TITLE`,
   `t10`.`CONFERENCE_TITLE` AS `CONFERENCE_CONFERENCE_TITLE_AWARD_TITLE`,
   `t10`.`ORGANISER` AS `CONFERENCE_ORGANISER`,
   `t10`.`CONFERENCE_LOCATION` AS `CONFERENCE_CONFERENCE_LOCATION_COUNTRY_STATE`,
   `t10`.`DATE` AS `CONFERENCE_DATE`,
   `t10`.`COMMENTS` AS `CONFERENCE_COMMENTS`,
   `t11`.`NAME_OF_GRANT_RECEIVED` AS `COMPETITIVE_GRANTS_NAME_GRANT_RECEIVED`,
   `t11`.`PROJECT_REFERENCE_NO` AS `COMPETITIVE_GRANTS_PROJECT_REFERENCE_NO`,
   `t28`.`SPONSOR_NAME` AS `COMPETITIVE_GRANTS_FUNDING_AGENCY`,
   `t11`.`RECIPIENT_OF_GRANT` AS `COMPETITIVE_GRANTS_RECIPIENT_GRANT`,
   `t11`.`HOST_INSTITUTION` AS `COMPETITIVE_GRANTS_HOST_INSTITUTION`,
   `t11`.`DIRECT_COST` AS `COMPETITIVE_GRANTS_DIRECT_COST`,
   `t11`.`INDIRECT_COST` AS `COMPETITIVE_GRANTS_INDIRECT_COST`,
   `t11`.`PROJECT_START_DATE` AS `COMPETITIVE_GRANTS_PROJECT_START_DATE`,
   `t11`.`PROJECT_END_DATE` AS `COMPETITIVE_GRANTS_PROJECT_END_DATE`,
   `t11`.`PROJECT_TITLE` AS `COMPETITIVE_GRANTS_PROJECT_TITLE`,
   `t11`.`COMMENTS` AS `COMPETITIVE_GRANTS_COMMENTS`,
   `t12`.`NAME_OF_COMPANY` AS `CASH_FUNDING_NAME_COMPANY_CONTRIBUTING`,
   `t29`.`COUNTRY_NAME` AS `CASH_FUNDING_COUNTRY_COMPANY`,
   `t12`.`COMPANY_UEN` AS `CASH_FUNDING_COMPANY_UEN`,
   `t12`.`DATE_OF_CONTRIBUTION` AS `CASH_FUNDING_DATE_CONTRIBUTION`,
   `t12`.`AMOUNT` AS `CASH_FUNDING_AMOUNT_CASH_FUNDING`,
   `t12`.`COMMENTS` AS `CASH_FUNDING_COMMENTS`,
   `t13`.`DATE_OF_CONTRIBUTION` AS `IN_KIND_DATE_CONTRIBUTION`,
   `t13`.`NAME_OF_COMPANY` AS `IN_KIND_NAME_COMPANY_CONTRIBUTING`,
   `t37`.`COUNTRY_NAME` AS `IN_KIND_COUNTRY_COMPANY`,
   `t13`.`COMPANY_UEN` AS `IN_KIND_COMPANY_UEN`,
   `t13`.`AMOUNT` AS `IN_KIND_AMOUNT_KIND_CONTRIBUTIONS`,
   `t13`.`COMMENTS` AS `IN_KIND_COMMENTS`,
   `t14`.`DATE_OF_DEPLOYING` AS `TECHNOLOGIES_DEPLOYED_DATE_DEPLOYING`,
   `t14`.`NAME_OF_COMPANY` AS `TECHNOLOGIES_DEPLOYED_NAME_COMPANY_DEPLOYING`,
   `t38`.`COUNTRY_NAME` AS `TECHNOLOGIES_DEPLOYED_COUNTRY_COMPANY`,
   `t14`.`COMPANY_UEN` AS `TECHNOLOGIES_DEPLOYED_COMPANY_UEN`,
   `t14`.`DETAILS_OF_TECHNOLOGIES` AS `TECHNOLOGIES_DEPLOYED_DETAILS`,
   `t14`.`COMMENTS` AS `TECHNOLOGIES_DEPLOYED_COMMENTS`,
   `t15`.`DATE_FILED` AS `PATENTS_DATE_FILED`,
   `t15`.`DATE_GRANTED` AS `PATENTS_DATE_GRANTED`,
   `t15`.`TITLE` AS `PATENTS_TITLE`,
   `t15`.`DESCRIPTION` AS `PATENTS_DESCRIPTION`,
   `t15`.`OWNERSHIP` AS `PATENTS_OWNERSHIP`,
   `t15`.`PATENT_NUMBER` AS `PATENTS_PATENT_NUMBER`,
   `t15`.`COMMENTS` AS `PATENTS_COMMENTS`,
   `t16`.`START_DATE` AS `LICENSES_START_DATE_LICENSING`,
   `t16`.`NAME_OF_LICENSE` AS `LICENSES_NAME_LICENSEE_ASSIGNEE`,
   `t16`.`COMPANY_UEN` AS `LICENSES_COMPANY_UEN`,
   `t16`.`LICENSING_PERIOD` AS `LICENSES_LICENSING_PERIOD`,
   `t16`.`DETAILS_OF_LICENSE` AS `LICENSES_DETAILS_IP_LICENSED`,
   `t16`.`COMMENTS` AS `LICENSES_COMMENTS`,
   `t17`.`DATE_OF_ESTABLISHMENT` AS `START_UPS_DATE_ESTABLISHMENT`,
   `t17`.`DATE_ESTABLISHED` AS `START_UPS_DATE_ESTABLISHED`,
   `t17`.`NAME_OF_COMPANY` AS `START_UPS_NAME_COMPANY`,
   `t17`.`COMPANY_UEN` AS `START_UPS_COMPANY_UEN`,
   `t17`.`EXTERNAL_FUNDING_CRITERIA` AS `START_UPS_EXTERNAL_FUNDING_CRITERIA`,
   `t17`.`VALUATION_CRITERIA` AS `START_UPS_VALUATION_CRITERIA`,
   `t17`.`ANNUAL_REVENUE_CRITERIA` AS `START_UPS_ANNUAL_REVENUE_CRITERIA`,
   `t17`.`COMMENTS` AS `START_UPS_COMMENTS`,
   `t18`.`DATE_ESTABLISHED` AS `HEALTH_SPECIFIC_DATE`,
   `t18`.`NUMBER_OF_LIFE_YEARS` AS `HEALTH_SPECIFIC_NUMBER_YEARS_SAVED`,
   `t18`.`TITLE` AS `HEALTH_SPECIFIC_DESCRIPTION_TITLE`,
   `t18`.`COMMENTS` AS `HEALTH_SPECIFIC_REMARKS`,
   `t19`.`EMPLOYMENT_START_DATE` AS `POST_DOCS_EMPLOYMENT_START_DATE`,
   `t19`.`EMPLOYEE_NAME` AS `POST_DOCS_NAME`,
   `t19`.`NATIONALITY` AS `POST_DOCS_NATIONALITY`,
   `t19`.`PERMANENT_RESIDENCE` AS `POST_DOCS_PERMANENT_RESIDENCE`,
   `t19`.`IDENTIFICATION_NUMBER` AS `POST_DOCS_NRIC_FIN`,
   `t19`.`COMMENTS` AS `POST_DOCS_COMMENTS`,
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`AWARD_ID` AS `AWARD_ID`,
   `t1`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
   `t1`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`,
   `t1`.`AWARD_STATUS` AS `AWARD_STATUS`,
   `t1`.`AWARD_TYPE` AS `AWARD_TYPE`,
   `t1`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`,
   `t1`.`ACTIVITY_TYPE` AS `ACTIVITY_TYPE`,
   `t1`.`GRANT_CALL_TITLE` AS `TITLE_GRANT_CALL`,
   `t1`.`FUNDING_SCHEME` AS `GRANT_SCHEME`,
   `t1`.`TITLE` AS `TITLE_AWARD`,
   `t1`.`AWARD_EFFECTIVE_DATE` AS `AWARD_NOTICEDATE`,
   `t1`.`BEGIN_DATE` AS `AWARD_EFFECTIVEDATE`,
   `t1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATIONDATE`,
   `t1`.`AWARD_CREATE_TIMESTAMP` AS `AWARD_CREATEDATE`,
   `t1`.`DURATION` AS `DURATION_PROJECT`,
   `t1`.`SPONSOR_NAME` AS `SPONSOR`,
   `t1`.`PRIME_SPONSOR_NAME` AS `PRIME_SPONSOR`,
   `t1`.`unit_name` AS `LEAD_UNIT`,
   `t1`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`,
   `t1`.`PI_NAME` AS `LEAD_PRINCIPAL_INVESTIGATOR`,
   `t1`.`KEY_PERSON_EMAIL` AS `KEY_PERSON_EMAIL`,
   `t1`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL`,
   `t1`.`AMOUNT_OBLIGATED_TO_DATE` AS `OBLIGATED_TOTAL`,
   `t1`.`TOTAL_PROJECT_COST` AS `TOTAL_PROJECT_COST`,
   `t1`.`ORIGINAL_APPROVED_BUDGET` AS `ORIGINAL_AMOUNT`,
   `t1`.`LATEST_APPROVED_BUDGET` AS `REVISED_AMOUNT`,
   `t32`.`REMARK` AS `REMARK`,
   `t32`.`ACTUAL_START_MONTH` AS `ACTUAL_START_MONTH`,
   `t32`.`ACTUAL_END_MONTH` AS `ACTUAL_END_MONTH`,
   date_format(`t34`.`WORKFLOW_START_DATE`, '%d/%m/%Y') AS `WORKFLOW_START_DATE`,
   date_format(`t34`.`WORKFLOW_END_DATE`, '%d/%m/%Y') AS `WORKFLOW_END_DATE`,
   `t32`.`START_DATE` AS `START_DATE`,
   `t32`.`end_date` AS `END_DATE`,
   `t32`.`MILESTONE` AS `MILESTONE`,
   `t32`.`DESCRIPTION` AS `MILESTONE_STATUS`,
   `t1`.`AWARD_WORKFLOW_STATUS` AS `AWARD_WORKFLOW_STATUS`,
   date_format(convert_tz(`t34`.`UPDATE_TIMESTAMP`, '+00:00', '+8:00'), '%d/%m/%Y %H:%i:%s') AS `REPORT_LAST_UPDATED_TIMESTAMP`,
   `t1`.`STEM_NONSTEM` AS `STEM_NONSTEM`,
   `t1`.`RIE_DOMAIN` AS `RIE_DOMAIN`,
   `t1`.`DISPLAY_AT_ACAD_PROFILE` AS `DISPLAY_AT_ACAD_PROFILE`,
   `t1`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`,
   `t34`.`APPROVAL_COMMENT` AS `APPROVAL_COMMENT`,
   `t34`.`DESCRIPTION` AS `OVERALL_COMMENT`,
   `t1`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
   `t34`.`ROLE_TYPE` AS `APPROVER_ROLE_TYPE`,
   ifnull(`t38`.`ACHIEVED_SUM`, '0.00') AS `ACHIEVED_SUM` 
from
   (
(((((((((((((((((((((((((((((((((`award_progress_report` `t0` 
      left join
         (
            select
               `w`.`MODULE_ITEM_ID` AS `MODULE_ITEM_ID`,
               `w`.`WORKFLOW_START_DATE` AS `WORKFLOW_START_DATE`,
               `w`.`WORKFLOW_END_DATE` AS `WORKFLOW_END_DATE`,
               (
                  case
                     when
                        (
                           `wd`.`APPROVAL_STATUS` = 'B'
                        )
                     then
                        `wd`.`APPROVAL_COMMENT` 
                     else
                        NULL 
                  end
               )
               AS `APPROVAL_COMMENT`, `wd`.`UPDATE_TIMESTAMP` AS `UPDATE_TIMESTAMP`, 
               (
                  case
                     when
                        (
                           `wd`.`APPROVAL_STATUS` = 'B'
                        )
                     then
                        NULL 
                     else
                        `p`.`FULL_NAME` 
                  end
               )
               AS `UPDATE_USER`, `wft`.`DESCRIPTION` AS `DESCRIPTION`, 
               (
                  case
                     when
                        (
                           `wd`.`APPROVAL_STATUS` = 'B'
                        )
                     then
                        NULL 
                     else
                        ifnull(`pr`.`DESCRIPTION`, `wd`.`STOP_NAME`) 
                  end
               )
               AS `ROLE_TYPE` 
            from
               (
((((`workflow` `w` 
                  left join
                     `workflow_detail` `wd` 
                     on((`w`.`WORKFLOW_ID` = `wd`.`WORKFLOW_ID`))) 
                  left join
                     `workflow_detail_ext` `wde` 
                     on((`wd`.`WORKFLOW_DETAIL_ID` = `wde`.`WORKFLOW_DETAIL_ID`))) 
                  left join
                     `person` `p` 
                     on((`p`.`USER_NAME` = `wd`.`UPDATE_USER`))) 
                  left join
                     `workflow_feedback_type` `wft` 
                     on((`wft`.`FEEDBACK_TYPE_CODE` = `wde`.`FEEDBACK_TYPE_CODE`))) 
                  left join
                     `person_role_type` `pr` 
                     on((`wd`.`ROLE_TYPE_CODE` = `pr`.`ROLE_TYPE_CODE`))
               )
            where
               (
(`w`.`MODULE_CODE` = 16) 
                  and 
                  (
                     `wd`.`APPROVAL_STATUS` in 
                     (
                        'A', 'B'
                     )
                  )
                  and 
                  (
                     `w`.`IS_WORKFLOW_ACTIVE` = 'Y'
                  )
               )
         )
         `t34` 
         on((`t34`.`MODULE_ITEM_ID` = `t0`.`PROGRESS_REPORT_ID`))) 
      left join
         `report_class` `t22` 
         on((`t0`.`REPORT_CLASS_CODE` = `t22`.`REPORT_CLASS_CODE`))) 
      left join
         `progress_report_status` `t` 
         on((`t`.`PROGRESS_REPORT_STATUS_CODE` = `t0`.`PROGRESS_REPORT_STATUS_CODE`))) 
      left join
         `award_master_dataset_rt` `t1` 
         on(((`t1`.`AWARD_ID` = `t0`.`AWARD_ID`) 
         and 
         (
            `t1`.`PERSON_ROLE_ID` = 3
         )
))) 
      left join
         `award_progress_report_kpi_summary` `t4` 
         on(((`t0`.`PROGRESS_REPORT_ID` = `t4`.`PROGRESS_REPORT_ID`) 
         and 
         (
            `t0`.`PROGRESS_REPORT_ID` = `t4`.`ORGINATING_PROGRESS_REPORT_ID`
         )
))) 
      left join
         `kpi_type` `t20` 
         on((`t20`.`KPI_TYPE_CODE` = `t4`.`KPI_CATEGORY_TYPE_CODE`))) 
      left join
         `kpi_criteria_type` `t21` 
         on((`t21`.`KPI_CRITERIA_TYPE_CODE` = `t4`.`KPI_CRITERIA_TYPE_CODE`))) 
      left join
         `progress_report_kpi_impact_publications` `t5` 
         on((`t5`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `kpi_publication_status` `t23` 
         on((`t23`.`PUBLICATION_STATUS_CODE` = `t5`.`PUBLICATION_STATUS_CODE`))) 
      left join
         (
            select
               `progress_report_kpi_collaboration_projects`.`PROJECT_TITLE` AS `PROJECT_TITLE`,
               `progress_report_kpi_collaboration_projects`.`PROJECT_DESCRIPTION` AS `PROJECT_DESCRIPTION`,
               `progress_report_kpi_collaboration_projects`.`PROJECT_START_DATE` AS `PROJECT_START_DATE`,
               `progress_report_kpi_collaboration_projects`.`PROJECT_END_DATE` AS `PROJECT_END_DATE`,
               `progress_report_kpi_collaboration_projects`.`COMPANY_UEN` AS `COMPANY_UEN`,
               `progress_report_kpi_collaboration_projects`.`COMMENTS` AS `COMMENTS`,
               `progress_report_kpi_collaboration_projects`.`COLLABORATING_ORGANIZATION` AS `COLLABORATING_ORGANIZATION`,
               `progress_report_kpi_collaboration_projects`.`KPI_SUMMARY_ID` AS `KPI_SUMMARY_ID`,
               `progress_report_kpi_collaboration_projects`.`COUNTRY_CODE` AS `COUNTRY_CODE` 
            from
               `progress_report_kpi_collaboration_projects`
         )
         `t6` 
         on((`t6`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `progress_report_kpi_technology_disclosure` `t7` 
         on((`t7`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `kpi_technology_disclosure_status` `t25` 
         on((`t25`.`TECHNOLOGY_DISCLOSURE_STATUS_CODE` = `t7`.`TECHNOLOGY_DISCLOSURE_STATUS_CODE`))) 
      left join
         `progress_report_kpi_manpower_development` `t8` 
         on((`t8`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `kpi_manpower_development_current_status` `t26` 
         on((`t26`.`CURRENT_STATUS_CODE` = `t8`.`CURRENT_STATUS_CODE`))) 
      left join
         `progress_report_kpi_undergraduate_student` `t9` 
         on((`t9`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `kpi_manpower_development_current_status` `t27` 
         on((`t27`.`CURRENT_STATUS_CODE` = `t9`.`CURRENT_STATUS_CODE`))) 
      left join
         (
            select distinct
               `arp`.`NAME_OF_PRESENTER` AS `NAME_OF_PRESENTER`,
               `arp`.`TITLE` AS `TITLE`,
               `arp`.`CONFERENCE_TITLE` AS `CONFERENCE_TITLE`,
               `arp`.`ORGANISER` AS `ORGANISER`,
               `arp`.`CONFERENCE_LOCATION` AS `CONFERENCE_LOCATION`,
               `arp`.`DATE` AS `DATE`,
               `arp`.`COMMENTS` AS `COMMENTS`,
               `ap`.`PROGRESS_REPORT_ID` AS `PROGRESS_REPORT_ID`,
               `arp`.`KPI_CRITERIA_TYPE_CODE` AS `KPI_CRITERIA_TYPE_CODE`,
               `arp`.`KPI_CONFERENCE_PRESENTATION_ID` AS `KPI_CONFERENCE_PRESENTATION_ID`,
               `ap`.`KPI_SUMMARY_ID` AS `KPI_SUMMARY_ID` 
            from
               (
                  `award_progress_report_kpi_summary` `ap` 
                  join
                     `progress_report_kpi_conference_presentation` `arp` 
                     on((`ap`.`KPI_SUMMARY_ID` = `arp`.`KPI_SUMMARY_ID`))
               )
         )
         `t10` 
         on((`t10`.`PROGRESS_REPORT_ID` = `t4`.`PROGRESS_REPORT_ID`))) 
      left join
         `progress_report_kpi_competitive_grants` `t11` 
         on((`t11`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `sponsor` `t28` 
         on((`t28`.`SPONSOR_CODE` = `t11`.`SPONSOR_CODE`))) 
      left join
         `progress_report_kpi_cash_funding` `t12` 
         on((`t12`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `country` `t29` 
         on((`t29`.`COUNTRY_CODE` = `t12`.`COUNTRY_CODE`))) 
      left join
         `progress_report_kpi_inkind_contributions` `t13` 
         on((`t13`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `progress_report_kpi_technologies_deployed` `t14` 
         on((`t14`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `progress_report_kpi_patents` `t15` 
         on((`t15`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `progress_report_kpi_licenses` `t16` 
         on((`t16`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `progress_report_kpi_successful_startups` `t17` 
         on((`t17`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         `progress_report_kpi_health_specific_outcomes` `t18` 
         on((`t18`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`))) 
      left join
         `country` `t24` 
         on((`t24`.`COUNTRY_CODE` = `t6`.`COUNTRY_CODE`))) 
      left join
         `country` `t37` 
         on((`t37`.`COUNTRY_CODE` = `t13`.`COUNTRY_CODE`))) 
      left join
         `country` `t38` 
         on((`t38`.`COUNTRY_CODE` = `t14`.`COUNTRY_CODE`))) 
      left join
         (
            select
               `progress_report_kpi_post_docs_employed`.`EMPLOYMENT_START_DATE` AS `EMPLOYMENT_START_DATE`,
               `progress_report_kpi_post_docs_employed`.`KPI_SUMMARY_ID` AS `KPI_SUMMARY_ID`,
               `progress_report_kpi_post_docs_employed`.`EMPLOYEE_NAME` AS `EMPLOYEE_NAME`,
               `progress_report_kpi_post_docs_employed`.`NATIONALITY` AS `NATIONALITY`,
               `progress_report_kpi_post_docs_employed`.`PERMANENT_RESIDENCE` AS `PERMANENT_RESIDENCE`,
               `progress_report_kpi_post_docs_employed`.`IDENTIFICATION_NUMBER` AS `IDENTIFICATION_NUMBER`,
               `progress_report_kpi_post_docs_employed`.`COMMENTS` AS `COMMENTS` 
            from
               `progress_report_kpi_post_docs_employed`
         )
         `t19` 
         on((`t19`.`KPI_SUMMARY_ID` = `t4`.`KPI_SUMMARY_ID`))) 
      left join
         (
            select distinct
               `ms`.`DESCRIPTION` AS `DESCRIPTION`,
               `aam`.`ACTUAL_START_MONTH` AS `ACTUAL_START_MONTH`,
               `aam`.`ACTUAL_END_MONTH` AS `ACTUAL_END_MONTH`,
               `aam`.`REMARK` AS `REMARK`,
               `aam`.`PROGRESS_REPORT_ID` AS `progress_report_id`,
               `aam`.`START_DATE` AS `START_DATE`,
               `aam`.`END_DATE` AS `end_date`,
               `aam`.`MILESTONE` AS `MILESTONE` 
            from
               (
                  `award_progress_report_milestone` `aam` 
                  left join
                     `milestone_status` `ms` 
                     on((`ms`.`MILESTONE_STATUS_CODE` = `aam`.`MILESTONE_STATUS_CODE`))
               )
         )
         `t32` 
         on((`t32`.`progress_report_id` = `t0`.`PROGRESS_REPORT_ID`))) 
      left join
         `person` `p` 
         on((`p`.`USER_NAME` = `t0`.`CREATE_USER`))) 
      left join
         (
            select distinct
(
               select
                  sum(`award_progress_report_kpi_summary`.`ACHIEVED`) 
               from
                  `award_progress_report_kpi_summary` 
               where
                  (
(`award_progress_report_kpi_summary`.`PROGRESS_REPORT_ID` = `t1`.`PROGRESS_REPORT_ID`) 
                     and 
                     (
                        `award_progress_report_kpi_summary`.`KPI_CRITERIA_TYPE_CODE` = `t1`.`KPI_CRITERIA_TYPE_CODE`
                     )
                  )
) AS `ACHIEVED_SUM`,
                  `t1`.`PROGRESS_REPORT_ID` AS `PROGRESS_REPORT_ID`,
                  `t1`.`KPI_CRITERIA_TYPE_CODE` AS `KPI_CRITERIA_TYPE_CODE` 
               from
                  (
                     `award_progress_report_kpi_summary` `t1` 
                     join
                        `award_progress_report` `t2` 
                        on((`t2`.`PROGRESS_REPORT_ID` = `t1`.`ORGINATING_PROGRESS_REPORT_ID`))
                  )
         )
         `t38` 
         on(((`t38`.`PROGRESS_REPORT_ID` = `t0`.`PROGRESS_REPORT_ID`) 
         and 
         (
            `t38`.`KPI_CRITERIA_TYPE_CODE` = `t4`.`KPI_CRITERIA_TYPE_CODE`
         )
))
   )
;

