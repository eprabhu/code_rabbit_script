CREATE PROCEDURE `RESET_AUTO_INCREMENT`()
BEGIN
	  SELECT @max := IFNULL(MAX(AWARD_SCIENCE_KEYWORD_ID),0)+ 1 FROM AWARD_SCIENCE_KEYWORD;
      SET @alter_statement = concat('ALTER TABLE AWARD_SCIENCE_KEYWORD AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(BUDGET_DETAILS_CAL_AMTS_ID),0)+1 FROM AWARD_BUDGET_DET_CAL_AMT;
      SET @alter_statement = concat('ALTER TABLE AWARD_BUDGET_DET_CAL_AMT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(BUDGET_NON_PERSON_DTL_ID),0)+1 FROM AWARD_BUDGET_NON_PERSON_DETAIL;
      SET @alter_statement = concat('ALTER TABLE AWARD_BUDGET_NON_PERSON_DETAIL AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(BUDGET_PERSON_DETAIL_ID),0)+1 FROM AWARD_BUDGET_PERSON_DETAIL;
      SET @alter_statement = concat('ALTER TABLE AWARD_BUDGET_PERSON_DETAIL AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(BUDGET_RATE_AND_BASE_ID),0)+1 FROM AWARD_BUDGET_RATE_AND_BASE;
      SET @alter_statement = concat('ALTER TABLE AWARD_BUDGET_RATE_AND_BASE AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(BUDGET_PERSON_ID),0)+1 FROM AWARD_BUDGET_PERSONS;
      SET @alter_statement = concat('ALTER TABLE AWARD_BUDGET_PERSONS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_RATE_ID),0)+1 FROM AWARD_RATES;
      SET @alter_statement = concat('ALTER TABLE AWARD_RATES AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_PERSON_UNIT_ID),0)+1 FROM AWARD_PERSON_UNIT;
      SET @alter_statement = concat('ALTER TABLE AWARD_PERSON_UNIT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(KEYPERSON_TIMESHEET_ID),0)+1 FROM AWARD_KEYPERSON_TIMESHEET;
      SET @alter_statement = concat('ALTER TABLE AWARD_KEYPERSON_TIMESHEET AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(ATTACHMENT_ID),0)+1 FROM AWARD_PERSON_ATTACHMNT;
      SET @alter_statement = concat('ALTER TABLE AWARD_PERSON_ATTACHMNT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_PERSON_ID),0)+1 FROM AWARD_PERSONS;
      SET @alter_statement = concat('ALTER TABLE AWARD_PERSONS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_PERSON_ROLE_ID),0)+1 FROM AWARD_PERSON_ROLES;
      SET @alter_statement = concat('ALTER TABLE AWARD_PERSON_ROLES AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_SPONSOR_CONTACT_ID),0)+1 FROM AWARD_CONTACT;
      SET @alter_statement = concat('ALTER TABLE AWARD_CONTACT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(FNA_DISTRIBUTION_ID),0)+1 FROM AWARD_AMT_FNA_DISTRIBUTION;
      SET @alter_statement = concat('ALTER TABLE AWARD_AMT_FNA_DISTRIBUTION AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_SPONSOR_TERM_ID),0)+1 FROM AWARD_SPONSOR_TERM;
      SET @alter_statement = concat('ALTER TABLE AWARD_SPONSOR_TERM AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_COST_SHARE_ID),0)+1 FROM AWARD_COST_SHARE;
      SET @alter_statement = concat('ALTER TABLE AWARD_COST_SHARE AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_APPROVED_SUBAWARD_ID),0)+1 FROM AWARD_APPROVED_SUBAWARDS;
      SET @alter_statement = concat('ALTER TABLE AWARD_APPROVED_SUBAWARDS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_SPECIAL_REVIEW_ID),0)+1 FROM AWARD_SPECIAL_REVIEW;
      SET @alter_statement = concat('ALTER TABLE AWARD_SPECIAL_REVIEW AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_PUBLICATION_ID),0)+1 FROM AWARD_PUBLICATIONS;
      SET @alter_statement = concat('ALTER TABLE AWARD_PUBLICATIONS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_ACHIEVEMENTS_ATTACH_ID),0)+1 FROM AWARD_ACHIEVEMENTS_ATTACHMENTS;
      SET @alter_statement = concat('ALTER TABLE AWARD_ACHIEVEMENTS_ATTACHMENTS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_ASSOC_DETAIL_ID),0)+1 FROM AWARD_ASSOC_DETAIL;
      SET @alter_statement = concat('ALTER TABLE AWARD_ASSOC_DETAIL AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_ASSOCIATION_ID),0)+1 FROM AWARD_ASSOCIATION;
      SET @alter_statement = concat('ALTER TABLE AWARD_ASSOCIATION AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_FUNDING_PROPOSAL_ID),0)+1 FROM AWARD_FUNDING_PROPOSALS;
      SET @alter_statement = concat('ALTER TABLE AWARD_FUNDING_PROPOSALS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_APPROVED_EQUIPMENT_ID),0)+1 FROM AWARD_APPROVED_EQUIPMENT;
      SET @alter_statement = concat('ALTER TABLE AWARD_APPROVED_EQUIPMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_APPR_FORN_TRAVEL_ID),0)+1 FROM AWARD_APPROVED_FOREIGN_TRAVEL;
      SET @alter_statement = concat('ALTER TABLE AWARD_APPROVED_FOREIGN_TRAVEL AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(CUSTOM_DATA_ID),0)+1 FROM CUSTOM_DATA;
      SET @alter_statement = concat('ALTER TABLE CUSTOM_DATA AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_MILESTONE_ID),0)+1 FROM AWARD_MILESTONE;
      SET @alter_statement = concat('ALTER TABLE AWARD_MILESTONE AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(RESRCH_AREA_ID),0)+1 FROM AWARD_RESEARCH_AREAS;
      SET @alter_statement = concat('ALTER TABLE AWARD_RESEARCH_AREAS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_MANPOWER_ID),0)+1 FROM AWARD_MANPOWER;
      SET @alter_statement = concat('ALTER TABLE AWARD_MANPOWER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_MANPOWER_RESOURCE_ID),0)+1 FROM AWARD_MANPOWER_RESOURCE;
      SET @alter_statement = concat('ALTER TABLE AWARD_MANPOWER_RESOURCE AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(QUESTIONNAIRE_ANS_HEADER_ID),0)+1 FROM QUEST_ANSWER_HEADER;
      SET @alter_statement = concat('ALTER TABLE QUEST_ANSWER_HEADER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(QUESTIONNAIRE_ANSWER_ID),0)+1 FROM QUEST_ANSWER;
      SET @alter_statement = concat('ALTER TABLE QUEST_ANSWER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(QUESTIONNAIRE_ANSWER_ATT_ID),0)+1 FROM QUEST_ANSWER_ATTACHMENT;
      SET @alter_statement = concat('ALTER TABLE QUEST_ANSWER_ATTACHMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(QUEST_TABLE_ANSWER_ID),0)+1 FROM QUEST_TABLE_ANSWER;
      SET @alter_statement = concat('ALTER TABLE QUEST_TABLE_ANSWER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(FEED_ID),0)+1 FROM SAP_AWARD_FEED;
      SET @alter_statement = concat('ALTER TABLE SAP_AWARD_FEED AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

      SELECT @max := IFNULL(MAX(AWARD_ID),0)+ 1 FROM AWARD;
      SET @alter_statement = concat('ALTER TABLE AWARD AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	SELECT @max := IFNULL(MAX(AWARD_AMOUNT_INFO_ID),0)+1 FROM AWARD_AMOUNT_INFO;
      SET @alter_statement = concat('ALTER TABLE AWARD_AMOUNT_INFO AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(AWARD_ATTACHMENT_ID),0)+1 FROM AWARD_ATTACHMENT;
      SET @alter_statement = concat('ALTER TABLE AWARD_ATTACHMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_COMMENT_ID),0)+1 FROM AWARD_COMMENT;
      SET @alter_statement = concat('ALTER TABLE AWARD_COMMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(AWARD_HIERARCHY_ID),0)+1 FROM AWARD_HIERARCHY;
      SET @alter_statement = concat('ALTER TABLE AWARD_HIERARCHY AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_HISTORY_LOG_ID),0)+1 FROM AWARD_HISTORY_LOG;
      SET @alter_statement = concat('ALTER TABLE AWARD_HISTORY_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_REVIEW_COMMENT_ID),0)+1 FROM AWARD_REVIEW_COMMENT;
      SET @alter_statement = concat('ALTER TABLE AWARD_REVIEW_COMMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(REVENUE_TRACKER_ID),0)+1 FROM AWARD_REVENUE_TRANSACTIONS;
      SET @alter_statement = concat('ALTER TABLE AWARD_REVENUE_TRANSACTIONS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(FILE_ID),0)+1 FROM AWARD_EXPENSE_FILES;
      SET @alter_statement = concat('ALTER TABLE AWARD_EXPENSE_FILES AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(FILE_ID),0)+1 FROM AWARD_REVENUE_FILES;
      SET @alter_statement = concat('ALTER TABLE AWARD_REVENUE_FILES AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(BATCH_ID),0)+1 FROM SAP_AWARD_FEED_BATCH;
      SET @alter_statement = concat('ALTER TABLE SAP_AWARD_FEED_BATCH AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(BATCH_ERROR_ID),0)+1 FROM SAP_AWARD_FEED_BATCH_ERROR_LOG;
      SET @alter_statement = concat('ALTER TABLE SAP_AWARD_FEED_BATCH_ERROR_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(BATCH_FILE_ID),0)+1 FROM SAP_AWARD_FEED_BATCH_FILES;
      SET @alter_statement = concat('ALTER TABLE SAP_AWARD_FEED_BATCH_FILES AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ID),0)+1 FROM FEED_AWARD_DETAILS;
      SET @alter_statement = concat('ALTER TABLE FEED_AWARD_DETAILS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(PAYROLL_ID),0)+1 FROM AWARD_MANPOWER_PAYROLL;
      SET @alter_statement = concat('ALTER TABLE AWARD_MANPOWER_PAYROLL AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_PERSON_ORCID_WORK_ID),0)+1 FROM AWARD_PERSON_ORCID_WORK;
      SET @alter_statement = concat('ALTER TABLE AWARD_PERSON_ORCID_WORK AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  /* SELECT @max := IFNULL(MAX(ERROR_LOG_ID),0)+1 FROM AWARD_EXPENSE_ERROR_LOG;
      SET @alter_statement = concat('ALTER TABLE AWARD_EXPENSE_ERROR_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt; */
	  
	  SELECT @max := IFNULL(MAX(AWARD_EXPENSE_TRANS_ID),0)+1 FROM AWARD_EXPENSE_TRANSACTIONS;
      SET @alter_statement = concat('ALTER TABLE AWARD_EXPENSE_TRANSACTIONS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(EXPENSE_TRACKER_ID),0)+1 FROM AWARD_EXPENSE_TRANSACTIONS_RT;
      SET @alter_statement = concat('ALTER TABLE AWARD_EXPENSE_TRANSACTIONS_RT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_REP_RECPNT_NOTIFY_LOG_ID),0)+1 FROM AWARD_REPORT_RECPNT_NOTIFY_LOG;
      SET @alter_statement = concat('ALTER TABLE AWARD_REPORT_RECPNT_NOTIFY_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_SUP_ORG_MAPPING_ID),0)+1 FROM AWARD_SUP_ORG_MAPPING;
      SET @alter_statement = concat('ALTER TABLE AWARD_SUP_ORG_MAPPING AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(REVENUE_TRACKER_ID),0)+1 FROM AWARD_REVENUE_TRANSACTIONS_RT;
      SET @alter_statement = concat('ALTER TABLE AWARD_REVENUE_TRANSACTIONS_RT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(TRNSCTN_HISTORY_ID),0)+1 FROM AWARD_AMT_TRNSCTN_HISTORY;
      SET @alter_statement = concat('ALTER TABLE AWARD_AMT_TRNSCTN_HISTORY AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

       SELECT @max := IFNULL(MAX(AWARD_REP_RECPNT_NOTIFY_LOG_ID),0)+1 FROM AWARD_REPORT_RECPNT_NOTIFY_LOG;
      SET @alter_statement = concat('ALTER TABLE AWARD_REPORT_RECPNT_NOTIFY_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(REMINDER_ID),0)+1 FROM AWARD_REPORT_REMINDER;
      SET @alter_statement = concat('ALTER TABLE AWARD_REPORT_REMINDER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(AWARD_APPROVED_SUBAWARD_ID),0)+1 FROM AWARD_APPROVED_SUBAWARDS;
      SET @alter_statement = concat('ALTER TABLE AWARD_APPROVED_SUBAWARDS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(SPONSOR_REPORT_ID),0)+1 FROM SPONSOR_REPORT;
      SET @alter_statement = concat('ALTER TABLE SPONSOR_REPORT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(SPONSOR_TERM_REPORT_ID),0)+1 FROM SPONSOR_TERM_REPORT;
      SET @alter_statement = concat('ALTER TABLE SPONSOR_TERM_REPORT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(BUDGET_DETAILS_CAL_AMTS_ID),0)+1 FROM BUDGET_DET_CAL_AMT;
      SET @alter_statement = concat('ALTER TABLE BUDGET_DET_CAL_AMT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(BUDGET_MODULAR_IDC_ID),0)+1 FROM BUDGET_MODULAR_IDC;
      SET @alter_statement = concat('ALTER TABLE BUDGET_MODULAR_IDC AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(BUDGET_PERSON_DETAIL_ID),0)+1 FROM BUDGET_PERSON_DETAIL;
      SET @alter_statement = concat('ALTER TABLE BUDGET_PERSON_DETAIL AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(BUD_PER_RATE_BASE_ID),0)+1 FROM BUDGET_PER_DET_RATE_AND_BASE;
      SET @alter_statement = concat('ALTER TABLE BUDGET_PER_DET_RATE_AND_BASE AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(BUDGET_RATE_AND_BASE_ID),0)+1 FROM BUDGET_RATE_AND_BASE;
      SET @alter_statement = concat('ALTER TABLE BUDGET_RATE_AND_BASE AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(PROTOCOL_ID),0)+1 FROM AC_PROTOCOL;
      SET @alter_statement = concat('ALTER TABLE AC_PROTOCOL AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(PROTOCOL_ID),0)+1 FROM IRB_PROTOCOL;
      SET @alter_statement = concat('ALTER TABLE IRB_PROTOCOL AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(CP_REPORT_HEADER_ID),0)+1 FROM CP_REPORT_HEADER;
      SET @alter_statement = concat('ALTER TABLE CP_REPORT_HEADER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(CP_REPORT_PROJECT_DETAIL_ID),0)+1 FROM CP_REPORT_PROJECT_DETAILS;
      SET @alter_statement = concat('ALTER TABLE CP_REPORT_PROJECT_DETAILS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(SELECTED_WIDGET_ID),0)+1 FROM USER_SELECTED_WIDGET;
      SET @alter_statement = concat('ALTER TABLE USER_SELECTED_WIDGET AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(EXPENSE_TRACKER_LOG_ID),0)+1 FROM AWARD_EXP_TRANSACTIONS_RT_LOG;
      SET @alter_statement = concat('ALTER TABLE AWARD_EXP_TRANSACTIONS_RT_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  /* SELECT @max := IFNULL(MAX(ERROR_ID),0)+1 FROM SAP_FEED_REPORT_ERROR_LOG;
      SET @alter_statement = concat('ALTER TABLE SAP_FEED_REPORT_ERROR_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt; */
	  
	  SELECT @max := IFNULL(MAX(ID),0)+1 FROM SAP_FEED_PROB_GRANTCODE_REPORT;
      SET @alter_statement = concat('ALTER TABLE SAP_FEED_PROB_GRANTCODE_REPORT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ID),0)+1 FROM SAP_FEED_TMPL_FM_BUDGET;
      SET @alter_statement = concat('ALTER TABLE SAP_FEED_TMPL_FM_BUDGET AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ID),0)+1 FROM SAP_FEED_TMPL_FUNDED_PRGM;
      SET @alter_statement = concat('ALTER TABLE SAP_FEED_TMPL_FUNDED_PRGM AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ID),0)+1 FROM SAP_FEED_TMPL_GRANT_BUD_MASTER;
      SET @alter_statement = concat('ALTER TABLE SAP_FEED_TMPL_GRANT_BUD_MASTER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	   SELECT @max := IFNULL(MAX(ID),0)+1 FROM SAP_FEED_TMPL_GRANT_MASTER;
      SET @alter_statement = concat('ALTER TABLE SAP_FEED_TMPL_GRANT_MASTER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	   SELECT @max := IFNULL(MAX(ID),0)+1 FROM SAP_FEED_TMPL_PROJECT_DEF;
      SET @alter_statement = concat('ALTER TABLE SAP_FEED_TMPL_PROJECT_DEF AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	   SELECT @max := IFNULL(MAX(ID),0)+1 FROM SAP_FEED_TMPL_SPONSOR_PRGM;
      SET @alter_statement = concat('ALTER TABLE SAP_FEED_TMPL_SPONSOR_PRGM AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ID),0)+1 FROM SAP_FEED_TMPL_SPONSOR_CLASS;
      SET @alter_statement = concat('ALTER TABLE SAP_FEED_TMPL_SPONSOR_CLASS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ID),0)+1 FROM SAP_FEED_TMPL_WBS;
      SET @alter_statement = concat('ALTER TABLE SAP_FEED_TMPL_WBS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(FUNDING_SCHEME_ATTACHMENT_ID),0)+1 FROM FUNDING_SCHEME_ATTACHMENT;
      SET @alter_statement = concat('ALTER TABLE FUNDING_SCHEME_ATTACHMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(GRANT_CRITERIA_CODE),0)+1 FROM GRANT_CALL_CRITERIA;
      SET @alter_statement = concat('ALTER TABLE GRANT_CALL_CRITERIA AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
 
      SELECT @max := IFNULL(MAX(INBOX_ID),0)+1 FROM INBOX;
      SET @alter_statement = concat('ALTER TABLE INBOX AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

      SELECT @max := IFNULL(MAX(PERSON_RT_ID),0)+1 FROM PERSON_RT;
      SET @alter_statement = concat('ALTER TABLE PERSON_RT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
 
      SELECT @max := IFNULL(MAX(AWARD_HOURS_LOG_ID),0)+1 FROM AWARD_HOURS_LOG_RT;
      SET @alter_statement = concat('ALTER TABLE AWARD_HOURS_LOG_RT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

	  SELECT @max := IFNULL(MAX(EXPENSE_TRACKER_ID),0)+1 FROM EXPENSE_TRACKER_RT;
      SET @alter_statement = concat('ALTER TABLE EXPENSE_TRACKER_RT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(LOGIN_DETAIL_ID),0)+1 FROM PERSON_LOGIN_DETAILS;
      SET @alter_statement = concat('ALTER TABLE PERSON_LOGIN_DETAILS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(MANPOWER_LOG_USER_ID),0)+1 FROM MANPOWER_LOG_USER;
      SET @alter_statement = concat('ALTER TABLE MANPOWER_LOG_USER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(WORKDAY_MANPOWER_INTERFACE_ID),0)+1 FROM WORKDAY_MANPOWER_INTERFACE;
      SET @alter_statement = concat('ALTER TABLE WORKDAY_MANPOWER_INTERFACE AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(BASE_SALARY_HISTORY_ID),0)+1 FROM MANPOWER_BASE_SALARY_HISTORY;
      SET @alter_statement = concat('ALTER TABLE MANPOWER_BASE_SALARY_HISTORY AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(MANPOWER_LOG_ID),0)+1 FROM MANPOWER_LOG;
      SET @alter_statement = concat('ALTER TABLE MANPOWER_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

      SELECT @max := IFNULL(MAX(WORKDAY_JOB_PROFILE_ID),0)+1 FROM WORKDAY_JOB_PROFILE_CHANGE;
      SET @alter_statement = concat('ALTER TABLE WORKDAY_JOB_PROFILE_CHANGE AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(LONG_LEAVE_ID),0)+1 FROM WORKDAY_LONG_LEAVE_DETAILS;
      SET @alter_statement = concat('ALTER TABLE WORKDAY_LONG_LEAVE_DETAILS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(WORKDAY_TERMINATION_ID),0)+1 FROM WORKDAY_TERMINATION_DETAILS;
      SET @alter_statement = concat('ALTER TABLE WORKDAY_TERMINATION_DETAILS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(MIGRATION_ATTCHMNT_ERROR_LOG_ID),0)+1 FROM MIGRATION_ATTACHMENT_ERROR_LOG;
      SET @alter_statement = concat('ALTER TABLE MIGRATION_ATTACHMENT_ERROR_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ATTACHMENT_ID),0)+1 FROM TEMP_ATTACHMENT_MIGRATION;
      SET @alter_statement = concat('ALTER TABLE TEMP_ATTACHMENT_MIGRATION AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(NOTIFICATION_LOG_RECIPIENT_ID),0)+1 FROM NOTIFICATION_LOG_RECIPIENT;
      SET @alter_statement = concat('ALTER TABLE NOTIFICATION_LOG_RECIPIENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(NOTIFICATION_RECIPIENT_ID),0)+1 FROM NOTIFICATION_RECIPIENT;
      SET @alter_statement = concat('ALTER TABLE NOTIFICATION_RECIPIENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(NOTIFICATION_LOG_ID),0)+1 FROM NOTIFICATION_LOG;
      SET @alter_statement = concat('ALTER TABLE NOTIFICATION_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ORCID_ERROR_LOG_ID),0)+1 FROM ORCID_ERROR_LOG;
      SET @alter_statement = concat('ALTER TABLE ORCID_ERROR_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ORCID_WEBHOOK_NOTIFY_LOG_ID),0)+1 FROM ORCID_WEBHOOK_NOTIFY_LOG;
      SET @alter_statement = concat('ALTER TABLE ORCID_WEBHOOK_NOTIFY_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ORCID_WORK_CONTRIBUTORS_ID),0)+1 FROM ORCID_WORK_CONTRIBUTOR;
      SET @alter_statement = concat('ALTER TABLE ORCID_WORK_CONTRIBUTOR AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ORCID_WORK_EXTERNAL_IDENTIFIER_ID),0)+1 FROM ORCID_WORK_EXTERNAL_IDENTIFIER;
      SET @alter_statement = concat('ALTER TABLE ORCID_WORK_EXTERNAL_IDENTIFIER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(PERSON_ORCID_WORK_ID),0)+1 FROM PERSON_ORCID_WORK;
      SET @alter_statement = concat('ALTER TABLE PERSON_ORCID_WORK AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(DELEGATION_ID),0)+1 FROM DELEGATIONS;
      SET @alter_statement = concat('ALTER TABLE DELEGATIONS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(PERSON_TRAINING_ID),0)+1 FROM PERSON_TRAINING;
      SET @alter_statement = concat('ALTER TABLE PERSON_TRAINING AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(TRAINING_ATTACHMENT_ID),0)+1 FROM PERSON_TRAINING_ATTACHMENT;
      SET @alter_statement = concat('ALTER TABLE PERSON_TRAINING_ATTACHMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(TRAINING_COMMENT_ID),0)+1 FROM PERSON_TRAINING_COMMENT;
      SET @alter_statement = concat('ALTER TABLE PERSON_TRAINING_COMMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ROLODEX_ID),0)+1 FROM ROLODEX;
      SET @alter_statement = concat('ALTER TABLE ROLODEX AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(CONG_DISTRICT_CODE),0)+1 FROM CONGRESSIONAL_DISTRICT;
      SET @alter_statement = concat('ALTER TABLE CONGRESSIONAL_DISTRICT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(VARIABLE_SECTION_ID),0)+1 FROM MODULE_VARIABLE_SECTION;
      SET @alter_statement = concat('ALTER TABLE MODULE_VARIABLE_SECTION AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(TASK_ID),0)+1 FROM TASK;
      SET @alter_statement = concat('ALTER TABLE TASK AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ACTION_LOG_ID),0)+1 FROM TASK_ACTION_LOG;
      SET @alter_statement = concat('ALTER TABLE TASK_ACTION_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ASSIGNEE_HISTORY_ID),0)+1 FROM TASK_ASSIGNEE_HISTORY;
      SET @alter_statement = concat('ALTER TABLE TASK_ASSIGNEE_HISTORY AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ATTACHMENT_ID),0)+1 FROM TASK_ATTACHMENT;
      SET @alter_statement = concat('ALTER TABLE TASK_ATTACHMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(COMMENT_ID),0)+1 FROM TASK_COMMENTS;
      SET @alter_statement = concat('ALTER TABLE TASK_COMMENTS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	   SELECT @max := IFNULL(MAX(ATTACHMENT_ID),0)+1 FROM TASK_COMMENT_ATTACHMENT;
      SET @alter_statement = concat('ALTER TABLE TASK_COMMENT_ATTACHMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(STATUS_HISTORY_ID),0)+1 FROM TASK_STATUS_HISTORY;
      SET @alter_statement = concat('ALTER TABLE TASK_STATUS_HISTORY AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(TRIAGE_HEADER_ID),0)+1 FROM TRIAGE_HEADER;
      SET @alter_statement = concat('ALTER TABLE TRIAGE_HEADER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(TRIAGE_TEMPLATE_ID),0)+1 FROM TRIAGE_TEMPLATE_MAPPING;
      SET @alter_statement = concat('ALTER TABLE TRIAGE_TEMPLATE_MAPPING AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(ATTACHMENT_ID),0)+1 FROM WORKFLOW_ATTACHMENT;
      SET @alter_statement = concat('ALTER TABLE WORKFLOW_ATTACHMENT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
	  SELECT @max := IFNULL(MAX(WORKFLOW_DETAIL_EXT_ID),0)+1 FROM WORKFLOW_DETAIL_EXT;
      SET @alter_statement = concat('ALTER TABLE WORKFLOW_DETAIL_EXT AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
      
      SELECT @max := IFNULL(MAX(AWARD_AMOUNT_TRANSACTION_ID),0)+ 1 FROM AWARD_AMOUNT_TRANSACTION;
      SET @alter_statement = concat('ALTER TABLE AWARD_AMOUNT_TRANSACTION AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

      SELECT @max := IFNULL(MAX(AWARD_SCOPUS_ID),0)+1 FROM AWARD_SCOPUS;
      SET @alter_statement = concat('ALTER TABLE AWARD_SCOPUS AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

      SELECT @max := IFNULL(MAX(ORCID_WEBHOOK_NOTIFY_LOG_ID),0)+1 FROM ORCID_WEBHOOK_NOTIFY_LOG;
      SET @alter_statement = concat('ALTER TABLE ORCID_WEBHOOK_NOTIFY_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

      SELECT @max := IFNULL(MAX(PERSON_ORCID_WORK_ID),0)+1 FROM PERSON_ORCID_WORK;
      SET @alter_statement = concat('ALTER TABLE PERSON_ORCID_WORK AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
      SELECT @max := IFNULL(MAX(ORCID_ERROR_LOG_ID),0)+1 FROM ORCID_ERROR_LOG;
      SET @alter_statement = concat('ALTER TABLE ORCID_ERROR_LOG AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

      SELECT @max := IFNULL(MAX(BUDGET_HEADER_ID),0)+1 FROM AWARD_BUDGET_HEADER;
      SET @alter_statement = concat('ALTER TABLE AWARD_BUDGET_HEADER AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;

      SELECT @max := IFNULL(MAX(BUDGET_PERIOD_ID),0)+1 FROM AWARD_BUDGET_PERIOD;
      SET @alter_statement = concat('ALTER TABLE AWARD_BUDGET_PERIOD AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
	  
      SELECT @max := IFNULL(MAX(BUDGET_DETAILS_ID),0)+1 FROM AWARD_BUDGET_DETAIL;
      SET @alter_statement = concat('ALTER TABLE AWARD_BUDGET_DETAIL AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt;
      
      /* SELECT @max := IFNULL(MAX(PERSON_AFFLIATION_ID),0)+1 FROM PERSON_AFFLIATION;
      SET @alter_statement = concat('ALTER TABLE PERSON_AFFLIATION AUTO_INCREMENT = ', @max);
      PREPARE stmt FROM @alter_statement;
      EXECUTE stmt; */

      DEALLOCATE PREPARE stmt;
END
