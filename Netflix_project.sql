select * from financials
select * from shows

ALTER TABLE shows
MODIFY COLUMN show_ID VARCHAR(255) PRIMARY KEY,
MODIFY COLUMN Date_Added TEXT,
MODIFY COLUMN Country TEXT,
MODIFY COLUMN Director TEXT,
MODIFY COLUMN Duration TEXT,
MODIFY COLUMN Listed_In TEXT,
MODIFY COLUMN Rating TEXT,
MODIFY COLUMN Release_Year BIGINT,
MODIFY COLUMN Title TEXT,
MODIFY COLUMN Type TEXT,
MODIFY COLUMN Continent TEXT;


ALTER TABLE financials
MODIFY COLUMN Show_ID VARCHAR(255) PRIMARY KEY,
MODIFY COLUMN Budget BIGINT,
MODIFY COLUMN Sales BIGINT,
MODIFY COLUMN Profit BIGINT,
MODIFY COLUMN `Profitable?` ENUM('Yes', 'No')




DESCRIBE netflix_project
DESCRIBE shows
DESCRIBE financials

-- Some basic questions first:
-- 1.How many rows are there in the table?
SELECT 
    COUNT(*) AS row_count
FROM
    netflix_project;
    
SELECT 
    COUNT(*) AS row_count
FROM
    financials;

SELECT 
    COUNT(*) AS row_count
FROM
    shows;
-- 2.How many unique titles we do have:
SELECT 
    COUNT(DISTINCT Title) AS unique_Titles
FROM
    shows;


-- Some more Questions
-- 1.Find the top 3 directors who have the highest average profit for their shows.
WITH DirectorProfit AS (
    SELECT 
        s.Director, 
        AVG(f.Profit) AS AvgProfit
    FROM 
        shows s
    JOIN 
        financials f ON s.Show_ID = f.Show_ID
    GROUP BY 
        s.Director
)
SELECT 
    Director, 
    AvgProfit
FROM 
    DirectorProfit
ORDER BY 
    AvgProfit DESC
LIMIT 3;

-- 2.Identify shows that have a higher budget than the average budget of all shows in the same continent.
WITH AvgBudgetByContinent AS (
    SELECT 
        Continent, 
        AVG(f.Budget) AS AvgBudget
    FROM 
        shows s
    JOIN 
        financials f ON s.Show_ID = f.Show_ID
    GROUP BY 
        Continent
)
SELECT 
    s.Title, 
    s.Continent, 
    f.Budget
FROM 
    shows s
JOIN 
    financials f ON s.Show_ID = f.Show_ID
JOIN 
    AvgBudgetByContinent abc ON s.Continent = abc.Continent
WHERE 
    f.Budget > abc.AvgBudget;

-- 3.List the titles of shows that have the same director and were released in the same year.
SELECT 
    s1.Title AS Title1, 
    s2.Title AS Title2, 
    s1.Director, 
    s1.Release_Year
FROM 
    shows s1
JOIN 
    shows s2 ON s1.Director = s2.Director 
    AND s1.Release_Year = s2.Release_Year 
    AND s1.Show_ID <> s2.Show_ID;
    
-- 4.Rank all shows by their profit within each continent and find the top profitable show per continent.
WITH RankedShows AS (
    SELECT 
        s.Title, 
        s.Continent, 
        f.Profit,
        RANK() OVER (PARTITION BY s.Continent ORDER BY f.Profit DESC) AS ProfitRank
    FROM 
        shows s
    JOIN 
        financials f ON s.Show_ID = f.Show_ID
)
SELECT 
    Title, 
    Continent, 
    Profit
FROM 
    RankedShows
WHERE 
    ProfitRank = 1;
    
-- 5.Find directors who have directed more than one show in different continents.
SELECT 
    Director, 
    COUNT(DISTINCT Continent) AS ContinentCount
FROM 
    shows
GROUP BY 
    Director
HAVING 
    ContinentCount > 1;
    
-- 6.List the shows that were added on the same date in different countries.  
SELECT 
    s1.Title AS Title1, 
    s2.Title AS Title2, 
    s1.Date_Added, 
    s1.Country AS Country1, 
    s2.Country AS Country2
FROM 
    shows s1
JOIN 
    shows s2 ON s1.Date_Added = s2.Date_Added 
    AND s1.Country <> s2.Country 
    AND s1.Show_ID <> s2.Show_ID;
    
    
-- 7.Determine the average duration of shows listed under the same genre.
WITH GenreDuration AS (
    SELECT 
        s.Listed_In, 
        AVG(CAST(SUBSTRING_INDEX(s.Duration, ' ', 1) AS UNSIGNED)) AS AvgDuration
    FROM 
        shows_df s
    GROUP BY 
        s.Listed_In
)
SELECT 
    Listed_In, 
    AvgDuration
FROM 
    GenreDuration;
    
    
-- 8.Identify the country with the highest total sales from its shows.
SELECT 
    s.Country, 
    SUM(f.Sales) AS TotalSales
FROM 
    shows s
JOIN 
    financials f ON s.Show_ID = f.Show_ID
GROUP BY 
    s.Country
ORDER BY 
    TotalSales DESC
LIMIT 1;


-- 9.Find the longest duration show in each release year and its director.
WITH LongestShowPerYear AS (
    SELECT 
        Release_Year, 
        MAX(CAST(SUBSTRING_INDEX(Duration, ' ', 1) AS UNSIGNED)) AS MaxDuration
    FROM 
        shows
    GROUP BY 
        Release_Year
)
SELECT 
    s.Title, 
    s.Director, 
    s.Release_Year, 
    s.Duration
FROM 
    shows s
JOIN 
    LongestShowPerYear lsp ON s.Release_Year = lsp.Release_Year 
    AND CAST(SUBSTRING_INDEX(s.Duration, ' ', 1) AS UNSIGNED) = lsp.MaxDuration;
    
    
-- 10.List the shows and their respective continents where the show’s budget exceeds the average budget of the shows in that continent by more than 50%.
WITH AvgBudget AS (
    SELECT 
        Continent, 
        AVG(f.Budget) AS AvgBudget
    FROM 
        shows s
    JOIN 
        financials f ON s.Show_ID = f.Show_ID
    GROUP BY 
        Continent
)
SELECT 
    s.Title, 
    s.Continent, 
    f.Budget
FROM 
    shows s
JOIN 
    financials f ON s.Show_ID = f.Show_ID
JOIN 
    AvgBudget ab ON s.Continent = ab.Continent
WHERE 
    f.Budget > 1.5 * ab.AvgBudget;
    
    
-- 11. Extract and list all unique genres (subcategories) from the Listed_In column, where multiple genres are separated by commas.
SELECT DISTINCT 
    TRIM(BOTH ' ' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(Listed_In, ',', numbers.n), ',', -1)) AS genre
FROM 
    shows
JOIN 
    (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) numbers
ON 
    CHAR_LENGTH(Listed_In) - CHAR_LENGTH(REPLACE(Listed_In, ',', '')) >= numbers.n - 1
ORDER BY 
    genre;


-- 12.Find all shows where the director's name consists of exactly two words.
SELECT 
    Title, 
    Director
FROM 
    shows
WHERE 
    Director REGEXP '^[A-Za-z]+ [A-Za-z]+$';
    

-- 13.Identify shows whose titles contain the year of release in parentheses, e.g., "Show Title (2020)".
SELECT 
    Title, 
    Release_Year
FROM 
    shows
WHERE 
    Title REGEXP '\\([0-9]{4}\\)';
    
    
-- 14.List all shows where the duration is specified in the format "XX min" (e.g., "90 min"), and extract the numeric value of the duration.
SELECT 
    Title, 
    Duration, 
    CAST(SUBSTRING_INDEX(Duration, ' ', 1) AS UNSIGNED) AS DurationMinutes
FROM 
    shows
WHERE 
    Duration REGEXP '^[0-9]+ min$';
    

-- 15.Extract and display all directors' first names and last names separately for directors whose names are in the format "First Middle Last" or "First Last".
SELECT 
    Title, 
    Director,
    SUBSTRING_INDEX(Director, ' ', 1) AS FirstName,
    CASE 
        WHEN CHAR_LENGTH(Director) - CHAR_LENGTH(REPLACE(Director, ' ', '')) = 2 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(Director, ' ', 2), ' ', -1)
        ELSE NULL
    END AS MiddleName,
    SUBSTRING_INDEX(Director, ' ', -1) AS LastName
FROM 
    shows
WHERE 
    Director REGEXP '^[A-Za-z]+( [A-Za-z]+)* [A-Za-z]+$'
    
    
-- 16.Find the top 3 directors who have the highest total profits for their shows, but only consider directors who have directed at least 3 different shows. For each of these directors, list their name, total profit, the number of shows they directed, and details of each show (Title, Release_Year, Profit).
-- Step 1: Create a CTE to calculate total profits and count of shows for each director
WITH DirectorProfits AS (
    SELECT 
        s.Director, 
        SUM(f.Profit) AS TotalProfit, 
        COUNT(s.Show_ID) AS ShowCount
    FROM 
        shows s
    JOIN 
        financials f ON s.Show_ID = f.Show_ID
    GROUP BY 
        s.Director
    HAVING 
        COUNT(s.Show_ID) >= 3
),
-- Step 2: Create another CTE to rank directors by their total profit
RankedDirectors AS (
    SELECT 
        Director, 
        TotalProfit, 
        ShowCount,
        RANK() OVER (ORDER BY TotalProfit DESC) AS ProfitRank
    FROM 
        DirectorProfits
),
-- Step 3: Select the top 3 directors based on the ranking
TopDirectors AS (
    SELECT 
        Director, 
        TotalProfit, 
        ShowCount
    FROM 
        RankedDirectors
    WHERE 
        ProfitRank <= 3
)
-- Step 4: Join the top directors with the original shows data to get details of each show they directed
SELECT 
    td.Director, 
    td.TotalProfit, 
    td.ShowCount, 
    s.Title, 
    s.Release_Year, 
    f.Profit
FROM 
    TopDirectors td
JOIN 
    shows s ON td.Director = s.Director
JOIN 
    financials f ON s.Show_ID = f.Show_ID
ORDER BY 
    td.TotalProfit DESC, 
    s.Release_Year DESC;
    