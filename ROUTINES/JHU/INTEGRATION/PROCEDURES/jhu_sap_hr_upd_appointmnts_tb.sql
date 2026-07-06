CREATE PROCEDURE `jhu_sap_hr_upd_appointmnts_tb`(av_person_id  VARCHAR(40)
,av_unit_number  VARCHAR(10)
,av_appointment_start_date  VARCHAR(10)
,av_appointment_end_date  VARCHAR(10)
,av_job_title  VARCHAR(50)
,av_prefered_job_title  VARCHAR(51)
,av_appointment_type VARCHAR(30)
,av_job_code  VARCHAR(6)
,av_salary  DECIMAL(12,2)
,av_personnel_sub_area  VARCHAR(255)
,av_personnel_sub_group  VARCHAR(255)
,av_update_timestamp DATE)
BEGIN

DECLARE ls_unit_number VARCHAR(8) DEFAULT RTRIM(SUBSTR(av_unit_number, 1, 8));
DECLARE ls_primary_indicator VARCHAR(30) DEFAULT NULL;
DECLARE ld_appointment_start_date DATETIME DEFAULT STR_TO_DATE(av_appointment_start_date, '%m%d%Y');
DECLARE ld_appointment_end_date DATETIME DEFAULT STR_TO_DATE(av_appointment_end_date, '%m%d%Y');
DECLARE ls_job_title VARCHAR(50) DEFAULT RTRIM(SUBSTR(av_job_title, 1, 50));
DECLARE ls_prefered_job_title VARCHAR(51) DEFAULT RTRIM(SUBSTR(av_prefered_job_title, 1, 51));
DECLARE ls_appointment_type VARCHAR(30) DEFAULT '12M EMPLOYEE';
DECLARE ls_job_code VARCHAR(6) DEFAULT av_job_code;
DECLARE lI_salary DECIMAL(12,2) DEFAULT CAST(RTRIM(SUBSTR(av_salary, 3, 12))AS  DECIMAL(12,2));
DECLARE ls_home_unit VARCHAR(8) DEFAULT NULL;
DECLARE ls_action_performed VARCHAR(8) DEFAULT NULL;
DECLARE li_row_count int(3);
DECLARE ls_file_text LONGTEXT DEFAULT  '';
SET SQL_SAFE_UPDATES =0;

	IF av_personnel_sub_group = '21'
		OR av_personnel_sub_group = '06'
		OR av_personnel_sub_group = '6' THEN
	  SET ls_job_code = '999999';

		  UPDATE person p
		  SET p.primary_title = ls_appointment_type
			 ,p.directory_title = ls_appointment_type
			 ,p.directory_department = (SELECT SUBSTR(unit_name, 1, 30)
										FROM unit
										WHERE unit_number = p.home_unit)
		  WHERE p.person_id = av_person_id;

	ELSE

		  UPDATE person p
		  SET p.home_unit = ls_unit_number
			 ,p.directory_department = (SELECT SUBSTR(unit_name, 1, 30)
										FROM unit
										WHERE unit_number = ls_unit_number)
		  WHERE p.person_id = av_person_id
		  AND   p.home_unit = '000001';

	END IF;

	SELECT COUNT(*)
	INTO li_row_count
	FROM person
	WHERE person_id = av_person_id;

	IF li_row_count = 0
	THEN
              SET ls_file_text = CONCAT('Invalid Person ID');
	ELSE


			  SELECT home_unit
			  INTO ls_home_unit
			  FROM person
			  WHERE person_id = av_person_id;

			  IF ls_unit_number = ls_home_unit  THEN
				SET ls_primary_indicator = 'Primary';
			  ELSE
				SET ls_primary_indicator = 'Secondary';
			  END IF;


			  SET ls_action_performed = 'Insert';


			  DELETE FROM appointments
			  WHERE person_id = av_person_id
			  AND update_timestamp <> av_update_timestamp;

			DELETE FROM appointments
			WHERE person_id = av_person_id
			and unit_number = '000001'
			and primary_secondary_indicator = 'Primary'
			and appointment_start_date =  '1900-01-01 00:00:00'
			and appointment_end_date = '9999-12-31 00:00:00'
			and appointment_type = '12M EMPLOYEE'
			and job_code = '999999'
			and salary = '0.00'
			and update_user = 'COEUS';


			IF trim(ls_job_code) = '' or ls_job_code is NULL then
			set ls_job_code = '000000' ;
			end if;

			  INSERT INTO appointments (person_id
										   ,unit_number
										   ,primary_secondary_indicator
										   ,appointment_start_date
										   ,appointment_end_date
										   ,job_title
										   ,prefered_job_title
										   ,appointment_type
										   ,job_code
										   ,salary
										   ,update_timestamp
										   ,update_user)
			  VALUES (av_person_id
					 ,ls_unit_number
					 ,ls_primary_indicator
					 ,ld_appointment_start_date
					 ,ld_appointment_end_date
					 ,ls_job_title
					 ,ls_prefered_job_title
					 ,ls_appointment_type
					 ,ls_job_code
					 ,0
					 ,av_update_timestamp
					 ,'COEUS');

	END IF;


	IF ls_job_title IS NOT NULL THEN
	  UPDATE person
	  SET is_faculty = 'Y'
	  WHERE person_id = av_person_id;
	END IF;

  END
