SELECT c.id AS id,
       c.account_no AS accountNo,
       c.external_id AS externalId,
       c.status_enum AS statusEnum,
       c.sub_status AS subStatus,
       cvSubStatus.code_value AS subStatusValue,
       cvSubStatus.code_description AS subStatusDesc,
       c.office_id AS officeId,
       o.name AS officeName,
       c.transfer_to_office_id AS transferToOfficeId,
       transferToOffice.name AS transferToOfficeName,
       c.firstname AS firstname,
       c.middlename AS middlename,
       c.lastname AS lastname,
       c.fullname AS fullname,
       c.display_name AS displayName,
       c.mobile_no AS mobileNo,
       c.date_of_birth AS dateOfBirth,
       c.gender_cv_id AS genderId,
       cv.code_value AS genderValue,
       c.client_type_cv_id AS clienttypeId,
       cvclienttype.code_value AS clienttypeValue,
       c.client_classification_cv_id AS classificationId,
       cvclassification.code_value AS classificationValue,
       c.legal_form_enum AS legalFormEnum,
       c.activation_date AS activationDate,
       c.image_id AS imageId,
       c.staff_id AS staffId,
       s.display_name AS staffName,
       c.default_savings_product AS savingsProductId,
       sp.name AS savingsProductName,
       c.default_savings_account AS savingsAccountId,
       c.submittedon_date AS submittedOnDate,
       sbu.username AS submittedByUsername,
       sbu.firstname AS submittedByFirstname,
       sbu.lastname AS submittedByLastname,
       c.closedon_date AS closedOnDate,
       clu.username AS closedByUsername,
       clu.firstname AS closedByFirstname,
       clu.lastname AS closedByLastname,
       acu.username AS activatedByUsername,
       acu.firstname AS activatedByFirstname,
       acu.lastname AS activatedByLastname,
       cnp.constitution_cv_id AS constitutionId,
       cvConstitution.code_value AS constitutionValue,
       cnp.incorp_no AS incorpNo,
       cnp.incorp_validity_till AS incorpValidityTill,
       cnp.main_business_line_cv_id AS mainBusinessLineId,
       cvMainBusinessLine.code_value AS mainBusinessLineValue,
       cnp.remarks AS remarks,
       act.total_balance AS totalBalance,
       act.loan_products AS activeProducts,
       act.total_loans AS activeLoans,
       clo.loan_products AS closedProducts,
       clo.total_loans AS closedLoans,
       clo.loan_status_string AS closedStatus,
       atc.attendance_total AS attendancePercentageofclient,
       atcd.expected_meeting AS expectedMeeting
FROM m_client c
JOIN m_office o ON o.id = c.office_id
LEFT JOIN m_client_non_person cnp ON cnp.client_id = c.id
JOIN m_group_client pgc ON pgc.client_id = c.id
INNER JOIN m_staff s ON s.id = c.staff_id
LEFT JOIN m_savings_product sp ON sp.id = c.default_savings_product
LEFT JOIN m_office transferToOffice ON transferToOffice.id = c.transfer_to_office_id
LEFT JOIN m_appuser sbu ON sbu.id = c.submittedon_userid
LEFT JOIN m_appuser acu ON acu.id = c.activatedon_userid
LEFT JOIN m_appuser clu ON clu.id = c.closedon_userid
LEFT JOIN m_code_value cv ON cv.id = c.gender_cv_id
LEFT JOIN m_code_value cvclienttype ON cvclienttype.id = c.client_type_cv_id
LEFT JOIN m_code_value cvclassification ON cvclassification.id = c.client_classification_cv_id
LEFT JOIN m_code_value cvSubStatus ON cvSubStatus.id = c.sub_status
LEFT JOIN m_code_value cvConstitution ON cvConstitution.id = cnp.constitution_cv_id
LEFT JOIN m_code_value cvMainBusinessLine ON cvMainBusinessLine.id = cnp.main_business_line_cv_id
LEFT JOIN CLIENT_ACTIVE_LOAN_STATUS act ON c.id=act.id
LEFT JOIN CLIENT_CLOSED_LOAN_STATUS clo ON c.id=clo.id
LEFT JOIN ATTENDANCE_BY_CLIENT atc ON c.id=atc.client_id
LEFT JOIN ATTENDANCE_BY_CLIENT_DIV atcd ON c.id=atcd.client_id limit 1\G



 alter table ATTENDANCE_BY_CLIENT_DIV add index idx_id(client_id);


DELIMITER ;

DROP PROCEDURE IF EXISTS client_generator;

DELIMITER #

CREATE PROCEDURE client_generator()

BEGIN

insert into audit_check(process_name,created_time)values('call_audience_generator', NOW());

CREATE TABLE CLIENT_ACTIVE_LOAN_STATUS AS 
SELECT 
mc.display_name, 
mc.id, 
center.group_id,
SUM((mr.principal_amount- IFNULL(mr.principal_completed_derived,0)) +
(mr.interest_amount- IFNULL(IFNULL(mr.interest_completed_derived,mr.interest_waived_derived),0))) as total_balance,
group_concat(distinct mpl.name) as loan_products,
count(distinct mr.loan_id) as total_loans
FROM m_client mc 
INNER JOIN m_group_client center ON center.client_id=mc.id 
INNER JOIN m_loan ml ON ml.client_id=mc.id
INNER JOIN m_loan_repayment_schedule mr ON mr.loan_id=ml.id            
INNER JOIN m_product_loan mpl ON ml.product_id=mpl.id 
where ml.loan_status_id=300
GROUP BY mc.display_name, mc.id, center.group_id;


CREATE TABLE CLIENT_CLOSED_LOAN_STATUS AS 
SELECT 
mc.display_name, 
mc.id, 
center.group_id, 
c.loan_status_string,
count(distinct ml.id) as total_loans,
group_concat(distinct mpl.name) as loan_products
FROM m_client mc 
INNER JOIN m_group_client center ON center.client_id=mc.id 
INNER JOIN m_loan ml ON ml.client_id=mc.id
INNER JOIN m_product_loan mpl ON ml.product_id=mpl.id 
INNER JOIN m_loan_status_master c ON ml.loan_status_id=c.loan_status_id
where ml.loan_status_id IN (600, 601)
GROUP BY mc.display_name, mc.id, center.group_id, c.loan_status_string;

CREATE TABLE ATTENDANCE_BY_CLIENT AS
SELECT 
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

CREATE TABLE ATTENDANCE_BY_CLIENT_DIV AS
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

alter table CLIENT_ACTIVE_LOAN_STATUS add index idx_id(id);
alter table CLIENT_CLOSED_LOAN_STATUS add index idx_id(id);
alter table ATTENDANCE_BY_CLIENT add index idx_id(client_id);
alter table ATTENDANCE_BY_CLIENT_DIV add index idx_id(client_id);

update audit_check set ended_time=NOW();

END#

DELIMITER ;