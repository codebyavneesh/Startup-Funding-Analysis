1. Data Source
The dataset is taken from Kaggle: Indian Startup Funding by Sudalai Rajkumar.

Link: https://www.kaggle.com/datasets/sudalairajkumar/indian-startup-funding

2. Data Overview
File Name: startup_funding.csv

Size: 425.8 KB

Time Period: January 2015 to August 2017

Total Records: ~548 rows

Total Columns: 10

3. Column Description
Column Name	Description
S.No	Serial number
Date	Date of funding (dd/mm/yyyy)
Startup Name	Name of the startup
Industry Vertical	Main sector of the startup
Industry Sub-vertical	Specific sub-sector
City Location	City where startup is based
Investors Name	Names of investors (may contain multiple)
Investment Type	Type of funding (Seed, Angel, Private Equity, etc.)
Amount in USD	Funding amount in US Dollars
Remarks	Any additional remarks (mostly blank)
4. Known Data Quality Issues (To Be Addressed in Cleaning)
Date Column: Contains dates in dd/mm/yyyy format (needs conversion).

Amount in USD: Contains commas (e.g., "10,00,000") and "N/A" values.

Investment Type: Inconsistent values (e.g., "Seed", "Seed Funding", "Seed Round" mean the same thing).

Investors Name: May have multiple investors in one cell (needs splitting or handling).

Missing Values: Some columns have null or blank values (especially Sub-vertical and Remarks).

5. Data Preparation Plan
  1. Load data using Pandas.

  2. Convert Date to datetime format.
  
  3. Clean Amount in USD (remove commas, handle N/A).
   
  4. Standardize Investment Type values.
   
  5. Handle missing values (decide to drop or fill).
   
  6. Load cleaned data into SQL database for analysis.