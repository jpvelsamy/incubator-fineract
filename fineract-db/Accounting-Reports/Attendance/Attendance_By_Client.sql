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
order by g.display_name