create database `mifosplatform-tenants`;
create database `mifosplatform-default`;

use `mifosplatform-default`;
select count(*) from m_account_transfer_details;

drop table if exists m_loan_status_master;

create table m_loan_status_master(
loan_status_id int not null,
loan_status_string varchar(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


insert into m_loan_status_master values(0,'Invalid'), (100,'Submitted&Pending'), (200, 'Approved'),
(300, 'Active'), (303,'TransferInProgress'), (304,'TransferOnHold'),(400,'WithDrawnByClient'),
(500,'Rejected'),(600, 'Closed +ve'),(601,'WrittenOff'),(602,'Resheduled&Paymentpending'),
(700,'Overpaid');

select count(a.id) as loan_count, b.loan_status_string as loan_status 
from m_loan a inner join m_loan_status_master b on 
a.loan_status_id=b.loan_status_id 
group by a.loan_status_id;



create table month_master(
month_num int not null,
month_name varchar(50))ENGINE=InnoDB DEFAULT CHARSET=utf8;


insert into month_master values (1,'Jan'),(2,'Feb'),(3,'Mar'),(4,'Apr'),(5,'May'),(6,'Jun'),
(7,'Jul'),(8,'Aug'),(9,'Sep'),(10,'Oct'),(11,'Nov'),(12,'Dec');

select count(a.id) as active_loan_count, month(a.disbursedon_date) as month_num, b.month_name from m_loan a inner join month_master b
on month(a.disbursedon_date) =b.month_num 
where a.loan_status_id = 300 group by b.month_num;
