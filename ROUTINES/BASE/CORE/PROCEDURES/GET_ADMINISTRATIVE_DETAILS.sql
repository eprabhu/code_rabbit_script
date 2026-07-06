-- `GET_ADMINISTRATIVE_DETAILS`; 

CREATE PROCEDURE `GET_ADMINISTRATIVE_DETAILS`(AD_TYPE VARCHAR(500) )
BEGIN
DECLARE TAB_QUERY LONGTEXT;
IF AD_TYPE = 'ROLE_MASTER_DATA' THEN
	SET TAB_QUERY = CONCAT('SELECT ROLE_NAME, STATUS, CREATED_BY, CREATED_ON, UPDATED_BY, UPDATED_ON FROM
	(SELECT "Role Name" as ROLE_NAME , "Status" as STATUS, "Created By" as CREATED_BY, "Created On" as CREATED_ON, "Updated By" as UPDATED_BY, "Updated On" as UPDATED_ON, 1 AS SORT_ORDER UNION
							(SELECT TRIM(t1.ROLE_NAME),t1.STATUS_FLAG,IFNULL(t2.FULL_NAME,t1.CREATE_USER) as CREATE_USER ,CONVERT_TZ(t1.CREATE_TIMESTAMP,''+00:00'',''+8:00'') AS CREATE_TIMESTAMP,
							IFNULL(t3.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER,CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, 2 AS SORT_ORDER
							FROM role t1 left outer join person t2 on t1.CREATE_USER = t2.USER_NAME
							left outer join person t3 on t1.UPDATE_USER = t3.USER_NAME
							 ) ORDER BY SORT_ORDER,1)Z');
    
ELSEIF AD_TYPE = 'ROLE_RIGHT_MAPPING' THEN
    SET TAB_QUERY = CONCAT('SELECT ROLE_NAME, RIGHT_NAME, UPDATED_BY, UPDATED_ON FROM
    (SELECT "Role Name" as ROLE_NAME, "Right Name" as RIGHT_NAME, "Updated By"as UPDATED_BY, "Updated On"as UPDATED_ON, 1 AS SORT_ORDER UNION
							(SELECT TRIM(t2.ROLE_NAME),TRIM(t3.RIGHT_NAME), IFNULL(t4.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, 2 AS SORT_ORDER
							FROM role_rights t1 inner join role t2 on t1.ROLE_ID = t2.ROLE_ID
							inner join rights t3 on t1.RIGHT_ID = t3.RIGHT_ID
							left outer join person t4 on t1.UPDATE_USER = t4.USER_NAME
							) ORDER BY SORT_ORDER,1,2)Z'); 
ELSEIF AD_TYPE = 'PERSON_ROLE_ASSIGNMENT' THEN
	SET TAB_QUERY = CONCAT('SELECT USER_NAME, FULL_NAME, EMAIL_ADDRESS, PERSON_STATUS_ACTIVE, PERSON_INACTIVE_DATE, HOME_UNIT, UNIT_NAME, ROLE_NAME, DESCEND_FLAG, UPDATE_USER, UPDATE_TIMESTAMP FROM
    (SELECT "Username" as USER_NAME, 
            "Full Name" AS FULL_NAME, 
            "Email Address" AS EMAIL_ADDRESS, 
            "Person Status Active" AS PERSON_STATUS_ACTIVE, 
            "Person Inactive Date" AS PERSON_INACTIVE_DATE, 
            "Home Unit" AS HOME_UNIT, 
            "Unit Name" AS UNIT_NAME, 
            "Role Name" AS ROLE_NAME, 
            "Descend Flag" AS DESCEND_FLAG, 
            "Updated By" AS UPDATE_USER, 
            "Updated On" AS UPDATE_TIMESTAMP, 
            1 AS SORT_ORDER 
    UNION
    (SELECT DISTINCT t2.USER_NAME, 
            TRIM(t2.FULL_NAME) AS FULL_NAME, 
            t2.EMAIL_ADDRESS, 
            IF(t2.STATUS = "A", "Active", "Inactive") AS PERSON_STATUS_ACTIVE,
            DATE(t2.DATE_WHEN_PERSON_INACTIVE) AS PERSON_INACTIVE_DATE, 
            t6.UNIT_NAME AS HOME_UNIT, 
            t3.UNIT_NAME, 
            t4.ROLE_NAME, 
            t1.DESCEND_FLAG,
            IFNULL(t5.FULL_NAME, t1.UPDATE_USER) AS UPDATE_USER, 
            CONVERT_TZ(t1.UPDATE_TIMESTAMP, ''+00:00'', ''+8:00'') AS UPDATE_TIMESTAMP, 
            2 AS SORT_ORDER
    FROM person_roles t1 
    INNER JOIN person t2 ON t1.PERSON_ID = t2.PERSON_ID
    INNER JOIN unit t3 ON t3.UNIT_NUMBER = t1.UNIT_NUMBER
    INNER JOIN role t4 ON t4.ROLE_ID = t1.ROLE_ID
    LEFT OUTER JOIN person t5 ON t1.UPDATE_USER = t5.USER_NAME
    LEFT OUTER JOIN unit t6 ON t6.UNIT_NUMBER = t2.HOME_UNIT
    ) 
    ORDER BY SORT_ORDER, 2) Z ');
                             
ELSEIF AD_TYPE = 'UNIT_HIERARCHY' THEN
	SET TAB_QUERY = CONCAT('SELECT UNIT_NUMBER, UNIT_NAME, PARENT_UNIT_NUMBER, PARENT_UNIT_NAME, IS_ACTIVE, UPDATED_BY, UPDATED_ON FROM
	(SELECT "Unit Number" as UNIT_NUMBER, "Unit Name" as UNIT_NAME, "Parent Unit Number" as PARENT_UNIT_NUMBER, "Parent Unit Name" as PARENT_UNIT_NAME, "Is Active" as IS_ACTIVE, "Updated By" as UPDATED_BY, "Updated On" as UPDATED_ON, 1 AS SORT_ORDER UNION
							(select t1.UNIT_NUMBER,TRIM(t1.UNIT_NAME),t1.PARENT_UNIT_NUMBER,t2.UNIT_NAME as PARENT_UNIT_NAME,
							t1.IS_ACTIVE,IFNULL(t4.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER,t1.UPDATE_TIMESTAMP as UPDATE_TIMESTAMP, 2 AS SORT_ORDER
							from unit t1 left outer join unit t2 on t1.PARENT_UNIT_NUMBER = t2.UNIT_NUMBER
							left outer join person t4 on t1.UPDATE_USER = t4.USER_NAME
							) ORDER BY SORT_ORDER, 2)Z');
                            
ELSEIF AD_TYPE = 'UNIT_ADMINISTRATOR_HOD' THEN
		SET TAB_QUERY = CONCAT('SELECT UNIT_NUMBER, UNIT_NAME, UNIT_ADMINISTRATOR_TYPE, ADMIN_FULL_NAME, HAS_HOD_ROLE_IN_RISE, UPDATED_BY, UPDATED_ON FROM
		(SELECT "Unit Number" as UNIT_NUMBER, "Unit Name"as UNIT_NAME, "Unit Administrator Type"as UNIT_ADMINISTRATOR_TYPE, "Admin Full Name"as ADMIN_FULL_NAME, "Has HOD Role in Rise"as HAS_HOD_ROLE_IN_RISE, "Updated By"as UPDATED_BY, "Updated On"as UPDATED_ON, 1 AS SORT_ORDER UNION
							(select t1.UNIT_NUMBER, TRIM(t4.UNIT_NAME), t2.DESCRIPTION AS UNIT_ADMINISTRATOR_TYPE, t3.FULL_NAME as ADMIN_FULL_NAME,
							CASE WHEN ( select count(*) from person_roles s1 where s1.PERSON_ID = t1.PERSON_ID
							and s1.UNIT_NUMBER = t1.UNIT_NUMBER and s1.ROLE_ID = 400) > 0 Then ''Y'' else ''N''
							END as HAS_HOD_ROLE_RISE, IFNULL(t5.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, 2 AS SORT_ORDER
							from unit_administrator t1 inner join unit_administrator_type t2 on t1.UNIT_ADMINISTRATOR_TYPE_CODE = t2.UNIT_ADMINISTRATOR_TYPE_CODE
							inner join person t3 on t1.PERSON_ID = t3.PERSON_ID inner join unit t4 on t4.UNIT_NUMBER = t1.UNIT_NUMBER
							left outer join person t5 on t1.UPDATE_USER = t5.USER_NAME ) ORDER BY SORT_ORDER,2)Z');
ELSEIF AD_TYPE = 'BUDGET_COST_ELEMENT_MASTER_DATA' THEN
	SET TAB_QUERY = CONCAT('SELECT COST_ELEMENT_CODE, COST_ELEMENT, BUDGET_CATEGORY_CODE, UPDATED_BY, UPDATED_ON FROM
	(SELECT "Cost Element Code"as COST_ELEMENT_CODE, "Cost Element"as COST_ELEMENT, "Budget Category Code"as BUDGET_CATEGORY_CODE, "Updated By"as UPDATED_BY, "Updated On"as UPDATED_ON, 1 AS SORT_ORDER UNION
							(select TRIM(t1.COST_ELEMENT) as COST_ELEMENT_CODE, t1.DESCRIPTION as COST_ELEMENT , t1.BUDGET_CATEGORY_CODE,
							IFNULL(t4.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, 2 AS SORT_ORDER
							from cost_element t1 left outer join person t4 on t1.UPDATE_USER = t4.USER_NAME
							) ORDER BY SORT_ORDER,1)Z');
                            
ELSEIF AD_TYPE = 'ROLODEX_MASTER_DATA' THEN
	SET TAB_QUERY = CONCAT('SELECT ROLODEX_ID, FULL_NAME, EMAIL_ADDRESS, ORGANIZATION_NAME, OWNED_BY_UNIT, CREATED_BY, UPDATED_BY, UPDATED_ON FROM
	(SELECT "Rolodex id#"as ROLODEX_ID,"Full Name"as FULL_NAME, "Email Address"as EMAIL_ADDRESS, "Organization Name"as ORGANIZATION_NAME, "Owned by Unit"as OWNED_BY_UNIT,"Created By"as CREATED_BY, "Updated By"as UPDATED_BY, "Updated On"as UPDATED_ON, 1 AS SORT_ORDER UNION
							(SELECT ROLODEX_ID, TRIM(rolodex.FULL_NAME) ,rolodex.EMAIL_ADDRESS,organization.ORGANIZATION_NAME,unit.UNIT_NAME as  OWNED_BY_UNIT,
                            rolodex.CREATE_USER,
							IFNULL(t5.FULL_NAME, rolodex.UPDATE_USER) as UPDATE_USER, CAST(rolodex.UPDATE_TIMESTAMP AS DATE) AS UPDATE_TIMESTAMP, 2 AS SORT_ORDER
							FROM rolodex left outer join organization on rolodex.ORGANIZATION = organization.ORGANIZATION_ID
							left outer join unit on rolodex.OWNED_BY_UNIT = unit.UNIT_NUMBER
							left outer join person t5 on rolodex.UPDATE_USER = t5.USER_NAME) ORDER BY SORT_ORDER ,2)Z');
ELSEIF AD_TYPE = 'SPONSOR_MASTER_DATA' THEN
		SET TAB_QUERY = CONCAT('SELECT SPONSOR_CODE, SPONSOR_NAME, ACRONYM, SPONSOR_TYPE, ROLODEX_FULL_NAME, OWNED_UNIT_NAME, ADDRESS_LINE_1, ADDRESS_LINE_2, ADDRESS_LINE_3, EMAIL_ADDRESS, COUNTRY_NAME, CREATED_BY, UPDATED_BY, UPDATED_ON FROM
		(SELECT "Sponsor Code"as SPONSOR_CODE, "Sponsor Name"as SPONSOR_NAME, "Acronym"as ACRONYM, "Sponsor Type"as SPONSOR_TYPE, "Rolodex Full Name"as ROLODEX_FULL_NAME, "Owned Unit Name"as OWNED_UNIT_NAME,
							"Address Line 1"as ADDRESS_LINE_1, "Address Line 2"as ADDRESS_LINE_2, "Address Line 3"as ADDRESS_LINE_3, "Email Address"as EMAIL_ADDRESS, "Country Name"as COUNTRY_NAME, "Created By"as CREATED_BY, "Updated By"as UPDATED_BY, "Updated On"as UPDATED_ON, 1 AS  SORT_ORDER UNION
							(SELECT sponsor.SPONSOR_CODE,TRIM(sponsor.SPONSOR_NAME),sponsor.ACRONYM, sponsor_type.DESCRIPTION as SPONSOR_TYPE,
							rolodex.FULL_NAME as ROLODEX_FULL_NAME,unit.UNIT_NAME as OWNED_UNIT_NAME,
							sponsor.ADDRESS_LINE_1,sponsor.ADDRESS_LINE_2,sponsor.ADDRESS_LINE_3,
							sponsor.EMAIL_ADDRESS,country.COUNTRY_NAME, sponsor.CREATE_USER , IFNULL(t5.FULL_NAME, sponsor.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(sponsor.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, 2 AS SORT_ORDER
							FROM sponsor left outer join sponsor_type on sponsor_type.SPONSOR_TYPE_CODE = sponsor.SPONSOR_TYPE_CODE
							left outer join rolodex on rolodex.ROLODEX_ID = sponsor.ROLODEX_ID left outer join unit on unit.UNIT_NUMBER = sponsor.OWNED_BY_UNIT
							left outer join country on sponsor.COUNTRY_CODE = country.COUNTRY_CODE left outer join person t5 on sponsor.UPDATE_USER = t5.USER_NAME
							)ORDER BY SORT_ORDER,2)Z');
							
ELSEIF AD_TYPE = 'ORGANIZATION_MASTER_DATA' THEN
	SET TAB_QUERY = CONCAT('SELECT ORGANIZATION_ID, ORGANIZATION_NAME, VENDOR_CODE, COUNTRY_CODE, IS_ACTIVE, UPDATED_BY, UPDATED_ON FROM
	(SELECT "Organization Id#" as ORGANIZATION_ID, "Organization Name"  as ORGANIZATION_NAME, "Vendor Code" as VENDOR_CODE, "Country Code" as COUNTRY_CODE, "Is Active" as IS_ACTIVE, "Updated By" as UPDATED_BY, "Updated On" as UPDATED_ON, 1 AS SORT_ORDER UNION
							(select t1.ORGANIZATION_ID,TRIM(t1.ORGANIZATION_NAME), t1.VENDOR_CODE, country.COUNTRY_NAME, t1.IS_ACTIVE,
							IFNULL(t5.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, 2 AS SORT_ORDER from organization t1
							left outer join country on t1.COUNTRY_CODE = country.COUNTRY_CODE left outer join person t5 on t1.UPDATE_USER = t5.USER_NAME
							) ORDER BY SORT_ORDER,2)Z');
							
ELSEIF AD_TYPE = 'MANPOWER_BASE_SALARY_ACCESS' THEN
		
	SET TAB_QUERY = CONCAT('select 
							z.MANPOWER_LOG_USER_ID, z.AWARD_NUMBER, z.ACCOUNT_NUMBER, z.PERSON_ID,z.UPDATE_TIMESTAMP,
							z.UPDATE_USER, z.LOGIN_PERSON_ID, z.FULL_NAME, z.ACCESS_STATUS
							from
							(
							SELECT 2 as sort_order,  "Manpower Log User Id#" as MANPOWER_LOG_USER_ID, "Award Number" as AWARD_NUMBER, "Account Number"as ACCOUNT_NUMBER, 
							"Person Id#" as PERSON_ID , "Updated On" as UPDATE_TIMESTAMP, "Updated By" as UPDATE_USER, "Login Person Id#" as LOGIN_PERSON_ID,
							 "Login Person Name" as FULL_NAME, "Access Status"  as ACCESS_STATUS
							 UNION
								(select 1 as sort_order, t1.MANPOWER_LOG_USER_ID, t1.AWARD_NUMBER, t1.ACCOUNT_NUMBER, t1.PERSON_ID,CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, t1.UPDATE_USER, t1.LOGIN_PERSON_ID, t2.FULL_NAME, t1.ACCESS_STATUS
								from manpower_log_user t1 left outer join person t2 on t1.LOGIN_PERSON_ID = t2.PERSON_ID 
								WHERE t1.UPDATE_TIMESTAMP >= (DATE_ADD(utc_timestamp(),INTERVAL -1 YEAR))
								order by t1.UPDATE_TIMESTAMP desc
								) order by sort_order desc, 6 desc
							) z');
ELSEIF AD_TYPE = 'PERSON_LOGIN_DATA' THEN
	SET TAB_QUERY = CONCAT('
					SELECT  PERSON_ID, USER_ID, FULL_NAME, HOME_UNIT,TRIM(LOGIN_DATE),
                       IS_FACULTY,STUDENT_STAFF,RESEARCH_STAFF,SUPPORT_STAFF,IS_CONTINGENCY, IS_EXTERNAL
                       FROM 
					   (SELECT  1 as SORT_ORDER,"Person Id" AS PERSON_ID, "User Id" AS USER_ID, "Full Name" AS FULL_NAME, "Home unit" AS HOME_UNIT, "Last login Datetime" AS LOGIN_DATE,
                       "Is Faculty" AS IS_FACULTY,"Is Graduate Student Staff" AS STUDENT_STAFF,"Is Research Staff" AS RESEARCH_STAFF,"Is Support Staff" AS SUPPORT_STAFF,"Is Contingency" AS IS_CONTINGENCY, "Is External User" AS IS_EXTERNAL
                       UNION
							( SELECT
                            2 AS SORT_ORDER,
							t1.PERSON_ID,
							t1.USER_NAME,
							t1.FULL_NAME,
							t2.UNIT_NAME as HOME_UNIT,
							(
									select CONVERT_TZ(s1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'')
									from person_login_details s1
									where s1.PERSON_ID = t1.person_id
									and s1.LOGIN_STATUS = ''IN''
									and  s1.LOGIN_DETAIL_ID = (select max(s2.LOGIN_DETAIL_ID) from person_login_details s2
																where s2.PERSON_ID = t1.person_id
																and s2.LOGIN_STATUS = ''IN'')
							) as LAST_LOGIN_DATE_TIME,
                            t1.IS_FACULTY,
							t1.IS_GRADUATE_STUDENT_STAFF,
                            IS_RESEARCH_STAFF,
							t1.IS_SUPPORT_STAFF,
							t1.IS_MEDICAL_STAFF,
							t1.IS_EXTERNAL_USER
							FROM PERSON t1
							LEFT OUTER JOIN UNIT t2 on t1.HOME_UNIT = t2.UNIT_NUMBER
							WHERE t1.STATUS = ''A''
                            ) ORDER BY SORT_ORDER,6)Z
                            ');
ELSEIF AD_TYPE = 'ROLE_RIGHT_AUDIT_LOG' THEN
SET TAB_QUERY = CONCAT('SELECT ACTION, TABLE_NAME, ROLE_NAME, RIGHT_NAME, UPDATED_ON, UPDATED_BY FROM
(SELECT "Action" as ACTION, "Table Name" as TABLE_NAME, "Role Name" as ROLE_NAME, "Right Name" as RIGHT_NAME, "Updated On" as UPDATED_ON, "Updated By" as UPDATED_BY,1 AS SORT_ORDER UNION
							(select t.MODE,t.SOURCE, IFNULL(t.role_name, t2.ROLE_NAME)  as ROLE_NAME, t3.RIGHT_NAME, CONVERT_TZ(t.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, t7.FULL_NAME, 2 AS SORT_ORDER
from (SELECT t1.MODE,t1.SOURCE,
IFNULL(t1.OLD_ROLE_ID, t1.NEW_ROLE_ID) as ROLE_ID,
IFNULL(t1.OLD_RIGHT_ID, t1.NEW_RIGHT_ID) as RIGHT_ID,
IFNULL(t1.OLD_PERSON_ID, t1.NEW_PERSON_ID) as PERSON_ID,
IFNULL(t1.OLD_UNIT_NUMBER, t1.NEW_UNIT_NUMBER) as UNIT_NUMBER,
IFNULL(t1.OLD_DESCEND_FLG, t1.NEW_DESCEND_FLG) as DESCEND_FLG,
t1.UPDATE_TIMESTAMP as UPDATE_TIMESTAMP,
IFNULL(t1.OLD_ROLE_NAME, t1.NEW_ROLE_NAME) as ROLE_NAME,
t1.UPDATE_USER, 3 AS SORT_ORDER
							FROM ROLE_RIGHTS_AUDIT_TAB t1) t
                            left outer join role t2 on t2.role_id = t.ROLE_ID
                            left outer join rights t3 on t3.right_id = t.RIGHT_ID
                            LEFT join person t7 on t7.USER_NAME = t.UPDATE_USER
                            WHERE T.SOURCE = ''ROLE_RIGHTS'')ORDER BY SORT_ORDER)Z');
ELSEIF AD_TYPE = 'MANPOWER_VIEW_BASE_SALARY_RIGHT_AUDIT_REPORT' THEN
	SET TAB_QUERY = CONCAT('SELECT  "Role Name", "Right Name", "Person Name","Unit Name", 
"Descend Flag", "Updated On" as UPDATE_TIMESTAMP, "Updated By" UNION ALL
(select * from (
							 SELECT distinct t.NEW_ROLE_NAME as role_name, t2.RIGHT_NAME, t5.FULL_NAME as PERSON_NAME, t4.unit_name,
t.NEW_DESCEND_FLG, CONVERT_TZ(t.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP,T7.FULL_NAME
FROM ROLE_RIGHTS_AUDIT_TAB t
inner join rights t2 on t2.RIGHT_NAME = ''MANPOWER_VIEW_BASE_SALARY''
inner join person_roles t6 on t.new_role_id = t6.role_id and t.NEW_PERSON_ID = t6.person_id
inner join unit t4 on t6.UNIT_NUMBER = t4.UNIT_NUMBER
inner join person t5 on t6.PERSON_ID = t5.PERSON_ID 
inner join person t7 on t7.user_name = t.update_user
where (t.new_role_id in (select distinct role_id from role_rights where right_id = t2.right_id)
and DATE_FORMAT(CONVERT_TZ(t6.UPDATE_TIMESTAMP,''+00:00'',''+8:00''), "%Y-%m-%d") =
DATE_FORMAT(DATE_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY), "%Y-%m-%d"))
and t.mode <> ''DELETE''
	-- for person role entry							
union 
SELECT distinct t.NEW_ROLE_NAME as role_name, t2.RIGHT_NAME, t5.FULL_NAME as PERSON_NAME, t4.unit_name,
t6.DESCEND_FLAG, CONVERT_TZ(t.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP,T7.FULL_NAME
FROM ROLE_RIGHTS_AUDIT_TAB t
inner join rights t2 on t2.RIGHT_NAME = ''MANPOWER_VIEW_BASE_SALARY''
inner join person_roles t6 on t.new_role_id = t6.role_id
inner join unit t4 on t6.UNIT_NUMBER = t4.UNIT_NUMBER
inner join person t5 on t6.PERSON_ID = t5.PERSON_ID 
inner join person t7 on t7.user_name = t.update_user
where t.new_right_id = t2.right_id 
and DATE_FORMAT(CONVERT_TZ(t.UPDATE_TIMESTAMP,''+00:00'',''+8:00''), "%Y-%m-%d") =
DATE_FORMAT(DATE_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY), "%Y-%m-%d")
and t.mode <> ''DELETE'' and t6.update_timestamp < t.UPDATE_TIMESTAMP
			-- for entries acheived by adding right to role				
union 
SELECT distinct t.NEW_ROLE_NAME as role_name, t2.RIGHT_NAME, t5.FULL_NAME as PERSON_NAME, t4.unit_name,
t.NEW_DESCEND_FLG, CONVERT_TZ(t.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP,T7.FULL_NAME
FROM ROLE_RIGHTS_AUDIT_TAB t
inner join rights t2 on t2.RIGHT_NAME = ''MANPOWER_VIEW_BASE_SALARY''
inner join role_rights t3 on t2.RIGHT_id= t3.right_id
inner join person t7 on t7.user_name = t.update_user
inner join person t5 on t.NEW_PERSON_ID = t5.PERSON_ID 
inner join unit t4 on t.new_UNIT_NUMBER = t4.UNIT_NUMBER
where t.NEW_ROLE_ID = t3.role_id 
and DATE_FORMAT(CONVERT_TZ(t.UPDATE_TIMESTAMP,''+00:00'',''+8:00''), "%Y-%m-%d") =
DATE_FORMAT(DATE_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY), "%Y-%m-%d")
and t.mode <> ''DELETE'' 
-- for entries that are not present in person roles
union
SELECT distinct t.NEW_ROLE_NAME as role_name, t2.RIGHT_NAME, t5.FULL_NAME as PERSON_NAME, t4.unit_name,
t.NEW_DESCEND_FLG, CONVERT_TZ(t.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP,T7.FULL_NAME
FROM ROLE_RIGHTS_AUDIT_TAB t
inner join rights t2 on t2.RIGHT_NAME = ''MANPOWER_VIEW_BASE_SALARY''
inner join person t7 on t7.user_name = t.update_user
inner join person t5 on t.NEW_PERSON_ID = t5.PERSON_ID 
inner join unit t4 on t.new_UNIT_NUMBER = t4.UNIT_NUMBER
where t.NEW_ROLE_ID in (select new_role_id from ROLE_RIGHTS_AUDIT_TAB where new_right_id = t2.right_id and SOURCE = ''ROLE_RIGHTS'' and new_role_id not in (select role_id from role))
and DATE_FORMAT(CONVERT_TZ(t.UPDATE_TIMESTAMP,''+00:00'',''+8:00''), "%Y-%m-%d") =
DATE_FORMAT(DATE_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY), "%Y-%m-%d")
and t.mode <> ''DELETE''  ) a  ) order by UPDATE_TIMESTAMP   desc                  
             -- for entries that are not present in person role and role rights               
                      
                      ');     
                      
ELSEIF AD_TYPE = 'PERSON_ROLE_AUDIT_LOG' THEN
	SET TAB_QUERY = CONCAT('SELECT ACTION, TABLE_NAME, ROLE_NAME, PERSON_NAME, UNIT_NAME, OLD_DESCEND_FLAG, NEW_DESCEND_FLAG, UPDATED_ON, UPDATED_BY FROM
	(SELECT "Action" as ACTION, "Table Name" as TABLE_NAME, "Role Name" as ROLE_NAME, "Person Name" as PERSON_NAME,"Unit Name" as UNIT_NAME, 
"Old Descend Flag" as OLD_DESCEND_FLAG,"New Descend Flag" as NEW_DESCEND_FLAG, "Updated On" as UPDATED_ON, "Updated By" as UPDATED_BY, 1 AS SORT_ORDER  UNION
							(select t.MODE,t.SOURCE, IFNULL(t.role_name, t2.ROLE_NAME)  as ROLE_NAME, t5.FULL_NAME, t4.unit_name,
t.OLD_DESCEND_FLG, t.NEW_DESCEND_FLG, CONVERT_TZ(t.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, t7.FULL_NAME,2 AS SORT_ORDER
from (SELECT t1.MODE,t1.SOURCE,
IFNULL(t1.OLD_ROLE_ID, t1.NEW_ROLE_ID) as ROLE_ID,
IFNULL(t1.OLD_RIGHT_ID, t1.NEW_RIGHT_ID) as RIGHT_ID,
IFNULL(t1.OLD_PERSON_ID, t1.NEW_PERSON_ID) as PERSON_ID,
IFNULL(t1.OLD_UNIT_NUMBER, t1.NEW_UNIT_NUMBER) as UNIT_NUMBER,
t1.OLD_DESCEND_FLG AS OLD_DESCEND_FLG, 
t1.NEW_DESCEND_FLG as NEW_DESCEND_FLG,
t1.UPDATE_TIMESTAMP as UPDATE_TIMESTAMP,
IFNULL(t1.OLD_ROLE_NAME, t1.NEW_ROLE_NAME) as ROLE_NAME,
T1.UPDATE_USER
							FROM ROLE_RIGHTS_AUDIT_TAB t1) t
							left outer join role t2 on t2.role_id = t.ROLE_ID
                            inner join unit t4 on t.UNIT_NUMBER = t4.UNIT_NUMBER
							inner join person t7 on t7.USER_NAME = t.UPDATE_USER
                            inner join person t5 on t.PERSON_ID = t5.PERSON_ID where t.SOURCE = ''PER_ROLES'')ORDER BY SORT_ORDER,3)Z');
END IF;
SET @QUERY_STATEMENT = TAB_QUERY;
PREPARE EXECUTABLE_STAEMENT FROM @QUERY_STATEMENT;
EXECUTE EXECUTABLE_STAEMENT;
END
