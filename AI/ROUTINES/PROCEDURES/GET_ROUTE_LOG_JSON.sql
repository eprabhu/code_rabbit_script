CREATE PROCEDURE `GET_ROUTE_LOG_JSON`(
    IN AV_MODULE_CODE INT,
    IN AV_MODULE_ITEM_ID INT,
    OUT ROUTE_LOG JSON
)
BEGIN
    SELECT JSON_OBJECT(
        'workflowDetails',
            (
                SELECT JSON_ARRAYAGG(map_obj)
                FROM (
                    SELECT JSON_OBJECT(
                        'mapName', wd.MAP_NAME,
                        'mapNumber', wd.MAP_NUMBER,
                        'mapDescription', wd.MAP_DESCRIPTION,
                        'stops',
                                (
                                    SELECT JSON_ARRAYAGG(stop_obj)
                                    FROM (
                                        SELECT JSON_OBJECT(
                                            'stopNumber', ws.APPROVAL_STOP_NUMBER,
                                            'stopName', ws.STOP_NAME,
                                            'approvers',
                                                (
                                                    SELECT JSON_ARRAYAGG(
                                                        JSON_OBJECT(
                                                            'primaryApprover', wa.APPROVER_PERSON_NAME,
                                                            'approvalStatusCode', wa.APPROVAL_STATUS,
                                                            'approvalStatus', ws2.DESCRIPTION,
                                                            'approvalDate', IF(wa.APPROVAL_DATE IS NOT NULL, wa.APPROVAL_DATE, NULL),
                                                            'actualApprover', IF(wa.APPROVAL_DATE IS NOT NULL, p.FULL_NAME, NULL)
                                                        )
                                                    )
                                                    FROM WORKFLOW_DETAIL wa
                                                    LEFT JOIN WORKFLOW_STATUS ws2
                                                            ON wa.APPROVAL_STATUS = ws2.APPROVAL_STATUS
                                                    LEFT JOIN PERSON p
                                                            ON wa.UPDATE_USER = p.USER_NAME
                                                    WHERE wa.WORKFLOW_ID = ws.WORKFLOW_ID
                                                        AND wa.MAP_NUMBER = ws.MAP_NUMBER
                                                        AND wa.APPROVAL_STOP_NUMBER = ws.APPROVAL_STOP_NUMBER
                                                )
                                        ) AS stop_obj
                                        FROM WORKFLOW_DETAIL ws
                                        WHERE ws.WORKFLOW_ID = wd.WORKFLOW_ID
                                            AND ws.MAP_NUMBER = wd.MAP_NUMBER
                                        GROUP BY ws.APPROVAL_STOP_NUMBER
                                    ) stop_sub
                                ),
                            'mapStatusCode',
                            (
                                SELECT CASE
                                    WHEN SUM(wa.APPROVAL_STATUS IN ('R','J')) > 0 THEN 'R'
                                    WHEN SUM(wa.APPROVAL_STATUS = 'C') > 0 THEN 'C'
                                    WHEN SUM(wa.APPROVAL_STATUS = 'X') > 0 THEN 'X'
                                    WHEN SUM(wa.APPROVAL_STATUS = 'W') > 0 THEN 'W'
                                    WHEN SUM(wa.APPROVAL_STATUS = 'T') > 0 THEN 'T'
                                    WHEN SUM(wa.APPROVAL_STATUS IN ('A','O','B','K')) > 0 THEN 'A'
                                    ELSE ''
                                END
                                FROM WORKFLOW_DETAIL wa
                                WHERE wa.WORKFLOW_ID = wd.WORKFLOW_ID
                                AND wa.MAP_NUMBER = wd.MAP_NUMBER
                                AND wa.PRIMARY_APPROVER_FLAG = 'Y'
                            )
                    ) AS map_obj
                    FROM WORKFLOW_DETAIL wd
                    WHERE wd.WORKFLOW_ID = w.WORKFLOW_ID
                    GROUP BY wd.MAP_NUMBER
                ) map_sub
            )
    ) INTO ROUTE_LOG
    FROM WORKFLOW w
    WHERE w.MODULE_CODE = AV_MODULE_CODE
        AND w.MODULE_ITEM_ID = AV_MODULE_ITEM_ID
        AND w.IS_WORKFLOW_ACTIVE = 'Y';
END
