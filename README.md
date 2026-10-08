# InsightCart – E-commerce Data Warehouse & Analytics Platform

## 📌 Project Overview

InsightCart is an e-commerce data warehouse and analytics project built to transform raw e-commerce data into structured, analysis-ready information and generate meaningful business insights.

The project uses **MySQL** for data warehousing, **Python and Pandas** for ETL and data transformation, and **Power BI** for interactive business analytics and visualization.

The warehouse follows a **star schema** design with a sales fact table connected to customer, product, seller, and date dimensions.

---

## 🏗️ Project Architecture

```text
Olist E-commerce Dataset
          ↓
     Source MySQL DB
          ↓
      Staging Tables
          ↓
    Python / Pandas ETL
          ↓
 Data Cleaning & Transformation
          ↓
    MySQL Data Warehouse
          ↓
       Star Schema
          ↓
        Power BI
```

---

## 🛠️ Technologies Used

* **Python**
* **Pandas**
* **SQL**
* **MySQL**
* **Power BI**
* **Jupyter Notebook**

---

## 🗄️ Data Warehouse Design

The warehouse follows a **star schema** centered around the `fact_sales` table.

### Fact Table

**`fact_sales`**

Contains order-item level sales information including:

* Order ID
* Customer Key
* Product Key
* Seller Key
* Date Key
* Product Price
* Freight Value
* Quantity
* Total Amount

The fact table contains **112,650 order-item records**.

### Dimension Tables

**`dim_customer`**

* Customer information
* Customer location/state

**`dim_product`**

* Product information
* Product category

**`dim_seller`**

* Seller information

**`dim_date`**

* Date
* Day
* Month
* Month Name
* Quarter
* Year

### Star Schema

```text
                    dim_customer
                         |
                         |
dim_date -------- fact_sales -------- dim_product
                         |
                         |
                    dim_seller
```

---

## 🔄 ETL Pipeline

A Python/Pandas ETL pipeline was developed to process the source data.

### ETL Process

1. Extract data from the source MySQL database.
2. Load source data into staging tables.
3. Clean and transform the data using Python and Pandas.
4. Combine order and order-item information.
5. Generate derived fields such as date keys and total sales values.
6. Look up surrogate keys from warehouse dimensions.
7. Validate the transformed fact dataset.
8. Load the final data into the warehouse fact table.
9. Perform post-load validation.

### Data Validation

The pipeline includes checks for:

* Row-count consistency
* Missing dimension keys
* Duplicate dimension identifiers
* Revenue calculation consistency
* Successful fact-table loading

---

## 📊 Power BI Dashboard

The warehouse was connected to Power BI to create an interactive analytics dashboard.

### Key KPIs

* Total Revenue
* Warehouse Sales Value
* Total Orders
* Total Customers
* Total Sellers
* Average Rating

### Visualizations

* Monthly Revenue Trend
* Revenue by State
* Top 10 Product Categories
* Revenue by Payment Method
* Customer Review Distribution

### Interactive Filters

* Year
* State
* Payment Type

---

## 📈 Key Results

The final warehouse contains:

| Metric                 |   Value |
| ---------------------- | ------: |
| Customers              |  99,441 |
| Products               |  32,951 |
| Orders                 |  99,441 |
| Order Items            | 112,650 |
| Warehouse Sales Value  | ₹15.84M |
| Source Payment Revenue | ₹16.01M |
| Average Rating         |    4.08 |

> **Note:** Source payment revenue and warehouse sales value are intentionally different metrics. Warehouse sales value is calculated at the order-item level using product price and freight value, while payment revenue comes from the source payment data.

---

## 📁 Project Structure

```text
InsightCart/
│
├── SQL/
│   └── warehouse_schema.sql
│
├── Python/
│   └── 03_ETL_PIPELINE.ipynb
│
├── PowerBI/
│   └── INSIGHTCART_proj.pbix
│
├── .gitignore
└── README.md
```

---

## 🎯 Learning Outcomes

Through this project, I gained practical experience in:

* Data warehousing
* Star schema design
* SQL and MySQL
* ETL pipeline development
* Python and Pandas
* Data cleaning and transformation
* Dimension key mapping
* Data quality validation
* Power BI dashboard development
* Business-oriented data analysis

---

## 👩‍💻 Author

**Priya Saini**

B.Tech – Computer Science Engineering
