CREATE  FUNCTION `FN_EVAL_DISCLOSURE_QUESTIONNAIRE`(
AV_MODULE_CODE    		 INT,
AV_SUB_MODULE_CODE    	 INT,
AV_MODULE_ITEM_KEY   INT
) RETURNS int
    DETERMINISTIC
BEGIN
DECLARE LI_QUES_ANS_HEADER_ID INT;
DECLARE LI_ANS_COUNT INT;
DECLARE LI_ANSWER VARCHAR(40);
DECLARE LI_QUESTIONNAIRE_ID INT;
SELECT 
    QUESTIONNAIRE_ANS_HEADER_ID
INTO LI_QUES_ANS_HEADER_ID FROM
    QUEST_ANSWER_HEADER
WHERE
    MODULE_ITEM_CODE = AV_MODULE_CODE
        AND MODULE_SUB_ITEM_CODE = AV_SUB_MODULE_CODE
        AND MODULE_ITEM_KEY = AV_MODULE_ITEM_KEY;
SELECT QUESTIONNAIRE_ID into LI_QUESTIONNAIRE_ID FROM quest_answer_header  where QUESTIONNAIRE_ANS_HEADER_ID =LI_QUES_ANS_HEADER_ID;
SELECT COUNT(1) INTO LI_ANS_COUNT FROM quest_answer where QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID and QUESTION_ID in (SELECT QUESTION_ID FROM quest_question where QUESTIONNAIRE_ID = LI_QUESTIONNAIRE_ID and 
QUESTION ='Question 03: Over the last 12 months, or do you expect to receive over the next 12 months: Payments for intellectual property such as copyrights or royalties from any source other than the University? (excluding scholarly works)?'
or QUESTION = 'Question 04: Over the last 12 months, or do you expect to receive over the next 12 months: Compensation for any board positions, including science '
or QUESTION = 'Question 05: Over the last 12 months, or do you expect to receive over the next 12 months: Consulting, salary, or other income for services work performed or other services provided?'
or QUESTION = 'Question 06: Do you have an Equity interest in a non-publically traded company (any amount)?'
or QUESTION = 'Question 08:  Do you have publicly traded stock or stock options in excess of $5,000 that must only be disclosed in then following circumstances: 
1. When it is held in combination with other relationships described above (Income) 
2. When the company sponsors the Investigator’s Research, or when the company’s line of business may reasonably appear to be related to the Investigator’s Research at the University
3. The value of the stock exceeds $100,000.') and ANSWER ='no';
IF LI_ANS_COUNT > 0 THEN
   RETURN 0;
ELSE
    SELECT ANSWER INTO  LI_ANSWER FROM quest_answer where QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID and 
    QUESTION_ID = (SELECT QUESTION_ID FROM quest_question where QUESTIONNAIRE_ID = LI_QUESTIONNAIRE_ID and 
    QUESTION ='Question 07: What is the range of publically traded stock in lieu of payment for services provided?');
	IF (LI_ANSWER = 'Between $5000 & $10000') THEN 
	 RETURN 1;
    END IF; 
END IF;
RETURN 0;
END
