


CREATE PROCEDURE `GET_ENTITY_MANDATORY_FIELDS`()
BEGIN

SELECT 
        JSON_OBJECT(
            'Overview', JSON_ARRAY(
                'entityName',
                'entityOwnershipTypeCode',
                'primaryAddressLine1',
                'city',
                'state',
                'postCode',
                'countryCode',
                'sponsorAddressType',
                'organizationAddressType'
            ),
            'Sponsor', JSON_ARRAY(
                'sponsorTypeCode'
            ),
            'Organization', JSON_ARRAY(
                'organizationTypeCode',
                'entityRisks'
            )
        ) AS mandatory_fields;
END