CREATE VIEW `eps_proposal_report_v` AS
    SELECT 
        `t1`.`PROPOSAL_ID` AS `PROPOSAL_ID`,
        `t1`.`TITLE` AS `TITLE`,
        CAST(`t1`.`END_DATE` AS DATE) AS `END_DATE`,
        CAST(`t1`.`START_DATE` AS DATE) AS `START_DATE`,
        `t1`.`DURATION` AS `DURATION`,
        `t9`.`DESCRIPTION` AS `PROPOSAL_STATUS`,
        `t10`.`DESCRIPTION` AS `ANTICIPATED_AWARD_TYPE`,
        CAST(`t1`.`SPONSOR_DEADLINE_DATE` AS DATE) AS `SPONSOR_DEADLINE_DATE`,
        CAST(`t1`.`SUBMISSION_DATE` AS DATE) AS `SUBMISSION_DATE`,
        `t3`.`DESCRIPTION` AS `PROPOSAL_TYPE`,
        `t4`.`DESCRIPTION` AS `GRANT_CALL_TYPE`,
        `t5`.`NAME` AS `GRANT_CALL_TITLE`,
        `t7`.`DESCRIPTION` AS `BUDGET_STATUS`,
        `t6`.`TOTAL_DIRECT_COST` AS `TOTAL_DIRECT_COST`,
        `t6`.`TOTAL_INDIRECT_COST` AS `TOTAL_INDIRECT_COST`,
        `t6`.`TOTAL_SUBCONTRACT_COST` AS `TOTAL_SUBCONTRACT_COST`,
        `t6`.`UNDERRECOVERY_AMOUNT` AS `UNDERRECOVERY_AMOUNT`,
        `t14`.`DISPLAY_NAME` AS `SPONSOR_NAME`,
        `t1`.`HOME_UNIT_NAME` AS `LEAD_UNIT_NAME`,
        `t2`.`DESCRIPTION` AS `ACTIVITY_TYPE`,
        `t12`.`DESCRIPTION` AS `SPECIAL_REVIEW`,
        `t32`.`DESCRIPTION` AS `FUNDING_SCHEME`,
        `t15`.`DESCRIPTION` AS `TYPE_OF_FUNDING_AGENCY`,
        `t16`.`DESCRIPTION` AS `DISCIPLINE_CLUSTER`,
        `t18`.`ORGANIZATION_NAME` AS `ORGANIZATION`,
        IFNULL(`t19`.`PERSON_ID`, `t19`.`ROLODEX_ID`) AS `PI_PERSON_ID`,
        `t19`.`FULL_NAME` AS `PI_NAME`,
        IFNULL(`t8`.`PERSON_ID`, `t8`.`ROLODEX_ID`) AS `PERSON_ID`,
        `t8`.`FULL_NAME` AS `PROPOSAL_KEY_PERSON_NAME`,
        (CASE
            WHEN (`t8`.`PERSON_ID` IS NOT NULL) THEN 'Y'
            ELSE 'N'
        END) AS `EMPLOYEE_FLAG`,
        `t8`.`PERCENTAGE_OF_EFFORT` AS `PERCENTAGE_OF_EFFORT`,
        `t20`.`DESCRIPTION` AS `PERSON_ROLE`,
        `t20`.`PROP_PERSON_ROLE_ID` AS `PERSON_ROLE_ID`,
        `t1`.`HOME_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
        `t23`.`TITLE` AS `AWARD_TITLE`,
        `t23`.`KEY_PERSON_NAME` AS `AWARD_KEY_PERSON_NAME`,
        `t23`.`KEY_PERSON_ID` AS `AWARD_KEY_PERSON_ID`,
        `t23`.`AWARD_TYPE` AS `AWARD_TYPE`,
        `t23`.`ACCOUNT_TYPE` AS `AWARD_ACCOUNT_TYPE`,
        `t23`.`AWARD_STATUS` AS `AWARD_STATUS`,
        `t23`.`SPONSOR_NAME` AS `AWARD_SPONSOR_NAME`,
        `t23`.`SPONSOR_TYPE` AS `AWARD_SPONSOR_TYPE`,
        `t23`.`SPONSOR_AWARD_NUMBER` AS `AWARD_SPONSOR_AWARD_NUMBER`,
        `t23`.`LEAD_UNIT_NUMBER` AS `AWARD_LEAD_UNIT_NUMBER`,
        `t23`.`unit_name` AS `AWARD_LEAD_UNIT_NAME`,
        `t23`.`AWARD_EFFECTIVE_DATE` AS `AWARD_EFFECTIVE_DATE`,
        `t23`.`FINAL_EXPIRATION_DATE` AS `AWARD_FINAL_EXPIRATION_DATE`,
        `t23`.`DURATION` AS `AWARD_DURATION`,
        `t23`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
        `t23`.`ACCOUNT_NUMBER` AS `AWARD_ACCOUNT_NUMBER`,
        `t23`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
        `t23`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
        `t23`.`AWARD_ID` AS `AWARD_ID`,
        `t24`.`DESCRIPTION` AS `SPECIAL_REVIEW_APPROVAL_STATUS`,
        `t11`.`SPR_PROTOCOL_NUMBER` AS `SPR_PROTOCOL_NUMBER`,
        CAST(`t11`.`SPR_APPLICATION_DATE` AS DATE) AS `SPR_APPLICATION_DATE`,
        CAST(`t11`.`SPR_APPROVAL_DATE` AS DATE) AS `SPR_APPROVAL_DATE`,
        CAST(`t11`.`SPR_EXPIRATION_DATE` AS DATE) AS `SPR_EXPIRATION_DATE`,
        `t33`.`DISPLAY_NAME` AS `PRIME_SPONSOR_NAME`,
        CAST(`t1`.`INTERNAL_DEADLINE_DATE` AS DATE) AS `INTERNAL_DEADLINE_DATE`,
        `t1`.`SPONSOR_PROPOSAL_NUMBER` AS `SPONSOR_PROPOSAL_NUMBER`,
        `t1`.`EXTERNAL_FUNDING_AGENCY_ID` AS `EXTERNAL_FUNDING_AGENCY_ID`,
        `t1`.`CFDA_NUMBER` AS `CFDA_NUMBER`,
        `t1`.`PROGRAM_ANNOUNCEMENT_NUMBER` AS `PROGRAM_ANNOUNCEMENT_NUMBER`,
        `t6`.`VERSION_NUMBER` AS `BUDGET_VERSION_NUMBER`,
        `t6`.`IS_FINAL_BUDGET` AS `FINAL_VERSION_FLAG`,
        `t5`.`ABBREVIATION` AS `GRANT_CALL_ABBREVIATION`,
        `t5`.`HOME_UNIT_NAME` AS `GRANT_CALL_HOME_UNIT_NAME`,
        CAST(`t5`.`OPENING_DATE` AS DATE) AS `GRANT_CALL_OPENING_DATE`,
        CAST(`t5`.`CLOSING_DATE` AS DATE) AS `GRANT_CALL_closing_date`,
        `t27`.`DESCRIPTION` AS `BUDGET_CATEGORY`,
        `t28`.`DESCRIPTION` AS `COST_ELEMENT`,
        `t26`.`LINE_ITEM_COST` AS `LINE_ITEM_COST`,
        IFNULL(`t29`.`EMAIL_ADDRESS`,
                `t31`.`EMAIL_ADDRESS`) AS `PERSON_EMAIL`,
        IFNULL(`t29`.`GENDER`, NULL) AS `KEY_PERSON_GENDER`,
         `t8`.`DESIGNATION` AS `KEY_PERSON_TITLE`,
        IFNULL(`t30`.`unit_name`,
                `t18`.`ORGANIZATION_NAME`) AS `PERSON_DEPARTMENT`,
        `t8`.`PERCENTAGE_OF_EFFORT` AS `PROPOSAL_PERCENTAGE_OF_EFFORT`,
        `t23`.`PERCENTAGE_OF_EFFORT` AS `AWARD_PERCENTAGE_OF_EFFORT`,
        `t23`.`PRIME_SPONSOR_NAME` AS `AWARD_PRIME_SPONSOR_NAME`,
        `t23`.`PI_NAME` AS `AWARD_PI_NAME`,
        `t23`.`PERSON_ROLE` AS `AWARD_KEY_PERSON_ROLE`,
        IFNULL(`t23`.`KEY_PERSON_DEPARTMENT`,
                `t23`.`KEY_PERSON_ORGANIZATION`) AS `AWARD_KEY_PERSON_DEPT`,
        `t23`.`KEY_PERSON_EMAIL` AS `AWARD_KEY_PERSON_EMAIL`,
        `t23`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`,
        `t1`.`IP_NUMBER` AS `PROPOSAL_NUMBER`,
        `t1`.`CREATE_TIMESTAMP` AS `PROPOSAL_CREATE_DATE`,
        `t23`.`AWARD_CREATE_TIMESTAMP` AS `AWARD_CREATE_DATE`,
        `t23`.`AWARD_EFFECTIVE_DATE` AS `AWARD_NOTICE_DATE`,
        ROUND(((`t6`.`COST_SHARING_AMOUNT` + `t6`.`UNDERRECOVERY_AMOUNT`) + `t6`.`TOTAL_COST`),
            2) AS `TOTAL_COST`,
        ROUND((`t6`.`COST_SHARING_AMOUNT` + `t6`.`UNDERRECOVERY_AMOUNT`),
            2) AS `IN_KIND_CONTRIBUTION`,
        ROUND(`t6`.`TOTAL_COST`, 2) AS `TOTAL_REQUESTED_COST`,
        ROUND((`t6`.`TOTAL_COST` / (SELECT 
                    `currency_rate`.`CURRENCY_RATE`
                FROM
                    `currency_rate`
                WHERE
                    (`currency_rate`.`COUNTRY_CODE` = 'USA'))),
            2) AS `TOTAL_REQUESTED_COST_USD`,
           `t19`.`DESIGNATION` AS `FACULTY_TITLE`,
            `t19`.`FACULTY_EMAIL_ADDRESS` AS `FACULTY_EMAIL_ADDRESS`,
        CONCAT(`t14`.`SPONSOR_CODE`,
                '-',
                `t14`.`DISPLAY_NAME`) AS `SPONSOR`,
        `t14`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
        `ps`.`DESCRIPTION` AS `INS_PROPOSAL_STATUS`,
        `t23`.`BEGIN_DATE` AS `BEGIN_DATE`,
        `t14`.`DISPLAY_NAME` AS `FUNDING_SPONSOR_NAME`,
        `t34`.`FULL_NAME` AS `PERMISSION_ASSIGNEE_NAME`,
        `t34`.`DERIVED_ROLE_NAME` AS `PROPOSAL_PERMISSION`
    FROM
        ((((((((((((((((((((((((((((((((((`eps_proposal` `t1`
        JOIN `activity_type` `t2` ON ((`t1`.`ACTIVITY_TYPE_CODE` = `t2`.`ACTIVITY_TYPE_CODE`)))
        JOIN `eps_proposal_type` `t3` ON ((`t3`.`TYPE_CODE` = `t1`.`TYPE_CODE`)))
        LEFT JOIN `grant_call_type` `t4` ON ((`t1`.`GRANT_TYPE_CODE` = `t4`.`GRANT_TYPE_CODE`)))
        LEFT JOIN `grant_call_header` `t5` ON ((`t5`.`GRANT_HEADER_ID` = `t1`.`GRANT_HEADER_ID`)))
        LEFT JOIN `budget_header` `t6` ON (((`t6`.`PROPOSAL_ID` = `t1`.`PROPOSAL_ID`)
             AND (CASE WHEN IS_FINAL_BUDGET = 'Y' THEN IS_FINAL_BUDGET = 'Y'
	    WHEN ((SELECT COUNT(1) FROM BUDGET_HEADER WHERE PROPOSAL_ID = t6.PROPOSAL_ID AND IS_FINAL_BUDGET = 'Y') =0 AND IS_LATEST_VERSION = 'Y') THEN IS_LATEST_VERSION = 'Y'  END))))
        LEFT JOIN `budget_status` `t7` ON ((`t7`.`BUDGET_STATUS_CODE` = `t6`.`BUDGET_STATUS_CODE`)))
        JOIN `eps_proposal_persons` `t8` ON ((`t1`.`PROPOSAL_ID` = `t8`.`PROPOSAL_ID`)))
        JOIN `eps_proposal_status` `t9` ON ((`t1`.`STATUS_CODE` = `t9`.`STATUS_CODE`)))
        LEFT JOIN `award_type` `t10` ON ((`t1`.`AWARD_TYPE_CODE` = `t10`.`AWARD_TYPE_CODE`)))
        LEFT JOIN (SELECT 
            `s1`.`PROPOSAL_ID` AS `PROPOSAL_ID`,
                `s1`.`SPECIAL_REVIEW_CODE` AS `SPECIAL_REVIEW_CODE`,
                `s1`.`APPROVAL_TYPE_CODE` AS `SPR_APPROVAL_TYPE_CODE`,
                `s1`.`PROTOCOL_NUMBER` AS `SPR_PROTOCOL_NUMBER`,
                `s1`.`APPLICATION_DATE` AS `SPR_APPLICATION_DATE`,
                `s1`.`APPROVAL_DATE` AS `SPR_APPROVAL_DATE`,
                `s1`.`EXPIRATION_DATE` AS `SPR_EXPIRATION_DATE`
        FROM
            `eps_proposal_special_review` `s1`
        WHERE
            `s1`.`PROPOSAL_SPECIAL_REVIEW_ID` IN (SELECT 
                    MAX(`s2`.`PROPOSAL_SPECIAL_REVIEW_ID`)
                FROM
                    `eps_proposal_special_review` `s2`
                WHERE
                    (`s1`.`PROPOSAL_ID` = `s2`.`PROPOSAL_ID`)
                GROUP BY `s2`.`PROPOSAL_ID` , `s2`.`SPECIAL_REVIEW_CODE`)) `t11` ON ((`t11`.`PROPOSAL_ID` = `t1`.`PROPOSAL_ID`)))
        LEFT JOIN `special_review` `t12` ON ((`t11`.`SPECIAL_REVIEW_CODE` = `t12`.`SPECIAL_REVIEW_CODE`)))
        LEFT JOIN `sponsor_funding_scheme` `t13` ON ((`t13`.`FUNDING_SCHEME_ID` = `t5`.`FUNDING_SCHEME_ID`)))
        LEFT JOIN `funding_scheme` `t32` ON ((`t32`.`FUNDING_SCHEME_CODE` = `t13`.`FUNDING_SCHEME_CODE`)))
        LEFT JOIN `sponsor` `t14` ON ((`t14`.`SPONSOR_CODE` = `t1`.`SPONSOR_CODE`)))
        LEFT JOIN `sponsor_type` `t15` ON ((`t15`.`SPONSOR_TYPE_CODE` = `t14`.`SPONSOR_TYPE_CODE`)))
        LEFT JOIN `eps_prop_discipline_cluster` `t16` ON ((`t1`.`CLUSTER_CODE` = `t16`.`CLUSTER_CODE`)))
        LEFT JOIN `rolodex` `t17` ON ((`t17`.`ROLODEX_ID` = `t8`.`ROLODEX_ID`)))
        LEFT JOIN `organization` `t18` ON ((`t18`.`ORGANIZATION_ID` = `t17`.`ORGANIZATION`)))
        LEFT JOIN (SELECT 
            `p1`.`PROPOSAL_ID` AS `PROPOSAL_ID`,
                `p1`.`PERSON_ID` AS `PERSON_ID`,
                `p1`.`ROLODEX_ID` AS `ROLODEX_ID`,
                `p1`.`FULL_NAME` AS `FULL_NAME`,
                `p1`.`PERCENTAGE_OF_EFFORT` AS `PERCENTAGE_OF_EFFORT`,
                `p1`.`DESIGNATION` AS `DESIGNATION`,
                IFNULL(`p2`.`EMAIL_ADDRESS`, `p3`.`EMAIL_ADDRESS`) AS `FACULTY_EMAIL_ADDRESS`
        FROM
            ((`eps_proposal_persons` `p1`
        LEFT JOIN `person` `p2` ON ((`p1`.`PERSON_ID` = `p2`.`PERSON_ID`)))
        LEFT JOIN `rolodex` `p3` ON ((`p1`.`ROLODEX_ID` = `p3`.`ROLODEX_ID`)))
        WHERE
            (`p1`.`PI_FLAG` = 'Y')
        GROUP BY `p1`.`PROPOSAL_ID`) `t19` ON ((`t19`.`PROPOSAL_ID` = `t1`.`PROPOSAL_ID`)))
        LEFT JOIN `eps_prop_person_role` `t20` ON ((`t20`.`PROP_PERSON_ROLE_ID` = `t8`.`PROP_PERSON_ROLE_ID`)))
        LEFT JOIN `proposal` `tp` ON (((`tp`.`PROPOSAL_NUMBER` = `t1`.`IP_NUMBER`) AND (`tp`.`PROPOSAL_SEQUENCE_STATUS` = 'ACTIVE'))))
        LEFT JOIN `proposal_status` `ps` ON ((`ps`.`STATUS_CODE` = `tp`.`STATUS_CODE`)))
        LEFT JOIN `award_funding_proposals` `t22` ON ((`t22`.`PROPOSAL_ID` = `tp`.`PROPOSAL_ID`)))
        LEFT JOIN `award_master_dataset_rt` `t23` ON ((`t23`.`AWARD_ID` = `t22`.`AWARD_ID`)))
        LEFT JOIN `sp_rev_approval_type` `t24` ON ((`t11`.`SPR_APPROVAL_TYPE_CODE` = `t24`.`APPROVAL_TYPE_CODE`)))
        LEFT JOIN `budget_period` `t25` ON ((`t6`.`BUDGET_HEADER_ID` = `t25`.`BUDGET_HEADER_ID`)))
        LEFT JOIN `budget_detail` `t26` ON ((`t25`.`BUDGET_PERIOD_ID` = `t26`.`BUDGET_PERIOD_ID`)))
        LEFT JOIN `budget_category` `t27` ON ((`t26`.`BUDGET_CATEGORY_CODE` = `t27`.`BUDGET_CATEGORY_CODE`)))
        LEFT JOIN `cost_element` `t28` ON ((`t26`.`COST_ELEMENT` = `t28`.`COST_ELEMENT`)))
        LEFT JOIN `person` `t29` ON ((`t8`.`PERSON_ID` = `t29`.`PERSON_ID`)))
        LEFT JOIN `rolodex` `t31` ON ((`t8`.`ROLODEX_ID` = `t31`.`ROLODEX_ID`)))
        LEFT JOIN `unit` `t30` ON ((`t29`.`HOME_UNIT` = `t30`.`UNIT_NUMBER`)))
        LEFT JOIN `sponsor` `t33` ON ((`t33`.`SPONSOR_CODE` = `t1`.`PRIME_SPONSOR_CODE`)))
        LEFT JOIN (
            SELECT PROPOSAL_ID, P.FULL_NAME,MDR.DERIVED_ROLE_NAME FROM EPS_PROPOSAL_PERSON_ROLES PPR
            INNER JOIN MODULE_DERIVED_ROLES MDR ON MDR.ROLE_ID = PPR.ROLE_ID
            LEFT JOIN PERSON P ON P.PERSON_ID = PPR.PERSON_ID
            WHERE MDR.MODULE_CODE = 3) `t34` ON ((`t34`.`PROPOSAL_ID` = `t1`.`PROPOSAL_ID`)))
    WHERE
        ((`t1`.`DOCUMENT_STATUS_CODE` <> 3)
            OR (`t1`.`DOCUMENT_STATUS_CODE` IS NULL))

