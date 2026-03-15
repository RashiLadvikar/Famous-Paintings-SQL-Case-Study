# Famous Paintings SQL Case Study

## Project Overview

This project explores and analyzes the **Famous Paintings Dataset** using **PostgreSQL and SQL**.
The goal of this case study is to practice real-world SQL queries such as joins, aggregations, window functions, and data cleaning operations.

The dataset contains information about:

* Paintings
* Artists
* Museums
* Painting subjects
* Canvas sizes
* Pricing information

Using SQL queries, we answer various analytical questions related to paintings, museums, and artists.

---

# Technologies Used

* PostgreSQL
* SQL
* Python
* Pandas
* SQLAlchemy

---

# Dataset Tables

The dataset consists of the following tables:

| Table Name   | Description                      |
| ------------ | -------------------------------- |
| artist       | Information about artists        |
| work         | Information about paintings      |
| museum       | Museums displaying paintings     |
| museum_hours | Opening hours of museums         |
| product_size | Pricing information of paintings |
| canvas_size  | Canvas size details              |
| subject      | Subject category of paintings    |
| image_link   | Image links of paintings         |

---

# Project Structure

```
famous-paintings-sql-case-study
│
├── data
│   ├── artist.csv
│   ├── canvas_size.csv
│   ├── image_link.csv
│   ├── museum.csv
│   ├── museum_hours.csv
│   ├── product_size.csv
│   ├── subject.csv
│   └── work.csv
│
├── scripts
│   └── load_csv_files.py
│
├── sql_queries
│   └── case_study_queries.sql
│
├── requirements.txt
└── README.md
```

---

# Loading Data into PostgreSQL

CSV files are loaded into PostgreSQL using Python and SQLAlchemy.

Example script:

```python
import pandas as pd
from sqlalchemy import create_engine

conn_string = 'postgresql://postgres:password@localhost/painting'

engine = create_engine(conn_string)

files = [
    'artist',
    'canvas_size',
    'image_link',
    'museum_hours',
    'museum',
    'product_size',
    'subject',
    'work'
]

for file in files:
    df = pd.read_csv(f'../data/{file}.csv')
    df.to_sql(file, con=engine, if_exists='replace', index=False)

print("Tables loaded successfully")
```

---

# Example SQL Queries

## 1 Paintings not displayed in any museum

```sql
SELECT *
FROM work
WHERE museum_id IS NULL;
```

---

## 2 Museums without any paintings

```sql
SELECT m.*
FROM museum m
LEFT JOIN work w
ON m.museum_id = w.museum_id
WHERE w.work_id IS NULL;
```

---

## 3 Paintings where asking price is greater than regular price

```sql
SELECT *
FROM product_size
WHERE sale_price > regular_price;
```

---

## 4 Top 10 most popular painting subjects

```sql
SELECT subject, COUNT(*) AS subject_count
FROM subject
GROUP BY subject
ORDER BY subject_count DESC
LIMIT 10;
```

---

## 5 Top 5 most popular museums

```sql
SELECT m.name, COUNT(w.work_id) AS painting_count
FROM museum m
JOIN work w
ON m.museum_id = w.museum_id
GROUP BY m.name
ORDER BY painting_count DESC
LIMIT 5;
```

---

## 6 Top 5 most popular artists

```sql
SELECT a.full_name, COUNT(w.work_id) AS painting_count
FROM artist a
JOIN work w
ON a.artist_id = w.artist_id
GROUP BY a.full_name
ORDER BY painting_count DESC
LIMIT 5;
```

---

# Skills Demonstrated

This project demonstrates the following skills:

* SQL Joins
* Aggregations
* Window Functions
* Data Cleaning
* Data Analysis
* Relational Database Design
* Loading data using Python

---

# How to Run This Project

### 1 Create PostgreSQL Database

```sql
CREATE DATABASE painting;
```

### 2 Install Required Python Libraries

```
pip install pandas sqlalchemy psycopg2-binary
```

### 3 Run the Python Script

```
python scripts/load_csv_files.py
```

This will load all CSV files into PostgreSQL tables.

---

# Learning Outcomes

Through this project, the following concepts were practiced:

* Working with relational datasets
* Writing analytical SQL queries
* Handling real-world case study problems
* Integrating Python with PostgreSQL
* Structuring data projects for GitHub

---

# Author

**Rashi Ladvikar**
Aspiring Data Analyst / Data Scientist

---

# Future Improvements

* Create data visualizations using Python or Power BI
* Perform advanced SQL analytics
* Build dashboards based on the dataset
* Add more complex case study questions
