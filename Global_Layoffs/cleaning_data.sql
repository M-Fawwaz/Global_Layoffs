-- DATA CLEANING
SET SQL_SAFE_UPDATES = 0;
use global_layoffs;

SELECT * FROM layoffs;

-- Membuat Tabel Baru Karena Tidak Mungkin Mengubah Raw Data (Database Asli)
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging 
SELECT * FROM layoffs;

-- Checking Duplicate
WITH duplicate_data AS (
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS dupes
FROM layoffs_staging
)
SELECT company, dupes FROM duplicate_data
WHERE dups > 1;

SELECT * FROM layoffs_staging
where company = 'Hibob'

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `dupes` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS dupes
FROM layoffs_staging

SELECT * FROM layoffs_staging2
WHERE dupes >1

-- DELETE DUPES
DELETE FROM layoffs_staging2
WHERE dupes > 1;

ALTER TABLE layoffs_staging2
DROP COLUMN dupes

-- Standarizing Data --
SELECT company,
 TRIM(company)  FROM layoffs_staging2
 
UPDATE layoffs_staging2
SET company = TRIM(company)

SELECT DISTINCT * FROM layoffs_staging2
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE  'Crypto%'

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1 

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'

SELECT `date`
FROM layoffs_staging2

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT `date`
FROM layoffs_staging2
WHERE `date` IS NULL;

DELETE FROM layoffs_staging2
WHERE `date` IS null

SELECT * FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''

SELECT * FROM layoffs_staging2
WHERE company = 'Airbnb'

SELECT t1.industry,
	   t2.industry
FROM layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
	 ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL

UPDATE layoffs_staging2
SET industry = NULL
where industry = ''

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 as t2
	 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL

-- Tidak membutuhkan data tersebut
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL

