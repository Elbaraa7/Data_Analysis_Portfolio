-- Data cleaning

-- Creating a backup table
CREATE TABLE sales_backup LIKE sales
;

INSERT sales_backup
SELECT *
FROM sales
;


-- Standardize columns names
ALTER TABLE sales
RENAME COLUMN `Transaction ID` TO transaction_id,
RENAME COLUMN `Item` TO item,
RENAME COLUMN `Quantity` TO quantity,
RENAME COLUMN `Price Per Unit` TO unit_price,
RENAME COLUMN `Total Spent` TO total_spent,
RENAME COLUMN `Payment Method` TO payment_method,
RENAME COLUMN `Location` TO location,
RENAME COLUMN `Transaction Date` TO transaction_date
;


-- creating new cleaned unit_price column
-- Checking for invalid data
SELECT DISTINCT
    (unit_price)
FROM
    sales
;

-- Getting the unit_price for items
SELECT DISTINCT
    item, unit_price
FROM
    sales
WHERE
    item NOT IN ('' , 'ERROR', 'UNKNOWN')
        AND unit_price NOT IN ('' , 'ERROR', 'UNKNOWN');


-- Creating new unit_price column with correct prices
ALTER TABLE sales 
ADD COLUMN unit_price_new DECIMAL(6,2);

UPDATE sales 
SET 
    unit_price_new = CASE
        WHEN unit_price NOT IN ('' , 'ERROR', 'UNKNOWN') THEN unit_price
        WHEN
            unit_price IN ('' , 'ERROR', 'UNKNOWN')
                AND item = 'Coffee'
        THEN
            2.00
        WHEN
            unit_price IN ('' , 'ERROR', 'UNKNOWN')
                AND item = 'Cake'
        THEN
            3.00
        WHEN
            unit_price IN ('' , 'ERROR', 'UNKNOWN')
                AND item = 'Cookie'
        THEN
            1.00
        WHEN
            unit_price IN ('' , 'ERROR', 'UNKNOWN')
                AND item = 'Salad'
        THEN
            5.00
        WHEN
            unit_price IN ('' , 'ERROR', 'UNKNOWN')
                AND item = 'Smoothie'
        THEN
            4.00
        WHEN
            unit_price IN ('' , 'ERROR', 'UNKNOWN')
                AND item = 'Sandwich'
        THEN
            4.00
        WHEN
            unit_price IN ('' , 'ERROR', 'UNKNOWN')
                AND item = 'Juice'
        THEN
            3.00
        WHEN
            unit_price IN ('' , 'ERROR', 'UNKNOWN')
                AND item = 'Tea'
        THEN
            1.50
        WHEN
            unit_price IN ('' , 'ERROR', 'UNKNOWN')
                AND item IN ('' , 'ERROR', 'UNKNOWN')
                AND total_spent NOT IN ('' , 'ERROR', 'UNKNOWN')
                AND quantity <> 0
        THEN
            CAST(total_spent / quantity AS DECIMAL (6 , 2 ))
        ELSE NULL
    END
;


-- Creating cleaned item column
-- Create new item column
ALTER TABLE sales 
ADD COLUMN item_new TEXT
;

-- Items with same prices cannot be determined, only items with distinct price can be imputed
UPDATE sales 
SET 
    item_new = CASE
        WHEN item NOT IN ('' , 'ERROR', 'UNKNOWN') THEN item
        WHEN
            item IN ('' , 'ERROR', 'UNKNOWN')
                AND unit_price_new = 2.00
        THEN
            'Coffee'
        WHEN
            item IN ('' , 'ERROR', 'UNKNOWN')
                AND unit_price_new = 1.00
        THEN
            'Cookie'
        WHEN
            item IN ('' , 'ERROR', 'UNKNOWN')
                AND unit_price_new = 1.50
        THEN
            'Tea'
        WHEN
            item IN ('' , 'ERROR', 'UNKNOWN')
                AND unit_price_new = 5.00
        THEN
            'Salad'
        ELSE NULL
    END
;


-- creating clean quantity column
-- create new quantity column
ALTER TABLE sales 
ADD COLUMN quantity_new INT
;

UPDATE sales 
SET 
    quantity_new = CASE
        WHEN quantity NOT IN ('' , 'ERROR', 'UNKNOWN') THEN quantity
        WHEN
            quantity IN ('' , 'ERROR', 'UNKNOWN')
                AND total_spent NOT IN ('' , 'ERROR', 'UNKNOWN')
        THEN
            (total_spent / unit_price_new)
        ELSE NULL
    END
;    


-- Clean total_spent column
-- Create new total_spent column
ALTER TABLE sales 
ADD COLUMN total_spent_new DECIMAL(9,2)
;

-- Creating new cleaned total column
UPDATE sales 
SET 
    total_spent_new = CASE
        WHEN total_spent NOT IN ('' , 'ERROR', 'UNKNOWN') THEN total_spent
        WHEN
            total_spent IN ('' , 'ERROR', 'UNKNOWN')
                AND quantity_new IS NOT NULL
        THEN
            (unit_price_new * quantity_new)
        ELSE NULL
    END
;


-- Creating new payment_method changing invalid values to null
ALTER TABLE sales 
ADD COLUMN payment_method_new TEXT
;

UPDATE sales 
SET 
    payment_method_new = CASE
        WHEN payment_method NOT IN ('' , 'ERROR', 'UNKNOWN') THEN payment_method
        ELSE NULL
    END
;


-- Creating new location changing invalid values to null
ALTER TABLE sales 
ADD COLUMN location_new TEXT
;

UPDATE sales 
SET 
    location_new = CASE
        WHEN location NOT IN ('' , 'ERROR', 'UNKNOWN') THEN location
        ELSE NULL
    END
;

-- Creating new payment_method changing invalid values to null
ALTER TABLE sales 
ADD COLUMN transaction_date_new DATE
;

UPDATE sales 
SET 
    transaction_date_new = CASE
        WHEN transaction_date NOT IN ('' , 'ERROR', 'UNKNOWN') THEN transaction_date
        ELSE NULL
    END
;


-- Moving cleaned columns to a new table
CREATE TABLE sales2 LIKE sales
;

CREATE TABLE `sales2` (
    `transaction_id` TEXT,
    `item` TEXT,
    `quantity` INT,
    `unit_price` DECIMAL(6 , 2 ),
    `total_spent` DECIMAL(9 , 2 ),
    `payment_method` TEXT,
    `location` TEXT,
    `transaction_date` DATE
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;

INSERT INTO sales2 (transaction_id, item, quantity, unit_price, total_spent, payment_method, location, transaction_date)
SELECT 
    transaction_id, item_new, quantity_new, unit_price_new, total_spent_new, payment_method_new, location_new, transaction_date_new
FROM sales
;

-- Clean rows with no usable informations
DELETE FROM sales2
WHERE total_spent IS NULL;


