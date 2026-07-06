CREATE VIEW `SR_ASSOC_DETAIL_V` AS
    SELECT 
        `t`.`SR_HEADER_ID` AS `SR_HEADER_ID`,
        `m`.`DESCRIPTION` AS `MODULE_NAME`,
        `t`.`MODULE_CODE` AS `MODULE_CODE`,
        `t`.`MODULE_ITEM_KEY` AS `MODULE_ITEM_KEY`,
        `t`.`MODULE_ITEM_ID` AS `MODULE_ITEM_ID`,
        `t`.`TITLE` AS `TITLE`,
        `t`.`PI_NAME` AS `PI_NAME`,
        `t`.`PI_PERSON_ID` AS `PI_PERSON_ID`,
        `t`.`PI_ROLODEX_PERSON_ID` AS `PI_ROLODEX_PERSON_ID`,
        `t`.`SPONSOR_CODE` AS `SPONSOR_CODE`,
        `sp`.`DISPLAY_NAME` AS `SPONSOR_NAME`,
        `t`.`START_DATE` AS `START_DATE`,
        `t`.`END_DATE` AS `END_DATE`,
        `t`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`,
        `u`.`DISPLAY_NAME` AS `LEAD_UNIT_NAME`
    FROM
        ((((SELECT 
            `asr`.`SR_HEADER_ID` AS `SR_HEADER_ID`,
                `asr`.`MODULE_CODE` AS `MODULE_CODE`,
                `asr`.`MODULE_ITEM_KEY` AS `MODULE_ITEM_KEY`,
                `asr`.`MODULE_ITEM_ID` AS `MODULE_ITEM_ID`,
                COALESCE(`aw`.`TITLE`, `ah`.`TITLE`, `dev_prop`.`TITLE`, `ip`.`TITLE`, `srh`.`SUBJECT`) AS `TITLE`,
                COALESCE(`awp`.`FULL_NAME`, `ahp`.`FULL_NAME`, `epp`.`FULL_NAME`, `pp`.`FULL_NAME`, `srp`.`FULL_NAME`) AS `PI_NAME`,
                COALESCE(`awp`.`PERSON_ID`, `ahp`.`PERSON_ID`, `epp`.`PERSON_ID`, `pp`.`PERSON_ID`, `srp`.`PERSON_ID`) AS `PI_PERSON_ID`,
                COALESCE(`awp`.`ROLODEX_ID`, `ahp`.`ROLODEX_ID`, `epp`.`ROLODEX_ID`, `pp`.`ROLODEX_ID`, `srp`.`ROLODEX_ID`) AS `PI_ROLODEX_PERSON_ID`,
                COALESCE(`aw`.`SPONSOR_CODE`, `ahs`.`SPONSOR_CODE`, `dev_prop`.`SPONSOR_CODE`, `ip`.`SPONSOR_CODE`) AS `SPONSOR_CODE`,
                COALESCE(`aw`.`BEGIN_DATE`, `ah`.`START_DATE`, `dev_prop`.`START_DATE`, `ip`.`START_DATE`) AS `START_DATE`,
                COALESCE(`aw`.`FINAL_EXPIRATION_DATE`, `ah`.`END_DATE`, `dev_prop`.`END_DATE`, `ip`.`END_DATE`) AS `END_DATE`,
                COALESCE(`aw`.`LEAD_UNIT_NUMBER`, `ah`.`UNIT_NUMBER`, `dev_prop`.`HOME_UNIT_NUMBER`, `ip`.`HOME_UNIT_NUMBER`, `srh`.`UNIT_NUMBER`) AS `LEAD_UNIT_NUMBER`
        FROM
            (((((((((((`assoc_sr` `asr`
        LEFT JOIN `award` `aw` ON (((`asr`.`MODULE_CODE` = 1)
            AND (`aw`.`AWARD_NUMBER` = `asr`.`MODULE_ITEM_KEY`)
            AND (`asr`.`MODULE_ITEM_ID` = `aw`.`AWARD_ID`))))
        LEFT JOIN (SELECT 
            `award_persons`.`PERSON_ID` AS `PERSON_ID`,
                `award_persons`.`ROLODEX_ID` AS `ROLODEX_ID`,
                `award_persons`.`FULL_NAME` AS `FULL_NAME`,
                `award_persons`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
                `award_persons`.`AWARD_ID` AS `AWARD_ID`
        FROM
            `award_persons`
        WHERE
            (`award_persons`.`PERSON_ROLE_ID` = 3)) `awp` ON (((`asr`.`MODULE_CODE` = 1)
            AND (`awp`.`AWARD_NUMBER` = `aw`.`AWARD_NUMBER`)
            AND (`awp`.`AWARD_ID` = `aw`.`AWARD_ID`))))
        LEFT JOIN `agreement_header` `ah` ON (((`asr`.`MODULE_CODE` = 13)
            AND (`ah`.`AGREEMENT_REQUEST_ID` = `asr`.`MODULE_ITEM_KEY`)
            AND (`asr`.`MODULE_ITEM_ID` = `ah`.`AGREEMENT_REQUEST_ID`))))
        LEFT JOIN (SELECT 
            `agreement_people`.`PERSON_ID` AS `PERSON_ID`,
                `agreement_people`.`ROLODEX_ID` AS `ROLODEX_ID`,
                `agreement_people`.`FULL_NAME` AS `FULL_NAME`,
                `agreement_people`.`AGREEMENT_REQUEST_ID` AS `AGREEMENT_REQUEST_ID`
        FROM
            `agreement_people`
        WHERE
            (`agreement_people`.`PEOPLE_TYPE_ID` = 3)) `ahp` ON (((`asr`.`MODULE_CODE` = 13)
            AND (`ahp`.`AGREEMENT_REQUEST_ID` = `ah`.`AGREEMENT_REQUEST_ID`))))
        LEFT JOIN `agreement_sponsor` `ahs` ON (((`asr`.`MODULE_CODE` = 13)
            AND (`ahs`.`AGREEMENT_REQUEST_ID` = `ah`.`AGREEMENT_REQUEST_ID`))))
        LEFT JOIN `eps_proposal` `dev_prop` ON (((`asr`.`MODULE_CODE` = 3)
            AND (`dev_prop`.`PROPOSAL_ID` = `asr`.`MODULE_ITEM_KEY`)
            AND (`asr`.`MODULE_ITEM_ID` = `dev_prop`.`PROPOSAL_ID`))))
        LEFT JOIN (SELECT 
            `eps_proposal_persons`.`PERSON_ID` AS `PERSON_ID`,
                `eps_proposal_persons`.`ROLODEX_ID` AS `ROLODEX_ID`,
                `eps_proposal_persons`.`FULL_NAME` AS `FULL_NAME`,
                `eps_proposal_persons`.`PROPOSAL_ID` AS `PROPOSAL_ID`
        FROM
            `eps_proposal_persons`
        WHERE
            (`eps_proposal_persons`.`PROP_PERSON_ROLE_ID` = 3)) `epp` ON (((`asr`.`MODULE_CODE` = 3)
            AND (`epp`.`PROPOSAL_ID` = `dev_prop`.`PROPOSAL_ID`))))
        LEFT JOIN `proposal` `ip` ON (((`asr`.`MODULE_CODE` = 2)
            AND (`ip`.`PROPOSAL_NUMBER` = `asr`.`MODULE_ITEM_KEY`)
            AND (`asr`.`MODULE_ITEM_ID` = `ip`.`PROPOSAL_ID`))))
        LEFT JOIN (SELECT 
            `proposal_persons`.`PERSON_ID` AS `PERSON_ID`,
                `proposal_persons`.`ROLODEX_ID` AS `ROLODEX_ID`,
                `proposal_persons`.`FULL_NAME` AS `FULL_NAME`,
                `proposal_persons`.`PROPOSAL_ID` AS `PROPOSAL_ID`,
                `proposal_persons`.`PROPOSAL_NUMBER` AS `PROPOSAL_NUMBER`
        FROM
            `proposal_persons`
        WHERE
            (`proposal_persons`.`PROP_PERSON_ROLE_ID` = 3)) `pp` ON (((`asr`.`MODULE_CODE` = 2)
            AND (`pp`.`PROPOSAL_ID` = `ip`.`PROPOSAL_ID`)
            AND (`pp`.`PROPOSAL_NUMBER` = `ip`.`PROPOSAL_NUMBER`))))
        LEFT JOIN `sr_header` `srh` ON (((`asr`.`MODULE_CODE` = 20)
            AND (`srh`.`SR_HEADER_ID` = `asr`.`MODULE_ITEM_KEY`)
            AND (`asr`.`MODULE_ITEM_ID` = `srh`.`SR_HEADER_ID`))))
        LEFT JOIN (SELECT 
            `sr_persons`.`PERSON_ID` AS `PERSON_ID`,
                `sr_persons`.`ROLODEX_ID` AS `ROLODEX_ID`,
                `sr_persons`.`FULL_NAME` AS `FULL_NAME`,
                `sr_persons`.`SR_HEADER_ID` AS `SR_HEADER_ID`
        FROM
            `sr_persons`
        WHERE
            (`sr_persons`.`PERSON_ROLE_ID` = 3)) `srp` ON (((`asr`.`MODULE_CODE` = 20)
            AND (`srp`.`SR_HEADER_ID` = `srh`.`SR_HEADER_ID`))))) `t`
        LEFT JOIN `sponsor` `sp` ON ((`t`.`SPONSOR_CODE` = `sp`.`SPONSOR_CODE`)))
        LEFT JOIN `unit` `u` ON ((`u`.`UNIT_NUMBER` = `t`.`LEAD_UNIT_NUMBER`)))
        LEFT JOIN `coeus_module` `m` ON ((`m`.`MODULE_CODE` = `t`.`MODULE_CODE`)))
