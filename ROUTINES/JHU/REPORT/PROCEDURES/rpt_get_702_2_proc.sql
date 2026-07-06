CREATE PROCEDURE `rpt_get_702_2_proc`(
    IN person_id_in                VARCHAR(40),
    IN other_support_as_of_date_in VARCHAR(40)
)
BEGIN

    SELECT DISTINCT
           'Funded'                                           AS PROPOSAL_STATUS,
           DATE_FORMAT(a.AWARD_EFFECTIVE_DATE, '%m/%d/%Y')    AS PROJECT_START_DATE,
           DATE_FORMAT(aai.FINAL_EXPIRATION_DATE, '%m/%d/%Y') AS PROJECT_END_DATE,
           DATE_FORMAT(amfd.start_date, '%m/%d/%Y')           AS PERIOD_START_DATE,
           DATE_FORMAT(amfd.end_date, '%m/%d/%Y')             AS PERIOD_END_DATE,
           sga.GRANT_AWARD_ACTION                             AS AWARD_ACTION,
           SUM(amfd.TOTAL_DIRECT_COST + amfd.TOTAL_INDIRECT_COST) AS TOTAL_COST,
           amfd.TOTAL_INDIRECT_COST                           AS TOTAL_INDIRECT_COST,
           amfd.TOTAL_DIRECT_COST                             AS PERIOD_DIRECT_COST,
           aai.ANTICIPATED_TOTAL_DIRECT                       AS TOT_PROJ_DIRECT_COST,
           amfd.BUDGET_PERIOD,
           pi.PERCENTAGE_OF_EFFORT                            AS "IP EFFORT %",
           CASE
               WHEN pi.prop_person_role_id IN (1, 3, 5)
                   THEN pi.PI_FLAG
               ELSE 'N'
           END                                                AS PRINCIPAL_INVESTIGATOR_FLAG,
           '-'                                                AS PERSON_NAME,
           a.sponsor_award_number                             AS AWARD_ID,
           p.title                                            AS TITLE,
           ai.FULL_NAME                                       AS AWARD_PI,
           s.ACRONYM                                          AS SPONSOR_ACRO,
           s.sponsor_name                                     AS SPONSOR,
           act.description                                    AS PURPOSE,
           pt.description                                     AS PROPOSAL_TYPE,
           at.description                                     AS AWARD_TYPE,
           SUBSTR(a.award_number, 1, 6)                       AS SAP_NUMBER,
           p.PROPOSAL_NUMBER,
           oas.description                                    AS GRANT_STATUS,
           '702-2'                                            AS REPORT_NUMBER,
           person_id_in                                       AS PARAM_ENTERED_1,
           pi.FULL_NAME                                       AS TARGET_INVESTIGATOR,
           other_support_as_of_date_in                        AS PARAM_ENTERED_2,
           SYSDATE()                                          AS RUN_TIME,
           'Other Support part2'                              AS REPORT_TITLE,
           @@hostname                                         AS HOST_NAME,
           NULL                                               AS NOTE
    FROM award_funding_proposals afp
    JOIN award a
        ON afp.AWARD_ID = a.AWARD_ID
    JOIN award_status oas
        ON a.status_code = oas.status_code
    LEFT OUTER JOIN proposal p
        ON p.PROPOSAL_ID = afp.PROPOSAL_ID
    JOIN proposal_persons pi
        ON p.PROPOSAL_ID = pi.PROPOSAL_ID
    JOIN (
        SELECT
            ap.*,
            ROW_NUMBER() OVER (PARTITION BY ap.award_number ORDER BY ap.sequence_number DESC) AS rn
        FROM award_persons ap
        WHERE ap.PI_FLAG = 'Y'
    ) ai
        ON ai.AWARD_ID = afp.AWARD_ID
       AND ai.rn = 1
    LEFT OUTER JOIN sponsor s
        ON a.sponsor_code = s.sponsor_code
    LEFT OUTER JOIN activity_type act
        ON p.activity_type_code = act.activity_type_code
    LEFT OUTER JOIN PROPOSAL_TYPE pt
        ON p.TYPE_CODE = pt.TYPE_CODE
    LEFT OUTER JOIN award_type at
        ON p.AWARD_TYPE_CODE = at.AWARD_TYPE_CODE
    JOIN AWARD_AMOUNT_INFO aai
        ON aai.AWARD_ID = a.AWARD_ID
    LEFT OUTER JOIN AWARD_AMT_FNA_DISTRIBUTION amfd
        ON a.AWARD_ID = amfd.AWARD_ID
    JOIN sap_grant_award sga
        ON amfd.BUDGET_PERIOD = sga.COEUS_PERIOD
    WHERE a.status_code = '1'
      AND a.sequence_number = (
              SELECT MAX(SEQUENCE_NUMBER)
              FROM award
              WHERE award_number = a.award_number
          )
      AND a.award_number LIKE '%-00001'
      AND p.type_code IN (1, 4, 5, 6, 9)
      AND p.SEQUENCE_NUMBER = (
              SELECT MAX(SEQUENCE_NUMBER)
              FROM proposal_persons
              WHERE proposal_number = p.proposal_number
          )
      AND p.status_code = '2'
      AND pi.SEQUENCE_NUMBER = (
              SELECT MAX(SEQUENCE_NUMBER)
              FROM proposal_persons
              WHERE proposal_number = pi.proposal_number
          )
      AND aai.sequence_number = (
              SELECT MAX(SEQUENCE_NUMBER)
              FROM award_amount_info
              WHERE award_number = aai.award_number
          )
      AND aai.AWARD_AMOUNT_INFO_ID = (
              SELECT MAX(AWARD_AMOUNT_INFO_ID)
              FROM award_amount_info
              WHERE award_number = aai.award_number
                AND SEQUENCE_NUMBER = aai.SEQUENCE_NUMBER
          )
      AND amfd.sequence_number = (
              SELECT MAX(sequence_number)
              FROM AWARD_AMT_FNA_DISTRIBUTION
              WHERE award_number = amfd.award_number
          )
      AND pi.person_id = person_id_in
      AND STR_TO_DATE(other_support_as_of_date_in, '%m/%d/%Y')
          BETWEEN amfd.start_date AND amfd.end_date
      AND pi.person_id != ai.person_id
      AND SUBSTR(a.award_number, 1, 6) = sga.grant_number
    GROUP BY a.award_id

    UNION

    SELECT DISTINCT
           'Funded'                                           AS PROPOSAL_STATUS,
           DATE_FORMAT(a.AWARD_EFFECTIVE_DATE, '%m/%d/%Y')    AS PROJECT_START_DATE,
           DATE_FORMAT(aai.FINAL_EXPIRATION_DATE, '%m/%d/%Y') AS PROJECT_END_DATE,
           'NO AYB DATA'                                      AS PERIOD_START_DATE,
           NULL                                               AS PERIOD_END_DATE,
           'NA'                                               AS AWARD_ACTION,
           NULL                                               AS TOTAL_COST,
           NULL                                               AS TOTAL_INDIRECT_COST,
           NULL                                               AS PERIOD_DIRECT_COST,
           aai.ANTICIPATED_TOTAL_DIRECT                       AS TOT_PROJ_DIRECT_COST,
           NULL                                               AS BUDGET_PERIOD,
           pi.PERCENTAGE_OF_EFFORT                            AS "IP EFFORT %",
           CASE
               WHEN pi.prop_person_role_id IN (1, 3, 5)
                   THEN pi.PI_FLAG
               ELSE 'N'
           END                                                AS PRINCIPAL_INVESTIGATOR_FLAG,
           '-'                                                AS PERSON_NAME,
           a.sponsor_award_number                             AS AWARD_ID,
           p.title                                            AS TITLE,
           ai.FULL_NAME                                       AS AWARD_PI,
           s.ACRONYM                                          AS SPONSOR_ACRO,
           s.sponsor_name                                     AS SPONSOR,
           act.description                                    AS PURPOSE,
           pt.description                                     AS PROPOSAL_TYPE,
           at.description                                     AS AWARD_TYPE,
           SUBSTR(a.award_number, 1, 6)                       AS SAP_NUMBER,
           p.PROPOSAL_NUMBER,
           oas.description                                    AS GRANT_STATUS,
           '702-2'                                            AS REPORT_NUMBER,
           person_id_in                                       AS PARAM_ENTERED_1,
           pi.FULL_NAME                                       AS TARGET_INVESTIGATOR,
           other_support_as_of_date_in                        AS PARAM_ENTERED_2,
           SYSDATE()                                          AS RUN_TIME,
           'Other Support part2'                              AS REPORT_TITLE,
           @@HOSTNAME                                         AS HOST_NAME,
           NULL                                               AS NOTE
    FROM award_funding_proposals afp
    JOIN award a
        ON afp.award_ID = a.award_ID
    JOIN award_status oas
        ON a.status_code = oas.status_code
    LEFT OUTER JOIN proposal p
        ON p.proposal_id = afp.proposal_id
    JOIN proposal_persons pi
        ON p.proposal_id = pi.proposal_id
    JOIN (
        SELECT
            ap.*,
            ROW_NUMBER() OVER (PARTITION BY ap.award_number ORDER BY ap.sequence_number DESC) AS rn
        FROM award_persons ap
        WHERE ap.PI_FLAG = 'Y'
    ) ai
        ON ai.award_ID = a.award_ID
       AND ai.rn = 1
    LEFT OUTER JOIN sponsor s
        ON a.sponsor_code = s.sponsor_code
    LEFT OUTER JOIN activity_type act
        ON p.activity_type_code = act.activity_type_code
    LEFT OUTER JOIN PROPOSAL_TYPE pt
        ON p.TYPE_CODE = PT.TYPE_CODE
    LEFT OUTER JOIN award_type at
        ON p.AWARD_TYPE_CODE = at.AWARD_TYPE_CODE
    JOIN AWARD_AMOUNT_INFO aai
        ON aai.award_ID = afp.award_ID
    LEFT OUTER JOIN AWARD_AMT_FNA_DISTRIBUTION amfd
        ON a.award_ID = amfd.award_ID
    JOIN sap_grant_award sga
        ON amfd.BUDGET_PERIOD = sga.COEUS_PERIOD
    JOIN (
        SELECT sg.grant_number
        FROM sap_grant sg,
             (
                 SELECT grant_number,
                        MAX(STR_TO_DATE(GRANT_BUDGET_END_DATE, '%Y%m%d')) AS max_budget_end_date
                 FROM sap_grant_award
                 GROUP BY grant_number
             ) sgag
        WHERE sg.grant_number = sgag.grant_number
          AND sg.user_status = 'E0003'
          AND sg.proposal_number != '00000000'
          AND STR_TO_DATE(GRANT_END_DATE, '%Y%m%d') > sgag.max_budget_end_date
          AND STR_TO_DATE(other_support_as_of_date_in, '%m/%d/%Y') > sgag.max_budget_end_date
    ) potential_aw
        ON potential_aw.grant_number = sga.grant_number
    WHERE p.type_code IN (1, 4, 5, 6, 9)
      AND aai.sequence_number = (
              SELECT MAX(SEQUENCE_NUMBER)
              FROM award_amount_info
              WHERE award_number = aai.award_number
          )
      AND aai.AWARD_AMOUNT_INFO_ID = (
              SELECT MAX(AWARD_AMOUNT_INFO_ID)
              FROM award_amount_info
              WHERE award_number = aai.award_number
                AND SEQUENCE_NUMBER = aai.SEQUENCE_NUMBER
          )
      AND amfd.sequence_number = (
              SELECT MAX(sequence_number)
              FROM AWARD_AMT_FNA_DISTRIBUTION
              WHERE award_number = amfd.award_number
          )
      AND pi.SEQUENCE_NUMBER = (
              SELECT MAX(SEQUENCE_NUMBER)
              FROM Proposal_PERSONS
              WHERE proposal_number = pi.proposal_number
          )
      AND p.SEQUENCE_NUMBER = (
              SELECT MAX(SEQUENCE_NUMBER)
              FROM Proposal_PERSONS
              WHERE proposal_number = p.proposal_number
          )
      AND p.status_code = '2'
      AND a.sequence_number = (
              SELECT MAX(SEQUENCE_NUMBER)
              FROM award
              WHERE award_number = a.award_number
          )
      AND a.status_code = '1'
      AND pi.person_id = person_id_in
      AND a.award_number LIKE '%-00001'
      AND ai.PI_FLAG = 'Y'
      AND pi.person_id != ai.person_id
      AND SUBSTR(a.award_number, 1, 6) = sga.grant_number;

END
