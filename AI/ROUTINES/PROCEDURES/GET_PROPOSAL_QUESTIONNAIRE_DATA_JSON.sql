CREATE PROCEDURE `GET_PROPOSAL_QUESTIONNAIRE_DATA_JSON`(
    IN AV_PROPOSAL_ID INT,
    OUT questionnaire_data JSON
)
BEGIN
	SELECT JSON_ARRAYAGG(
		JSON_OBJECT(
		  'questionnaireId', T2.QUESTIONNAIRE_ID,
		  'questionnaireNumber', T2.QUESTIONNAIRE_NUMBER,
		  'versionNumber', T2.VERSION_NUMBER,
		  'questionnaire', T2.QUESTIONNAIRE,
		  'questionnaireLabel', T1.QUESTIONNAIRE_LABEL,
		  'isMandatory', T1.IS_MANDATORY,
		  'ruleId', T1.RULE_ID,
		  'isFinal', T2.IS_FINAL,
		  'moduleItemCode', T1.MODULE_ITEM_CODE,
		  'moduleSubItemCode', T1.MODULE_SUB_ITEM_CODE,
		  'questionnaireAnswerHeaderId', T3.QUESTIONNAIRE_ANS_HEADER_ID,
		  'questionnaireCompletedFlag', T3.QUESTIONNAIRE_COMPLETED_FLAG,
		  'updateUserFullName', T4.FULL_NAME,
		  'updateTimestamp', T3.UPDATE_TIMESTAMP,
		  'questions', (
			    SELECT JSON_ARRAYAGG(
			        JSON_OBJECT(
				        'questionId', Q.QUESTION_ID,
                        'questionNumber', Q.QUESTION_NUMBER,
                        'questionVersionNumber', Q.QUESTION_VERSION_NUMBER,
                        'sortOrder', Q.SORT_ORDER,
                        'question', Q.QUESTION,
                        'description', Q.DESCRIPTION,
                        'parentQuestionId', Q.PARENT_QUESTION_ID,
                        'helpLink', Q.HELP_LINK,
                        'answerType', Q.ANSWER_TYPE,
                        'answerLength', Q.ANSWER_LENGTH,
                        'numberOfAnswers', Q.NO_OF_ANSWERS,
                        'lookupType', Q.LOOKUP_TYPE,
                        'lookupName', Q.LOOKUP_NAME,
                        'lookupField', Q.LOOKUP_FIELD,
                        'groupName', Q.GROUP_NAME,
                        'groupLabel', Q.GROUP_LABEL,
                        'hasCondition', Q.HAS_CONDITION,
                        'footerDescription', Q.FOOTER_DESCRIPTION,
                        'ruleId', Q.RULE_ID,
                        'answer', (
                            SELECT JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'answerId', A.QUESTIONNAIRE_ANSWER_ID,
                                    'optionNumber', A.OPTION_NUMBER,
                                    'answerNumber', A.ANSWER_NUMBER,
                                    'answer', A.ANSWER,
                                    'answerLookupCode', A.ANSWER_LOOKUP_CODE,
                                    'explanation', A.EXPLANATION
                                )
                            )
                            FROM QUEST_ANSWER A
                            WHERE A.QUESTIONNAIRE_ANS_HEADER_ID = T3.QUESTIONNAIRE_ANS_HEADER_ID
                                AND A.QUESTION_ID = Q.QUESTION_ID
                        )
			        )
			    )
			    FROM QUEST_QUESTION Q
			    WHERE Q.QUESTIONNAIRE_ID = T2.QUESTIONNAIRE_ID
                    AND EXISTS (
                        SELECT 1
                        FROM QUEST_ANSWER A2
                        WHERE A2.QUESTIONNAIRE_ANS_HEADER_ID = T3.QUESTIONNAIRE_ANS_HEADER_ID
                            AND A2.QUESTION_ID = Q.QUESTION_ID
                            AND A2.ANSWER IS NOT NULL
                    )
		    )
		)
	) AS questionnaire_data into questionnaire_data
	FROM QUEST_USAGE T1
	    INNER JOIN QUEST_HEADER T2 ON T1.QUESTIONNAIRE_ID = T2.QUESTIONNAIRE_ID
	    LEFT JOIN QUEST_ANSWER_HEADER T3 ON T1.QUESTIONNAIRE_ID = T3.QUESTIONNAIRE_ID
	        AND T1.MODULE_ITEM_CODE = T3.MODULE_ITEM_CODE
	        AND T3.MODULE_ITEM_KEY = AV_PROPOSAL_ID
	        AND T3.MODULE_SUB_ITEM_KEY = ''
	    LEFT JOIN PERSON T4 ON T4.USER_NAME = T3.UPDATE_USER
	WHERE T1.MODULE_ITEM_CODE = 3
		AND T1.MODULE_SUB_ITEM_CODE = 0
		AND T2.IS_FINAL = 'Y'
	ORDER BY T1.SORT_ORDER ASC;
END
