select * 
from 
(select AssetAmount
.glcode as 'glcode', AssetAmount
.name as 'name', 
ifnull(AssetAmount
.debitamount,0) as 'debitamout',
ifnull(LiabilityAmount.creditamount,0) as 'creditamout',
IF(AssetAmount
.type = 'ASSET' or AssetAmount
.type = 'EXPENSES', ifnull(AssetAmount
.debitamount,0)-ifnull(LiabilityAmount.creditamount,0),'') as 'debit', 
IF(AssetAmount
.type = 'INCOME' or AssetAmount
.type = 'EQUITY' or AssetAmount
.type = 'LIABILITIES', ifnull(LiabilityAmount.creditamount,0)-ifnull(AssetAmount
.debitamount,0),'') as 'credit'

from 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'debitamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a 
inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=2 
and a.entry_date between '2017-01-01' and '2017-05-31' 
where a.office_id=46 and reversed=0 and b.classification_enum=1
group by b.name, glcode, type 
order by glcode) AssetAmount

LEFT OUTER JOIN 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'creditamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=1 
and a.entry_date between '2017-05-01' and '2017-05-31' 
where a.office_id=46 and reversed=0 and  b.classification_enum=2
group by b.name, glcode, type 
order by glcode) LiabilityAmount

on AssetAmount
.name=LiabilityAmount.name 

union 

select LiabilityAmount.glcode as 'glcode', LiabilityAmount.name as 'name', ifnull(AssetAmount
.debitamount,0) as 'debitamout',
ifnull(LiabilityAmount.creditamount,0) as 'creditamout',
IF(AssetAmount
.type = 'ASSET' or AssetAmount
.type = 'EXPENSES', ifnull(AssetAmount
.debitamount,0)-ifnull(LiabilityAmount.creditamount,0),'') as 'debit', 
IF(AssetAmount
.type = 'INCOME' or AssetAmount
.type = 'EQUITY' or AssetAmount
.type = 'LIABILITIES', ifnull(LiabilityAmount.creditamount,0)-ifnull(AssetAmount
.debitamount,0),'') as 'credit' 
from 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'debitamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=2 
and a.entry_date between '2017-01-01' and '2017-01-31' 
where a.office_id=46 and reversed=0  AND b.classification_enum=1
group by b.name, glcode, type 
order by glcode) AssetAmount

RIGHT OUTER JOIN 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'creditamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=1 
and a.entry_date between '2017-01-01' and '2017-05-31' 
where a.office_id=46 and reversed=0  AND b.classification_enum=2
group by b.name, glcode, type 
order by glcode) LiabilityAmount

on AssetAmount
.name=LiabilityAmount.name) as fullouterjoinresult 
order by glcode


 '${startDate}' and '${endDate}'
----------------------------------------------------------

sample:

select * 
from 
(select AssetAmount
.glcode as 'glcode', AssetAmount
.name as 'name', 
ifnull(AssetAmount
.debitamount,0) as 'debitamout',
ifnull(LiabilityAmount.creditamount,0) as 'creditamout',
IF(AssetAmount
.type = 'ASSET' or AssetAmount
.type = 'EXPENSES', ifnull(AssetAmount
.debitamount,0)-ifnull(LiabilityAmount.creditamount,0),'') as 'debit', 
IF(AssetAmount
.type = 'INCOME' or AssetAmount
.type = 'EQUITY' or AssetAmount
.type = 'LIABILITIES', ifnull(LiabilityAmount.creditamount,0)-ifnull(AssetAmount
.debitamount,0),'') as 'credit'

from 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'debitamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a 
inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=2 
and a.entry_date between '${startDate}' and '${endDate}' 
where a.office_id=${officeId} and b.id!=101 and b.classification_enum=1
group by b.name, glcode, type 
order by glcode) AssetAmount

LEFT OUTER JOIN 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'creditamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=1 
and a.entry_date between '${startDate}' and '${endDate}' 
where a.office_id=${officeId}  and b.id!=101 and b.classification_enum=2
group by b.name, glcode, type 
order by glcode) LiabilityAmount

on AssetAmount
.name=LiabilityAmount.name 

union 

select LiabilityAmount.glcode as 'glcode', LiabilityAmount.name as 'name', ifnull(AssetAmount
.debitamount,0) as 'debitamout',
ifnull(LiabilityAmount.creditamount,0) as 'creditamout',
IF(AssetAmount
.type = 'ASSET' or AssetAmount
.type = 'EXPENSES', ifnull(AssetAmount
.debitamount,0)-ifnull(LiabilityAmount.creditamount,0),'') as 'debit', 
IF(AssetAmount
.type = 'INCOME' or AssetAmount
.type = 'EQUITY' or AssetAmount
.type = 'LIABILITIES', ifnull(LiabilityAmount.creditamount,0)-ifnull(AssetAmount
.debitamount,0),'') as 'credit' 
from 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'debitamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=2 
and a.entry_date between '${startDate}' and '${endDate}' 
where a.office_id=${officeId}  and b.id!=101 AND b.classification_enum=1
group by b.name, glcode, type 
order by glcode) AssetAmount

RIGHT OUTER JOIN 

(select b.gl_code as 'glcode',b.name,sum(amount) as 'creditamount', c.account_type_name as 'type' 
from acc_gl_journal_entry a inner join acc_gl_account b on b.id = a.account_id 
inner join account_type_master c on b.classification_enum = c. account_type_num 
and a.type_enum=1 
and a.entry_date between '${startDate}' and '${endDate}' 
where a.office_id=${officeId} and b.id!=101 AND b.classification_enum=2
group by b.name, glcode, type 
order by glcode) LiabilityAmount

on AssetAmount
.name=LiabilityAmount.name) as fullouterjoinresult 
order by glcode

	