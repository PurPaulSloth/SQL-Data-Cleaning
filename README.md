# SQL Data Cleaning

## Project Overview

This project is my first SQL data cleaning exercise, completed as part of Alex the Analyst's bootcamp. It focuses on demonstrating fundamental SQL skills for data preprocessing and quality control. The goal was to take a raw dataset and prepare it for analysis by addressing common data inconsistencies and errors.

## Project Goals

* Identify and handle duplicate records.
* Standardize data formats and correct data types.
* Address missing values and inconsistencies.
* Transform the data into a clean, analysis-ready dataset.

## Data Description

* **Data Source:** [Provided as part of the Alex the Analyst YT bootcamp] (https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv)
* **Dataset Overview:** [This data set contains companies layoffs around the world.It has a total of 9 columns  which includes company, location,industry,total_laid_off,percentage of the laid off, company stage, country, and its fund raised in millions]
* **Initial Data Issues:** [Non-Standard data and data types, Dealing with Nulls, Contains Duplicates and Unnecessary rows.]

## Cleaning Methodology

* **Duplicate Handling:**
    * I used a Common Table Expression (CTE) with the `ROW_NUMBER()` window function partitioned by key identifying columns (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) to assign a unique row number to each record. Subsequently, duplicates were identified by filtering for `row_num` values greater than 1, and these duplicates were then deleted from a new staging table (`layoffs_staging2`).
    * ```sql
      -- CTE to identify duplicates
      WITH duplicate_cte AS (
          SELECT *,
                 ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ORDER BY company) AS row_num
          FROM layoffs_staging
      )
      -- Select duplicates for verification
      SELECT *
      FROM duplicate_cte
      WHERE row_num > 1;

      -- Create new staging table with row_num
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

      -- Insert data into the new table with row_num
      INSERT INTO layoffs_staging2
      SELECT *,
             ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ORDER BY company) AS row_num
      FROM layoffs_staging;

      -- Verify duplicates in the new table
      SELECT *
      FROM layoffs_staging2
      WHERE row_num > 1;

      -- Delete duplicates from the new table
      DELETE FROM layoffs_staging2
      WHERE row_num > 1;
    ```

* **Data Standardization and Type Correction:**
    * I Performed data standardization and type correction by trimming whitespace from text fields, converting date strings to date format using `STR_TO_DATE`, altering the table structure to change the `date` column type, and standardizing capitalization and removing trailing periods from the `country` column.
    * ```sql
      -- Trim whitespace from company, location, and industry columns
      UPDATE layoffs_staging2
      SET company = TRIM(company),
          location = TRIM(location),
          industry = TRIM(industry);

      -- Standardize 'Crypto' industry
      UPDATE layoffs_staging2
      SET industry = 'Crypto'
      WHERE industry LIKE 'Crypto%';

      -- Convert date strings to date format
      UPDATE layoffs_staging2
      SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

      -- Alter table to change date column type to DATE
      ALTER TABLE layoffs_staging2
      MODIFY COLUMN `date` DATE;

      -- Remove trailing periods from country column
      UPDATE layoffs_staging2
      SET country = TRIM(TRAILING '.' FROM country);
    ```
    
* **Handling Nulls and Blanks:**
    *I Addressed null and blank values in the dataset. I Identified records with null values in both `total_laid_off` and `percentage_laid_off` columns. Standardized blank `industry` values to null. Implemented a self-join to populate missing `industry` values based on matching `company` and `country` records where available.
    * ```sql
      -- Identify records with null values in total_laid_off and percentage_laid_off
      SELECT *
      FROM layoffs_staging2
      WHERE total_laid_off IS NULL
      AND percentage_laid_off IS NULL;

      -- Standardize blank industry values to null
      UPDATE layoffs_staging2
      SET industry = NULL
      WHERE industry = '';

      -- Verify null industry values
      SELECT *
      FROM layoffs_staging2
      WHERE industry IS NULL
      OR industry = '';

      -- Identify records with null industry and corresponding non-null industry records
      SELECT T1.industry, T2.industry
      FROM layoffs_staging2 AS T1
      JOIN layoffs_staging2 AS T2
          ON T1.company = T2.company
          AND T1.country = T2.country
      WHERE (T1.industry IS NULL OR T1.industry = '')
      AND T2.industry IS NOT NULL;

      -- Populate null industry values using self-join
      UPDATE layoffs_staging2 AS T1
      JOIN layoffs_staging2 AS T2
          ON T1.company = T2.company
      SET T1.industry = T2.industry
      WHERE T1.industry IS NULL
      AND T2.industry IS NOT NULL;
    ```
* **Removing Unnecessary Columns and Rows:**
    * Removed unnecessary rows where both `total_laid_off` and `percentage_laid_off` were null, as these records provided minimal analytical value. Also, dropped the `row_num` column, which was used for duplicate identification and was no longer needed after the cleaning process.
    * ```sql
      -- Identify rows with null values in total_laid_off and percentage_laid_off
      SELECT *
      FROM layoffs_staging2
      WHERE total_laid_off IS NULL
      AND percentage_laid_off IS NULL;

      -- Delete rows with null values in total_laid_off and percentage_laid_off
      DELETE FROM layoffs_staging2
      WHERE total_laid_off IS NULL
      AND percentage_laid_off IS NULL;

      -- Remove the row_num column
      ALTER TABLE layoffs_staging2
      DROP COLUMN row_num;
    ```
## Key Skills Demonstrated

* Identifying and removing duplicate records.
* Standardizing data formats and correcting data types.
* Handling missing values and inconsistencies.
* Using SQL queries for data preprocessing.


## Acknowledgments

This project was completed as a guided exercise from Alex the Analyst's bootcamp.
