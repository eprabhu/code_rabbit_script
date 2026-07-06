-- irb_protocol_v;

CREATE VIEW IRB_PROTOCOL_V AS
SELECT 
        CONCAT('IRB', `t1`.`PROTOCOL_ID`) AS `ID`,
        `t1`.`PROTOCOL_ID` AS `PROTOCOL_ID`,
        `t1`.`PROTOCOL_NUMBER` AS `PROTOCOL_NUMBER`,
        `t1`.`PROTOCOL_STATUS_CODE` AS `PROTOCOL_STATUS_CODE`,
        `t2`.`DESCRIPTION` AS `PROTOCOL_STATUS`,
        `t1`.`TITLE` AS `TITLE`,
        `t1`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`,
        `t3`.`DISPLAY_NAME` AS `UNIT_NAME`,
        DATE_FORMAT(`t1`.`APPROVAL_DATE`, '%m/%d/%Y') AS `APPROVAL_DATE`,
        DATE_FORMAT(`t1`.`EXPIRATION_DATE`, '%m/%d/%Y') AS `EXPIRATION_DATE`,
        `t1`.`PROTOCOL_TYPE_CODE` AS `PROTOCOL_TYPE_CODE`,
        `t4`.`DESCRIPTION` AS `PROTOCOL_TYPE`,
        NULL AS `PI_NAME`
    FROM
        (((`irb_protocol` `t1`
        JOIN `irb_protocol_status` `t2` ON ((`t2`.`PROTOCOL_STATUS_CODE` = `t1`.`PROTOCOL_STATUS_CODE`)))
        JOIN `unit` `t3` ON ((`t1`.`LEAD_UNIT_NUMBER` = `t3`.`UNIT_NUMBER`)))
        JOIN `irb_protocol_type` `t4` ON ((`t4`.`PROTOCOL_TYPE_CODE` = `t1`.`PROTOCOL_TYPE_CODE`)))
    WHERE
        (`t1`.`PROTOCOL_ID` = (SELECT 
                MAX(`irb_protocol`.`PROTOCOL_ID`)
            FROM
                `irb_protocol`
            WHERE
                (`irb_protocol`.`PROTOCOL_NUMBER` = `t1`.`PROTOCOL_NUMBER`)));

