CREATE VIEW sr_assoc_detail_v AS
    SELECT 
        asr.SR_HEADER_ID AS SR_HEADER_ID,
        asr.MODULE_CODE AS MODULE_CODE,
        cm.DESCRIPTION AS MODULE_NAME,
        asr.MODULE_ITEM_KEY AS MODULE_ITEM_KEY,
        asr.MODULE_ITEM_ID AS MODULE_ITEM_ID,
        (CASE
            WHEN (asr.MODULE_CODE = 13) THEN agr.TITLE
            WHEN (asr.MODULE_CODE = 20) THEN srh.SUBJECT
            ELSE stage.TITLE
        END) AS TITLE,
        (CASE
            WHEN (asr.MODULE_CODE = 13) THEN agr.PRINCIPAL_PERSON_FULL_NAME
            WHEN (asr.MODULE_CODE = 20) THEN srh.PI_NAME
            ELSE stage.PI_NAME
        END) AS PI_NAME,
        (CASE
            WHEN (asr.MODULE_CODE = 13) THEN agr.AGREEMENT_STATUS
            WHEN (asr.MODULE_CODE = 20) THEN srh.STATUS
            ELSE stage.STATUS
        END) AS STATUS,
        (CASE
            WHEN (asr.MODULE_CODE = 13) THEN NULL
            WHEN (asr.MODULE_CODE = 20) THEN NULL
            ELSE stage.SPONSOR_CODE
        END) AS SPONSOR_CODE,
        (CASE
            WHEN (asr.MODULE_CODE = 13) THEN agr.SPONSOR_NAME
            WHEN (asr.MODULE_CODE = 20) THEN NULL
            ELSE stage.SPONSOR_NAME
        END) AS SPONSOR_NAME,
        (CASE
            WHEN (asr.MODULE_CODE = 13) THEN agr.UNIT_NUMBER
            WHEN (asr.MODULE_CODE = 20) THEN srh.UNIT_NUMBER
            ELSE stage.LEAD_UNIT_NUMBER
        END) AS LEAD_UNIT_NUMBER,
        (CASE
            WHEN (asr.MODULE_CODE = 13) THEN agr.UNIT_NAME
            WHEN (asr.MODULE_CODE = 20) THEN srh.UNIT_NAME
            ELSE stage.LEAD_UNIT_NAME
        END) AS LEAD_UNIT_NAME,
        (CASE
            WHEN (asr.MODULE_CODE = 13) THEN agr.AGREEMENT_START_DATE
            ELSE stage.START_DATE
        END) AS START_DATE,
        (CASE
            WHEN (asr.MODULE_CODE = 13) THEN agr.AGREEMENT_END_DATE
            ELSE stage.END_DATE
        END) AS END_DATE,
        (CASE
            WHEN (asr.MODULE_CODE = 13) THEN NULL
            WHEN (asr.MODULE_CODE = 20) THEN srh.PI_PERSON_ID
            ELSE stage.PERSON_ID
        END) AS PI_PERSON_ID,
        (CASE
            WHEN (asr.MODULE_CODE = 20) THEN srh.PI_ROLODEX_PERSON_ID
            ELSE NULL
        END) AS PI_ROLODEX_PERSON_ID
    FROM
        ((((assoc_sr asr
        LEFT JOIN sr_int_stage_elastic_index stage ON (((asr.MODULE_CODE = stage.MODULE_CODE)
            AND (asr.MODULE_ITEM_KEY = stage.MODULE_ITEM_KEY)
            AND (asr.MODULE_ITEM_ID = stage.DOCUMENT_NUMBER))))
        LEFT JOIN sr_int_stage_agreement agr ON (((asr.MODULE_CODE = 13)
            AND (asr.MODULE_ITEM_KEY = agr.AGREEMENT_ID)
            AND (asr.MODULE_ITEM_ID = agr.AGREEMENT_ID))))
        LEFT JOIN (SELECT 
            sr.SR_HEADER_ID AS SR_HEADER_ID,
                sr.SUBJECT AS SUBJECT,
                sp.FULL_NAME AS PI_NAME,
                st.DESCRIPTION AS STATUS,
                sr.UNIT_NUMBER AS UNIT_NUMBER,
                u.DISPLAY_NAME AS UNIT_NAME,
                sp.PERSON_ID AS PI_PERSON_ID,
                sp.ROLODEX_ID AS PI_ROLODEX_PERSON_ID
        FROM
            (((sr_header sr
        LEFT JOIN (SELECT 
            sr_persons.SR_HEADER_ID AS SR_HEADER_ID,
                sr_persons.FULL_NAME AS FULL_NAME,
                sr_persons.PERSON_ID AS PERSON_ID,
                sr_persons.ROLODEX_ID AS ROLODEX_ID
        FROM
            sr_persons
        WHERE
            (sr_persons.PERSON_ROLE_ID = 3)) sp ON ((sp.SR_HEADER_ID = sr.SR_HEADER_ID)))
        LEFT JOIN sr_status st ON ((st.STATUS_CODE = sr.STATUS_CODE)))
        LEFT JOIN unit u ON ((u.UNIT_NUMBER = sr.UNIT_NUMBER)))) srh ON (((asr.MODULE_CODE = 20)
            AND (asr.MODULE_ITEM_KEY = srh.SR_HEADER_ID)
            AND (asr.MODULE_ITEM_ID = srh.SR_HEADER_ID))))
        LEFT JOIN coeus_module cm ON ((asr.MODULE_CODE = cm.MODULE_CODE)))
