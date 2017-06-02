select * 
from 
(select debits.glcode as 'glcode', debits.name as 'name', 
ifnull(debits.debitamount,0) as 'debitamout',
ifnull(credits.creditamount,0) as 'creditamout',
IF(debits.type = 'ASSET' or debits.type = 'EXPENSES', ifnull(debits.debitamount,0)-ifnull(credits.creditamount,0),'') as 'debit', 
IF(debits.type = 'INCOME' or debits.type = 'EQUITY' or debits.type = 'LIABILITIES', ifnull(credits.creditamount,0)-ifnull(debits.debitamount,0),'') as 'credit'

from 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'debitamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a 
inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=2 
and a.entry_date between '2017-01-01' and '2017-05-31' 
where a.office_id=46 and reversed=0
group by b.name, glcode, type 
order by glcode) debits 

LEFT OUTER JOIN 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'creditamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=1 
and a.entry_date between '2017-01-01' and '2017-05-31' 
where a.office_id=46  and reversed=0
group by b.name, glcode, type 
order by glcode) credits 

on debits.name=credits.name 

union 

select credits.glcode as 'glcode', credits.name as 'name', ifnull(debits.debitamount,0) as 'debitamout',
ifnull(credits.creditamount,0) as 'creditamout',
IF(debits.type = 'ASSET' or debits.type = 'EXPENSES', ifnull(debits.debitamount,0)-ifnull(credits.creditamount,0),'') as 'debit', 
IF(debits.type = 'INCOME' or debits.type = 'EQUITY' or debits.type = 'LIABILITIES', ifnull(credits.creditamount,0)-ifnull(debits.debitamount,0),'') as 'credit' 
from 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'debitamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=2 
and a.entry_date between '2017-01-01' and '2017-05-31' 
where a.office_id=46  and reversed=0
group by b.name, glcode, type 
order by glcode) debits 

RIGHT OUTER JOIN 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'creditamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=1 
and a.entry_date between '2017-01-01' and '2017-05-31' 
where a.office_id=46 and reversed=0
group by b.name, glcode, type 
order by glcode) credits 

on debits.name=credits.name) as fullouterjoinresult 
order by glcode