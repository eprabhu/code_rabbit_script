-- `INSERT_CRITERIA_MAPPING`; 

CREATE PROCEDURE `INSERT_CRITERIA_MAPPING`()
BEGIN
DECLARE LS_KPI_CRITERIA_TYPE_CODE VARCHAR(3);
DECLARE LS_KPI_TYPE_CODE VARCHAR(3);
DECLARE LS_tempate_table VARCHAR(50);
DECLARE NEXT_VAL VARCHAR(3);
BEGIN
DECLARE DONE1 INT DEFAULT FALSE;
	DECLARE CUR_CRITERIA CURSOR FOR
	SELECT
	KPI_CRITERIA_TYPE_CODE,
	KPI_TYPE_CODE
	FROM kpi_criteria_type;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
	OPEN CUR_CRITERIA;
	INSERT_CUR_MAPPING_LOOP: LOOP
	FETCH CUR_CRITERIA INTO
	LS_KPI_CRITERIA_TYPE_CODE,
	LS_KPI_TYPE_CODE;
		IF DONE1 THEN
		LEAVE INSERT_CUR_MAPPING_LOOP;
		END IF;
			select case when LS_KPI_CRITERIA_TYPE_CODE in ('5','1','4','3','2') then
			'ProgressReportKPIImpactPublications'
			when LS_KPI_CRITERIA_TYPE_CODE in ('51') then
			'ProgressReportKPISuccessfulStartups'
			when LS_KPI_CRITERIA_TYPE_CODE in ('57','56','55') then
			'ProgressReportKPIManpowerDevelopment'
			when LS_KPI_CRITERIA_TYPE_CODE in ('54','53','52') then
			'ProgressReportKPIManpowerDevelopment'
			when LS_KPI_CRITERIA_TYPE_CODE in ('61','58','60','62','59','77','73','74','75','76') then
			'ProgressReportKPIHealthSpecificOutcomes'
			when LS_KPI_CRITERIA_TYPE_CODE in ('72','6','7','8','9','11','10') then
			'ProgressReportKPICollaborationProjects'
			when LS_KPI_CRITERIA_TYPE_CODE in ('78','81') then
			'ProgressReportKPIConferencePresentation'
			when LS_KPI_CRITERIA_TYPE_CODE in ('70') then
			'ProgressReportKPICompetitiveGrants'
			when LS_KPI_CRITERIA_TYPE_CODE in ('80') then
			'ProgressReportKPIPostDocsEmployed'
			when LS_KPI_CRITERIA_TYPE_CODE in ('24','23','22','21','20','19') then
			'ProgressReportKPICashFunding'
			when LS_KPI_CRITERIA_TYPE_CODE in ('71','79','82','85','84') then
			'ProgressReportKPIGrantSpecific'
			when LS_KPI_CRITERIA_TYPE_CODE in ('30','29','28','27','26','25') then
			'ProgressReportKPIInkindContributions'
			when LS_KPI_CRITERIA_TYPE_CODE in ('35','31','32','33','34','36') then
			'ProgressReportKPITechnologiesDeployed'
			when LS_KPI_CRITERIA_TYPE_CODE in ('37') then
			'ProgressReportKPITechnologyDisclosure'
			when LS_KPI_CRITERIA_TYPE_CODE in ('38') then
			'ProgressReportKPIPatents'
			when LS_KPI_CRITERIA_TYPE_CODE in ('50','49','48','47','46','45') then
			'ProgressReportKPILicenses'
			when LS_KPI_CRITERIA_TYPE_CODE in ('44','43','42','41','40','39') then
			'ProgressReportKPILicenses'
            when LS_KPI_CRITERIA_TYPE_CODE in ('83') then
			'ProgressReportKPIUndergraduateStudent'
			end into LS_tempate_table from dual;
			select case when LS_KPI_CRITERIA_TYPE_CODE in ('5','1','4','3','2') then
			'1'
			when LS_KPI_CRITERIA_TYPE_CODE in ('51') then
			'10'
			when LS_KPI_CRITERIA_TYPE_CODE in ('57','56','55') then
			'4'
			when LS_KPI_CRITERIA_TYPE_CODE in ('54','53','52') then
			'4'
			when LS_KPI_CRITERIA_TYPE_CODE in ('61','58','60','62','59','77','73','74','75','76') then
			'11'
			when LS_KPI_CRITERIA_TYPE_CODE in ('72','6','7','8','9','11','10') then
			'2'
			when LS_KPI_CRITERIA_TYPE_CODE in ('78','81') then
			'6'
			when LS_KPI_CRITERIA_TYPE_CODE in ('70') then
			'7'
			when LS_KPI_CRITERIA_TYPE_CODE in ('80') then
			'12'
			when LS_KPI_CRITERIA_TYPE_CODE in ('24','23','22','21','20','19') then
			'14'
			when LS_KPI_CRITERIA_TYPE_CODE in ('71','79','82','85','84') then
			'13'
			when LS_KPI_CRITERIA_TYPE_CODE in ('30','29','28','27','26','25') then
			'15'
			when LS_KPI_CRITERIA_TYPE_CODE in ('35','31','32','33','34','36') then
			'16'
			when LS_KPI_CRITERIA_TYPE_CODE in ('37') then
			'3'
			when LS_KPI_CRITERIA_TYPE_CODE in ('38') then
			'8'
			when LS_KPI_CRITERIA_TYPE_CODE in ('50','49','48','47','46','45') then
			'9'
			when LS_KPI_CRITERIA_TYPE_CODE in ('44','43','42','41','40','39') then
			'9'
            when LS_KPI_CRITERIA_TYPE_CODE in ('83') then
			'5'
			end into NEXT_VAL from dual;
			INSERT INTO PROGRESS_REPORT_KPI_MAPPING(
			KPI_TYPE_CODE,
			KPI_CRITERIA_TYPE_CODE,
			TEMPLATE_TABLE,
			SECTION_CODE,
			IS_ACTIVE,
			UPDATE_TIMESTAMP,
			UPDATE_USER
			)
			VALUES
			(
			LS_KPI_TYPE_CODE,
			LS_KPI_CRITERIA_TYPE_CODE,
			LS_tempate_table,
			NEXT_VAL,
			'Y',
			NOW(),
			'admin'
			);
		END LOOP;
	CLOSE CUR_CRITERIA;
END;
END
