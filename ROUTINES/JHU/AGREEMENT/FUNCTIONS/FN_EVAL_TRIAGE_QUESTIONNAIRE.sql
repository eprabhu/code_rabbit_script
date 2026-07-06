CREATE FUNCTION `FN_EVAL_TRIAGE_QUESTIONNAIRE`(
    AV_MODULE_CODE INT,
    AV_SUB_MODULE_CODE INT,
    AV_MODULE_ITEM_KEY VARCHAR(20),
	AV_LOGIN_PERSON_ID VARCHAR(90)
) RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE LI_TEMPLATE_ID INT;
    DECLARE LI_QUES_ANS_HEADER_ID INT;
    DECLARE LI_COUNT INT;
    DECLARE Q1_ANSWER VARCHAR(4000);
    DECLARE Q2_ANSWER VARCHAR(4000);
    DECLARE Q21_ANSWER VARCHAR(4000);
    DECLARE Q22_ANSWER VARCHAR(4000);
    DECLARE Q23_ANSWER VARCHAR(4000);
    DECLARE Q24_ANSWER VARCHAR(4000);
    DECLARE LI_ANS_COUNT INT;
    DECLARE LI_RESULT INT DEFAULT NULL;

	/* 
	All the QUESTION_NUMBER hardcoded here will varies across instances depending  on questionnaire configured,
	Pls adjust the QUESTION_NUMBER as per questionaire configured
	*/
    -- Retrieve the QUESTIONNAIRE_ANS_HEADER_ID
    SELECT QUESTIONNAIRE_ANS_HEADER_ID
    INTO LI_QUES_ANS_HEADER_ID
    FROM QUEST_ANSWER_HEADER
    WHERE MODULE_ITEM_CODE = AV_MODULE_CODE
        AND MODULE_SUB_ITEM_CODE = AV_SUB_MODULE_CODE
        AND MODULE_ITEM_KEY = AV_MODULE_ITEM_KEY;

    -- Retrieve answers for Q1, Q2, Q2.1, and Q2.2
    SELECT TRIM(T1.ANSWER) INTO Q1_ANSWER
    FROM QUEST_ANSWER T1
    INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
    WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
    AND T2.QUESTION_NUMBER = 6912; -- Does this Agreement or Award already have an SAP Grant#?
    
      IF UPPER(Q1_ANSWER) LIKE UPPER('Yes - That is a Modification of Funded Agreement%') THEN 
      
				SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
				FROM QUEST_ANSWER T1
				INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
				WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
				AND T2.QUESTION_NUMBER = 6918; --  Please search for and choose the relevant Award.	

				SET LI_RESULT = 1;

	  ELSEIF UPPER(Q1_ANSWER) = UPPER('NO') THEN 
                SELECT TRIM(T1.ANSWER) INTO Q2_ANSWER
				FROM QUEST_ANSWER T1
				INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
				WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
				AND T2.QUESTION_NUMBER = 6913; --  Was a Fibi Proposal Development record (PD) submitted for this Agreement/Award?
                
                IF UPPER(Q2_ANSWER) LIKE UPPER('Yes - Select IPN%') THEN
                            SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
							FROM QUEST_ANSWER T1
							INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
							WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
							AND T2.QUESTION_NUMBER = 6917; -- Please search for and choose the relevant IPN.

			/* create_agreement permission check  : personId, answer , module(AWARD/IP/AGREEMENT) etc*/
							IF FN_CHECK_CREATE_AGREEMENT_PERMISSION(AV_LOGIN_PERSON_ID, Q24_ANSWER, 'IP') = 0 THEN  
								RETURN 0;
							END IF;

							SET LI_RESULT = 9;

				ELSEIF UPPER(Q2_ANSWER) LIKE UPPER(TRIM('No - You are initiating an Unfunded Agreement. (​If this is a Funded Agreement, please submit a Fibi PD and obtain a Fibi IPN before submitting this Agreement)%')) THEN 
                        SELECT TRIM(T1.ANSWER) INTO Q21_ANSWER
						FROM QUEST_ANSWER T1
						INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
						WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
						AND T2.QUESTION_NUMBER = 6914; -- Is this Agreement related to a current Agreement?​
                        
                           IF UPPER(Q21_ANSWER) LIKE  UPPER(TRIM('Yes - This is a Modification of an Unfunded Agreement%')) THEN
                                    SELECT TRIM(T1.ANSWER) INTO Q22_ANSWER
									FROM QUEST_ANSWER T1
									INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
									WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
									AND T2.QUESTION_NUMBER = 6916; -- Does the Agreement involve:
                                   
                                        IF UPPER(Q22_ANSWER) LIKE UPPER(TRIM('Yes - Research Activities or a Faculty Secondment?%')) THEN 
                                                        SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
														FROM QUEST_ANSWER T1
														INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
														WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
														AND T2.QUESTION_NUMBER = 6919; -- Select the purpose of the agreement from the list below:​
                                                 IF UPPER(Q24_ANSWER) LIKE UPPER('CDA/NDA: Share or receive confidential information?%') THEN
													SET LI_RESULT = 5; -- Intellectual Property Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('COLLABORATION AGREEMENT: Establish an unfunded collaboration with the outside institution?%') THEN
													SET LI_RESULT = 6; -- Material Transfer Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('CRADA: Establish a cooperative framework with a federal entity? (Note: This is a specific agreement issued by federal entity entitled Cooperative Research and Development Agreement or “CRADA.”)%') THEN
													SET LI_RESULT = 7; -- NDA/CDA Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('DATA USE AGREEMENT: Govern the transfer and use of data?%') THEN
													SET LI_RESULT = 8; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('EQUIPMENT LOAN AGREEMENT (BAILMENT): Give or take physical possession (but not ownership) of equipment or other tangible property for a stated purpose?%') THEN
													SET LI_RESULT = 25; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER(TRIM('Allow student exchanges between JHU and another institution to take courses  at an outside institution and receive credit at their home institution?%')) THEN
													SET LI_RESULT = 26; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('INTELLECTUAL PROPERTY AGREEMENT: Set forth the respective intellectual property rights between two parties prior to an award?%') THEN
													SET LI_RESULT = 27; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('INTERNAL - REVIEW: Requires research administration review prior to a proposal or award document is received?%') THEN
													SET LI_RESULT = 28; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('LICENSE AGREEMENT: Grant rights to use specified intellectual property assets?%') THEN
													SET LI_RESULT = 29; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('MASTER AGREEMENT: Set out approved terms to govern multiple forthcoming project agreements?%') THEN
													SET LI_RESULT = 30; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('MATERIAL TRANSFER AGREEMENT: Define the conditions under which research or other materials can be transferred and used among the parties?%') THEN
													SET LI_RESULT = 31; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('MEMBERSHIP AGREEMENT: Establish a relationship among parties for membership of an organization with broad research program objectives that are of interest to multiple organizations. Separate agreements for specific projects may also be required%') THEN
													SET LI_RESULT = 32; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('MEMORANDUM OF UNDERSTANDING: Establish a non-binding agreement between two or more parties to discuss future collaborative work?%') THEN
													SET LI_RESULT = 33; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('SERVICE CENTER AGREEMENT: Govern the provision of professional services from a JHU lab or center that regularly provides such services to other organizations?%') THEN
													SET LI_RESULT = 34; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('STUDENT AGREEMENT: Provide funds to allow a JHU student to perform work required as part of their degree program at another organization.%') THEN
													SET LI_RESULT = 35; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('TEAMING AGREEMENT: Set forth the respective obligations of two or more parties when collaborating to prepare a formal project proposal in response to a solicitation?%') THEN
													SET LI_RESULT = 36; -- Teaming Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('VISITOR AGREEMENT: Outline the expectations of the sending and receiving institutions when a JHU faculty member or student is visiting another institution or when a visitor coming to JHU and which require an agreement to participate in research or educational activities?%') THEN
													SET LI_RESULT = 37; -- Teaming Agreement - Modification
                                                ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('COMPASSIONATE USE AGREEMENT (also known as Expanded Access Agreements) Allows patients with serious or life-threatening conditions to access investigational drugs, biologics, or medical devices outside of clinical trials when no satisfactory alternatives are available%') THEN
													SET LI_RESULT = 55; -- Compassionate Use Agreement - Modification
                                                ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('TASK ORDER AGREEMENT: An agreement for performance of a project governed by a separate Master Agreement%') THEN
													SET LI_RESULT = 56; -- Task Order Agreement - Modification 
                                                ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('SECONDMENT AGREEMENT/IPA: Govern the temporary assignment of a JHU faculty member to another organization?%') THEN
													SET LI_RESULT = 60; -- Secondment Agreement/ IPA - Modification    
												END IF;
										ELSEIF UPPER(Q22_ANSWER) LIKE UPPER('No - Student Placements, Handshake Agreements, Professional Development, or Educational Programs?%') THEN 
                                                        SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
														FROM QUEST_ANSWER T1
														INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
														WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
														AND T2.QUESTION_NUMBER =6929; -- Is the purpose of the agreement to:
												IF UPPER(Q24_ANSWER) LIKE UPPER('EDUCATIONAL PROGRAM: Develop a degree-granting program in collaboration with an outside institution?%') THEN
													SET LI_RESULT = 17; -- Student Agreement - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('EXCHANGE PROGRAM: Allow student exchanges between JHU and another institution to take courses at an outside institution and receive credit at their home institution?%') THEN
													SET LI_RESULT = 18; -- Degree Program - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('INTERNAL - REVIEW: Requires research administration review prior to a proposal or award document is received?%') THEN
													SET LI_RESULT = 19; -- Exchange Program - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('MEMORANDUM OF UNDERSTANDING: Establish a non-binding agreement between two or more parties to discuss future collaborative work?%') THEN
													SET LI_RESULT = 20; -- IPA's/Secondments - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('SECONDMENT AGREEMENT/IPA: Govern the temporary assignment of a JHU faculty member to another organization?%') THEN
													SET LI_RESULT = 38; -- IPA's/Secondments - Modification
												ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('STUDENT PLACEMENT AGREEMENT: Set out the terms to allow a JHU student to perform work required as part of their degree program at another organization.%') THEN
													SET LI_RESULT = 39; -- IPA's/Secondments - Modification
												END IF;    
                                                       
                                        END IF;
						   ELSEIF UPPER(Q21_ANSWER) LIKE UPPER('No - This is a New Unfunded Agreement%') THEN
                                                    SELECT TRIM(T1.ANSWER) INTO Q23_ANSWER
													FROM QUEST_ANSWER T1
													INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
													WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
													AND T2.QUESTION_NUMBER = 6915; -- Does the agreement involve research activities?
													
                                                        IF UPPER(Q23_ANSWER) LIKE UPPER('Yes - Research Activities or a Faculty Secondment?%') THEN
                                                                    SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
																	FROM QUEST_ANSWER T1
																	INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
																	WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
																	AND T2.QUESTION_NUMBER = 6921;
                                                                    
                                                            IF UPPER(Q24_ANSWER) LIKE UPPER('CDA/NDA: Share or receive confidential information?%') THEN
																SET LI_RESULT = 13; -- Intellectual Property Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('COLLABORATION AGREEMENT: Establish an unfunded collaboration with the outside institution?%') THEN
																SET LI_RESULT = 14; -- Material Transfer Agreement - New
															ELSEIF UPPER(TRIM(Q24_ANSWER)) LIKE UPPER(TRIM('CRADA: Establish a cooperative framework with a federal entity? (Note: This is a specific agreement issued by federal entity entitled Cooperative Research and Development Agreement or “CRADA.”)%')) THEN
																SET LI_RESULT = 15; -- NDA/CDA Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('DATA USE AGREEMENT: Govern the transfer and use of data?%') THEN
																SET LI_RESULT = 16; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('EQUIPMENT LOAN AGREEMENT (BAILMENT): Give or take physical possession (but not ownership) of equipment or other tangible property for a stated purpose?%') THEN
																SET LI_RESULT = 40; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Allow student exchanges between JHU and another institution to take courses  at an outside institution and receive credit at their home institution?%')) THEN
																SET LI_RESULT = 41; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('INTELLECTUAL PROPERTY AGREEMENT: Set forth the respective intellectual property rights between two parties prior to an award?%') THEN
																SET LI_RESULT = 42; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('INTERNAL - REVIEW: Requires research administration review prior to a proposal or award document is received?%') THEN
																SET LI_RESULT = 43; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('LICENSE AGREEMENT: Grant rights to use specified intellectual property assets?%') THEN
																SET LI_RESULT = 44; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('MASTER AGREEMENT: Set out approved terms to govern multiple forthcoming project agreements?%') THEN
																SET LI_RESULT = 45; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('MATERIAL TRANSFER AGREEMENT: Define the conditions under which research or other materials can be transferred and used among the parties?%') THEN
																SET LI_RESULT = 46; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('MEMBERSHIP AGREEMENT: Establish a relationship among parties for membership of an organization with broad research program objectives that are of interest to multiple organizations. Separate agreements for specific projects may also be required%') THEN
																SET LI_RESULT = 47; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('MEMORANDUM OF UNDERSTANDING: Establish a non-binding agreement between two or more parties to discuss future collaborative work?%') THEN
																SET LI_RESULT = 48; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('SERVICE CENTER AGREEMENT: Govern the provision of professional services from a JHU lab or center that regularly provides such services to other organizations?%') THEN
																SET LI_RESULT = 49; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('STUDENT AGREEMENT: Provide funds to allow a JHU student to perform work required as part of their degree program at another organization.%') THEN
																SET LI_RESULT = 50; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('TEAMING AGREEMENT: Set forth the respective obligations of two or more parties when collaborating to prepare a formal project proposal in response to a solicitation?%') THEN
																SET LI_RESULT = 51; -- Teaming Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('VISITOR AGREEMENT: Outline the expectations of the sending and receiving institutions when a JHU faculty member or student is visiting another institution or when a visitor coming to JHU and which require an agreement to participate in research or educational activities%') THEN
																SET LI_RESULT = 52; -- Teaming Agreement - New
                                                            ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('COMPASSIONATE USE AGREEMENT (also known as Expanded Access Agreements) Allows patients with serious or life-threatening conditions to access investigational drugs, biologics, or medical devices outside of clinical trials when no satisfactory alternatives are available%') THEN
																SET LI_RESULT = 57; -- Compassionate Use Agreement - New
															ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('TASK ORDER AGREEMENT: An agreement for performance of a project governed by a separate Master Agreement%') THEN
																SET LI_RESULT = 58; -- Task Order Agreement - New
                                                            ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('SECONDMENT AGREEMENT/IPA: Govern the temporary assignment of a JHU faculty member to another organization?%') THEN
																SET LI_RESULT = 59; -- Secondment Agreement/ IPA - New    
															END IF;
														ELSEIF UPPER(Q23_ANSWER) LIKE UPPER('No - Student Placements, Handshake Agreements, Professional Development, or Educational Programs?%') THEN 
                                                                        SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
																		FROM QUEST_ANSWER T1
																		INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
																		WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
																		AND T2.QUESTION_NUMBER = 6922; -- Is the purpose of the agreement to:

                                                                IF UPPER(Q24_ANSWER) LIKE UPPER('EDUCATIONAL PROGRAM: Develop a degree-granting program in collaboration with an outside institution?%') THEN
																	SET LI_RESULT = 21; -- Student Agreement - New
																ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('EXCHANGE PROGRAM: Allow student exchanges between JHU and another institution to take courses at an outside institution and receive credit at their home institution?%') THEN
																	SET LI_RESULT = 22; -- Degree Program - New
																ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('INTERNAL - REVIEW: Requires research administration review prior to a proposal or award document is received?%') THEN
																	SET LI_RESULT = 23; -- Exchange Program - New
																ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('MEMORANDUM OF UNDERSTANDING:%') THEN
																	SET LI_RESULT = 24; -- IPA's/Secondments - New
																ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('SECONDMENT AGREEMENT/IPA: Govern the temporary assignment of a JHU faculty member to another organization?%') THEN
																	SET LI_RESULT = 53; -- IPA's/Secondments - New
																ELSEIF UPPER(Q24_ANSWER) LIKE UPPER('STUDENT PLACEMENT AGREEMENT: Set out the terms to allow a JHU student to perform work required as part of their degree program at another organization.%') THEN
																	SET LI_RESULT = 54; -- IPA's/Secondments - New
																END IF;
														END IF;
                           END IF;
                END IF;
      END IF;

  SELECT COUNT(1) INTO LI_ANS_COUNT
	FROM QUEST_ANSWER T1
	INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
	WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
	AND T2.QUESTION_NUMBER in (6917,6918,7016);   -- configured question numbers for ip/award/agreement etc
		IF LI_ANS_COUNT = 0 THEN
			RETURN 0;
		END IF;

    RETURN COALESCE(LI_RESULT, 0);	-- Return the matched result, or 0 if nothing matched
END
