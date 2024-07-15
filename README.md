# Netflix_Project

Netflix Data Analysis Project
This project involves a comprehensive analysis of Netflix data using MySQL, Python, and Tableau. The project encompasses data extraction, cleaning, exploratory data analysis (EDA), statistical testing, and data visualization.

Table of Contents
Introduction
Data Sources
MySQL Queries and Analysis
Python Analysis and Statistical Testing
Tableau Visualization
Conclusion
Usage
License
Introduction
This project aims to analyze Netflix shows and their financial performance using a combination of SQL queries, Python scripts, and Tableau visualizations. The objective is to derive insights from the data, perform statistical testing, and present the findings through interactive dashboards.

Data Sources
The data used in this project is stored in two tables:

shows: Contains information about Netflix shows, including their ID, title, director, country, release year, rating, and more.
financials: Contains financial details of the shows, including budget, sales, and profit.
MySQL Queries and Analysis
SQL Scripts
The SQL scripts used in this project perform the following tasks:

Data Retrieval and Table Modifications:

sql
Copy code
SELECT * FROM financials;
SELECT * FROM shows;

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
MODIFY COLUMN `Profitable?` ENUM('Yes', 'No');
Basic Queries:

sql
Copy code
SELECT COUNT(*) AS row_count FROM netflix_project;
SELECT COUNT(*) AS row_count FROM financials;
SELECT COUNT(*) AS row_count FROM shows;
SELECT COUNT(DISTINCT Title) AS unique_Titles FROM shows;
Advanced Analysis:

sql
Copy code
-- Top 3 directors with highest average profit
WITH DirectorProfit AS (
    SELECT s.Director, AVG(f.Profit) AS AvgProfit
    FROM shows s
    JOIN financials f ON s.Show_ID = f.Show_ID
    GROUP BY s.Director
)
SELECT Director, AvgProfit
FROM DirectorProfit
ORDER BY AvgProfit DESC
LIMIT 3;

-- Shows with higher budget than average in the same continent
WITH AvgBudgetByContinent AS (
    SELECT Continent, AVG(f.Budget) AS AvgBudget
    FROM shows s
    JOIN financials f ON s.Show_ID = f.Show_ID
    GROUP BY Continent
)
SELECT s.Title, s.Continent, f.Budget
FROM shows s
JOIN financials f ON s.Show_ID = f.Show_ID
JOIN AvgBudgetByContinent abc ON s.Continent = abc.Continent
WHERE f.Budget > abc.AvgBudget;
Python Analysis and Statistical Testing
The Python script (available in the repository) performs the following tasks:

Data Loading
The script connects to the MySQL database and loads data from the shows and financials tables into pandas DataFrames.

Exploratory Data Analysis (EDA)
The EDA includes:

Merging the two DataFrames on Show_ID.
Calculating summary statistics for numerical columns.
Visualizing distributions and relationships between variables using libraries like Matplotlib and Seaborn.
Statistical Testing
The script performs various statistical tests, including:

A/B Testing: Comparing the profits of Movies vs. TV Shows using an independent t-test.
K-Nearest Neighbors (KNN) Classification: Predicting whether a show is profitable based on its budget, sales, and release year.
Decision Tree Classification: Another classification approach to predict profitability.
Hypothesis Testing: ANOVA to test if there is a significant difference in budgets across different continents.
Example Code Snippets
python
Copy code
# A/B Testing
from scipy import stats

group_a = merged_df[merged_df['Type'] == 'Movie']['Profit']
group_b = merged_df[merged_df['Type'] == 'TV Show']['Profit']

t_stat, p_val = stats.ttest_ind(group_a, group_b, nan_policy='omit')

# KNN Classification
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score

X = merged_df[['Budget', 'Sales', 'Release_Year']]
y = merged_df['Profitable']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

knn = KNeighborsClassifier(n_neighbors=5)
knn.fit(X_train, y_train)
y_pred_knn = knn.predict(X_test)
knn_accuracy = accuracy_score(y_test, y_pred_knn)
Tableau Visualization
An interactive dashboard is created using Tableau to visualize the findings from the data analysis. The dashboard provides insights into various aspects of Netflix shows and their financial performance.

You can view the Tableau dashboard here.

Conclusion
This project demonstrates a comprehensive approach to data analysis using SQL for data extraction and manipulation, Python for EDA and statistical testing, and Tableau for interactive visualizations. The combination of these tools provides deep insights into Netflix's show performance and financial metrics.

Usage
To reproduce the analysis:

Set up the MySQL database and import the data.
Run the SQL scripts provided in Netflix_project.sql to create and query the tables.
Execute the Python script Netflix_project.ipynb to perform EDA and statistical tests.
Explore the Tableau dashboard using the provided link.
License
This project is licensed under the MIT License. See the LICENSE file for details.
