/*
    ----------------------------------------------------------
    SQL Data Warehouse Project - Bronze Layer Load Procedure
    ----------------------------------------------------------

    WARNING:
    This procedure will TRUNCATE (completely empty) all Bronze tables 
    before reloading them from CSV files. Existing data will be lost. 
    Ensure your source files are correct and you have backups if needed.

    ----------------------------------------------------------
    DESCRIPTION:
    This stored procedure handles the ETL loading of the Bronze layer
    in the DataWarehouse, performing the following steps:
    
    - Logs the start and end times of each bulk insert
    - Truncates each Bronze table to clear previous data
    - Bulk-loads new data from CSV files into each Bronze table
    - Measures and prints the duration of each load step for monitoring
    - Handles any errors using TRY/CATCH with detailed error output

    This procedure follows best practices for a controlled
    and trackable data ingestion process in the staging layer.
*/

CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
    -- Declare variables to track load timing
    DECLARE @start_time DATETIME, 
            @end_time DATETIME, 
            @batch_start_time DATETIME, 
            @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '============================';
        PRINT 'Starting Bronze Layer Load';
        PRINT '============================';

        /*
            -----------------------
            CRM Data Load
            -----------------------
        */
        PRINT '--------------------';
        PRINT 'Loading CRM Tables';
        PRINT '--------------------';

        -- Load CRM Customer Info
        SET @start_time = GETDATE();
        PRINT '>> Truncating Bronze.crm_cust_info';
        TRUNCATE TABLE Bronze.crm_cust_info;
        PRINT '>> Inserting data into Bronze.crm_cust_info';
        BULK INSERT Bronze.crm_cust_info
        FROM 'C:\Users\tshid\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Load CRM Product Info
        SET @start_time = GETDATE();
        PRINT '>> Truncating Bronze.crm_prd_info';
        TRUNCATE TABLE Bronze.crm_prd_info;
        PRINT '>> Inserting data into Bronze.crm_prd_info';
        BULK INSERT Bronze.crm_prd_info
        FROM 'C:\Users\tshid\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Load CRM Sales Details
        SET @start_time = GETDATE();
        PRINT '>> Truncating Bronze.crm_sales_details';
        TRUNCATE TABLE Bronze.crm_sales_details;
        PRINT '>> Inserting data into Bronze.crm_sales_details';
        BULK INSERT Bronze.crm_sales_details
        FROM 'C:\Users\tshid\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        /*
            -----------------------
            ERP Data Load
            -----------------------
        */
        PRINT '--------------------';
        PRINT 'Loading ERP Tables';
        PRINT '--------------------';

        -- Load ERP Location
        SET @start_time = GETDATE();
        PRINT '>> Truncating Bronze.erp_loc_a101';
        TRUNCATE TABLE Bronze.erp_loc_a101;
        PRINT '>> Inserting data into Bronze.erp_loc_a101';
        BULK INSERT Bronze.erp_loc_a101
        FROM 'C:\Users\tshid\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Load ERP Customer
        SET @start_time = GETDATE();
        PRINT '>> Truncating Bronze.erp_cust_az12';
        TRUNCATE TABLE Bronze.erp_cust_az12;
        PRINT '>> Inserting data into Bronze.erp_cust_az12';
        BULK INSERT Bronze.erp_cust_az12
        FROM 'C:\Users\tshid\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Load ERP Product Categories
        SET @start_time = GETDATE();
        PRINT '>> Truncating Bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE Bronze.erp_px_cat_g1v2;
        PRINT '>> Inserting data into Bronze.erp_px_cat_g1v2';
        BULK INSERT Bronze.erp_px_cat_g1v2
        FROM 'C:\Users\tshid\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Final completion message
        SET @batch_end_time = GETDATE();
        PRINT '================================================================';
        PRINT 'Bronze Layer Load Completed';
        PRINT 'Total Batch Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================================';

    END TRY
    BEGIN CATCH
        -- Capture and report errors
        PRINT '================================================================';
        PRINT 'ERROR OCCURRED DURING BRONZE LAYER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================================================';
    END CATCH
END;
GO

-- Execute the procedure to test loading the Bronze layer
EXEC Bronze.load_bronze;
