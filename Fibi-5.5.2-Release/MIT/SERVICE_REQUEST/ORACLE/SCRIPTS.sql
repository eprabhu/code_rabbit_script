DECLARE
    table_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'MIT_INT_STAGE_SR';
    
    IF table_exists = 0 THEN
        EXECUTE IMMEDIATE '
            CREATE TABLE "MIT_INT_STAGE_SR" 
            ("MODULE_CODE" NUMBER, 
            "MODULE_ITEM_KEY" NUMBER, 
            "PI_NAME" VARCHAR2(90 BYTE), 
            "LEAD_UNIT_NUMBER" VARCHAR2(8 BYTE), 
            "LEAD_UNIT_NAME" VARCHAR2(200 BYTE), 
            "SUBJECT" VARCHAR2(1000 BYTE), 
            "STATUS_CODE" NUMBER(3,0), 
            "STATUS" VARCHAR2(200 BYTE), 
            "REPORTER_NAME" VARCHAR2(90 BYTE), 
            "PRIORITY_ID" NUMBER, 
            "PRIORITY" VARCHAR2(200 BYTE), 
            "CATEGORY_CODE" NUMBER(3,0), 
            "CATEGORY" VARCHAR2(500 BYTE), 
            "TYPE_CODE" NUMBER(3,0), 
            "TYPE" VARCHAR2(500 BYTE), 
            "FIRST_FED_TIMESTAMP" DATE, 
            "LAST_FED_TIMESTAMP" DATE, 
            "UPDATE_BY" VARCHAR2(90 BYTE), 
            "UPDATE_TIMESTAMP" DATE, 
            "DESCRIPTION" CLOB, 
            "AA_PERSON_FULL_NAME" VARCHAR2(90 BYTE), 
            CONSTRAINT "PK_MIT_INT_STAGE_SR" PRIMARY KEY ("MODULE_ITEM_KEY")
            )';
    END IF;
END;
/

DECLARE
    table_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO table_exists
    FROM user_tables
    WHERE table_name = 'SR_CONNECT_CONFIG';
    IF table_exists = 0 THEN
        EXECUTE IMMEDIATE '
            CREATE TABLE SR_CONNECT_CONFIG 
            (SR_CONFIG_ID NUMBER(10,0), 
            SUBJECT VARCHAR2(1000), 
            PRIORITY_ID NUMBER(10,0), 
            CATEGORY_CODE VARCHAR2(3), 
            TYPE_CODE VARCHAR2(3),
            DESCRIPTION CLOB, 
            CREATE_USER VARCHAR2(60), 
            CREATE_TIMESTAMP DATE DEFAULT SYSDATE, 
            UPDATE_BY VARCHAR2(40), 
            UPDATE_TIMESTAMP DATE, 
            ASSOC_CONFIG_CODE VARCHAR2(3), 
            RELATION_TYPE_CODE VARCHAR2(3), 
            FETCH_LIMIT_FOR_SYNC NUMBER DEFAULT 100 NOT NULL, 
            STATUS_CODE VARCHAR2(10), 
            PRIMARY KEY (SR_CONFIG_ID)
            )';
    END IF;
END;
/

MERGE INTO SR_CONNECT_CONFIG T
USING (SELECT 1 AS SR_CONFIG_ID FROM DUAL) S
ON (T.SR_CONFIG_ID = S.SR_CONFIG_ID)
WHEN NOT MATCHED THEN
  INSERT (
    SR_CONFIG_ID, SUBJECT, PRIORITY_ID, CATEGORY_CODE, TYPE_CODE, DESCRIPTION,
    CREATE_USER, CREATE_TIMESTAMP, UPDATE_BY, UPDATE_TIMESTAMP,
    ASSOC_CONFIG_CODE, RELATION_TYPE_CODE, FETCH_LIMIT_FOR_SYNC, STATUS_CODE
  )
  VALUES (
    1, 'New Award Received', 1, '13', '1',
    'New Award Received. This ticket is generated from Fibi-Agreement : ',
    'admin', SYSDATE, 'admin', SYSDATE,
    '4', '4', 10000, '1'
  );
