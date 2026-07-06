-- `AWARD_REVENUE_TRACKER_REFRESH`; 

CREATE PROCEDURE `AWARD_REVENUE_TRACKER_REFRESH`(
AV_FILE_ID INT)
BEGIN
DECLARE LI_REVENUE_TRACKER_ID                         INT(11);
DECLARE LS_ACCOUNT_NUMBER                                                 VARCHAR(100);
DECLARE LS_AWARD_NUMBER                                                VARCHAR(12);
DECLARE LS_INTERNAL_ORDER_CODE                                 VARCHAR(50);
DECLARE LS_REMARKS                                                         VARCHAR(1000);
DECLARE LI_AMOUNT_IN_FMA_CURRENCY                                 DECIMAL(15,2);
DECLARE LS_ACTUAL_OR_COMMITTED_FLAG                         VARCHAR(1);
DECLARE LS_ENTRY_DATE                                         VARCHAR(20);
DECLARE LS_FI_POSTING_DATE                                         VARCHAR(20);
DECLARE LS_BP_CODE                                                 VARCHAR(50);
DECLARE LS_BP_NAME                                                 VARCHAR(300);
DECLARE LS_DOCUMENT_DATE                                                 VARCHAR(20);
DECLARE LS_FI_GL_ACCOUNT                                                 VARCHAR(50);
DECLARE LS_FI_GL_DESCRIPTION                                         VARCHAR(200);
DECLARE LS_TRANSACTION_REFERENCE_NUMBER                 VARCHAR(100);
DECLARE LS_REFERENCE_DOCUMENT_NUMBER                         VARCHAR(10);
DECLARE LS_REFERENCE_POSTING_LINE                                VARCHAR(6);
DECLARE LS_GUID                                                        VARCHAR(40);
DECLARE LS_GMIA_DOCNR                        VARCHAR(10);
DECLARE LS_DOCLN                                        VARCHAR(6);
DECLARE LS_RBUKRS                                                VARCHAR(4);
DECLARE LS_RVALUETYPE_9                                                VARCHAR(2);
DECLARE LS_RYEAR                                                        VARCHAR(4);
DECLARE LS_GL_SIRID                                        VARCHAR(40);
DECLARE LS_BATCH_ID                                                        VARCHAR(100);
DECLARE LS_GRANT_NBR                                                        VARCHAR(20);
DECLARE LS_SPONSOR_PROGRAM                                                VARCHAR(100);
DECLARE LS_SPONSOR_CLASS                                                VARCHAR(50);
DECLARE LS_FUND                                                                VARCHAR(10);
DECLARE LS_FUND_CENTER                                                        VARCHAR(16);
DECLARE LI_FLAG                                                                 INT;
DECLARE LS_ERROR_MSG                                                        VARCHAR(1000);
DECLARE LI_SEQ_ERROR_LOG_ID                                                INT;
DECLARE LI_ERROR_FLAG                                                        INT;
DECLARE LS_PAYMENT_DOC_NUMBER                                                                                   VARCHAR(100);
DECLARE LS_PAYMENT_DATE                                                                                 DATETIME;
DECLARE LS_PAYMENT_FISCAL_YEAR                                                                  VARCHAR(100);
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
                GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
                 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
                SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
                SELECT @full_error INTO LS_ERROR_MSG;
                INSERT INTO AWARD_REVENUE_ERROR_LOG(ACCOUNT_NUMBER,INTERNAL_ORDER_CODE,ERROR_MESSAGE,PROCEDURE_NAME,UPDATE_TIMESTAMP, UPDATE_USER)
                VALUES(LS_ACCOUNT_NUMBER,LS_INTERNAL_ORDER_CODE,LS_ERROR_MSG,'AWARD_REVENUE_TRACKER_REFRESH',UTC_TIMESTAMP(),'admin');
                SET LI_ERROR_FLAG = 1;
        END;
        SET LI_ERROR_FLAG = 0;
        BEGIN
                DECLARE DONE1 INT DEFAULT FALSE;
                DECLARE CUR_SEL_DATA CURSOR FOR
                SELECT
                        ACCOUNT_NUMBER,
                        INTERNAL_ORDER_CODE,
                        REMARKS,
                        AMOUNT_IN_FMA_CURRENCY,
                        ACTUAL_OR_COMMITTED_FLAG,
                        ENTRY_DATE,
                        FI_POSTING_DATE,
                        BP_CODE,
                        BP_NAME,
                        DOCUMENT_DATE,
                        FI_GL_ACCOUNT,
                        FI_GL_DESCRIPTION,
                        TRANSACTION_REFERENCE_NUMBER,
                        REFERENCE_DOCUMENT_NUMBER,
                        REFERENCE_POSTING_LINE,
                        GUID,
                        GMIA_DOCNR,
                        DOCLN,
                        RBUKRS,
                        RVALUETYPE_9,
                        RYEAR,
                        GL_SIRID,
                        BATCH_ID,
                        GRANT_NBR,
                        SPONSOR_PROGRAM,
                        SPONSOR_CLASS,
                        FUND,
                        FUND_CENTER,
                        PAYMENT_DOC_NUMBER,
                        PAYMENT_DATE,
                        PAYMENT_FISCAL_YEAR
        FROM AWARD_REVENUE_TRANSACTIONS_RT WHERE FILE_ID = AV_FILE_ID;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
        OPEN CUR_SEL_DATA;
        INSERT_LOOP: LOOP
                FETCH CUR_SEL_DATA INTO
                LS_ACCOUNT_NUMBER,
                LS_INTERNAL_ORDER_CODE,
                LS_REMARKS,
                LI_AMOUNT_IN_FMA_CURRENCY,
                LS_ACTUAL_OR_COMMITTED_FLAG,
                LS_ENTRY_DATE,
                LS_FI_POSTING_DATE,
                LS_BP_CODE,
                LS_BP_NAME,
                LS_DOCUMENT_DATE,
                LS_FI_GL_ACCOUNT,
                LS_FI_GL_DESCRIPTION,
                LS_TRANSACTION_REFERENCE_NUMBER,
                LS_REFERENCE_DOCUMENT_NUMBER,
                LS_REFERENCE_POSTING_LINE,
                LS_GUID,
                LS_GMIA_DOCNR,
                LS_DOCLN,
                LS_RBUKRS,
                LS_RVALUETYPE_9,
                LS_RYEAR,
                LS_GL_SIRID,
                LS_BATCH_ID,
                LS_GRANT_NBR,
                LS_SPONSOR_PROGRAM,
                LS_SPONSOR_CLASS,
                LS_FUND,
                LS_FUND_CENTER,
                LS_PAYMENT_DOC_NUMBER,
                LS_PAYMENT_DATE,
                LS_PAYMENT_FISCAL_YEAR;
        IF DONE1 THEN
                LEAVE INSERT_LOOP;
        END IF;
        IF LENGTH(LS_ACCOUNT_NUMBER) > 15 THEN
                SET LS_ACCOUNT_NUMBER = SUBSTRING(LS_ACCOUNT_NUMBER, 1, 15);
        END IF;
        IF LS_ENTRY_DATE = '' THEN
                SET LS_ENTRY_DATE = NULL;
        END IF;
        IF LS_FI_POSTING_DATE = '' THEN
                SET LS_FI_POSTING_DATE = NULL;
        END IF;
        IF LS_DOCUMENT_DATE = '' THEN
                SET LS_DOCUMENT_DATE = NULL;
        END IF;
    SELECT COUNT(1) INTO LI_FLAG
    FROM AWARD T1
        WHERE T1.ACCOUNT_NUMBER = LS_ACCOUNT_NUMBER;
    IF LI_FLAG > 0 THEN
                SELECT AWARD_NUMBER INTO LS_AWARD_NUMBER FROM AWARD T1
                WHERE T1.ACCOUNT_NUMBER = LS_ACCOUNT_NUMBER
        AND T1.AWARD_SEQUENCE_STATUS = 'ACTIVE';
        ELSE
                SET LS_AWARD_NUMBER = NULL;
        END IF;
        IF LI_ERROR_FLAG = 0 THEN
                SELECT COUNT(1) INTO LI_FLAG
                FROM AWARD_REVENUE_TRANSACTIONS
                WHERE IFNULL(TRIM(REFERENCE_DOCUMENT_NUMBER),'0') = IFNULL(TRIM(LS_REFERENCE_DOCUMENT_NUMBER),'0')
                AND IFNULL(TRIM(REFERENCE_POSTING_LINE),'0') = IFNULL(TRIM(LS_REFERENCE_POSTING_LINE),'0')
                AND IFNULL(TRIM(GUID),'0') = IFNULL(TRIM(LS_GUID),'0')
                AND IFNULL(TRIM(GMIA_DOCNR),'0') = IFNULL(TRIM(LS_GMIA_DOCNR),'0')
                AND IFNULL(TRIM(DOCLN),'0') = IFNULL(TRIM(LS_DOCLN),'0')
                AND IFNULL(TRIM(RBUKRS),'0') = IFNULL(TRIM(LS_RBUKRS),'0')
                AND IFNULL(TRIM(RVALUETYPE_9),'0') = IFNULL(TRIM(LS_RVALUETYPE_9),'0')
                AND IFNULL(TRIM(RYEAR),'0') = IFNULL(TRIM(LS_RYEAR),'0')
                AND IFNULL(TRIM(GL_SIRID),'0') = IFNULL(TRIM(LS_GL_SIRID),'0');
                IF LI_FLAG = 0 THEN
                        SELECT IFNULL(MAX(REVENUE_TRACKER_ID),0)+1 INTO LI_REVENUE_TRACKER_ID FROM AWARD_REVENUE_TRANSACTIONS;
                        INSERT INTO AWARD_REVENUE_TRANSACTIONS
                                (
                                        REVENUE_TRACKER_ID,
                                        AWARD_NUMBER,
                                        ACCOUNT_NUMBER,
                                        INTERNAL_ORDER_CODE,
                                        REMARKS,
                                        AMOUNT_IN_FMA_CURRENCY,
                                        ACTUAL_OR_COMMITTED_FLAG,
                                        FM_POSTING_DATE,
                                        FI_POSTING_DATE,
                                        BP_CODE,
                                        BP_NAME,
                                        DOCUMENT_DATE,
                                        FI_GL_ACCOUNT,
                                        FI_GL_DESCRIPTION,
                                        TRANSACTION_REFERENCE_NUMBER,
                                        REFERENCE_DOCUMENT_NUMBER,
                                        REFERENCE_POSTING_LINE,
                                        GUID,
                                        GMIA_DOCNR,
                                        DOCLN,
                                        RBUKRS,
                                        RVALUETYPE_9,
                                        RYEAR,
                                        GL_SIRID,
                                        BATCH_ID,
                                        GRANT_NBR,
                                        SPONSOR_PROGRAM,
                                        SPONSOR_CLASS,
                                        FUND,
                                        FUND_CENTER,
                                        UPDATE_TIMESTAMP,
                                        UPDATE_USER,
                                        FILE_ID,
                                        PAYMENT_DOC_NUMBER,
                                        PAYMENT_DATE,
                                        PAYMENT_FISCAL_YEAR,
                                        BUDGET_CATEGORY_CODE
                                )
                                VALUES
                                (
                                        LI_REVENUE_TRACKER_ID,
                                        LS_AWARD_NUMBER,
                                        LS_ACCOUNT_NUMBER,
                                        LS_INTERNAL_ORDER_CODE,
                                        LS_REMARKS,
                                        LI_AMOUNT_IN_FMA_CURRENCY,
                                        LS_ACTUAL_OR_COMMITTED_FLAG,
                                        date_format(LS_ENTRY_DATE,'%Y-%m-%d'),
                                        date_format(LS_FI_POSTING_DATE,'%Y-%m-%d'),
                                        LS_BP_CODE,
                                        LS_BP_NAME,
                                        date_format(LS_DOCUMENT_DATE,'%Y-%m-%d'),
                                        LS_FI_GL_ACCOUNT,
                                        LS_FI_GL_DESCRIPTION,
                                        LS_TRANSACTION_REFERENCE_NUMBER,
                                        TRIM(LS_REFERENCE_DOCUMENT_NUMBER),
                                        TRIM(LS_REFERENCE_POSTING_LINE),
                                        TRIM(LS_GUID),
                                        TRIM(LS_GMIA_DOCNR),
                                        TRIM(LS_DOCLN),
                                        TRIM(LS_RBUKRS),
                                        TRIM(LS_RVALUETYPE_9),
                                        TRIM(LS_RYEAR),
                                        TRIM(LS_GL_SIRID),
                                        LS_BATCH_ID,
                                        LS_GRANT_NBR,
                                        LS_SPONSOR_PROGRAM,
                                        LS_SPONSOR_CLASS,
                                        LS_FUND,
                                        LS_FUND_CENTER,
                                        UTC_TIMESTAMP(),
                                        'admin',
                                        AV_FILE_ID,
                                        LS_PAYMENT_DOC_NUMBER,
                                        LS_PAYMENT_DATE,
                                        LS_PAYMENT_FISCAL_YEAR,
                                        SUBSTR(LS_INTERNAL_ORDER_CODE,16,3)
                                );
                        ELSE
                        select count(1) into LI_FLAG from  award_revenue_files where FILE_NAME like ("%rise_revenue%") and file_id = AV_FILE_ID;
                        IF LI_FLAG = 0 THEN
                                UPDATE AWARD_REVENUE_TRANSACTIONS
                                SET
                                        REFERENCE_DOCUMENT_NUMBER = TRIM(LS_REFERENCE_DOCUMENT_NUMBER),
                                        REFERENCE_POSTING_LINE = TRIM(LS_REFERENCE_POSTING_LINE),
                                                                                BATCH_ID = LS_BATCH_ID,
                                        GUID = TRIM(LS_GUID),
                                        GMIA_DOCNR = TRIM(LS_GMIA_DOCNR),
                                        DOCLN = TRIM(LS_DOCLN),
                                        RBUKRS = TRIM(LS_RBUKRS),
                                        RVALUETYPE_9 = TRIM(LS_RVALUETYPE_9),
                                        RYEAR = TRIM(LS_RYEAR),
                                        GL_SIRID = TRIM(LS_GL_SIRID),
                                        UPDATE_TIMESTAMP = UTC_TIMESTAMP(),
                                        UPDATE_USER = 'admin',
                                        FILE_ID = AV_FILE_ID,
                                        PAYMENT_DOC_NUMBER = LS_PAYMENT_DOC_NUMBER,
                                                                                PAYMENT_DATE = LS_PAYMENT_DATE,
                                        PAYMENT_FISCAL_YEAR = LS_PAYMENT_FISCAL_YEAR
                                WHERE IFNULL(TRIM(REFERENCE_DOCUMENT_NUMBER),'0') = IFNULL(TRIM(LS_REFERENCE_DOCUMENT_NUMBER),'0')
                                AND IFNULL(TRIM(REFERENCE_POSTING_LINE),'0') = IFNULL(TRIM(LS_REFERENCE_POSTING_LINE),'0')
                                AND IFNULL(TRIM(GUID),'0') = IFNULL(TRIM(LS_GUID),'0')
                                AND IFNULL(TRIM(GMIA_DOCNR),'0') = IFNULL(TRIM(LS_GMIA_DOCNR),'0')
                                AND IFNULL(TRIM(DOCLN),'0') = IFNULL(TRIM(LS_DOCLN),'0')
                                AND IFNULL(TRIM(RBUKRS),'0') = IFNULL(TRIM(LS_RBUKRS),'0')
                                AND IFNULL(TRIM(RVALUETYPE_9),'0') = IFNULL(TRIM(LS_RVALUETYPE_9),'0')
                                AND IFNULL(TRIM(RYEAR),'0') = IFNULL(TRIM(LS_RYEAR),'0')
                                AND IFNULL(TRIM(GL_SIRID),'0') = IFNULL(TRIM(LS_GL_SIRID),'0');
                        ELSE
                         UPDATE AWARD_REVENUE_TRANSACTIONS
                                SET AWARD_NUMBER = LS_AWARD_NUMBER,
                                        ACCOUNT_NUMBER = LS_ACCOUNT_NUMBER,
                                        INTERNAL_ORDER_CODE = LS_INTERNAL_ORDER_CODE,
                                        REMARKS = LS_REMARKS,
                                        AMOUNT_IN_FMA_CURRENCY = LI_AMOUNT_IN_FMA_CURRENCY,
                                        ACTUAL_OR_COMMITTED_FLAG = LS_ACTUAL_OR_COMMITTED_FLAG,
                                        FM_POSTING_DATE = date_format(LS_ENTRY_DATE,'%Y-%m-%d'),
                                        FI_POSTING_DATE = date_format(LS_FI_POSTING_DATE,'%Y-%m-%d'),
                                        BP_CODE = LS_BP_CODE,
                                        BP_NAME = LS_BP_NAME,
                                        DOCUMENT_DATE = date_format(LS_DOCUMENT_DATE,'%Y-%m-%d'),
                                        FI_GL_ACCOUNT = LS_FI_GL_ACCOUNT,
                                        FI_GL_DESCRIPTION = LS_FI_GL_DESCRIPTION,
                                        TRANSACTION_REFERENCE_NUMBER = LS_TRANSACTION_REFERENCE_NUMBER,
                                        REFERENCE_DOCUMENT_NUMBER = TRIM(LS_REFERENCE_DOCUMENT_NUMBER),
                                        REFERENCE_POSTING_LINE = TRIM(LS_REFERENCE_POSTING_LINE),
                                        GUID = TRIM(LS_GUID),
                                        GMIA_DOCNR = TRIM(LS_GMIA_DOCNR),
                                        DOCLN = TRIM(LS_DOCLN),
                                        RBUKRS = TRIM(LS_RBUKRS),
                                        RVALUETYPE_9 = TRIM(LS_RVALUETYPE_9),
                                        RYEAR = TRIM(LS_RYEAR),
                                        GL_SIRID = TRIM(LS_GL_SIRID),
                                        BATCH_ID = LS_BATCH_ID,
                                        GRANT_NBR = LS_GRANT_NBR,
                                        SPONSOR_PROGRAM = LS_SPONSOR_PROGRAM,
                                        SPONSOR_CLASS = LS_SPONSOR_CLASS,
                                        FUND = LS_FUND,
                                        FUND_CENTER = LS_FUND_CENTER,
                                        UPDATE_TIMESTAMP = UTC_TIMESTAMP(),
                                        UPDATE_USER = 'admin',
                                        FILE_ID = AV_FILE_ID,
                                        BUDGET_CATEGORY_CODE = SUBSTR(LS_INTERNAL_ORDER_CODE,16,3)
                                WHERE IFNULL(TRIM(REFERENCE_DOCUMENT_NUMBER),'0') = IFNULL(TRIM(LS_REFERENCE_DOCUMENT_NUMBER),'0')
                                AND IFNULL(TRIM(REFERENCE_POSTING_LINE),'0') = IFNULL(TRIM(LS_REFERENCE_POSTING_LINE),'0')
                                AND IFNULL(TRIM(GUID),'0') = IFNULL(TRIM(LS_GUID),'0')
                                AND IFNULL(TRIM(GMIA_DOCNR),'0') = IFNULL(TRIM(LS_GMIA_DOCNR),'0')
                                AND IFNULL(TRIM(DOCLN),'0') = IFNULL(TRIM(LS_DOCLN),'0')
                                AND IFNULL(TRIM(RBUKRS),'0') = IFNULL(TRIM(LS_RBUKRS),'0')
                                AND IFNULL(TRIM(RVALUETYPE_9),'0') = IFNULL(TRIM(LS_RVALUETYPE_9),'0')
                                AND IFNULL(TRIM(RYEAR),'0') = IFNULL(TRIM(LS_RYEAR),'0')
                                AND IFNULL(TRIM(GL_SIRID),'0') = IFNULL(TRIM(LS_GL_SIRID),'0');
                        END IF;
                        END IF;
                END IF;
                                SELECT COUNT(1) INTO LI_FLAG FROM CLAIM_INVOICE_LOG WHERE CLAIM_NUMBER  = LS_TRANSACTION_REFERENCE_NUMBER AND OUTPUT_DOCUMENT_NUMBER = TRIM(LS_REFERENCE_DOCUMENT_NUMBER);
                IF LI_FLAG > 0 and  LS_DOCUMENT_DATE is not null THEN
                                        UPDATE CLAIM SET DOCUMENT_DATE =  date_format(LS_DOCUMENT_DATE,'%Y-%m-%d') WHERE CLAIM_NUMBER = LS_TRANSACTION_REFERENCE_NUMBER;
                                END IF;
                SET LS_AWARD_NUMBER = NULL;
                SET LS_ACCOUNT_NUMBER = NULL;
                SET LS_INTERNAL_ORDER_CODE = NULL;
                SET LS_REMARKS = NULL;
                SET LI_AMOUNT_IN_FMA_CURRENCY = NULL;
                SET LS_ACTUAL_OR_COMMITTED_FLAG = NULL;
                SET LS_ENTRY_DATE = NULL;
                SET LS_FI_POSTING_DATE = NULL;
                SET LS_BP_CODE = NULL;
                SET LS_BP_NAME = NULL;
                SET LS_DOCUMENT_DATE = NULL;
                SET LS_FI_GL_ACCOUNT = NULL;
                SET LS_FI_GL_DESCRIPTION = NULL;
                SET LS_TRANSACTION_REFERENCE_NUMBER = NULL;
                SET LS_REFERENCE_DOCUMENT_NUMBER = NULL;
                SET LS_REFERENCE_POSTING_LINE = NULL;
                SET LS_GUID = NULL;
                SET LS_GMIA_DOCNR = NULL;
                SET LS_DOCLN = NULL;
                SET LS_RBUKRS = NULL;
                SET LS_RVALUETYPE_9 = NULL;
                SET LS_RYEAR = NULL;
                SET LS_GL_SIRID = NULL;
                SET LS_BATCH_ID = NULL;
                SET LS_GRANT_NBR = NULL;
                SET LS_SPONSOR_PROGRAM = NULL;
                SET LS_SPONSOR_CLASS = NULL;
                SET LS_FUND = NULL;
                SET LS_FUND_CENTER = NULL;
                SET LS_PAYMENT_DOC_NUMBER = NULL;
                SET LS_PAYMENT_DATE = NULL;
                SET LS_PAYMENT_FISCAL_YEAR = NULL;
        END LOOP;
        CLOSE CUR_SEL_DATA;
        END;
END;
END
