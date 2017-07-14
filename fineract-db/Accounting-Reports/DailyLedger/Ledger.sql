DROP VIEW IF EXISTS ACC_GL_JOURNAL_CREDIT;


CREATE VIEW ACC_GL_JOURNAL_CREDIT AS
SELECT
glAccount.classification_enum as account_type_id ,
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
where journalEntry.type_enum=1
group by account_type_id, account_name, account_id, entry_date, office_id, office_name, account_type_name;

DROP VIEW IF EXISTS ACC_GL_JOURNAL_DEBIT;


CREATE VIEW ACC_GL_JOURNAL_DEBIT AS
SELECT
glAccount.classification_enum as account_type_id ,
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
where journalEntry.type_enum=2
group by account_type_id, account_name, account_id, entry_date, office_id, office_name, account_type_name;



DROP VIEW IF EXISTS ACC_GL_JOURNAL_CREDIT_DEBIT;

CREATE VIEW ACC_GL_JOURNAL_CREDIT_DEBIT AS
SELECT
jc.office_id as office_id,
jc.office_name as office_name,
jc.entry_date as entry_date,
sum(jc.credit) as credit,
sum(jd.debit) as debit
from ACC_GL_JOURNAL_CREDIT jc
INNER JOIN ACC_GL_JOURNAL_DEBIT jd ON jc.office_id = jd.office_id AND jc.entry_date=jd.entry_date
GROUP BY jc.office_id, jc.office_name, jc.entry_date;


DROP TABLE IF EXISTS ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL;

CREATE TABLE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL (
  account_type_id smallint(5) ,
  account_type_name varchar(15) CHARACTER SET utf8 DEFAULT NULL,
  account_name varchar(200) CHARACTER SET utf8 ,
  account_id bigint(20)  DEFAULT '0',
  office_id bigint(20)  DEFAULT '0',
  office_name varchar(50) CHARACTER SET utf8 ,
  entry_date date ,
  credit decimal(41,6)  DEFAULT '0.000000',
  debit decimal(41,6)  DEFAULT '0.000000'
  ) ENGINE=InnoDB DEFAULT CHARSET=latin1;


INSERT INTO ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL (account_type_id, account_type_name, account_name, account_id, office_id, office_name, entry_date,credit, debit)
SELECT
jc.account_type_id as account_type_id ,
jc.account_type_name as account_type_name,
jc.account_name as account_name, 
jc.account_id as account_id,  
jc.office_id as office_id,
jc.office_name as office_name,
jc.entry_date as entry_date,
jc.credit as credit,
jd.debit as debit
from ACC_GL_JOURNAL_CREDIT jc
INNER JOIN ACC_GL_JOURNAL_DEBIT jd ON jc.account_id = jd.account_id AND jc.office_id = jd.office_id AND jc.entry_date = jd.entry_date;





DROP TABLE IF EXISTS ACC_CREDIT;

CREATE TABLE ACC_CREDIT AS select distinct account_id from ACC_GL_JOURNAL_CREDIT;

DROP TABLE IF EXISTS ACC_DEBIT;

CREATE TABLE ACC_DEBIT AS select distinct account_id from ACC_GL_JOURNAL_DEBIT;





DROP TABLE IF EXISTS CREDIT_LEFT_OVERS;

CREATE TABLE CREDIT_LEFT_OVERS AS
select a.account_id from ACC_CREDIT a LEFT JOIN ACC_DEBIT b ON a.account_id=b.account_id
where b.account_id is null;

DROP TABLE IF EXISTS DEBIT_LEFT_OVERS;

CREATE TABLE DEBIT_LEFT_OVERS AS
select b.account_id from ACC_CREDIT a RIGHT JOIN ACC_DEBIT b ON a.account_id=b.account_id
where a.account_id is null;


INSERT INTO ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL (account_type_id, account_type_name, account_name, account_id, office_id, office_name, entry_date,credit, debit)  
SELECT
jc.account_type_id as account_type_id ,
jc.account_type_name as account_type_name,
jc.account_name as account_name, 
jc.account_id as account_id,  
jc.office_id as office_id,
jc.office_name as office_name,
jc.entry_date as entry_date,
jc.credit as credit,
0 AS debit
from ACC_GL_JOURNAL_CREDIT jc
WHERE jc.account_id IN (SELECT account_id FROM CREDIT_LEFT_OVERS);

INSERT INTO ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL (account_type_id, account_type_name, account_name, account_id, office_id, office_name, entry_date,credit, debit)  
SELECT
jc.account_type_id as account_type_id ,
jc.account_type_name as account_type_name,
jc.account_name as account_name, 
jc.account_id as account_id,  
jc.office_id as office_id,
jc.office_name as office_name,
jc.entry_date as entry_date,
0 AS credit,
jc.debit as debit
from ACC_GL_JOURNAL_DEBIT jc
WHERE jc.account_id IN (SELECT account_id FROM DEBIT_LEFT_OVERS);


INSERT INTO ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL (account_type_name, account_name, office_id, office_name, entry_date, credit)
SELECT 'Balance',
'Closing Balance',
office_id,
office_name,
entry_date,
closing_bal
from LEDGER_OPENING_CLOSING_BALANCE;



ALTER TABLE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL add column display_index int;


UPDATE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL SET account_type_id=6 where account_name = "Opening Balance";

UPDATE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL SET account_type_id=7 where account_name = "Closing Balance";

UPDATE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL SET display_index=0 where account_name = "Opening Balance";

UPDATE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL SET display_index=2 where account_name = "Closing Balance";

UPDATE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL SET display_index=1 where account_type_name != "Balance";




------------------Testing queries
select a.office_id, b.office_id from ACC_GL_JOURNAL_CREDIT a INNER JOIN ACC_GL_JOURNAL_DEBIT b ON a.office_id=b.office_id AND a.account_id=b.account_id AND a.entry_date=b.entry_date;


select count(distinct account_id) from ACC_GL_JOURNAL_CREDIT;
select count(distinct account_id) from ACC_GL_JOURNAL_DEBIT;


