-- `GET_AWARD_REVENUE_TRANSACTIONS`; 

CREATE PROCEDURE `GET_AWARD_REVENUE_TRANSACTIONS`(
av_award_number varchar(12),
av_account_number varchar(100)
  )
    DETERMINISTIC
BEGIN
DECLARE LI_AWARD_ID INT;
SELECT AWARD_ID INTO  LI_AWARD_ID FROM AWARD T1
WHERE T1.AWARD_NUMBER = AV_AWARD_NUMBER
AND T1.AWARD_SEQUENCE_STATUS = 'ACTIVE';
IF LI_AWARD_ID IS NOT NULL THEN
SELECT
        S2.BUDGET_CATEGORY_CODE,
        S2.BUDGET_CATEGORY,
        S2.COST_ELEMENT,
        S2.LINE_ITEM,
        S2.IO_CODE,
        S2.QUANTITY,      
        S2.BUDGET_CATEGORY_TYPE_CODE,
        S2.SORT_ORDER,
        S2.BUDGET_DETAILS_ID,
        S2.UPDATE_TIMESTAMP,
        S2.STUDENT_HRS_FLAG,
        S2.IS_UNASSIGN_TRANSACTION
FROM
(SELECT
        DISTINCT
        T3.BUDGET_CATEGORY_CODE,
        T6.description AS BUDGET_CATEGORY,
        T3.COST_ELEMENT,
        T7.DESCRIPTION AS LINE_ITEM,
        T3.INTERNAL_ORDER_CODE AS IO_CODE,
        T3.QUANTITY,
        S1.LINE_ITEM_COST as ORIGINAL_APPROVED_BUDGET,
        T3.LINE_ITEM_COST as LATEST_APPROVED_BUDGET,
        CASE WHEN T6.BUDGET_CATEGORY_TYPE_CODE = 'P' AND T3.INTERNAL_ORDER_CODE IS NULL THEN
                          (
                                SELECT
                                SUM(E1.TOTAL_REVENUE_AMOUNT)
                                FROM AWARD_BUDGET_PERSON_DETAIL BP1
                                INNER JOIN AWARD_REVENUE_DETAILS E1 ON  BP1.IO_CODE = E1.INTERNAL_ORDER_CODE
                                WHERE  BP1.BUDGET_DETAILS_ID = T3.BUDGET_DETAILS_ID
                                AND T1.AWARD_NUMBER = E1.AWARD_NUMBER
                                AND T2.ACCOUNT_NUMBER = E1.ACCOUNT_NUMBER
                          )
        else
                T4.TOTAL_REVENUE_AMOUNT
        END AS EXPENDITURE_TO_DATE,
        T6.BUDGET_CATEGORY_TYPE_CODE,
        T6.SORT_ORDER,
    T3.BUDGET_DETAILS_ID,
        T2.UPDATE_TIMESTAMP ,
        case when T7.COST_ELEMENT = '4' then 'Y'
                 else
                        'N'
        end as STUDENT_HRS_FLAG,
    'N' AS IS_UNASSIGN_TRANSACTION
FROM AWARD_BUDGET_HEADER T1
LEFT OUTER JOIN AWARD_REVENUE_TRANSACTIONS T2 ON T1.AWARD_NUMBER = T2.AWARD_NUMBER AND T2.ACCOUNT_NUMBER = av_account_number
LEFT OUTER JOIN AWARD_BUDGET_PERIOD P1 ON T1.BUDGET_HEADER_ID = P1.BUDGET_HEADER_ID
LEFT OUTER JOIN AWARD_BUDGET_DETAIL T3 ON T3.BUDGET_PERIOD_ID = P1.BUDGET_PERIOD_ID
LEFT OUTER JOIN AWARD_REVENUE_DETAILS T4 ON T1.AWARD_NUMBER = T4.AWARD_NUMBER
 AND T2.ACCOUNT_NUMBER = T4.ACCOUNT_NUMBER
                                                                                 AND T3.INTERNAL_ORDER_CODE = T4.INTERNAL_ORDER_CODE
LEFT OUTER JOIN (SELECT
                                                A3.COST_ELEMENT,
                                                A3.LINE_ITEM_COST,
                                                A2.BUDGET_HEADER_ID,
                                                A3.INTERNAL_ORDER_CODE,
                                                A3.LINE_ITEM_NUMBER,
                                                A3.BUDGET_PERIOD
                                        FROM AWARD_BUDGET_HEADER A2
                                        LEFT OUTER JOIN AWARD_BUDGET_PERIOD P2 ON A2.BUDGET_HEADER_ID = P2.BUDGET_HEADER_ID
                                        LEFT OUTER JOIN AWARD_BUDGET_DETAIL A3 ON P2.BUDGET_PERIOD_ID = A3.BUDGET_PERIOD_ID
                                        where A2.award_id = LI_AWARD_ID
                                        AND A2.SEQUENCE_NUMBER IN (SELECT MIN(AB1.SEQUENCE_NUMBER) FROM AWARD_BUDGET_HEADER AB1
                                                                                                                          WHERE AB1.award_id = A2.award_id)
                                        and A3.BUDGET_CATEGORY_CODE<>600
                                ) S1 ON S1.INTERNAL_ORDER_CODE = T3.INTERNAL_ORDER_CODE
INNER JOIN BUDGET_CATEGORY T6 ON T3.BUDGET_CATEGORY_CODE = T6.BUDGET_CATEGORY_CODE
LEFT OUTER JOIN COST_ELEMENT T7 ON T7.COST_ELEMENT = T3.COST_ELEMENT
WHERE T1.AWARD_ID = LI_AWARD_ID
AND T1.SEQUENCE_NUMBER IN (SELECT MAX(AB1.SEQUENCE_NUMBER) FROM AWARD_BUDGET_HEADER AB1
                                                  WHERE AB1.AWARD_ID = T1.AWARD_ID)
AND T3.BUDGET_CATEGORY_CODE<>600
) S2;
END IF;
END
