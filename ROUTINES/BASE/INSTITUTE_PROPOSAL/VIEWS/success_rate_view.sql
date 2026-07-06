-- success_rate_view;

CREATE VIEW `success_rate_view` AS 
select
   `t1`.`ALL_PROPOSAL` AS `ALL_PROPOSAL`,
   `t1`.`FULL_NAME` AS `FULL_NAME`,
   `t1`.`UNIT_NAME` AS `UNIT_NAME`,
   ifnull(`t2`.`FUNDED_PROPOSAL`, 0) AS `FUNDED_PROPOSAL`,
   (
(ifnull(`t2`.`FUNDED_PROPOSAL`, 0) / `t1`.`ALL_PROPOSAL`) * 100
   )
   AS `SUCCESS_RATE`,
   `t1`.`PERSON_ID` AS `PERSON_ID`,
   `t1`.`HOME_UNIT_NUMBER` AS `HOME_UNIT_NUMBER` 
from
   (
(
      select
         count(`t1`.`PROPOSAL_NUMBER`) AS `ALL_PROPOSAL`, `t4`.`FULL_NAME` AS `FULL_NAME`, `t3`.`unit_name` AS `UNIT_NAME`, `t1`.`HOME_UNIT_NUMBER` AS `HOME_UNIT_NUMBER`, `t2`.`PERSON_ID` AS `PERSON_ID` 
      from
         (
((`proposal` `t1` 
            join
               `proposal_persons` `t2` 
               on(((`t1`.`PROPOSAL_ID` = `t2`.`PROPOSAL_ID`) 
               and 
               (
                  `t2`.`PROP_PERSON_ROLE_ID` = 3
               )
))) 
            join
               `person` `t4` 
               on((`t2`.`PERSON_ID` = `t4`.`PERSON_ID`))) 
            join
               `unit` `t3` 
               on((`t3`.`UNIT_NUMBER` = `t1`.`HOME_UNIT_NUMBER`))
         )
      where
         `t1`.`SEQUENCE_NUMBER` in 
         (
            select
               max(`s1`.`SEQUENCE_NUMBER`) 
            from
               `proposal` `s1` 
            where
               (
                  `s1`.`PROPOSAL_NUMBER` = `t1`.`PROPOSAL_NUMBER`
               )
         )
      group by
         `t1`.`HOME_UNIT_NUMBER`, `t4`.`FULL_NAME`) `t1` 
         left join
            (
               select
                  count(`t1`.`PROPOSAL_NUMBER`) AS `FUNDED_PROPOSAL`,
                  `t5`.`FULL_NAME` AS `FULL_NAME`,
                  `t3`.`unit_name` AS `UNIT_NAME`,
                  `t1`.`HOME_UNIT_NUMBER` AS `HOME_UNIT_NUMBER`,
                  `t2`.`PERSON_ID` AS `PERSON_ID` 
               from
                  (
((`proposal` `t1` 
                     join
                        `proposal_persons` `t2` 
                        on(((`t1`.`PROPOSAL_ID` = `t2`.`PROPOSAL_ID`) 
                        and 
                        (
                           `t2`.`PROP_PERSON_ROLE_ID` = 3
                        )
))) 
                     join
                        `person` `t5` 
                        on((`t2`.`PERSON_ID` = `t5`.`PERSON_ID`))) 
                     join
                        `unit` `t3` 
                        on((`t3`.`UNIT_NUMBER` = `t1`.`HOME_UNIT_NUMBER`))
                  )
               where
                  (
                     `t1`.`SEQUENCE_NUMBER` in 
                     (
                        select
                           max(`s1`.`SEQUENCE_NUMBER`) 
                        from
                           `proposal` `s1` 
                        where
                           (
                              `s1`.`PROPOSAL_NUMBER` = `t1`.`PROPOSAL_NUMBER`
                           )
                     )
                     and 
                     (
                        `t1`.`STATUS_CODE` = 2
                     )
                  )
               group by
                  `t1`.`HOME_UNIT_NUMBER`,
                  `t5`.`FULL_NAME`
            )
            `t2` 
            on(((`t1`.`PERSON_ID` = `t2`.`PERSON_ID`) 
            and 
            (
               `t1`.`HOME_UNIT_NUMBER` = `t2`.`HOME_UNIT_NUMBER`
            )
))
   )
;

