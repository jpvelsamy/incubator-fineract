DROP TABLE ATTENDANCE_BY_CLIENT_DIV;
CREATE TABLE ATTENDANCE_BY_CLIENT_DIV select g.id AS groupid,g.display_name AS group_name,c.id AS client_id,c.display_name AS client_name,count(lr.completed_derived) AS expected_meeting 
from m_loan_repayment_schedule lr 
join m_loan l on l.id = lr.loan_id
join m_client c on c.id = l.client_id
join m_group_client gc on gc.client_id = c.id
join m_group g on g.id = gc.group_id
join m_office mo on g.office_id = mo.id
where lr.duedate <= curdate() and lr.completed_derived = 1
group by c.id order by c.display_name