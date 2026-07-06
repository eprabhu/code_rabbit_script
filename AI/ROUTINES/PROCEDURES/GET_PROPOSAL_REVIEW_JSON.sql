CREATE PROCEDURE `GET_PROPOSAL_REVIEW_JSON`(
    IN AV_PROPOSAL_ID INT,
    OUT combined_review_json JSON
)
BEGIN
    SELECT JSON_OBJECT(
        'preReviews', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'preReviewId', pr.PRE_REVIEW_ID,
                    'moduleItemCode', pr.MODULE_ITEM_CODE,
                    'moduleSubItemCode', pr.MODULE_SUB_ITEM_CODE,
                    'moduleItemKey', pr.MODULE_ITEM_KEY,
                    'moduleSubItemKey', pr.MODULE_SUB_ITEM_KEY,
                    'reviewTypeCode', pr.PRE_REVIEW_TYPE_CODE,
                    'reviewTypeDescription', prt.DESCRIPTION,
                    'reviewSectionTypeCode', pr.PRE_REVIEW_SECTION_TYPE_CODE,
                    'reviewSectionTypeDescription', prst.DESCRIPTION,
                    'reviewStatusCode', pr.PRE_REVIEW_STATUS_CODE,
                    'reviewStatusDescription', prs.DESCRIPTION,
                    'reviewerPersonId', pr.REVIEWER_PERSON_ID,
                    'reviewerFullName', pr.REVIEWER_FULLNAME,
                    'reviewerEmailAddress', pr.REVIEWER_EMAIL,
                    'requestorPersonId', pr.REQUESTOR_PERSON_ID,
                    'requestorFullName', pr.REQUESTOR_FULLNAME,
                    'requestorEmailAddress', pr.REQUESTOR_EMAIL,
                    'requestorComment', pr.REQUESTOR_COMMENT,
                    'requestDate', pr.REQUEST_DATE,
                    'completionDate', pr.COMPLETION_DATE,
                    'updateTimestamp', pr.UPDATE_TIMESTAMP,
                    'updateUser', pr.UPDATE_USER,
                    'comments', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'preReviewCommentId', c.PRE_REVIEW_COMMENT_ID,
                                'reviewComment', c.REVIEW_COMMENT,
                                'isPrivateComment', c.IS_PRIVATE_COMMENT,
                                'updateTimestamp', c.UPDATE_TIMESTAMP,
                                'updateUser', c.UPDATE_USER,
                                'personId', c.PERSON_ID,
                                'fullName', c.FULL_NAME,
                                'attachments', (
                                    SELECT JSON_ARRAYAGG(
                                        JSON_OBJECT(
                                            'preReviewAttachmentId', a.PRE_REVIEW_ATTACHMENT_ID,
                                            'fileName', a.FILE_NAME,
                                            'fileDataId', a.FILE_DATA_ID,
                                            'mimeType', a.MIME_TYPE,
                                            'updateTimestamp', a.UPDATE_TIMESTAMP,
                                            'updateUser', a.UPDATE_USER
                                        )
                                    )
                                    FROM PRE_REVIEW_ATTACHMENT a
                                    WHERE a.PRE_REVIEW_COMMENT_ID = c.PRE_REVIEW_COMMENT_ID
                                )
                            )
                        )
                        FROM PRE_REVIEW_COMMENT c
                        WHERE c.PRE_REVIEW_ID = pr.PRE_REVIEW_ID
                    )
                )
            )
            FROM PRE_REVIEW pr
                LEFT JOIN PRE_REVIEW_TYPE prt ON pr.PRE_REVIEW_TYPE_CODE = prt.PRE_REVIEW_TYPE_CODE
                LEFT JOIN PRE_REVIEW_SECTION_TYPE prst ON pr.PRE_REVIEW_SECTION_TYPE_CODE = prst.PRE_REVIEW_SECTION_TYPE_CODE
                LEFT JOIN PRE_REVIEW_STATUS prs ON pr.PRE_REVIEW_STATUS_CODE = prs.PRE_REVIEW_STATUS_CODE
            WHERE pr.MODULE_ITEM_KEY = AV_PROPOSAL_ID
                AND pr.PRE_REVIEW_TYPE_CODE = '1'
        ),
        'externalReviews', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'extReviewId', er.EXT_REVIEW_ID,
                    'fibiReviewId', er.FIBI_REVIEW_ID,
                    'moduleItemCode', er.MODULE_ITEM_CODE,
                    'moduleSubItemCode', er.MODULE_SUB_ITEM_CODE,
                    'moduleItemKey', er.MODULE_ITEM_KEY,
                    'moduleSubItemKey', er.MODULE_SUB_ITEM_KEY,
                    'reviewModuleCode', er.REVIEW_MODULE_CODE,
                    'extReviewServiceTypeCode', er.EXT_REVIEW_SERVICE_TYPE_CODE,
                    'serviceTypeDescription', erst.DESCRIPTION,
                    'description', er.DESCRIPTION,
                    'extReviewStatusCode', er.EXT_REVIEW_STATUS_CODE,
                    'statusDescription', ers.DESCRIPTION,
                    'reviewRequestorId', er.REVIEW_REQUESTOR_ID,
                    'requestDate', er.REQUEST_DATE,
                    'deadlineDate', er.DEADLINE_DATE,
                    'completionDate', er.COMPLETION_DATE,
                    'updateTimestamp', er.UPDATE_TIMESTAMP,
                    'updateUser', er.UPDATE_USER,
                    'preProposalExtReviewId', er.PRE_PROPOSAL_EXT_REVIEW_ID,
                    'versionNumber', er.VERSION_NUMBER,
                    'attachments', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'extReviewAttachmentId', era.EXT_REVIEW_ATTACHMENT_ID,
                                'description', era.DESCRIPTION,
                                'fileName', era.FILE_NAME,
                                'attachmentTypeCode', era.ATTACHMENT_TYPE_CODE,
                                'fileDataId', era.FILE_DATA_ID,
                                'isAttachmentMandatory', era.IS_ATTACHMENT_MANDATORY,
                                'updateTimestamp', era.UPDATE_TIMESTAMP,
                                'updateUser', era.UPDATE_USER
                            )
                        )
                        FROM ext_review_attachments era
                        WHERE era.EXT_REVIEW_ID = er.EXT_REVIEW_ID
                    )
                )
            )
            FROM EXT_REVIEW er
                LEFT JOIN EXT_REVIEW_SERVICE_TYPE erst ON er.EXT_REVIEW_SERVICE_TYPE_CODE = erst.EXT_REVIEW_SERVICE_TYPE_CODE
                LEFT JOIN EXT_REVIEW_STATUS ers ON er.EXT_REVIEW_STATUS_CODE = ers.EXT_REVIEW_STATUS_CODE
            WHERE er.MODULE_ITEM_KEY = AV_PROPOSAL_ID
        )
    ) AS combined_review_json INTO combined_review_json;
END
