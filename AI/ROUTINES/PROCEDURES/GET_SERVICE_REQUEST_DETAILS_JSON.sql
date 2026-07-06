CREATE PROCEDURE `GET_SERVICE_REQUEST_DETAILS_JSON`(
    IN AV_SERVICE_REQUEST_ID INT
)
BEGIN
    SELECT JSON_OBJECT(
        'SR_HEADER_ID', sh.SR_HEADER_ID,
        'ASSIGNEE_PERSON_ID', sh.ASSIGNEE_PERSON_ID,
        'CREATE_TIMESTAMP', sh.CREATE_TIMESTAMP,
        'CREATE_USER', sh.CREATE_USER,
        'DESCRIPTION', sh.DESCRIPTION,
        'STATUS_DESCRIPTION', ss.DESCRIPTION,
        'SUBJECT', sh.SUBJECT,
        'TYPE_DESCRIPTION', st.DESCRIPTION,
        'UPDATE_TIMESTAMP', sh.UPDATE_TIMESTAMP,
        'UPDATE_USER', sh.UPDATE_USER,
        'UNIT_NAME', u.UNIT_NAME,
        'IS_SYSTEM_GENERATED', sh.IS_SYSTEM_GENERATED,
        'PRIORITY_DESCRIPTION', sp.DESCRIPTION,
        'CATEGORY_DESCRIPTION', sc.DESCRIPTION,
		'ADMIN_GROUP_NAME', ag.ADMIN_GROUP_NAME,
        'ADMIN_GROUP_DESCRIPTION', ag.DESCRIPTION,
        'ADMIN_GROUP_IS_ACTIVE', ag.IS_ACTIVE,
        
        -- Key Personnel
        'KEY_PERSONNEL', IFNULL(
            (SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'FULL_NAME', spers.FULL_NAME,
                    'PERCENTAGE_OF_EFFORT', spers.PERCENTAGE_OF_EFFORT,
                    'PI_FLAG', spers.PI_FLAG,
                    'ROLE_DESCRIPTION', spr.DESCRIPTION
                )
            )
            FROM sr_persons spers
            LEFT JOIN eps_prop_person_role spr 
                ON spers.PERSON_ROLE_ID = spr.PROP_PERSON_ROLE_ID
            WHERE spers.SR_HEADER_ID = sh.SR_HEADER_ID
            ), JSON_ARRAY()
        ),

        -- Project Associations
        'PROJECT_ASSOCIATIONS', IFNULL(
            (SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'MODULE_CODE', ass.MODULE_CODE,
                    'MODULE_ITEM_KEY', ass.MODULE_ITEM_KEY,
                    'MODULE_ITEM_ID', ass.MODULE_ITEM_ID,
                    'ASSOC_TYPE', ass.ASSOC_TYPE,
                    'RELATION_TYPE_CODE', ass.RELATION_TYPE_CODE,
                    'ASSOC_CONFIG_CODE', ass.ASSOC_CONFIG_CODE,
                    'ASSOC_CONFIG_LABEL', amm.LABEL,
                    'RELATION_DESCRIPTION', art.DESCRIPTION,
                    
                    -- DETAILS nested
                    'DETAILS', CASE 
                        WHEN ass.ASSOC_CONFIG_CODE = '1' THEN IFNULL(
                            (SELECT JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'ID', aw.AWARD_NUMBER,
                                    'Title', aw.TITLE,
                                    'Status', aws.DESCRIPTION,
                                    'Principal Investigator', (
                                        SELECT IFNULL(p2.FULL_NAME, r1.FULL_NAME)
                                        FROM award_persons p1
                                        LEFT JOIN person p2 ON p1.PERSON_ID = p2.PERSON_ID
                                        LEFT JOIN rolodex r1 ON p1.ROLODEX_ID = r1.ROLODEX_ID
                                        WHERE p1.AWARD_ID = aw.AWARD_ID AND p1.PI_FLAG = 'Y'
                                    ),
                                    'Lead Unit', CONCAT(aw.LEAD_UNIT_NUMBER, '-', uaw.UNIT_NAME),
                                    'Sponsor', CONCAT(aw.SPONSOR_CODE, '-', sp.SPONSOR_NAME),
                                    'Prime Sponsor', CONCAT(aw.PRIME_SPONSOR_CODE, '-', sp2.SPONSOR_NAME),
                                    'Sponsor Award Number', aw.SPONSOR_AWARD_NUMBER,
                                    'Anticipated Amount', IFNULL(aa.ANTICIPATED_TOTAL_AMOUNT, 0.00),
                                    'Obligated Amount', IFNULL(aa.AMOUNT_OBLIGATED_TO_DATE, 0.00),
                                    'Effective Date', DATE(aw.BEGIN_DATE),
                                    'Final Expiration Date', DATE(aw.FINAL_EXPIRATION_DATE)
                                )
                            )
                            FROM award aw
                            INNER JOIN award_status aws ON aw.STATUS_CODE = aws.STATUS_CODE
                            LEFT JOIN sponsor sp ON aw.SPONSOR_CODE = sp.SPONSOR_CODE
                            LEFT JOIN sponsor sp2 ON aw.PRIME_SPONSOR_CODE = sp2.SPONSOR_CODE
                            LEFT JOIN unit uaw ON aw.LEAD_UNIT_NUMBER = uaw.UNIT_NUMBER
                            LEFT JOIN (
                                SELECT s1.AWARD_NUMBER, s1.ANTICIPATED_TOTAL_AMOUNT, s1.AMOUNT_OBLIGATED_TO_DATE
                                FROM award_amount_info s1
                                INNER JOIN (
                                    SELECT MAX(s3.AWARD_AMOUNT_INFO_ID) AS AWARD_AMOUNT_INFO_ID, s3.AWARD_NUMBER
                                    FROM award_amount_info s3
                                    INNER JOIN award s5 ON s5.AWARD_NUMBER = s3.AWARD_NUMBER
                                    GROUP BY s3.AWARD_NUMBER
                                ) s2 ON s1.AWARD_AMOUNT_INFO_ID = s2.AWARD_AMOUNT_INFO_ID
                                AND s1.AWARD_NUMBER = s2.AWARD_NUMBER
                            ) aa ON aa.AWARD_NUMBER = aw.AWARD_NUMBER
                            WHERE aw.AWARD_ID = ass.MODULE_ITEM_ID
                            ), JSON_ARRAY()
                        )
                        WHEN ass.ASSOC_CONFIG_CODE = '2' THEN IFNULL(
                            (SELECT JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'ID', p.PROPOSAL_ID,
                                    'Title', p.TITLE,
                                    'Status', ps.DESCRIPTION,
                                    'Principal Investigator', pp.FULL_NAME,
                                    'Lead Unit', CONCAT(p.HOME_UNIT_NUMBER, '-', up.UNIT_NAME),
                                    'Proposed Start Date', DATE(p.START_DATE),
                                    'Proposed End Date', DATE(p.END_DATE),
                                    'Sponsor', CONCAT(p.SPONSOR_CODE, '-', sp.SPONSOR_NAME),
                                    'Total Project Cost', bh.TOTAL_COST
                                )
                            )
                            FROM eps_proposal p
                            INNER JOIN eps_proposal_status ps ON ps.STATUS_CODE = p.STATUS_CODE
                            LEFT JOIN (
                                SELECT PROPOSAL_ID, FULL_NAME
                                FROM eps_proposal_persons
                                WHERE PI_FLAG = 'Y'
                                GROUP BY PROPOSAL_ID
                            ) pp ON pp.PROPOSAL_ID = p.PROPOSAL_ID
                            LEFT JOIN unit up ON up.UNIT_NUMBER = p.HOME_UNIT_NUMBER
                            LEFT JOIN sponsor sp ON sp.SPONSOR_CODE = p.SPONSOR_CODE
                            LEFT JOIN budget_header bh ON bh.PROPOSAL_ID = p.PROPOSAL_ID AND bh.IS_LATEST_VERSION = 'Y'
                            WHERE p.PROPOSAL_ID = ass.MODULE_ITEM_ID
                            ), JSON_ARRAY()
                        )
                        WHEN ass.ASSOC_CONFIG_CODE = '3' THEN IFNULL(
                            (SELECT JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'ID', sr.SR_HEADER_ID,
                                    'Title', sr.SUBJECT,
                                    'Status', srs.DESCRIPTION,
                                    'Reporter', per.FULL_NAME,
                                    'Lead Unit', CONCAT(sr.UNIT_NUMBER, '-', us.UNIT_NAME),
                                    'Type', srt.DESCRIPTION,
                                    'Category', src.DESCRIPTION
                                )
                            )
                            FROM sr_header sr
                            INNER JOIN sr_status srs ON srs.STATUS_CODE = sr.STATUS_CODE
                            INNER JOIN sr_type srt ON srt.TYPE_CODE = sr.TYPE_CODE
                            LEFT JOIN unit us ON us.UNIT_NUMBER = sr.UNIT_NUMBER
                            LEFT JOIN sr_category src ON src.CATEGORY_CODE = sr.CATEGORY_CODE
                            LEFT JOIN person per ON per.PERSON_ID = sr.REPORTER_PERSON_ID
                            WHERE sr.SR_HEADER_ID = ass.MODULE_ITEM_ID
                            ), JSON_ARRAY()
                        )
                        WHEN ass.ASSOC_CONFIG_CODE = '4' THEN IFNULL(
                            (SELECT JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'ID', a.AGREEMENT_REQUEST_ID,
                                    'Title', a.TITLE,
                                    'Status', CASE WHEN a.IS_HOLD = 'Y' THEN CONCAT(ast.DESCRIPTION, ' - Info Requested') ELSE ast.DESCRIPTION END,
                                    'Principal Investigator', (
                                        SELECT GROUP_CONCAT(DISTINCT ap.FULL_NAME SEPARATOR ' | ')
                                        FROM agreement_people ap
                                        WHERE ap.AGREEMENT_REQUEST_ID = a.AGREEMENT_REQUEST_ID
                                        AND ap.PEOPLE_TYPE_ID = 3
                                    ),
                                    'Lead Unit', u.DISPLAY_NAME,
                                    'Type', at.DESCRIPTION,
                                    'Sponsor', spo.ORGANIZATION
                                )
                            )
                            FROM agreement_header a
                            INNER JOIN agreement_status ast ON ast.AGREEMENT_STATUS_CODE = a.AGREEMENT_STATUS_CODE
                            INNER JOIN agreement_type at ON at.AGREEMENT_TYPE_CODE = a.AGREEMENT_TYPE_CODE
                            LEFT JOIN (
                                SELECT AGS.AGREEMENT_REQUEST_ID, S.DISPLAY_NAME AS ORGANIZATION
                                FROM agreement_sponsor AGS
                                LEFT JOIN sponsor S ON S.SPONSOR_CODE = AGS.SPONSOR_CODE
                                WHERE AGS.AGREEMENT_SPONSOR_TYPE_CODE = '1'
                            ) spo ON spo.AGREEMENT_REQUEST_ID = a.AGREEMENT_REQUEST_ID
                            INNER JOIN unit u ON u.UNIT_NUMBER = a.UNIT_NUMBER
                            WHERE a.AGREEMENT_REQUEST_ID = ass.MODULE_ITEM_ID
                            ), JSON_ARRAY()
                        )
                        WHEN ass.ASSOC_CONFIG_CODE = '5' THEN IFNULL(
                        (SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'ID', p.PROPOSAL_NUMBER,
                                'Title', p.TITLE,
                                'Status', ps.DESCRIPTION,
                                'Principal Investigator', pp.FULL_NAME,
                                'Lead Unit', CONCAT(p.HOME_UNIT_NUMBER, '-', up.UNIT_NAME),
                                'Proposed Start Date', DATE(p.START_DATE),
                                'Proposed End Date', DATE(p.END_DATE),
                                'Sponsor', CONCAT(p.SPONSOR_CODE, '-', sp.SPONSOR_NAME),
                                'Total Project Cost', bh.TOTAL_COST
                            )
                        )
                        FROM proposal p
                        INNER JOIN proposal_status ps ON ps.STATUS_CODE = p.STATUS_CODE
                        LEFT JOIN unit up ON up.UNIT_NUMBER = p.HOME_UNIT_NUMBER
                        LEFT JOIN sponsor sp ON sp.SPONSOR_CODE = p.SPONSOR_CODE
                        LEFT JOIN ip_budget_header bh ON bh.PROPOSAL_ID = p.PROPOSAL_ID
                        LEFT JOIN (
                            SELECT PROPOSAL_ID, FULL_NAME
                            FROM proposal_persons
                            WHERE PI_FLAG = 'Y'
                            GROUP BY PROPOSAL_ID
                        ) pp ON pp.PROPOSAL_ID = p.PROPOSAL_ID
                        WHERE p.PROPOSAL_ID = ass.MODULE_ITEM_ID
                        ), JSON_ARRAY()
                    )
                        ELSE JSON_ARRAY()
                    END
                )
            )
            FROM assoc_sr ass
            LEFT JOIN assoc_module_mapping amm ON ass.ASSOC_CONFIG_CODE = amm.ASSOC_CONFIG_CODE
            LEFT JOIN assoc_relation_type art ON ass.RELATION_TYPE_CODE = art.ASSOC_RELATION_TYPE_CODE
            WHERE ass.SR_HEADER_ID = sh.SR_HEADER_ID
            ), JSON_ARRAY()
        ),
        
        -- Service Request Attachments (excluding types 1 and 4)
        'SERVICE_REQUEST_ATTACHMENTS', IFNULL(
            (SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'ACTION_LOG_ID', sra.ACTION_LOG_ID,
                    'FILE_NAME', sra.FILE_NAME,
                    'CONTENT_TYPE', sra.CONTENT_TYPE,
                    'UPDATE_TIMESTAMP', sra.UPDATE_TIMESTAMP,
                    'UPDATE_USER', sra.UPDATE_USER,
                    'ATTACHMENT_TYPE_CODE', sra.ATTACHMENT_TYPE_CODE,
                    'ATTACHMENT_TYPE_DESCRIPTION', srat.DESCRIPTION
                )
            )
            FROM sr_attachment sra
            LEFT JOIN sr_attachment_type srat 
                ON sra.ATTACHMENT_TYPE_CODE = srat.ATTACHMENT_TYPE_CODE
            WHERE sra.SR_HEADER_ID = sh.SR_HEADER_ID
            AND sra.ATTACHMENT_TYPE_CODE NOT IN (1, 4)
            ), JSON_ARRAY()
        ),
        
        -- Comments grouped by section with attachments
        'COMMENTS', IFNULL(
            (SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'SECTION_CODE', grouped_comments.SECTION_CODE,
                    'SECTION_DESCRIPTION', grouped_comments.SECTION_DESCRIPTION,
                    'COMMENTS', grouped_comments.COMMENTS_ARRAY
                )
            )
            FROM (
                SELECT 
                    scmt.SECTION_CODE,
                    st.DESCRIPTION AS SECTION_DESCRIPTION,
                    JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'ACTION_LOG_ID', scmt.ACTION_LOG_ID,
                            'COMMENT_ID', scmt.COMMENT_ID,
                            'COMMENTS', scmt.COMMENTS,
                            'UPDATE_USER', scmt.UPDATE_USER,
                            'ATTACHMENTS', IFNULL(
                                (SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT(
                                        'FILE_NAME', sra.FILE_NAME,
                                        'CONTENT_TYPE', sra.CONTENT_TYPE,
                                        'UPDATE_TIMESTAMP', sra.UPDATE_TIMESTAMP,
                                        'UPDATE_USER', sra.UPDATE_USER,
                                        'ATTACHMENT_TYPE_CODE', sra.ATTACHMENT_TYPE_CODE,
                                        'ATTACHMENT_TYPE_DESCRIPTION', srat.DESCRIPTION
                                    )
                                )
                                FROM sr_attachment sra
                                LEFT JOIN sr_attachment_type srat 
                                    ON sra.ATTACHMENT_TYPE_CODE = srat.ATTACHMENT_TYPE_CODE
                                WHERE sra.ACTION_LOG_ID = scmt.ACTION_LOG_ID
                                AND sra.ATTACHMENT_TYPE_CODE = 1
                                ), JSON_ARRAY()
                            )
                        )
                    ) AS COMMENTS_ARRAY
                FROM sr_comments scmt
                LEFT JOIN section_type st ON scmt.SECTION_CODE = st.SECTION_CODE
                WHERE scmt.SR_HEADER_ID = sh.SR_HEADER_ID
                AND scmt.PRIVATE_FLAG = 'N'
                GROUP BY scmt.SECTION_CODE, st.DESCRIPTION
                ORDER BY scmt.SECTION_CODE
            ) AS grouped_comments
            ), JSON_ARRAY()
        ),
        -- Service Request Workflow
        'SERVICE_REQUEST_WORKFLOW', IFNULL(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'WORKFLOW_DETAIL_ID', wd.WORKFLOW_DETAIL_ID,
                        'MAP_NUMBER', wd.MAP_NUMBER,
                        'APPROVAL_STOP_NUMBER', wd.APPROVAL_STOP_NUMBER,
                        'APPROVER_NUMBER', wd.APPROVER_NUMBER,
                        'PRIMARY_APPROVER_FLAG', wd.PRIMARY_APPROVER_FLAG,
                        'APPROVER_PERSON_NAME', wd.APPROVER_PERSON_NAME,
                        'APPROVAL_STATUS', wd.APPROVAL_STATUS,
                        'APPROVAL_STATUS_DESCRIPTION', ws.DESCRIPTION,
                        'APPROVAL_DATE', wd.APPROVAL_DATE,
                        'STOP_NAME', wd.STOP_NAME,
                        'MAP_NAME', wd.MAP_NAME,
                        'MAP_DESCRIPTION', wd.MAP_DESCRIPTION,
                        'ATTACHMENTS', IFNULL(
                            (
                                SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT(
                                        'ATTACHMENT_ID', wa.ATTACHMENT_ID,
                                        'FILE_NAME', wa.FILE_NAME,
                                        'MIME_TYPE', wa.MIME_TYPE
                                    )
                                )
                                FROM workflow_attachment wa
                                WHERE wa.WORKFLOW_DETAIL_ID = wd.WORKFLOW_DETAIL_ID
                            ), JSON_ARRAY()
                        )
                    )
                )
                FROM workflow w
                INNER JOIN workflow_detail wd ON w.WORKFLOW_ID = wd.WORKFLOW_ID
                LEFT JOIN workflow_status ws ON wd.APPROVAL_STATUS = ws.APPROVAL_STATUS
                WHERE w.MODULE_ITEM_ID = sh.SR_HEADER_ID
                AND w.MODULE_CODE = 20
                AND w.IS_WORKFLOW_ACTIVE = 'Y'
            ),
            JSON_ARRAY()
        ),
        -- Service Request History (merged from your separate procedure)
        'SERVICE_REQUEST_HISTORY', IFNULL((
              SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'actionLogId', sal.ACTION_LOG_ID,
            'serviceRequestId', sal.SR_HEADER_ID,
            'actionTypeCode', sal.ACTION_TYPE_CODE,
            'serviceRequestActionType', JSON_OBJECT(
                'actionTypeCode', sat.ACTION_TYPE_CODE,
                'description', sat.DESCRIPTION,
                'updateTimestamp', UNIX_TIMESTAMP(sat.UPDATE_TIMESTAMP) * 1000,
                'updateUser', sat.UPDATE_USER,
                'message', sat.MESSAGE
            ),
            'statusCode', sal.STATUS_CODE,
            'serviceRequestStatus', IFNULL(JSON_OBJECT(
                'statusCode', ss.STATUS_CODE,
                'description', ss.DESCRIPTION,
                'updateTimestamp', UNIX_TIMESTAMP(ss.UPDATE_TIMESTAMP) * 1000,
                'updateUser', ss.UPDATE_USER
            ), NULL),
            'assigneePersonId', sal.ASSIGNEE_PERSON_ID,
            'assigneePersonName', sal.ASSIGNEE_PERSON_NAME,
            'updateTimestamp', UNIX_TIMESTAMP(sal.UPDATE_TIMESTAMP) * 1000,
            'updateUser', sal.UPDATE_USER,
            'updateUserFullName', pu.FULL_NAME,
            
            -- Service Request History for this action log
            'serviceRequestHistory', IFNULL(
                (SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'SR_HEADER_HISTORY_ID', shh.SR_HEADER_HISTORY_ID,
                        'ACTION_LOG_ID', shh.ACTION_LOG_ID,
                        'ASSIGNEE_PERSON_NAME', T2.FULL_NAME,
                        'DESCRIPTION', shh.DESCRIPTION,
                        'CATEGORY_CODE', shh.CATEGORY_CODE,
                        'CATEGORY_CODE_DESC', T11.DESCRIPTION,
                        'MODULE_ITEM_KEY', shh.MODULE_ITEM_KEY,
                        'ATTACHMENT_NAME', shh.ATTACHMENT_NAME,
                        'PREV_ATTACHMENT_NAME', shh.PREV_ATTACHMENT_NAME,
                        'PREV_ASSIGNEE_PERSON_NAME', T3.FULL_NAME,
                        'PREV_DESCRIPTION', shh.PREV_DESCRIPTION,
                        'PREV_CATEGORY_CODE', shh.PREV_CATEGORY_CODE,
                        'PREV_CATEGORY_CODE_DESC', T12.DESCRIPTION,
                        'PREV_MODULE_ITEM_KEY', shh.PREV_MODULE_ITEM_KEY,
                        'PREV_REPORTER_PERSON_NAME', T5.FULL_NAME,
                        'PREV_SUBJECT', shh.PREV_SUBJECT,
                        'PREV_TYPE_DESC', T8.DESCRIPTION,
                        'REPORTER_PERSON_NAME', T4.FULL_NAME,
                        'SUBJECT', shh.SUBJECT,
                        'TYPE_DESC', T7.DESCRIPTION,
                        'UPDATE_TIMESTAMP', shh.UPDATE_TIMESTAMP,
                        'UPDATE_USER', T6.FULL_NAME,
                        'SR_HEADER_ID', shh.SR_HEADER_ID,
                        'PRIORITY_DESC', T9.DESCRIPTION,
                        'ADMIN_GROUP_DESC', T15.ADMIN_GROUP_NAME,
                        'PREV_PRIORITY_DESC', T10.DESCRIPTION,
                        'PREV_ADMIN_GROUP_DESC', T16.ADMIN_GROUP_NAME,
                        'UNIT_NAME', T13.unit_name,
                        'PREV_UNIT_NAME', T14.unit_name,
                        'PREV_TITLE', T.TITLE,
                        'TITLE', R.TITLE,
                        'ADDED_PERMISSION', shh.ADDED_PERMISSION,
                        'DELETED_PERMISSION', shh.DELETED_PERMISSION,
                        'PERMISSION_ASSIGNED_USER', shh.PERMISSION_ASSIGNED_USER,
                        'NOTIFICATION_SUBJECT', shh.NOTIFICATION_SUBJECT,
                        'NOTIFICATION_RECIPIENT_NAME', shh.NOTIFICATION_RECIPIENT_NAME
                    )
                )
                FROM SR_HEADER_HISTORY shh
                LEFT JOIN PERSON T2 ON shh.ASSIGNEE_PERSON_ID = T2.PERSON_ID
                LEFT JOIN PERSON T3 ON shh.PREV_ASSIGNEE_PERSON_ID = T3.PERSON_ID
                LEFT JOIN PERSON T4 ON shh.REPORTER_PERSON_ID = T4.PERSON_ID
                LEFT JOIN PERSON T5 ON shh.PREV_REPORTER_PERSON_ID = T5.PERSON_ID
                LEFT JOIN PERSON T6 ON shh.UPDATE_USER = T6.USER_NAME
                LEFT JOIN SR_TYPE T7 ON shh.TYPE_CODE = T7.TYPE_CODE
                LEFT JOIN SR_TYPE T8 ON shh.PREV_TYPE_CODE = T8.TYPE_CODE
                LEFT JOIN SR_PRIORITY T9 ON shh.PRIORITY_ID = T9.PRIORITY_ID
                LEFT JOIN SR_PRIORITY T10 ON shh.PREV_PRIORITY_ID = T10.PRIORITY_ID
                LEFT JOIN SR_CATEGORY T11 ON T11.CATEGORY_CODE = shh.CATEGORY_CODE
                LEFT JOIN SR_CATEGORY T12 ON T12.CATEGORY_CODE = shh.PREV_CATEGORY_CODE
                LEFT JOIN UNIT T13 ON shh.UNIT_NUMBER = T13.UNIT_NUMBER
                LEFT JOIN UNIT T14 ON shh.PREV_UNIT_NUMBER = T14.UNIT_NUMBER
                LEFT JOIN ADMIN_GROUP T15 ON shh.ADMIN_GROUP_ID = T15.ADMIN_GROUP_ID
                LEFT JOIN ADMIN_GROUP T16 ON shh.PREV_ADMIN_GROUP_ID = T16.ADMIN_GROUP_ID
                LEFT JOIN (
                    SELECT AGREEMENT_REQUEST_ID AS MODULE_ITEM_KEY, TITLE, 13 AS MODULE_CODE FROM AGREEMENT_HEADER
                    UNION ALL
                    SELECT AWARD_ID AS MODULE_ITEM_KEY, TITLE, 1 AS MODULE_CODE FROM AWARD
                    UNION ALL
                    SELECT PROPOSAL_ID AS MODULE_ITEM_KEY, TITLE, 2 AS MODULE_CODE FROM PROPOSAL
                    UNION ALL
                    SELECT PROPOSAL_ID AS MODULE_ITEM_KEY, TITLE, 3 AS MODULE_CODE FROM EPS_PROPOSAL
                ) T ON shh.PREV_MODULE_ITEM_KEY = T.MODULE_ITEM_KEY AND shh.PREV_MODULE_CODE = T.MODULE_CODE
                LEFT JOIN (
                    SELECT AGREEMENT_REQUEST_ID AS MODULE_ITEM_KEY, TITLE, 13 AS MODULE_CODE FROM AGREEMENT_HEADER
                    UNION ALL
                    SELECT AWARD_ID AS MODULE_ITEM_KEY, TITLE, 1 AS MODULE_CODE FROM AWARD
                    UNION ALL
                    SELECT PROPOSAL_ID AS MODULE_ITEM_KEY, TITLE, 2 AS MODULE_CODE FROM PROPOSAL
                    UNION ALL
                    SELECT PROPOSAL_ID AS MODULE_ITEM_KEY, TITLE, 3 AS MODULE_CODE FROM EPS_PROPOSAL
                ) R ON shh.MODULE_ITEM_KEY = R.MODULE_ITEM_KEY AND shh.MODULE_CODE = R.MODULE_CODE
                WHERE shh.ACTION_LOG_ID = sal.ACTION_LOG_ID
                    ), JSON_ARRAY())
                )
            )
			FROM SR_ACTION_LOG sal
			LEFT JOIN SR_ACTION_TYPE sat 
				ON sal.ACTION_TYPE_CODE = sat.ACTION_TYPE_CODE
			LEFT JOIN SR_STATUS ss
				ON sal.STATUS_CODE = ss.STATUS_CODE
            LEFT JOIN person pu 
                ON pu.USER_NAME = sal.UPDATE_USER
			WHERE sal.SR_HEADER_ID = sh.SR_HEADER_ID
        ), JSON_ARRAY()),
        -- TASK Section
		'TASK', IFNULL(
			(SELECT JSON_ARRAYAGG(
				JSON_OBJECT(
					'TASK_ID', st.TASK_ID,
					'TASK_TYPE_CODE', st.TASK_TYPE_CODE,
					'TASK_TYPE_DESCRIPTION', stt.DESCRIPTION,
					'TASK_STATUS_CODE', st.TASK_STATUS_CODE,
					'DESCRIPTION', st.DESCRIPTION,
					'DUE_DATE', st.DUE_DATE,
					'CREATE_TIMESTAMP', st.CREATE_TIMESTAMP,
					'ASSIGNED_ON', st.ASSIGNED_ON,
					'ASSIGNEE_PERSON_NAME', p1.FULL_NAME,
					'CREATE_USER_FULL_NAME', p2.FULL_NAME,
					'ATTACHMENTS', IFNULL(
						(SELECT JSON_ARRAYAGG(
							JSON_OBJECT(
								'ATTACHMENT_ID', sta.ATTACHMENT_ID,
								'FILE_NAME', sta.FILE_NAME,
								'CONTENT_TYPE', sta.CONTENT_TYPE
							)
						)
						FROM sr_task_attachment sta
						WHERE sta.SR_TASK_ID = st.TASK_ID
						), JSON_ARRAY()
					)
				)
			)
			FROM sr_task st
			LEFT JOIN person p1 ON st.ASSIGNEE_PERSON_ID = p1.PERSON_ID
			LEFT JOIN person p2 ON st.CREATE_USER = p2.PERSON_ID
			LEFT JOIN sr_task_type stt ON st.TASK_TYPE_CODE = stt.TASK_TYPE_CODE
			WHERE st.SR_HEADER_ID = sh.SR_HEADER_ID
			), JSON_ARRAY()
		)
    ) AS SERVICE_REQUEST_JSON
    FROM sr_header sh
    LEFT JOIN sr_status ss ON sh.STATUS_CODE = ss.STATUS_CODE
    LEFT JOIN sr_type st ON sh.TYPE_CODE = st.TYPE_CODE
    LEFT JOIN sr_priority sp ON sh.PRIORITY_ID = sp.PRIORITY_ID
    LEFT JOIN sr_category sc ON sh.CATEGORY_CODE = sc.CATEGORY_CODE
    LEFT JOIN unit u ON sh.UNIT_NUMBER = u.UNIT_NUMBER
    LEFT JOIN admin_group ag ON sh.ADMIN_GROUP_ID = ag.ADMIN_GROUP_ID
    WHERE sh.SR_HEADER_ID = AV_SERVICE_REQUEST_ID;
END
