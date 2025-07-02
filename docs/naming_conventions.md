# 📝 Naming Conventions

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse to ensure consistency, clarity, and maintainability.

---

## 📄 Table of Contents

- [General Principles](#general-principles)  
- [Table Naming Conventions](#table-naming-conventions)  
  - [Bronze Rules](#bronze-rules)  
  - [Silver Rules](#silver-rules)  
  - [Gold Rules](#gold-rules)  
- [Column Naming Conventions](#column-naming-conventions)  
  - [Surrogate Keys](#surrogate-keys)  
  - [Technical Columns](#technical-columns)  
- [Stored Procedures](#stored-procedures)

---

## General Principles

✅ Names should be clear, concise, and readable  
✅ Use **snake_case** or lowercase with underscores to separate words  
✅ Prefix objects with the relevant schema name  
✅ Avoid reserved keywords (e.g., “user”, “order”)  
✅ Keep naming consistent across the entire data warehouse  

---

## Table Naming Conventions

### Bronze Rules

- Schema: `Bronze`  
- Tables reflect raw data from source systems  
- Use the original naming as much as possible with minimal transformation  
- Examples:  
  - `Bronze.crm_cust_info`  
  - `Bronze.erp_px_cat_g1v2`  

### Silver Rules

- Schema: `Silver`  
- Tables store cleansed and standardized data  
- Retain source names but with enhanced structure and added columns  
- Add `wrh_create_date` as technical/audit tracking  
- Examples:  
  - `Silver.crm_cust_info`  
  - `Silver.crm_sales_details`  

### Gold Rules

- Schema: `Gold`  
- Views use star-schema style naming  
- Dimensions use the prefix `dim_`  
- Facts use the prefix `fact_`  
- Examples:  
  - `Gold.dim_customers`  
  - `Gold.dim_product`  
  - `Gold.fact_sales`  

---

## Column Naming Conventions

✅ Use clear and business-relevant names  
✅ Follow consistent prefixes for keys  
✅ Prefer snake_case or lowerCamelCase where appropriate  
✅ Examples:  
- `customer_key` for dimension surrogate key  
- `order_date` for dates  
- `sales_amount` for measures  

### Surrogate Keys

- Always use `*_key` for surrogate keys  
- Example: `customer_key`, `product_key`

### Technical Columns

- Audit or technical fields should have clear suffixes  
- Example: `wrh_create_date` (warehouse ingestion timestamp)

---

## Stored Procedures

- Use the schema prefix  
- Use clear verbs such as `load_`, `transform_`, or `refresh_`  
- Examples:  
  - `Bronze.load_bronze`  
  - `Silver.transform_silver`  
  - `Gold.refresh_gold_views` (future)

---

## ✅ Summary

These naming standards help:  
- Promote consistency  
- Improve developer collaboration  
- Support easier data lineage tracking  

For any additions or changes, please propose updates in this file and review them with the team. 🚀

