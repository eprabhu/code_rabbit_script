-- custom_data_v;

CREATE VIEW `custom_data_v` AS 
select
   `custom_data`.`MODULE_ITEM_KEY` AS `MODULE_ITEM_KEY`,
   max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'GRANT CODE'
                  )
            )
         )
      then
         ifnull(`custom_data`.`DESCRIPTION`, `custom_data`.`VALUE`) 
   end
)) AS `GRANT_CODE`, max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'Input GST Category'
                  )
            )
         )
      then
         ifnull(`custom_data`.`DESCRIPTION`, `custom_data`.`VALUE`) 
   end
)) AS `INPUT_GST_CATEGORY`, max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'Output GST Category'
                  )
            )
         )
      then
         ifnull(`custom_data`.`DESCRIPTION`, `custom_data`.`VALUE`) 
   end
)) AS `OUTPUT_GST_CATEGORY`, max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'STEM/Non-STEM'
                  )
            )
         )
      then
         ifnull(`custom_data`.`DESCRIPTION`, `custom_data`.`VALUE`) 
   end
)) AS `STEM_NONSTEM`, max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'RIE Domain'
                  )
            )
         )
      then
         ifnull(`custom_data`.`DESCRIPTION`, `custom_data`.`VALUE`) 
   end
)) AS `RIE_DOMAIN`, max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'Sub_lead_Unit'
                  )
            )
         )
      then
         `custom_data`.`DESCRIPTION` 
   end
)) AS `SUB_LEAD_UNIT`, max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'PROFIT CENTER'
                  )
            )
         )
      then
         ifnull(`custom_data`.`DESCRIPTION`, `custom_data`.`VALUE`) 
   end
)) AS `PROFIT_CENTER`, max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'FUND CENTER'
                  )
            )
         )
      then
         ifnull(`custom_data`.`DESCRIPTION`, `custom_data`.`VALUE`) 
   end
)) AS `FUND_CENTER`, max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'COST CENTER'
                  )
            )
         )
      then
         ifnull(`custom_data`.`DESCRIPTION`, `custom_data`.`VALUE`) 
   end
)) AS `COST_CENTER`, max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'Display at Acad Profile?'
                  )
            )
         )
      then
         ifnull(`custom_data`.`DESCRIPTION`, `custom_data`.`VALUE`) 
   end
)) AS `DISPLAY_AT_ACAD_PROFILE`, max((
   case
      when
         (
            `custom_data`.`CUSTOM_DATA_ELEMENTS_ID` = 
            (
               select
                  max(`custom_data_elements`.`CUSTOM_DATA_ELEMENTS_ID`) 
               from
                  `custom_data_elements` 
               where
                  (
                     `custom_data_elements`.`custom_element_name` = 'CLAIM_PREPARER'
                  )
            )
         )
      then
         ifnull(`custom_data`.`VALUE`, `custom_data`.`DESCRIPTION`) 
   end
)) AS `CLAIM_PREPARER` 
from
   `custom_data` 
where
   (
      `custom_data`.`MODULE_ITEM_CODE` = 1
   )
group by
   `custom_data`.`MODULE_ITEM_KEY`;
   
