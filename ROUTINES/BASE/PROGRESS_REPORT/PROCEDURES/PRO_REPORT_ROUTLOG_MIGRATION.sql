-- `PRO_REPORT_ROUTLOG_MIGRATION`; 

CREATE PROCEDURE `PRO_REPORT_ROUTLOG_MIGRATION`()
BEGIN
                    DECLARE DONE2 INT DEFAULT FALSE;
                    DECLARE LS_WORKFLOW_DETAIL_ID VARCHAR(100);
                    DECLARE LS_STOP_NAME VARCHAR(200);
                    DECLARE LS_MAP_ID VARCHAR(100);
                    DECLARE LS_APPROVAL_STOP_NUMBER VARCHAR(100);
                    DECLARE LS_WORKFLOW_ID VARCHAR(100);
                    DECLARE CUR_WORKFLOW_DETAIL_DATA CURSOR FOR 
                    SELECT DISTINCT MIN( wd.WORKFLOW_DETAIL_ID), wd.STOP_NAME, wd.MAP_ID, wd.APPROVAL_STOP_NUMBER, wd.WORKFLOW_ID
                    from workflow_detail wd INNER JOIN workflow w ON wd.WORKFLOW_ID=w.WORKFLOW_ID 
                    WHERE w.MODULE_CODE=16 GROUP BY wd.WORKFLOW_ID, wd.MAP_ID, wd.APPROVAL_STOP_NUMBER;
                    DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE2 = TRUE;
                    OPEN CUR_WORKFLOW_DETAIL_DATA;
                    WORKFLOW_DET_LOOP: LOOP 
                    FETCH CUR_WORKFLOW_DETAIL_DATA INTO
                    LS_WORKFLOW_DETAIL_ID, LS_STOP_NAME, LS_MAP_ID, LS_APPROVAL_STOP_NUMBER, LS_WORKFLOW_ID;
                    IF DONE2 THEN
                        LEAVE WORKFLOW_DET_LOOP;
                    END IF;
                        BEGIN
                            IF ISNULL(LS_STOP_NAME) THEN
                                UPDATE workflow_detail SET STOP_NAME = CONCAT("Stop ",APPROVAL_STOP_NUMBER) 
                                WHERE WORKFLOW_ID=LS_WORKFLOW_ID AND MAP_ID = LS_MAP_ID AND APPROVAL_STOP_NUMBER = LS_APPROVAL_STOP_NUMBER;
                            ELSE 
                                UPDATE workflow_detail SET STOP_NAME = LS_STOP_NAME
                                WHERE WORKFLOW_ID=LS_WORKFLOW_ID AND MAP_ID = LS_MAP_ID AND APPROVAL_STOP_NUMBER = LS_APPROVAL_STOP_NUMBER AND WORKFLOW_DETAIL_ID != LS_WORKFLOW_DETAIL_ID;
                            END IF;
                        END;
                    END LOOP;
                    CLOSE CUR_WORKFLOW_DETAIL_DATA;
END
