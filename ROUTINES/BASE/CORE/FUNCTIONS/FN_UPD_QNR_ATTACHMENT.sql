CREATE FUNCTION FN_UPD_QNR_ATTACHMENT(
    AV_QUESTIONNAIRE_ANSWER_ATT_ID INT,
    AV_QUESTIONNAIRE_ANSWER_ID INT,
    AV_ATTACHMENT LONGBLOB,
    AV_FILE_NAME VARCHAR(300),
    AV_CONTENT_TYPE VARCHAR(100),
    AV_UPDATE_USER VARCHAR(60),
    AV_MODULE_CODE INT
)
RETURNS INT
DETERMINISTIC
BEGIN

    IF AV_MODULE_CODE IN (8,23,24,26,27) THEN
        IF AV_QUESTIONNAIRE_ANSWER_ATT_ID IS NULL THEN
            -- Insert new record
            INSERT INTO coi_quest_answer_attachment (
                QUESTIONNAIRE_ANSWER_ID,
                ATTACHMENT,
                FILE_NAME,
                CONTENT_TYPE,
                UPDATE_TIMESTAMP,
                UPDATE_USER
            ) VALUES (
                AV_QUESTIONNAIRE_ANSWER_ID,
                AV_ATTACHMENT,
                AV_FILE_NAME,
                AV_CONTENT_TYPE,
                utc_timestamp(),
                AV_UPDATE_USER
            );

            -- Get the newly inserted ID
            RETURN LAST_INSERT_ID();
        ELSE
            -- Update existing record
            UPDATE coi_quest_answer_attachment
            SET
                QUESTIONNAIRE_ANSWER_ID = AV_QUESTIONNAIRE_ANSWER_ID,
                ATTACHMENT = AV_ATTACHMENT,
                FILE_NAME = AV_FILE_NAME,
                CONTENT_TYPE = AV_CONTENT_TYPE,
                UPDATE_TIMESTAMP = utc_timestamp(),
                UPDATE_USER = AV_UPDATE_USER
            WHERE QUESTIONNAIRE_ANSWER_ATT_ID = AV_QUESTIONNAIRE_ANSWER_ATT_ID;

            -- Return the same ID
            RETURN AV_QUESTIONNAIRE_ANSWER_ATT_ID;
        END IF;

    ELSE

        IF AV_QUESTIONNAIRE_ANSWER_ATT_ID IS NULL THEN
            -- Insert new record
            INSERT INTO quest_answer_attachment (
                QUESTIONNAIRE_ANSWER_ID,
                ATTACHMENT,
                FILE_NAME,
                CONTENT_TYPE,
                UPDATE_TIMESTAMP,
                UPDATE_USER
            ) VALUES (
                AV_QUESTIONNAIRE_ANSWER_ID,
                AV_ATTACHMENT,
                AV_FILE_NAME,
                AV_CONTENT_TYPE,
                utc_timestamp(),
                AV_UPDATE_USER
            );

            -- Get the newly inserted ID
            RETURN LAST_INSERT_ID();
        ELSE
            -- Update existing record
            UPDATE quest_answer_attachment
            SET
                QUESTIONNAIRE_ANSWER_ID = AV_QUESTIONNAIRE_ANSWER_ID,
                ATTACHMENT = AV_ATTACHMENT,
                FILE_NAME = AV_FILE_NAME,
                CONTENT_TYPE = AV_CONTENT_TYPE,
                UPDATE_TIMESTAMP = utc_timestamp(),
                UPDATE_USER = AV_UPDATE_USER
            WHERE QUESTIONNAIRE_ANSWER_ATT_ID = AV_QUESTIONNAIRE_ANSWER_ATT_ID;

            -- Return the same ID
            RETURN AV_QUESTIONNAIRE_ANSWER_ATT_ID;
        END IF;
    END IF;
END
