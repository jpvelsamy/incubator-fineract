DROP VIEW SAMPLE_CREDIT_SYSTEM;

CREATE VIEW SAMPLE_CREDIT_SYSTEM AS 
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
WHERE jl.account_id!=2 AND jl.type_enum=1 
group by account_type.name, mg.display_name, jl.office_id, jl.entry_date;

SELECT * FROM SAMPLE_CREDIT_SYSTEM WHERE entry_date='2017-04-01' AND office_id=39;

DROP VIEW SAMPLE_CREDIT_MANUAL;

CREATE VIEW SAMPLE_CREDIT_MANUAL AS 
SELECT 
jl.account_id, 
account_type.name, 
SUM(jl.amount) as amount, 
jl.office_id, 
jl.entry_date 
from acc_gl_journal_entry jl 
inner join acc_gl_account account_type on jl.account_id=account_type.id 
WHERE manual_entry=1 and type_enum=2 AND jl.account_id=85
GROUP BY jl.account_id, account_type.name, jl.office_id, jl.entry_date;

SELECT * FROM SAMPLE_CREDIT_MANUAL WHERE entry_date='2017-04-01' AND office_id=39;

DROP VIEW SAMPLE_DEBIT_SYSTEM;

CREATE VIEW SAMPLE_DEBIT_SYSTEM AS 
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
WHERE jl.account_id=2 AND jl.type_enum=1 
group by account_type.name, mg.display_name, jl.office_id, jl.entry_date;

SELECT * FROM SAMPLE_DEBIT_SYSTEM WHERE entry_date='2017-04-01' AND office_id=39;

DROP VIEW SAMPLE_DEBIT_MANUAL;

CREATE VIEW SAMPLE_DEBIT_MANUAL AS 
SELECT 
jl.account_id, 
account_type.name, 
SUM(jl.amount) AS amount, 
jl.office_id, jl.entry_date 
from acc_gl_journal_entry jl 
inner join acc_gl_account account_type on jl.account_id=account_type.id 
WHERE manual_entry=1 and type_enum=2 and jl.account_id!=85
GROUP BY jl.account_id, account_type.name, jl.office_id, jl.entry_date;

SELECT * FROM SAMPLE_DEBIT_MANUAL WHERE entry_date='2017-04-01';