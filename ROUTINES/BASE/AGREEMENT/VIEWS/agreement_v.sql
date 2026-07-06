-- agreement_v;

CREATE VIEW `agreement_v` AS 
select distinct
   `t1`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
   `t1`.`CATEGORY_CODE` AS `CATEGORY_CODE`,
   `t2`.`DESCRIPTION` AS `CATEGORY`,
   `t1`.`AGREEMENT_TYPE_CODE` AS `AGREEMENT_TYPE_CODE`,
   `t3`.`DESCRIPTION` AS `AGREEMENT_TYPE`,
   `t1`.`AGREEMENT_STATUS_CODE` AS `AGREEMENT_STATUS_CODE`,
   `t1`.`AGREEMENT_SEQUENCE_STATUS` AS `AGREEMENT_SEQUENCE_STATUS`,
   (
      case
         when
            (
               `t1`.`IS_HOLD` = 'Y'
            )
         then
            concat(`t4`.`DESCRIPTION`, ' - ', 'Info Requested') 
         else
            `t4`.`DESCRIPTION` 
      end
   )
   AS `AGREEMENT_STATUS`, `t1`.`UNIT_NUMBER` AS `UNIT_NUMBER`, `t5`.`unit_name` AS `UNIT_NAME`, `t5`.`DISPLAY_NAME` AS `UNIT_DISPLAY_NAME`, `t1`.`TITLE` AS `TITLE`, `t1`.`CURRENCY_CODE` AS `CURRENCY_CODE`, `t1`.`CONTRACT_VALUE` AS `CONTRACT_VALUE`, date_format(`t1`.`START_DATE`, '%m/%d/%Y') AS `START_DATE`, date_format(`t1`.`END_DATE`, '%m/%d/%Y') AS `END_DATE`, `t1`.`REQUESTOR_PERSON_ID` AS `REQUESTOR_PERSON_ID`, `t1`.`AMOUNT_IN_WORDS` AS `AMOUNT_IN_WORDS`, `t1`.`REMARKS` AS `REMARKS`, `t12`.`NEGOTIATION_ID` AS `NEGOTIATION_ID`, `t13`.`LOCATION_DETAILS` AS `LOCATION_DETAILS`, `t59`.`DESCRIPTION` AS `NEGO_ACTIVITY_COMMENT`, `t13`.`NEGO_LOCATION_TYPE` AS `NEGO_LOCATION_TYPE`, `t16`.`VERSION_NUMBER` AS `VERSION_NUMBER`, `t16`.`UPDATE_TIMESTAMP` AS `AGREEMENT_GENERATED_DATE`, `pr1`.`PERSON_ID` AS `HOD_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr2`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr2`.`LAST_NAME`)) AS `HOD_PERSON_NAME`, `pr2`.`PRIMARY_TITLE` AS `HOD_PERSON_DESIGNATION`, `t17`.`DESCRIPTION` AS `PERSON_ROLE`, `t19`.`INSTITUTIONAL_PERSON_ID` AS `IP_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr3`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr3`.`LAST_NAME`)) AS `IP_FULL_NAME`, `pr3`.`EMAIL_ADDRESS` AS `IP_EMAIL_ADDRESS`, `t20`.`NEGOTIATOR_PERSON_ID` AS `NEGOTIATOR_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr4`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr4`.`LAST_NAME`)) AS `NEGOTIATOR_PERSON_NAME`, `pr4`.`FULL_NAME` AS `NEGOTIATOR_PERSON_FULL_NAME`, `pr4`.`EMAIL_ADDRESS` AS `NEGOTIATOR_EMAIL_ADDRESS`, concat(trim(trailing ' ' 
from
   `t6`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `t6`.`LAST_NAME`)) AS `REQUESTOR_NAME`, `t6`.`FULL_NAME` AS `REQUESTOR_FULL_NAME`, `t21`.`LEGAL_PERSON_ID` AS `LEGAL_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr5`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr5`.`LAST_NAME`)) AS `LEGAL_PERSON_FULL_NAME`, `t22`.`PRINCIPAL_PERSON_ID` AS `PRINCIPAL_PERSON_ID`, `pr6`.`FULL_NAME` AS `PRINCIPAL_PERSON_FULL_NAME`, `pr6`.`FULL_NAME` AS `PI_PERSON_FULL_NAME`, `pr6`.`LAST_NAME` AS `PRINCIPAL_PERSON_LAST_NAME`, `pr5`.`EMAIL_ADDRESS` AS `LEGAL_EMAIL_ADDRESS`, `pr6`.`EMAIL_ADDRESS` AS `PI_EMAIL_ADDRESS`, `t23`.`CATALYST_PERSON_ID` AS `CATALYST_PERSON_ID`, `t13`.`FULL_NAME` AS `ASSIGNEE_PERSON_FULL_NAME`, concat(trim(trailing ' ' 
from
   `pr23`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr23`.`LAST_NAME`)) AS `CATALYST_FULL_NAME`, `pr23`.`FULL_NAME` AS `CATALYST_PERSON_FULL_NAME`, `t24`.`STO_PERSON_ID` AS `STO_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr24`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr24`.`LAST_NAME`)) AS `STO_FULL_NAME`, `pr24`.`FULL_NAME` AS `STO_PERSON_FULL_NAME`, `t25`.`CA_PERSON_ID` AS `CA_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr25`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr25`.`LAST_NAME`)) AS `CA_FULL_NAME`, `pr25`.`FULL_NAME` AS `CA_PERSON_FULL_NAME`, `t26`.`AA_PERSON_ID` AS `AA_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr26`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr26`.`LAST_NAME`)) AS `AA_FULL_NAME`, `pr35`.`FULL_NAME` AS `AA_PERSON_FULL_NAME`, `t27`.`TLO_PERSON_ID` AS `TLO_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr27`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr27`.`LAST_NAME`)) AS `TLO_FULL_NAME`, `pr27`.`FULL_NAME` AS `TLO_PERSON_FULL_NAME`, `t28`.`AM_PERSON_ID` AS `AM_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr28`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr28`.`LAST_NAME`)) AS `AM_FULL_NAME`, `t29`.`GM_PERSON_ID` AS `GM_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr29`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr29`.`LAST_NAME`)) AS `GM_FULL_NAME`, `t30`.`AO_PERSON_ID` AS `AO_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr30`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr30`.`LAST_NAME`)) AS `AO_FULL_NAME`, `t31`.`FO_PERSON_ID` AS `FO_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr31`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr31`.`LAST_NAME`)) AS `FO_FULL_NAME`, `t32`.`RESEARCHER_PERSON_ID` AS `RESEARCHER_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr32`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr32`.`LAST_NAME`)) AS `RESEARCHER_FULL_NAME`, `t33`.`FACULTY_PERSON_ID` AS `FACULTY_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr33`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr33`.`LAST_NAME`)) AS `FACULTY_FULL_NAME`, `t34`.`STUDENT_PERSON_ID` AS `STUDENT_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr34`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr34`.`LAST_NAME`)) AS `STUDENT_FULL_NAME`, `pr24`.`EMAIL_ADDRESS` AS `STO_EMAIL_ADDRESS`, `pr25`.`EMAIL_ADDRESS` AS `CA_EMAIL_ADDRESS`, `pr26`.`EMAIL_ADDRESS` AS `AA_EMAIL_ADDRESS`, `pr27`.`EMAIL_ADDRESS` AS `TLO_EMAIL_ADDRESS`, `pr28`.`EMAIL_ADDRESS` AS `AM_EMAIL_ADDRESS`, `pr29`.`EMAIL_ADDRESS` AS `GM_EMAIL_ADDRESS`, `pr30`.`EMAIL_ADDRESS` AS `AO_EMAIL_ADDRESS`, `pr31`.`EMAIL_ADDRESS` AS `FO_EMAIL_ADDRESS`, `pr32`.`EMAIL_ADDRESS` AS `RESEARCHER_EMAIL_ADDRESS`, `pr33`.`EMAIL_ADDRESS` AS `FACULTY_EMAIL_ADDRESS`, `pr34`.`EMAIL_ADDRESS` AS `STUDENT_EMAIL_ADDRESS`, `pr23`.`EMAIL_ADDRESS` AS `CATALYST_EMAIL_ADDRESS`, `t35`.`SPONSOR_NAME` AS `SPONSOR_NAME`, `t36`.`DISPLAY_NAME` AS `SPONSOR_DISPLAY_NAME`, `t36`.`ADDRESS_LINE_1` AS `ADDRESS_LINE_1`, `t36`.`ADDRESS_LINE_2` AS `ADDRESS_LINE_2`, `t36`.`SPONSOR_LOCATION` AS `SPONSOR_LOCATION`, `t36`.`POSTAL_CODE` AS `ZIP`, `t36`.`STATE` AS `STATE`, `t37`.`DESCRIPTION` AS `SPONSOR_TYPE_NAME`, `t38`.`COUNTRY_NAME` AS `COUNTRY_NAME`, `t39`.`DESCRIPTION` AS `SPONSOR_ROLE`, `t40`.`CONTACT_EMAIL_ID` AS `PRIMARY_CONTACT_PERSON_EMAIL`, `t40`.`CONTACT_PERSON_NAME` AS `PRIMARY_CONTACT_PERSON_NAME`, `t41`.`CONTACT_EMAIL_ID` AS `TECHNICAL_CONTACT_PERSON_EMAIL`, `t41`.`CONTACT_PERSON_NAME` AS `TECHNICAL_CONTACT_PERSON_NAME`, `t42`.`CONTACT_EMAIL_ID` AS `LEGAL_CONTACT_PERSON_EMAIL`, `t42`.`CONTACT_PERSON_NAME` AS `LEGAL_CONTACT_PERSON_NAME`, `t43`.`REVIEW_STATUS_CODE` AS `REVIEW_STATUS_CODE`, `t43`.`DESCRIPTION` AS `REVIEW_STATUS`, `t47`.`UPDATE_TIMESTAMP` AS `SUBMISSION_DATE`, `t1`.`ADMIN_PERSON_ID` AS `ADMIN_PERSON_ID`, concat(trim(trailing ' ' 
from
   `pr35`.`FIRST_NAME`), ' ', trim(leading ' ' 
from
   `pr35`.`LAST_NAME`)) AS `ADMIN_FULL_NAME`, `pr35`.`EMAIL_ADDRESS` AS `ADMIN_EMAIL_ADDRESS`, `t1`.`START_DATE` AS `AGREEMENT_START_DATE`, `t1`.`END_DATE` AS `AGREEMENT_END_DATE`, `t49`.`KEYWORD` AS `KEYWORD`, `t58`.`ADMIN_GROUP_NAME` AS `ADMIN_GROUP_NAME` 
from
   (
((((((((((((((((((((((((((((((((((((((((((((((((((((((((`agreement_header` `t1` 
      left join
         `agreement_category` `t2` 
         on((`t1`.`CATEGORY_CODE` = `t2`.`CATEGORY_CODE`))) 
      left join
         `agreement_type` `t3` 
         on((`t3`.`AGREEMENT_TYPE_CODE` = `t1`.`AGREEMENT_TYPE_CODE`))) 
      left join
         `agreement_status` `t4` 
         on((`t4`.`AGREEMENT_STATUS_CODE` = `t1`.`AGREEMENT_STATUS_CODE`))) 
      left join
         `unit` `t5` 
         on((`t5`.`UNIT_NUMBER` = `t1`.`UNIT_NUMBER`))) 
      left join
         `person` `t6` 
         on((`t6`.`PERSON_ID` = `t1`.`REQUESTOR_PERSON_ID`))) 
      left join
         `admin_group` `t58` 
         on((`t58`.`ADMIN_GROUP_ID` = `t1`.`ADMIN_GROUP_ID`))) 
      left join
         (
            select
               `ap`.`PERSON_ID` AS `INSTITUTIONAL_PERSON_ID`,
               `ap`.`FULL_NAME` AS `INSTITUTIONAL_PERSON_FULL_NAME`,
               `ap`.`PEOPLE_TYPE_ID` AS `INSTITUTIONAL_PEOPLE_TYPE_CODE`,
               `ap`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID`,
               `ap`.`PI_PERSONNEL_TYPE_CODE` AS `PI_PERSONNEL_TYPE_CODE` 
            from
               `agreement_people` `ap` 
            where
               `ap`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 1
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t19` 
         on((`t19`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         `negotiation_association` `t12` 
         on(((`t12`.`ASSOCIATED_PROJECT_ID` = `t1`.`AGREEMENT_REQUEST_ID`) 
         and 
         (
            `t12`.`ASSOCIATION_TYPE_CODE` = 4
         )
))) 
      left join
         (
            select
               `s1`.`NEGOTIATION_LOCATION_ID` AS `NEGOTIATION_LOCATION_ID`,
               `s1`.`NEGOTIATION_ID` AS `NEGOTIATION_ID`,
               `t14`.`DESCRIPTION` AS `NEGO_LOCATION_TYPE`,
               `pr36`.`FULL_NAME` AS `FULL_NAME`,
               `loc`.`LOCATION_DETAILS` AS `LOCATION_DETAILS` 
            from
               (
(((`negotiation_location` `s1` 
                  join
                     `negotiation_location_type` `t14` 
                     on((`t14`.`LOCATION_TYPE_CODE` = `s1`.`LOCATION_TYPE_CODE`))) 
                  join
                     `negotiation_location_status` `t15` 
                     on((`t15`.`LOCATION_STATUS_CODE` = `s1`.`LOCATION_STATUS_CODE`))) 
                  left join
                     `person` `pr36` 
                     on((`pr36`.`PERSON_ID` = `s1`.`ASSIGNEE_PERSON_ID`))) 
                  join
                     (
                        select
                           `s2`.`NEGOTIATION_ID` AS `NEGOTIATION_ID`,
                           group_concat(concat(`t14`.`DESCRIPTION`, ' (', if((`pr36`.`FULL_NAME` is not null), concat(`pr36`.`FULL_NAME`, ' - '), ''), if((`t15`.`DESCRIPTION` is not null), concat(`t15`.`DESCRIPTION`, ''), ''), ')') separator '; ') AS `LOCATION_DETAILS` 
                        from
                           (
((`negotiation_location` `s2` 
                              join
                                 `negotiation_location_type` `t14` 
                                 on((`t14`.`LOCATION_TYPE_CODE` = `s2`.`LOCATION_TYPE_CODE`))) 
                              join
                                 `negotiation_location_status` `t15` 
                                 on((`t15`.`LOCATION_STATUS_CODE` = `s2`.`LOCATION_STATUS_CODE`))) 
                              left join
                                 `person` `pr36` 
                                 on((`pr36`.`PERSON_ID` = `s2`.`ASSIGNEE_PERSON_ID`))
                           )
                        group by
                           `s2`.`NEGOTIATION_ID`
                     )
                     `loc` 
                     on((`loc`.`NEGOTIATION_ID` = `s1`.`NEGOTIATION_ID`))
               )
         )
         `t13` 
         on((`t13`.`NEGOTIATION_ID` = `t12`.`NEGOTIATION_ID`))) 
      left join
         (
            select
               `s1`.`DESCRIPTION` AS `DESCRIPTION`,
               `s1`.`NEGOTIATION_ID` AS `NEGOTIATION_ID` 
            from
               `negotiation_activity` `s1` 
            where
               `s1`.`NEGOTIATION_ACTIVITY_ID` in 
               (
                  select
                     max(`s2`.`NEGOTIATION_ACTIVITY_ID`) 
                  from
                     `negotiation_activity` `s2` 
                  where
                     (
                        `s2`.`NEGOTIATION_ID` = `s1`.`NEGOTIATION_ID`
                     )
               )
         )
         `t59` 
         on((`t59`.`NEGOTIATION_ID` = `t12`.`NEGOTIATION_ID`))) 
      left join
         (
            select
               `a1`.`VERSION_NUMBER` AS `VERSION_NUMBER`,
               `a1`.`UPDATE_TIMESTAMP` AS `UPDATE_TIMESTAMP`,
               `a1`.`AGREEMENT_ATTACHMENT_TYPE_CODE` AS `AGREEMENT_ATTACHMENT_TYPE_CODE`,
               `a1`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID` 
            from
               `agreement_attachment` `a1` 
            where
               `a1`.`AGREEMENT_ATTACHMENT_ID` in 
               (
                  select
                     max(`a2`.`AGREEMENT_ATTACHMENT_ID`) 
                  from
                     `agreement_attachment` `a2` 
                  where
                     (
(`a2`.`AGREEMENT_REQUEST_ID` = `a1`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `a2`.`AGREEMENT_ATTACHMENT_TYPE_CODE` = 4
                        )
                        and `a2`.`VERSION_NUMBER` in 
                        (
                           select
                              max(`a3`.`VERSION_NUMBER`) 
                           from
                              `agreement_attachment` `a3` 
                           where
                              (
                                 `a3`.`AGREEMENT_REQUEST_ID` = `a2`.`AGREEMENT_REQUEST_ID`
                              )
                        )
                     )
               )
         )
         `t16` 
         on((`t16`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `person_roles`.`UNIT_NUMBER` AS `UNIT_NUMBER`,
               `person_roles`.`PERSON_ID` AS `PERSON_ID` 
            from
               `person_roles` 
            where
               (
(`person_roles`.`ROLE_ID` = 400) 
                  and 
                  (
                     `person_roles`.`UNIT_NUMBER` is not null
                  )
               )
            group by
               `person_roles`.`UNIT_NUMBER`
         )
         `pr1` 
         on((`pr1`.`UNIT_NUMBER` = `t1`.`UNIT_NUMBER`))) 
      left join
         `person` `pr2` 
         on((`pr2`.`PERSON_ID` = `pr1`.`PERSON_ID`))) 
      left join
         `person` `pr3` 
         on((`pr3`.`PERSON_ID` = `t19`.`INSTITUTIONAL_PERSON_ID`))) 
      left join
         `negotiation_personnel_type` `t17` 
         on((`t19`.`PI_PERSONNEL_TYPE_CODE` = `t17`.`PERSONNEL_TYPE_CODE`))) 
      left join
         (
            select
               `ap2`.`PERSON_ID` AS `NEGOTIATOR_PERSON_ID`,
               `ap2`.`FULL_NAME` AS `NEGOTIATOR_PERSON_NAME`,
               `ap2`.`PEOPLE_TYPE_ID` AS `NEGOTIATOR_PEOPLE_TYPE_CODE`,
               `ap2`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap2`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap2` 
            where
               `ap2`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap3`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap3` 
                  where
                     (
(`ap3`.`AGREEMENT_REQUEST_ID` = `ap2`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap3`.`PEOPLE_TYPE_ID` = 2
                        )
                        and 
                        (
                           `ap3`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t20` 
         on((`t20`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         `person` `pr4` 
         on((`pr4`.`PERSON_ID` = `t20`.`NEGOTIATOR_PERSON_ID`))) 
      left join
         (
            select
               `ap3`.`PERSON_ID` AS `LEGAL_PERSON_ID`,
               `ap3`.`FULL_NAME` AS `LEGAL_PERSON_FULL_NAME`,
               `ap3`.`PEOPLE_TYPE_ID` AS `LEGAL_PEOPLE_TYPE_CODE`,
               `ap3`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap3`.`AGREEMENT_PEOPLE_ID` AS `LEGAL_PEOPLE_ID` 
            from
               `agreement_people` `ap3` 
            where
               `ap3`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap3`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 4
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t21` 
         on((`t21`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap4`.`PERSON_ID` AS `PRINCIPAL_PERSON_ID`,
               `ap4`.`FULL_NAME` AS `PRINCIPAL_PERSON_FULL_NAME`,
               `ap4`.`PEOPLE_TYPE_ID` AS `PRINCIPAL_PEOPLE_TYPE_CODE`,
               `ap4`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap4`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap4` 
            where
               `ap4`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap4`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 3
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t22` 
         on((`t22`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         `person` `pr5` 
         on((`pr5`.`PERSON_ID` = `t21`.`LEGAL_PERSON_ID`))) 
      left join
         `person` `pr6` 
         on((`pr6`.`PERSON_ID` = `t22`.`PRINCIPAL_PERSON_ID`))) 
      left join
         (
            select
               `ap5`.`PERSON_ID` AS `CATALYST_PERSON_ID`,
               `ap5`.`FULL_NAME` AS `CATALYST_FULL_NAME`,
               `ap5`.`PEOPLE_TYPE_ID` AS `CATALYST_TYPE_CODE`,
               `ap5`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap5`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap5` 
            where
               `ap5`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap5`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 5
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t23` 
         on((`t23`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap6`.`PERSON_ID` AS `STO_PERSON_ID`,
               `ap6`.`FULL_NAME` AS `STO_FULL_NAME`,
               `ap6`.`PEOPLE_TYPE_ID` AS `STO_TYPE_CODE`,
               `ap6`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap6`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap6` 
            where
               `ap6`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap6`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 6
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t24` 
         on((`t24`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap7`.`PERSON_ID` AS `CA_PERSON_ID`,
               `ap7`.`FULL_NAME` AS `CA_FULL_NAME`,
               `ap7`.`PEOPLE_TYPE_ID` AS `CA_TYPE_CODE`,
               `ap7`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap7`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap7` 
            where
               `ap7`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap7`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 7
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t25` 
         on((`t25`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap8`.`PERSON_ID` AS `AA_PERSON_ID`,
               `ap8`.`FULL_NAME` AS `AA_FULL_NAME`,
               `ap8`.`PEOPLE_TYPE_ID` AS `AA_TYPE_CODE`,
               `ap8`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap8`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap8` 
            where
               `ap8`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap8`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 8
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t26` 
         on((`t26`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap9`.`PERSON_ID` AS `TLO_PERSON_ID`,
               `ap9`.`FULL_NAME` AS `TLO_FULL_NAME`,
               `ap9`.`PEOPLE_TYPE_ID` AS `TLO_TYPE_CODE`,
               `ap9`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap9`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap9` 
            where
               `ap9`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap9`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 9
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t27` 
         on((`t27`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap10`.`PERSON_ID` AS `AM_PERSON_ID`,
               `ap10`.`FULL_NAME` AS `AM_FULL_NAME`,
               `ap10`.`PEOPLE_TYPE_ID` AS `AM_TYPE_CODE`,
               `ap10`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap10`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap10` 
            where
               `ap10`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap10`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 10
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t28` 
         on((`t28`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap11`.`PERSON_ID` AS `GM_PERSON_ID`,
               `ap11`.`FULL_NAME` AS `GM_FULL_NAME`,
               `ap11`.`PEOPLE_TYPE_ID` AS `GM_TYPE_CODE`,
               `ap11`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap11`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap11` 
            where
               `ap11`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap11`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 11
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t29` 
         on((`t29`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap12`.`PERSON_ID` AS `AO_PERSON_ID`,
               `ap12`.`FULL_NAME` AS `AO_FULL_NAME`,
               `ap12`.`PEOPLE_TYPE_ID` AS `AO_TYPE_CODE`,
               `ap12`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap12`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap12` 
            where
               `ap12`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap12`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 12
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t30` 
         on((`t30`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap13`.`PERSON_ID` AS `FO_PERSON_ID`,
               `ap13`.`FULL_NAME` AS `FO_FULL_NAME`,
               `ap13`.`PEOPLE_TYPE_ID` AS `FO_TYPE_CODE`,
               `ap13`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap13`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap13` 
            where
               `ap13`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap13`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 13
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t31` 
         on((`t31`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap14`.`PERSON_ID` AS `RESEARCHER_PERSON_ID`,
               `ap14`.`FULL_NAME` AS `RESEARCHER_FULL_NAME`,
               `ap14`.`PEOPLE_TYPE_ID` AS `RESEARCHER_TYPE_CODE`,
               `ap14`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap14`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap14` 
            where
               `ap14`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap14`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 14
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t32` 
         on((`t32`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               trim(trailing '|' 
            from
               group_concat(`sk`.`DESCRIPTION` separator '| ')) AS `KEYWORD`,
               `ak`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID` 
            from
               (
                  `agreement_keywords` `ak` 
                  join
                     `science_keyword` `sk` 
                     on((`ak`.`SCIENCE_KEYWORD_CODE` = `sk`.`SCIENCE_KEYWORD_CODE`))
               )
            group by
               `ak`.`AGREEMENT_REQUEST_ID`
         )
         `t49` 
         on((`t1`.`AGREEMENT_REQUEST_ID` = `t49`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap15`.`PERSON_ID` AS `FACULTY_PERSON_ID`,
               `ap15`.`FULL_NAME` AS `FACULTY_FULL_NAME`,
               `ap15`.`PEOPLE_TYPE_ID` AS `FACULTY_TYPE_CODE`,
               `ap15`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap15`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap15` 
            where
               `ap15`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap15`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 15
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t33` 
         on((`t33`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         (
            select
               `ap16`.`PERSON_ID` AS `STUDENT_PERSON_ID`,
               `ap16`.`FULL_NAME` AS `STUDENT_FULL_NAME`,
               `ap16`.`PEOPLE_TYPE_ID` AS `STUDENT_TYPE_CODE`,
               `ap16`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `ap16`.`AGREEMENT_PEOPLE_ID` AS `AGREEMENT_PEOPLE_ID` 
            from
               `agreement_people` `ap16` 
            where
               `ap16`.`AGREEMENT_PEOPLE_ID` in 
               (
                  select
                     max(`ap1`.`AGREEMENT_PEOPLE_ID`) 
                  from
                     `agreement_people` `ap1` 
                  where
                     (
(`ap1`.`AGREEMENT_REQUEST_ID` = `ap16`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `ap1`.`PEOPLE_TYPE_ID` = 16
                        )
                        and 
                        (
                           `ap1`.`PERSON_ID` is not null
                        )
                     )
               )
         )
         `t34` 
         on((`t34`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         `person` `pr23` 
         on((`pr23`.`PERSON_ID` = `t23`.`CATALYST_PERSON_ID`))) 
      left join
         `person` `pr24` 
         on((`pr24`.`PERSON_ID` = `t24`.`STO_PERSON_ID`))) 
      left join
         `person` `pr25` 
         on((`pr25`.`PERSON_ID` = `t25`.`CA_PERSON_ID`))) 
      left join
         `person` `pr26` 
         on((`pr26`.`PERSON_ID` = `t26`.`AA_PERSON_ID`))) 
      left join
         `person` `pr27` 
         on((`pr27`.`PERSON_ID` = `t27`.`TLO_PERSON_ID`))) 
      left join
         `person` `pr28` 
         on((`pr28`.`PERSON_ID` = `t28`.`AM_PERSON_ID`))) 
      left join
         `person` `pr29` 
         on((`pr29`.`PERSON_ID` = `t29`.`GM_PERSON_ID`))) 
      left join
         `person` `pr30` 
         on((`pr30`.`PERSON_ID` = `t30`.`AO_PERSON_ID`))) 
      left join
         `person` `pr31` 
         on((`pr31`.`PERSON_ID` = `t31`.`FO_PERSON_ID`))) 
      left join
         `person` `pr32` 
         on((`pr32`.`PERSON_ID` = `t32`.`RESEARCHER_PERSON_ID`))) 
      left join
         `person` `pr33` 
         on((`pr33`.`PERSON_ID` = `t33`.`FACULTY_PERSON_ID`))) 
      left join
         `person` `pr34` 
         on((`pr34`.`PERSON_ID` = `t34`.`STUDENT_PERSON_ID`))) 
      left join
         (
            select
               `as1`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
               `as1`.`SPONSOR_NAME` AS `SPONSOR_NAME`,
               `as1`.`SPONSOR_ROLE_TYPE_CODE` AS `SPONSOR_ROLE_TYPE_CODE`,
               `as1`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `as1`.`AGREEMENT_SPONSOR_ID` AS `AGREEMENT_SPONSOR_ID` 
            from
               `agreement_sponsor` `as1` 
            where
               `as1`.`AGREEMENT_SPONSOR_ID` in 
               (
                  select
                     max(`as0`.`AGREEMENT_SPONSOR_ID`) 
                  from
                     `agreement_sponsor` `as0` 
                  where
                     (
(`as0`.`AGREEMENT_REQUEST_ID` = `as1`.`AGREEMENT_REQUEST_ID`) 
                        and 
                        (
                           `as0`.`AGREEMENT_SPONSOR_TYPE_CODE` = 1
                        )
                     )
               )
         )
         `t35` 
         on((`t35`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`))) 
      left join
         `sponsor` `t36` 
         on((`t36`.`SPONSOR_CODE` = `t35`.`SPONSOR_CODE`))) 
      left join
         `sponsor_type` `t37` 
         on((`t37`.`SPONSOR_TYPE_CODE` = `t36`.`SPONSOR_TYPE_CODE`))) 
      left join
         `country` `t38` 
         on((`t36`.`COUNTRY_CODE` = `t38`.`COUNTRY_CODE`))) 
      left join
         `sponsor_role` `t39` 
         on((`t39`.`SPONSOR_ROLE_TYPE_CODE` = `t35`.`SPONSOR_ROLE_TYPE_CODE`))) 
      left join
         `agreement_review_status` `t43` 
         on(((`t43`.`REVIEW_STATUS_CODE` = `t1`.`REVIEW_STATUS_CODE`) 
         and 
         (
            `t43`.`IS_ACTIVE` = 'Y'
         )
))) 
      left join
         (
            select
               `asc1`.`AGREEMENT_SPONSOR_CONTACT_ID` AS `AGREEMENT_SPONSOR_CONTACT_ID`,
               `asc1`.`AGREEMENT_SPONSOR_ID` AS `AGREEMENT_SPONSOR_ID`,
               `asc1`.`CONTACT_EMAIL_ID` AS `CONTACT_EMAIL_ID`,
               `asc1`.`CONTACT_PERSON_NAME` AS `CONTACT_PERSON_NAME` 
            from
               `agreement_sponsor_contact` `asc1` 
            where
               `asc1`.`AGREEMENT_SPONSOR_CONTACT_ID` in 
               (
                  select
                     max(`asc2`.`AGREEMENT_SPONSOR_CONTACT_ID`) 
                  from
                     `agreement_sponsor_contact` `asc2` 
                  where
                     (
(`asc2`.`AGREEMENT_SPONSOR_ID` = `asc1`.`AGREEMENT_SPONSOR_ID`) 
                        and 
                        (
                           `asc2`.`SPONSOR_CONTCT_TYPE_CODE` = 1
                        )
                     )
               )
         )
         `t40` 
         on((`t40`.`AGREEMENT_SPONSOR_ID` = `t35`.`AGREEMENT_SPONSOR_ID`))) 
      left join
         (
            select
               `asc1`.`AGREEMENT_SPONSOR_CONTACT_ID` AS `AGREEMENT_SPONSOR_CONTACT_ID`,
               `asc1`.`AGREEMENT_SPONSOR_ID` AS `AGREEMENT_SPONSOR_ID`,
               `asc1`.`CONTACT_EMAIL_ID` AS `CONTACT_EMAIL_ID`,
               `asc1`.`CONTACT_PERSON_NAME` AS `CONTACT_PERSON_NAME` 
            from
               `agreement_sponsor_contact` `asc1` 
            where
               `asc1`.`AGREEMENT_SPONSOR_CONTACT_ID` in 
               (
                  select
                     max(`asc2`.`AGREEMENT_SPONSOR_CONTACT_ID`) 
                  from
                     `agreement_sponsor_contact` `asc2` 
                  where
                     (
(`asc2`.`AGREEMENT_SPONSOR_ID` = `asc1`.`AGREEMENT_SPONSOR_ID`) 
                        and 
                        (
                           `asc2`.`SPONSOR_CONTCT_TYPE_CODE` = 2
                        )
                     )
               )
         )
         `t41` 
         on((`t41`.`AGREEMENT_SPONSOR_ID` = `t35`.`AGREEMENT_SPONSOR_ID`))) 
      left join
         (
            select
               `asc1`.`AGREEMENT_SPONSOR_CONTACT_ID` AS `AGREEMENT_SPONSOR_CONTACT_ID`,
               `asc1`.`AGREEMENT_SPONSOR_ID` AS `AGREEMENT_SPONSOR_ID`,
               `asc1`.`CONTACT_EMAIL_ID` AS `CONTACT_EMAIL_ID`,
               `asc1`.`CONTACT_PERSON_NAME` AS `CONTACT_PERSON_NAME` 
            from
               `agreement_sponsor_contact` `asc1` 
            where
               `asc1`.`AGREEMENT_SPONSOR_CONTACT_ID` in 
               (
                  select
                     max(`asc2`.`AGREEMENT_SPONSOR_CONTACT_ID`) 
                  from
                     `agreement_sponsor_contact` `asc2` 
                  where
                     (
(`asc2`.`AGREEMENT_SPONSOR_ID` = `asc1`.`AGREEMENT_SPONSOR_ID`) 
                        and 
                        (
                           `asc2`.`SPONSOR_CONTCT_TYPE_CODE` = 3
                        )
                     )
               )
         )
         `t42` 
         on((`t42`.`AGREEMENT_SPONSOR_ID` = `t35`.`AGREEMENT_SPONSOR_ID`))) 
      left join
         `person` `pr35` 
         on((`pr35`.`PERSON_ID` = `t1`.`ADMIN_PERSON_ID`))) 
      left join
         (
            select
               `t1`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`,
               `t1`.`UPDATE_TIMESTAMP` AS `UPDATE_TIMESTAMP` 
            from
               `agreement_action_log` `t1` 
            where
               (
(`t1`.`ACTION_TYPE_CODE` in 
                  (
                     2,
                     20
                  )
) 
                  and 
                  (
                     `t1`.`ACTION_LOG_ID` = 
                     (
                        select
                           min(`agreement_action_log`.`ACTION_LOG_ID`) 
                        from
                           `agreement_action_log` 
                        where
                           (
(`agreement_action_log`.`AGREEMENT_REQUEST_ID` = `t1`.`AGREEMENT_REQUEST_ID`) 
                              and 
                              (
                                 `agreement_action_log`.`ACTION_TYPE_CODE` in 
                                 (
                                    2,
                                    20
                                 )
                              )
                           )
                     )
                  )
               )
         )
         `t47` 
         on((`t1`.`AGREEMENT_REQUEST_ID` = `t47`.`AGREEMENT_REQUEST_ID`))
   )
;

