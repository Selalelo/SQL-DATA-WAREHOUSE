/*
    ----------------------------------------------------------
    SQL Data Warehouse Project - Gold Layer Views
    ----------------------------------------------------------

    WARNING:
    This script will DROP existing Gold views before recreating them.
    Any downstream dashboards or reports depending on these views
    may break if their structure changes. Please validate carefully.

    ----------------------------------------------------------
    DESCRIPTION:
    These views define the Gold layer semantic models for
    analytical consumption, transforming cleansed Silver data
    into a star-schema format:

    - Gold.dim_customers: customer dimension
    - Gold.dim_product: product dimension
    - Gold.fact_sales: sales fact

    These views provide simplified, business-ready models for
    reporting tools and BI dashboards.
*/


-- =============================================================================
-- Create Dimension View: gold.dim_customers
-- =============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW Gold.dim_customers AS
SELECT 
    -- surrogate key for dimension
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS firstname,
    ci.cst_lastname AS lastname,
    el.cntry AS country,
    -- prefer CRM gender, fallback to ERP gender if missing
    CASE 
        WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ec.gen, 'n/a')
    END AS gender,
    ci.cst_marital_status AS marital_status,
    ec.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM Silver.crm_cust_info AS ci
LEFT JOIN Silver.erp_cust_az12 AS ec
    ON ci.cst_key = ec.cid
LEFT JOIN Silver.erp_loc_a101 AS el
    ON ci.cst_key = el.cid;
GO


-- =============================================================================
-- Create Dimension View: gold.dim_product
-- =============================================================================

IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
    DROP VIEW gold.dim_product;
GO

CREATE VIEW Gold.dim_product AS
SELECT
    -- surrogate key for dimension
    ROW_NUMBER() OVER (ORDER BY cp.prd_id, cp.prd_key) AS product_key,
    cp.prd_id AS product_id,
    cp.prd_key AS product_number,
    cp.prd_nm AS product_name,
    cp.prd_line AS product_line,
    cp.cat_id AS category_id,
    ec.cat AS category,
    ec.subcat AS subcategory,
    ec.maintenance,
    cp.prd_cost AS product_cost,
    cp.prd_start_dt AS product_start_date
FROM Silver.crm_prd_info AS cp
LEFT JOIN Silver.erp_px_cat_g1v2 AS ec
    ON cp.cat_id = ec.id
WHERE cp.prd_end_dt IS NULL;   -- only active products
GO


-- =============================================================================
-- Create Fact View: gold.fact_sales
-- =============================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW Gold.fact_sales AS
SELECT 
    cs.sls_ord_num AS order_number,
    dp.product_key,
    dc.customer_key,
    cs.sls_order_dt AS order_date,
    cs.sls_ship_dt AS shipping_date,
    cs.sls_due_dt AS due_date,
    cs.sls_sales AS sales_amount,
    cs.sls_quantity AS quantity,
    cs.sls_price AS price
FROM Silver.crm_sales_details AS cs
LEFT JOIN Gold.dim_product AS dp
    ON cs.sls_prd_key = dp.product_number
LEFT JOIN Gold.dim_customers AS dc
    ON cs.sls_cust_id = dc.customer_id;
GO
