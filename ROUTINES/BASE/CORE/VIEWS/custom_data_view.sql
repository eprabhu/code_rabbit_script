-- custom_data_view;

CREATE VIEW `custom_data_view` AS 
select
   `t1`.`MODULE_ITEM_KEY` AS `MODULE_ITEM_KEY`,
   `t2`.`VALUE` AS `GRANT_CODE`,
   `t3`.`VALUE` AS `INPUT_GST_CATEGORY`,
   `t4`.`VALUE` AS `OUTPUT_GST_CATEGORY`,
   `t5`.`VALUE` AS `RIE_DOMAIN`,
   `t6`.`VALUE` AS `COST_CENTER`,
   `t7`.`VALUE` AS `PROFIT_CENTER`,
   `t8`.`VALUE` AS `FUND_CENTER` 
from
   (
((((((`custom_data` `t1` 
      left join
         `custom_data` `t2` 
         on(((`t2`.`MODULE_ITEM_KEY` = `t1`.`MODULE_ITEM_KEY`) 
         and 
         (
            `t2`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  `custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID` 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'GRANT CODE'
                  )
            )
         )
))) 
      left join
         `custom_data` `t3` 
         on(((`t3`.`MODULE_ITEM_KEY` = `t1`.`MODULE_ITEM_KEY`) 
         and 
         (
            `t3`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  `custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID` 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'Input GST Category'
                  )
            )
         )
))) 
      left join
         `custom_data` `t4` 
         on(((`t4`.`MODULE_ITEM_KEY` = `t1`.`MODULE_ITEM_KEY`) 
         and 
         (
            `t4`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  `custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID` 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'Output GST Category'
                  )
            )
         )
))) 
      left join
         `custom_data` `t5` 
         on(((`t5`.`MODULE_ITEM_KEY` = `t1`.`MODULE_ITEM_KEY`) 
         and 
         (
            `t5`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  `custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID` 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'RIE Domain'
                  )
            )
         )
))) 
      left join
         `custom_data` `t6` 
         on(((`t6`.`MODULE_ITEM_KEY` = `t1`.`MODULE_ITEM_KEY`) 
         and 
         (
            `t6`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  `custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID` 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'COST CENTER'
                  )
            )
         )
))) 
      left join
         `custom_data` `t7` 
         on(((`t7`.`MODULE_ITEM_KEY` = `t1`.`MODULE_ITEM_KEY`) 
         and 
         (
            `t7`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  `custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID` 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'PROFIT CENTER'
                  )
            )
         )
))) 
      left join
         `custom_data` `t8` 
         on(((`t8`.`MODULE_ITEM_KEY` = `t1`.`MODULE_ITEM_KEY`) 
         and 
         (
            `t8`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  `custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID` 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'FUND CENTER'
                  )
            )
         )
))
   )
where
   (
      `t1`.`MODULE_ITEM_CODE` = 1
   )
group by
   `t1`.`MODULE_ITEM_KEY`;
   