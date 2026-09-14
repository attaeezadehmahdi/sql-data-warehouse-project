/*
=====================================================
Creating Bronze Layer Tables
=====================================================
Description:
Create tables for each source table from CRM and ERP
systems to store the raw source data in the Bronze layer
before any transformation or data cleaning.

Before creating each table, check if the table already
exists. If it exists, drop it and recreate the table to
ensure the Bronze layer has the correct table structure.
*/
-- CRM 
USE DataWarehouse;
GO
IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
GO
CREATE TABLE bronze.crm_cust_info
(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(5),
	cst_gndr NVARCHAR(5),
	cst_create_date DATE
);
GO
IF OBJECT_ID('bronze.crm_prd_info','U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
GO
CREATE TABLE bronze.crm_prd_info
(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(75),
	prd_cost MONEY,
	prd_line NVARCHAR(5),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);
GO
IF OBJECT_ID('bronze.crm_sales_details','U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details
(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(75),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales MONEY,
	sls_quantity SMALLINT,
	sls_price MONEY
);
GO
-- ERP
IF OBJECT_ID('bronze.erp_cust_az12','U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
GO
CREATE TABLE bronze.erp_cust_az12
(
	cid NVARCHAR(75),
	bdate DATE,
	gen NVARCHAR(20)
);
GO
IF OBJECT_ID('bronze.erp_luc_a101','U') IS NOT NULL
	DROP TABLE bronze.erp_luc_a101;
GO
CREATE TABLE bronze.erp_luc_a101
(
	cid NVARCHAR(75),
	cntry NVARCHAR(50)

);
GO
IF OBJECT_ID('bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
GO
CREATE TABLE bronze.erp_px_cat_g1v2
(
	id NVARCHAR(20),
    cat NVARCHAR(75),
	sucat NVARCHAR(75),
	maintenance NVARCHAR(10)
);
GO
