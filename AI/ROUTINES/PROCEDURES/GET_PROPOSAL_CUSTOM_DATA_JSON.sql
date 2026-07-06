CREATE PROCEDURE `GET_PROPOSAL_CUSTOM_DATA_JSON`(
    IN AV_PROPOSAL_ID INT,
    OUT custom_data JSON
)
BEGIN
	SELECT JSON_ARRAYAGG(
	  JSON_OBJECT(
		'customElementUsageId', cdu.custom_data_element_usage_id,
		'isRequired', cdu.is_required,
		'orderNumber', cdu.order_number,
		'isRequiredAdvanceSearch', cdu.is_req_advance_search,
		'updateUser', cdu.update_user,
		'updateTimestamp', cdu.update_timestamp,
		'module', m.description,
		'subSection',
            CASE
                WHEN dssc.sub_section_code IS NOT NULL THEN dssc.description
                ELSE NULL
            END,
		'customDataElement', JSON_OBJECT(
            'id', cde.custom_data_elements_id,
            'label', cde.column_label,
            'dataType', dt.description,
            'dataLength', cde.data_length,
            'defaultValue', cde.default_value,
            'customElementName', cde.custom_element_name,
            'isMultiSelectLookup', cde.is_multi_select_lookup,
            'hasLookup', cde.has_lookup,
            'lookupWindow', cde.lookup_window,
            'lookupArgument', cde.lookup_argument,
            'isActive', cde.is_active,
            'helpDescription', cde.help_description,
            'helpLink', cde.help_link
		),
		'answer',
            CASE
                WHEN cd.custom_data_id IS NOT NULL THEN JSON_OBJECT(
                    'value', cd.value,
                    'description', cd.description
                    )
                ELSE NULL
            END
	  )
	) as custom_data
	INTO custom_data
	FROM custom_data_element_usage cdu
		LEFT JOIN custom_data_elements cde ON cde.custom_data_elements_id = cdu.custom_data_elements_id
		LEFT JOIN coeus_module m ON m.module_code = cdu.module_code
		LEFT JOIN dyn_subsection_config dssc ON dssc.sub_section_code = cdu.sub_section_code
		LEFT JOIN custom_data_elements_data_type dt ON dt.data_type_code = cde.data_type
		LEFT JOIN custom_data cd
            ON cd.custom_data_elements_id = cdu.custom_data_elements_id
            AND cd.module_item_code = 3
            AND cd.module_sub_item_code = 0
            AND cd.module_item_key = AV_PROPOSAL_ID
            AND cd.module_sub_item_key = 0
	WHERE cdu.module_code = 3 AND cde.IS_ACTIVE = 'Y';
END
