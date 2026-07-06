CREATE PROCEDURE `GET_PROPOSAL_SUPPORT_QUESTIONS_JSON`(
    IN AV_PROPOSAL_ID INT,
    OUT support_questions JSON
)
BEGIN
    SELECT JSON_OBJECT(
        'supportQuestions', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'preReviewId', pr.PRE_REVIEW_ID,
                    'reviewSectionTypeCode', pr.PRE_REVIEW_SECTION_TYPE_CODE,
                    'reviewSectionDescription', prst.DESCRIPTION,
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
                    'comments', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'preReviewCommentId', prc.PRE_REVIEW_COMMENT_ID,
                                'reviewComment', prc.REVIEW_COMMENT,
                                'updateUser', prc.UPDATE_USER,
                                'updateTimeStamp', prc.UPDATE_TIMESTAMP,
                                'isPrivateComment', prc.IS_PRIVATE_COMMENT,
                                'personId', prc.PERSON_ID,
                                'fullName', prc.FULL_NAME,
                                'attachments', (
                                    SELECT JSON_ARRAYAGG(
                                        JSON_OBJECT(
                                            'preReviewAttachmentId', pra.PRE_REVIEW_ATTACHMENT_ID,
                                            'fileName', pra.FILE_NAME,
                                            'fileDataId', pra.FILE_DATA_ID,
                                            'mimeType', pra.MIME_TYPE,
                                            'updateUser', pra.UPDATE_USER,
                                            'updateTimeStamp', pra.UPDATE_TIMESTAMP
                                        )
                                    )
                                    FROM PRE_REVIEW_ATTACHMENT pra
                                    WHERE pra.PRE_REVIEW_COMMENT_ID = prc.PRE_REVIEW_COMMENT_ID
                                )
                            )
                        )
                        FROM PRE_REVIEW_COMMENT prc
                        WHERE prc.PRE_REVIEW_ID = pr.PRE_REVIEW_ID
                    )
                )
            )
            FROM PRE_REVIEW pr
                LEFT JOIN PRE_REVIEW_SECTION_TYPE prst ON pr.PRE_REVIEW_SECTION_TYPE_CODE = prst.PRE_REVIEW_SECTION_TYPE_CODE
                LEFT JOIN PRE_REVIEW_STATUS prs ON pr.PRE_REVIEW_STATUS_CODE = prs.PRE_REVIEW_STATUS_CODE
            WHERE pr.MODULE_ITEM_KEY = AV_PROPOSAL_ID
                AND pr.PRE_REVIEW_TYPE_CODE = '2'
        )
    ) AS result INTO support_questions;
END
