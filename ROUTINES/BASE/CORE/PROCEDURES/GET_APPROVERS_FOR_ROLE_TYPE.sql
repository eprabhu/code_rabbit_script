CREATE PROCEDURE `GET_APPROVERS_FOR_ROLE_TYPE`(
        AV_MODULE_CODE DECIMAL(38, 0),
        AV_MODULE_ITEM_ID VARCHAR(20),
        AV_ROLE_TYPE DECIMAL(38, 0),
        AV_SUBMODULE_CODE DECIMAL(38, 0),
        AV_SUB_MODULE_ITEM_KEY VARCHAR(20)
) DETERMINISTIC
BEGIN
DECLARE LI_RETURN DECIMAL(38, 0);
DECLARE LS_LEAD_UNIT VARCHAR(50);
DECLARE LS_SUBMITING_UNIT_NUMBER VARCHAR(50);
DECLARE LS_UNIT_ADMIN_TYPE_CODE DECIMAL(38, 0);
DECLARE LS_CREATE_USER VARCHAR(20);
DECLARE LS_CODE CHAR(5) DEFAULT '00000';
DECLARE LS_MSG TEXT;
DECLARE LI_MODULE_CODE INT(3);
DECLARE LS_MODULE_ITEM_KEY VARCHAR(20);
DECLARE LS_AWARD_ID VARCHAR(22);
DECLARE LS_AWARD_NUMBER VARCHAR(12);
DECLARE LS_ACTIVE_AWARD_ID VARCHAR(22);
DECLARE LI_FLAG INT;
DECLARE LS_ADMIN_PERSON_ID VARCHAR(22);
DECLARE LI_GRANT_TYPE INT;
DECLARE LI_FUNDING_SCHEME_ID INT;
DECLARE LI_PERSON_COUNT INT;
DECLARE LI_COUNT INT DEFAULT 0;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
BEGIN 
        GET DIAGNOSTICS CONDITION 1 LS_CODE = RETURNED_SQLSTATE,LS_MSG = MESSAGE_TEXT;
END;

IF AV_MODULE_CODE = 1 THEN
        SELECT T2.AWARD_ID INTO LS_ACTIVE_AWARD_ID
        FROM AWARD T1,AWARD T2
        WHERE T1.AWARD_ID = AV_MODULE_ITEM_ID
        AND T1.AWARD_NUMBER = T2.AWARD_NUMBER
        AND T2.AWARD_SEQUENCE_STATUS = 'ACTIVE';
        IF LS_ACTIVE_AWARD_ID IS NOT NULL THEN
                SET AV_MODULE_ITEM_ID = LS_ACTIVE_AWARD_ID;
        END IF;
        SELECT LEAD_UNIT_NUMBER INTO LS_LEAD_UNIT
        FROM AWARD
        WHERE AWARD_ID = AV_MODULE_ITEM_ID;

ELSEIF AV_MODULE_CODE = 2 THEN
        SELECT HOME_UNIT_NUMBER INTO LS_LEAD_UNIT
        FROM PROPOSAL
        WHERE PROPOSAL_ID = AV_MODULE_ITEM_ID;				  
ELSEIF AV_MODULE_CODE = 3 THEN
        SELECT HOME_UNIT_NUMBER INTO LS_LEAD_UNIT
        FROM EPS_PROPOSAL
        WHERE PROPOSAL_ID = AV_MODULE_ITEM_ID;

ELSEIF AV_MODULE_CODE = 12 THEN
        SELECT UNIT_NUMBER INTO LS_LEAD_UNIT
        FROM AGREEMENT_HEADER
        WHERE AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID;
        IF LS_LEAD_UNIT IS NULL THEN
                SELECT UNIT_NUMBER INTO LS_LEAD_UNIT
                FROM UNIT
                WHERE PARENT_UNIT_NUMBER IS NULL;
        END IF;

ELSEIF AV_MODULE_CODE = 15 THEN
        SELECT HOME_UNIT_NUMBER INTO LS_LEAD_UNIT
        FROM GRANT_CALL_HEADER
        WHERE GRANT_HEADER_ID = AV_MODULE_ITEM_ID;

ELSEIF AV_MODULE_CODE = 20 THEN
        SELECT MODULE_CODE,ORIGINATING_MODULE_ITEM_KEY INTO LI_MODULE_CODE,LS_MODULE_ITEM_KEY
        FROM SR_HEADER T1
        WHERE T1.SR_HEADER_ID = AV_MODULE_ITEM_ID;
        IF LI_MODULE_CODE = 1 THEN
                SELECT AWARD_ID,LEAD_UNIT_NUMBER INTO LS_AWARD_ID,LS_LEAD_UNIT
                FROM AWARD
                WHERE AWARD_ID = LS_MODULE_ITEM_KEY;
        ELSEIF LI_MODULE_CODE = 3 THEN
                SELECT HOME_UNIT_NUMBER INTO LS_LEAD_UNIT
                FROM EPS_PROPOSAL
                WHERE PROPOSAL_ID = LS_MODULE_ITEM_KEY;
        END IF;

ELSEIF AV_MODULE_CODE = 14 THEN
        SELECT LEAD_UNIT_NUMBER,AWARD_ID INTO LS_LEAD_UNIT,LS_AWARD_ID
        FROM AWARD
        WHERE AWARD_ID IN(
                SELECT AWARD_ID
                FROM CLAIM
                WHERE CLAIM_ID = AV_MODULE_ITEM_ID
        );

ELSEIF AV_MODULE_CODE = 16 THEN
        SELECT LEAD_UNIT_NUMBER,AWARD_ID INTO LS_LEAD_UNIT,LS_AWARD_ID
        FROM AWARD
        WHERE AWARD_ID IN(
                SELECT AWARD_ID
                FROM AWARD_PROGRESS_REPORT
                WHERE PROGRESS_REPORT_ID = AV_MODULE_ITEM_ID
        );

ELSEIF AV_MODULE_CODE = 21 THEN
        SELECT FUNDING_OFFICE INTO LS_LEAD_UNIT
        FROM EXTERNAL_USER
        WHERE PERSON_ID = AV_MODULE_ITEM_ID;
END IF;

IF AV_ROLE_TYPE IN (1, 3) THEN
        IF AV_MODULE_CODE = 15 AND AV_SUBMODULE_CODE = 1 THEN
                SELECT SUBMITING_UNIT_NUMBER INTO LS_SUBMITING_UNIT_NUMBER
                FROM GRANT_CALL_IOI_HEADER
                WHERE GRANT_HEADER_ID = AV_MODULE_ITEM_ID
                AND IOI_ID = AV_SUB_MODULE_ITEM_KEY;
                SELECT T1.PERSON_ID
                FROM UNIT_ADMINISTRATOR T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.UNIT_NUMBER = LS_SUBMITING_UNIT_NUMBER
                AND T1.UNIT_ADMINISTRATOR_TYPE_CODE = (
                        SELECT (
                                CASE
                                        AV_ROLE_TYPE
                                        WHEN 1 THEN 1
                                        WHEN 3 THEN 4
                                END
                        ) AS UNIT_ADMINISTRATOR_TYPE_CODE
                FROM DUAL
                )
                AND T2.STATUS = 'A';
        ELSE
                SELECT T1.PERSON_ID
                FROM UNIT_ADMINISTRATOR T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.UNIT_NUMBER = LS_LEAD_UNIT
                AND T1.UNIT_ADMINISTRATOR_TYPE_CODE = (
                        SELECT (
                                CASE
                                        AV_ROLE_TYPE
                                        WHEN 1 THEN 1
                                        WHEN 3 THEN 4
                                END
                        ) AS UNIT_ADMINISTRATOR_TYPE_CODE
                FROM DUAL
                )
                AND T2.STATUS = 'A';
        END IF;

ELSEIF AV_ROLE_TYPE = 2 THEN 

        IF AV_MODULE_CODE = 13 THEN
                SELECT DISTINCT T1.PERSON_ID
                FROM PERSON_ROLES T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.UNIT_NUMBER = LS_LEAD_UNIT
                AND T1.ROLE_ID = 400
                AND T2.STATUS = 'A';
        ELSE
                SELECT DISTINCT T1.PERSON_ID
                FROM PERSON_ROLES T1
                LEFT JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.ROLE_ID = 400
                AND T1.UNIT_NUMBER = LS_LEAD_UNIT
                AND T2.STATUS = 'A';
        END IF;

ELSEIF AV_ROLE_TYPE = 4 THEN 

        IF AV_MODULE_CODE = 5 THEN
                SELECT T1.NEGOTIATOR_PERSON_ID
                FROM NEGOTIATION T1
                INNER JOIN PERSON T2 ON T1.NEGOTIATOR_PERSON_ID = T2.PERSON_ID
                WHERE T1.NEGOTIATION_ID = AV_MODULE_ITEM_ID
                AND T2.STATUS = 'A';

        ELSEIF AV_MODULE_CODE = 12 THEN
                SELECT T1.NEGOTIATOR_PERSON_ID AS PERSON_ID
                FROM AGREEMENT_HEADER T1
                INNER JOIN PERSON T2 ON T1.NEGOTIATOR_PERSON_ID = T2.PERSON_ID
                WHERE T1.AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID
                AND T2.STATUS = 'A';
        ELSEIF AV_MODULE_CODE = 13 THEN
                SELECT T1.PERSON_ID
                FROM AGREEMENT_PEOPLE T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID
                AND T1.PEOPLE_TYPE_ID = 2
                AND T2.STATUS = 'A';
        END IF;

ELSEIF AV_ROLE_TYPE = 5 THEN 

        IF AV_MODULE_CODE = 1 THEN
                SELECT T2.PERSON_ID
                FROM AWARD T1
                INNER JOIN AWARD_PERSONS T2 ON T1.AWARD_ID = T2.AWARD_ID
                INNER JOIN PERSON T3 ON T2.PERSON_ID = T3.PERSON_ID
                WHERE T1.AWARD_ID = AV_MODULE_ITEM_ID
                AND T2.PERSON_ROLE_ID = 3
                AND T3.STATUS = 'A';
        ELSEIF AV_MODULE_CODE = 16 THEN
                SELECT T2.PERSON_ID
                FROM AWARD T1
                INNER JOIN AWARD_PERSONS T2 ON T1.AWARD_ID = T2.AWARD_ID
                INNER JOIN PERSON T3 ON T2.PERSON_ID = T3.PERSON_ID
                WHERE T1.AWARD_ID = LS_AWARD_ID
                AND T2.PERSON_ROLE_ID = 3
                AND T3.STATUS = 'A';
        ELSEIF AV_MODULE_CODE = 3 THEN
                SELECT T2.PERSON_ID
                FROM EPS_PROPOSAL T1
                INNER JOIN EPS_PROPOSAL_PERSONS T2 ON T1.PROPOSAL_ID = T2.PROPOSAL_ID
                AND T2.PROP_PERSON_ROLE_ID = 3
                INNER JOIN PERSON T3 ON T2.PERSON_ID = T3.PERSON_ID
                WHERE T1.PROPOSAL_ID = AV_MODULE_ITEM_ID
                AND T3.STATUS = 'A';
        ELSEIF AV_MODULE_CODE = 2 THEN
                SELECT T2.PERSON_ID
                FROM PROPOSAL T1
                INNER JOIN PROPOSAL_PERSONS T2 ON T1.PROPOSAL_ID = T2.PROPOSAL_ID
                AND T2.PROP_PERSON_ROLE_ID = 3
                INNER JOIN PERSON T3 ON T2.PERSON_ID = T3.PERSON_ID
                WHERE T1.PROPOSAL_ID = AV_MODULE_ITEM_ID
                AND T3.STATUS = 'A';
        ELSEIF AV_MODULE_CODE = 20 THEN
                SELECT MODULE_CODE,ORIGINATING_MODULE_ITEM_KEY INTO LI_MODULE_CODE, LS_MODULE_ITEM_KEY
                FROM SR_HEADER T1
                WHERE T1.SR_HEADER_ID = AV_MODULE_ITEM_ID;
                IF LI_MODULE_CODE = 1 THEN
                        SELECT T2.PERSON_ID
                        FROM AWARD T1
                        INNER JOIN AWARD_PERSONS T2 ON T1.AWARD_ID = T2.AWARD_ID
                        INNER JOIN PERSON T3 ON T2.PERSON_ID = T3.PERSON_ID
                        WHERE T1.AWARD_ID = LS_AWARD_ID
                        AND T2.PERSON_ROLE_ID = 3
                        AND T3.STATUS = 'A';
                ELSEIF LI_MODULE_CODE = 3 THEN
                        SELECT T2.PERSON_ID
                        FROM EPS_PROPOSAL T1
                        INNER JOIN EPS_PROPOSAL_PERSONS T2 ON T1.PROPOSAL_ID = T2.PROPOSAL_ID
                        AND T2.PROP_PERSON_ROLE_ID = 3
                        INNER JOIN PERSON T3 ON T2.PERSON_ID = T3.PERSON_ID
                        WHERE T1.PROPOSAL_ID = LS_MODULE_ITEM_KEY
                        AND T3.STATUS = 'A';
                END IF;

        ELSEIF AV_MODULE_CODE = 15 AND AV_SUBMODULE_CODE = 1 THEN
                SELECT T1.PI_PERSON_ID AS PERSON_ID
                FROM GRANT_CALL_IOI_HEADER T1
                INNER JOIN PERSON T2 ON T1.PI_PERSON_ID = T2.PERSON_ID
                WHERE T1.GRANT_HEADER_ID = AV_MODULE_ITEM_ID
                AND T1.IOI_ID = AV_SUB_MODULE_ITEM_KEY
                AND T2.STATUS = 'A';

        ELSEIF AV_MODULE_CODE = 14 THEN
                SELECT T2.PERSON_ID
                FROM CLAIM T
                INNER JOIN AWARD T1 ON T.AWARD_ID = T1.AWARD_ID
                INNER JOIN AWARD_PERSONS T2 ON T1.AWARD_ID = T2.AWARD_ID
                INNER JOIN PERSON T3 ON T3.PERSON_ID = T2.PERSON_ID
                WHERE T.CLAIM_ID = AV_MODULE_ITEM_ID
                AND T2.PERSON_ROLE_ID = 3
                AND T3.STATUS = 'A';

        ELSEIF AV_MODULE_CODE = 13 THEN
                SELECT DISTINCT T1.PERSON_ID
                FROM AGREEMENT_PEOPLE T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID
                AND T1.PEOPLE_TYPE_ID = 3
                AND T2.STATUS = 'A';

        ELSEIF AV_MODULE_CODE = 16 THEN
                SELECT T2.PERSON_ID
                FROM AWARD T1
                INNER JOIN AWARD_PERSONS T2 ON T1.AWARD_ID = T2.AWARD_ID
                INNER JOIN PERSON T3 ON T3.PERSON_ID = T2.PERSON_ID
                WHERE T1.AWARD_ID = LS_AWARD_ID
                AND T2.PERSON_ROLE_ID = 3
                AND T3.STATUS = 'A';
        END IF;

ELSEIF AV_ROLE_TYPE = 6 THEN 

        IF AV_MODULE_CODE = 1 THEN
                SELECT T2.PERSON_ID
                FROM AWARD T1
                INNER JOIN AWARD_PERSONS T2 ON T1.AWARD_ID = T2.AWARD_ID
                INNER JOIN PERSON T3 ON T3.PERSON_ID = T2.PERSON_ID
                WHERE T1.AWARD_ID = AV_MODULE_ITEM_ID
                AND T3.STATUS = 'A';
        ELSEIF AV_MODULE_CODE = 2 THEN
                SELECT T1.PERSON_ID
                FROM PROPOSAL_PERSONS T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.PROPOSAL_ID = AV_MODULE_ITEM_ID
                AND T2.STATUS = 'A';
        ELSEIF AV_MODULE_CODE = 3 THEN
                SELECT T1.PERSON_ID
                FROM EPS_PROPOSAL_PERSONS T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.PROPOSAL_ID = AV_MODULE_ITEM_ID
                AND T2.STATUS = 'A';
        ELSEIF AV_MODULE_CODE = 20 THEN
                SELECT MODULE_CODE,MODULE_ITEM_KEY INTO LI_MODULE_CODE,LS_MODULE_ITEM_KEY
                FROM SR_HEADER T1
                WHERE T1.SR_HEADER_ID = AV_MODULE_ITEM_ID;
                IF LI_MODULE_CODE = 1 THEN
                        SELECT T2.PERSON_ID
                        FROM AWARD T1
                        INNER JOIN AWARD_PERSONS T2 ON T1.AWARD_ID = T2.AWARD_ID
                        INNER JOIN PERSON T3 ON T3.PERSON_ID = T2.PERSON_ID
                        WHERE T1.AWARD_ID = LS_AWARD_ID
                        AND T3.STATUS = 'A';
                ELSEIF LI_MODULE_CODE = 3 THEN
                        SELECT T1.PERSON_ID
                        FROM EPS_PROPOSAL_PERSONS T1
                        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                        WHERE T1.PROPOSAL_ID = LS_MODULE_ITEM_KEY
                        AND T2.STATUS = 'A';
                END IF;
        END IF;

ELSEIF AV_ROLE_TYPE = 8 THEN 
        IF AV_MODULE_CODE = 3 THEN
                SELECT T2.PERSON_ID
                FROM PERSON T2
                WHERE T2.PERSON_ID in (
                        SELECT S2.SUPERVISOR_PERSON_ID
                        FROM EPS_PROPOSAL_PERSONS S1
                        INNER JOIN PERSON S2 ON S1.PERSON_ID = S2.PERSON_ID
                        WHERE S1.PROPOSAL_ID = AV_MODULE_ITEM_ID
                        AND S1.PROP_PERSON_ROLE_ID = 3
                )
                AND T2.STATUS = 'A';
        END IF;

ELSEIF AV_ROLE_TYPE = 9 THEN
        SELECT T2.PERSON_ID
        FROM PERSON T2
        WHERE T2.DIRECTORY_TITLE = 'Faculty'
        OR T2.IS_FACULTY = 'Y'
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 10 THEN
        SELECT T2.PERSON_ID
        FROM PERSON T2
        WHERE T2.DIRECTORY_TITLE = 'Research Staff'
        OR T2.IS_RESEARCH_STAFF = 'Y'
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 11 THEN 

        IF AV_MODULE_CODE IN (14, 16, 1) THEN -- NTU
                SELECT COUNT(1) INTO LI_FLAG
                FROM UNIT
                WHERE UNIT_NUMBER = LS_LEAD_UNIT
                AND UNIT_NUMBER NOT IN (
                        SELECT UNIT_NUMBER
                        FROM UNIT
                        WHERE UNIT_NUMBER IN ('495', '259', '396')
                        OR PARENT_UNIT_NUMBER IN ('495', '259', '396')
                );
                IF LI_FLAG > 0 THEN
                        SELECT distinct T1.PERSON_ID
                        FROM PERSON_ROLES T1
                        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                        WHERE T1.ROLE_ID = '660'
                        AND T1.UNIT_NUMBER = (SELECT VALUE FROM PARAMETER WHERE PARAMETER_NAME = 'ROOT_UNIT')
                        AND T2.STATUS = 'A';
                ELSE -- LKCM
                        SELECT COUNT(1) INTO LI_FLAG
                        FROM UNIT
                        WHERE UNIT_NUMBER = LS_LEAD_UNIT
                        AND UNIT_NUMBER IN (
                                SELECT UNIT_NUMBER
                                FROM UNIT
                                WHERE UNIT_NUMBER = '495'
                                        OR PARENT_UNIT_NUMBER = '495'
                        );
                        IF LI_FLAG > 0 THEN
                                SELECT distinct T1.PERSON_ID
                                FROM PERSON_ROLES T1
                                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                                WHERE T1.ROLE_ID = '660'
                                AND T1.UNIT_NUMBER = '495'
                                AND T2.STATUS = 'A';
                        ELSE -- RSIS
                                SELECT COUNT(1) INTO LI_FLAG
                                FROM UNIT
                                WHERE UNIT_NUMBER = LS_LEAD_UNIT
                                AND UNIT_NUMBER IN (
                                        SELECT UNIT_NUMBER
                                        FROM UNIT
                                        WHERE UNIT_NUMBER = '259'
                                        OR PARENT_UNIT_NUMBER = '259'
                                        );
                                IF LI_FLAG > 0 THEN
                                        SELECT distinct T1.PERSON_ID
                                        FROM PERSON_ROLES T1
                                        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                                        WHERE T1.ROLE_ID = '660'
                                        AND T1.UNIT_NUMBER = '259'
                                        AND T2.STATUS = 'A';
                                ELSE -- RSIS
                                        SELECT COUNT(1) INTO LI_FLAG
                                        FROM UNIT
                                        WHERE UNIT_NUMBER = LS_LEAD_UNIT
                                        AND UNIT_NUMBER IN (
                                                SELECT UNIT_NUMBER
                                                FROM UNIT
                                                WHERE UNIT_NUMBER = '396'
                                                OR PARENT_UNIT_NUMBER = '396'
                                        );
                        IF LI_FLAG > 0 THEN
                                SELECT distinct T1.PERSON_ID
                                FROM PERSON_ROLES T1
                                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                                WHERE T1.ROLE_ID = '660'
                                AND T1.UNIT_NUMBER = '396'
                                AND T2.STATUS = 'A';
                        END IF;
                END IF;
                END IF;
        END IF;
        ELSE
                SELECT distinct T1.PERSON_ID
                FROM PERSON_ROLES T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.ROLE_ID = 660
                AND T2.STATUS = 'A';
        END IF;

ELSEIF AV_ROLE_TYPE = 12 THEN
        /*SELECT HOME_UNIT_NUMBER
        INTO LS_LEAD_UNIT
        FROM GRANT_CALL_HEADER
        WHERE GRANT_HEADER_ID = AV_MODULE_ITEM_ID;*/
        SELECT DISTINCT T1.PERSON_ID
        FROM PERSON_ROLES T1
        LEFT JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        WHERE ROLE_ID = 400
        AND T1.UNIT_NUMBER = LS_LEAD_UNIT
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 13 THEN 
        IF AV_MODULE_CODE = 3 THEN
                SELECT T1.FUNDING_SCHEME_ID INTO LI_FUNDING_SCHEME_ID
                FROM GRANT_CALL_HEADER T1
                INNER JOIN EPS_PROPOSAL T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                WHERE T2.PROPOSAL_ID = AV_MODULE_ITEM_ID;
                SELECT COUNT(1) INTO LI_PERSON_COUNT
                FROM GRANT_CALL_FUNDING_SCHEME_MANAGERS T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.FUNDING_SCHEME_CODE IN (
                        SELECT FUNDING_SCHEME_CODE
                        FROM SPONSOR_FUNDING_SCHEME
                        WHERE FUNDING_SCHEME_ID = LI_FUNDING_SCHEME_ID
                )
                AND T2.STATUS = 'A';
                IF LI_PERSON_COUNT = 0 THEN
                        SELECT COUNT(1) INTO LI_FLAG
                        FROM EPS_PROPOSAL T1
                        INNER JOIN GRANT_CALL_HEADER T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                        WHERE T1.PROPOSAL_ID = AV_MODULE_ITEM_ID
                        AND T1.GRANT_HEADER_ID IS NOT NULL
                        AND T2.HOME_UNIT_NUMBER <> (SELECT VALUE FROM PARAMETER WHERE PARAMETER_NAME = 'ROOT_UNIT');
                        IF LI_FLAG > 0 THEN
                                SELECT T2.HOME_UNIT_NUMBER INTO LS_LEAD_UNIT
                                FROM EPS_PROPOSAL T1
                                INNER JOIN GRANT_CALL_HEADER T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                                WHERE T1.PROPOSAL_ID = AV_MODULE_ITEM_ID;
                        ELSE
                                SELECT T1.HOME_UNIT_NUMBER INTO LS_LEAD_UNIT
                                FROM EPS_PROPOSAL T1
                                WHERE T1.PROPOSAL_ID = AV_MODULE_ITEM_ID;
                        END IF;
                        SELECT DISTINCT T1.PERSON_ID
                        FROM PERSON_ROLES T1
                        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                        WHERE T1.ROLE_ID = 100
                        AND T1.UNIT_NUMBER = LS_LEAD_UNIT
                        AND T2.STATUS = 'A';
                ELSE
                        SELECT distinct T1.PERSON_ID
                        FROM GRANT_CALL_FUNDING_SCHEME_MANAGERS T1
                                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                        WHERE T1.FUNDING_SCHEME_CODE IN (
                                SELECT FUNDING_SCHEME_CODE
                                FROM SPONSOR_FUNDING_SCHEME
                                WHERE FUNDING_SCHEME_ID = LI_FUNDING_SCHEME_ID
                        )
                        AND T2.STATUS = 'A';
                END IF;

        ELSEIF AV_MODULE_CODE = 1 THEN
                SELECT T1.FUNDING_SCHEME_ID INTO LI_FUNDING_SCHEME_ID
                FROM GRANT_CALL_HEADER T1
                INNER JOIN AWARD T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                WHERE T2.AWARD_ID = AV_MODULE_ITEM_ID;
                SELECT COUNT(1) INTO LI_PERSON_COUNT
                FROM GRANT_CALL_FUNDING_SCHEME_MANAGERS T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.FUNDING_SCHEME_CODE IN (
                        SELECT FUNDING_SCHEME_CODE
                        FROM SPONSOR_FUNDING_SCHEME
                        WHERE FUNDING_SCHEME_ID = LI_FUNDING_SCHEME_ID
                )
                AND T2.STATUS = 'A';
                IF LI_PERSON_COUNT = 0 THEN
                        SELECT COUNT(1) INTO LI_FLAG
                        FROM AWARD T1
                        INNER JOIN GRANT_CALL_HEADER T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                        WHERE T1.AWARD_ID = AV_MODULE_ITEM_ID
                        AND T1.GRANT_HEADER_ID IS NOT NULL
                        AND T2.HOME_UNIT_NUMBER <> (SELECT VALUE FROM PARAMETER WHERE PARAMETER_NAME = 'ROOT_UNIT');
                        IF LI_FLAG > 0 THEN
                                SELECT T2.HOME_UNIT_NUMBER INTO LS_LEAD_UNIT
                                FROM AWARD T1
                                INNER JOIN GRANT_CALL_HEADER T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                                WHERE T1.AWARD_ID = AV_MODULE_ITEM_ID;
                        ELSE
                                SELECT T1.LEAD_UNIT_NUMBER INTO LS_LEAD_UNIT
                                FROM AWARD T1
                                WHERE T1.AWARD_ID = AV_MODULE_ITEM_ID;
                        END IF;
                        SELECT DISTINCT T1.PERSON_ID
                        FROM PERSON_ROLES T1
                        LEFT JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                        WHERE T1.ROLE_ID = 100
                        AND T1.UNIT_NUMBER = LS_LEAD_UNIT
                        AND T2.STATUS = 'A';
                ELSE
                        SELECT distinct T1.PERSON_ID
                        FROM GRANT_CALL_FUNDING_SCHEME_MANAGERS T1
                        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                        WHERE T1.FUNDING_SCHEME_CODE IN (
                                SELECT FUNDING_SCHEME_CODE
                                FROM SPONSOR_FUNDING_SCHEME
                                WHERE FUNDING_SCHEME_ID = LI_FUNDING_SCHEME_ID
                        )
                        AND T2.STATUS = 'A';
                END IF;
                
        ELSEIF AV_MODULE_CODE in (14, 16) THEN

                SELECT T1.FUNDING_SCHEME_ID INTO LI_FUNDING_SCHEME_ID
                FROM GRANT_CALL_HEADER T1
                INNER JOIN AWARD T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                WHERE T2.AWARD_ID = LS_AWARD_ID;
                SELECT COUNT(1) INTO LI_PERSON_COUNT
                FROM GRANT_CALL_FUNDING_SCHEME_MANAGERS T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.FUNDING_SCHEME_CODE IN (
                        SELECT FUNDING_SCHEME_CODE
                        FROM SPONSOR_FUNDING_SCHEME
                        WHERE FUNDING_SCHEME_ID = LI_FUNDING_SCHEME_ID
                )
                AND T2.STATUS = 'A';
                IF LI_PERSON_COUNT = 0 THEN
                        SELECT COUNT(1) INTO LI_FLAG
                        FROM AWARD T1
                        INNER JOIN GRANT_CALL_HEADER T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                        WHERE T1.AWARD_ID = LS_AWARD_ID
                        AND T1.GRANT_HEADER_ID IS NOT NULL
                        AND T2.HOME_UNIT_NUMBER <> (SELECT VALUE FROM PARAMETER WHERE PARAMETER_NAME = 'ROOT_UNIT');
                        IF LI_FLAG > 0 THEN
                                SELECT T2.HOME_UNIT_NUMBER INTO LS_LEAD_UNIT
                                FROM AWARD T1
                                INNER JOIN GRANT_CALL_HEADER T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                                WHERE T1.AWARD_ID = LS_AWARD_ID;
                        ELSE
                                SELECT T1.LEAD_UNIT_NUMBER INTO LS_LEAD_UNIT
                                FROM AWARD T1
                                WHERE T1.AWARD_ID = LS_AWARD_ID;
                        END IF;
                        SELECT DISTINCT T1.PERSON_ID
                        FROM PERSON_ROLES T1
                        LEFT JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                        WHERE T1.ROLE_ID = 100
                        AND T1.UNIT_NUMBER = LS_LEAD_UNIT
                        AND T2.STATUS = 'A';
                ELSE
                        SELECT distinct T1.PERSON_ID
                        FROM GRANT_CALL_FUNDING_SCHEME_MANAGERS T1
                        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                        WHERE T1.FUNDING_SCHEME_CODE IN (
                                SELECT FUNDING_SCHEME_CODE
                                FROM SPONSOR_FUNDING_SCHEME
                                WHERE FUNDING_SCHEME_ID = LI_FUNDING_SCHEME_ID
                        )
                        AND T2.STATUS = 'A';
                END IF;
        END IF;

ELSEIF AV_ROLE_TYPE = 14 THEN
        SELECT DISTINCT T1.PERSON_ID
        FROM PERSON_ROLES T1
        LEFT JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        WHERE ROLE_ID = 120
        AND T1.UNIT_NUMBER = LS_LEAD_UNIT
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 15 THEN
        SELECT DISTINCT T1.PERSON_ID
        FROM PERSON_ROLES T1
        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        WHERE T1.ROLE_ID = 28
        AND T1.UNIT_NUMBER = LS_LEAD_UNIT
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 16 THEN 

        IF AV_MODULE_CODE = 3 THEN
                SELECT T1.FUNDING_SCHEME_ID INTO LI_FUNDING_SCHEME_ID
                FROM GRANT_CALL_HEADER T1
                INNER JOIN EPS_PROPOSAL T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                WHERE T2.PROPOSAL_ID = AV_MODULE_ITEM_ID;
        ELSEIF AV_MODULE_CODE = 1 THEN
                SELECT T1.FUNDING_SCHEME_ID INTO LI_FUNDING_SCHEME_ID
                FROM GRANT_CALL_HEADER T1
                INNER JOIN AWARD T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                WHERE T2.AWARD_ID = AV_MODULE_ITEM_ID;
        END IF;

        SELECT COUNT(1) INTO LI_PERSON_COUNT
        FROM GRANT_CALL_FUNDING_SCHEME_MANAGERS T1
        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        AND T2.HOME_UNIT = '252'
        AND T2.STATUS = 'A'
        WHERE T1.FUNDING_SCHEME_CODE IN (
                SELECT FUNDING_SCHEME_CODE
                FROM SPONSOR_FUNDING_SCHEME
                WHERE FUNDING_SCHEME_ID = LI_FUNDING_SCHEME_ID
                )
        AND T2.STATUS = 'A';

        IF LI_PERSON_COUNT = 0 THEN
                SELECT distinct T1.PERSON_ID
                FROM PERSON_ROLES T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE ROLE_ID = 100
                AND T1.UNIT_NUMBER = '252'
                AND T2.STATUS = 'A';
        ELSE
                SELECT distinct T1.PERSON_ID
                FROM GRANT_CALL_FUNDING_SCHEME_MANAGERS T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.FUNDING_SCHEME_CODE IN (
                        SELECT FUNDING_SCHEME_CODE
                        FROM SPONSOR_FUNDING_SCHEME
                        WHERE FUNDING_SCHEME_ID = LI_FUNDING_SCHEME_ID
                )
                AND T2.STATUS = 'A'
                AND T2.HOME_UNIT = '252';
        END IF;

ELSEIF AV_ROLE_TYPE = 17 THEN
        SELECT DISTINCT T1.PERSON_ID
        FROM PERSON_ROLES T1
        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        WHERE ROLE_ID = 400
        AND T1.UNIT_NUMBER = '252'
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 18 THEN
        SELECT DISTINCT T1.PERSON_ID
        FROM PERSON_ROLES T1
        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        WHERE ROLE_ID = 100
        AND T1.UNIT_NUMBER = '654'
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 19 THEN
        SELECT DISTINCT T1.PERSON_ID
        FROM PERSON_ROLES T1
        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        WHERE ROLE_ID = 400
        AND T1.UNIT_NUMBER = '654'
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 21 THEN 
			IF AV_MODULE_CODE = 3 THEN
					SELECT PERSON_ID 
					FROM EPS_PROPOSAL_PERSON_ROLES 
					WHERE ROLE_ID = 5
					AND PROPOSAL_ID = AV_MODULE_ITEM_ID;
		    END IF;

ELSEIF AV_ROLE_TYPE = 22 THEN
        SELECT DISTINCT T1.PERSON_ID
        FROM PERSON_ROLES T1
        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        WHERE T1.ROLE_ID = 670
        AND T1.UNIT_NUMBER = LS_LEAD_UNIT
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 23 THEN -- Action Owner  -  Persons who is taking the action (Approve/Bypass) in any stop in the Route Log
        IF AV_MODULE_CODE = 20 THEN -- if module is service request we change the module to award for taking the route log persons
                SET AV_MODULE_CODE = 1;
                SELECT ORIGINATING_MODULE_ITEM_KEY INTO AV_MODULE_ITEM_ID
                FROM SR_HEADER
                WHERE SR_HEADER_ID = AV_MODULE_ITEM_ID;
        END IF;
        SELECT DISTINCT T3.PERSON_ID AS PERSON_ID
        FROM WORKFLOW T1
        INNER JOIN WORKFLOW_DETAIL T2 ON T1.WORKFLOW_ID = T2.WORKFLOW_ID
        INNER JOIN PERSON T3 ON T3.USER_NAME = T2.UPDATE_USER
        WHERE T1.MODULE_CODE = AV_MODULE_CODE
        AND T1.MODULE_ITEM_ID = AV_MODULE_ITEM_ID
        AND T1.SUB_MODULE_CODE = AV_SUBMODULE_CODE
        AND T1.SUB_MODULE_ITEM_ID = AV_SUB_MODULE_ITEM_KEY
        AND T1.MAP_TYPE = 'R'
        AND T1.IS_WORKFLOW_ACTIVE = 'Y'
        AND T2.APPROVAL_STATUS IN ('A', 'B')
        AND T3.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 24 THEN -- Approvers in Waiting - Approvers who are waiting in the Route log.

        IF AV_MODULE_CODE = 20 THEN -- if module is service request we change the module to award for taking the route log persons
                SET AV_MODULE_CODE = 1;
                SELECT ORIGINATING_MODULE_ITEM_KEY INTO AV_MODULE_ITEM_ID
                FROM SR_HEADER
                WHERE SR_HEADER_ID = AV_MODULE_ITEM_ID;
        END IF;
        SELECT DISTINCT T2.APPROVER_PERSON_ID AS PERSON_ID
        FROM WORKFLOW T1
        INNER JOIN WORKFLOW_DETAIL T2 ON T1.WORKFLOW_ID = T2.WORKFLOW_ID
        INNER JOIN PERSON T3 ON T3.PERSON_ID = T2.APPROVER_PERSON_ID
        WHERE T1.MODULE_CODE = AV_MODULE_CODE
        AND T1.MODULE_ITEM_ID = AV_MODULE_ITEM_ID
        AND T1.SUB_MODULE_CODE = AV_SUBMODULE_CODE
        AND T1.SUB_MODULE_ITEM_ID = AV_SUB_MODULE_ITEM_KEY
        AND T1.MAP_TYPE = 'R'
        AND T1.IS_WORKFLOW_ACTIVE = 'Y'
        AND T2.APPROVAL_STATUS IN ('W')
        AND T3.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 25 THEN -- All Approvers - All Approvers in the Route log (including approvers, alternate).

        SELECT DISTINCT T2.APPROVER_PERSON_ID AS PERSON_ID FROM WORKFLOW T1
		INNER JOIN WORKFLOW_DETAIL T2 ON T1.WORKFLOW_ID = T2.WORKFLOW_ID
		INNER JOIN PERSON T3 ON T3.PERSON_ID = T2.APPROVER_PERSON_ID
		WHERE T1.MODULE_CODE = AV_MODULE_CODE
		AND T1.MODULE_ITEM_ID = AV_MODULE_ITEM_ID
		AND T1.SUB_MODULE_CODE = AV_SUBMODULE_CODE
		AND T1.SUB_MODULE_ITEM_ID = AV_SUB_MODULE_ITEM_KEY
		AND T1.MAP_TYPE = 'R'
		AND T1.IS_WORKFLOW_ACTIVE = 'Y'
		AND T3.STATUS = 'A';

ELSEIF AV_ROLE_TYPE IN (28) THEN -- NSS-HR_RMSO

        IF AV_MODULE_CODE = 1 THEN
                SELECT COUNT(1) INTO LI_FLAG
                FROM UNIT
                WHERE UNIT_NUMBER = LS_LEAD_UNIT
                AND UNIT_NUMBER NOT IN (
                        SELECT UNIT_NUMBER
                        FROM UNIT
                        WHERE UNIT_NUMBER IN ('495', '259', '396')
                        OR PARENT_UNIT_NUMBER IN ('495', '259', '396')
                );
                IF LI_FLAG > 0 THEN
                        SELECT "nss-hr_rmso@ntu.edu.sg" AS RECIPIENT_ADDRESS;
                ELSE
                SELECT COUNT(1) INTO LI_FLAG
                FROM UNIT
                WHERE UNIT_NUMBER = LS_LEAD_UNIT
                AND UNIT_NUMBER IN (
                        SELECT UNIT_NUMBER
                        FROM UNIT
                        WHERE UNIT_NUMBER = '495'
                                OR PARENT_UNIT_NUMBER = '495'
                );
                IF LI_FLAG > 0 THEN
                        SELECT "hrcomm-lkcsom@ntu.edu.sg" AS RECIPIENT_ADDRESS;
                ELSE
                        SELECT COUNT(1) INTO LI_FLAG
                        FROM UNIT
                        WHERE UNIT_NUMBER = LS_LEAD_UNIT
                        AND UNIT_NUMBER IN (
                                SELECT UNIT_NUMBER
                                FROM UNIT
                                WHERE UNIT_NUMBER = '259'
                                OR PARENT_UNIT_NUMBER = '259'
                        );
                        IF LI_FLAG > 0 THEN
                                SELECT "rsishr@ntu.edu.sg" AS RECIPIENT_ADDRESS;
                        ELSE
                                SELECT COUNT(1) INTO LI_FLAG
                                FROM UNIT
                                WHERE UNIT_NUMBER = LS_LEAD_UNIT
                                AND UNIT_NUMBER IN (
                                        SELECT UNIT_NUMBER
                                        FROM UNIT
                                        WHERE UNIT_NUMBER = '396'
                                        OR PARENT_UNIT_NUMBER = '396'
                        );
                IF LI_FLAG > 0 THEN
                        SELECT "hrdres@nie.edu.sg" AS RECIPIENT_ADDRESS;
                END IF;
                END IF;
                END IF;
        END IF;
        END IF;

ELSEIF AV_ROLE_TYPE = 29 THEN -- Staffing Partner

        IF AV_MODULE_CODE = 1 THEN
                SELECT COUNT(1) INTO LI_FLAG
                FROM UNIT
                WHERE UNIT_NUMBER = LS_LEAD_UNIT
                AND UNIT_NUMBER NOT IN (
                        SELECT UNIT_NUMBER
                        FROM UNIT
                        WHERE UNIT_NUMBER in ('495', '259', '396')
                                OR PARENT_UNIT_NUMBER IN ('495', '259', '396')
                );
                IF LI_FLAG > 0 THEN
                        SELECT "staffing_org_support@ntu.edu.sg" AS RECIPIENT_ADDRESS;
                ELSE
                        SELECT COUNT(1) INTO LI_FLAG
                        FROM UNIT
                        WHERE UNIT_NUMBER = LS_LEAD_UNIT
                        AND UNIT_NUMBER IN (
                                SELECT UNIT_NUMBER
                                FROM UNIT
                                WHERE UNIT_NUMBER = '495'
                                OR PARENT_UNIT_NUMBER = '495'
                        );
                        IF LI_FLAG > 0 THEN
                                SELECT "hrcomm-lkcsom@ntu.edu.sg" AS RECIPIENT_ADDRESS;
                        ELSE
                                SELECT COUNT(1) INTO LI_FLAG
                                FROM UNIT
                                WHERE UNIT_NUMBER = LS_LEAD_UNIT
                                AND UNIT_NUMBER IN (
                                        SELECT UNIT_NUMBER
                                        FROM UNIT
                                        WHERE UNIT_NUMBER = '259'
                                        OR PARENT_UNIT_NUMBER = '259'
                                );
                                IF LI_FLAG > 0 THEN
                                        SELECT "rsishr@ntu.edu.sg" AS RECIPIENT_ADDRESS;
                                ELSE
                                        SELECT COUNT(1) INTO LI_FLAG
                                        FROM UNIT
                                        WHERE UNIT_NUMBER = LS_LEAD_UNIT
                                        AND UNIT_NUMBER IN (
                                                SELECT UNIT_NUMBER
                                                FROM UNIT
                                                WHERE UNIT_NUMBER = '396'
                                                OR PARENT_UNIT_NUMBER = '396'
                                        );
                        IF LI_FLAG > 0 THEN
                        SELECT "hrdres@nie.edu.sg" AS RECIPIENT_ADDRESS;
                        END IF;
                END IF;
        END IF;
        END IF;
        ELSE
                SELECT DISTINCT T1.PERSON_ID
                FROM PERSON_ROLES T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.ROLE_ID = 680
                AND T2.STATUS = 'A';
        END IF;

ELSEIF AV_ROLE_TYPE = 30 THEN -- CITS Administrator
        SELECT DISTINCT T1.PERSON_ID
        FROM PERSON_ROLES T1
        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        WHERE T1.ROLE_ID = 663
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 31 THEN -- CLAIM REVIEWER
        IF AV_MODULE_CODE in (14) THEN
        SELECT LEAD_UNIT_NUMBER,AWARD_ID INTO LS_LEAD_UNIT,LS_AWARD_ID
        FROM AWARD
        WHERE AWARD_ID IN(
                SELECT AWARD_ID
                FROM CLAIM
                WHERE CLAIM_ID = AV_MODULE_ITEM_ID
        );
        SELECT COUNT(1) INTO LI_FLAG
        FROM UNIT
        WHERE UNIT_NUMBER = LS_LEAD_UNIT
        AND UNIT_NUMBER NOT IN (
                SELECT UNIT_NUMBER
                FROM UNIT
                WHERE UNIT_NUMBER in ('495', '259', '396')
                OR PARENT_UNIT_NUMBER IN ('495', '259', '396')
        );
        IF LI_FLAG > 0 THEN
                SELECT distinct T1.PERSON_ID
                FROM PERSON_ROLES T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.ROLE_ID = '682'
                AND T1.UNIT_NUMBER = (SELECT VALUE FROM PARAMETER WHERE PARAMETER_NAME = 'ROOT_UNIT')
                AND T2.STATUS = 'A';
        ELSE
                SELECT COUNT(1) INTO LI_FLAG
                FROM UNIT
                WHERE UNIT_NUMBER = LS_LEAD_UNIT
                AND UNIT_NUMBER IN (
                        SELECT UNIT_NUMBER
                        FROM UNIT
                        WHERE UNIT_NUMBER = '495'
                        OR PARENT_UNIT_NUMBER = '495'
                );
                IF LI_FLAG > 0 THEN
                        SELECT distinct T1.PERSON_ID
                        FROM PERSON_ROLES T1
                        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                        WHERE T1.ROLE_ID = '682'
                        AND T1.UNIT_NUMBER = '495'
                        AND T2.STATUS = 'A';
                ELSE
                        SELECT COUNT(1) INTO LI_FLAG
                        FROM UNIT
                        WHERE UNIT_NUMBER = LS_LEAD_UNIT
                        AND UNIT_NUMBER IN (
                                SELECT UNIT_NUMBER
                                FROM UNIT
                                WHERE UNIT_NUMBER = '259'
                                OR PARENT_UNIT_NUMBER = '259'
                        );
                IF LI_FLAG > 0 THEN
                        SELECT distinct T1.PERSON_ID
                        FROM PERSON_ROLES T1
                        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                        WHERE T1.ROLE_ID = '682'
                        AND T1.UNIT_NUMBER = '259'
                        AND T2.STATUS = 'A';
                ELSE
                        SELECT COUNT(1) INTO LI_FLAG
                        FROM UNIT
                        WHERE UNIT_NUMBER = LS_LEAD_UNIT
                        AND UNIT_NUMBER IN (
                                SELECT UNIT_NUMBER
                                FROM UNIT
                                WHERE UNIT_NUMBER = '396'
                                OR PARENT_UNIT_NUMBER = '396'
                        );
                        IF LI_FLAG > 0 THEN
                                SELECT distinct T1.PERSON_ID
                                FROM PERSON_ROLES T1
                                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                                WHERE T1.ROLE_ID = '682'
                                AND T1.UNIT_NUMBER = '396'
                                AND T2.STATUS = 'A';
                        END IF;
                END IF;
        END IF;
        END IF;
        ELSE
                SELECT distinct T1.PERSON_ID
                FROM PERSON_ROLES T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.ROLE_ID = '682'
                AND T1.UNIT_NUMBER = LS_LEAD_UNIT
                AND T2.STATUS = 'A';
        END IF;

ELSEIF AV_ROLE_TYPE = 32 THEN -- RSO ADMIN
        SELECT DISTINCT T1.PERSON_ID
        FROM PERSON_ROLES T1
        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        WHERE T1.ROLE_ID = 619
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 33 THEN -- Claim Preparer
        IF AV_MODULE_CODE = 14 THEN
                SELECT t1.PERSON_ID
                FROM PERSON t1
                WHERE t1.USER_NAME IN (
                        SELECT CREATE_USER
                        FROM CLAIM
                        WHERE CLAIM_ID = AV_MODULE_ITEM_ID
                );
        END IF;
        IF AV_MODULE_CODE = 1 THEN
                SELECT CAST(T1.CLAIM_PREPARER as char(100)) AS PERSON_ID
                FROM CUSTOM_DATA_V T1
                WHERE T1.MODULE_ITEM_KEY = AV_MODULE_ITEM_ID;
        END IF;

ELSEIF AV_ROLE_TYPE = 34 THEN -- Unit GS
        SELECT DISTINCT T1.PERSON_ID
        FROM PERSON_ROLES T1
        INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
        WHERE T1.ROLE_ID = 671
        AND T1.UNIT_NUMBER = LS_LEAD_UNIT
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = 35 THEN -- Agreement Administrator
        IF AV_MODULE_CODE = 13 THEN
                SELECT ADMIN_PERSON_ID INTO LS_ADMIN_PERSON_ID
                FROM AGREEMENT_HEADER
                WHERE AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID;
                IF LS_ADMIN_PERSON_ID IS NULL THEN
                       SELECT PR.PERSON_ID AS PERSON_ID
        FROM
        PERSON_ROLES PR,
        (SELECT ROLE_ID,RT.RIGHT_NAME 
           FROM ROLE_RIGHTS RR,
                RIGHTS RT
            WHERE RR.RIGHT_ID = RT.RIGHT_ID
        ) RLE,
        PERSON P
        WHERE (( PR. DESCEND_FLAG = 'Y' AND LS_LEAD_UNIT IN (SELECT CHILD_UNIT_NUMBER
                                                                 FROM UNIT_WITH_CHILDREN 
                                                                                  WHERE UNIT_NUMBER = PR.UNIT_NUMBER
             ))OR ( PR. DESCEND_FLAG = 'N' AND PR.UNIT_NUMBER = LS_LEAD_UNIT )
            )
         AND PR.PERSON_ID=P.PERSON_ID AND P.STATUS='A' AND RLE.ROLE_ID =1300  AND RLE.ROLE_ID = PR.ROLE_ID;
                ELSE
                        SELECT T1.ADMIN_PERSON_ID AS PERSON_ID
                        FROM AGREEMENT_HEADER T1
                        INNER JOIN PERSON T2 ON T1.ADMIN_PERSON_ID = T2.PERSON_ID
                        WHERE AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID
                        AND T2.STATUS = 'A';
                END IF;
        END IF;

ELSEIF AV_ROLE_TYPE = 36 THEN -- Agreement Person
        IF AV_MODULE_CODE = 13 THEN
                SELECT DISTINCT T1.PERSON_ID
                FROM AGREEMENT_PEOPLE T1
                INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                WHERE T1.AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID
                AND T2.STATUS = 'A';
        END IF;

ELSEIF AV_ROLE_TYPE = 37 THEN
        SELECT "liji.saji@polussoftware.com" AS RECIPIENT_ADDRESS
        WHERE T1.ROLE_ID = 671
        AND T1.UNIT_NUMBER = LS_LEAD_UNIT
        AND T2.STATUS = 'A';

ELSEIF AV_ROLE_TYPE = (38) THEN
        SELECT "nssfar@ntu.edu.sg" AS RECIPIENT_ADDRESS;

ELSEIF AV_ROLE_TYPE = 39 THEN 

        IF AV_MODULE_CODE = 3 THEN
                SELECT GRANT_TYPE_CODE INTO LI_GRANT_TYPE
                FROM EPS_PROPOSAL
                WHERE PROPOSAL_ID = AV_MODULE_ITEM_ID;
                IF LI_GRANT_TYPE = 1 THEN -- INTERNAL
                        SELECT DISTINCT T1.PERSON_ID
                        FROM PERSON_ROLES T1
                        WHERE T1.ROLE_ID = 43;
                ELSEIF LI_GRANT_TYPE = 2 THEN -- EXTERNAL
                        SELECT DISTINCT T1.PERSON_ID
                        FROM PERSON_ROLES T1
                        WHERE ROLE_ID = 42;
                END IF;
        END IF;
ELSEIF AV_ROLE_TYPE = 40  THEN

        IF AV_MODULE_CODE = 13 THEN
                SELECT T1.SUBMIT_USER_ID AS PERSON_ID
                FROM AGREEMENT_HEADER T1
		INNER JOIN PERSON T2 ON T1.SUBMIT_USER_ID = T2.PERSON_ID 
                WHERE T1.AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID
		AND T2.STATUS = 'A';
        END IF;	

ELSEIF AV_ROLE_TYPE = 46 THEN

	IF AV_MODULE_CODE = 1 THEN
		SELECT T1.PERSON_ID
		FROM PERSON T1 WHERE T1.USER_NAME = (SELECT CREATE_USER 
		FROM AWARD
		WHERE AWARD_ID = AV_MODULE_ITEM_ID)
		   AND T1.STATUS = 'A';
	
		ELSEIF AV_MODULE_CODE = 3 THEN
                        SELECT T2.PERSON_ID
						FROM PERSON T2 WHERE T2.USER_NAME = (SELECT CREATE_USER 
						FROM eps_proposal
						WHERE PROPOSAL_ID = AV_MODULE_ITEM_ID) AND T2.STATUS = 'A';

        ELSEIF AV_MODULE_CODE = 20 THEN
                        SELECT T2.PERSON_ID
						FROM PERSON T2 WHERE T2.USER_NAME = (SELECT CREATE_USER 
						FROM SR_HEADER
						WHERE SR_HEADER_ID = AV_MODULE_ITEM_ID) AND T2.STATUS = 'A';
                        ELSEIF AV_MODULE_CODE = 13 THEN 
                SELECT T1.REQUESTOR_PERSON_ID AS PERSON_ID
                                        FROM AGREEMENT_HEADER T1
                                        INNER JOIN PERSON T2 ON T1.REQUESTOR_PERSON_ID = T2.PERSON_ID 
                                        WHERE T1.AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID AND T2.STATUS = 'A';
    END IF;

ELSEIF AV_ROLE_TYPE = 47 THEN

	IF AV_MODULE_CODE = 1 THEN

		SELECT T1.WORKFLOW_START_PERSON
		FROM WORKFLOW T1,
		PERSON P
		WHERE T1.MODULE_CODE = 1 
		AND T1.MODULE_ITEM_ID = AV_MODULE_ITEM_ID
		AND T1.IS_WORKFLOW_ACTIVE = 'Y'
		AND T1.WORKFLOW_SEQUENCE = (SELECT MAX(T2.WORKFLOW_SEQUENCE)
		FROM  WORKFLOW T2
		WHERE T2.MODULE_CODE = 1 
		AND T2.MODULE_ITEM_ID =T1.MODULE_ITEM_ID
		AND T2.IS_WORKFLOW_ACTIVE = 'Y'
		)
		AND P.PERSON_ID = T1.WORKFLOW_START_PERSON
		AND P.STATUS = 'A';

        ELSEIF AV_MODULE_CODE = 20 THEN

		SELECT MODULE_CODE,MODULE_ITEM_KEY INTO LI_MODULE_CODE,LS_MODULE_ITEM_KEY
		FROM SR_HEADER T1
		WHERE T1.SR_HEADER_ID = AV_MODULE_ITEM_ID;
        
        IF LI_MODULE_CODE = 1 THEN
        
				SELECT T1.WORKFLOW_START_PERSON AS PERSON_ID
				FROM WORKFLOW T1, PERSON P
				WHERE T1.MODULE_CODE = LI_MODULE_CODE
				AND T1.MODULE_ITEM_ID = LS_MODULE_ITEM_KEY
				AND T1.IS_WORKFLOW_ACTIVE = 'Y'
				AND T1.WORKFLOW_SEQUENCE = (SELECT MAX(T2.WORKFLOW_SEQUENCE)
											FROM  WORKFLOW T2
											WHERE T2.MODULE_CODE = LI_MODULE_CODE 
											AND T2.MODULE_ITEM_ID =T1.MODULE_ITEM_ID
											AND T2.IS_WORKFLOW_ACTIVE = 'Y'
											)
				AND P.PERSON_ID = T1.WORKFLOW_START_PERSON
				AND P.STATUS = 'A';
        
        END IF;
                
        END IF;
ELSEIF AV_ROLE_TYPE = 48 THEN -- External Review Administrators

		IF AV_MODULE_CODE = 22 THEN
                        SELECT GROUP_CONCAT(EMAIL_ADDRESS_PRIMARY) AS RECIPIENT_ADDRESS FROM EXTERNAL_REVIEWER T1 
			INNER JOIN  EXTERNAL_REVIEWER_RIGHTS T2 ON T2.EXTERNAL_REVIEWER_ID = T1.EXTERNAL_REVIEWER_ID 
                        WHERE REVIEWER_RIGHTS_ID = 3;
                END IF;
ELSEIF AV_ROLE_TYPE = 50 THEN  -- Service Request Watcher
	IF AV_MODULE_CODE = 20 THEN
SELECT 
    spr.PERSON_ID
FROM 
    SR_PERSON_ROLES spr
INNER JOIN 
    role_rights rr ON rr.role_id = spr.role_id 
INNER JOIN 
    rights r ON r.RIGHT_ID = rr.RIGHT_ID AND r.RIGHT_NAME = 'SERVICE_REQUEST_WATCHER'
WHERE spr.SR_HEADER_ID = AV_MODULE_ITEM_ID
AND EXISTS (SELECT 1 FROM PERSON T2 WHERE T2.PERSON_ID = spr.PERSON_ID AND T2.STATUS = 'A');
	END IF;
ELSEIF AV_ROLE_TYPE = 52 THEN  
	IF AV_MODULE_CODE = 20 THEN
		SELECT T1.PERSON_ID
		FROM PERSON_ROLES T1
		LEFT JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
		WHERE ROLE_ID = 1339 AND T2.STATUS = 'A';
	 END IF;
ELSEIF AV_ROLE_TYPE = 55 THEN
    IF AV_MODULE_CODE = 3 THEN

              SELECT COUNT(1) INTO LI_COUNT
          FROM EPS_PROPOSAL EPS
          WHERE EPS.PROPOSAL_ID = AV_MODULE_ITEM_ID
            AND EXISTS (
                SELECT 1
                FROM SPONSOR S
                INNER JOIN SPONSOR_TYPE ST
                ON ST.SPONSOR_TYPE_CODE = S.SPONSOR_TYPE_CODE
                WHERE ST.DESCRIPTION = 'Foundation'
                  AND S.SPONSOR_CODE = EPS.SPONSOR_CODE
            );

               IF LI_COUNT > 0 THEN 

                    SELECT DISTINCT T1.PERSON_ID
                    FROM PERSON_ROLES T1
                    INNER JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                    WHERE T1.ROLE_ID = 1450
                      AND T1.UNIT_NUMBER = '410075'
                      AND T2.STATUS = 'A';
               ELSE
                      SELECT P.PERSON_ID 
                      FROM EPS_PROPOSAL_PERSON_ROLES EPR  
                      INNER JOIN ROLE R ON R.ROLE_ID = EPR.ROLE_ID 
		      INNER JOIN PERSON P ON EPR.PERSON_ID = P.PERSON_ID
                      WHERE EPR.PROPOSAL_ID = AV_MODULE_ITEM_ID
                        AND R.ROLE_ID = 5 
			AND P.STATUS = 'A'
                      UNION ALL 
                      SELECT '4845' AS PERSON_ID 
                      UNION ALL 
                      SELECT '2457' AS PERSON_ID;
              END IF;
    END IF;
ELSEIF AV_ROLE_TYPE = 53 THEN
              IF AV_MODULE_CODE = 13 THEN 
                SELECT DISTINCT T1.PERSON_ID
                        FROM AGREEMENT_HEADER T2
                        INNER JOIN ADMIN_GROUP T3 ON T2.ADMIN_GROUP_ID = T3.ADMIN_GROUP_ID
                        INNER JOIN PERSON_ROLES T1 ON T3.ROLE_ID = T1.ROLE_ID
                        INNER JOIN PERSON T4 ON T1.PERSON_ID = T4.PERSON_ID
                        WHERE T2.AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID
                        AND T3.IS_ACTIVE = 'Y'
                        AND T4.STATUS = 'A' 
                UNION SELECT DISTINCT T3.PERSON_ID
                        FROM AGREEMENT_HEADER T2
                        INNER JOIN ADMIN_GROUP T3 ON T2.ADMIN_GROUP_ID = T3.ADMIN_GROUP_ID
                        INNER JOIN PERSON T4 ON T3.PERSON_ID = T4.PERSON_ID
                        WHERE T2.AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID
                        AND T3.IS_ACTIVE = 'Y'
                        AND T4.STATUS = 'A';
        END IF;
ELSEIF AV_ROLE_TYPE = 54 THEN  
                IF AV_MODULE_CODE = 13 THEN
                /* Use the Agreement Aggregator role ID based on the instance */
                        SELECT T1.PERSON_ID 
                                        FROM AGREEMENT_PEOPLE_ROLES T1
                                        LEFT JOIN PERSON T2 ON T1.PERSON_ID = T2.PERSON_ID
                                        WHERE T1.AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_ID AND T1.ROLE_ID = 1337 AND T2.STATUS = 'A';                                             
                END IF;
END IF;

END
