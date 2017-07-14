CREATE VIEW ATTENDANCE_BY_GROUP AS
select 
g.id 'groupid',
g.display_name 'group_name',
count(ca.attendance_type_enum) 'attendance_total'
from m_client_attendance ca
INNER JOIN m_client c ON c.id=ca.client_id
INNER JOIN m_group_client gc ON gc.client_id=c.id
INNER JOIN m_group g ON g.id=gc.group_id
where  ca.attendance_type_enum=1 or ca.attendance_type_enum=5 
group by  g.id
order by g.display_name;



CREATE VIEW ATTENDANCE_BY_GROUP_DIV AS
SELECT 
g.id 'groupid',
g.display_name 'group_name',
count(lr.completed_derived) 'expected_meeting'
from m_loan_repayment_schedule lr
INNER JOIN m_loan l ON l.id=lr.loan_id
INNER JOIN m_client c ON c.id=l.client_id
INNER JOIN m_group_client gc ON gc.client_id=c.id
INNER JOIN m_group g ON g.id=gc.group_id
INNER JOIN m_office mo ON g.office_id=mo.id
where lr.duedate<=curdate() AND ORD(lr.completed_derived)=1
group by g.id
order by g.display_name;



CREATE VIEW ATTENDANCE_BY_CLIENT AS
select 
g.id 'groupid',
g.display_name 'group_name',
c.id 'client_id',
c.display_name 'client_name',
count(ca.attendance_type_enum) 'attendance_total'
from m_client_attendance ca
INNER JOIN m_client c ON c.id=ca.client_id
INNER JOIN m_group_client gc ON gc.client_id=c.id
INNER JOIN m_group g ON g.id=gc.group_id
where  ca.attendance_type_enum=1 or ca.attendance_type_enum=5 
group by  c.id
order by g.display_name;



CREATE VIEW ATTENDANCE_BY_CLIENT_DIV AS
SELECT 
g.id 'groupid',
g.display_name 'group_name',
c.id 'client_id',
c.display_name 'client_name',
count(lr.completed_derived) 'expected_meeting'
from m_loan_repayment_schedule lr
INNER JOIN m_loan l ON l.id=lr.loan_id
INNER JOIN m_client c ON c.id=l.client_id
INNER JOIN m_group_client gc ON gc.client_id=c.id
INNER JOIN m_group g ON g.id=gc.group_id
INNER JOIN m_office mo ON g.office_id=mo.id
where lr.duedate<=curdate() AND ORD(lr.completed_derived)=1
group by c.id
order by c.display_name;




