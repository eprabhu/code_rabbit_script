-- agreement_custom_report_v;


CREATE VIEW `agreement_custom_report_v` AS 
select
   `ah`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
   `ah`.`TITLE` AS `TITLE`,
   `ah`.`CATEGORY_CODE` AS `CATEGORY_CODE`,
   `acat`.`DESCRIPTION` AS `CATEGORY`,
   `ah`.`AGREEMENT_TYPE_CODE` AS `AGREEMENT_TYPE_CODE`,
   `at`.`DESCRIPTION` AS `AGREEMENT_TYPE`,
   `ah`.`AGREEMENT_STATUS_CODE` AS `AGREEMENT_STATUS_CODE`,
   `ah`.`AGREEMENT_SEQUENCE_STATUS` AS `AGREEMENT_SEQUENCE_STATUS`,
   (
      case
         when
            (
               `ah`.`IS_HOLD` = 'Y'
            )
         then
            concat(`agr_sts`.`DESCRIPTION`, ' - ', 'Info Requested') 
         else
            `agr_sts`.`DESCRIPTION` 
      end
   )
   AS `AGREEMENT_STATUS`, `ah`.`UNIT_NUMBER` AS `UNIT_NUMBER`, `ah`.`UNIT_NAME` AS `UNIT_NAME`, `ah`.`START_DATE` AS `AGREEMENT_START_DATE`, `ah`.`END_DATE` AS `AGREEMENT_END_DATE`, `ah`.`REQUESTOR_PERSON_ID` AS `REQUESTOR_PERSON_ID`, `ah`.`REQUESTOR_NAME` AS `REQUESTOR_NAME`, `ah`.`AMOUNT_IN_WORDS` AS `AMOUNT_IN_WORDS`, `ah`.`CURRENCY_CODE` AS `CURRENCY_CODE`, 
   (
      case
         when
            (
(`ip_link`.`module_link_count` = 0) 
               or 
               (
                  `ip_link`.`module_link_count` is null
               )
            )
         then
            'New' 
         else
            `ip_link`.`LINKED_IDS` 
      end
   )
   AS `TRANSACTION_TYPE`, `spsnr`.`agreement_sponsor_type` AS `AGREEMENT_SPONSOR_TYPE`, `spsnr`.`SPONSOR_NAME` AS `SPONSOR_NAME`, `spsnr`.`SPONSOR_ROLE_TYPE` AS `SPONSOR_ROLE_TYPE`, `ap`.`PERSON_ID` AS `PI_PERSON_ID`, `ap`.`FULL_NAME` AS `PI_PERSON_FULL_NAME`, `ah`.`REMARKS` AS `DESCRIPTION`, concat((
   case
      when
         (
            `cur`.`CURRENCY_SYMBOL` is not null
         )
      then
         `cur`.`CURRENCY_SYMBOL` 
      else
         `ah`.`CURRENCY_CODE` 
   end
), convert(format(`ah`.`CONTRACT_VALUE`, 2) using utf8mb4)) AS `CONTRACT_VALUE`, 
   (
      case
         when
            (
               `ah`.`CATEGORY_CODE` = 19
            )
         then
            'Incoming' 
         when
            (
               `ah`.`CATEGORY_CODE` = 20
            )
         then
            'Outgoing' 
         else
            'NA' 
      end
   )
   AS `IO_FUNDING`, `child`.`WORKFLOW_STATUS` AS `REVIEW_STATUS`, `child`.`WORKFLOW_UPDATE_TIMESTAMP` AS `REVIEW_UPDATE_TIMESTAMP`, `neg_act`.`DESCRIPTION` AS `COMMENT`, `loc_type`.`DESCRIPTION` AS `LOCATION`, date_format(`cd`.`VALUE`, '%d/%m/%Y') AS `DATE_OF_INITIATION`, `neg_loc`.`REVIEW_START_DATE` AS `LOCATION_ASSIGNED_DATE`, `neg_loc`.`REVIEW_END_DATE` AS `REVIEW_END_DATE`, 
   (
      case
         when
            (
               `neg_loc`.`DAYS_IN_LOCATION` <= 0
            )
         then
            '-' 
         else
            `neg_loc`.`DAYS_IN_LOCATION` 
      end
   )
   AS `DAYS_IN_LOCATION`, 
   (
      case
         when
            (
(to_days(utc_date()) - to_days(`cd`.`VALUE`)) < 0
            )
         then
            '-' 
         else
((to_days(utc_date()) - to_days(`cd`.`VALUE`)) + 1) 
      end
   )
   AS `TOTAL_DAYS`, 'Negotiation' AS `PROPOSAL_STATUS`, NULL AS `RECOMMENDATION` 
from
   (
((((((((((((`agreement_header` `ah` 
      join
         `agreement_category` `acat` 
         on((`acat`.`CATEGORY_CODE` = `ah`.`CATEGORY_CODE`))) 
      left join
         (
            select
               `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` AS `AGREEMENT_WORKFLOW_ACTION_ID`,
               `t1`.`REVIEW_STATUS_CODE` AS `REVIEW_STATUS_CODE`,
               `t1`.`DESCRIPTION` AS `WORKFLOW_STATUS`,
               `t2`.`ACTION_TYPE_CODE` AS `ACTION_TYPE_CODE`,
               `t2`.`DESCRIPTION` AS `ACTION_TYPE`,
               max(`t3`.`UPDATE_TIMESTAMP`) AS `WORKFLOW_UPDATE_TIMESTAMP`,
               max(`t3`.`ACTION_LOG_ID`) AS `MAX(t3.ACTION_LOG_ID)`,
               `t3`.`DESCRIPTION` AS `ACTION_LOG`,
               `t3`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID` 
            from
               (
(`agreement_workflow_action` `t1` 
                  join
                     `agreement_action_type` `t2` 
                     on((0 <> (
                     case
                        when
                           (
                              `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` = '300'
                           )
                        then
(`t2`.`ACTION_TYPE_CODE` = 14) 
                        when
                           (
                              `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` = '301'
                           )
                        then
(`t2`.`ACTION_TYPE_CODE` = 15) 
                        when
                           (
                              `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` = '302'
                           )
                        then
(`t2`.`ACTION_TYPE_CODE` = 16) 
                        when
                           (
                              `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` = '303'
                           )
                        then
(`t2`.`ACTION_TYPE_CODE` = 25) 
                        when
                           (
                              `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` = '304'
                           )
                        then
(`t2`.`ACTION_TYPE_CODE` = 26) 
                        when
                           (
                              `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` = '305'
                           )
                        then
(`t2`.`ACTION_TYPE_CODE` = 27) 
                        when
                           (
                              `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` = '306'
                           )
                        then
(`t2`.`ACTION_TYPE_CODE` = 28) 
                        when
                           (
                              `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` = '307'
                           )
                        then
(`t2`.`ACTION_TYPE_CODE` = 29) 
                        when
                           (
                              `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` = '308'
                           )
                        then
(`t2`.`ACTION_TYPE_CODE` = 34) 
                        when
                           (
                              `t1`.`AGREEMENT_WORKFLOW_ACTION_ID` = '309'
                           )
                        then
(`t2`.`ACTION_TYPE_CODE` = 35) 
                     end
)))) 
                  left join
                     `agreement_action_log` `t3` 
                     on((`t3`.`ACTION_TYPE_CODE` = `t2`.`ACTION_TYPE_CODE`))
               )
            where
               (
                  `t3`.`AGREEMENT_REQUEST_ID` is not null
               )
            group by
               `t1`.`REVIEW_STATUS_CODE`, `t3`.`AGREEMENT_REQUEST_ID`
         )
         `child` 
         on(((`child`.`AGREEMENT_REQUEST_ID` = `ah`.`AGREEMENT_REQUEST_ID`) 
         and 
         (
            `child`.`REVIEW_STATUS_CODE` = `ah`.`REVIEW_STATUS_CODE`
         )
))) 
      left join
         `agreement_type` `at` 
         on((`at`.`AGREEMENT_TYPE_CODE` = `ah`.`AGREEMENT_TYPE_CODE`))) 
      left join
         (
            select
               `t1`.`MODULE_ITEM_KEY` AS `MODULE_ITEM_KEY`,
               `t1`.`MODULE_ITEM_CODE` AS `MODULE_ITEM_CODE`,
               `t1`.`MODULE_SUB_ITEM_CODE` AS `MODULE_SUB_ITEM_CODE`,
               `t1`.`VALUE` AS `VALUE` 
            from
               (
                  `custom_data` `t1` 
                  join
                     `custom_data_elements` `t2` 
                     on(((`t2`.`CUSTOM_DATA_ELEMENTS_ID` = `t1`.`CUSTOM_DATA_ELEMENTS_ID`) 
                     and 
                     (
                        `t2`.`COLUMN_LABEL` = 'Date of Initiation'
                     )
))
               )
         )
         `cd` 
         on(((`cd`.`MODULE_ITEM_KEY` = `ah`.`AGREEMENT_REQUEST_ID`) 
         and 
         (
            `cd`.`MODULE_ITEM_CODE` = 13
         )
         and 
         (
            `cd`.`MODULE_SUB_ITEM_CODE` = 0
         )
))) 
      left join
         (
            select
               `s1`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               count(`s1`.`MODULE_ITEM_KEY`) AS `module_link_count`,
               group_concat((
               case
                  when
                     (
                        `s1`.`MODULE_CODE` = 2
                     )
                  then
                     concat('IP: ', `s2`.`PROPOSAL_NUMBER`) 
                  when
                     (
                        `s1`.`MODULE_CODE` = 1
                     )
                  then
                     concat('AW: ', `s3`.`AWARD_NUMBER`) 
                  when
                     (
                        `s1`.`MODULE_CODE` = 3
                     )
                  then
                     convert(concat('DP: ', `s4`.`PROPOSAL_ID`) using utf8mb4) 
                  when
                     (
                        `s1`.`MODULE_CODE` = 13
                     )
                  then
                     convert(concat('AG: ', `s5`.`AGREEMENT_REQUEST_ID`) using utf8mb4) 
               end
) separator ',') AS `LINKED_IDS` 
            from
               (
(((`agreement_association_link` `s1` 
                  left join
                     `proposal` `s2` 
                     on(((`s2`.`PROPOSAL_ID` = `s1`.`MODULE_ITEM_KEY`) 
                     and 
                     (
                        `s1`.`MODULE_CODE` = 2
                     )
))) 
                  left join
                     `award` `s3` 
                     on(((`s3`.`AWARD_ID` = `s1`.`MODULE_ITEM_KEY`) 
                     and 
                     (
                        `s1`.`MODULE_CODE` = 1
                     )
))) 
                  left join
                     `eps_proposal` `s4` 
                     on(((`s4`.`PROPOSAL_ID` = `s1`.`MODULE_ITEM_KEY`) 
                     and 
                     (
                        `s1`.`MODULE_CODE` = 3
                     )
))) 
                  left join
                     `agreement_header` `s5` 
                     on(((`s5`.`AGREEMENT_REQUEST_ID` = `s1`.`MODULE_ITEM_KEY`) 
                     and 
                     (
                        `s1`.`MODULE_CODE` = 13
                     )
))
               )
            group by
               `s1`.`AGREEMENT_REQUEST_ID`
         )
         `ip_link` 
         on((`ip_link`.`AGREEMENT_REQUEST_ID` = `ah`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `t1`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `t3`.`AGREEMENT_SPONSOR_TYPE_CODE` AS `AGREEMENT_SPONSOR_TYPE_CODE`,
               `t3`.`DESCRIPTION` AS `agreement_sponsor_type`,
               `t1`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
               `t2`.`SPONSOR_ROLE_TYPE_CODE` AS `SPONSOR_ROLE_TYPE_CODE`,
               `t2`.`DESCRIPTION` AS `SPONSOR_ROLE_TYPE` 
            from
               (
(`agreement_sponsor` `t1` 
                  join
                     `sponsor_role` `t2` 
                     on((`t2`.`SPONSOR_ROLE_TYPE_CODE` = `t1`.`SPONSOR_ROLE_TYPE_CODE`))) 
                  join
                     `agreement_sponsor_type` `t3` 
                     on((`t3`.`AGREEMENT_SPONSOR_TYPE_CODE` = `t1`.`AGREEMENT_SPONSOR_TYPE_CODE`))
               )
            where
               (
                  `t1`.`AGREEMENT_SPONSOR_TYPE_CODE` = 1
               )
         )
         `spsnr` 
         on((`spsnr`.`AGREEMENT_REQUEST_ID` = `ah`.`AGREEMENT_REQUEST_ID`))) 
      left join
         `agreement_people` `ap` 
         on(((`ap`.`AGREEMENT_REQUEST_ID` = `ah`.`AGREEMENT_REQUEST_ID`) 
         and 
         (
            `ap`.`PEOPLE_TYPE_ID` = 3
         )
))) 
      left join
         `agreement_status` `agr_sts` 
         on((`agr_sts`.`AGREEMENT_STATUS_CODE` = `ah`.`AGREEMENT_STATUS_CODE`))) 
      left join
         `negotiation_association` `neg_aso` 
         on(((`neg_aso`.`ASSOCIATION_TYPE_CODE` = 4) 
         and 
         (
            `neg_aso`.`ASSOCIATED_PROJECT_ID` = `ah`.`AGREEMENT_REQUEST_ID`
         )
))) 
      left join
         (
            select
               `negotiation_activity`.`NEGOTIATION_ACTIVITY_ID` AS `NEGOTIATION_ACTIVITY_ID`,
               `negotiation_activity`.`NEGOTIATION_ID` AS `NEGOTIATION_ID`,
               `negotiation_activity`.`NEGOTIATION_LOCATION_ID` AS `NEGOTIATION_LOCATION_ID`,
               `negotiation_activity`.`LOCATION_TYPE_CODE` AS `LOCATION_TYPE_CODE`,
               `negotiation_activity`.`ACTIVITY_TYPE_CODE` AS `ACTIVITY_TYPE_CODE`,
               `negotiation_activity`.`START_DATE` AS `START_DATE`,
               `negotiation_activity`.`END_DATE` AS `END_DATE`,
               `negotiation_activity`.`CREATE_DATE` AS `CREATE_DATE`,
               `negotiation_activity`.`FOLLOWUP_DATE` AS `FOLLOWUP_DATE`,
               `negotiation_activity`.`DESCRIPTION` AS `DESCRIPTION`,
               `negotiation_activity`.`RESTRICTED` AS `RESTRICTED`,
               `negotiation_activity`.`UPDATE_TIMESTAMP` AS `UPDATE_TIMESTAMP`,
               `negotiation_activity`.`UPDATE_USER` AS `UPDATE_USER` 
            from
               `negotiation_activity` 
            where
               (
                  `negotiation_activity`.`UPDATE_TIMESTAMP`,
                  `negotiation_activity`.`NEGOTIATION_ID`
               )
               in 
               (
                  select
                     max(`negotiation_activity`.`UPDATE_TIMESTAMP`),
                     `negotiation_activity`.`NEGOTIATION_ID` 
                  from
                     `negotiation_activity` 
                  group by
                     `negotiation_activity`.`NEGOTIATION_ID`
               )
         )
         `neg_act` 
         on((`neg_act`.`NEGOTIATION_ID` = `neg_aso`.`NEGOTIATION_ID`))) 
      left join
         (
            select
               `negotiation_location`.`NEGOTIATION_LOCATION_ID` AS `NEGOTIATION_LOCATION_ID`,
               `negotiation_location`.`NEGOTIATION_ID` AS `NEGOTIATION_ID`,
               `negotiation_location`.`LOCATION_TYPE_CODE` AS `LOCATION_TYPE_CODE`,
               `negotiation_location`.`UPDATE_TIMESTAMP` AS `UPDATE_TIMESTAMP`,
               `negotiation_location`.`UPDATE_USER` AS `UPDATE_USER`,
               `negotiation_location`.`ASSIGNEE_PERSON_ID` AS `ASSIGNEE_PERSON_ID`,
               `negotiation_location`.`CREATE_TIMESTAMP` AS `CREATE_TIMESTAMP`,
               `negotiation_location`.`REVIEW_START_DATE` AS `REVIEW_START_DATE`,
               `negotiation_location`.`REVIEW_END_DATE` AS `REVIEW_END_DATE`,
               `negotiation_location`.`CREATE_USER` AS `CREATE_USER`,
               `negotiation_location`.`LOCATION_STATUS_CODE` AS `LOCATION_STATUS_CODE`,
               `negotiation_location`.`DESCRIPTION` AS `DESCRIPTION`,
               (
(to_days(ifnull(`negotiation_location`.`REVIEW_END_DATE`, utc_date())) - to_days(`negotiation_location`.`REVIEW_START_DATE`)) + 1
               )
               AS `DAYS_IN_LOCATION` 
            from
               `negotiation_location` 
            where
               `negotiation_location`.`NEGOTIATION_LOCATION_ID` in 
               (
                  select
                     max(`negotiation_location`.`NEGOTIATION_LOCATION_ID`) 
                  from
                     `negotiation_location` 
                  group by
                     `negotiation_location`.`NEGOTIATION_ID`
               )
         )
         `neg_loc` 
         on((`neg_loc`.`NEGOTIATION_ID` = `neg_aso`.`NEGOTIATION_ID`))) 
      left join
         `negotiation_location_type` `loc_type` 
         on((`loc_type`.`LOCATION_TYPE_CODE` = `neg_loc`.`LOCATION_TYPE_CODE`))) 
      left join
         `currency` `cur` 
         on((`cur`.`CURRENCY_CODE` = `ah`.`CURRENCY_CODE`))
   )
;

