CREATE VIEW `eps_proposal_v` AS
    SELECT 
        `t1`.`PROPOSAL_ID` AS `PROPOSAL_ID`,
        `t1`.`TITLE` AS `TITLE`,
        CAST(`t1`.`END_DATE` AS DATE) AS `END_DATE`,
        CAST(`t1`.`START_DATE` AS DATE) AS `START_DATE`,
        `t1`.`DURATION` AS `DURATION`,
        `t9`.`DESCRIPTION` AS `PROPOSAL_STATUS`,
        `t10`.`DESCRIPTION` AS `AWARD_TYPE`,
        CAST(`t1`.`SPONSOR_DEADLINE_DATE` AS DATE) AS `SPONSOR_DEADLINE_DATE`,
        CAST(`t1`.`SUBMISSION_DATE` AS DATE) AS `SUBMISSION_DATE`,
        `t3`.`DESCRIPTION` AS `PROPOSAL_TYPE`,
        `t4`.`DESCRIPTION` AS `GRANT_CALL_TYPE`,
        `t5`.`NAME` AS `GRANT_CALL_TITLE`,
        `t7`.`DESCRIPTION` AS `BUDGET_STATUS`,
        ((`t6`.`COST_SHARING_AMOUNT` + `t6`.`UNDERRECOVERY_AMOUNT`) + `t6`.`TOTAL_COST`) AS `TOTAL_COST`,
        `t6`.`TOTAL_DIRECT_COST` AS `TOTAL_DIRECT_COST`,
        `t6`.`TOTAL_INDIRECT_COST` AS `TOTAL_INDIRECT_COST`,
        `t6`.`TOTAL_SUBCONTRACT_COST` AS `TOTAL_SUBCONTRACT_COST`,
        `t6`.`UNDERRECOVERY_AMOUNT` AS `UNDERRECOVERY_AMOUNT`,
        `t14`.`DISPLAY_NAME` AS `SPONSOR_NAME`,
        `t1`.`HOME_UNIT_NAME` AS `LEAD_UNIT_NAME`,
        `t2`.`DESCRIPTION` AS `ACTIVITY_TYPE`,
        `t12`.`DESCRIPTION` AS `SPECIAL_REVIEW`,
        `t21`.`DESCRIPTION` AS `FUNDING_SCHEME`,
        `t15`.`DESCRIPTION` AS `TYPE_OF_FUNDING_AGENCY`,
        `t16`.`DESCRIPTION` AS `DISCIPLINE_CLUSTER`,
        `t18`.`ORGANIZATION_NAME` AS `ORGANIZATION`,
        IFNULL(`t19`.`PERSON_ID`, `t19`.`ROLODEX_ID`) AS `PI_PERSON_ID`,
        `t19`.`FULL_NAME` AS `PI_NAME`,
        IFNULL(`t8`.`PERSON_ID`, `t8`.`ROLODEX_ID`) AS `PERSON_ID`,
        `t8`.`FULL_NAME` AS `PERSON_NAME`,
        (CASE
            WHEN (`t8`.`PERSON_ID` IS NOT NULL) THEN 'Y'
            ELSE 'N'
        END) AS `EMPLOYEE_FLAG`,
        `t8`.`PERCENTAGE_OF_EFFORT` AS `PERCENTAGE_OF_EFFORT`,
        `t20`.`DESCRIPTION` AS `PERSON_ROLE`,
        `t20`.`PROP_PERSON_ROLE_ID` AS `PERSON_ROLE_ID`,
        `t1`.`HOME_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
        `t22`.`DESCRIPTION` AS `EVALUATION_RECOMMENDATION`,
        `t1`.`PROPOSAL_RANK` AS `PROPOSAL_RANK`,
        `t23`.`DISPLAY_NAME` AS `PRIME_SPONSOR_NAME`,
        `t24`.`FULL_NAME` AS `PERMISSION_ASSIGNEE_NAME`,
        `t24`.`DERIVED_ROLE_NAME` AS `PROPOSAL_PERMISSION`
    FROM
        (((((((((((((((((((((((`eps_proposal` `t1`
        JOIN `activity_type` `t2` ON ((`t1`.`ACTIVITY_TYPE_CODE` = `t2`.`ACTIVITY_TYPE_CODE`)))
        JOIN `eps_proposal_type` `t3` ON ((`t3`.`TYPE_CODE` = `t1`.`TYPE_CODE`)))
        LEFT JOIN `grant_call_type` `t4` ON ((`t1`.`GRANT_TYPE_CODE` = `t4`.`GRANT_TYPE_CODE`)))
        LEFT JOIN `grant_call_header` `t5` ON ((`t5`.`GRANT_HEADER_ID` = `t1`.`GRANT_HEADER_ID`)))
        LEFT JOIN `budget_header` `t6` ON (((`t6`.`PROPOSAL_ID` = `t1`.`PROPOSAL_ID`)
            AND (`t6`.`IS_LATEST_VERSION` = 'Y'))))
        LEFT JOIN `budget_status` `t7` ON ((`t7`.`BUDGET_STATUS_CODE` = `t6`.`BUDGET_STATUS_CODE`)))
        JOIN `eps_proposal_persons` `t8` ON ((`t1`.`PROPOSAL_ID` = `t8`.`PROPOSAL_ID`)))
        JOIN `eps_proposal_status` `t9` ON ((`t1`.`STATUS_CODE` = `t9`.`STATUS_CODE`)))
        LEFT JOIN `award_type` `t10` ON ((`t1`.`AWARD_TYPE_CODE` = `t10`.`AWARD_TYPE_CODE`)))
        LEFT JOIN `evaluation_recommendation` `t22` ON ((`t1`.`EVALUATION_RECOMMENDATION_CODE` = `t22`.`EVALUATION_RECOMMENDATION_CODE`)))
        LEFT JOIN (SELECT 
            `s1`.`PROPOSAL_ID` AS `PROPOSAL_ID`,
                `s1`.`SPECIAL_REVIEW_CODE` AS `SPECIAL_REVIEW_CODE`
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
        LEFT JOIN `funding_scheme` `t21` ON ((`t21`.`FUNDING_SCHEME_CODE` = `t13`.`FUNDING_SCHEME_CODE`)))
        LEFT JOIN `sponsor` `t14` ON ((`t14`.`SPONSOR_CODE` = `t1`.`SPONSOR_CODE`)))
        LEFT JOIN `sponsor_type` `t15` ON ((`t15`.`SPONSOR_TYPE_CODE` = `t14`.`SPONSOR_TYPE_CODE`)))
        LEFT JOIN `eps_prop_discipline_cluster` `t16` ON ((`t1`.`CLUSTER_CODE` = `t16`.`CLUSTER_CODE`)))
        LEFT JOIN `rolodex` `t17` ON ((`t17`.`ROLODEX_ID` = `t8`.`ROLODEX_ID`)))
        LEFT JOIN `organization` `t18` ON ((`t18`.`ORGANIZATION_ID` = `t17`.`ORGANIZATION`)))
        LEFT JOIN `SPONSOR` `t23` ON ((`t23`.`SPONSOR_CODE` = `t1`.`PRIME_SPONSOR_CODE`)))     
        LEFT JOIN (
            SELECT PROPOSAL_ID, P.FULL_NAME,MDR.DERIVED_ROLE_NAME FROM EPS_PROPOSAL_PERSON_ROLES PPR
            INNER JOIN MODULE_DERIVED_ROLES MDR ON MDR.ROLE_ID = PPR.ROLE_ID
            LEFT JOIN PERSON P ON P.PERSON_ID = PPR.PERSON_ID
            WHERE MDR.MODULE_CODE = 3) `t24` ON ((`t24`.`PROPOSAL_ID` = `t1`.`PROPOSAL_ID`)))
        
        LEFT JOIN (SELECT 
            `p1`.`PROPOSAL_ID` AS `PROPOSAL_ID`,
                `p1`.`PERSON_ID` AS `PERSON_ID`,
                `p1`.`ROLODEX_ID` AS `ROLODEX_ID`,
                `p1`.`FULL_NAME` AS `FULL_NAME`,
                `p1`.`PERCENTAGE_OF_EFFORT` AS `PERCENTAGE_OF_EFFORT`
        FROM
            `eps_proposal_persons` `p1`
        WHERE
            (`p1`.`PI_FLAG` = 'Y')
        GROUP BY `p1`.`PROPOSAL_ID`) `t19` ON ((`t19`.`PROPOSAL_ID` = `t1`.`PROPOSAL_ID`)))
        LEFT JOIN `eps_prop_person_role` `t20` ON ((`t20`.`PROP_PERSON_ROLE_ID` = `t8`.`PROP_PERSON_ROLE_ID`)))
    WHERE
        ((`t1`.`DOCUMENT_STATUS_CODE` <> '3'));
