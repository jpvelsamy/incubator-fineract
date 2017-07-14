CREATE TABLE BRANCHWISE_OUTBOUND_CASH_SYSTEM AS
SELECT 
jl.account_id, 
account_type.name, 
SUM(jl.amount) as amount,
mg.display_name, 
jl.office_id, 
jl.entry_date 
FROM acc_gl_journal_entry jl 
INNER JOIN acc_gl_account account_type ON jl.account_id=account_type.id
INNER JOIN m_loan_transaction mlt ON jl.loan_transaction_id=mlt.id
INNER JOIN m_loan ml ON ml.id=mlt.loan_id
INNER JOIN m_group mg ON ml.group_id=mg.id
WHERE (jl.account_id=2 or jl.account_id=92) and jl.reversed=0 AND jl.type_enum=1
group by account_type.name, mg.display_name, jl.office_id, jl.entry_date;

CREATE TABLE BRANCHWISE_OUTBOUND_CASH_MANUAL AS
select
jl.account_id, 
account_type.name, 
SUM(jl.amount) AS amount, 
jl.office_id, jl.entry_date 
from acc_gl_journal_entry jl 
inner join acc_gl_account account_type on jl.account_id=account_type.id 
WHERE manual_entry=1 and type_enum=2 and jl.account_id!=85 and jl.reversed=0 and (jl.account_id=99 or account_type.classification_enum=2 or account_type.classification_enum=5)
GROUP BY jl.account_id, account_type.name, jl.office_id, jl.entry_date; 