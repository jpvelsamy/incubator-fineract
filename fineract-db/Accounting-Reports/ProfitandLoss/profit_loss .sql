DROP TABLE IF EXISTS PROFIT_LOSS ;
CREATE TABLE PROFIT_LOSS( 
uptodate VARCHAR(150), 
office_id bigint,  
Account_type varchar (40), 
Account_name varchar (40), 
Debit decimal(19,6) ,
Credit decimal(19,6)
) ENGINE=INNODB DEFAULT CHARSET=UTF8; 





DROP PROCEDURE IF EXISTS generate_p_l_balance; 

DELIMITER $$ 
CREATE PROCEDURE generate_p_l_balance() 
 BEGIN 
 DECLARE office_done BOOLEAN DEFAULT FALSE; 
 DECLARE officeid INT DEFAULT 0; 
 DECLARE uptodate VARCHAR(150); 
 DECLARE Account_type varchar(150);
 DECLARE Account_name varchar (40);
 DECLARE credit DECIMAL(19,6); 
 DECLARE debit DECIMAL(19,6); 
 DECLARE total_debit DECIMAL(19,6);
 DECLARE total_credit DECIMAL(19,6);
 DECLARE office_cursor CURSOR FOR select DISTINCT office_id as office_id from acc_gl_journal_entry; 
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET office_done = TRUE; 

 OPEN office_cursor; 
  prepare_profitandloss:LOOP 
   FETCH office_cursor INTO officeid; 
    IF office_done THEN 
     CLOSE office_cursor; 
     LEAVE prepare_profitandloss; 
    END IF; 



    select concat(MIN(entry_date),MAX(entry_date)) as "uptodate" from  acc_gl_journal_entry where office_id=officeid INTO uptodate;

   

INSERT INTO PROFIT_LOSS(uptodate,office_id, Account_type,Account_name,Debit) 
    SELECT uptodate,officeid,am.account_type_name,acc.name, IFNULL(SUM(je.amount),0) as Debit 
    from acc_gl_journal_entry je INNER JOIN acc_gl_account acc ON je.account_id=acc.id  INNER JOIN  account_type_master am ON acc.classification_enum=am.account_type_num  AND je.type_enum=2 AND acc.classification_enum=5 and je.office_id=officeid
    group by acc.name ,uptodate;


    INSERT INTO PROFIT_LOSS(uptodate,office_id, Account_type,Account_name,Credit) 
    SELECT uptodate,officeid,am.account_type_name,acc.name, IFNULL(SUM(je.amount),0) as Credit
    from acc_gl_journal_entry je INNER JOIN acc_gl_account acc ON je.account_id=acc.id  INNER JOIN  account_type_master am ON acc.classification_enum=am.account_type_num  AND je.type_enum=1 AND acc.classification_enum= 4 and je.office_id=officeid
    group by acc.name ,uptodate;


select sum(tb.Debit) from PROFIT_LOSS tb where tb.office_id=officeid INTO total_debit;

select sum(tb.Credit) from PROFIT_LOSS tb where tb.office_id=officeid INTO total_credit;

INSERT INTO PROFIT_LOSS(uptodate,office_id,Account_name,Debit) 
    SELECT uptodate,officeid,"total",total_debit;

    INSERT INTO PROFIT_LOSS(uptodate,office_id,Account_name,Credit) 
    SELECT uptodate,officeid,"total",total_credit;

    if total_credit>total_credit then
      INSERT INTO PROFIT_LOSS(uptodate,office_id,Account_name,Credit) 
    SELECT uptodate,officeid,"profit",total_credit-total-credit;

    else
    INSERT INTO PROFIT_LOSS(uptodate,office_id,Account_name,Debit) 
    SELECT uptodate,officeid,"loss",total_debit-total_credit;
    

    end if;
    END LOOP prepare_profitandloss;

    


END $$ 
DELIMITER ;

call generate_p_l_balance(); 

select *from PROFIT_LOSS where office_id=45;