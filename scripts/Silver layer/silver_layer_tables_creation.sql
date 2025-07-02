/*
    ----------------------------------------------------------
    SQL Data Warehouse Project - Silver Tables Creation
    ----------------------------------------------------------

    WARNING:
    This script will DROP any existing Silver tables before recreating them, 
    permanently deleting all existing data. 
    Make sure to back up your Silver layer if you wish to preserve it.

    ----------------------------------------------------------
    DESCRIPTION:
    This script defines the Silver layer tables in the DataWarehouse. 
    The Silver layer stores cleansed and standardized data from
    the Bronze layer, prepared for downstream analytics or further
    transformation into Gold-layer star schema.

    These tables retain a structure close to the source but with
    higher data quality, adding:
    - consistent datatypes
    - cleaned, standardized fields
    - a wrh_create_date column for audit tracking

    These Silver tables act as a refined staging area, forming the
    trusted foundation before modeling into Gold-layer dimension/fact
    structures.
*/

-- Silver CRM Customer Information (cleansed staging)
IF OBJECT_ID('Silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE Silver.crm_cust_info;
GO

CREATE TABLE Silver.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    wrh_create_date DATETIME2 DEFAULT GETDATE()  -- audit load timestamp
);
GO

-- Silver CRM Product Information (cleansed staging)
IF OBJECT_ID('Silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE Silver.crm_prd_info;
GO

CREATE TABLE Silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    wrh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Silver CRM Sales Details (cleansed staging)
IF OBJECT_ID('Silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE Silver.crm_sales_details;
GO

CREATE TABLE Silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    wrh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Silver ERP Location Data (cleansed staging)
IF OBJECT_ID('Silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE Silver.erp_loc_a101;
GO

CREATE TABLE Silver.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    wrh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
