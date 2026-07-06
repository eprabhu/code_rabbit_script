CREATE PROCEDURE `GET_PROPOSAL_ATTACHMENTS_JSON`(
    IN AV_PROPOSAL_ID INT,
    OUT attachments JSON
)
BEGIN
    SELECT JSON_ARRAYAGG(attachment_obj) INTO attachments
    FROM (
        -- Main proposal attachments
        SELECT JSON_OBJECT(
            'description', pa.DESCRIPTION,
            'fileName', pa.FILE_NAME,
            'fileType', SUBSTRING_INDEX(pa.FILE_NAME, '.', -1),
            'mimeType', pa.MIME_TYPE,
            'updateTimestamp', pa.UPDATE_TIMESTAMP,
            'updateUser', pa.UPDATE_USER,
            'narrativeStatus', ns.DESCRIPTION,
            'versionNumber', pa.VERSION_NUMBER,
            'fileDataId', pa.FILE_DATA_ID,
            'documentStatus', ds.DESCRIPTION,
            'category', at.DESCRIPTION,
            'documentId', pa.DOCUMENT_ID,
            'source', 'proposal'
        ) AS attachment_obj
        FROM EPS_PROPOSAL_ATTACHMENTS pa
            LEFT JOIN EPS_PROPOSAL_ATTACH_TYPE at ON pa.ATTACHMNT_TYPE_CODE = at.ATTACHMNT_TYPE_CODE
            LEFT JOIN NARRATIVE_STATUS ns ON pa.NARRATIVE_STATUS_CODE = ns.NARRATIVE_STATUS_CODE
            LEFT JOIN DOCUMENT_STATUS ds ON pa.DOCUMENT_STATUS_CODE = ds.DOCUMENT_STATUS_CODE
        WHERE pa.PROPOSAL_ID = AV_PROPOSAL_ID
			AND ds.DOCUMENT_STATUS_CODE = 1
            AND at.IS_PRIVATE = 'N'

        UNION ALL

        -- Person-level attachments with joins
        SELECT JSON_OBJECT(
            'proposalPersonId', ppa.PROPOSAL_PERSON_ID,
            'personName', ppp.FULL_NAME,
            'description', ppa.DESCRIPTION,
            'fileName', ppa.FILE_NAME,
            'fileType', SUBSTRING_INDEX(ppa.FILE_NAME, '.', -1),
            'mimeType', ppa.MIME_TYPE,
            'updateTimestamp', ppa.UPDATE_TIMESTAMP,
            'updateUser', ppa.UPDATE_USER,
            'versionNumber', ppa.VERSION_NUMBER,
            'fileDataId', ppa.FILE_DATA_ID,
            'documentStatus', ds.DESCRIPTION,
            'attachmentType', kpat.DESCRIPTION,
            'category', kpat.DESCRIPTION,
            'documentId', ppa.DOCUMENT_ID,
            'source', 'person'
        ) AS attachment_obj
        FROM eps_proposal_person_attachmnt ppa
            LEFT JOIN EPS_PROPOSAL_KEY_PERSONNEL_ATTACH_TYPE kpat ON ppa.ATTACHMNT_TYPE_CODE = kpat.ATTACHMNT_TYPE_CODE
            LEFT JOIN DOCUMENT_STATUS ds ON ppa.DOCUMENT_STATUS_CODE = ds.DOCUMENT_STATUS_CODE
			INNER JOIN eps_proposal_persons ppp ON ppp.proposal_person_id = ppa.PROPOSAL_PERSON_ID
			    AND ppp.proposal_id = AV_PROPOSAL_ID
			AND ds.DOCUMENT_STATUS_CODE = 1
            AND kpat.IS_PRIVATE = 'N'

		UNION ALL

        -- Questionnaire Answer Attachments
        SELECT JSON_OBJECT(
            'fileDataId', qaa.QUESTIONNAIRE_ANSWER_ATT_ID,
            'questionnaireAnswerId', qaa.QUESTIONNAIRE_ANSWER_ID,
            'fileName', qaa.FILE_NAME,
            'fileType', SUBSTRING_INDEX(qaa.FILE_NAME, '.', -1),
            'mimeType', qaa.CONTENT_TYPE,
            'updateTimestamp', qaa.UPDATE_TIMESTAMP,
            'updateUser', qaa.UPDATE_USER,
            'questionId', qq.QUESTION_ID,
            'question', qq.QUESTION,
            'category', CONCAT('Questionnaire Attachment'),
            'source', 'questionnaire'
        ) AS attachment_obj
        FROM quest_answer_attachment qaa
            INNER JOIN quest_answer qa ON qa.QUESTIONNAIRE_ANSWER_ID = qaa.QUESTIONNAIRE_ANSWER_ID
            INNER JOIN quest_question qq ON qq.QUESTION_ID = qa.QUESTION_ID
            INNER JOIN quest_answer_header qah ON qah.QUESTIONNAIRE_ANS_HEADER_ID = qa.QUESTIONNAIRE_ANS_HEADER_ID
            INNER JOIN quest_header qh ON qh.QUESTIONNAIRE_ID = qah.QUESTIONNAIRE_ID
        WHERE qah.MODULE_ITEM_KEY = AV_PROPOSAL_ID

        UNION ALL

		-- Comment attachments (with comment text)
		SELECT JSON_OBJECT(
            'commentId', pc.EPS_PROPOSAL_COMMENT_ID,
            'comment', pc.COMMENTS,
            'attachmentId', pca.COMMENT_ATTACHMENT_ID,
            'fileName', pca.FILE_NAME,
            'fileDataId', pca.FILE_DATA_ID,
            'fileType', SUBSTRING_INDEX(pca.FILE_NAME, '.', -1),
            'mimeType', pca.MIME_TYPE,
            'updateTimestamp', pca.UPDATE_TIMESTAMP,
            'updateUser', pca.UPDATE_USER,
            'lastUpdateUserFullName', per.FULL_NAME,
            'category', CONCAT('Comment Attachment'),
            'source', 'comment'
		) AS attachment_obj
		FROM EPS_PROPOSAL_COMMENT_ATTACHMENTS pca
            INNER JOIN EPS_PROPOSAL_COMMENTS pc ON pc.EPS_PROPOSAL_COMMENT_ID = pca.EPS_PROPOSAL_COMMENT_ID
            LEFT JOIN PERSON per ON per.USER_NAME = pca.UPDATE_USER
		WHERE pc.PROPOSAL_ID = AV_PROPOSAL_ID
			AND pc.IS_PRIVATE = 'N'

        UNION ALL

        -- External Review Attachments
        SELECT JSON_OBJECT(
            'extReviewId', era.EXT_REVIEW_ID,
            'extReviewAttachmentId', era.EXT_REVIEW_ATTACHMENT_ID,
            'description', era.DESCRIPTION,
            'fileName', era.FILE_NAME,
            'fileType', SUBSTRING_INDEX(era.FILE_NAME, '.', -1),
            'attachmentType', erat.DESCRIPTION,
            'fileDataId', era.FILE_DATA_ID,
            'isAttachmentMandatory', era.IS_ATTACHMENT_MANDATORY,
            'updateTimestamp', era.UPDATE_TIMESTAMP,
            'updateUser', era.UPDATE_USER,
            'category', CONCAT('External Review Attachment'),
            'source', 'externalReview'
        ) AS attachment_obj
        FROM ext_review_attachments era
            INNER JOIN ext_review er ON er.EXT_REVIEW_ID = era.EXT_REVIEW_ID
            LEFT JOIN ext_review_attachment_type erat ON era.ATTACHMENT_TYPE_CODE = erat.ATTACHMENT_TYPE_CODE
        WHERE er.MODULE_ITEM_KEY = AV_PROPOSAL_ID

        UNION ALL

        -- Pre-Review Attachments (from comments)
        SELECT JSON_OBJECT(
            'preReviewId', pr.PRE_REVIEW_ID,
            'preReviewCommentId', c.PRE_REVIEW_COMMENT_ID,
            'preReviewAttachmentId', a.PRE_REVIEW_ATTACHMENT_ID,
            'fileName', a.FILE_NAME,
            'fileDataId', a.FILE_DATA_ID,
            'fileType', SUBSTRING_INDEX(a.FILE_NAME, '.', -1),
            'mimeType', a.MIME_TYPE,
            'updateTimestamp', a.UPDATE_TIMESTAMP,
            'updateUser', a.UPDATE_USER,
            'category', CONCAT('Pre-Review Comment Attachment'),
            'source', 'preReview'
        ) AS attachment_obj
        FROM PRE_REVIEW_ATTACHMENT a
            INNER JOIN PRE_REVIEW_COMMENT c ON c.PRE_REVIEW_COMMENT_ID = a.PRE_REVIEW_COMMENT_ID
            INNER JOIN PRE_REVIEW pr ON pr.PRE_REVIEW_ID = c.PRE_REVIEW_ID
        WHERE pr.MODULE_ITEM_KEY = AV_PROPOSAL_ID
			AND pr.PRE_REVIEW_TYPE_CODE = '1'

        UNION ALL

        -- Workflow (Route Log) Attachments
        SELECT JSON_OBJECT(
            'fileDataId', wat.ATTACHMENT_ID,
            'description', wat.DESCRIPTION,
            'fileName', wat.FILE_NAME,
            'fileType', SUBSTRING_INDEX(wat.FILE_NAME, '.', -1),
            'mimeType', wat.MIME_TYPE,
            'updateTimestamp', wat.UPDATE_TIMESTAMP,
            'updateUser', wat.UPDATE_USER,
            'workflowDetailId', wat.WORKFLOW_DETAIL_ID,
            'reviewerDetailsId', wat.REVIEWER_DETAILS_ID,
            'category', 'Workflow Attachment',
            'source', 'workflow'
        ) AS attachment_obj
        FROM workflow_attachment wat
        WHERE EXISTS (
            SELECT 1
            FROM WORKFLOW_DETAIL wd
                INNER JOIN WORKFLOW w ON w.WORKFLOW_ID = wd.WORKFLOW_ID
            WHERE wd.WORKFLOW_DETAIL_ID = wat.WORKFLOW_DETAIL_ID
                AND w.MODULE_ITEM_ID = AV_PROPOSAL_ID
                AND w.MODULE_CODE = '3'
                AND w.IS_WORKFLOW_ACTIVE = 'Y'
        )

    ) AS combined_attachments;
END
