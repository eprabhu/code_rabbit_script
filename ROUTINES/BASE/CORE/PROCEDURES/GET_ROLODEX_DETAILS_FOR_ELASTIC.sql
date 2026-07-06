CREATE PROCEDURE `GET_ROLODEX_DETAILS_FOR_ELASTIC`(
	IN AV_MODULE_ITEM_ID INT
)
BEGIN

    SELECT 'ID',
           'Full Name',
           'Status',
           'Email',
           'Address'

    UNION

    SELECT 
        R.ROLODEX_ID,
        R.FULL_NAME,
        CASE 
            WHEN R.IS_ACTIVE = 'Y' THEN 'Active'
            WHEN R.IS_ACTIVE = 'N' THEN 'Inactive'
            ELSE ''
        END AS STATUS,
        R.EMAIL_ADDRESS,
        CONCAT_WS(', ',
            NULLIF(R.ADDRESS_LINE_1, ''),
            NULLIF(R.ADDRESS_LINE_2, ''),
            NULLIF(R.ADDRESS_LINE_3, '')
        ) AS ADDRESS

    FROM ROLODEX R

    WHERE R.ROLODEX_ID = AV_MODULE_ITEM_ID;
END
