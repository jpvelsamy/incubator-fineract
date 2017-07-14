DELIMITER ;

DROP PROCEDURE IF EXISTS ledger_master;

DELIMITER #
CREATE PROCEDURE ledger_master()
BEGIN



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


INSERT INTO ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL (account_type_name, account_name, office_id, office_name, entry_date, credit)
SELECT 'Balance',
'Opening Balance',
office_id,
office_name,
entry_date,
opening_bal
from LEDGER_OPENING_CLOSING_BALANCE;  


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


UPDATE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL SET display_index=0 where account_name = "Opening Balance";

UPDATE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL SET display_index=2 where account_name = "Closing Balance";

UPDATE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL SET display_index=1 where account_type_name != "Balance";

UPDATE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL SET account_type_id=6 where account_name = "Opening Balance";

UPDATE ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL SET account_type_id=7 where account_name = "Closing Balance";


call generate_office_ledger();

END#

DELIMITER ;

call ledger_master();

select * from ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL;






select 
account_type_id 'Account Type Id',
account_type_name 'Account Type Name',
account_name 'Account Name',
account_id 'Account Id',
office_id 'Office Id',
office_name 'Office Name',
entry_date 'Date',
credit 'Credit',
debit 'Debit'
from ACC_GL_JOURNAL_CREDIT_DEBIT_DETAIL 
where office_id=${officeId}
