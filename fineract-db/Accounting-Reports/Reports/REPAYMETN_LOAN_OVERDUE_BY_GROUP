CREATE VIEW PAYMENT_PENDING_BY_GROUP AS
SELECT
pl.id 'ProductId',
g.id 'GroupId',
max(installment) 'installment',
SUM((lr.principal_amount- IFNULL(lr.principal_completed_derived,0)) +
    (lr.interest_amount- IFNULL(IFNULL(lr.interest_completed_derived,lr.interest_waived_derived),0)) + 
    (IFNULL(lr.fee_charges_amount,0)- IFNULL(IFNULL(lr.fee_charges_completed_derived,lr.fee_charges_waived_derived),0)) + 
    (IFNULL(lr.penalty_charges_amount,0)- IFNULL(IFNULL(lr.penalty_charges_completed_derived,lr.penalty_charges_waived_derived),0))) as "Payment_pending"
from m_loan_repayment_schedule lr
INNER JOIN m_loan l ON l.id=lr.loan_id
INNER JOIN m_product_loan pl ON pl.id=l.product_id
INNER JOIN m_client c ON c.id=l.client_id
INNER JOIN m_group_client gc ON gc.client_id=c.id
INNER JOIN m_group g ON g.id=gc.group_id AND g.level_id=2
where lr.duedate<=curdate() AND ORD(lr.completed_derived)=0 and l.loan_status_id=300
GROUP BY pl.id, g.id;




CREATE VIEW LOAN_OUTSTANDING_BY_GROUP AS
SELECT
pl.id 'ProductId',
g.id 'GroupId',
max(installment) 'installment',
SUM((lr.principal_amount- IFNULL(lr.principal_completed_derived,0)) +
    (lr.interest_amount- IFNULL(IFNULL(lr.interest_completed_derived,lr.interest_waived_derived),0)) + 
    (IFNULL(lr.fee_charges_amount,0)- IFNULL(IFNULL(lr.fee_charges_completed_derived,lr.fee_charges_waived_derived),0)) + 
    (IFNULL(lr.penalty_charges_amount,0)- IFNULL(IFNULL(lr.penalty_charges_completed_derived,lr.penalty_charges_waived_derived),0))) as "outstanding_amount"
from m_loan_repayment_schedule lr
INNER JOIN m_loan l ON l.id=lr.loan_id
INNER JOIN m_product_loan pl ON pl.id=l.product_id
INNER JOIN m_client c ON c.id=l.client_id
INNER JOIN m_group_client gc ON gc.client_id=c.id
INNER JOIN m_group g ON g.id=gc.group_id AND g.level_id=2
where  ORD(lr.completed_derived)=0 and l.loan_status_id=300
GROUP BY pl.id, g.id;




CREATE VIEW TOTAL_COLLECTION_AS_OF_NOW_BY_GROUP AS
SELECT 
mo.name 'office_name',
g.id 'group_id',
g.display_name 'centre_Name',
vg.client_count 'total_clients',
min(l.disbursedon_date) 'first_date',
max(l.disbursedon_date) 'last_date',
tcs.Collected_sofar 'total_collection_as_of_now',
pl.short_name 'loan_product'
FROM m_office mo	
INNER JOIN m_group g ON  g.office_id=mo.id
INNER JOIN VIEW_GROUPS_ONLY vg ON vg.group_id=g.id
INNER JOIN m_loan l ON l.group_id=g.id
INNER JOIN completed_collection_sumtotal tcs ON tcs.group_id=g.id
INNER JOIN m_product_loan pl ON pl.id=l.product_id 
GROUP BY g.id, g.display_name, mo.name, pl.short_name, pl.id




REPORT QUERY
select 
tc.office_name 'Office Name',
tc.centre_name 'Center Name',
tc.total_clients 'Total Clients',
tc.first_date 'First Date',
tc.last_date 'Last Date',
tc.total_collection_as_of_now 'Total Collection As Of Now',
p.Payment_pending 'Payment Pending',
l.outstanding_amount 'Loan Outstanding',
tc.loan_product 'Product Name'
from m_office mo
join m_office ounder on ounder.hierarchy like concat(mo.hierarchy, '%')
 and ounder.hierarchy like concat('${currentUserHierarchy}', '%')
INNER JOIN TOTAL_COLLECTION_AS_OF_NOW_BY_GROUP tc on tc.office_name=mo.name
INNER JOIN PAYMENT_PENDING_BY_GROUP p on p.GroupId=tc.group_id
INNER JOIN LOAN_OUTSTANDING_BY_GROUP l on l.GroupId=p.p.GroupId
where mo.id = ${officeId}

select 
tc.office_name 'Office Name',
tc.centre_name 'Center Name',
tc.total_clients 'Total Clients',
tc.first_date 'First Date',
tc.last_date 'Last Date',
tc.total_collection_as_of_now 'Total Collection As Of Now',
p.Payment_pending 'Payment Pending',
l.outstanding_amount 'Loan Outstanding',
tc.loan_product 'Product Name'
from m_office mo
INNER JOIN TOTAL_COLLECTION_AS_OF_NOW_BY_GROUP tc on tc.office_name=mo.name
INNER JOIN PAYMENT_PENDING_BY_GROUP p on p.GroupId=tc.group_id
INNER JOIN LOAN_OUTSTANDING_BY_GROUP l on l.GroupId=p.p.GroupId
where mo.id = 39