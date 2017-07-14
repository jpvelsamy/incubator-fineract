DROP TABLE IF EXISTS LEDGER_OPENING_CLOSING_BALANCE;

CREATE TABLE LEDGER_OPENING_CLOSING_BALANCE (
office_id bigint,
office_name VARCHAR(50),
entry_date DATE NOT NULL, 
prev_date DATE NOT NULL,
credit decimal(19,6) default 0, 
debit decimal(19,6) default 0, 
opening_bal decimal(26,6) default 0,
closing_bal decimal(19,6) default 0
)ENGINE=INNODB DEFAULT CHARSET=UTF8;


DELIMITER ;
DROP PROCEDURE IF EXISTS generate_office_ledger;

DELIMITER #
CREATE PROCEDURE generate_office_ledger()
 BEGIN
 DECLARE office_done BOOLEAN DEFAULT FALSE; 
 DECLARE officeid INT DEFAULT 0; 
 DECLARE office_cursor CURSOR FOR  select DISTINCT office_id as office_id from ACC_GL_JOURNAL_CREDIT_DEBIT;
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
     DECLARE opening DECIMAL(25,6) DEFAULT 0.00;
     DECLARE closing DECIMAL(25,6) DEFAULT 0.00;
     DECLARE date_cursor CURSOR FOR select DISTINCT entry_date as entry_date from ACC_GL_JOURNAL_CREDIT_DEBIT WHERE office_id=officeid order by entry_date asc;
     DECLARE CONTINUE HANDLER FOR NOT FOUND SET date_done = TRUE;
     OPEN date_cursor;
      prepare_balance:LOOP
       FETCH date_cursor INTO entryDate;
        IF date_done THEN
         LEAVE prepare_balance;
        END IF;
        IF prevDate IS NULL THEN
         SELECT MIN(entry_date) FROM ACC_GL_JOURNAL_CREDIT_DEBIT WHERE office_id=officeid INTO prevDate;
         SELECT 0 INTO opening;
        ELSE
          SELECT closing_bal FROM LEDGER_OPENING_CLOSING_BALANCE WHERE office_id = officeid AND entry_date=prevDate INTO opening;
        END IF;
        
        INSERT INTO LEDGER_OPENING_CLOSING_BALANCE (office_id, office_name, entry_date, prev_date, credit, debit, opening_bal, closing_bal) SELECT officeid, office_name, entryDate, prevDate, credit, debit, opening, (opening+credit)-debit from ACC_GL_JOURNAL_CREDIT_DEBIT where office_id=officeid AND entry_date=entryDate;
 
        SELECT entryDate INTO prevDate;

      END LOOP prepare_balance;
     CLOSE date_cursor;
    END BLOCK2;
  END LOOP find_txn_date;
 END#
DELIMITER ;

call generate_office_ledger();