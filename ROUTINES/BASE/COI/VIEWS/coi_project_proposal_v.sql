-- `coi_project_proposal_v`;

CREATE  VIEW `coi_project_proposal_v` AS
    SELECT 
        NULL AS `ID`,
        `t1`.`PROPOSAL_ID` AS `EXTERNAL_SYSTEM_REF_ID`,
        '3' AS `COI_PROJECT_TYPE_CODE`,
        `t1`.`PROPOSAL_ID` AS `PROPOSAL_NUMBER`,
        `t1`.`TITLE` AS `TITLE`,
        (SELECT 
                `eps_proposal_persons`.`PERSON_ID`
            FROM
                `eps_proposal_persons`
            WHERE
                ((`eps_proposal_persons`.`PROP_PERSON_ROLE_ID` = 3)
                    AND (`eps_proposal_persons`.`PI_FLAG` = 'Y')
                    AND (`eps_proposal_persons`.`PROPOSAL_ID` = `t1`.`PROPOSAL_ID`)
                    AND (`t1`.`DOCUMENT_STATUS_CODE` <> 3)
                    AND (`t1`.`STATUS_CODE` NOT IN (1 , 29, 35, 9, 22, 20, 24, 30, 3, 12))
                    AND (`t1`.`DOCUMENT_STATUS_CODE` <> 3))
            LIMIT 1) AS `PI_PERSON_ID`,
        (SELECT 
                `eps_proposal_persons`.`FULL_NAME`
            FROM
                `eps_proposal_persons`
            WHERE
                (`eps_proposal_persons`.`PERSON_ID` = `PI_PERSON_ID`)
            LIMIT 1) AS `PI_NAME`,
        COALESCE(`t6`.`PERSON_ID`,T6.ROLODEX_ID) AS `KEY_PERSON_ID`,
        COALESCE(`t7`.`FULL_NAME`,T8.FULL_NAME) AS `KEY_PERSON_NAME`,
        `t6`.`PROP_PERSON_ROLE_ID` AS `KEY_PERSON_ROLE_CODE`,
        `t6`.`DESIGNATION` AS `KEY_PERSON_ROLE_NAME`,
        NULL AS `CERTIFICATION_FLAG`,
        NULL AS `DISCLOSURE_REQUIRED_FLAG`,
        `t3`.`DESCRIPTION` AS `PROPOSAL_STATUS`,
        `t1`.`STATUS_CODE` AS `PROPOSAL_STATUS_CODE`,
        `t4`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
        `t1`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
        `t5`.`SPONSOR_NAME` AS `PRIME_SPONSOR_NAME`,
        `t1`.`PRIME_SPONSOR_CODE` AS `PRIME_SPONSOR_CODE`,
        `t1`.`START_DATE` AS `PROPOSAL_START_DATE`,
        `t1`.`END_DATE` AS `PROPOSAL_END_DATE`,
        `t1`.`HOME_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
        `t1`.`HOME_UNIT_NAME` AS `LEAD_UNIT_NAME`,
        NULL AS `PROPOSAL_TYPE_CODE`,
        NULL AS `UPDATE_TIMESTAMP`,
        NULL AS `LINKED_IP_NUMBER`,
        NULL AS `PERSON_STATUS`,
        NULL AS `DOCUMENT_NUMBER`,
		case when t6.PERSON_ID  is null then 'Y' else 'N' END AS NON_EMPLOYEE_FLAG
    FROM
        (((((`eps_proposal` `t1`
        JOIN `eps_proposal_status` `t3` ON ((`t3`.`STATUS_CODE` = `t1`.`STATUS_CODE`)))
        JOIN `sponsor` `t4` ON ((`t4`.`SPONSOR_CODE` = `t1`.`SPONSOR_CODE`)))
        LEFT JOIN `sponsor` `t5` ON ((`t5`.`SPONSOR_CODE` = `t1`.`PRIME_SPONSOR_CODE`)))
        JOIN `eps_proposal_persons` `t6` ON ((`t6`.`PROPOSAL_ID` = `t1`.`PROPOSAL_ID`)))
        JOIN `person` `t7` ON ((`t6`.`PERSON_ID` = `t7`.`PERSON_ID`))
		JOIN `rolodex` `t8` ON ((`t6`.`ROLODEX_ID` = `t8`.`ROLODEX_ID`)))
    WHERE
        ((`t1`.`DOCUMENT_STATUS_CODE` <> 3)
            AND (`t1`.`STATUS_CODE` NOT IN (1 , 29, 35, 9, 22, 20, 24, 30, 3, 12))
            AND (`t1`.`DOCUMENT_STATUS_CODE` <> 3)) 
    UNION ALL SELECT 
        `coi_int_stage_dev_proposal`.`STAGE_PROPOSAL_ID` AS `ID`,
        `coi_int_stage_dev_proposal`.`PROPOSAL_NUMBER` AS `EXTERNAL_SYSTEM_REF_ID`,
        '3' AS `COI_PROJECT_TYPE_CODE`,
        `coi_int_stage_dev_proposal`.`PROPOSAL_NUMBER` AS `PROPOSAL_NUMBER`,
        `coi_int_stage_dev_proposal`.`TITLE` AS `TITLE`,
        (SELECT 
                `coi_int_stage_dev_proposal_person`.`KEY_PERSON_ID`
            FROM
                `coi_int_stage_dev_proposal_person`
            WHERE
                ((`coi_int_stage_dev_proposal_person`.`KEY_PERSON_ROLE` = 'Principal Investigator')
                    AND (`coi_int_stage_dev_proposal_person`.`PROPOSAL_NUMBER` = `coi_int_stage_dev_proposal`.`PROPOSAL_NUMBER`)
                    AND (`coi_int_stage_dev_proposal_person`.`STATUS` != 'I'))
            LIMIT 1) AS `PI_PERSON_ID`,
        (SELECT 
                `coi_int_stage_dev_proposal_person`.`KEY_PERSON_NAME`
            FROM
                `coi_int_stage_dev_proposal_person`
            WHERE
                (`coi_int_stage_dev_proposal_person`.`KEY_PERSON_ID` = `PI_PERSON_ID`)
            LIMIT 1) AS `PI_NAME`,
        `coi_int_stage_dev_proposal_person`.`KEY_PERSON_ID` AS `KEY_PERSON_ID`,
        `coi_int_stage_dev_proposal_person`.`KEY_PERSON_NAME` AS `KEY_PERSON_NAME`,
        `coi_int_stage_dev_proposal_person`.`KEY_PERSON_ROLE_CODE` AS `KEY_PERSON_ROLE_CODE`,
        `coi_int_stage_dev_proposal_person`.`KEY_PERSON_ROLE` AS `KEY_PERSON_ROLE_NAME`,
        `coi_int_stage_dev_proposal_person`.`CERTIFICATION_FLAG` AS `CERTIFICATION_FLAG`,
        `coi_int_stage_dev_proposal_person`.`DISCLOSURE_REQUIRED_FLAG` AS `DISCLOSURE_REQUIRED_FLAG`,
        `coi_int_stage_dev_proposal`.`PROPOSAL_STATUS` AS `PROPOSAL_STATUS`,
        `coi_int_stage_dev_proposal`.`PROPOSAL_STATUS_CODE` AS `PROPOSAL_STATUS_CODE`,
        `coi_int_stage_dev_proposal`.`SPONSOR` AS `SPONSOR_NAME`,
        `coi_int_stage_dev_proposal`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
        `coi_int_stage_dev_proposal`.`PRIME_SPONSOR` AS `PRIME_SPONSOR_NAME`,
        `coi_int_stage_dev_proposal`.`PRIME_SPONSOR_CODE` AS `PRIME_SPONSOR_CODE`,
        `coi_int_stage_dev_proposal`.`PROPOSAL_START_DATE` AS `PROPOSAL_START_DATE`,
        `coi_int_stage_dev_proposal`.`PROPOSAL_END_DATE` AS `PROPOSAL_END_DATE`,
        `coi_int_stage_dev_proposal`.`LEAD_UNIT` AS `LEAD_UNIT_NUMBER`,
        `coi_int_stage_dev_proposal`.`LEAD_UNIT_NAME` AS `LEAD_UNIT_NAME`,
        `coi_int_stage_dev_proposal`.`PROPOSAL_TYPE_CODE` AS `PROPOSAL_TYPE_CODE`,
        `coi_int_stage_dev_proposal`.`SRC_SYS_UPDATE_TIMESTAMP` AS `UPDATE_TIMESTAMP`,
        `coi_int_stage_dev_proposal`.`IP_NUMBER` AS `LINKED_IP_NUMBER`,
        `coi_int_stage_dev_proposal_person`.`STATUS` AS `PERSON_STATUS`,
        `coi_int_stage_dev_proposal`.`ATTRIBUTE_2_VALUE` AS `DOCUMENT_NUMBER`,
		`coi_int_stage_dev_proposal_person`.`ATTRIBUTE_1_VALUE` AS `NON_EMPLOYEE_FLAG`
    FROM
        (`coi_int_stage_dev_proposal`
        JOIN `coi_int_stage_dev_proposal_person` ON ((`coi_int_stage_dev_proposal`.`PROPOSAL_NUMBER` = `coi_int_stage_dev_proposal_person`.`PROPOSAL_NUMBER`)));

