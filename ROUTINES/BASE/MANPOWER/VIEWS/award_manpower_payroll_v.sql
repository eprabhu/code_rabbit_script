CREATE VIEW `award_manpower_payroll_v` AS
    SELECT DISTINCT
        CONCAT('WD-', `t8`.`MANPOWER_WORKDAY_RESOURCE_ID`) AS `ID`,
        `t2`.`PAYROLL_ID` AS `PAYROLL_ID`,
        `t2`.`GL_ACCOUNT_CODE` AS `GL_ACCOUNT_CODE`,
        `t2`.`EMPLOYEE_NUMBER` AS `EMPLOYEE_NUMBER`,
        `t2`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE`,
        `t2`.`COST_SHARING` AS `COST_SHARING`,
        `t2`.`PAY_ELEMENT_CODE` AS `PAY_ELEMENT_CODE`,
        `t2`.`PAY_ELEMENT` AS `PAY_ELEMENT`,
        STR_TO_DATE(CONCAT('01', `t2`.`PAYROLL_PERIOD`),
                '%d%m%Y') AS `PAYROLL_PERIOD`,
        `t2`.`REMARKS` AS `REMARKS`,
        `t2`.`AMOUNT` AS `AMOUNT`,
        `t4`.`NATIONALITY` AS `NATIONALITY`,
        `t4`.`CITIZENSHIP` AS `CITIZENSHIP`,
        `t3`.`DESCRIPTION` AS `POSITION_STATUS`,
        `t8`.`POSITION_STATUS_CODE` AS `POSITION_STATUS_CODE`,
        `t7`.`DESCRIPTION` AS `JOB_PROFILE_TYPE`,
        `t7`.`DEFAULT_JOB_TITLE` AS `DEFAULT_JOB_PROFILE_TYPE`,
        `t4`.`BASE_SALARY` AS `BASE_SALARY`,
        `t2`.`EMPLOYEE_NUMBER` AS `PERSON_ID`,
        `t9`.`FULL_NAME` AS `FULL_NAME`,
        `t8`.`POSITION_ID` AS `POSITION_ID`,
        `t8`.`COST_ALLOCATION` AS `COST_ALLOCATION`,
        DATE_FORMAT(`t8`.`CHARGE_START_DATE`, '%d/%m/%Y') AS `CHARGE_START_DATE`,
        DATE_FORMAT(`t8`.`CHARGE_END_DATE`, '%d/%m/%Y') AS `CHARGE_END_DATE`,
        `t8`.`CHARGE_DURATION` AS `CHARGE_DURATION`,
        (CASE `t9`.`STATUS`
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'Inactive'
        END) AS `PERSON_STATUS`,
        `t10`.`unit_name` AS `HOME_DEPARTMENT`,
        DATE_FORMAT(`t4`.`HIRE_DATE`, '%d/%m/%Y') AS `HIRE_DATE`,
        DATE_FORMAT(`t4`.`CONTRACT_END_DATE`, '%d/%m/%Y') AS `CONTRACT_END_DATE`,
        DATE_FORMAT(`t4`.`CADIDATURE_START_DATE`, '%d/%m/%Y') AS `CANDIDATURE_START_DATE`,
        DATE_FORMAT(`t4`.`CADIDATURE_END_DATE`, '%d/%m/%Y') AS `CANDIDATURE_END_DATE`,
        `t9`.`EMAIL_ADDRESS` AS `PERSON_EMAIL`,
        `t15`.`TITLE` AS `TITLE`,
        `t15`.`PI_PERSON_ID` AS `PI_PERSON_ID`,
        `t15`.`PI_NAME` AS `PI_NAME`,
        `t15`.`AWARD_TYPE` AS `AWARD_TYPE`,
        `t15`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`,
        `t15`.`AWARD_STATUS` AS `AWARD_STATUS`,
        `t15`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
        `t15`.`SPONSOR_TYPE` AS `SPONSOR_TYPE`,
        `t15`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`,
        `t15`.`unit_name` AS `UNIT_NAME`,
        `t15`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`,
        `t15`.`BEGIN_DATE` AS `BEGIN_DATE`,
        `t15`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
        `t15`.`DURATION` AS `DURATION`,
        `t15`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`,
        `t15`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`,
        `t15`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`,
        `t15`.`TOTAL_COST` AS `TOTAL_COST`,
        `t15`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`,
        `t15`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`,
        `t15`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
        `t15`.`AWARD_SEQUENCE_STATUS` AS `AWARD_SEQUENCE_STATUS`,
        CAST(`t15`.`AWARD_ID` AS UNSIGNED) AS `AWARD_ID`,
        `t15`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
        `t15`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`,
        'Staff' AS `MANPOWER_CATEGORY_TYPE`,
        `t2`.`INTERNAL_ORDER_CODE` AS `WBS_NUMBER`,
        `t15`.`F_AND_A_RATE_TYPE` AS `F_AND_A_RATE_TYPE`   
    FROM
        (((((((`award_master_dataset_rt` `t15`
        JOIN (SELECT 
            `z1`.`PAYROLL_ID` AS `PAYROLL_ID`,
                `z1`.`GL_ACCOUNT_CODE` AS `GL_ACCOUNT_CODE`,
                `z1`.`EMPLOYEE_NUMBER` AS `EMPLOYEE_NUMBER`,
                `z1`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE`,
                SUBSTR(`z1`.`INTERNAL_ORDER_CODE`, 1, 15) AS `ACCOUNT_NUMBER`,
                `z1`.`COST_SHARING` AS `COST_SHARING`,
                `z1`.`PAY_ELEMENT_CODE` AS `PAY_ELEMENT_CODE`,
                `z1`.`PAY_ELEMENT` AS `PAY_ELEMENT`,
                `z1`.`PAYROLL_PERIOD` AS `PAYROLL_PERIOD`,
                `z1`.`REMARKS` AS `REMARKS`,
                `z1`.`AMOUNT` AS `AMOUNT`
        FROM
            `award_manpower_payroll` `z1`) `t2` ON ((`t15`.`ACCOUNT_NUMBER` = `t2`.`ACCOUNT_NUMBER`)))
        LEFT JOIN `manpower` `t4` ON ((`t4`.`PERSON_ID` = `t2`.`EMPLOYEE_NUMBER`)))
        LEFT JOIN `manpower_workday_resource` `t8` ON (`t8`.`wbs_number` = `t2`.`INTERNAL_ORDER_CODE`)
        AND (`t8`.`PERSON_ID` = `t2`.`EMPLOYEE_NUMBER`)
        AND STR_TO_DATE(CONCAT('01', `t2`.`PAYROLL_PERIOD`), '%d%m%Y') BETWEEN `t8`.`CHARGE_START_DATE` AND `t8`.`CHARGE_END_DATE`)
        LEFT JOIN `manpower_job_profile_type` `t7` ON ((`t7`.`JOB_PROFILE_TYPE_CODE` = `t8`.`JOB_PROFILE_TYPE_CODE`)))
        LEFT JOIN `manpower_position_status` `t3` ON `t3`.`POSITION_STATUS_CODE` = `t8`.`POSITION_STATUS_CODE`)
        LEFT JOIN `person` `t9` ON ((`t9`.`PERSON_ID` = `t2`.`EMPLOYEE_NUMBER`)))
        LEFT JOIN `unit` `t10` ON ((`t9`.`HOME_UNIT` = `t10`.`UNIT_NUMBER`)))
    WHERE
        (`t15`.`PERSON_ROLE_ID` = 3)
