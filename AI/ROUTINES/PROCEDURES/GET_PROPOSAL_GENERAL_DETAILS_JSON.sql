CREATE PROCEDURE `GET_PROPOSAL_GENERAL_DETAILS_JSON`(
    IN AV_PROPOSAL_ID INT,
    OUT full_proposal JSON
)
BEGIN
    SELECT JSON_OBJECT(
        'generalInformation', (
            SELECT
            json_object(
                'grantCallId', p.grant_header_id,
                'proposalStatus', ps.description,
                'proposalType', pt.description,
                'canMergeToIp', pt.can_merge_to_ip,
                'title', p.title,
                'startDate', p.start_date,
                'endDate', p.end_date,
                'submissionDate', p.submission_date,
                'internalDeadlineDate', p.internal_deadline_date,
                'abstractDescription', p.abstract_desc,
                'fundingStrategy', p.funding_strategy,
                'details', p.details,
                'deliverables', p.deliverables,
                'researchDescription', p.research_area_desc,
                'createTimestamp', p.create_timestamp,
                'createUser', p.create_user,
                'updateTimestamp', p.update_timestamp,
                'updateUser', p.update_user,
                'ipNumber', p.ip_number,
                'sponsorDeadlineDate', p.sponsor_deadline_date,
                'isEndorsedOnce', p.is_endorsed_once,
                'proposalRank', p.proposal_rank,
                'applicationId', p.application_id,
                'multiDisciplinaryDescription', p.multi_disciplinary_desc,
                'duration', p.duration,
                'proposalKeywords', (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'keywordId', pk.keyword_id,
                            'keyword', pk.keyword,
                            'updateTimestamp', pk.update_timestamp,
                            'updateUser', pk.update_user,
                            'scienceKeyword', sk.description
                        )
                    )
                    FROM eps_proposal_keywords pk
                        LEFT JOIN science_keyword sk ON pk.science_keyword_code = sk.science_keyword_code
                    WHERE pk.proposal_id = p.proposal_id
                ),
                'grantCallType', json_object(
                    'grantCallType', gct.description,
                    'updateTimestamp', gct.update_timestamp,
                    'updateUser', gct.update_user,
                    'isActive', gct.is_active,
                    'grantCallCategory', gcc.description
                ),
                'homeUnitNumber', p.home_unit_number,
                'homeUnitName', p.home_unit_name,
                'unit', json_object(
                    'unitNumber', u.unit_number,
                    'unitName', u.unit_name,
                    'unitType', ut.description,
                    'unitAdministrators', (
                        SELECT json_arrayagg(
                            json_object(
                                'personId', ua.person_id,
                                'unitAdministratorTypeCode', ua.unit_administrator_type_code,
                                'unitAdministratorType', json_object(
                                    'code', uat.unit_administrator_type_code,
                                    'description', uat.description
                                )
                            )
                        )
                        FROM unit_administrator ua
                            LEFT JOIN unit_administrator_type uat
                            ON ua.unit_administrator_type_code = uat.unit_administrator_type_code
                        WHERE ua.unit_number = u.unit_number
                    )
                ),
                'activityType', json_object(
                    'activityTypeCode', at.activity_type_code,
                    'description', at.description,
                    'higherEducationFunctionCode', at.higher_education_function_code
                ),
                'sponsor', json_object(
                    'sponsorName', s.sponsor_name,
                    'sponsorType', st.description,
                    'acronym', s.acronym,
                    'emailAddress', s.email_address,
                    'phoneNumber', s.phone_number,
                    'country', c.country_name,
                    'unit', json_object(
                        'unitNumber', su.unit_number,
                        'unitName', su.unit_name
                    ),
                    'rolodex',
                    CASE
                        WHEN r.rolodex_id IS NOT NULL THEN json_object(
                            'rolodexId', r.rolodex_id,
                            'fullName', r.full_name,
                            'emailAddress', r.email_address,
                            'phoneNumber', r.phone_number,
                            'organization', r.organization_name
                        )
                        ELSE NULL
                    END
                ),
                'submitUser', p.submit_user,
                'sponsorProposalNumber', p.sponsor_proposal_number,
                'awardType',  awt.description,
                'primeSponsorCode', p.prime_sponsor_code,
                'primeSponsor', json_object(
                    'sponsorCode', ps2.sponsor_code,
                    'sponsorName', ps2.sponsor_name,
                    'sponsorType', pst.description,
                    'unit', json_object(
                        'unitNumber', psu.unit_number,
                        'unitName', psu.unit_name
                    ),
                    'country', c.country_name,
                    'rolodex',
                    CASE
                        WHEN psr.rolodex_id IS NOT NULL THEN json_object(
                            'rolodexId', psr.rolodex_id,
                            'firstName', psr.first_name,
                            'lastName', psr.last_name,
                            'emailAddress', psr.email_address
                        )
                        ELSE NULL
                    END
                ),
                'baseProposalNumber', p.base_proposal_number,
                'programAnnouncementNumber', p.program_announcement_number,
                'cfdaNumber', p.cfda_number,
                'externalFundingAgencyId', p.external_funding_agency_id,
                'disciplineCluster', dc.description,
                'isEligibilityCriteriaMet', p.is_eligible_criteria_met,
                'evaluationRecommendation', er.description,
                'awardNumber', p.award_number,
                'documentStatus', ds.description,
                'sourceProposalId', p.source_proposal_id
            )
            FROM eps_proposal p
                LEFT JOIN eps_proposal_status ps ON p.status_code = ps.status_code
                LEFT JOIN eps_proposal_type pt ON p.type_code = pt.type_code
                LEFT JOIN grant_call_type gct ON p.grant_type_code = gct.grant_type_code
                LEFT JOIN grant_call_category gcc ON gct.grant_call_category_code = gcc.grant_call_category_code
                LEFT JOIN unit u ON p.home_unit_number = u.unit_number
                LEFT JOIN unit_type ut ON u.unit_type_id = ut.unit_type_id
                LEFT JOIN activity_type at ON p.activity_type_code = at.activity_type_code
                LEFT JOIN sponsor s ON p.sponsor_code = s.sponsor_code
                LEFT JOIN sponsor ps2 ON p.prime_sponsor_code = ps2.sponsor_code
                LEFT JOIN award_type awt ON p.award_type_code = awt.award_type_code
                LEFT JOIN eps_prop_discipline_cluster dc ON p.cluster_code = dc.cluster_code
                LEFT JOIN evaluation_recommendation er ON p.evaluation_recommendation_code = er.evaluation_recommendation_code
                LEFT JOIN eps_proposal_document_status ds ON p.document_status_code = ds.document_status_code
                LEFT JOIN sponsor_type st ON s.sponsor_type_code = st.sponsor_type_code
                LEFT JOIN unit su ON s.owned_by_unit = su.unit_number
                LEFT JOIN country c ON s.country_code = c.country_code
                LEFT JOIN rolodex r ON s.rolodex_id = r.rolodex_id
                LEFT JOIN sponsor_type pst ON ps2.sponsor_type_code = pst.sponsor_type_code
                LEFT JOIN unit psu ON ps2.owned_by_unit = psu.unit_number
                LEFT JOIN country psc ON ps2.country_code = psc.country_code
                LEFT JOIN rolodex psr ON ps2.rolodex_id = psr.rolodex_id
            WHERE p.proposal_id = AV_PROPOSAL_ID
        ),
        'proposalPersons', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'proposalPersonId', pp.proposal_person_id,
                    'proposalId', pp.proposal_id,
                    'personId', pp.person_id,
                    'fullName', pp.full_name,
                    'personRole', ppr.description,
                    'effortPercentage', pp.PERCENTAGE_OF_EFFORT,
                    'units', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'unitNumber', ppu.unit_number,
                                'leadUnitFlag', ppu.lead_unit_flag,
                                'unitName', u.unit_name
                            )
                        )
                        FROM eps_prop_person_units ppu
                            LEFT JOIN unit u ON u.unit_number = ppu.unit_number
                        WHERE ppu.proposal_person_id = pp.proposal_person_id
                    ),
                    'attachments', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'attachmentId', ppa.attachment_id,
                                'description', ppa.description,
                                'fileName', ppa.file_name,
                                'mimeType', ppa.mime_type,
                                'fileDataId', ppa.file_data_id,
                                'documentId', ppa.document_id,
                                'versionNumber', ppa.version_number,
                                'attachmentType', atk.description,
                                'documentStatus', ds.description,
                                'updateTimestamp', ppa.update_timestamp,
                                'updateUser', ppa.update_user
                            )
                        )
                        FROM eps_proposal_person_attachmnt ppa
                            LEFT JOIN eps_proposal_key_personnel_attach_type atk ON atk.ATTACHMNT_TYPE_CODE = ppa.ATTACHMNT_TYPE_CODE
                            LEFT JOIN document_status ds ON ds.document_status_code = ppa.document_status_code
                        WHERE ppa.proposal_person_id = pp.proposal_person_id
                        ),
                    'designation', pp.designation,
                    'department', pp.department,
                    'isPi', pp.pi_flag,
                    'projectRole', pp.project_role,
                    'trainingStatus', pp.is_training_completed,
                    'isMultiPi', pp.is_multi_pi,
                    'personCertified', pp.is_person_certified,
                    'projectRole', pp.project_role,
                    'trainingStatus', pp.is_training_completed
                )
            ) AS proposal_persons
            FROM eps_proposal_persons pp
                LEFT JOIN eps_prop_person_role ppr ON pp.prop_person_role_id = ppr.prop_person_role_id
            WHERE pp.proposal_id = AV_PROPOSAL_ID
        ),
        'proposalOrganizations', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'proposalOrganizationId', po.proposal_organization_id,
                    'organization', JSON_OBJECT(
                        'organizationId', o.organization_id,
                        'organizationName', o.organization_name,
                        'address', o.address,
                        'congressionalDistrict',cd.description,
                        'dunsNumber', o.duns_number,
                        'cageNumber', o.cage_number,
                        'dodacNumber', o.dodac_number,
                        'isPartneringOrganization', o.is_partnering_organization,
                        'country', c.country_name
                    ),
                    'organizationType', ot.description,
                    'proposalCongDistricts', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'proposalCongDistrictId', pcd.proposal_cong_district_id,
                                'congDistrictCode', pcd.cong_district_code,
                                'description', cdist.description
                            )
                        )
                        FROM eps_proposal_cong_district pcd
                            LEFT JOIN congressional_district cdist ON cdist.cong_district_code = pcd.cong_district_code
                        WHERE pcd.proposal_organization_id = po.proposal_organization_id
                    ),
                    'rolodex',
                    CASE
                        WHEN r.rolodex_id IS NOT NULL THEN JSON_OBJECT(
                            'rolodexId', r.rolodex_id,
                            'fullName', r.full_name,
                            'firstName', r.first_name,
                            'lastName', r.last_name,
                            'middleName', r.middle_name,
                            'designation', r.designation,
                            'title', r.title,
                            'prefix', r.prefix,
                            'suffix', r.suffix,
                            'emailAddress', r.email_address,
                            'phoneNumber', r.phone_number,
                            'faxNumber', r.fax_number,
                            'organization', r.organization,
                            'organizationName', r.organization_name,
                            'countryOfCitizenship', r.country_of_citizenship,
                            'countryCode', r.country_code,
                            'state', r.state,
                            'stateCode', r.state_code,
                            'city', r.city,
                            'postalCode', r.postal_code,
                            'addressLine1', r.address_line_1,
                            'addressLine2', r.address_line_2,
                            'addressLine3', r.address_line_3,
                            'county', r.county,
                            'comments', r.comments
                        )
                        ELSE NULL
                    END,
                    'location', po.location,
                    'updateUser', po.update_user,
                    'updateTimestamp', po.update_timestamp
                )
            ) AS proposal_organizations
            FROM eps_proposal_organization po
                LEFT JOIN organization_type ot ON ot.organization_type_code = po.organization_type_code
                LEFT JOIN organization o ON o.organization_id = po.organization_id
                LEFT JOIN congressional_district cd ON cd.cong_district_code = o.cong_district_code
                LEFT JOIN country c ON c.country_code = o.country_code
                LEFT JOIN rolodex r ON r.rolodex_id = po.rolodex_id
            WHERE po.proposal_id = AV_PROPOSAL_ID
        ),
        'proposalProjectTeam', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'proposalProjectTeamId', pt.proposal_project_team_id,
                    'personId', pt.person_id,
                    'fullName', pt.full_name,
                    'projectRole', pt.project_role,
                    'nonEmployeeFlag', pt.non_employee_flag,
                    'percentageCharged', pt.percentage_charged,
                    'startDate', pt.start_date,
                    'endDate', pt.end_date,
                    'isActive', pt.is_active,
                    'updateTimestamp', pt.update_timestamp,
                    'updateUser', pt.update_user,
                    'designation', pt.designation
                )
            )
            FROM eps_proposal_project_team pt
            WHERE pt.proposal_id = AV_PROPOSAL_ID
        ),
        'proposalSpecialReviews', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'proposalSpecialReviewId', sr.proposal_special_review_id,
                    'specialReviewType', srt.description,
                    'approvalType', at.description,
                    'protocolStatus', sr.protocol_status_description,
                    'protocolNumber', sr.protocol_number,
                    'applicationDate', sr.application_date,
                    'approvalDate', sr.approval_date,
                    'expirationDate', sr.expiration_date,
                    'comments', sr.comments,
                    'updateTimestamp', sr.update_timestamp,
                    'updateUser', sr.update_user,
                    'isProtocolIntegrated', sr.is_integrated_protocol
                )
            )
            FROM eps_proposal_special_review sr
                LEFT JOIN special_review srt ON srt.special_review_code = sr.special_review_code
                LEFT JOIN sp_rev_approval_type at ON at.approval_type_code = sr.approval_type_code
            WHERE sr.proposal_id = AV_PROPOSAL_ID
        ),
        'otherFundingSupport', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'sponsorId', ps.sponsor_id,
                    'sponsorCode', ps.sponsor_code,
                    'sponsorName', ps.sponsor_name,
                    'fullName', ps.full_name,
                    'startDate', ps.start_date,
                    'endDate', ps.end_date,
                    'amount', ps.amount,
                    'fundingStatus', pfs.description,
                    'sponsorType', st.description,
                    'projectTitle', ps.project_title,
                    'personRole', ppr.description,
                    'percentageOfEffort', ps.percentage_of_effort,
                    'grantCallName', ps.grant_call_name,
                    'currency', JSON_OBJECT(
                        'code', ps.currency_code,
                        'name', c.currency
                    ),
                    'sponsor', JSON_OBJECT(
                        'code', s.sponsor_code,
                        'name', s.sponsor_name,
                        'typeCode', s.sponsor_type_code,
                        'type', st2.description,
                        'email', s.email_address,
                        'phone', s.phone_number,
                        'country', cn.country_name,
                        'city', s.city,
                        'state', s.state,
                        'postalCode', s.postal_code,
                        'addressLine1', s.address_line_1,
                        'addressLine2', s.address_line_2,
                        'addressLine3', s.address_line_3,
                        'location', s.sponsor_location,
                        'contactPerson', s.contact_person
                    ),
                    'updateTimestamp', ps.update_timestamp,
                    'updateUser', ps.update_user
                )
            )
            FROM eps_proposal_sponsors ps
                LEFT JOIN proposal_funding_status pfs ON pfs.funding_status_code = ps.funding_status_code
                LEFT JOIN sponsor_type st ON st.sponsor_type_code = ps.sponsor_type_code
                LEFT JOIN eps_prop_person_role ppr ON ppr.prop_person_role_id = ps.prop_person_role_id
                LEFT JOIN currency c ON c.currency_code = ps.currency_code
                LEFT JOIN sponsor s ON s.sponsor_code = ps.sponsor_code
                LEFT JOIN sponsor_type st2 ON st2.sponsor_type_code = s.sponsor_type_code
                LEFT JOIN country cn ON cn.country_code = s.country_code
            WHERE ps.proposal_id = AV_PROPOSAL_ID
        ),
        'proposalResearchAreas', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'researchAreaId', pra.resrch_area_id,
                    'proposalId', pra.proposal_id,
                    'researchRank', pra.research_rank,
                    'researchType',  rt.description,
                    'researchTypeArea', rta.description,
                    'researchTypeSubArea', rtsa.description,
                    'updateUser', pra.update_user,
                    'updateTimestamp', pra.update_timestamp
                )
            )
            FROM eps_proposal_resrch_areas pra
                LEFT JOIN research_type rt ON rt.resrch_type_code = pra.resrch_type_code
                LEFT JOIN research_type_area rta ON rta.resrch_type_area_code = pra.resrch_type_area_code
                LEFT JOIN research_type_sub_area rtsa ON rtsa.resrch_type_sub_area_code = pra.resrch_type_sub_area_code
            WHERE pra.proposal_id = AV_PROPOSAL_ID
        )
    )
    AS full_proposal INTO full_proposal;
END
