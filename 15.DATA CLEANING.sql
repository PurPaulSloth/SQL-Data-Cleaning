-- DATA CLEANING RETAKE
Select* 
from world_layofss2.layoffs;

CREATE TABLE Layoffs_staging
LIKE world_layofss2.layoffs;

Select* 
from Layoffs_staging;

INSERT layoffs_staging
SELECT*
FROM world_layofss2.layoffs;

-- FIND DUPLICATES AND REMOVE IT

WITH duplicate_cte AS
(Select*,
ROW_NUMBER() OVER (PARTITION BY 
	company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions Order by company)  AS row_num
FROM layoffs_staging)

Select *
FROM Duplicate_cte
where row_num > 1;

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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
Select*, ROW_NUMBER() OVER (PARTITION BY 
	company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions Order by company)  AS row_num
FROM layoffs_staging;

SELECT*
FROM layoffs_staging2
Where row_num > 1;

DELETE FROM layoffs_staging2
Where row_num > 1;

-- Standardizing Data

Select *
from layoffs_staging2;

Update layoffs_staging2
SET company = TRIM(company),
	location = TRIM(location),
    industry = TRIM(industry);
    
Select DISTINCT industry
From layoffs_staging2
Order by 1;

Select *
from layoffs_staging2
where industry like 'Crypto%';

Update layoffs_staging2
Set industry = 'Crypto'
Where industry like 'Crypto%';

Select `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') as Formated_Date
From layoffs_staging2;

UPDATE layoffs_staging2 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

Alter Table world_layofss2.layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT distinct COUNTRY
from layoffs_staging2
order by 1;

SELECT DISTINCT country, TRIM(trailing '.' FROM COUNTRY)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET country = TRIM(trailing '.' FROM COUNTRY);

-- Dealing with Nulls and Blanks



Select* 
FROM world_layofss2.layoffs_staging2
Where total_laid_off is Null
and percentage_laid_off is Null;

Update layoffs_staging2
Set industry = null
Where industry ='';


Select*
from layoffs_staging2
where industry is null
or industry ='';

Select T1.industry, T2.industry
from layoffs_staging2 as T1
Join layoffs_staging2 as T2
	On T1.company = T2.company
    And T1.country = T2.country
Where (T1.industry is null OR T1.industry = '')
and T2.industry is not null;

UPDATE layoffs_staging2 as T1
Join layoffs_staging2 as T2
	on T1.company = T2.company
Set T1.industry = T2.industry
Where T1.industry is null 
and T2.industry is not null;


-- Removing unnecessary Collumn and Rows
Select*
from layoffs_staging2;

Select*
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

Delete
From layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

ALTER TABLE layoffs_staging2
Drop column row_num;

    
    
    