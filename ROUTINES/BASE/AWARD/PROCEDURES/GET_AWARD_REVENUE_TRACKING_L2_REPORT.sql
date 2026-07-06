-- `GET_AWARD_REVENUE_TRACKING_L2_REPORT`; 

CREATE PROCEDURE `GET_AWARD_REVENUE_TRACKING_L2_REPORT`(
  )
    DETERMINISTIC
BEGIN
truncate l2_revenue_report_budget;
truncate l2_revenue_report;
insert into l2_revenue_report (ACCOUNT_NUMBER, internal_order_code, CUMMILATIVE_REVENUE)
select 
	t1.account_number, 
	t1.internal_order_code,
	sum(t1.AMOUNT_IN_FMA_CURRENCY) as CUMMILATIVE_REVENUE
from award_revenue_transactions t1
where t1.file_id is not null AND ACTUAL_OR_COMMITTED_FLAG= 'R'
group by t1.ACCOUNT_NUMBER,t1.INTERNAL_ORDER_CODE;
insert into l2_revenue_report_budget (AWARD_ID, AWARD_NUMBER, ACCOUNT_NUMBER,
INTERNAL_ORDER_CODE, line_item_cost,
campus, UNIT_NUMBER, unit_name)
select s2.AWARD_ID,s2.AWARD_NUMBER,s2.ACCOUNT_NUMBER,
s2.INTERNAL_ORDER_CODE,s2.line_item_cost,
t3.campus, t3.UNIT_NUMBER, t3.unit_name
from (SELECT T1.AWARD_ID,T1.AWARD_NUMBER,T1.ACCOUNT_NUMBER,t4.INTERNAL_ORDER_CODE,t4.line_item_cost,T1.LEAD_UNIT_NUMBER
FROM AWARD T1  
INNER JOIN AWARD_BUDGET_HEADER T2 ON T1.AWARD_ID = T2.AWARD_ID
inner join award_budget_detail t4 on t2.budget_header_id = t4.budget_header_id
WHERE T1.ACCOUNT_NUMBER IN(SELECT DISTINCT ACCOUNT_NUMBER FROM AWARD_REVENUE_TRANSACTIONS)
AND T1.AWARD_SEQUENCE_STATUS = 'ACTIVE'
AND T2.SEQUENCE_NUMBER in (select max(t4.SEQUENCE_NUMBER) from award_budget_header t4 where t4.award_id = t2.award_id)
) s2 
inner join unit t3 on s2.LEAD_UNIT_NUMBER = t3.UNIT_NUMBER;
COMMIT;
select t2.unit_number, t2.UNIT_NAME, t2.campus,
ifnull(t2.account_number,t1.account_number) as account_number, ifnull(t1.internal_order_code,t2.internal_order_code) as internal_order_code,t2.line_item_cost,t1.CUMMILATIVE_REVENUE,
IFNULL(t2.line_item_cost,0)-IFNULL(t1.CUMMILATIVE_REVENUE,0) as Balance
from L2_REVENUE_REPORT t1
right outer join l2_revenue_report_budget t2 on trim(t2.account_number) = trim(t1.account_number) 
and trim(IFNULL(t2.internal_order_code,0)) = trim(IFNULL(t1.internal_order_code,0));
END
