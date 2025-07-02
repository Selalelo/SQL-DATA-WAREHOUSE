/*
    ----------------------------------------------------------
    SQL Data Warehouse Project - Silver Layer Load Procedure
    ----------------------------------------------------------

    WARNING:
    This procedure will **TRUNCATE** all Silver tables, permanently removing
    any existing data before reloading them from the cleansed Bronze layer.
    Please ensure Bronze layer loads are correct before running this step.

    ----------------------------------------------------------
    DESCRIPTION:
    This procedure (Silver.load_silver) performs the transformation and loading
    of data from the Bronze (raw) layer to the Silver (cleansed) layer.
    It does the following:

    - Truncates existing Silver tables
    - Loads cleaned and transformed data from Bronze tables
    - Applies standardization and business rules
    - Tracks load duration with logging
    - Handles errors gracefully using TRY/CATCH

    This supports a reliable, repeatable, and auditable ETL process
    for the cleansed Silver layer.
*/

CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
    -- Declare variables for batch and step timing
    DECLARE @start_time DATETIME, 
            @end_time DATETIME, 
            @batch_start_time DATETIME, 
            @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '============================';
        PRINT 'Starting Silver Layer Load';
        PRINT '============================';

        /*
            ----------------------------------------------------
            Load CRM Tables into Silver
            ----------------------------------------------------
        */
        PRINT '--------------------';
        PRINT 'Loading CRM Tables';
        PRINT '--------------------';

        -- CRM Customer Info transformation and load
        SET @start_time = GETDATE();
        PRINT '>> Truncating Silver.crm_cust_info';
        TRUNCATE TABLE Silver.crm_cust_info;
        PRINT '>> Inserting data into Silver.crm_cust_info';

        INSERT INTO Silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            -- Clean up marital status codes
            CASE cst_marital_status
                WHEN 'S' THEN 'Single'
                WHEN 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,
            -- Standardize gender codes
            CASE cst_gndr
                WHEN 'F' THEN 'Female'
                WHEN 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            cst_create_date
        FROM (
            -- Only keep the most recent customer record per cst_id
            SELECT *,
                RANK() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
            FROM Bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- CRM Product Info transformation and load
        SET @start_time = GETDATE();
        PRINT '>> Truncating Silver.crm_prd_info';
        TRUNCATE TABLE Silver.crm_prd_info;
        PRINT '>> Inserting data into Silver.crm_prd_info';

        INSERT INTO Silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,   -- extract category id
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,          -- extract product key
            prd_nm,
            COALESCE(prd_cost, 0) AS prd_cost,
            -- Standardize product line names
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            -- determine product end date based on LEAD window
            CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
        FROM Bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- CRM Sales Details transformation and load
        SET @start_time = GETDATE();
        PRINT '>> Truncating Silver.crm_sales_details';
        TRUNCATE TABLE Silver.crm_sales_details;
        PRINT '>> Inserting data into Silver.crm_sales_details';

        INSERT INTO Silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            -- parse 8-digit date fields
            CASE WHEN LEN(sls_order_dt) <> 8 THEN NULL ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE) END,
            CASE WHEN LEN(sls_ship_dt) <> 8 THEN NULL ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE) END,
            CASE WHEN LEN(sls_due_dt) <> 8 THEN NULL ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE) END,
            -- calculate consistent sales amount if needed
            CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> ABS(sls_price) * sls_quantity
                THEN ABS(sls_price) * sls_quantity
                ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            -- derive price if missing or invalid
            CASE WHEN sls_price IS NULL OR sls_price <= 0
                THEN ABS(sls_sales) / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price
        FROM Bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        /*
            ----------------------------------------------------
            Load ERP Tables into Silver
            ----------------------------------------------------
        */
        PRINT '--------------------';
        PRINT 'Loading ERP Tables';
        PRINT '--------------------';

        -- ERP Product Category
        SET @start_time = GETDATE();
        PRINT '>> Truncating Silver.erp_px_cat_g1v2';
        TRUNCATE TABLE Silver.erp_px_cat_g1v2;
        PRINT '>> Inserting data into Silver.erp_px_cat_g1v2';

        INSERT INTO Silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM Bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- ERP Customer Info
        SET @start_time = GETDATE();
        PRINT '>> Truncating Silver.erp_cust_az12';
        TRUNCATE TABLE Silver.erp_cust_az12;
        PRINT '>> Inserting data into Silver.erp_cust_az12';

        INSERT INTO Silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            -- clean up ids with NAS prefix
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END,
            -- validate birthdates
            CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
            -- standardize gender
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END
        FROM Bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- ERP Location
        SET @start_time = GETDATE();
        PRINT '>> Truncating Silver.erp_loc_a101';
        TRUNCATE TABLE Silver.erp_loc_a101;
        PRINT '>> Inserting data into Silver.erp_loc_a101';

        INSERT INTO Silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid,   -- remove dashes
            CASE 
                WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
                WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
                WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
                ELSE cntry
            END AS cntry
        FROM Bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Batch summary
        SET @batch_end_time = GETDATE();
        PRINT '================================================================';
        PRINT 'Silver Layer Load Completed';
        PRINT 'Total Batch Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================================';

    END TRY
    BEGIN CATCH
        -- Exception handler with error messages
        PRINT '================================================================';
        PRINT 'ERROR OCCURRED DURING SILVER LAYER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================================================';
    END CATCH
END;
GO
