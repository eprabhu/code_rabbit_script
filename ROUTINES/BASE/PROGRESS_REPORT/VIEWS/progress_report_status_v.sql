


-- progress_report_status_v;

CREATE VIEW `progress_report_status_v` AS 
select
   `t1`.`AWARD_ID` AS `AWARD_ID`,
   `t1`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`,
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`ACCOUNT_NUMBER` AS `PROJECT_NUMBER`,
   `t1`.`TITLE` AS `AWARD_TITLE`,
   `t1`.`PI_NAME` AS `PI_NAME`,
   `t3`.`REPORT_FREQUENCY` AS `REPORT_FREQUENCY`,
   `t3`.`DUE_DATE` AS `DUE_DATE`,
   `t3`.`REPORT_START_DATE` AS `REPORT_START_DATE`,
   `t3`.`REPORT_END_DATE` AS `REPORT_END_DATE`,
   `t3`.`PROGRESS_REPORT_NUMBER` AS `PROGRESS_REPORT_NUMBER`,
   `t10`.`file_name` AS `FILE_NAME`,
   `t11`.`DESCRIPTION` AS `REPORT_STATUS`,
   `t13`.`DESCRIPTION` AS `GRANT_TYPE` 
from
   (
(((`award_master_dataset_rt` `t1` 
      join
         (
            select
               NULL AS `REPORT_FREQUENCY`,
               `t3`.`DUE_DATE` AS `DUE_DATE`,
               `t3`.`REPORT_START_DATE` AS `REPORT_START_DATE`,
               `t3`.`REPORT_END_DATE` AS `REPORT_END_DATE`,
               `t3`.`PROGRESS_REPORT_NUMBER` AS `PROGRESS_REPORT_NUMBER`,
               NULL AS `SEQUENCE_NUMBER`,
               `t3`.`AWARD_ID` AS `AWARD_ID`,
               `t3`.`PROGRESS_REPORT_ID` AS `PROGRESS_REPORT_ID`,
               `t3`.`PROGRESS_REPORT_STATUS_CODE` AS `PROGRESS_REPORT_STATUS_CODE` 
            from
               `award_progress_report` `t3` 
            where
               (
(`t3`.`AWARD_REPORT_TRACKING_ID` is null) 
                  and 
                  (
                     `t3`.`REPORT_CLASS_CODE` = 1
                  )
               )
            union
            select
               `t6`.`DESCRIPTION` AS `REPORT_FREQUENCY`,
               `t0`.`DUE_DATE` AS `DUE_DATE`,
               `t3`.`REPORT_START_DATE` AS `REPORT_START_DATE`,
               `t3`.`REPORT_END_DATE` AS `REPORT_END_DATE`,
               `t3`.`PROGRESS_REPORT_NUMBER` AS `PROGRESS_REPORT_NUMBER`,
               `t5`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`,
               `t0`.`AWARD_ID` AS `AWARD_ID`,
               `t0`.`PROGRESS_REPORT_ID` AS `PROGRESS_REPORT_ID`,
               `t3`.`PROGRESS_REPORT_STATUS_CODE` AS `PROGRESS_REPORT_STATUS_CODE` 
            from
               (
((`award_report_tracking` `t0` 
                  join
                     `award_report_terms` `t5` 
                     on((`t0`.`AWARD_REPORT_TERMS_ID` = `t5`.`AWARD_REPORT_TERMS_ID`))) 
                  left join
                     `award_progress_report` `t3` 
                     on(((`t0`.`PROGRESS_REPORT_ID` = `t3`.`PROGRESS_REPORT_ID`) 
                     and 
                     (
                        `t3`.`AWARD_REPORT_TRACKING_ID` is not null
                     )
))) 
                  join
                     `frequency` `t6` 
                     on((`t5`.`FREQUENCY_CODE` = `t6`.`FREQUENCY_CODE`))
               )
            where
               (
(`t5`.`SEQUENCE_NUMBER` = 0) 
                  and 
                  (
                     `t5`.`REPORT_CLASS_CODE` = 1
                  )
               )
         )
         `t3` 
         on((`t1`.`AWARD_ID` = `t3`.`AWARD_ID`))) 
      left join
         `progress_report_status` `t11` 
         on((`t11`.`PROGRESS_REPORT_STATUS_CODE` = `t3`.`PROGRESS_REPORT_STATUS_CODE`))) 
      left join
         `grant_call_type` `t13` 
         on((`t1`.`GRANT_TYPE_CODE` = `t13`.`GRANT_TYPE_CODE`))) 
      left join
         (
            select
               group_concat(' ', `t12`.`FILE_NAME` separator ',') AS `file_name`,
               `t12`.`PROGRESS_REPORT_ID` AS `PROGRESS_REPORT_ID` 
            from
               `award_progress_report_attachment` `t12` 
            where
               (
(`t12`.`DOCUMENT_STATUS_CODE` = 1) 
                  and `t12`.`UPDATE_TIMESTAMP` in 
                  (
                     select
                        max(`award_progress_report_attachment`.`UPDATE_TIMESTAMP`) 
                     from
                        `award_progress_report_attachment` 
                     where
                        (
(`award_progress_report_attachment`.`PROGRESS_REPORT_ID` = `t12`.`PROGRESS_REPORT_ID`) 
                           and 
                           (
                              `award_progress_report_attachment`.`DOCUMENT_STATUS_CODE` = 1
                           )
                        )
                  )
               )
            group by
               `t12`.`PROGRESS_REPORT_ID`
         )
         `t10` 
         on((`t10`.`PROGRESS_REPORT_ID` = `t3`.`PROGRESS_REPORT_ID`))
   )
where
   (
      `t1`.`PERSON_ROLE_ID` = 3
   )
;
