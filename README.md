# World Life Expectancy — Data Cleaning & SQL Analysis

## Overview
This project analyzes global life expectancy data spanning multiple years and countries, alongside health and economic indicators (GDP, BMI, adult mortality, immunization rates, schooling, etc.). The workflow covers cleaning a messy real-world dataset — handling duplicates, missing values, and blank fields — followed by exploratory SQL analysis to uncover trends in global health and its relationship to economic development.

## Dataset
- **`world_life_expectancy`** — ~2,940 records covering multiple countries across multiple years, including life expectancy, adult mortality, GDP, BMI, immunization rates (Polio, Diphtheria), HIV/AIDS prevalence, schooling, and development status (Developed/Developing)

Source files included:
- `data/raw/World_Life_Expectancy_Original.csv` — raw, uncleaned data
- `data/cleaned/World_Life_Expectancy_Edited.csv` — cleaned data, ready for analysis

## Tools Used
- **SQL (MySQL)** — data cleaning, window functions, conditional aggregation, and exploratory data analysis

## Data Cleaning
The raw dataset had several real-world data quality issues that were addressed in `World_Life_Expectancy_Analysis.sql`:

- **Removed duplicate records**: Used `ROW_NUMBER()` with `PARTITION BY` to identify duplicate Country/Year combinations, then deleted the duplicate rows
- **Filled in missing `Status` values**: Some rows had a blank Development Status. Since a country's status (Developed/Developing) doesn't change year to year, missing values were filled by self-joining the table on `Country` and copying the status from other rows for the same country
- **Filled in missing `Life expectancy` values**: Used a self-join across consecutive years (the year before and after a gap) to estimate missing life expectancy values as the average of the surrounding years — a simple linear interpolation approach

## Exploratory Analysis
The SQL script answers questions including:
- Which countries saw the largest increase in life expectancy over the period covered?
- How has average global life expectancy changed year over year?
- How does GDP relate to life expectancy?
- How does a country's development status (Developed vs. Developing) relate to life expectancy?
- How does BMI relate to life expectancy?
- How does adult mortality accumulate over time per country (using a running total via window functions)?

## Key Insights
- **Biggest gains in life expectancy**: Haiti saw the largest increase of any country in the dataset, rising from 36.3 to 65.0 years — a 28.7-year increase. Zimbabwe, Eritrea, Uganda, and Rwanda also saw large gains (19-23 years), suggesting major recoveries from crises like conflict, disease epidemics, or natural disasters during the earlier years of the dataset.
- **Global life expectancy is rising**: The global average increased steadily from about 66.8 years (2007) to 71.6 years (2022) — nearly a 5-year gain over 15 years.
- **GDP and life expectancy are strongly linked**: Countries with GDP ≥ 1,000 have an average life expectancy of 73.5 years, compared to 65.0 years for countries below that threshold — a gap of roughly 9 years. Across all countries, GDP and life expectancy show a strong positive correlation (~0.61).
- **Development status matters even more**: "Developed" countries average 79.2 years of life expectancy vs. 66.8 years for "Developing" countries — a 12.4-year gap, larger than the GDP-based split alone, suggesting development status captures broader factors (healthcare access, infrastructure, education) beyond GDP alone.
- **BMI shows a surprisingly strong correlation (~0.72) with life expectancy** — but this is almost certainly not a direct causal relationship. It likely reflects that higher average BMI in this dataset is associated with wealthier, more developed countries (where obesity is more common but healthcare access is also better), rather than higher BMI directly causing longer life. Worth flagging as a "correlation isn't causation" example.

## How to Use
1. Import `data/cleaned/World_Life_Expectancy_Edited.csv` into a MySQL database as a table named `world_life_expectancy`
2. Run `World_Life_Expectancy_Analysis.sql` to reproduce the cleaning steps and exploratory queries
