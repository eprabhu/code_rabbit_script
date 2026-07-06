

CREATE PROCEDURE `VALIDATE_ENTITY_MANDATORY_FIELDS`(IN entityId INT)
BEGIN
    DECLARE overview_filled JSON;
    DECLARE sponsor_filled JSON;
    DECLARE organization_filled JSON;
    DECLARE result JSON;
    DECLARE li_sao_count INT DEFAULT 0;
    DECLARE li_address_count INT DEFAULT 0;
    DECLARE li_sponsor_type_code VARCHAR(1);
    DECLARE li_org_type_code VARCHAR(1);
    DECLARE LS_COUNTRY_CODE VARCHAR(3);

    DECLARE overview_valid BOOLEAN DEFAULT TRUE;
    DECLARE sponsor_valid BOOLEAN DEFAULT TRUE;
    DECLARE organization_valid BOOLEAN DEFAULT TRUE;
    
    DECLARE validation_message VARCHAR(255);
    DECLARE validation_type VARCHAR(2);

    DECLARE all_null BOOLEAN DEFAULT TRUE;

	SELECT COUNTRY_CODE INTO LS_COUNTRY_CODE FROM ENTITY WHERE ENTITY_ID = entityId;

    IF LS_COUNTRY_CODE IN ('CAN', 'USA') THEN
    
    SELECT JSON_OBJECT(
        'entityName', PRIMARY_NAME IS NOT NULL,
        'primaryAddressLine1', PRIMARY_ADDRESS_LINE_1 IS NOT NULL,
        'city', city IS NOT NULL,
        'state', state IS NOT NULL,
        'postCode', POST_CODE IS NOT NULL,
        'countryCode', COUNTRY_CODE IS NOT NULL
    )
    INTO overview_filled
    FROM entity
    WHERE entity_Id = entityId;
    
    IF overview_filled IS NULL OR 
       JSON_UNQUOTE(overview_filled->'$.entityName') = 'false' OR
       JSON_UNQUOTE(overview_filled->'$.primaryAddressLine1') = 'false' OR
       JSON_UNQUOTE(overview_filled->'$.city') = 'false' OR
       JSON_UNQUOTE(overview_filled->'$.state') = 'false' OR
       JSON_UNQUOTE(overview_filled->'$.postCode') = 'false' OR
       JSON_UNQUOTE(overview_filled->'$.countryCode') = 'false' THEN
        SET overview_valid = FALSE;
    END IF;

    ELSE
    

	SELECT JSON_OBJECT(
        'entityName', PRIMARY_NAME IS NOT NULL,
        'primaryAddressLine1', PRIMARY_ADDRESS_LINE_1 IS NOT NULL,
        'city', city IS NOT NULL,
        'countryCode', COUNTRY_CODE IS NOT NULL
    )
    INTO overview_filled
    FROM entity
    WHERE entity_Id = entityId;

    IF overview_filled IS NULL OR 
       JSON_UNQUOTE(overview_filled->'$.entityName') = 'false' OR
       JSON_UNQUOTE(overview_filled->'$.primaryAddressLine1') = 'false' OR
       JSON_UNQUOTE(overview_filled->'$.city') = 'false' OR
       JSON_UNQUOTE(overview_filled->'$.countryCode') = 'false' THEN
        SET overview_valid = FALSE;
    END IF;

    END IF;

	SELECT COUNT(*) INTO li_address_count
	FROM ENTITY_MAILING_ADDRESS EMA
	WHERE EMA.ENTITY_ID = entityId
	AND EMA.ADDRESS_TYPE_CODE = '3';
        
	SELECT COUNT(*) INTO li_sponsor_type_code
	FROM entity_sponsor_info
	WHERE entity_id = entityId
    AND SPONSOR_TYPE_CODE IS NOT NULL;
    
    SELECT JSON_OBJECT(
        'sponsorTypeCode', li_sponsor_type_code > 0,
        'sponsorAddress', li_address_count > 0
    )
	INTO sponsor_filled;
    
    IF sponsor_filled IS NULL OR 
       JSON_UNQUOTE(sponsor_filled->'$.sponsorTypeCode') = 'false' OR
	   JSON_UNQUOTE(sponsor_filled->'$.sponsorAddress') = 'false' THEN
        SET sponsor_valid = FALSE;
    END IF;

    SELECT COUNT(*) INTO li_sao_count
    FROM entity_risk ER
    INNER JOIN entity_risk_type ERT ON ER.RISK_TYPE_CODE = ERT.RISK_TYPE_CODE
    WHERE ER.ENTITY_ID = entityId
    AND ERT.RISK_CATEGORY_CODE = 'OR';

	SELECT COUNT(*) INTO li_address_count
	FROM ENTITY_MAILING_ADDRESS EMA
	WHERE EMA.ENTITY_ID = entityId
	AND EMA.ADDRESS_TYPE_CODE = '4';
    
    SELECT COUNT(*) INTO li_org_type_code
	FROM entity_sub_org_info
	WHERE entity_id = entityId
    AND ORGANIZATION_TYPE_CODE IS NOT NULL;
    
    SELECT JSON_OBJECT(
        'organizationTypeCode', li_org_type_code > 0,
        'entityRisks', li_sao_count > 0,
        'organizationAddress', li_address_count > 0
    )
	INTO organization_filled;

    IF organization_filled IS NULL OR 
       JSON_UNQUOTE(organization_filled->'$.organizationTypeCode') = 'false' OR
       JSON_UNQUOTE(organization_filled->'$.entityRisks') = 'false' OR
	   JSON_UNQUOTE(organization_filled->'$.organizationAddress') = 'false' THEN
        SET organization_valid = FALSE;
    END IF;

    IF overview_valid THEN
        SET validation_message = 'Overview Information is complete.';
        SET validation_type = null;
    ELSE
        SET validation_message = 'Overview Information is incomplete.';
        SET validation_type = 'VE';
        SET all_null = FALSE;
    END IF;

	SET overview_filled = COALESCE(overview_filled, 
		(SELECT JSON_OBJECT(
			'entityName', false,
			'primaryAddressLine1', false,
			'city', false,
			'state', false,
			'postCode', false,
			'countryCode', false
		))
	);
    SET result = JSON_OBJECT(
        'ValidationType', validation_type,
        'ValidationMessage', validation_message,
        'Overview', overview_filled
    );

    IF sponsor_valid THEN
        SET validation_message = 'Sponsor Information is complete.';
        SET validation_type = null;
    ELSE
        SET validation_message = 'Sponsor Information is incomplete.';
        SET validation_type = 'VW';
        SET all_null = FALSE;
    END IF;

	SET sponsor_filled = COALESCE(sponsor_filled, 
		(SELECT JSON_OBJECT(
			'sponsorTypeCode', false,
            'sponsorAddress', false
		))
	);
    
    SET result = JSON_ARRAY_APPEND(result, '$',
        JSON_OBJECT(
            'ValidationType', validation_type,
            'ValidationMessage', validation_message,
            'Sponsor', sponsor_filled
        )
    );

    IF organization_valid THEN
        SET validation_message = 'Organization Information is complete.';
        SET validation_type = null;
    ELSE
        SET validation_message = 'Organization Information is incomplete.';
        SET validation_type = 'VW';
        SET all_null = FALSE;
    END IF;
    
    SET organization_filled = COALESCE(organization_filled, 
		(SELECT JSON_OBJECT(
			'organizationTypeCode', false,
			'entityRisks', false,
            'organizationAddress', false
		))
	);

    SET result = JSON_ARRAY_APPEND(result, '$',
        JSON_OBJECT(
            'ValidationType', validation_type,
            'ValidationMessage', validation_message,
            'Organization', organization_filled
        )
    );

    -- Check if all validation types are null
    -- IF all_null THEN
    --    SET result = JSON_ARRAY();  -- Return an empty JSON array
    -- END IF;

    SELECT result AS fields_status;
END
