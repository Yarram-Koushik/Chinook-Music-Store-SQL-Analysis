# 🎵 Chinook Music Store — SQL Analysis

<p align="center">

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-CC2927?style=for-the-badge&logo=databricks&logoColor=white)
![Data Analytics](https://img.shields.io/badge/Data%20Analytics-blue?style=for-the-badge)
![Business Analysis](https://img.shields.io/badge/Business%20Analysis-orange?style=for-the-badge)

</p>

---

# 📌 Project Overview

This project presents an end-to-end **SQL Data Analytics** solution for the **Chinook Music Store** — a digital media store similar to iTunes.

The objective is to analyze the Chinook database to uncover business insights related to sales performance, customer behavior, genre trends, regional patterns, churn risk, and customer lifetime value.

The entire analysis was performed using **MySQL**, leveraging complex JOINs, subqueries, Common Table Expressions (CTEs), window functions, aggregations, and CASE-based segmentation.

---

# 🎯 Business Problem

The Chinook Music Store wants to make data-driven decisions to grow revenue and improve customer retention.

The key business questions include:

- Which tracks, artists, and genres generate the most revenue?
- What are the customer purchasing patterns and demographics?
- Which customers are at risk of churning?
- How does sales performance vary across different countries?
- Which albums should be prioritized for promotion in the USA?
- What is the customer lifetime value across different segments?

A detailed SQL-based analysis was performed to answer these questions and provide actionable business recommendations.

---

# 🛠 Tools & Skills Used

- MySQL
- Complex JOINs (Multi-table)
- Subqueries & Correlated Subqueries
- Common Table Expressions (CTEs)
- Window Functions (RANK, DENSE_RANK, ROW_NUMBER)
- Aggregate Functions (SUM, AVG, COUNT)
- CASE Statements & Conditional Logic
- Date Functions (DATEDIFF, DATE_FORMAT, DATE_SUB)
- Data Cleaning & NULL Analysis
- Customer Segmentation
- Churn Rate Analysis
- Customer Lifetime Value (CLV) Modeling
- Product Affinity Analysis
- Business Analysis & Recommendations

---

# 📂 Repository Structure

```text
Chinook-Music-Store-SQL-Analysis
│
├── Documentation
│   └── KoushikYarram_Chinook_Answers.docx
├── Presentation
│   └── KoushikYarram_Chinook_Presentation.pptx
├── SQL
│   ├── Chinook_Music_Store_DB.sql
│   └── KoushikYarram_Chinook_SQL.sql
├── README.md
├── LICENSE
└── .gitignore
```

---

# 📈 Key Performance Indicators (KPIs)

- Total Revenue Analysis (Global & Country-wise)
- Top-Selling Tracks, Artists & Albums
- Genre-wise Sales Contribution (%)
- Customer Demographic Breakdown
- Average Order Value & Basket Size
- Customer Purchase Frequency
- Customer Churn Rate
- Customer Lifetime Value (CLV)
- Regional Market Performance
- New vs Returning Customer Trends

---

# 📌 Key Insights

✅ **Rock** is the dominant genre in the USA, contributing the highest percentage of total sales.

✅ Top artists like **Iron Maiden** and **U2** drive significant revenue in the US market.

✅ Customer purchasing behavior shows an average of **~7 orders per customer** with consistent basket sizes.

✅ Customers purchasing from **3+ genres** represent highly engaged, cross-genre buyers.

✅ **Long-term customers** show higher purchase frequency and total spend compared to new customers.

✅ Regional analysis reveals significant variation in spending patterns and churn rates across countries.

✅ **High-risk customers** (inactive > 365 days) can be identified and targeted with re-engagement campaigns.

✅ Genre pairs like **Rock & Metal** are frequently purchased together, enabling cross-selling opportunities.

✅ Monthly revenue trends help identify seasonal patterns for **new vs returning** customer acquisition.

✅ **Customer Lifetime Value** segmentation enables targeted marketing for High, Medium, and Low value segments.

---

# 💼 Business Recommendations

- Prioritize **Rock, Latin, and Metal** genre albums for USA promotions
- Implement **cross-selling strategies** based on genre & artist affinity analysis
- Launch **re-engagement campaigns** targeting high-risk churned customers
- Focus marketing spend on **high-CLV customer segments** for maximum ROI
- Optimize **regional strategies** based on country-level purchasing behavior
- Introduce **loyalty programs** for long-term, high-frequency customers
- Use **predictive staffing & inventory** based on monthly revenue trends
- Monitor KPIs through **regular dashboard reporting**

---

# 📁 Project Deliverables

| File                    | Description                                              |
| ----------------------- | -------------------------------------------------------- |
| SQL Analysis Script     | Complete SQL queries for all objective & subjective questions |
| Database Script         | Chinook database schema and data                         |
| Documentation (DOCX)    | Detailed answers with explanations and screenshots       |
| Presentation (PPTX)     | Executive summary with key insights and recommendations  |

---

# 📊 Analysis Categories

### Objective Questions (O1–O12)
- Data quality checks (duplicates & NULL values)
- Top-selling tracks, artists & genres in the USA
- Customer demographics & geographic distribution
- Revenue analysis by country, state & city
- Top 5 customers by revenue per country
- Customer purchasing behavior & patterns
- Customer churn rate calculation
- Genre sales contribution analysis
- Multi-genre customer identification
- Genre ranking by sales performance
- Inactive customer identification

### Subjective Questions (S1–S11)
- Album promotion recommendations for the USA
- Global genre sales comparison (USA vs International)
- Long-term vs new customer behavior analysis
- Product affinity & cross-selling analysis
- Regional market & churn rate analysis
- Customer risk profiling & segmentation
- Customer Lifetime Value (CLV) modeling
- Campaign impact measurement framework
- Exploratory data analysis approach
- Database schema modification (ALTER TABLE)
- Geographic purchasing behavior analysis

---

# 📚 What I Learned

- Writing complex SQL queries with multi-table JOINs
- Using CTEs and window functions for advanced analytics
- Customer segmentation and churn analysis using SQL
- Building Customer Lifetime Value models
- Product affinity analysis for cross-selling recommendations
- Regional market analysis and geographic insights
- Translating data findings into business recommendations
- Data quality assessment and NULL handling strategies

---

# 🚀 Future Improvements

- Power BI / Tableau Dashboard Integration
- Python-based Advanced Analytics
- Machine Learning for Churn Prediction
- Automated Reporting Pipeline
- Real-time KPI Monitoring Dashboard

---

# 👨‍💻 Author

**Koushik Yarram**

Data Science Learning Journey (Phase 1 – Data Analytics)

---

⭐ If you found this project useful, consider giving it a star!
