Daysheet report
------------------------------




Non executable, but refereneable query
-------------------------------------
SELECT jl.account_id, account_type.name,jl.amount FROM acc_gl_journal_entry jl INNER JOIN acc_gl_account account_type ON jl.account_id=account_type.id
INNER JOIN m_loan_transaction mlt ON jl.loan_transaction_id=mlt.id
INNER JOIN m_loan ml ON ml.id=mlt.loan_id
INNER JOIN m_client mc ON mc.id=ml.client_id
INNER JOIN m_group mg ON ml.group_id=mg.id
WHERE jl.entry_date='2017-04-01';


Query meant to find out all rouge entries with principal being mapped to loan-portfolio
-------------------------------------------------------------------
SELECT jl.account_id, account_type.name,jl.amount FROM acc_gl_journal_entry jl INNER JOIN acc_gl_account account_type ON jl.account_id=account_type.id
WHERE jl.type_enum=1 AND jl.amount in (290, 50);



SELECT DISTINCT amount FROM acc_gl_journal_entry jl WHERE  jl.type_enum=1;

update instruction to change all the rogue entries
-------------------------------------------------------
UPDATE acc_gl_journal_entry jl SET jl.account_id=84 WHERE jl.type_enum=1 AND jl.amount in (290,50);


verification query
--------------------------
 select count(*), transaction_type_enum from m_loan_transaction group by transaction_type_enum;

Daysheet credit 
--------------------------------------

DROP VIEW SAMPLE_CREDIT_SYSTEM;
CREATE VIEW SAMPLE_CREDIT_SYSTEM AS SELECT jl.account_id, account_type.name, SUM(jl.amount) as amount,mg.display_name, jl.office_id, jl.entry_date FROM acc_gl_journal_entry jl INNER JOIN acc_gl_account account_type ON jl.account_id=account_type.id
INNER JOIN m_loan_transaction mlt ON jl.loan_transaction_id=mlt.id
INNER JOIN m_loan ml ON ml.id=mlt.loan_id
INNER JOIN m_group mg ON ml.group_id=mg.id
WHERE jl.account_id!=2 AND 
jl.type_enum=1 group by account_type.name, mg.display_name, jl.office_id, jl.entry_date;

--Test queries
-------------------
SELECT * FROM SAMPLE_CREDIT_SYSTEM WHERE entry_date='2017-04-01' AND office_id=39;

SELECT a.entry_date as date, m_office.name,a.display_name as centre, group_concat(a.name) as components, SUM(a.amount) as credit FROM SAMPLE_CREDIT_SYSTEM a INNER JOIN m_office ON a.office_id=m_office.id 
WHERE a.entry_date='2017-04-01' AND office_id=39 GROUP BY a.display_name ;


DROP VIEW SAMPLE_CREDIT_MANUAL;
CREATE VIEW SAMPLE_CREDIT_MANUAL AS SELECT jl.account_id, account_type.name, SUM(jl.amount) as amount, jl.office_id, jl.entry_date from acc_gl_journal_entry jl inner join acc_gl_account account_type on jl.account_id=account_type.id WHERE manual_entry=1 and type_enum=2
AND jl.account_id=85
GROUP BY jl.account_id, account_type.name, jl.office_id, jl.entry_date;

--Test queries
-------------------
SELECT * FROM SAMPLE_CREDIT_MANUAL WHERE entry_date='2017-04-01' AND office_id=39;
SELECT * FROM SAMPLE_CREDIT_MANUAL WHERE entry_date='2017-04-03' AND office_id=39;
SELECT * FROM SAMPLE_CREDIT_MANUAL WHERE entry_date='2017-04-01' AND office_id=1;


DROP VIEW SAMPLE_DEBIT_SYSTEM;
CREATE VIEW SAMPLE_DEBIT_SYSTEM AS SELECT jl.account_id, account_type.name, SUM(jl.amount) as amount,mg.display_name, jl.office_id, jl.entry_date FROM acc_gl_journal_entry jl INNER JOIN acc_gl_account account_type ON jl.account_id=account_type.id
INNER JOIN m_loan_transaction mlt ON jl.loan_transaction_id=mlt.id
INNER JOIN m_loan ml ON ml.id=mlt.loan_id
INNER JOIN m_group mg ON ml.group_id=mg.id
WHERE jl.account_id=2 AND 
jl.type_enum=1 group by account_type.name, mg.display_name, jl.office_id, jl.entry_date;

SELECT * FROM SAMPLE_DEBIT_SYSTEM WHERE entry_date='2017-04-01' AND office_id=39;


Daysheet debit 
--------------------------------------
DROP VIEW SAMPLE_DEBIT_MANUAL;
CREATE VIEW SAMPLE_DEBIT_MANUAL AS SELECT jl.account_id, account_type.name, SUM(jl.amount) AS amount, jl.office_id, jl.entry_date from acc_gl_journal_entry jl inner join acc_gl_account account_type on jl.account_id=account_type.id WHERE manual_entry=1 and type_enum=2 and
jl.account_id!=85
GROUP BY jl.account_id, account_type.name, jl.office_id, jl.entry_date;

SELECT * FROM SAMPLE_DEBIT_MANUAL WHERE entry_date='2017-04-01' AND office_id=39;

SELECT entry_date as date, m_office.name, a.name as outgoing, amount from SAMPLE_DEBIT_MANUAL a INNER JOIN m_office ON a.office_id=m_office.id 
WHERE a.entry_date='2017-04-01' AND office_id=39;

SELECT jl.account_id, account_type.name, jl.amount AS amount, jl.office_id, jl.entry_date, jl.type_enum from acc_gl_journal_entry jl inner join acc_gl_account account_type on jl.account_id=account_type.id 
WHERE jl.entry_date='2017-04-01' AND jl.office_id=39  AND manual_entry=1;


Final queries for report
------------------------------------------

System Incoming/Credit(Principal, interest, fees)
-------------------------------------------------
SELECT a.entry_date as date, m_office.name,a.display_name as centre, group_concat(a.name) as components, SUM(a.amount) as credit FROM SAMPLE_CREDIT_SYSTEM a INNER JOIN m_office ON a.office_id=m_office.id 
WHERE a.entry_date='2017-04-01' AND office_id=39 GROUP BY a.display_name ;

Manual Incoming/Credit(Cash transfer)
------------------------------------------------
SELECT * FROM SAMPLE_CREDIT_MANUAL WHERE entry_date='2017-04-01' AND office_id=39;

System Outgoing/Debit(Loan disbursal)
----------------------------------------------
SELECT * FROM SAMPLE_DEBIT_SYSTEM WHERE entry_date='2017-04-01' AND office_id=39;

Manual Outgoing/Debit(Cash transfer & expenses)
-------------------------------------------------
SELECT entry_date as date, m_office.name, a.name as outgoing, amount from SAMPLE_DEBIT_MANUAL a INNER JOIN m_office ON a.office_id=m_office.id 
WHERE a.entry_date='2017-04-01' AND office_id=39;




Stored procedure calculation queriues
------------------------------------------


System Credit query
--------------
SELECT SUM(a.amount) as credit FROM SAMPLE_CREDIT_SYSTEM a WHERE a.entry_date='2017-04-01' AND office_id=39;

Manual Credit query
-------------
SELECT sum(amount) FROM SAMPLE_CREDIT_MANUAL WHERE entry_date='2017-04-03' AND office_id=39;

System Debit query
-------------
SELECT sum(amount) FROM SAMPLE_DEBIT_SYSTEM WHERE entry_date='2017-04-01' AND office_id=39;

Manual debit query
---------
SELECT sum(a.amount) from SAMPLE_DEBIT_MANUAL a WHERE a.entry_date='2017-04-01' AND office_id=39;




DROP TABLE IF EXISTS BALANCE_SHEET;
CREATE TABLE BALANCE_SHEET(
entry_date DATE NOT NULL, 
credit decimal(19,6) default 0, 
debit decimal(19,6) default 0, 
opening_bal decimal(19,6) default 0,
closing_bal decimal(19,6) default 0,
office_id bigint
) ENGINE=INNODB DEFAULT CHARSET=UTF8;



DELIMITER ;
DROP PROCEDURE IF EXISTS generate_balance_sheet;

DELIMITER #
CREATE PROCEDURE generate_balance_sheet()
 BEGIN
 DECLARE office_done BOOLEAN DEFAULT FALSE; 
 DECLARE officeid INT DEFAULT 0; 
 DECLARE office_cursor CURSOR FOR  select DISTINCT office_id as office_id from acc_gl_journal_entry;
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
         SELECT ifnull(SUM(a.amount),0) as credit FROM SAMPLE_CREDIT_SYSTEM a WHERE a.entry_date=prevDate AND office_id=officeid INTO systemCredit;

         SELECT ifnull(sum(amount),0) FROM SAMPLE_CREDIT_MANUAL WHERE entry_date=prevDate AND office_id=officeid INTO manualCredit;

         SELECT ifnull(sum(amount),0) FROM SAMPLE_DEBIT_SYSTEM WHERE entry_date=prevDate AND office_id=officeid INTO systemDebit;

         SELECT ifnull(sum(a.amount),0) from SAMPLE_DEBIT_MANUAL a WHERE entry_date=prevDate AND office_id=officeid INTO manualDebit;

         SELECT systemCredit+manualCredit INTO totalCredit;

         SELECT systemDebit+manualDebit INTO totalDebit;

         INSERT INTO BALANCE_SHEET (entry_date, office_id, credit, debit, opening_bal, closing_bal) SELECT prevDate, officeid, totalCredit, totalDebit, opening, (opening+totalCredit)-totalDebit;

        ELSE 
         IF entryDate>prevDate THEN
          SELECT closing_bal FROM BALANCE_SHEET WHERE office_id=officeid AND entry_date=prevDate INTO opening;

          SELECT ifnull(SUM(a.amount),0) as credit FROM SAMPLE_CREDIT_SYSTEM a WHERE a.entry_date=entryDate AND office_id=officeid INTO systemCredit;

          SELECT ifnull(sum(amount),0) FROM SAMPLE_CREDIT_MANUAL WHERE entry_date=entryDate AND office_id=officeid INTO manualCredit;

          SELECT ifnull(sum(amount),0) FROM SAMPLE_DEBIT_SYSTEM WHERE entry_date=entryDate AND office_id=officeid INTO systemDebit;

          SELECT ifnull(sum(a.amount),0) from SAMPLE_DEBIT_MANUAL a WHERE entry_date=entryDate AND office_id=officeid INTO manualDebit;

          SELECT systemCredit+manualCredit INTO totalCredit;

          SELECT systemDebit+manualDebit INTO totalDebit;

          INSERT INTO BALANCE_SHEET (entry_date, office_id, credit, debit, opening_bal, closing_bal) SELECT entryDate, officeid, totalCredit, totalDebit, opening, (opening+totalCredit)-totalDebit;          

          SELECT entryDate INTO prevDate;

         END IF;
        END IF;

      END LOOP prepare_balance;
     CLOSE date_cursor;
    END BLOCK2;
  END LOOP find_txn_date;
 END#
DELIMITER ; 



DROP TABLE IF EXISTS daily_sheet;
CREATE TABLE `daily_sheet` (
  `entry_date` date NOT NULL,
  `office_id` bigint(20) DEFAULT NULL,
  `details` varchar(250) DEFAULT NULL,
  `credit` decimal(19,6) DEFAULT '0.000000',
  `debit` decimal(19,6) DEFAULT '0.000000',
  `entry_order` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;
DROP PROCEDURE IF EXISTS generate_daily_sheet;

DELIMITER #
CREATE PROCEDURE generate_daily_sheet()
BEGIN
 DECLARE office_done BOOLEAN DEFAULT FALSE; 
 DECLARE officeid INT DEFAULT 0; 
 DECLARE office_cursor CURSOR FOR  select DISTINCT office_id as office_id from BALANCE_SHEET;
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
     DECLARE date_cursor CURSOR FOR select DISTINCT entry_date as entry_date from BALANCE_SHEET WHERE office_id=officeid order by entry_date asc;
     DECLARE CONTINUE HANDLER FOR NOT FOUND SET date_done = TRUE;
     OPEN date_cursor;
      prepare_balance:LOOP
       FETCH date_cursor INTO entryDate;
        IF date_done THEN
         LEAVE prepare_balance;
        END IF;
       
        INSERT INTO daily_sheet(entry_date, office_id, details, credit, debit, entry_order) 
        SELECT entryDate, officeid, "Opening Balance", opening_bal as credit, 0 as debit, 0 as entry_order FROM BALANCE_SHEET WHERE entry_date=entryDate AND office_id=officeid;

        INSERT INTO daily_sheet(entry_date, office_id, details, credit, debit, entry_order) 
        SELECT entryDate, officeid, "Inbound Cash transfer", ifnull(sum(amount),0) as credit, 0 as debit, 1 entry_order FROM SAMPLE_CREDIT_MANUAL WHERE entry_date=entryDate AND office_id=officeid;

        INSERT INTO daily_sheet(entry_date, office_id, details, credit, debit, entry_order) 
        SELECT entryDate, officeid, CONCAT("Collection for ",a.display_name) as details, SUM(amount) as credit, 0 as debit, 3 as entry_order FROM SAMPLE_CREDIT_SYSTEM a WHERE a.entry_date=entryDate AND office_id=officeid GROUP BY a.display_name;

        INSERT INTO daily_sheet(entry_date, office_id, details, credit, debit, entry_order) 
        SELECT entryDate, officeid, CONCAT("Loan disbursal for ",a.display_name) as details, 0 as credit, SUM(amount) as debit, 4 as entry_order FROM SAMPLE_DEBIT_SYSTEM a WHERE a.entry_date=entryDate AND office_id=officeid GROUP BY a.office_id;

        INSERT INTO daily_sheet(entry_date, office_id, details, credit, debit, entry_order) 
        SELECT entryDate, officeid, a.name as details, 0 AS credit, amount as debit, 5 as entry_order from SAMPLE_DEBIT_MANUAL a WHERE a.entry_date=entryDate AND office_id=officeid;

        INSERT INTO daily_sheet(entry_date, office_id, details, credit, debit, entry_order) 
        SELECT entryDate, officeid, "Closing Balance", 0 as credit, closing_bal as debit, 6 as entry_order FROM BALANCE_SHEET WHERE entry_date=entryDate AND office_id=officeid;

        INSERT INTO daily_sheet(entry_date, office_id, details, credit, debit, entry_order) 
        SELECT entryDate, officeid, "Total Credit/Debit", opening_bal+credit as credit, closing_bal+debit as debit, 7 as entry_order FROM BALANCE_SHEET WHERE entry_date=entryDate AND office_id=officeid;

        
      END LOOP prepare_balance;
     CLOSE date_cursor;
    END BLOCK2;
  END LOOP find_txn_date;
 END#
DELIMITER ; 



SELECT bs.details as "Details",
  bs.credit as "Incoming credit",
  bs.debit as "Outgoing debit"    
  FROM m_office mo
    JOIN m_office ounder ON ounder.hierarchy LIKE CONCAT(mo.hierarchy, '%')
    AND ounder.hierarchy like CONCAT('.', '%')
    INNER JOIN day_sheet bs ON bs.office_id=ounder.id     
    WHERE mo.id=39    
  AND bs.entry_date = '2017-04-01'  ORDER BY bs.entry_order asc


SELECT bs.details as "Details",
  bs.credit as "Incoming credit",
  bs.debit as "Outgoing debit"
  FROM m_office mo
    JOIN m_office ounder ON ounder.hierarchy LIKE CONCAT(mo.hierarchy, '%')
    AND ounder.hierarchy like CONCAT('${currentUserHierarchy}', '%')
    INNER JOIN day_sheet bs ON bs.office_id=ounder.id     
    WHERE mo.id=${officeId}   
  AND bs.entry_date in ('${startDate}')  ORDER BY bs.entry_order asc



SELECT bs.details as "Details",
  bs.credit as "Incoming credit",
  bs.debit as "Outgoing debit"    
  FROM m_office mo
    JOIN m_office ounder ON ounder.hierarchy LIKE CONCAT(mo.hierarchy, '%')
    AND ounder.hierarchy like CONCAT('.', '%')
    INNER JOIN day_sheet bs ON bs.office_id=ounder.id     
    WHERE mo.id=1    
  AND bs.entry_date = '2017-04-01'  ORDER BY bs.entry_order asc

Stored procedure meant for executing day sheet generation on cron
--------------------------------------------------------------------
DELIMITER ;
DROP PROCEDURE IF EXISTS day_sheet_generator;

DELIMITER #
CREATE PROCEDURE day_sheet_generator()
BEGIN
  TRUNCATE BALANCE_SHEET; 
  CALL generate_balance_sheet();
  TRUNCATE daily_sheet;
  CALL generate_daily_sheet();
  DROP TABLE day_sheet;
  CREATE TABLE day_sheet AS SELECT * FROM daily_sheet;
END#
DELIMITER ;
