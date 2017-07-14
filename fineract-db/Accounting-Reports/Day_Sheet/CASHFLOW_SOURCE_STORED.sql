DROP TABLE IF EXISTS OPENING_BAL_CLOSING_BAL
CREATE TABLE OPENING_BAL_CLOSING_BAL(
entry_date DATE NOT NULL,
credit decimal(19,6) default 0, 
debit decimal(19,6) default 0, 
opening_bal decimal(19,6) default 0,
closing_bal decimal(19,6) default 0,
office_id bigint
) ENGINE=INNODB DEFAULT CHARSET=UTF8;

DELIMITER ;

DROP PROCEDURE IF EXISTS generate_balance_sheet_new;

DELIMITER #

CREATE PROCEDURE generate_balance_sheet_new()

 BEGIN
 DECLARE office_done BOOLEAN DEFAULT FALSE; 
 DECLARE officeid INT DEFAULT 0; 
 DECLARE office_cursor CURSOR FOR  select DISTINCT office_id from day_sheet_candidates where active=1;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET office_done = TRUE;
 OPEN office_cursor;
  find_txn_date:LOOP
   FETCH office_cursor INTO officeid;
    IF office_done THEN 
     CLOSE office_cursor;
     LEAVE find_txn_date;
    END IF; 
    BLOCK2: BEGIN
     DECLARE date_done BOOLEAN DEFAULT FALSE;
     DECLARE entryDate DATE DEFAULT NULL;
     DECLARE prevDate DATE DEFAULT NULL;
     DECLARE systemCredit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE manualCredit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE systemDebit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE manualDebit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE totalCredit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE totalDebit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE opening DECIMAL(15,6) DEFAULT 0.00;
     DECLARE date_cursor CURSOR FOR select DISTINCT entry_date as entry_date from acc_gl_journal_entry WHERE office_id=officeid order by entry_date asc;
     DECLARE CONTINUE HANDLER FOR NOT FOUND SET date_done = TRUE;
     OPEN date_cursor;
      prepare_balance:LOOP
       FETCH date_cursor INTO entryDate;
        IF date_done THEN
         LEAVE prepare_balance;
        END IF;
        IF prevDate IS NULL THEN
         SELECT MIN(entry_date) FROM acc_gl_journal_entry WHERE office_id=officeid INTO prevDate;

         SELECT ifnull(SUM(a.amount),0) as credit FROM BRANCHWISE_INBOUND_CASH_SYSTEM a WHERE a.entry_date=prevDate AND office_id=officeid INTO systemCredit;

         SELECT ifnull(sum(amount),0) FROM BRANCHWISE_INBOUND_CASH_MANUAL WHERE entry_date=prevDate AND office_id=officeid INTO manualCredit;

         SELECT ifnull(sum(amount),0) FROM BRANCHWISE_OUTBOUND_CASH_SYSTEM WHERE entry_date=prevDate AND office_id=officeid INTO systemDebit;

         SELECT ifnull(sum(a.amount),0) from BRANCHWISE_OUTBOUND_CASH_MANUAL a WHERE entry_date=prevDate AND office_id=officeid INTO manualDebit;

         SELECT systemCredit+manualCredit INTO totalCredit;

         SELECT systemDebit+manualDebit INTO totalDebit;

         INSERT INTO OPENING_BAL_CLOSING_BAL (entry_date, office_id, credit, debit, opening_bal, closing_bal) SELECT prevDate, officeid, totalCredit, totalDebit, opening, (opening+totalCredit)-totalDebit;

        ELSE 

         IF entryDate>prevDate THEN

          SELECT closing_bal FROM OPENING_BAL_CLOSING_BAL WHERE office_id=officeid AND entry_date=prevDate INTO opening;

          SELECT ifnull(SUM(a.amount),0) as credit FROM BRANCHWISE_INBOUND_CASH_SYSTEM a WHERE a.entry_date=entryDate AND office_id=officeid INTO systemCredit;

          SELECT ifnull(sum(amount),0) FROM BRANCHWISE_INBOUND_CASH_MANUAL WHERE entry_date=entryDate AND office_id=officeid INTO manualCredit;

          SELECT ifnull(sum(amount),0) FROM BRANCHWISE_OUTBOUND_CASH_SYSTEM WHERE entry_date=entryDate AND office_id=officeid INTO systemDebit;

          SELECT ifnull(sum(a.amount),0) from BRANCHWISE_OUTBOUND_CASH_MANUAL a WHERE entry_date=entryDate AND office_id=officeid INTO manualDebit;

          SELECT systemCredit+manualCredit INTO totalCredit;

          SELECT systemDebit+manualDebit INTO totalDebit;

          INSERT INTO OPENING_BAL_CLOSING_BAL (entry_date, office_id, credit, debit, opening_bal, closing_bal) SELECT entryDate, officeid, totalCredit, totalDebit, opening, (opening+totalCredit)-totalDebit;          

          SELECT entryDate INTO prevDate;

         END IF;

        END IF;

      END LOOP prepare_balance;

     CLOSE date_cursor;

    END BLOCK2;

  END LOOP find_txn_date;

 END#

DELIMITER ; 


DROP TABLE IF EXISTS CASHFLOW_SOURCE;
CREATE TABLE CASHFLOW_SOURCE (
  entry_date date NOT NULL,
  office_id bigint(20) DEFAULT NULL,
  details varchar(250) DEFAULT NULL,
  credit decimal(19,6) DEFAULT '0.000000',
  debit decimal(19,6) DEFAULT '0.000000',
  entry_order INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DELIMITER ;
DROP PROCEDURE IF EXISTS generate_cashflow_source;

DELIMITER #
CREATE PROCEDURE generate_cashflow_source()
BEGIN
 DECLARE office_done BOOLEAN DEFAULT FALSE;	
 DECLARE officeid INT DEFAULT 0; 
 DECLARE office_cursor CURSOR FOR  select DISTINCT office_id as office_id from OPENING_BAL_CLOSING_BAL;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET office_done = TRUE;
 OPEN office_cursor;
 find_txn_date:LOOP
   FETCH office_cursor INTO officeid;
    IF office_done THEN 
     CLOSE office_cursor;
     LEAVE find_txn_date;
    END IF;
    BLOCK2: BEGIN
     DECLARE date_done BOOLEAN DEFAULT FALSE;
     DECLARE entryDate DATE DEFAULT NULL;
     DECLARE prevDate DATE DEFAULT NULL;
     DECLARE systemCredit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE manualCredit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE systemDebit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE manualDebit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE totalCredit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE totalDebit DECIMAL(15,6) DEFAULT 0.00;
     DECLARE opening DECIMAL(15,6) DEFAULT 0.00;
     DECLARE date_cursor CURSOR FOR select DISTINCT entry_date as entry_date from OPENING_BAL_CLOSING_BAL WHERE office_id=officeid order by entry_date asc;
     DECLARE CONTINUE HANDLER FOR NOT FOUND SET date_done = TRUE;
     OPEN date_cursor;
      prepare_balance:LOOP
       FETCH date_cursor INTO entryDate;
        IF date_done THEN
         LEAVE prepare_balance;
        END IF;
       
   	    INSERT INTO CASHFLOW_SOURCE(entry_date, office_id, details, credit, debit, entry_order) 
   	    SELECT entryDate, officeid, "Opening Balance", opening_bal as credit, 0 as debit, 0 as entry_order FROM OPENING_BAL_CLOSING_BAL WHERE entry_date=entryDate AND office_id=officeid;

        INSERT INTO CASHFLOW_SOURCE(entry_date, office_id, details, credit, debit, entry_order) 
   	    SELECT entryDate, officeid, "Inbound Cash transfer", ifnull(sum(amount),0) as credit, 0 as debit, 1 entry_order FROM BRANCHWISE_INBOUND_CASH_MANUAL WHERE entry_date=entryDate AND office_id=officeid;

   	    INSERT INTO CASHFLOW_SOURCE(entry_date, office_id, details, credit, debit, entry_order) 
   	    SELECT entryDate, officeid, CONCAT("Collection for ",a.display_name) as details, SUM(amount) as credit, 0 as debit, 3 as entry_order FROM BRANCHWISE_INBOUND_CASH_SYSTEM a WHERE a.entry_date=entryDate AND office_id=officeid GROUP BY a.display_name;

   	    INSERT INTO CASHFLOW_SOURCE(entry_date, office_id, details, credit, debit, entry_order) 
   	    SELECT entryDate, officeid, CONCAT("Loan disbursal for ",a.display_name) as details, 0 as credit, SUM(amount) as debit, 4 as entry_order FROM BRANCHWISE_OUTBOUND_CASH_SYSTEM a WHERE a.entry_date=entryDate AND office_id=officeid GROUP BY a.office_id, a.display_name;

   	    INSERT INTO CASHFLOW_SOURCE(entry_date, office_id, details, credit, debit, entry_order) 
        SELECT entryDate, officeid, a.name as details, 0 AS credit, amount as debit, 5 as entry_order from BRANCHWISE_OUTBOUND_CASH_MANUAL a WHERE a.entry_date=entryDate AND office_id=officeid;

        INSERT INTO CASHFLOW_SOURCE(entry_date, office_id, details, credit, debit, entry_order) 
   	    SELECT entryDate, officeid, "Closing Balance", 0 as credit, closing_bal as debit, 6 as entry_order FROM OPENING_BAL_CLOSING_BAL WHERE entry_date=entryDate AND office_id=officeid;

   	    INSERT INTO CASHFLOW_SOURCE(entry_date, office_id, details, credit, debit, entry_order) 
   	    SELECT entryDate, officeid, "Total Credit/Debit", opening_bal+credit as credit, closing_bal+debit as debit, 7 as entry_order FROM OPENING_BAL_CLOSING_BAL WHERE entry_date=entryDate AND office_id=officeid;

        
      END LOOP prepare_balance;
     CLOSE date_cursor;
    END BLOCK2;
  END LOOP find_txn_date;
 END#
DELIMITER ; 


DELIMITER ;
DROP PROCEDURE IF EXISTS cashflow_target;

DELIMITER #
CREATE PROCEDURE cashflow_target()
BEGIN
TRUNCATE OPENING_BAL_CLOSING_BAL;
call branchwise_in_out_bound(); 
CALL generate_balance_sheet_new();
TRUNCATE CASHFLOW_SOURCE;
CALL generate_cashflow_source();
DROP TABLE IF EXISTS CASHFLOW_TARGET;
CREATE TABLE CASHFLOW_TARGET AS SELECT * FROM CASHFLOW_SOURCE;
END#
DELIMITER ;