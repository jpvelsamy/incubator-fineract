DROP VIEW CLIENT_ACTIVE_LOAN_STATUS;
CREATE table CLIENT_ACTIVE_LOAN_STATUS AS 
SELECT mc.display_name AS display_name,mc.id AS id,center.group_id AS group_id,
       sum(((mr.principal_amount - ifnull(mr.principal_completed_derived,0)) + (mr.interest_amount - ifnull(ifnull(mr.interest_completed_derived,mr.interest_waived_derived),0)))) AS total_balance,
       group_concat(DISTINCT mpl.name separator ',') AS loan_products,
       count(DISTINCT mr.loan_id) AS total_loans
FROM m_client mc
         JOIN m_group_client center on center.client_id = mc.id
        JOIN m_loan ml force index (idx_client_id) on ml.client_id = mc.id
       JOIN m_loan_repayment_schedule mr on mr.loan_id = ml.id
      JOIN m_product_loan mpl on ml.product_id = mpl.id
WHERE ml.loan_status_id = 300
GROUP BY mc.display_name,mc.id,center.group_id
