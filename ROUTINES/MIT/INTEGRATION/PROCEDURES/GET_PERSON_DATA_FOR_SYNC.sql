CREATE OR REPLACE PROCEDURE GET_PERSON_DATA_FOR_SYNC (
    AV_START_TIMESTAMP IN TIMESTAMP,
    AV_END_TIMESTAMP   IN TIMESTAMP,
    AV_OFFSET          IN NUMBER,
    AV_LIMIT           IN NUMBER,
    AV_RESULT_SET      OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN AV_RESULT_SET FOR
        SELECT 
            PERSON_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_NAME,
            FULL_NAME,
            PRIOR_NAME,
            USER_NAME,
            PASSWORD,
            EMAIL_ADDRESS,
            DATE_OF_BIRTH,
            AGE,
            AGE_BY_FISCAL_YEAR,
            GENDER,
            EDUCATION_LEVEL,
            OFFICE_LOCATION,
            OFFICE_PHONE,
            SECONDRY_OFFICE_LOCATION,
            SECONDRY_OFFICE_PHONE,
            SCHOOL,
            DIRECTORY_DEPARTMENT,
            SALUTATION,
            NULL AS COUNTRY_OF_CITIZENSHIP,
            PRIMARY_TITLE,
            DIRECTORY_TITLE,
            HOME_UNIT,
            IS_FACULTY,
            IS_GRADUATE_STUDENT_STAFF,
            IS_RESEARCH_STAFF,
            IS_SERVICE_STAFF,
            IS_SUPPORT_STAFF,
            IS_OTHER_ACCADEMIC_GROUP,
            IS_MEDICAL_STAFF,
            ADDRESS_LINE_1,
            ADDRESS_LINE_2,
            ADDRESS_LINE_3,
            CITY,
            COUNTY,
            STATE,
            POSTAL_CODE,
            COUNTRY_CODE,
            FAX_NUMBER,
            PAGER_NUMBER,
            MOBILE_PHONE_NUMBER,
            SUPERVISOR_PERSON_ID,
            ORCID_ID,
            ACCESS_TOKEN,
            CASE
                WHEN STATUS IS NULL OR TRIM(STATUS) = '' THEN 'I'
                WHEN STATUS = 'Y' THEN 'A'
                WHEN STATUS = 'N' THEN 'I'
                ELSE STATUS
            END AS STATUS,
            SALARY_ANNIVERSARY_DATE,
            UPDATE_TIMESTAMP,
            UPDATE_USER,
            JOB_CODE
        FROM PERSON
        WHERE UPDATE_TIMESTAMP BETWEEN AV_START_TIMESTAMP AND AV_END_TIMESTAMP
        ORDER BY PERSON_ID ASC
        OFFSET AV_OFFSET ROWS
        FETCH NEXT AV_LIMIT ROWS ONLY;
END;
