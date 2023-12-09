use victor;
SELECT 
    *
FROM
    presidents;

-- ===============  data exploratory and cleaning ===========================
-- Rename columns with two or more words by linking them with underscores
ALTER TABLE presidents
CHANGE COLUMN `Higher Education` Higher_Education text,
CHANGE COLUMN `Military Service` Military_Service text,
CHANGE COLUMN `Vice President` Vice_President text,
CHANGE COLUMN `Previous Office` Previous_Office text,
CHANGE COLUMN `Foreign Affairs` Foreign_Affairs text,
CHANGE COLUMN `Military Activity` Military_Activity text,
CHANGE COLUMN `Other Events` Other_Events text;

-- count the total number of records and the number of null values for each column
SELECT 
    COUNT(*) AS TotalRecords,
    SUM(CASE
        WHEN Name IS NULL THEN 1
        ELSE 0
    END) AS NullName,
    SUM(CASE
        WHEN Birthplace IS NULL THEN 1
        ELSE 0
    END) AS NullBirthplace,
    SUM(CASE
        WHEN Birthday IS NULL THEN 1
        ELSE 0
    END) AS NullBirthday,
    SUM(CASE
        WHEN Life IS NULL THEN 1
        ELSE 0
    END) AS NullLife,
    SUM(CASE
        WHEN Height IS NULL THEN 1
        ELSE 0
    END) AS NullHeight,
    SUM(CASE
        WHEN Children IS NULL THEN 1
        ELSE 0
    END) AS NullChildren,
    SUM(CASE
        WHEN Religion IS NULL THEN 1
        ELSE 0
    END) AS NullReligion,
    SUM(CASE
        WHEN Higher_Education IS NULL THEN 1
        ELSE 0
    END) AS NullHigherEducation,
    SUM(CASE
        WHEN Occupation IS NULL THEN 1
        ELSE 0
    END) AS NullOccupation,
    SUM(CASE
        WHEN Military_Service IS NULL THEN 1
        ELSE 0
    END) AS NullMilitaryService,
    SUM(CASE
        WHEN Term IS NULL THEN 1
        ELSE 0
    END) AS NullTerm,
    SUM(CASE
        WHEN Party IS NULL THEN 1
        ELSE 0
    END) AS NullParty,
    SUM(CASE
        WHEN Vice_President IS NULL THEN 1
        ELSE 0
    END) AS NullVicePresident,
    SUM(CASE
        WHEN Previous_Office IS NULL THEN 1
        ELSE 0
    END) AS NullPreviousOffice,
    SUM(CASE
        WHEN Economy IS NULL THEN 1
        ELSE 0
    END) AS NullEconomy,
    SUM(CASE
        WHEN Foreign_Affairs IS NULL THEN 1
        ELSE 0
    END) AS NullForeignAffairs,
    SUM(CASE
        WHEN Military_Activity IS NULL THEN 1
        ELSE 0
    END) AS NullMilitaryActivity,
    SUM(CASE
        WHEN Other_Events IS NULL THEN 1
        ELSE 0
    END) AS NullOtherEvents,
    SUM(CASE
        WHEN Legacy IS NULL THEN 1
        ELSE 0
    END) AS NullLegacy
FROM
    presidents;


-- Add new columns for PlaceName and StateAbbreviation
ALTER TABLE presidents
ADD COLUMN BirthPlaceName VARCHAR(255),
ADD COLUMN BirthStateAbbreviation VARCHAR(255);

-- Update the new columns with values from the Birthplace column
-- split the column in two - BirthPlaceName and BirthStateAbbreviation
UPDATE presidents 
SET 
    BirthPlaceName = TRIM(SUBSTRING_INDEX(Birthplace, ',', 1)),
    BirthStateAbbreviation = TRIM(SUBSTRING_INDEX(Birthplace, ',', - 1));

-- Move the BirthPlaceName and BirthStateAbbreviation columns after the Name column
ALTER TABLE presidents
MODIFY COLUMN BirthPlaceName VARCHAR(255) AFTER Name,
MODIFY COLUMN BirthStateAbbreviation VARCHAR(255) AFTER BirthPlaceName;

-- drop the Birthplace column after splitting
ALTER TABLE presidents
drop Birthplace ;

-- Display the updated data
SELECT 
    *
FROM
    presidents;

-- ================================================================================
--          Basic Statistics:
-- ===================================================================================
-- What is the total number of records in the dataset?
SELECT 
    COUNT(*) AS total_records
FROM
    presidents;

-- What is the average height of the presidents?
SELECT 
    ROUND(AVG(Height), 4) AS avg_height
FROM
    presidents;

-- What is the distribution of presidents based on religion? 
SELECT 
    Religion, COUNT(*) AS count_religoin
FROM
    presidents
GROUP BY Religion
ORDER BY count_religoin DESC;


-- ===============  Temporal Analysis:  ========================================
-- How many presidents were born in each state (using BirthStateAbbreviation)?
SELECT 
    BirthStateAbbreviation, COUNT(*) count_birth_state
FROM
    presidents
GROUP BY BirthStateAbbreviation
ORDER BY count_birth_state DESC;

-- What is the distribution of presidents based on birth years (using Birthday)?

SELECT 
    Birthday
FROM
    presidents;

-- Update the 'Birthday' column  convert to date type 
UPDATE presidents 
SET 
    Birthday = STR_TO_DATE(CONCAT('2000-', Birthday), '%Y-%d-%b');

-- Update the 'Birthday' column to only include day and month without year
UPDATE presidents 
SET 
    Birthday = DATE_FORMAT(Birthday, '%m-%d');


-- Count the data distribution based on the month in the 'Birthday' column
SELECT 
    DATE_FORMAT(Birthday, '%m') AS Month,
    COUNT(*) AS CountByMonth
FROM
    presidents
WHERE
    Birthday IS NOT NULL
GROUP BY Month
ORDER BY Month;

-- Display the count Birthday for each month in the 'Birthday' column
SELECT 
    SUBSTRING(Birthday, 1, 2) AS Month, COUNT(*) AS CountByMonth
FROM
    presidents
WHERE
    LENGTH(Birthday) >= 5
GROUP BY Month
ORDER BY CountByMonth DESC;


-- Can you identify any trends in the number of children presidents have?
SELECT 
    Name, Children
FROM
    presidents
ORDER BY Children DESC;

-- Identify trends in the number of children presidents have
SELECT 
    COUNT(*) AS PresidentsCount, Children
FROM
    presidents
GROUP BY Children
ORDER BY PresidentsCount DESC;

-- Calculate the percentage of children presidents have by religion
SELECT 
    Religion,
    COUNT(*) AS PresidentsCount,
    SUM(Children) AS TotalChildren,
    ROUND((SUM(Children) / (SELECT 
                    SUM(Children)
                FROM
                    presidents
                WHERE
                    Children IS NOT NULL)) * 100,
            2) AS PercentageOfTotalChildren
FROM
    presidents
WHERE
    Children IS NOT NULL
GROUP BY Religion
ORDER BY PercentageOfTotalChildren DESC;

-- =================== Political Analysis: =======================================
-- Update the values in the columns by casting the varchar values to integers, handling non-numeric values
UPDATE victor.presidents 
SET 
    StartDate = NULLIF(CAST(StartDate AS SIGNED), 0),
    EndDate = NULLIF(CAST(NULLIF(EndDate, '') AS SIGNED), 0);

-- Change the data type of StartDate and EndDate columns to INT
ALTER TABLE victor.presidents
MODIFY COLUMN StartDate INT NULL,
MODIFY COLUMN EndDate INT NULL;

describe presidents;

-- Calculate the number of years of presidency for each president
SELECT 
    Name, Term, (EndDate - StartDate) AS YearsOfPresidency
FROM
    presidents
ORDER BY YearsOfPresidency DESC;


-- What is the distribution of presidents based on political party affiliation?
SELECT 
    Party,
    COUNT(*) AS party_distribution,
    ROUND(COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    victor.presidents
                WHERE
                    Party IS NOT NULL) * 100,
            2) AS percentage
FROM
    presidents
GROUP BY Party
ORDER BY percentage DESC;

-- ====================================================================================
--                 Text Analysis:
-- =====================================================================================
-- Can you identify common themes in the "Legacy" and "Other_Events" columns?
SELECT 
    Legacy, Other_Events
FROM
    presidents;

-- Are there 'war' word that frequently appear in the "Military_Activity" column?
SELECT 
    Party,
    COUNT(*) AS per_party,
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            victor.presidents) * 100 AS percentage
FROM
    presidents
WHERE
    Military_Activity LIKE '%war%'
GROUP BY Party
ORDER BY percentage DESC;


-- ==================== Geographical Analysis: ======================================
-- What is the distribution of birth by states for the presidents?
SELECT 
    BirthStateAbbreviation, COUNT(*) AS count_birth_state
FROM
    presidents
GROUP BY BirthStateAbbreviation
ORDER BY count_birth_state DESC;

-- =============== Religious and Educational Analysis: ==========================
-- What is the predominant religion among the presidents?
SELECT 
    Religion, COUNT(*) predominant_religion
FROM
    presidents
GROUP BY Religion
ORDER BY predominant_religion DESC
LIMIT 1;


-- Can you identify any patterns in the higher education backgrounds of the presidents?
SELECT 
    Higher_Education, COUNT(*) AS PresidentsCount
FROM
    victor.presidents
WHERE
    Higher_Education IS NOT NULL
GROUP BY Higher_Education
ORDER BY PresidentsCount DESC;

-- select all president with no higher education  
SELECT 
    Name
FROM
    presidents
WHERE
    Higher_Education = 'None';

-- total presidents vsv presidents with no higher education, rate percentage 
SELECT 
    (SELECT 
            COUNT(*)
        FROM
            presidents) total_presidents,
    COUNT(*) presidents_with_no_higher_education,
    ROUND(COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    presidents) * 100,
            2) AS rate_non_higher_education
FROM
    presidents
WHERE
    Higher_Education = 'None';
  

-- ===============  Comparison Analysis: ==================================

SELECT 
    party, SUM(Children)
FROM
    presidents
GROUP BY Party
ORDER BY SUM(Children) DESC;

-- comparison of presidential term by parties
SELECT 
    Party, SUM(EndDate - StartDate) AS period_years
FROM
    presidents
GROUP BY Party
ORDER BY period_years DESC;

-- comparison of Birth State  by parties
SELECT 
    Party,
    BirthStateAbbreviation,
    COUNT(BirthStateAbbreviation) AS sum_of_location
FROM
    presidents
GROUP BY Party , BirthStateAbbreviation
ORDER BY sum_of_location DESC;







