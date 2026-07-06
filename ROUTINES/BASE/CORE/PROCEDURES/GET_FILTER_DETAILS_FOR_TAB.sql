CREATE PROCEDURE `GET_FILTER_DETAILS_FOR_TAB`(
    IN AV_MODULE_CODE INT,
    IN AV_TAB_ID INT,
    IN AV_PERSON_ID VARCHAR(40)
)
BEGIN

   -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @text = MESSAGE_TEXT;
        
        SELECT JSON_OBJECT(
            'success', FALSE,
            'error', JSON_OBJECT(
                'code', @errno,
                'sqlstate', @sqlstate,
                'message', @text
            )
        ) AS result;
    END;
    
main_proc: BEGIN

WITH 
	SOURCE_TABS AS (
		SELECT TAB_TYPE_ID, TAB_KEY FROM DASHBOARD_TAB_TYPE WHERE MODULE_CODE = AV_MODULE_CODE AND PERSON_ID IS NULL
    ),
    CUST_ELEMETS AS (
		SELECT T1.CUSTOM_DATA_ELEMENTS_ID FROM CUSTOM_DATA_ELEMENT_USAGE T1
        INNER JOIN CUSTOM_DATA_ELEMENTS T2 ON T1.CUSTOM_DATA_ELEMENTS_ID = T2.CUSTOM_DATA_ELEMENTS_ID
        WHERE T1.MODULE_CODE = AV_MODULE_CODE AND T1.IS_REQ_ADVANCE_SEARCH = 'Y' AND T2.IS_ACTIVE = 'Y'  
    ),
	MY_TABS AS (
        SELECT T1.TAB_TYPE_ID, T1.DISPLAY_NAME, T1.TAB_KEY,
        COALESCE(T2.SORT_ORDER, T1.DEFAULT_SORT_ORDER) AS SORT_ORDER,
        COALESCE(T2.IS_PRIMARY_TAB, T1.DEFAULT_IS_PRIMARY_TAB) AS IS_PRIMARY_TAB,
        T1.IS_AUTO_SEARCH,
        T1.SOURCE_TAB_ID,
        T3.TAB_TYPE_ID AS SOURCE_ID,
        COALESCE(T2.PAGE_LIMIT, 20) AS PAGE_LIMIT
        FROM DASHBOARD_TAB_TYPE  T1
        LEFT JOIN dashboard_tab_preference T2 ON T2.TAB_TYPE_ID = T1.TAB_TYPE_ID AND T2.PERSON_ID = AV_PERSON_ID
        INNER JOIN SOURCE_TABS T3 ON T3.TAB_KEY = T1.TAB_KEY
        WHERE T1.MODULE_CODE = AV_MODULE_CODE AND T1.IS_ACTIVE = 'Y' AND (T1.PERSON_ID IS NULL OR T1.PERSON_ID = AV_PERSON_ID)
        
     ),
     SELECTED_TAB AS (
        SELECT TAB_TYPE_ID, DISPLAY_NAME, TAB_KEY, SORT_ORDER, IS_PRIMARY_TAB, IS_AUTO_SEARCH, SOURCE_ID, SOURCE_TAB_ID, PAGE_LIMIT FROM MY_TABS WHERE ( AV_TAB_ID = 0 AND IS_PRIMARY_TAB = 'Y') OR (TAB_TYPE_ID = AV_TAB_ID)  LIMIT 1
     ),
     MY_FILTERS AS (
     SELECT FILTER_ID, FILTER_NAME, PERSON_ID, IS_CURRENT FROM dashboard_filter_preference WHERE MODULE_CODE = AV_MODULE_CODE
     AND (
     (TAB_TYPE_ID = (SELECT TAB_TYPE_ID FROM SELECTED_TAB LIMIT 1) AND (PERSON_ID IS NULL OR PERSON_ID = AV_PERSON_ID))
     OR
     (TAB_TYPE_ID = (SELECT SOURCE_ID FROM SELECTED_TAB LIMIT 1) AND PERSON_ID IS NULL)
     ) 	
     ),
     CURRENT_FILTER AS (
   SELECT FILTER_ID, FILTER_NAME, PERSON_ID, IS_CURRENT
   FROM MY_FILTERS
   ORDER BY
      CASE WHEN PERSON_ID IS NOT NULL AND IS_CURRENT = 'Y' THEN 1 ELSE 0 END DESC,
      CASE WHEN PERSON_ID IS NULL AND IS_CURRENT = 'Y' THEN 1 ELSE 0 END DESC,
      CASE WHEN PERSON_ID IS NULL THEN 1 ELSE 0 END DESC,
      FILTER_ID ASC 
   LIMIT 1
),
    CURRENT_CRITERIAS AS (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
            'filterCriteriaId',T2.FILTER_CRITERIA_ID,
            'criteriaId', T1.CRITERIA_ID,
            'criteriaKey', T1.CRITERIA_KEY,
            'value', CAST(T2.VALUE AS JSON),
            'sortOrder', COALESCE(T2.SORT_ORDER, T1.DEFAULT_SORT_ORDER)
            )
        ) AS criterias_json
        FROM dashboard_criteria_lookup T1
        INNER JOIN dashboard_filter_criteria T2 ON T1.CRITERIA_ID = T2.CRITERIA_ID
        WHERE T1.IS_ACTIVE = 'Y' AND T2.FILTER_ID = (SELECT FILTER_ID FROM CURRENT_FILTER)
        AND (T1.CUSTOM_DATA_ELEMENTS_ID IN (SELECT CUSTOM_DATA_ELEMENTS_ID FROM CUST_ELEMETS) OR T1.CUSTOM_DATA_ELEMENTS_ID IS NULL)
    ),
    CURRENT_COLUMNS AS (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
            'filterColumnId',T2.FILTER_COLUMN_ID,
                'columnId', T1.COLUMN_ID,
                'columnKey', T1.COLUMN_KEY,
                'displayName', T1.DISPLAY_NAME,
                'sortOrder', COALESCE(T2.SORT_ORDER, T1.DEFAULT_SORT_ORDER)
            )
        ) AS columns_json
        FROM dashboard_column_lookup T1
        INNER JOIN dashboard_filter_column T2 ON T1.COLUMN_ID = T2.COLUMN_ID
        WHERE T1.IS_ACTIVE = 'Y' AND T2.FILTER_ID = (SELECT FILTER_ID FROM CURRENT_FILTER)
        AND (T1.CUSTOM_DATA_ELEMENTS_ID IN (SELECT CUSTOM_DATA_ELEMENTS_ID FROM CUST_ELEMETS) OR T1.CUSTOM_DATA_ELEMENTS_ID IS NULL)
    )


            SELECT JSON_OBJECT(
                    'tabId', ST.TAB_TYPE_ID,
                    'sourceTabId', ST.SOURCE_TAB_ID,
                    'tabName', ST.DISPLAY_NAME,
                    'tabKey', ST.TAB_KEY,
                    'sortOrder', ST.SORT_ORDER,
                    'isPrimaryTab', ST.IS_PRIMARY_TAB,
                    'isAutoSearch',ST.IS_AUTO_SEARCH,
                    'pageLimit', ST.PAGE_LIMIT,
                    'currentFilter', JSON_OBJECT(
                                'filterId', (SELECT FILTER_ID FROM CURRENT_FILTER),
                                'filterName', (SELECT FILTER_NAME FROM CURRENT_FILTER),
                                'criterias', COALESCE((SELECT criterias_json FROM CURRENT_CRITERIAS), JSON_ARRAY()),
                                'columns', COALESCE((SELECT columns_json FROM CURRENT_COLUMNS), JSON_ARRAY()),
                                'personId',(SELECT PERSON_ID FROM CURRENT_FILTER),
                                'isCurrent', (SELECT CASE WHEN IS_CURRENT = 'Y' THEN 1 ELSE 0 END FROM CURRENT_FILTER)
                            ),
                    'filters', ((SELECT JSON_ARRAYAGG(JSON_OBJECT('filterId',FILTER_ID,'filterName',FILTER_NAME,'personId', PERSON_ID,'isCurrent', CASE WHEN IS_CURRENT = 'Y' THEN 1 ELSE 0 END)) FROM MY_FILTERS))
                ) as tabList
            FROM SELECTED_TAB ST;
    

    END main_proc;
    
END
