DROP TABLE CLIENT_CLOSED_LOAN_STATUS;

create table CLIENT_CLOSED_LOAN_STATUS select mc.display_name AS display_name,mc.id AS id,center.group_id AS group_id,c.loan_status_string AS loan_status_string,count(distinct ml.id) AS total_loans,group_concat(distinct mpl.name separator ',') AS loan_products from 
m_client mc join m_group_client center on center.client_id = mc.id
join m_loan ml on ml.client_id = mc.id
join m_product_loan mpl on ml.product_id = mpl.id
join m_loan_status_master c on ml.loan_status_id = c.loan_status_id
where ml.loan_status_id in (600,601) 
group by mc.display_name,mc.id,center.group_id,c.loan_status_string