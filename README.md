# Northwind Data Analytics Project: SQL & Power BI 📊

![Project Status](https://img.shields.io/badge/Status-Completed-success)
![Database](https://img.shields.io/badge/Database-MySQL-blue)
![BI Tool](https://img.shields.io/badge/BI-Power_BI-yellow)

## 🎯 Project Overview
This project transforms raw transactional data from the classic **Northwind** database into a strategic Business Intelligence ecosystem. It covers the full data lifecycle: from **Exploratory Data Analysis (EDA)** and **Data Engineering** in MySQL to **Advanced Visualization** in Power BI.

The goal is to provide actionable insights for sales management, inventory control, and customer loyalty programs.

---

## 🛠️ Tech Stack
* **SQL (MySQL):** Data cleaning, EDA, and Creation of optimized Views.
* **Power BI:** Data modeling (Star Schema), DAX measures, and UX/UI design.
* **DAX:** Advanced conditional formatting and dynamic business KPIs.

---

## 📁 Repository Structure
* `/sql_scripts`: Contains all `.sql` files used for EDA and View creation.
* `/dashboards`: Screenshots of the 4-page Power BI report.
* `/data_model`: Diagram of the Star Schema relationship model.

---

## 🚀 Key Implementation Phases

### 1. Data Engineering (SQL Backend)
To ensure report performance, I designed custom **SQL Views** that handle complex logic before reaching Power BI:
* **Customer Segmentation:** Built a dynamic segmentator using date logic to classify clients as *Active*, *At Risk*, or *Critical*.
* **Inventory Management:** Created alerts for stock-outs and calculated inventory valuation.
* **Granularity Control:** Resolved many-to-many relationship issues between suppliers and categories.

### 2. Data Modeling
Implemented a **Star/Snowflake Schema** focused on the Sales Fact Table.
* Connected Dimensions: Employees, Customers, Inventory, and Suppliers.
* Bidirectional filter cleanup to ensure accurate cross-filtering.

### 3. Business Dashboards
The final report consists of 4 specialized pages:
* **Executive Summary:** Revenue trends, Top 5 Customers, and Global Sales Geolocation.
* **Customer Loyalty:** Churn risk monitor and Sales vs. Order volume scatter analysis.
* **Operations & Inventory:** Critical stock alerts and tied-up capital valuation.
* **Employee Performance:** Comparative matrices using **Advanced DAX** to highlight the "Top Seller" per category.

---

## 💡 Key Business Insights
* Identified that **14% of customers** are in a "Critical" state (no orders in 4+ months), enabling targeted re-engagement campaigns.
* Detected that the **Beverages** category holds the highest inventory value, suggesting a rotation optimization opportunity.
* Optimized the **Supplier View** to track supply average prices per category.

---

## 📸 Dashboard Preview
*(Replace these with the links to your images once uploaded to GitHub)*
* **Page 1: [Executive Summary](https://github.com/ManuAnria/Northwind-Project-SQL-Power-BI/blob/main/dashboards/n1.png)**
* **Page 2: [Customer Loyalty](https://github.com/ManuAnria/Northwind-Project-SQL-Power-BI/blob/main/dashboards/n2.png)**
* **Page 3: [Inventory Status](https://github.com/ManuAnria/Northwind-Project-SQL-Power-BI/blob/main/dashboards/n3.png)**
* **Page 4: [Employee Performance](https://github.com/ManuAnria/Northwind-Project-SQL-Power-BI/blob/main/dashboards/n4.png)**

---

## 🔧 Setup Instructions
1. Clone the repository.
2. Run the scripts in `/sql_scripts` on your MySQL instance.
3. Open the `.pbix` file (Power BI) and update the Data Source settings to point to your local MySQL server.

---
**Developed by Manuel Anria** *Connect with me on [LinkedIn](www.linkedin.com/in/manuelanria)*
