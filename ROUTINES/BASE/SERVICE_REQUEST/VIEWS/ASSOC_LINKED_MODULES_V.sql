CREATE VIEW `ASSOC_LINKED_MODULES_V` AS
    SELECT DISTINCT
        `t2`.`ASSOC_MODULE_CODE` AS `CODE`,
        `t2`.`NAME` AS `DESCRIPTION`,
        20 AS `MODULE_CODE`
    FROM
        (`sr_module_mapping` `t1`
        JOIN `assoc_config` `t2` ON ((`t1`.`ASSOC_CONFIG_CODE` = `t2`.`ASSOC_CONFIG_CODE`))) 
    UNION SELECT DISTINCT
        `t4`.`ASSOC_MODULE_CODE` AS `CODE`,
        `t4`.`NAME` AS `DESCRIPTION`,
        13 AS `MODULE_CODE`
    FROM
        (`assoc_module_mapping` `t3`
        JOIN `assoc_config` `t4` ON ((`t3`.`ASSOC_CONFIG_CODE` = `t4`.`ASSOC_CONFIG_CODE`)))
    WHERE
        (`t3`.`APPLIED_MODULE_CODE` = 13)

