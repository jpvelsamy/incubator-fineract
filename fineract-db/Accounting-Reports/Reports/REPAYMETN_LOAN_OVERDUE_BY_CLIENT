CREATE VIEW COLLECTION_AS_OF_NOW_BY_CLIENT AS
SELECT 
mo.name 'office_name',
lo.display_name as "loan_officer",
g.display_name 'centre_name',
c.display_name 'client_name',
l.account_no 'loan_acc_no',
SUM(IFNULL(lr.principal_completed_derived,0)+(IFNULL(IFNULL(lr.interest_completed_derived,lr.interest_waived_derived),0))+ 
    (IFNULL(IFNULL(lr.fee_charges_completed_derived,lr.fee_charges_waived_derived),0))
    +(IFNULL(IFNULL(lr.penalty_charges_completed_derived,lr.penalty_charges_waived_derived),0))) as "collection"
from m_office mo 
INNER JOIN m_client c on c.office_id=mo.id
INNER JOIN m_loan l on client_id=c.id
INNER JOIN m_group g on g.id=l.group_id
INNER JOIN m_staff lo on lo.id = l.loan_officer_id
INNER JOIN m_loan_repayment_schedule lr on lr.loan_id=l.id
where lr.duedate<=curdate()
group by lr.loan_id ,c.id;



CREATE VIEW PAYMENT_PENDING_AS_OF_NOW_BY_CLIENT AS
SELECT
g.display_name 'centre_name',
c.display_name 'client_name',
pl.id 'ProductId',
g.id 'GroupId',
l.account_no 'loan_acc_no',
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
GROUP BY pl.id, c.id,l.account_no 
ORDER BY g.id;



CREATE VIEW TOTAL_LOAN_OUTSTANDING_AS_OF_NOW_BY_CLIENT AS
SELECT
g.display_name 'centre_name',
c.display_name 'client_name',
pl.id 'ProductId',
g.id 'GroupId',
l.account_no 'loan_acc_no',
max(installment) 'installment',
SUM((lr.principal_amount- IFNULL(lr.principal_completed_derived,0)) +
    (lr.interest_amount- IFNULL(IFNULL(lr.interest_completed_derived,lr.interest_waived_derived),0)) + 
    (IFNULL(lr.fee_charges_amount,0)- IFNULL(IFNULL(lr.fee_charges_completed_derived,lr.fee_charges_waived_derived),0)) + 
    (IFNULL(lr.penalty_charges_amount,0)- IFNULL(IFNULL(lr.penalty_charges_completed_derived,lr.penalty_charges_waived_derived),0))) as "loan_outstanding"
from m_loan_repayment_schedule lr
INNER JOIN m_loan l ON l.id=lr.loan_id
INNER JOIN m_product_loan pl ON pl.id=l.product_id
INNER JOIN m_client c ON c.id=l.client_id
INNER JOIN m_group_client gc ON gc.client_id=c.id
INNER JOIN m_group g ON g.id=gc.group_id AND g.level_id=2
where ORD(lr.completed_derived)=0 and l.loan_status_id=300
GROUP BY pl.id, c.id,l.account_no 
ORDER BY g.id;



REPORT QUERY
select 
tc.office_name 'Office Name',
tc.loan_officer,
tc.centre_name 'Center Name',
tc.client_name 'Client_Name',
p.loan_acc_no 'Loan_account_number',
tc.collection 'Total Collection As Of Now',
p.Payment_pending 'Payment Pending',
tl.loan_outstanding 'Loan Outstanding',
tl.ProductId 'Product Name'
from m_office mo
join m_office ounder on ounder.hierarchy like concat(mo.hierarchy, '%')
 and ounder.hierarchy like concat('${currentUserHierarchy}', '%')
INNER JOIN COLLECTION_AS_OF_NOW_BY_CLIENT tc on tc.office_name=mo.name
INNER JOIN  PAYMENT_PENDING_AS_OF_NOW_BY_CLIENT p on p.loan_acc_no=tc.loan_acc_no
INNER JOIN TOTAL_LOAN_OUTSTANDING_AS_OF_NOW_BY_CLIENT tl on tl.loan_acc_no=p.loan_acc_no
where mo.id = ${officeId}
order by tl.loan_acc_no


