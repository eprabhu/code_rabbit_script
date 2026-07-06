CREATE VIEW `award_manpower_report_v` AS
    SELECT DISTINCT
        `t`.`ID` AS `ID`,
        `t`.`AWARD_MANPOWER_ID` AS `AWARD_MANPOWER_ID`,
        `t10`.`AWARD_ID` AS `AWARD_ID`,
        `t10`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
        `t10`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`,
        `t`.`MANPOWER_TYPE_CODE` AS `MANPOWER_TYPE_CODE`,
        `t3`.`DESCRIPTION` AS `MANPOWER_CATEGORY_TYPE`,
        `t`.`PERSON_ID` AS `PERSON_ID`,
        `t`.`ROLODEX_ID` AS `ROLODEX_ID`,
        `t`.`FULL_NAME` AS `FULL_NAME`,
        `t`.`POSITION_ID` AS `POSITION_ID`,
        `t4`.`DESCRIPTION` AS `POSITION_STATUS`,
        `t`.`PLAN_JOB_PROFILE_TYPE_CODE` AS `PLAN_JOB_PROFILE_TYPE_CODE`,
        `t5`.`DESCRIPTION` AS `PLAN_JOB_PROFILE_TYPE`,
        `t6`.`DESCRIPTION` AS `JOB_PROFILE_TYPE`,
        `t`.`CANDIDATE_TITLE_TYPE_CODE` AS `CANDIDATE_TITLE_TYPE_CODE`,
        `t7`.`DESCRIPTION` AS `CANDIDATE_TITLE_TYPE`,
        `t`.`COMMENTS` AS `COMMENTS`,
        (CASE COALESCE(`t9`.`STATUS`, `t12`.`IS_ACTIVE`)
            WHEN 'A' THEN 'ACTIVE'
            WHEN 'I' THEN 'INACTIVE'
        END) AS `PERSON_STATUS`,
        `t`.`COST_ALLOCATION` AS `COST_ALLOCATION`,
        `t`.`PLANNED_BASE_SALARY` AS `INITIAL_MONTHLY_BASE_SALARY`,
        `t`.`PLANNED_SALARY` AS `INITIAL_COMMITTED_AMOUNT`,
        `t`.`CHARGE_START_DATE` AS `CHARGE_START_DATE`,
        `t`.`CHARGE_END_DATE` AS `CHARGE_END_DATE`,
        `t`.`CHARGE_DURATION` AS `CHARGE_DURATION`,
        `t8`.`BASE_SALARY` AS `BASE_SALARY`,
        COALESCE(`t11`.`unit_name`, `t13`.`unit_name`) AS `HOME_DEPARTMENT`,
        `t8`.`HIRE_DATE` AS `HIRE_DATE`,
        `t8`.`CONTRACT_END_DATE` AS `CONTRACT_END_DATE`,
        `t8`.`CADIDATURE_START_DATE` AS `CANDIDATURE_START_DATE`,
        `t8`.`CADIDATURE_END_DATE` AS `CANDIDATURE_END_DATE`,
        `t14`.`DESCRIPTION` AS `NON_PAID_MANPOWER_TYPE`,
        `t8`.`NATIONALITY` AS `NATIONALITY`,
        `t8`.`CITIZENSHIP` AS `CITIZENSHIP`,
        `t10`.`TITLE` AS `TITLE`,
        `t10`.`PI_PERSON_ID` AS `PI_PERSON_ID`,
        `t10`.`PI_NAME` AS `PI_NAME`,
        `t10`.`AWARD_TYPE` AS `AWARD_TYPE`,
        `t10`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`,
        `t10`.`AWARD_STATUS` AS `AWARD_STATUS`,
        `t10`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
        `t10`.`SPONSOR_TYPE` AS `SPONSOR_TYPE`,
        `t10`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`,
        `t10`.`unit_name` AS `UNIT_NAME`,
        `t10`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`,
        `t10`.`LEVEL_2_SUP_ORG` AS `LEVEL_2_SUP_ORG`,
        `t10`.`BEGIN_DATE` AS `AWARD_EFFECTIVE_DATE`,
        `t10`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
        `t10`.`DURATION` AS `DURATION`,
        `t10`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
        `t10`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
        `t10`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
        `t10`.`TOTAL_PROJECT_COST` AS `TOTAL_COST`,
        `t10`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`,
        `t10`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`,
        `t10`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
        `t10`.`AWARD_SEQUENCE_STATUS` AS `AWARD_SEQUENCE_STATUS`,
        `t9`.`GENDER` AS `KEY_PERSON_GENDER`,
        `t9`.`EMAIL_ADDRESS` AS `KEY_PERSON_EMAIL`,
        `t`.`L2_WBS_NUMBER` AS `L2_WBS_NUMBER`,
        IFNULL(`t9`.`EMAIL_ADDRESS`,
                `t12`.`EMAIL_ADDRESS`) AS `PERSON_EMAIL`,
        `t`.`JOB_PROFILE_TYPE_CODE` AS `JOB_PROFILE_TYPE_CODE`,
        `t`.`WORKDAY_REFERENCE_ID` AS `WORKDAY_REFERENCE_ID`,
        (`t`.`LINE_ITEM_COST` - IFNULL(`t15`.`COMMITTED_AMOUNT`, 0)) AS `UNCOMMITTED_AMOUNT`,
        `t16`.`EXPENSE_AMOUNT` AS `EXPENSE_AMOUNT`,
        `t17`.`ACTUAL_HEAD_COUNT` AS `ACTUAL_HEAD_COUNT`,
        CAST(`t`.`QUANTITY` AS UNSIGNED) AS `APPROVED_HEAD_COUNT`,
        `t18`.`DESCRIPTION` AS `COST_ELEMENT`,
        `t`.`LINE_ITEM_COST` AS `LINE_ITEM_COST`,
        `t15`.`COMMITTED_AMOUNT` AS `COMMITTED_AMOUNT`,
        `t`.`LINE_ITEM_DESCRIPTION` AS `LINE_ITEM_DESCRIPTION`
    FROM
        (((((((((((((((((SELECT 
            CONCAT('FIBI-', `s2`.`AWARD_MANPOWER_RESOURCE_ID`) AS `ID`,
            `s1`.`AWARD_MANPOWER_ID` AS `AWARD_MANPOWER_ID`,
                `s1`.`AWARD_ID` AS `AWARD_ID`,
                `s1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
                `s1`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`,
                `s1`.`MANPOWER_TYPE_CODE` AS `MANPOWER_TYPE_CODE`,
                `s2`.`PERSON_ID` AS `PERSON_ID`,
                `s2`.`ROLODEX_ID` AS `ROLODEX_ID`,
                `s2`.`FULL_NAME` AS `FULL_NAME`,
                `s2`.`POSITION_ID` AS `POSITION_ID`,
                `s2`.`POSITION_STATUS_CODE` AS `POSITION_STATUS_CODE`,
                `s2`.`PLAN_JOB_PROFILE_TYPE_CODE` AS `PLAN_JOB_PROFILE_TYPE_CODE`,
                `s2`.`CANDIDATE_TITLE_TYPE_CODE` AS `CANDIDATE_TITLE_TYPE_CODE`,
                `s2`.`DESCRIPTION` AS `COMMENTS`,
                `s2`.`COST_ALLOCATION` AS `COST_ALLOCATION`,
                NULL AS `PROPOSED_COST_ALLOCATION`,
                `s2`.`PLANNED_BASE_SALARY` AS `PLANNED_BASE_SALARY`,
                `s2`.`PLANNED_SALARY` AS `PLANNED_SALARY`,
                `s2`.`CHARGE_START_DATE` AS `CHARGE_START_DATE`,
                `s2`.`CHARGE_END_DATE` AS `CHARGE_END_DATE`,
                `s2`.`CHARGE_DURATION` AS `CHARGE_DURATION`,
                `s2`.`COMMITTED_COST` AS `COMMITTED_COST`,
                (CASE
                    WHEN (`s1`.`BUDGET_REFERENCE_TYPE_CODE` = 1) THEN `s1`.`BUDGET_REFERENCE_NUMBER`
                    ELSE NULL
                END) AS `L2_WBS_NUMBER`,
                NULL AS `ADJUSTED_COMMITTED_COST`,
                `s2`.`JOB_PROFILE_TYPE_CODE` AS `JOB_PROFILE_TYPE_CODE`,
                NULL AS `WORKDAY_REFERENCE_ID`,
                `s2`.`RESOURCE_TYPE_CODE` AS `RESOURCE_TYPE_CODE`,
                `s2`.`PLAN_START_DATE` AS `PLAN_START_DATE`,
                `s2`.`PLAN_END_DATE` AS `PLAN_END_DATE`,
                `s9`.`BUDGET_DETAILS_ID` AS `BUDGET_DETAILS_ID`,
                `s9`.`cost_element` AS `COST_ELEMENT`,
                `s9`.`LINE_ITEM_DESCRIPTION` AS `LINE_ITEM_DESCRIPTION`,
                `s9`.`LINE_ITEM_COST` AS `LINE_ITEM_COST`,
                `s9`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE`,
                `s9`.`QUANTITY` AS `QUANTITY`
        FROM
            ((((`award_manpower` `s1`
        JOIN `award_manpower_resource` `s2` ON ((`s1`.`AWARD_MANPOWER_ID` = `s2`.`AWARD_MANPOWER_ID`)))
        JOIN `award` `s7` ON (((`s7`.`AWARD_ID` = `s1`.`AWARD_ID`)
            AND ((`s7`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE')
            OR ((`s7`.`AWARD_SEQUENCE_STATUS` = 'PENDING')
            AND (`s7`.`AWARD_DOCUMENT_TYPE_CODE` = 1))))))
        JOIN `award_budget_header` `s8` ON (((`s8`.`AWARD_ID` = `s7`.`AWARD_ID`)
            AND (`s8`.`VERSION_NUMBER` = (SELECT 
                MAX(`award_budget_header`.`VERSION_NUMBER`)
            FROM
                `award_budget_header`
            WHERE
                (`award_budget_header`.`AWARD_ID` = `s7`.`AWARD_ID`))))))
        LEFT JOIN `award_budget_detail` `s9` ON (((`s9`.`BUDGET_HEADER_ID` = `s8`.`BUDGET_HEADER_ID`)
            AND ((`s9`.`INTERNAL_ORDER_CODE` = `s1`.`BUDGET_REFERENCE_NUMBER`)
            OR (`s9`.`BUDGET_DETAILS_ID` = `s1`.`BUDGET_REFERENCE_NUMBER`)))))
        WHERE
            (((`s2`.`PERSON_ID` IS NULL)
                OR (`s2`.`PERSON_ID` <> '999999999100'))
                AND (`s1`.`MANPOWER_TYPE_CODE` <> 1)) UNION SELECT 
                CONCAT('WD-', `s3`.`MANPOWER_WORKDAY_RESOURCE_ID`) AS `ID`,
                NULL AS `AWARD_MANPOWER_ID`,
                NULL AS `AWARD_ID`,
                NULL AS `AWARD_NUMBER`,
                NULL AS `SEQUENCE_NUMBER`,
                1 AS `MANPOWER_TYPE_CODE`,
                `s3`.`PERSON_ID` AS `PERSON_ID`,
                NULL AS `ROLODEX_ID`,
                `s4`.`FULL_NAME` AS `FULL_NAME`,
                `s3`.`POSITION_ID` AS `POSITION_ID`,
                `s3`.`POSITION_STATUS_CODE` AS `POSITION_STATUS_CODE`,
                NULL AS `PLAN_JOB_PROFILE_TYPE_CODE`,
                NULL AS `CANDIDATE_TITLE_TYPE_CODE`,
                NULL AS `COMMENTS`,
                `s3`.`COST_ALLOCATION` AS `COST_ALLOCATION`,
                NULL AS `PROPOSED_COST_ALLOCATION`,
                NULL AS `PLANNED_BASE_SALARY`,
                NULL AS `PLANNED_SALARY`,
                `s3`.`CHARGE_START_DATE` AS `CHARGE_START_DATE`,
                `s3`.`CHARGE_END_DATE` AS `CHARGE_END_DATE`,
                `s3`.`CHARGE_DURATION` AS `CHARGE_DURATION`,
                `s3`.`COMMITTED_COST` AS `COMMITTED_COST`,
                `s3`.`WBS_NUMBER` AS `L2_WBS_NUMBER`,
                `s3`.`ADJUSTED_COMMITTED_COST` AS `ADJUSTED_COMMITTED_COST`,
                `s3`.`JOB_PROFILE_TYPE_CODE` AS `JOB_PROFILE_TYPE_CODE`,
                `s3`.`WORKDAY_REFERENCE_ID` AS `WORKDAY_REFERENCE_ID`,
                NULL AS `RESOURCE_TYPE_CODE`,
                NULL AS `PLAN_START_DATE`,
                NULL AS `PLAN_END_DATE`,
                `s9`.`BUDGET_DETAILS_ID` AS `BUDGET_DETAILS_ID`,
                `s9`.`cost_element` AS `COST_ELEMENT`,
                `s9`.`LINE_ITEM_DESCRIPTION` AS `LINE_ITEM_DESCRIPTION`,
                `s9`.`LINE_ITEM_COST` AS `LINE_ITEM_COST`,
                `s9`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE`,
                `s9`.`QUANTITY` AS `QUANTITY`
        FROM
            ((`manpower_workday_resource` `s3`
        LEFT JOIN `person` `s4` ON ((`s4`.`PERSON_ID` = `s3`.`PERSON_ID`)))
        JOIN `award_budget_detail` `s9` ON ((`s9`.`INTERNAL_ORDER_CODE` = `s3`.`WBS_NUMBER`)))
        WHERE
            ((`s3`.`WORKDAY_REFERENCE_ID` IS NOT NULL)
                AND `s9`.`BUDGET_HEADER_ID` IN (SELECT 
                    MAX(`tb1`.`BUDGET_HEADER_ID`)
                FROM
                    (`award_budget_header` `tb1`
                JOIN `award` `tb2` ON (((`tb1`.`AWARD_ID` = `tb2`.`AWARD_ID`)
                    AND (`tb2`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'))))
                GROUP BY `tb2`.`AWARD_ID`))) `t`
        LEFT JOIN `manpower_type` `t3` ON ((`t3`.`MANPOWER_TYPE_CODE` = `t`.`MANPOWER_TYPE_CODE`)))
        LEFT JOIN `manpower_position_status` `t4` ON ((`t4`.`POSITION_STATUS_CODE` = `t`.`POSITION_STATUS_CODE`)))
        LEFT JOIN `manpower_job_profile_type` `t5` ON ((`t5`.`JOB_PROFILE_TYPE_CODE` = `t`.`PLAN_JOB_PROFILE_TYPE_CODE`)))
        LEFT JOIN `manpower_job_profile_type` `t6` ON ((`t6`.`JOB_PROFILE_TYPE_CODE` = `t`.`JOB_PROFILE_TYPE_CODE`)))
        LEFT JOIN `manpower_candidate_title_type` `t7` ON ((`t7`.`CANDIDATE_TITLE_TYPE_CODE` = `t`.`CANDIDATE_TITLE_TYPE_CODE`)))
        LEFT JOIN `manpower` `t8` ON ((`t8`.`PERSON_ID` = `t`.`PERSON_ID`)))
        LEFT JOIN `person` `t9` ON ((`t9`.`PERSON_ID` = `t`.`PERSON_ID`)))
        LEFT JOIN `unit` `t11` ON ((`t9`.`HOME_UNIT` = `t11`.`UNIT_NUMBER`)))
        LEFT JOIN `rolodex` `t12` ON ((`t12`.`ROLODEX_ID` = `t`.`ROLODEX_ID`)))
        LEFT JOIN `unit` `t13` ON ((`t12`.`OWNED_BY_UNIT` = `t13`.`UNIT_NUMBER`)))
        JOIN `award_master_dataset_rt` `t10` ON ((((`t10`.`AWARD_ID` = `t`.`AWARD_ID`)
            OR (`t10`.`ACCOUNT_NUMBER` = SUBSTRING_INDEX(`t`.`L2_WBS_NUMBER`, 'EOM', 1)))
            AND (`t10`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE')
            AND (`t10`.`PERSON_ROLE_ID` = 3))))
        LEFT JOIN `manpower_resource_type` `t14` ON ((`t14`.`RESOURCE_TYPE_CODE` = `t`.`RESOURCE_TYPE_CODE`)))
        LEFT JOIN `cost_element` `t18` ON ((`t18`.`COST_ELEMENT` = `t`.`COST_ELEMENT`)))
        LEFT JOIN (SELECT 
            IFNULL(SUM(`sub_query`.`amount`), 0) AS `COMMITTED_AMOUNT`,
                `sub_query`.`WBS_NUMBER` AS `WBS_NUMBER`
        FROM
            (SELECT 
            IFNULL(SUM(COALESCE(`ta1`.`COMMITTED_COST`, `ta1`.`PLANNED_SALARY`, 0)), 0) AS `amount`,
                `ta2`.`BUDGET_REFERENCE_NUMBER` AS `WBS_NUMBER`
        FROM
            (((`award_manpower_resource` `ta1`
        JOIN `award_manpower` `ta2` ON ((`ta1`.`AWARD_MANPOWER_ID` = `ta2`.`AWARD_MANPOWER_ID`)))
        LEFT JOIN `workday_position_requisition` `ta3` ON ((`ta1`.`POSITION_ID` = `ta3`.`POSITION_ID`)))
        JOIN `award` `ta4` ON (((`ta2`.`AWARD_ID` = `ta4`.`AWARD_ID`)
            AND (`ta4`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'))))
        WHERE
            (((`ta2`.`MANPOWER_TYPE_CODE` = 1)
                AND ((`ta1`.`POSITION_ID` IS NULL)
                OR (`ta3`.`JOB_REQUISITION_STATUS` IS NULL)
                OR (`ta3`.`JOB_REQUISITION_STATUS` = 'Open')))
                OR (`ta2`.`MANPOWER_TYPE_CODE` <> 1))
        GROUP BY `ta2`.`BUDGET_REFERENCE_NUMBER` UNION ALL SELECT 
            SUM(COALESCE(`sq1`.`ADJUSTED_COMMITTED_COST`, `sq1`.`COMMITTED_COST`, 0)) AS `amount`,
                `sq1`.`WBS_NUMBER` AS `WBS_NUMBER`
        FROM
            `manpower_workday_resource` `sq1`
        GROUP BY `sq1`.`WBS_NUMBER`) `sub_query`
        GROUP BY `sub_query`.`WBS_NUMBER`) `t15` ON ((`t`.`L2_WBS_NUMBER` = `t15`.`WBS_NUMBER`)))
        LEFT JOIN (SELECT 
            IFNULL(SUM(`award_expense_details`.`TOTAL_EXPENSE_AMOUNT`), 0) AS `EXPENSE_AMOUNT`,
                `award_expense_details`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE`
        FROM
            `award_expense_details`
        GROUP BY `award_expense_details`.`INTERNAL_ORDER_CODE`) `t16` ON ((`t`.`L2_WBS_NUMBER` = `t16`.`INTERNAL_ORDER_CODE`)))
        LEFT JOIN (SELECT 
            COUNT(DISTINCT `sq2`.`PERSON_ID`) AS `ACTUAL_HEAD_COUNT`,
                `sq2`.`WBS_NUMBER` AS `WBS_NUMBER`
        FROM
            `manpower_workday_resource` `sq2`
        WHERE
            ((`sq2`.`PERSON_ID` IS NOT NULL)
                AND (`sq2`.`PERSON_ID` <> '999999999100')
                AND (`sq2`.`POSITION_STATUS_CODE` NOT IN ('8' , '5'))
                AND (CAST(UTC_TIMESTAMP() AS DATE) BETWEEN CAST(`sq2`.`CHARGE_START_DATE` AS DATE) AND CAST(`sq2`.`CHARGE_END_DATE` AS DATE)))
        GROUP BY `sq2`.`WBS_NUMBER`) `t17` ON ((`t`.`L2_WBS_NUMBER` = `t17`.`WBS_NUMBER`)))
