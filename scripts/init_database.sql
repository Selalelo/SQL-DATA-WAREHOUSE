/*
    ----------------------------------------------------------
    SQL Data Warehouse Project - Database and Schema Creation
    ----------------------------------------------------------

    WARNING:
    This script will DROP the existing DataWarehouse database if it exists,
    resulting in the permanent loss of all its current data. 
    Make sure to back up any important data before running this script.

    ----------------------------------------------------------
    DESCRIPTION:
    This script sets up the foundational layers of a modern data warehouse
    architecture in SQL Server. It does the following:

    - Drops and recreates the DataWarehouse database to ensure a clean state
    - Creates separate schemas to organize data pipelines:
        * Bronze schema: for raw, ingested data
        * Silver schema: for cleansed, transformed data
        * Gold schema: for curated, analytics-ready data
    This layered approach follows best practices for data engineering.
*/

-- Drop the database if it exists, to recreate from scratch
DROP DATABASE IF EXISTS DataWarehouse;
GO

-- Create the DataWarehouse database
CREATE DATABASE DataWarehouse;
GO

-- Switch context to the newly created database
USE DataWarehouse;
GO

-- Create Bronze schema for raw data ingestion
CREATE SCHEMA Bronze;
GO

-- Create Silver schema for cleansed and transformed data
CREATE SCHEMA Silver;
GO

-- Create Gold schema for curated, analytics-ready data
CREATE SCHEMA Gold;
GO
