-- Data Cleaning

-- Creating backup for the data
CREATE TABLE layoffs_backup LIKE layoffs
; 

INSERT layoffs_backup 
SELECT *
FROM layoffs
;

-- Removing Duplicates

-- Checking for duplicates 
SELECT * FROM (
	SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
		`date`, stage, country, funds_raised_millions) AS rn
	FROM layoffs) AS test
WHERE rn >1
;

-- Creating A new table with no duplicates
CREATE TABLE layoffs2 AS
SELECT * FROM (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
		`date`, stage, country, funds_raised_millions) AS rn
    FROM layoffs
) AS deduplicated
WHERE rn = 1
;

-- Deleting rn column
ALTER TABLE layoffs2
DROP COLUMN rn
;


-- Standardizing the data

-- Cleaning the company column
SELECT DISTINCT
    company
FROM
    layoffs2
ORDER BY 1
;

UPDATE layoffs2 
SET 
    company = TRIM(company)
;


-- Clean industry column
SELECT DISTINCT
    industry
FROM
    layoffs2
ORDER BY 1
;

SELECT 
    *
FROM
    layoffs2
WHERE
    industry LIKE '%cryp%'
; 

UPDATE layoffs2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE '%crypto%'
; 

SELECT 
    *
FROM
    layoffs2
WHERE
    industry IS NULL OR industry = ''
ORDER BY industry
;

-- Setting blanks to nulls 
UPDATE layoffs2 
SET 
    industry = NULL
WHERE
    industry = ''
;

-- Updating null values in industry column with non-null values from matching company rows.
SELECT 
    *
FROM
    layoffs2 l1
        JOIN
    layoffs2 l2 ON l1.company = l2.company
WHERE
    l1.industry IS NULL
        AND l2.industry IS NOT NULL
;

UPDATE layoffs2 l1
        JOIN
    layoffs2 l2 ON l1.company = l2.company 
SET 
    l1.industry = l2.industry
WHERE
    l1.industry IS NULL
        AND l2.industry IS NOT NULL
;

-- Check location column 
SELECT DISTINCT
    location
FROM
    layoffs2
ORDER BY 1
;

-- Clean country column
SELECT DISTINCT
    country
FROM
    layoffs2
ORDER BY 1
;

UPDATE layoffs2 
SET 
    country = 'United States'
WHERE
    country LIKE 'United States%'
;

-- Clean date column
SELECT 
    `date`
FROM
    layoffs2
;

UPDATE layoffs2 
SET 
    `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

ALTER TABLE layoffs2
MODIFY COLUMN `date` DATE
;


-- Clean rows with no usable informations
SELECT 
    *
FROM
    layoffs2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL
;

DELETE FROM layoffs2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL
;


