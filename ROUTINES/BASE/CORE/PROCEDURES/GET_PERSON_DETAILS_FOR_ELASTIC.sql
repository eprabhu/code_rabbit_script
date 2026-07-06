CREATE PROCEDURE `GET_PERSON_DETAILS_FOR_ELASTIC`(
	IN AV_PERSON_ID VARCHAR(40)
)
BEGIN

    SELECT 'ID',
           'Full Name',
           'Status',
           'Email',
           'Home Unit'

    UNION

    SELECT 
        P.PERSON_ID,
        P.FULL_NAME,
        CASE 
            WHEN P.STATUS = 'A' THEN 'Active'
            WHEN P.STATUS = 'I' THEN 'Inactive'
            ELSE ''
        END AS STATUS,
        P.EMAIL_ADDRESS,
        U.DISPLAY_NAME

    FROM PERSON P
    LEFT OUTER JOIN UNIT U ON P.HOME_UNIT = U.UNIT_NUMBER
    WHERE P.PERSON_ID = AV_PERSON_ID;
END
