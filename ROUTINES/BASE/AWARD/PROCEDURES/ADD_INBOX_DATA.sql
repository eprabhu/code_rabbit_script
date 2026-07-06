-- `ADD_INBOX_DATA`; 

CREATE PROCEDURE `ADD_INBOX_DATA`()
BEGIN
DECLARE LI_AWARD_ID INT;
DECLARE LS_PERSON_ID VARCHAR(40);
DECLARE LI_TASK_ID INT;
DECLARE LS_TASK_TYPE_CODE VARCHAR(3);
DECLARE LS_USER_MESSAGE VARCHAR(1000);
DECLARE LS_TASK_TYPE VARCHAR(200);
BEGIN
	DECLARE DONE4 INT DEFAULT FALSE;
	
	DECLARE CUR_DATA CURSOR FOR 
	
	
select t1.module_item_key AS AWARD_ID,T1.ASSIGNEE_PERSON_ID,t1.task_id,T3.DESCRIPTION AS TASK_TYPE
from
(
SELECT task.* FROM task 
inner join award on task.MODULE_ITEM_ID = award.AWARD_ID  and task.TASK_STATUS_CODE = '1' and task.MODULE_ITEM_ID = award.AWARD_ID
inner join award_persons on award_persons.AWARD_ID = award.AWARD_ID and award_persons.PI_FLAG = 'Y'
inner join feed_award_details on feed_award_details.AWARD_ID = award.AWARD_ID
inner join tmp_pi_uat on tmp_pi_uat.EXT_DEPT_CODE = award.LEAD_UNIT_NUMBER and  award_persons.PERSON_ID = tmp_pi_uat.PERSON_ID
where  feed_award_details.scenario in ('PI - Award Task Completion Process','PI - Award Task Completion Proce')
) t1
left outer join inbox t2 on t1.MODule_item_key = t2.MODule_item_key and t1.task_id = t2.sub_MODule_item_key
LEFT OUTER JOIN TASK_TYPE T3 ON T1.TASK_TYPE_CODE = T3.TASK_TYPE_CODE;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE4 = TRUE;
	
	OPEN CUR_DATA;
	
	INSERT_LOOP4: LOOP 
	FETCH CUR_DATA INTO 
	LI_AWARD_ID,
	LS_PERSON_ID,
	LI_TASK_ID,
	LS_TASK_TYPE;
    
	IF DONE4 THEN
		LEAVE INSERT_LOOP4;
	END IF;
	
	SET LS_USER_MESSAGE = CONCAT('#',LI_TASK_ID,'-',LS_TASK_TYPE);
	
	
	CALL ADD_TO_INBOX(
	1,
	LI_AWARD_ID,
	LS_PERSON_ID,
	'T',
	LS_USER_MESSAGE,
	'admin',
	'116',
	2,
	LI_TASK_ID
	);
	
	END LOOP;
	CLOSE CUR_DATA;
 END;
					
END
