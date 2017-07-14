DROP TABLE IF EXISTS BALANCE_SHEET_BY_ACC_VANNA; 

CREATE TABLE  BALANCE_SHEET_BY_ACC_VANNA( 
uptodate VARCHAR(150), 
office_id bigint, 
Liabilities varchar(150), 
LiabilityAmount decimal(19,6) ,
Asset varchar(40), 
AssetAmount decimal(19,6) 
) ENGINE=INNODB DEFAULT CHARSET=UTF8; 





DROP PROCEDURE generate_balancesheetbyacctype; 
DELIMITER $$ 
CREATE PROCEDURE generate_balancesheetbyacctype() 
 BEGIN 
 DECLARE office_done BOOLEAN DEFAULT FALSE;	
 DECLARE officeid INT DEFAULT 0; 
 DECLARE uptodate VARCHAR(150); 
 DECLARE total_L DECIMAL(19,6);
 DECLARE total_A DECIMAL(19,6);
 DECLARE Liabilities varchar(150);
 DECLARE income VARCHAR(40); 
 DECLARE expenses VARCHAR(40); 
 DECLARE credit DECIMAL(19,6); 
 DECLARE debit DECIMAL(19,6); 
 DECLARE office_cursor CURSOR FOR select DISTINCT office_id as office_id from acc_gl_journal_entry; 
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET office_done = TRUE; 

 OPEN office_cursor; 
  prepare_profitandloss:LOOP 
   FETCH office_cursor INTO officeid; 
    IF office_done THEN 
     CLOSE office_cursor; 
     LEAVE prepare_profitandloss; 
    END IF; 

select concat(MIN(entry_date),' ',MAX(entry_date)) as "uptodate" from  acc_gl_journal_entry where office_id=officeid INTO uptodate;

    INSERT INTO BALANCE_SHEET_BY_ACC_VANNA(uptodate,office_id,Liabilities,LiabilityAmount) 
    SELECT uptodate,officeid,acc.name, IFNULL(SUM(je.amount),0) as LiabilityAmount
    from acc_gl_journal_entry je INNER JOIN acc_gl_account acc ON je.account_id=acc.id  INNER JOIN  account_type_master am ON acc.classification_enum=am.account_type_num  AND je.type_enum=1 AND acc.classification_enum=2 and je.office_id=officeid
  where reversed=0
    group by acc.name ,uptodate; 


INSERT INTO BALANCE_SHEET_BY_ACC_VANNA(uptodate,office_id,Asset,AssetAmount)
    SELECT uptodate,officeid,acc.name,IFNULL(SUM(je.amount),0) as AssetAmount
    from acc_gl_journal_entry je INNER JOIN acc_gl_account acc ON je.account_id=acc.id  INNER JOIN  account_type_master am ON acc.classification_enum=am.account_type_num  AND je.type_enum=2 AND acc.classification_enum=1 and je.office_id=officeid
    where reversed=0
    group by acc.name,uptodate; 


select SUM(pl.LiabilityAmount) from BALANCE_SHEET_BY_ACC_VANNA  pl where pl.office_id=officeid  INTO total_L;


select SUM(pl.AssetAmount) from BALANCE_SHEET_BY_ACC_VANNA  pl where pl.office_id=officeid  INTO total_A;


INSERT INTO BALANCE_SHEET_BY_ACC_VANNA(uptodate,office_id,Liabilities,LiabilityAmount)
select uptodate,officeid, "Total",total_L;


INSERT INTO BALANCE_SHEET_BY_ACC_VANNA(uptodate,office_id,Asset,AssetAmount)
select uptodate,officeid, "Total",total_A;



    END LOOP prepare_profitandloss;
    


END $$ 
DELIMITER ;

call generate_balancesheetbyacctype();
select *from BALANCE_SHEET_BY_ACC_VANNA where office_id=46;

sample query:
--------------------------------
select 
pl.uptodate ,
pl.office_id,
mo.name 'Office_Name',
pl.Liabilities,
pl.LiabilityAmount,
pl.Asset,
pl.AssetAmount 
from m_office mo
INNER JOIN BALANCE_SHEET_BY_ACC_VANNA pl ON pl.office_id=mo.id
where mo.id=45


Template query:
----------------------------
select 
pl.uptodate ,
pl.office_id,
mo.name 'Office_Name',
pl.Liabilities,
pl.LiabilityAmount,
pl.Asset,
pl.AssetAmount 
from m_office mo
JOIN m_office ounder ON ounder.hierarchy LIKE CONCAT(mo.hierarchy, '%')
 AND ounder.hierarchy like CONCAT('${currentUserHierarchy}', '%')
 INNER JOIN BALANCE_SHEET_BY_ACC_VANNA pl ON pl.office_id=mo.id
WHERE mo.id=${officeId}



BALANCE_SHEET_BY_ACC_VANNA Document:
--------------------------------------

1)->First create a table BALANCE_SHEET_BY_ACC_VANNA for get the credit  and debit  details by account_type(ASSET,LIABILITY) from starting date(first_entry_date) to currentdate(last_entry_date)

	BALANCE_SHEET_BY_ACC_VANNA columns:
						uptodate 
						office_id
						Liabilities((like loan_liability,etc)
						LiabilityAmount(amount per transaction_name)
						Asset(portfolio,Cash corporate,etc)
						AssetAmount(amount per transaction_name)

2)->We need a details for office wise.

3)->LIABILITY type Transaction_amount is called as credit(Income)
  ->ASSET type Transactions_amount is called as debit(Expenses).

4)  ->LIABILITY type=classification_enum=2 in table   acc_gl_account
  ->ASSET type=classification_enum=1 in table   acc_gl_account


5)->Create procedure for genrate_balance_sheet statement.


6)->first we declare a variables for store the data for easy accesing.(calculated data are stored in variables like (min.date to max.date))

  7)->And next we create a cursor(name:office_cursor) for office_id to get the details for office wise.
    ->office cursor to be exexute inside the  loop  for fetch the all office_id from database(from table= acc_gl_journal_entry).
      *-> we get the all needed data  to be executed  inside the loop.*

8)->select concat(MIN(entry_date),' ',MAX(entry_date)) as "uptodate" from  acc_gl_journal_entry where office_id=officeid INTO uptodate;
     -> above query used to calculate the office_starting_date and Last_entry_date.

9)->Next INSERT INTO BALANCE_SHEET_BY_ACC_VANNA(specified_coloumns from BALANCE_SHEET_BY_ACC_VANNA) select (get the details for specified_coloumns of BALANCE_SHEET_BY_ACC_VANNA).
    

	sample query
	--------------------------------
	INSERT INTO BALANCE_SHEET_BY_ACC_VANNA(uptodate,office_id,Liabilities,LiabilityAmount) 
    SELECT uptodate,officeid,acc.name, IFNULL(SUM(je.amount),0) as LiabilityAmount
    from acc_gl_journal_entry je INNER JOIN acc_gl_account acc ON je.account_id=acc.id  INNER JOIN  account_type_master am ON acc.classification_enum=am.account_type_num  AND je.type_enum=1 AND acc.classification_enum=2 and je.office_id=officeid
    group by acc.name ,uptodate; 

	-> Above query used to get the asset data. (acc.classification_enum=1). asset data is debit.
    ->so we can get all other account_type data by (acc.classification_enum). REFER step 3 and 4

   10)->After this query we will calculate total amount for both credit(LIABILITY) and debit(ASSET) Refer step.3
    both two values( total_for_credit and total_for_debit) stored into declare variables. REFER step_6.

        sample query:
        --------------------------------
          select sum(tb.Debit) from BALANCE_SHEET_BY_ACC_VANNA tb where tb.office_id=officeid INTO total_debit;



  11)->AND Insert the total credit and debit values into BALANCE_SHEET_BY_ACC_VANNA. 
  			->using insert_into_statement like step_9

  12->close the loop.

  13)->end

  14)->  call the procedure().

