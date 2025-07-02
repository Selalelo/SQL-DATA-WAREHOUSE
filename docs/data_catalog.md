# 📒 Data Catalogue: Gold Layer

This document describes the Gold-layer views in the data warehouse, forming the semantic, business-ready presentation layer for analytics and reporting.

---

## ⭐ Gold.dim_customers

**Description:**  
This view provides a clean, consistent customer dimension enriched with CRM and ERP data, including demographics and location information.  

| Column           | Data Type     | Description                                      |
|------------------|---------------|--------------------------------------------------|
| customer_key     | INT           | Surrogate key for dimension                      |
| customer_id      | INT           | Business identifier from CRM                     |
| customer_number  | NVARCHAR(50)  | External customer number                         |
| firstname        | NVARCHAR(50)  | Customer first name                              |
| lastname         | NVARCHAR(50)  | Customer last name                               |
| country          | NVARCHAR(50)  | Country derived from ERP location(e.g.'Australia')                |
| gender           | NVARCHAR(50)  | Cleaned gender (CRM preferred, ERP fallback)     |
| marital_status   | NVARCHAR(50)  | Marital status                                   |
| birthdate        | DATE          | Birthdate from ERP                               |
| create_date      | DATE          | Original customer create date                    |

---

## ⭐ Gold.dim_product

**Description:**  
This view provides a product dimension with details from CRM products and ERP category enrichment.  

| Column              | Data Type     | Description                                    |
|---------------------|---------------|------------------------------------------------|
| product_key         | INT           | Surrogate key for dimension                    |
| product_id          | INT           | Business product ID from CRM                   |
| product_number      | NVARCHAR(50)  | External product number                        |
| product_name        | NVARCHAR(50)  | Product name                                   |
| product_line        | NVARCHAR(50)  | Product line (e.g., Mountain, Road, Touring)   |
| category_id         | NVARCHAR(50)  | Category identifier from CRM                   |
| category            | NVARCHAR(50)  | Category name from ERP                         |
| subcategory         | NVARCHAR(50)  | Subcategory name from ERP                      |
| maintenance         | NVARCHAR(50)  | Maintenance category from ERP                  |
| product_cost        | INT           | Product unit cost                              |
| product_start_date  | DATE          | Product valid start date                       |

---

## ⭐ Gold.fact_sales

**Description:**  
This view contains sales facts with relationships to the customer and product dimensions, ready for analytics and reporting.  

| Column         | Data Type     | Description                                   |
|----------------|---------------|-----------------------------------------------|
| order_number   | NVARCHAR(50)  | Unique sales order identifier                 |
| product_key    | INT           | Surrogate key linking to Gold.dim_product     |
| customer_key   | INT           | Surrogate key linking to Gold.dim_customers   |
| order_date     | DATE          | Date the order was placed                     |
| shipping_date  | DATE          | Date the order was shipped                    |
| due_date       | DATE          | Due date for delivery                         |
| sales_amount   | INT           | Total sales amount                            |
| quantity       | INT           | Quantity of products sold                     |
| price          | INT           | Unit price                                    |

---

## 🚀 Notes

- Gold-layer views follow a **star-schema** pattern, exposing clean dimensions and a central fact table for reporting.  
- Naming conventions:  
  - `dim_*` = dimension views  
  - `fact_*` = fact views  

- These views are designed for ease of use in Power BI or other BI tools.  
