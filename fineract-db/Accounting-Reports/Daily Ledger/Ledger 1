DROP VIEW IF EXISTS ACC_GL_JOURNAL_CREDIT;


CREATE VIEW ACC_GL_JOURNAL_CREDIT AS
SELECT
glAccount.classification_enum as account_type_id,
tm.account_type_name as account_type_name, 
glAccount.name as account_name, 
glAccount.id as account_id,  
office.id as office_id,
office.name as office_name,
journalEntry.entry_date as entry_date,  
IFNULL(sum(journalEntry.amount),0) as credit
from acc_gl_journal_entry as journalEntry  
INNER JOIN acc_gl_account as glAccount on glAccount.id = journalEntry.account_id
INNER JOIN account_type_master as tm on tm.account_type_num=glAccount.classification_enum 
INNER JOIN m_office as office on office.id = journalEntry.office_id 
where journalEntry.type_enum=1 AND journalEntry.office_id=46 AND journalEntry.reversed=0
group by account_type_id, account_name, account_id, entry_date, office_id, office_name, account_type_name;


DROP VIEW IF EXISTS ACC_GL_JOURNAL_DEBIT;


CREATE VIEW ACC_GL_JOURNAL_DEBIT AS
SELECT
glAccount.classification_enum as account_type_id,
tm.account_type_name as account_type_name, 
glAccount.name as account_name, 
glAccount.id as account_id,  
office.id as office_id,
office.name as office_name,
journalEntry.entry_date as entry_date,  
IFNULL(sum(journalEntry.amount),0) as debit
from acc_gl_journal_entry as journalEntry  
INNER JOIN acc_gl_account as glAccount on glAccount.id = journalEntry.account_id
INNER JOIN account_type_master as tm on tm.account_type_num=glAccount.classification_enum 
INNER JOIN m_office as office on office.id = journalEntry.office_id 
where journalEntry.type_enum=2 AND journalEntry.office_id=46 AND journalEntry.reversed=0
group by account_type_id, account_name, account_id, entry_date, office_id, office_name, account_type_name;


DROP VIEW IF EXISTS ACC_GL_JOURNAL_CREDIT_DEBIT;


CREATE VIEW ACC_GL_JOURNAL_CREDIT_DEBIT AS
SELECT
jc.office_id as office_id,
jc.office_name as office_name,
jc.entry_date as entry_date,
jd.account_id as account_id,
sum(jc.credit) as credit,
sum(jd.debit) as debit
from ACC_GL_JOURNAL_CREDIT jc
INNER JOIN ACC_GL_JOURNAL_DEBIT jd ON jc.office_id = jd.office_id AND jc.entry_date=jd.entry_date
GROUP BY jc.office_id, jc.office_name, jc.entry_date;