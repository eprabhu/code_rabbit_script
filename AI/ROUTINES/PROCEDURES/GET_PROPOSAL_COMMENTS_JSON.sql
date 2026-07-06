CREATE PROCEDURE `GET_PROPOSAL_COMMENTS_JSON`(
    IN AV_PROPOSAL_ID INT,
    OUT comments JSON
)
BEGIN
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'proposalCommentId', pc.EPS_PROPOSAL_COMMENT_ID,
            'commentType', ct.DESCRIPTION,
            'comment', pc.COMMENTS,
            'isPrivate', pc.IS_PRIVATE,
            'updateTimestamp', pc.UPDATE_TIMESTAMP,
            'updateUser', pc.UPDATE_USER,
            'fullName', per.FULL_NAME,
            'attachments', (
                SELECT IFNULL(JSON_ARRAYAGG(
                    JSON_OBJECT(
                            'commentAttachmentId', pca.COMMENT_ATTACHMENT_ID,
                            'fileName', pca.FILE_NAME,
                            'fileDataId', pca.FILE_DATA_ID,
                            'mimeType', pca.MIME_TYPE,
                            'updateTimestamp', pca.UPDATE_TIMESTAMP,
                            'updateUser', pca.UPDATE_USER
                        )
                    ), JSON_ARRAY()
                )
                FROM EPS_PROPOSAL_COMMENT_ATTACHMENTS pca
                WHERE pca.EPS_PROPOSAL_COMMENT_ID = pc.EPS_PROPOSAL_COMMENT_ID
            )
        )
    ) AS comments INTO comments
    FROM EPS_PROPOSAL_COMMENTS pc
        LEFT JOIN COMMENT_TYPE ct ON pc.COMMENT_TYPE_CODE = ct.COMMENT_TYPE_CODE
        LEFT JOIN PERSON per ON per.USER_NAME = pc.UPDATE_USER
    WHERE pc.PROPOSAL_ID = AV_PROPOSAL_ID
		AND pc.IS_PRIVATE = 'N';
END
