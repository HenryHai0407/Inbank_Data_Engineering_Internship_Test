-- Hi, my name is Hai. Here is my solution regarding to this assignment :)
-- Please run this query in MySQL platform, it would return some syntax errors if you are using another platform, thank you in advance :)
-- Create queries
create TABLE if not exists BLACKLIST (
	USER_ID NUMERIC(38,0),
	BLACKLIST_CODE NUMERIC(38,0),
	BLACKLIST_START_DATE DATE,
	BLACKLIST_END_DATE DATE
);

create TABLE if not exists CURRENCIES (
	CURRENCY_ID NUMERIC(38,0),
	CURRENCY_CODE VARCHAR(50),
	START_DATE DATE,
	END_DATE DATE
);

create TABLE if not exists CURRENCY_RATES (
	CURRENCY_ID NUMERIC(38,0),
	EXCHANGE_RATE_TO_EUR NUMERIC(38,2),
	EXCHANGE_DATE DATE
);

create TABLE if not exists PAYMENTS (
	USER_ID_SENDER NUMERIC(38,0),
	CONTRACT_ID NUMERIC(38,0),
	AMOUNT NUMERIC(38,2),
	CURRENCY NUMERIC(38,0),
	TRANSACTION_DATE DATE
);

INSERT INTO BLACKLIST (USER_ID,BLACKLIST_CODE,BLACKLIST_START_DATE,BLACKLIST_END_DATE) VALUES
	 (3837,101,'2022-01-01',NULL);
	
INSERT INTO CURRENCIES (CURRENCY_ID,CURRENCY_CODE,START_DATE,END_DATE) VALUES
	 (111,'EUR','1999-01-01',NULL),
	 (222,'PLN','1995-01-01',NULL),
	 (333,'CZK','1993-01-01',NULL),
	 (444,'HRK','1994-05-30','2022-12-31'),
	 (555,'YUM','1994-01-01','2003-01-01');
	
INSERT INTO CURRENCY_RATES (CURRENCY_ID,EXCHANGE_RATE_TO_EUR,EXCHANGE_DATE) VALUES
	 (222,0.19,'2023-01-05'),
	 (222,0.20,'2023-02-05'),
	 (222,0.21,'2023-03-05');

INSERT INTO PAYMENTS (USER_ID_SENDER,CONTRACT_ID,AMOUNT,CURRENCY,TRANSACTION_DATE) VALUES
	 (9863,786283,10,111,'2023-01-05'),
	 (7619,379828,34,111,'2023-01-05'),
	 (8472,367139,750,444,'2023-01-05'),
	 (9382,382033,378,222,'2023-01-05'),
	 (3837,789912,82,111,'2023-02-05'),
	 (9863,786283,19,111,'2023-02-05'),
	 (9382,382033,406,222,'2023-02-05'),
	 (9863,786283,53,111,'2023-03-05'),
	 (5673,372832,640,444,'2023-03-05'),
	 (7619,379828,34,111,'2023-03-05');
INSERT INTO PAYMENTS (USER_ID_SENDER,CONTRACT_ID,AMOUNT,CURRENCY,TRANSACTION_DATE) VALUES
	 (5321,466423,231,111,'2023-03-05');
     
-- Part 1: Write a query to return the amounts in euros aggregated by transaction_date
-- 1/ Create criteria filtered table
WITH cte as
(SELECT *
FROM Payments
WHERE USER_ID_SENDER NOT IN (SELECT USER_ID FROM Blacklist) -- Excluding blacklist users from Payments table
AND CURRENCY NOT IN (SELECT CURRENCY_ID FROM Currencies WHERE Currencies.END_DATE is NOT NULL) -- Excluding users who have discontinued currencies
),

-- 2/ Turning all payment' values into the same currency (EUR) through joining with Currency_rates table and returning required calculation
	-- a/ Joining 2 tables
 cte2 as
(select *
FROM cte
LEFT JOIN currency_rates as rate1
ON (cte.CURRENCY = rate1.CURRENCY_ID and cte.TRANSACTION_DATE = rate1.EXCHANGE_DATE)
),
	-- b/ Converting currencies into the desired currency (EUR)
  cte3 as
(SELECT TRANSACTION_DATE,
CASE WHEN CURRENCY = CURRENCY_ID THEN AMOUNT * EXCHANGE_RATE_TO_EUR
ELSE AMOUNT
END as AMOUNT_EUR
FROM cte2) 
	-- c/ Return the amounts in euros aggregated by transaction_date
SELECT SUM(AMOUNT_EUR), TRANSACTION_DATE
FROM cte3
GROUP BY TRANSACTION_DATE;
