-- EDA 

-- 5 Largest laid offs 
SELECT 
    *
FROM
    layoffs2
ORDER BY total_laid_off DESC
LIMIT 5;

-- Total employees laid off by industry 
SELECT 
    industry, SUM(total_laid_off)
FROM
    layoffs2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC
;

-- Average and total employees laid off by year
SELECT 
    YEAR(`date`) AS `year`,
    ROUND(AVG(total_laid_off), 2) AS avg_laid_off,
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs2
WHERE
    YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC
;

-- employees laid off count by ountry
SELECT 
    country, COUNT(*) AS laid_off_count
FROM
    layoffs2
GROUP BY country
ORDER BY laid_off_count DESC
;

-- layoffs by company stage
SELECT 
    stage,
    COUNT(*) AS laid_off_count,
    SUM(total_laid_off) AS total_layoffs
FROM
    layoffs2
GROUP BY stage
ORDER BY total_layoffs DESC
;


-- Commpanies that had multiple layoffs
SELECT 
    company, COUNT(*) AS layoffs_count
FROM
    layoffs2
GROUP BY company
HAVING layoffs_count > 1
ORDER BY layoffs_count DESC
;

-- companies that shut down "100% layoffs"
SELECT 
    *
FROM
    layoffs2
WHERE
    percentage_laid_off = 1
ORDER BY `date`
;

-- Rolling total of layoffs per month
WITH dates_cte AS (
	SELECT SUBSTRING(`date`,1,7) as dates, SUM(total_laid_off) AS total_laid_off
	FROM layoffs2
	GROUP BY dates
	ORDER BY dates ASC
) 
SELECT 
	dates, SUM(total_laid_off) OVER(ORDER BY dates ASC) AS rolling_total
FROM dates_cte
ORDER BY dates ASC
;    
    
    
-- Finding the month with the highest number of layoffs for each year
WITH monthly_layoffs AS (
    SELECT 
        YEAR(`date`) AS `year`, MONTH(`date`) AS `month`, SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs2
    WHERE total_laid_off IS NOT NULL 
    GROUP BY `year`, `month`
)
SELECT 
    `year`, `month`, monthly_layoffs
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY `year` ORDER BY monthly_layoffs DESC) AS rn
    FROM monthly_layoffs
) ranked
WHERE rn = 1 AND `year` IS NOT NULL
ORDER BY `year`, `month`;


-- Finding top 3 the companies with most layoffs per year 
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS `year`, SUM(total_laid_off) AS total_laid_off
  FROM layoffs2
  GROUP BY company, `year`
)
, Company_Year_Rank AS (
  SELECT company, `year`, total_laid_off, DENSE_RANK() OVER (PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, `year`, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND `year` IS NOT NULL
ORDER BY `year` ASC, total_laid_off DESC;



