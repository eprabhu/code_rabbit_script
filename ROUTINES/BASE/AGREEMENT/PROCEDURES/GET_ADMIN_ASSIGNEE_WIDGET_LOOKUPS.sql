CREATE PROCEDURE `GET_ADMIN_ASSIGNEE_WIDGET_LOOKUPS`()
BEGIN
	(
 SELECT JSON_OBJECT(
        'agreementStatusesLookUp', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'statusCode', T.AGREEMENT_STATUS_CODE,
                    'description', T.DESCRIPTION
                )
            ) as lookUp
            FROM 
            (SELECT DISTINCT T1.AGREEMENT_STATUS_CODE, T1.DESCRIPTION FROM AGREEMENT_STATUS T1 WHERE T1.IS_ACTIVE = 'Y') T
        ),
        'agreementCategoryLookUp', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'categoryCode', CATEGORY_CODE,
                    'description', DESCRIPTION
                )
            ) as lookUp
            FROM AGREEMENT_CATEGORY
            WHERE IS_ACTIVE = 'Y'
        ),
        'agreementLocationStatusLookUp', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'locationStatusCode', LOCATION_STATUS_CODE,
                    'description', DESCRIPTION
                )
            ) as lookUp
            FROM NEGOTIATION_LOCATION_STATUS
            WHERE IS_ACTIVE = 'Y'
        )
    ) AS widgetDetails
        );
END
