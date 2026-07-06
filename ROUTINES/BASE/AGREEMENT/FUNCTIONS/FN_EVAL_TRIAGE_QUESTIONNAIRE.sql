-- `FN_EVAL_TRIAGE_QUESTIONNAIRE`; 

CREATE FUNCTION `FN_EVAL_TRIAGE_QUESTIONNAIRE`(
AV_MODULE_CODE    		 INT,
AV_SUB_MODULE_CODE    	 INT,
AV_MODULE_ITEM_KEY   VARCHAR(20)
) RETURNS int(11)
    DETERMINISTIC
BEGIN
DECLARE LI_TEMPLATE_ID INT ;
DECLARE LI_QUES_ANS_HEADER_ID INT;
DECLARE LI_ANSWER VARCHAR(4000);
SELECT 
    QUESTIONNAIRE_ANS_HEADER_ID
INTO LI_QUES_ANS_HEADER_ID FROM
    QUEST_ANSWER_HEADER
WHERE
    MODULE_ITEM_CODE = AV_MODULE_CODE
        AND MODULE_SUB_ITEM_CODE = AV_SUB_MODULE_CODE
        AND MODULE_ITEM_KEY = AV_MODULE_ITEM_KEY;
SELECT 
    ANSWER
INTO LI_ANSWER FROM
    QUEST_ANSWER
WHERE
    QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID;
IF (LI_ANSWER = 'Only to receive or have access to confidential information to enable a discussion in anticipation of a future research project or collaboration.') then
SET LI_TEMPLATE_ID = 1;
RETURN 1;
END IF;
IF(LI_ANSWER = 'Only to provide confidential information to an outside organization to enable a discussion in anticipation of a future research project or collaboration.') then
SET LI_TEMPLATE_ID = 2;
RETURN 2;
END IF;
IF(LI_ANSWER = 'Both to receive and provide or have access to confidential information to enable a discussion in anticipation of a future research project or collaboration.') then
SET LI_TEMPLATE_ID =  3;
RETURN 3;
END IF;
IF(LI_ANSWER = 'Only to receive a discrete data set for use in my research.') then
SET LI_TEMPLATE_ID = 4;
RETURN 4;
END IF;
IF(LI_ANSWER = 'Only to provide a discrete data set for my research to an outside organization.') then
SET LI_TEMPLATE_ID =  5;
RETURN 5;
END IF;
IF(LI_ANSWER = 'Other purpose not listed here.') then
SET LI_TEMPLATE_ID =  6;
RETURN 6;
END IF;
IF(LI_ANSWER = 'Only to receive, provide or exchange confidential information in connection with discussions relating to potential licensing of MIT Technology.') then
SET LI_TEMPLATE_ID = 7;
RETURN 7;
END IF;
IF(LI_ANSWER = 'Only to receive, provide or exchange confidential information in connection with discussions relating to a non-research or educational purpose.') then
SET LI_TEMPLATE_ID = 8;
RETURN 8;
END IF;
RETURN 0;
END
