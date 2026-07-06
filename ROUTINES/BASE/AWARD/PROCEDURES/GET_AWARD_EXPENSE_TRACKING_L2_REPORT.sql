-- `GET_AWARD_EXPENSE_TRACKING_L2_REPORT`; 

CREATE PROCEDURE `GET_AWARD_EXPENSE_TRACKING_L2_REPORT`(
  )
    DETERMINISTIC
BEGIN
truncate l2_expense_report_budget;
truncate l2_expense_report;
insert into l2_expense_report (ACCOUNT_NUMBER, internal_order_code, cummilative_expense, COMMITED_AMOUNT)
select 
	t1.account_number, 
	t1.internal_order_code,
	sum(t1.AMOUNT_IN_FMA_CURRENCY) as cummilative_expense,
    S1.COMMITED_AMOUNT
from award_expense_transactions t1
LEFT OUTER JOIN (select t2.ACCOUNT_NUMBER,
						t2.INTERNAL_ORDER_CODE,
                        SUM(T2.COMMITTED_AMOUNT) AS COMMITED_AMOUNT
				from AWARD_EXPENSE_DETAILS_EXT t2
				where (T2.ACCOUNT_NUMBER,t2.INTERNAL_ORDER_CODE) IN (SELECT DISTINCT ACCOUNT_NUMBER,INTERNAL_ORDER_CODE 
																	 FROM AWARD_EXPENSE_TRANSACTIONS WHERE FILE_ID IS NOT NULL
                                                                     )
group by t2.ACCOUNT_NUMBER,t2.INTERNAL_ORDER_CODE) S1 ON S1.ACCOUNT_NUMBER = T1.ACCOUNT_NUMBER 
AND S1.INTERNAL_ORDER_CODE = T1.INTERNAL_ORDER_CODE
where t1.file_id is not null AND ACTUAL_OR_COMMITTED_FLAG= 'A'
group by t1.ACCOUNT_NUMBER,t1.INTERNAL_ORDER_CODE;
insert into l2_expense_report_budget (AWARD_ID, AWARD_NUMBER, ACCOUNT_NUMBER,
INTERNAL_ORDER_CODE, line_item_cost,
campus, UNIT_NUMBER, unit_name)
select s2.AWARD_ID,s2.AWARD_NUMBER,s2.ACCOUNT_NUMBER,
s2.INTERNAL_ORDER_CODE,s2.line_item_cost,
t3.campus, t3.UNIT_NUMBER, t3.unit_name
from (SELECT T1.AWARD_ID,T1.AWARD_NUMBER,T1.ACCOUNT_NUMBER,t4.INTERNAL_ORDER_CODE,t4.line_item_cost,T1.LEAD_UNIT_NUMBER
FROM AWARD T1  
INNER JOIN AWARD_BUDGET_HEADER T2 ON T1.AWARD_ID = T2.AWARD_ID
inner join award_budget_detail t4 on t2.budget_header_id = t4.budget_header_id
WHERE T1.ACCOUNT_NUMBER IN(SELECT DISTINCT ACCOUNT_NUMBER FROM AWARD_EXPENSE_TRANSACTIONS)
AND T1.AWARD_SEQUENCE_STATUS = 'ACTIVE'
AND T2.SEQUENCE_NUMBER in (select max(t4.SEQUENCE_NUMBER) from award_budget_header t4 where t4.award_id = t2.award_id)
) s2 
inner join unit t3 on s2.LEAD_UNIT_NUMBER = t3.UNIT_NUMBER;
COMMIT;
select t2.unit_number, t2.UNIT_NAME, t2.campus,
ifnull(t2.account_number,t1.account_number) as account_number, ifnull(t1.internal_order_code,t2.internal_order_code) as internal_order_code,t2.line_item_cost,t1.cummilative_expense,
IFNULL(t2.line_item_cost,0)-IFNULL(t1.cummilative_expense,0) as Balance
, t1.COMMITED_AMOUNT, (IFNULL(t2.line_item_cost,0)-IFNULL(t1.cummilative_expense,0))-IFNULL(t1.COMMITED_AMOUNT,0) as Total_commited
from l2_expense_report t1
right outer join l2_expense_report_budget t2 on trim(t2.account_number) = trim(t1.account_number) 
and trim(IFNULL(t2.internal_order_code,0)) = trim(IFNULL(t1.internal_order_code,0));
END
