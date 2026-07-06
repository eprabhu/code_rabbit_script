CREATE PROCEDURE `GET_DASHBOARD_DETAILS`(
    IN AV_MODULE_CODE INT,
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

WITH MY_TABS AS (
        SELECT T1.TAB_TYPE_ID, T1.DISPLAY_NAME, T1.TAB_KEY,T1.SOURCE_TAB_ID,
        COALESCE(T2.SORT_ORDER, T1.DEFAULT_SORT_ORDER) AS SORT_ORDER,
        COALESCE(T2.IS_PRIMARY_TAB, T1.DEFAULT_IS_PRIMARY_TAB) AS IS_PRIMARY_TAB,
        T1.IS_AUTO_SEARCH,
        T1.PERSON_ID
        FROM DASHBOARD_TAB_TYPE  T1
        LEFT JOIN dashboard_tab_preference T2 ON T2.TAB_TYPE_ID = T1.TAB_TYPE_ID AND T2.PERSON_ID = AV_PERSON_ID
        WHERE T1.MODULE_CODE = AV_MODULE_CODE AND T1.IS_ACTIVE = 'Y' AND (T1.PERSON_ID IS NULL OR T1.PERSON_ID = AV_PERSON_ID)
     )
    SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'tabId', MT.TAB_TYPE_ID,
                    'sourceTabId', MT.SOURCE_TAB_ID,
                    'tabName', MT.DISPLAY_NAME,
                    'tabKey', MT.TAB_KEY,
                    'sortOrder', MT.SORT_ORDER,
                    'isPrimaryTab', MT.IS_PRIMARY_TAB,
                    'isAutoSearch',MT.IS_AUTO_SEARCH,
                    'personId',MT.PERSON_ID
                )
            ) as tabList
            FROM MY_TABS MT;

    END main_proc;
END
