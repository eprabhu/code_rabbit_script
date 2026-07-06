CREATE PROCEDURE `GET_SERVICE_REQUEST_ATTACHMENTS_JSON`(
    IN AV_SERVICE_REQUEST_ID INT,
    OUT attachments JSON
)
BEGIN
    SELECT JSON_ARRAYAGG(attachment_obj) INTO attachments
    FROM (
        SELECT JSON_OBJECT(
            'ATTACHMENT_ID', sra.ATTACHMENT_ID,
            'ACTION_LOG_ID', sra.ACTION_LOG_ID,
            'SR_HEADER_ID', sra.SR_HEADER_ID,
            'fileDataId', sra.FILE_DATA_ID,
            'fileName', sra.FILE_NAME,
            'fileType', SUBSTRING_INDEX(sra.FILE_NAME, '.', -1),
            'ATTACHMENT_TYPE_CODE', sra.ATTACHMENT_TYPE_CODE,
            'ATTACHMENT_TYPE_DESCRIPTION', srat.DESCRIPTION,
            'updateTimestamp', sra.UPDATE_TIMESTAMP,
            'UPDATE_USER', sra.UPDATE_USER,
            'source', 'service_request'
        ) AS attachment_obj
        FROM sr_attachment sra
        LEFT JOIN sr_attachment_type srat 
            ON sra.ATTACHMENT_TYPE_CODE = srat.ATTACHMENT_TYPE_CODE
        WHERE sra.SR_HEADER_ID = AV_SERVICE_REQUEST_ID
        AND srat.IS_PRIVATE = 'N'
        AND NOT EXISTS (
            SELECT 1
            FROM sr_comments scmt
            WHERE scmt.ACTION_LOG_ID = sra.ACTION_LOG_ID
            AND scmt.SR_HEADER_ID = sra.SR_HEADER_ID
            AND scmt.PRIVATE_FLAG = 'Y'
        )
        ORDER BY sra.ACTION_LOG_ID, sra.UPDATE_TIMESTAMP
    ) AS combined_attachments;
END
