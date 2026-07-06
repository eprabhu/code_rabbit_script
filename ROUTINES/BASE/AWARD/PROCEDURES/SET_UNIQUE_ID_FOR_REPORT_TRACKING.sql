-- `SET_UNIQUE_ID_FOR_REPORT_TRACKING`; 

CREATE PROCEDURE `SET_UNIQUE_ID_FOR_REPORT_TRACKING`()
BEGIN
	 DECLARE done INT DEFAULT FALSE;
    DECLARE cur_award_number VARCHAR(255);
    DECLARE cur_due_date DATE;
    DECLARE cur_unique_id INT;
    DECLARE cur_rep_class_code varchar(3);
    DECLARE cur_rep_code varchar(3);
    DECLARE LI_UNIQUE_ID INT;
 
    DECLARE cur CURSOR FOR
        SELECT DISTINCT t1.award_number, t1.due_date,t2.REPORT_CLASS_CODE,t2.REPORT_CODE,t1.UNIQUE_ID
        FROM award_report_tracking t1 left join award_report_terms t2 on t2.AWARD_REPORT_TERMS_ID = t1.AWARD_REPORT_TERMS_ID
        ORDER BY t1.award_number, t1.due_date;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    SET cur_unique_id = 1;
    
    read_loop: LOOP
        FETCH cur INTO cur_award_number, cur_due_date, cur_rep_class_code, cur_rep_code, LI_UNIQUE_ID;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        IF LI_UNIQUE_ID IS NOT NULL THEN
            LEAVE read_loop;
        END IF;
       
       set sql_safe_updates=0;
        
        UPDATE award_report_tracking t1
        left join award_report_terms t2 on t2.AWARD_REPORT_TERMS_ID = t1.AWARD_REPORT_TERMS_ID
        SET t1.unique_id = cur_unique_id
        WHERE t1.award_number = cur_award_number
            AND t1.due_date = cur_due_date AND t2.REPORT_CLASS_CODE = cur_rep_class_code AND 
            (
            CASE 
            WHEN cur_rep_code is null THEN t2.REPORT_CODE is null
            ELSE t2.REPORT_CODE = cur_rep_code
            END
            );
        SET cur_unique_id = cur_unique_id + 1;
    END LOOP;
    set sql_safe_updates=1;
    
    CLOSE cur;
END
