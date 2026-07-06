CREATE 
VIEW `PROGRESS_REPORT_STATUS_V` AS
    SELECT 
        `t1`.`AWARD_ID` AS `AWARD_ID`,
        `t1`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`,
        `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
        `t1`.`ACCOUNT_NUMBER` AS `PROJECT_NUMBER`,
        `t1`.`TITLE` AS `AWARD_TITLE`,
        `t1`.`AWARD_STATUS` AS `AWARD_STATUS`,
        `t1`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`,
        `t1`.`ACTIVITY_TYPE` AS `ACTIVITY_TYPE`,
        `t1`.`BEGIN_DATE` AS `AWARD_EFFECTIVE_DATE`,
        `t1`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`,
        `t1`.`AWARD_TYPE` AS `AWARD_TYPE`,
        `t1`.`unit_name` AS `UNIT_NAME`,
        `t1`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
        `t1`.`PRIME_SPONSOR_NAME` AS `PRIME_SPONSOR_NAME`,
        `rc`.`DESCRIPTION` AS `REPORT_CLASS`,
        `t1`.`PI_NAME` AS `PI_NAME`,
        `f`.`DESCRIPTION` AS `REPORT_FREQUENCY`,
        `t0`.`DUE_DATE` AS `DUE_DATE`,
        `t3`.`PROGRESS_REPORT_NUMBER` AS `PROGRESS_REPORT_NUMBER`,
        `t3`.`REPORT_START_DATE` AS `REPORT_START_DATE`,
        `t3`.`REPORT_END_DATE` AS `REPORT_END_DATE`,
        `t3`.`CREATE_TIMESTAMP` AS `REPORT_CREATED_DATE`,
        `t11`.`DESCRIPTION` AS `REPORT_STATUS`,
        `t13`.`DESCRIPTION` AS `GRANT_TYPE`,
        `t1`.`FUNDER_APPROVAL_DATE` AS `FUNDER_APPROVAL_DATE`,
        `t1`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
        `t10`.`FILE_NAME` AS `FILE_NAME`
    FROM
        ((((((((`award_master_dataset_rt` `t1`
        JOIN `award_report_tracking` `t0` ON ((`t1`.`AWARD_ID` = `t0`.`AWARD_ID`)))
        JOIN `award_report_terms` `t5` ON (((`t0`.`AWARD_REPORT_TERMS_ID` = `t5`.`AWARD_REPORT_TERMS_ID`)
            AND (`t5`.`SEQUENCE_NUMBER` = 0))))
        LEFT JOIN `frequency` `f` ON ((`t5`.`FREQUENCY_CODE` = `f`.`FREQUENCY_CODE`)))
        LEFT JOIN `award_progress_report` `t3` ON ((`t0`.`PROGRESS_REPORT_ID` = `t3`.`PROGRESS_REPORT_ID`)))
        LEFT JOIN `report_class` `rc` ON ((`rc`.`REPORT_CLASS_CODE` = `t5`.`REPORT_CLASS_CODE`)))
        LEFT JOIN `progress_report_status` `t11` ON ((`t11`.`PROGRESS_REPORT_STATUS_CODE` = `t3`.`PROGRESS_REPORT_STATUS_CODE`)))
        LEFT JOIN `grant_call_type` `t13` ON ((`t1`.`GRANT_TYPE_CODE` = `t13`.`GRANT_TYPE_CODE`)))
        LEFT JOIN (SELECT 
            GROUP_CONCAT(`t12`.`FILE_NAME`
                    SEPARATOR ', ') AS `FILE_NAME`,
                `t12`.`PROGRESS_REPORT_ID` AS `PROGRESS_REPORT_ID`
        FROM
            `award_progress_report_attachment` `t12`
        WHERE
            ((`t12`.`DOCUMENT_STATUS_CODE` = 1)
                AND (`t12`.`UPDATE_TIMESTAMP` = (SELECT 
                    MAX(`t13`.`UPDATE_TIMESTAMP`)
                FROM
                    `award_progress_report_attachment` `t13`
                WHERE
                    ((`t13`.`PROGRESS_REPORT_ID` = `t12`.`PROGRESS_REPORT_ID`)
                        AND (`t13`.`DOCUMENT_STATUS_CODE` = 1)))))
        GROUP BY `t12`.`PROGRESS_REPORT_ID`) `t10` ON ((`t10`.`PROGRESS_REPORT_ID` = `t3`.`PROGRESS_REPORT_ID`)))
    WHERE
        (`t1`.`PERSON_ROLE_ID` = 3)
