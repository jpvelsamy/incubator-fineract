DROP TABLE ATTENDANCE_BY_CLIENT;
CREATE TABLE ATTENDANCE_BY_CLIENT select g.id AS groupid,g.display_name AS group_name,c.id AS client_id,c.display_name AS client_name,count(ca.attendance_type_enum) AS attendance_total 
from m_client_attendance ca 
join m_client c on c.id = ca.client_id
join m_group_client gc on gc.client_id = c.id
join m_group g on g.id = gc.group_id
where ca.attendance_type_enum = 1 or ca.attendance_type_enum = 5
group by c.id order by g.display_name
