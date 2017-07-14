Demand vs collection

79650 - demand

5025 - collection

select (sum(principal_amount)+sum(interest_charged_derived)) as "Total", d.display_name from m_loan a inner join m_group d on
a.group_id=d.id where  a.group_id=361;

select sum(a.amount) as collection, d.display_name from m_loan_transaction a inner join m_loan b on a.loan_id=b.id inner join m_group d on b.group_id=d.id  WHERE d.display_name='Sakthimariyamman group' and a.transaction_type_enum=2 group by d.id;


SELECT sum(b.approved_principal) +sum(b.interest_charged_derived) as Total, d.display_name from m_loan b inner join m_group d on b.group_id=d.id where  b.group_id=2; 

select sum(a.amount) as collection, d.display_name from m_loan_transaction a inner join m_loan b on a.loan_id=b.id inner join m_group d on b.group_id=d.id  WHERE d.id=2 and a.transaction_type_enum=2 group by d.id;

With out filter
CREATE VIEW demand as SELECT sum(b.approved_principal) +sum(b.interest_charged_derived) as Total, d.display_name, d.id from m_loan b inner join m_group d on b.group_id=d.id group by b.group_id; 

CREATE VIEW collection as SELECT sum(a.amount) as collection, d.display_name, d.id from m_loan_transaction a inner join m_loan b on a.loan_id=b.id inner join m_group d on b.group_id=d.id  WHERE a.transaction_type_enum=2 group by d.id;

SELECT a.display_name as Branch, a.Total as Demand, b.collection as Collection, a.Total-b.collection as Pending  from demand a inner join collection b on a.id=b.id;



Opening balance vs Closing balance summary
CREATE VIEW non_core_credit as select sum(amount) as aggregate, office_id, manual_entry, type_enum, b.name from acc_gl_journal_entry a inner join acc_gl_account b on a.account_id=b.id where manual_entry=1 and type_enum=1 group by office_id, manual_entry, type_enum, b.id;
CREATE VIEW non_core_debit as select sum(amount) as aggregate, office_id, manual_entry, type_enum, b.name from acc_gl_journal_entry a inner join acc_gl_account b on a.account_id=b.id where manual_entry=1 and type_enum=2 group by office_id, manual_entry, type_enum, b.id;

SELECT a.aggregate as "Total Credit", b.aggregate as "Total debit", a.name as "Transaction Name", c.name as "Office name" from non_core_credit a inner join non_core_debit b on a.office_id=b.office_id inner join m_office c on a.office_id=c.id;


CREATE VIEW core_credit as select sum(amount) as aggregate, office_id, manual_entry, type_enum, b.name from acc_gl_journal_entry a inner join acc_gl_account b on a.account_id=b.id where manual_entry=0 and type_enum=1 group by office_id, manual_entry, type_enum, b.id;
CREATE VIEW core_debit as select sum(amount) as aggregate, office_id, manual_entry, type_enum, b.name from acc_gl_journal_entry a inner join acc_gl_account b on a.account_id=b.id where manual_entry=0 and type_enum=2 group by office_id, manual_entry, type_enum, b.id;

 SELECT a.aggregate as "Total Credit", b.aggregate as "Total debit", a.name as "Transaction Name", c.name as "Office name" from core_credit a inner join core_debit b on a.office_id=b.office_id inner join m_office c on a.office_id=c.id;