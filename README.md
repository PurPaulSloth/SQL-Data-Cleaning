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
    * [Describe the SQL queries used to standardize data formats and correct data types. E.g., "Used `UPDATE` statements with `CAST` and `CONVERT` functions to standardize date formats and correct data types."]
    * ```sql
        -- Example query (adapt to your specific case)
        UPDATE table_name
        SET date_column = STR_TO_DATE(date_column, '%m/%d/%Y')
        WHERE date_column LIKE '%/%/%';
        ```
* **Missing Value Handling:**
    * [Describe the SQL queries used to handle missing values. E.g., "Used `UPDATE` statements with `CASE` statements to replace missing values with appropriate defaults or calculated values."]
    * ```sql
        -- Example query (adapt to your specific case)
        UPDATE table_name
        SET column_name = 'Unknown'
        WHERE column_name IS NULL;
        ```
* **Inconsistency Resolution:**
    * [Describe the steps you took to resolve inconsistencies, e.g., "Used `UPDATE` and `REPLACE` to fix inconsistent naming conventions."]

## Key Skills Demonstrated

* Identifying and removing duplicate records.
* Standardizing data formats and correcting data types.
* Handling missing values and inconsistencies.
* Using SQL queries for data preprocessing.

## How to Use This Project

1.  Set up a MySQL database.
2.  Run the SQL scripts located in the `scripts/` folder to create the tables.
3.  Import the raw data into the tables.
4.  Run the SQL cleaning scripts to process the data.
5.  Examine the cleaned data to verify the results.

## Acknowledgments

This project was completed as a guided exercise from Alex the Analyst's bootcamp.
