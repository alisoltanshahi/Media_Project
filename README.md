# Netflix_Project

## Netflix Data Analysis Project

This project involves a comprehensive analysis of Netflix data using MySQL, Python, and Tableau. The project encompasses data extraction, cleaning, exploratory data analysis (EDA), statistical testing, and data visualization.

## Table of Contents
1. [Introduction](#introduction)
2. [Data Sources](#data-sources)
3. [MySQL Queries and Analysis](#mysql-queries-and-analysis)
4. [Python Analysis and Statistical Testing](#python-analysis-and-statistical-testing)
5. [Tableau Visualization](#tableau-visualization)
6. [Conclusion](#conclusion)
7. [Usage](#usage)
8. [License](#license)

## Introduction
This project aims to analyze Netflix shows and their financial performance using a combination of SQL queries, Python scripts, and Tableau visualizations. The objective is to derive insights from the data, perform statistical testing, and present the findings through interactive dashboards.

## Data Sources
The data used in this project is stored in two tables:
- `shows`: Contains information about Netflix shows, including their ID, title, director, country, release year, rating, and more.
- `financials`: Contains financial details of the shows, including budget, sales, and profit.

## MySQL Queries and Analysis

### SQL Scripts
The SQL scripts used in this project perform the following tasks:

#### Data Retrieval and Table Modifications:
```sql
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
```

#### Basic Queries:
```sql
SELECT COUNT(*) AS row_count FROM netflix_project;
SELECT COUNT(*) AS row_count FROM financials;
SELECT COUNT(*) AS row_count FROM shows;
SELECT COUNT(DISTINCT Title) AS unique_Titles FROM shows;
```

#### Advanced Analysis:
```sql
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
```

## Python Analysis and Statistical Testing

The Python script (available in the repository) performs the following tasks:

### Data Loading
The script connects to the MySQL database and loads data from the `shows` and `financials` tables into pandas DataFrames.

### Exploratory Data Analysis (EDA)
The EDA includes:
- Merging the two DataFrames on `Show_ID`.
- Calculating summary statistics for numerical columns.
- Visualizing distributions and relationships between variables using libraries like Matplotlib and Seaborn.

### Statistical Testing
The script performs various statistical tests, including:
- **A/B Testing:** Comparing the profits of Movies vs. TV Shows using an independent t-test.
- **K-Nearest Neighbors (KNN) Classification:** Predicting whether a show is profitable based on its budget, sales, and release year.
- **Decision Tree Classification:** Another classification approach to predict profitability.
- **Hypothesis Testing:** ANOVA to test if there is a significant difference in budgets across different continents.

### Example Code Snippets
```python
import pandas as pd
import sqlalchemy
from scipy import stats
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score

# Define your database connection details
db_connection_str = 'mysql+pymysql://username:password@localhost/db_name'
db_connection = sqlalchemy.create_engine(db_connection_str)

# Load the tables into pandas DataFrames
shows_df = pd.read_sql('SELECT * FROM shows', con=db_connection)
financials_df = pd.read_sql('SELECT * FROM financials', con=db_connection)

# Display the first few rows of each DataFrame
print(shows_df.head())
print(financials_df.head())

# Merge the two DataFrames on Show_ID
merged_df = pd.merge(shows_df, financials_df, on='Show_ID')

# A/B Testing: Assume we are testing the effect of 'Type' on 'Profit'
group_a = merged_df[merged_df['Type'] == 'Movie']['Profit']
group_b = merged_df[merged_df['Type'] == 'TV Show']['Profit']

# Perform an independent t-test
t_stat, p_val = stats.ttest_ind(group_a, group_b, nan_policy='omit')

print(f"T-test Statistic: {t_stat}, P-value: {p_val}")

# Prepare data for KNN and Decision Tree
merged_df['Profitable'] = merged_df['Profitable?'].apply(lambda x: 1 if x == 'Yes' else 0)
features = ['Budget', 'Sales', 'Release_Year']
X = merged_df[features]
y = merged_df['Profitable']

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# KNN Classifier
knn = KNeighborsClassifier(n_neighbors=5)
knn.fit(X_train, y_train)
y_pred_knn = knn.predict(X_test)
knn_accuracy = accuracy_score(y_test, y_pred_knn)
print(f"KNN Accuracy: {knn_accuracy}")

# Decision Tree Classifier
tree = DecisionTreeClassifier(random_state=42)
tree.fit(X_train, y_train)
y_pred_tree = tree.predict(X_test)
tree_accuracy = accuracy_score(y_test, y_pred_tree)
print(f"Decision Tree Accuracy: {tree_accuracy}")

# ANOVA: Test if there's a significant difference in 'Budget' across different 'Continent'
anova_result = stats.f_oneway(
    merged_df[merged_df['Continent'] == 'North America']['Budget'],
    merged_df[merged_df['Continent'] == 'Europe']['Budget'],
    merged_df[merged_df['Continent'] == 'Asia']['Budget']
    # Add other continents as needed
)

print(f"ANOVA Statistic: {anova_result.statistic}, P-value: {anova_result.pvalue}")
```

## Tableau Visualization

An interactive dashboard is created using Tableau to visualize the findings from the data analysis. The dashboard provides insights into various aspects of Netflix shows and their financial performance.

You can view the Tableau dashboard [here](https://public.tableau.com/views/Netflix_project_17209846031570/Dashboard?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link).

## Conclusion

This project demonstrates a comprehensive approach to data analysis using SQL for data extraction and manipulation, Python for EDA and statistical testing, and Tableau for interactive visualizations. The combination of these tools provides deep insights into Netflix's show performance and financial metrics.

## Usage

To reproduce the analysis:
1. Set up the MySQL database and import the data.
2. Run the SQL scripts provided in `Netflix_project.sql` to create and query the tables.
3. Execute the Python script `Netflix_project.ipynb` to perform EDA and statistical tests.
4. Explore the Tableau dashboard using the provided link.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

