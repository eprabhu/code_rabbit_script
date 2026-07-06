CREATE PROCEDURE `MERGE_AWD_SECTION_MANPOWER`(
AV_AWARD_ID             INT,
AV_AWARD_NUMBER         VARCHAR(12),
AV_SEQUENCE_NUMBER      INT(4),
AV_VARIATION_TYPE_CODE  VARCHAR(3),
AV_UPDATE_USER          VARCHAR(60)
)
BEGIN
 
DECLARE LS_ERROR_MSG                        VARCHAR(1000);
DECLARE LS_TABLE_NAME                       VARCHAR(30);
DECLARE LI_FLAG                             INT;
DECLARE LI_MASTER_AWARD_ID                  INT;
DECLARE LI_MASTER_SEQ_NUMBER                INT(4);
 
DECLARE LI_AWARD_MANPWR_NEXT_VAL            BIGINT(20);
 
DECLARE LI_AWARD_MANPOWER_ID            INT(12);
DECLARE LS_MANPOWER_TYPE_CODE           VARCHAR(3);
DECLARE LS_BUDGET_REFERENCE_NUMBER      VARCHAR(50);
DECLARE LS_BUDGET_REFERENCE_TYPE_CODE   VARCHAR(3);
DECLARE LI_BUDGET_VERSION_NUMBER        INT(11);
DECLARE LI_ACTUAL_HEADCOUNT             INT(5);
DECLARE LS_CREATE_USER                  VARCHAR(60);
DECLARE LS_CREATE_TIMESTAMP             DATETIME;
DECLARE LS_UPDATE_USER                  VARCHAR(60);
DECLARE LS_UPDATE_TIMESTAMP             DATETIME;
DECLARE LS_MODULE_CODE                  INT(12);
DECLARE LS_SUB_MODULE_CODE              INT(12);
 
DECLARE LI_AWARD_MANPOWER_RESOURCE_ID   INT(12);
DECLARE LS_PERSON_ID                    VARCHAR(40);
DECLARE LI_ROLODEX_ID                   INT(11);
DECLARE LS_POSITION_ID                  VARCHAR(50);
DECLARE LS_FULL_NAME                    VARCHAR(90);
DECLARE LS_POSITION_STATUS_CODE         VARCHAR(3);
DECLARE LI_COST_ALLOCATION              DECIMAL(5,2);
DECLARE LS_PLAN_COMPENSATION_TYPE_CODE  VARCHAR(3);
DECLARE LS_PLAN_JOB_PROFILE_TYPE_CODE   VARCHAR(20);
DECLARE LS_COMPENSATION_GRADE_TYPE_CODE VARCHAR(3);
DECLARE LS_JOB_PROFILE_TYPE_CODE        VARCHAR(20);
DECLARE LS_PLAN_START_DATE              DATETIME;
DECLARE LS_PLAN_END_DATE                DATETIME;
DECLARE LS_PLAN_DURATION                VARCHAR(50);
DECLARE LS_CHARGE_START_DATE            DATETIME;
DECLARE LS_CHARGE_END_DATE              DATETIME;
DECLARE LS_CHARGE_DURATION              VARCHAR(50);
DECLARE LS_COMMITTED_COST               DECIMAL(12,2);
DECLARE LS_RESOURCE_TYPE_CODE           VARCHAR(3);
DECLARE LS_DESCRIPTION                  VARCHAR(4000);
DECLARE LS_CANDIDATE_TITLE_TYPE_CODE    VARCHAR(3);
DECLARE LS_PLANNED_BASE_SALARY          DECIMAL(12,2);
DECLARE LS_PLANNED_SALARY               DECIMAL(12,2);
DECLARE LS_RESOURCE_UNIQUE_ID           VARCHAR(100);
DECLARE LS_IS_MULTI_ACCOUNT             VARCHAR(1);
DECLARE LS_IS_MAIN_ACCOUNT              VARCHAR(1);
DECLARE LR_AWARD_NUMBER VARCHAR(12);
DECLARE LR_MODULE_CODE INT(12);
 DECLARE LR_SUB_MODULE_CODE INT(12);
 DECLARE LR_FREEZE_DATE DATETIME;
 DECLARE LR_MULTIPLIER_USED DECIMAL(12,2);
 DECLARE LR_PREVIOUS_CHARGE_END_DATE DATETIME;
 DECLARE LR_PREVIOUS_CHARGE_START_DATE DATETIME;
 DECLARE LR_BASE_SALARY_USED VARCHAR(200);
 DECLARE LR_IS_REMAINING_CA_FROM_WBS VARCHAR(1);
 DECLARE LR_IS_RESOURCE_CREATED_OR_UPDATED VARCHAR(1);
  DECLARE LR_COMMITTED_AMOUNT_USED DECIMAL(12,2);
  DECLARE LS_CPFC_AMOUNT				DECIMAL(12,2);
  DECLARE LS_CPFE_PERCENTAGE			DECIMAL(12,2);
  DECLARE LS_SDL_PERCENTAGE				DECIMAL(12,2);
  DECLARE LS_SDLC_AMOUNT				    DECIMAL(12,2);
  DECLARE LS_ONB_PERCENTAGE				DECIMAL(12,2);
  DECLARE LS_YEARLY_BENEFIT_AMOUNT		DECIMAL(12,2);
  DECLARE LS_ANNUAL_WORKING_DAYS			DECIMAL(12,2);
  DECLARE LS_PI_SUP_ORG_ID_USED			VARCHAR(20);
DECLARE LS_DOCUMENT_UPDATE_USER         VARCHAR(60);
DECLARE LS_DOCUMENT_UPDATE_TIMESTAMP    DATETIME;
DECLARE LI_COUNT  INT;
DECLARE LI_RESOURCE_HAS_COUNT INT;

    BEGIN

            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
            set sql_safe_updates = 0;
                GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
                 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;

                SET @full_error = CONCAT(@msg,'|SEC131-4|',LS_TABLE_NAME );

                SELECT @full_error INTO LS_ERROR_MSG;

                RESIGNAL SET MESSAGE_TEXT = LS_ERROR_MSG;

            END;

            SELECT
    COUNT(1)
INTO LI_FLAG FROM
    AWARD
WHERE
    AWARD_NUMBER = AV_AWARD_NUMBER
        AND SEQUENCE_NUMBER = 0;

            IF LI_FLAG > 0 THEN

                SELECT AWARD_ID,SEQUENCE_NUMBER
                INTO LI_MASTER_AWARD_ID,LI_MASTER_SEQ_NUMBER
                FROM AWARD
                WHERE AWARD_NUMBER = AV_AWARD_NUMBER
                AND SEQUENCE_NUMBER = 0;

            END IF;


            DELETE FROM AWARD_MANPOWER_RESOURCE
            WHERE  AWARD_MANPOWER_ID IN (SELECT AWARD_MANPOWER_ID FROM AWARD_MANPOWER
                                        WHERE AWARD_ID = LI_MASTER_AWARD_ID
                                        AND MANPOWER_TYPE_CODE IN(2,3));

            DELETE FROM AWARD_MANPOWER
            WHERE AWARD_ID = LI_MASTER_AWARD_ID AND MANPOWER_TYPE_CODE IN(2,3);








            SET LS_TABLE_NAME = 'AWARD_MANPOWER';
            BEGIN

                DECLARE DONE1 INT DEFAULT FALSE;

                DECLARE CUR_AWARD_MANPWR CURSOR FOR
                SELECT
                    AWARD_MANPOWER_ID,
                    MANPOWER_TYPE_CODE,
                    BUDGET_REFERENCE_NUMBER,
                    BUDGET_REFERENCE_TYPE_CODE,
                    BUDGET_VERSION_NUMBER,
                    ACTUAL_HEADCOUNT,
                    CREATE_USER,
                    CREATE_TIMESTAMP,
                    UPDATE_USER,
                    UPDATE_TIMESTAMP,
                    MODULE_CODE,
                    SUB_MODULE_CODE
                FROM AWARD_MANPOWER
                WHERE AWARD_ID = AV_AWARD_ID;

                DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;

                OPEN CUR_AWARD_MANPWR;
                INSERT_CUR_AWARD_MANPWR_LOOP: LOOP
                FETCH CUR_AWARD_MANPWR INTO
                LI_AWARD_MANPOWER_ID,
                LS_MANPOWER_TYPE_CODE,
                LS_BUDGET_REFERENCE_NUMBER,
                LS_BUDGET_REFERENCE_TYPE_CODE,
                LI_BUDGET_VERSION_NUMBER,
                LI_ACTUAL_HEADCOUNT,
                LS_CREATE_USER,
                LS_CREATE_TIMESTAMP,
                LS_UPDATE_USER,
                LS_UPDATE_TIMESTAMP,
                LS_MODULE_CODE,
                LS_SUB_MODULE_CODE;

                IF DONE1 THEN
                    LEAVE INSERT_CUR_AWARD_MANPWR_LOOP;
                END IF;

                IF (LS_MANPOWER_TYPE_CODE = 1 ) THEN

                    SELECT COUNT(*) INTO LI_COUNT
                    FROM AWARD_MANPOWER
                    WHERE BUDGET_REFERENCE_NUMBER = LS_BUDGET_REFERENCE_NUMBER
                    AND  AWARD_ID  = LI_MASTER_AWARD_ID ;

                ELSE

                    SET LI_COUNT = 0;

                END IF;

                        IF (LI_COUNT = 0) THEN


                                INSERT INTO AWARD_MANPOWER(
                                AWARD_ID,
                                AWARD_NUMBER,
                                SEQUENCE_NUMBER,
                                MANPOWER_TYPE_CODE,
                                BUDGET_REFERENCE_NUMBER,
                                BUDGET_REFERENCE_TYPE_CODE,
                                BUDGET_VERSION_NUMBER,
                                ACTUAL_HEADCOUNT,
                                CREATE_USER,
                                CREATE_TIMESTAMP,
                                UPDATE_USER,
                                UPDATE_TIMESTAMP,
                                MODULE_CODE,
                                SUB_MODULE_CODE
                                )
                                VALUES
                                (
                                LI_MASTER_AWARD_ID,
                                AV_AWARD_NUMBER,
                                LI_MASTER_SEQ_NUMBER,
                                LS_MANPOWER_TYPE_CODE,
                                LS_BUDGET_REFERENCE_NUMBER,
                                LS_BUDGET_REFERENCE_TYPE_CODE,
                                LI_BUDGET_VERSION_NUMBER,
                                LI_ACTUAL_HEADCOUNT,
                                LS_CREATE_USER,
                                LS_CREATE_TIMESTAMP,
                                LS_UPDATE_USER,
                                LS_UPDATE_TIMESTAMP,
                                LS_MODULE_CODE,
                                LS_SUB_MODULE_CODE
                                );

                                SELECT LAST_INSERT_ID() INTO LI_AWARD_MANPWR_NEXT_VAL;
                        ELSE


                                UPDATE AWARD_MANPOWER
                                SET BUDGET_REFERENCE_TYPE_CODE = LS_BUDGET_REFERENCE_TYPE_CODE,
                                BUDGET_VERSION_NUMBER = LI_BUDGET_VERSION_NUMBER,
                                ACTUAL_HEADCOUNT = LI_ACTUAL_HEADCOUNT,
                                CREATE_USER = LS_CREATE_USER,
                                CREATE_TIMESTAMP = LS_CREATE_TIMESTAMP,
                                UPDATE_USER = LS_UPDATE_USER,
                                UPDATE_TIMESTAMP = LS_UPDATE_TIMESTAMP,
                                MODULE_CODE = LS_MODULE_CODE,
                                SUB_MODULE_CODE = LS_SUB_MODULE_CODE
                                where BUDGET_REFERENCE_NUMBER = LS_BUDGET_REFERENCE_NUMBER
                                AND AWARD_ID = LI_MASTER_AWARD_ID;


                                SELECT AWARD_MANPOWER_ID INTO LI_AWARD_MANPWR_NEXT_VAL
                                FROM AWARD_MANPOWER
                                WHERE BUDGET_REFERENCE_NUMBER = LS_BUDGET_REFERENCE_NUMBER
                                AND AWARD_ID = LI_MASTER_AWARD_ID;

                        END IF;


                        SET LS_TABLE_NAME = 'AWARD_MANPOWER_RESOURCE';

                         BEGIN

                            DECLARE DONE2 INT DEFAULT FALSE;

                            DECLARE CUR_AWD_MANPWR_RES CURSOR FOR
                            SELECT
                                PERSON_ID, ROLODEX_ID, POSITION_ID, FULL_NAME, POSITION_STATUS_CODE, COST_ALLOCATION, PLAN_COMPENSATION_TYPE_CODE,
                                PLAN_JOB_PROFILE_TYPE_CODE, COMPENSATION_GRADE_TYPE_CODE, JOB_PROFILE_TYPE_CODE, PLAN_START_DATE, PLAN_END_DATE, PLAN_DURATION,
                                CHARGE_START_DATE, CHARGE_END_DATE, CHARGE_DURATION, COMMITTED_COST, RESOURCE_TYPE_CODE, DESCRIPTION,
                                CANDIDATE_TITLE_TYPE_CODE, PLANNED_BASE_SALARY, PLANNED_SALARY, RESOURCE_UNIQUE_ID, CREATE_USER,
                                CREATE_TIMESTAMP, UPDATE_USER, UPDATE_TIMESTAMP,AWARD_NUMBER, MODULE_CODE, SUB_MODULE_CODE, FREEZE_DATE, MULTIPLIER_USED,
                                PREVIOUS_CHARGE_END_DATE, PREVIOUS_CHARGE_START_DATE, BASE_SALARY_USED, IS_REMAINING_CA_FROM_WBS, IS_RESOURCE_CREATED_OR_UPDATED,IS_MULTI_ACCOUNT,IS_MAIN_ACCOUNT,CPFC_AMOUNT,CPFE_PERCENTAGE,SDL_PERCENTAGE,SDLC_AMOUNT,ONB_PERCENTAGE,YEARLY_BENEFIT_AMOUNT,ANNUAL_WORKING_DAYS,PI_SUP_ORG_ID_USED,COMMITTED_AMOUNT_USED

                            FROM AWARD_MANPOWER_RESOURCE
                            WHERE AWARD_MANPOWER_ID = LI_AWARD_MANPOWER_ID;

                            DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE2 = TRUE;

                            OPEN CUR_AWD_MANPWR_RES;
                            INSERT_CUR_AWD_MANPWR_RES_LOOP: LOOP
                            FETCH CUR_AWD_MANPWR_RES INTO
                            LS_PERSON_ID,
                            LI_ROLODEX_ID,
                            LS_POSITION_ID,
                            LS_FULL_NAME,
                            LS_POSITION_STATUS_CODE,
                            LI_COST_ALLOCATION,
                            LS_PLAN_COMPENSATION_TYPE_CODE,
                            LS_PLAN_JOB_PROFILE_TYPE_CODE,
                            LS_COMPENSATION_GRADE_TYPE_CODE,
                            LS_JOB_PROFILE_TYPE_CODE,
                            LS_PLAN_START_DATE,
                            LS_PLAN_END_DATE,
                            LS_PLAN_DURATION,
                            LS_CHARGE_START_DATE,
                            LS_CHARGE_END_DATE,
                            LS_CHARGE_DURATION,
                            LS_COMMITTED_COST,
                            LS_RESOURCE_TYPE_CODE,
                            LS_DESCRIPTION,
                            LS_CANDIDATE_TITLE_TYPE_CODE,
                            LS_PLANNED_BASE_SALARY,
                            LS_PLANNED_SALARY,
                            LS_RESOURCE_UNIQUE_ID,
                            LS_CREATE_USER,
                            LS_CREATE_TIMESTAMP,
                            LS_UPDATE_USER,
                            LS_UPDATE_TIMESTAMP,
                            LR_AWARD_NUMBER ,
                            LR_MODULE_CODE ,
                             LR_SUB_MODULE_CODE ,
                             LR_FREEZE_DATE ,
                             LR_MULTIPLIER_USED ,
                             LR_PREVIOUS_CHARGE_END_DATE ,
                             LR_PREVIOUS_CHARGE_START_DATE ,
                             LR_BASE_SALARY_USED ,
                             LR_IS_REMAINING_CA_FROM_WBS ,
                             LR_IS_RESOURCE_CREATED_OR_UPDATED,
                             LS_IS_MULTI_ACCOUNT,
                             LS_IS_MAIN_ACCOUNT,
                             LS_CPFC_AMOUNT,
                             LS_CPFE_PERCENTAGE,
                             LS_SDL_PERCENTAGE,
                             LS_SDLC_AMOUNT,
                             LS_ONB_PERCENTAGE,
                             LS_YEARLY_BENEFIT_AMOUNT,
                             LS_ANNUAL_WORKING_DAYS,
                             LS_PI_SUP_ORG_ID_USED,
                             LR_COMMITTED_AMOUNT_USED;

                            IF DONE2 THEN
                                LEAVE INSERT_CUR_AWD_MANPWR_RES_LOOP;
                            END IF;

                            IF (LI_COUNT = 1) THEN


                                SELECT COUNT(*) INTO LI_RESOURCE_HAS_COUNT
                                FROM AWARD_MANPOWER_RESOURCE
                                WHERE RESOURCE_UNIQUE_ID =  LS_RESOURCE_UNIQUE_ID
                                AND AWARD_MANPOWER_ID IN(SELECT AWARD_MANPOWER_ID FROM AWARD_MANPOWER
                                                        WHERE AWARD_ID = LI_MASTER_AWARD_ID );


                            ELSE

                                SET LI_RESOURCE_HAS_COUNT = 0;

                            END IF;

                            IF (LI_RESOURCE_HAS_COUNT = 0) THEN


                                    INSERT INTO AWARD_MANPOWER_RESOURCE
                                    (
                                     AWARD_MANPOWER_ID, PERSON_ID, ROLODEX_ID, POSITION_ID, FULL_NAME, POSITION_STATUS_CODE, COST_ALLOCATION,
                                     PLAN_COMPENSATION_TYPE_CODE, PLAN_JOB_PROFILE_TYPE_CODE, COMPENSATION_GRADE_TYPE_CODE, JOB_PROFILE_TYPE_CODE, PLAN_START_DATE,
                                     PLAN_END_DATE, PLAN_DURATION, CHARGE_START_DATE, CHARGE_END_DATE, CHARGE_DURATION, COMMITTED_COST, RESOURCE_TYPE_CODE,
                                     DESCRIPTION, CANDIDATE_TITLE_TYPE_CODE, PLANNED_BASE_SALARY, PLANNED_SALARY,
                                     RESOURCE_UNIQUE_ID, CREATE_USER, CREATE_TIMESTAMP, UPDATE_USER, UPDATE_TIMESTAMP,
                                     AWARD_NUMBER, MODULE_CODE, SUB_MODULE_CODE, FREEZE_DATE, MULTIPLIER_USED,
                                    PREVIOUS_CHARGE_END_DATE, PREVIOUS_CHARGE_START_DATE, BASE_SALARY_USED, IS_REMAINING_CA_FROM_WBS, IS_RESOURCE_CREATED_OR_UPDATED,IS_MULTI_ACCOUNT,IS_MAIN_ACCOUNT,CPFC_AMOUNT,CPFE_PERCENTAGE,SDL_PERCENTAGE,SDLC_AMOUNT,ONB_PERCENTAGE,YEARLY_BENEFIT_AMOUNT,ANNUAL_WORKING_DAYS,PI_SUP_ORG_ID_USED,COMMITTED_AMOUNT_USED
                                    )
                                    VALUES
                                    (
                                    LI_AWARD_MANPWR_NEXT_VAL,
                                    LS_PERSON_ID,
                                    LI_ROLODEX_ID,
                                    LS_POSITION_ID,
                                    LS_FULL_NAME,
                                    LS_POSITION_STATUS_CODE,
                                    LI_COST_ALLOCATION,
                                    LS_PLAN_COMPENSATION_TYPE_CODE,
                                    LS_PLAN_JOB_PROFILE_TYPE_CODE,
                                    LS_COMPENSATION_GRADE_TYPE_CODE,
                                    LS_JOB_PROFILE_TYPE_CODE,
                                    LS_PLAN_START_DATE,
                                    LS_PLAN_END_DATE,
                                    LS_PLAN_DURATION,
                                    LS_CHARGE_START_DATE,
                                    LS_CHARGE_END_DATE,
                                    LS_CHARGE_DURATION,
                                    LS_COMMITTED_COST,
                                    LS_RESOURCE_TYPE_CODE,
                                    LS_DESCRIPTION,
                                    LS_CANDIDATE_TITLE_TYPE_CODE,
                                    LS_PLANNED_BASE_SALARY,
                                    LS_PLANNED_SALARY,
                                    LS_RESOURCE_UNIQUE_ID,
                                    LS_CREATE_USER,
                                    LS_CREATE_TIMESTAMP,
                                    LS_UPDATE_USER,
                                    LS_UPDATE_TIMESTAMP,
                                    LR_AWARD_NUMBER ,
                                    LR_MODULE_CODE ,
                                     LR_SUB_MODULE_CODE ,
                                     LR_FREEZE_DATE ,
                                     LR_MULTIPLIER_USED ,
                                     LR_PREVIOUS_CHARGE_END_DATE ,
                                     LR_PREVIOUS_CHARGE_START_DATE ,
                                     LR_BASE_SALARY_USED ,
                                     LR_IS_REMAINING_CA_FROM_WBS ,
                                     LR_IS_RESOURCE_CREATED_OR_UPDATED,
                                     LS_IS_MULTI_ACCOUNT,
                                     LS_IS_MAIN_ACCOUNT,
                                     LS_CPFC_AMOUNT,
                                     LS_CPFE_PERCENTAGE,
                                     LS_SDL_PERCENTAGE,
                                     LS_SDLC_AMOUNT,
                                     LS_ONB_PERCENTAGE,
                                     LS_YEARLY_BENEFIT_AMOUNT,
                                     LS_ANNUAL_WORKING_DAYS,
                                     LS_PI_SUP_ORG_ID_USED,
                                     LR_COMMITTED_AMOUNT_USED
                                    );
                            ELSE

                                    UPDATE AWARD_MANPOWER_RESOURCE
                                    SET PERSON_ID = LS_PERSON_ID,
                                    ROLODEX_ID = LI_ROLODEX_ID,
                                    POSITION_ID = LS_POSITION_ID,
                                    FULL_NAME = LS_FULL_NAME,
                                    POSITION_STATUS_CODE = LS_POSITION_STATUS_CODE,
                                    COST_ALLOCATION = LI_COST_ALLOCATION,
                                     PLAN_COMPENSATION_TYPE_CODE = LS_PLAN_COMPENSATION_TYPE_CODE,
                                     PLAN_JOB_PROFILE_TYPE_CODE = LS_PLAN_JOB_PROFILE_TYPE_CODE,
                                     COMPENSATION_GRADE_TYPE_CODE = LS_COMPENSATION_GRADE_TYPE_CODE,
                                     JOB_PROFILE_TYPE_CODE = LS_JOB_PROFILE_TYPE_CODE,
                                     PLAN_START_DATE = LS_PLAN_START_DATE,
                                     PLAN_END_DATE = LS_PLAN_END_DATE,
                                     PLAN_DURATION = LS_PLAN_DURATION,
                                     CHARGE_START_DATE = LS_CHARGE_START_DATE,
                                     CHARGE_END_DATE = LS_CHARGE_END_DATE,
                                     CHARGE_DURATION = LS_CHARGE_DURATION,
                                     COMMITTED_COST = LS_COMMITTED_COST,
                                     RESOURCE_TYPE_CODE = LS_RESOURCE_TYPE_CODE,
                                     DESCRIPTION = LS_DESCRIPTION,
                                     CANDIDATE_TITLE_TYPE_CODE = LS_CANDIDATE_TITLE_TYPE_CODE,
                                     PLANNED_BASE_SALARY = LS_PLANNED_BASE_SALARY,
                                     PLANNED_SALARY = LS_PLANNED_SALARY,
                                     CREATE_USER = LS_CREATE_USER,
                                     CREATE_TIMESTAMP = LS_CREATE_TIMESTAMP,
                                     UPDATE_USER = LS_UPDATE_USER,
                                     UPDATE_TIMESTAMP = LS_UPDATE_TIMESTAMP,
                                     AWARD_NUMBER = LR_AWARD_NUMBER,
                                     MODULE_CODE = LR_MODULE_CODE,
                                     SUB_MODULE_CODE = LR_SUB_MODULE_CODE,
                                     FREEZE_DATE = LR_FREEZE_DATE,
                                     MULTIPLIER_USED = LR_MULTIPLIER_USED,
                                    PREVIOUS_CHARGE_END_DATE = LR_PREVIOUS_CHARGE_END_DATE,
                                    PREVIOUS_CHARGE_START_DATE = LR_PREVIOUS_CHARGE_START_DATE ,
                                    BASE_SALARY_USED = LR_BASE_SALARY_USED,
                                    IS_REMAINING_CA_FROM_WBS = LR_IS_REMAINING_CA_FROM_WBS,
                                    IS_RESOURCE_CREATED_OR_UPDATED = LR_IS_RESOURCE_CREATED_OR_UPDATED,
                                    IS_MULTI_ACCOUNT = LS_IS_MULTI_ACCOUNT,
                                    IS_MAIN_ACCOUNT = LS_IS_MAIN_ACCOUNT,
                                    COMMITTED_AMOUNT_USED = LR_COMMITTED_AMOUNT_USED,
                                    CPFC_AMOUNT = LS_CPFC_AMOUNT,
                                    CPFE_PERCENTAGE = LS_CPFE_PERCENTAGE,
                                    SDL_PERCENTAGE = LS_SDL_PERCENTAGE,
                                    SDLC_AMOUNT = LS_SDLC_AMOUNT,
                                    ONB_PERCENTAGE = LS_ONB_PERCENTAGE,
                                    YEARLY_BENEFIT_AMOUNT = LS_YEARLY_BENEFIT_AMOUNT,
                                    ANNUAL_WORKING_DAYS = LS_ANNUAL_WORKING_DAYS,
                                    PI_SUP_ORG_ID_USED = LS_PI_SUP_ORG_ID_USED
                                    WHERE RESOURCE_UNIQUE_ID =  LS_RESOURCE_UNIQUE_ID
                                    AND AWARD_MANPOWER_ID = (SELECT AWARD_MANPOWER_ID FROM AWARD_MANPOWER WHERE
                                    BUDGET_REFERENCE_NUMBER = LS_BUDGET_REFERENCE_NUMBER AND AWARD_ID = LI_MASTER_AWARD_ID);
                            END IF;
                        END LOOP;
                        CLOSE CUR_AWD_MANPWR_RES;
                        END;
                       
                       
                       
                        END LOOP;
                        CLOSE CUR_AWARD_MANPWR;
                   
                    END;
                   
    END;
END
