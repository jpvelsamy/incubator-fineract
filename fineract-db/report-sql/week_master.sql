drop table if exists week_master;

create table week_master(
week_id varchar (10),
year_no int not null,
month_no int not null,
week_no int not null,
week_name varchar(8),
start_date date,
end_date date,
start_date_str varchar(30),
end_date_str varchar(30),
primary key (week_id))engine=innodb charset=utf8;


drop table if exists day_master;

create table day_master(
day_id varchar(20),
year_no int not null,
month_no int not null,
week_no int not null,
day_no int not null,
primary key (day_id))engine=innodb charset=utf8;

insert into week_master(week_id, year_no, month_no, week_no, start_date, end_date, start_date_str, end_date_str) 
select concat(year_no,'-',month_no,'-',week_no), year_no, month_no, week_no, min(day_id) as start_date, max(day_id) as end_date,
min(day_id) as start_date_str, max(day_id) as end_date_str 
from day_master group by year_no, month_no, week_no;


create view week_count as select count(*) total_weeks, month_no, year_no from week_master group by year_no, month_no ;

select week_no, if(week_no=53, week_no,(week_no%5)) as week_name, month_no, year_no from week_master order by year_no, month_no, week_no asc;

Reference
http://stackoverflow.com/questions/6682916/how-to-take-backup-of-a-single-table-in-a-mysql-database

mysqldump -uroot -ppassword mifostenant-default day_master week_master>/home/jpvel/Downloads/masterdata.sql