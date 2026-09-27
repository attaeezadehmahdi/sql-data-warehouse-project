/*
=====================================================
Creating Silver Layer Tables
=====================================================
Description:
Create tables for each  tables from bronze layer tables.

Before creating each table, check if the table already
exists. If it exists, drop it and recreate the table to
ensure the silver layer has the correct table structure.
*/
-- CRM 
USE DataWarehouse;
GO
IF OBJECT_ID('silver.crm_cust_info','U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
GO
CREATE TABLE silver.crm_cust_info
(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(10),
	cst_gndr NVARCHAR(10),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
GO
CREATE TABLE silver.crm_prd_info
(
	prd_id INT,
	prd_key NVARCHAR(50),
	cat_id NVARCHAR(10),
	prd_nm NVARCHAR(75),
	prd_cost MONEY,
	prd_line NVARCHAR(10),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
IF OBJECT_ID('silver.crm_sales_details','U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details
(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(75),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales MONEY,
	sls_quantity SMALLINT,
	sls_price MONEY,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
-- ERP
IF OBJECT_ID('silver.erp_cust_az12','U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
GO
CREATE TABLE silver.erp_cust_az12
(
	cid NVARCHAR(75),
	bdate DATE,
	gen NVARCHAR(20),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
IF OBJECT_ID('silver.erp_luc_a101','U') IS NOT NULL
	DROP TABLE silver.erp_luc_a101;
GO
CREATE TABLE silver.erp_luc_a101
(
	cid NVARCHAR(75),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO
IF OBJECT_ID('silver.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
GO
CREATE TABLE silver.erp_px_cat_g1v2
(
	id NVARCHAR(20),
    cat NVARCHAR(75),
	sucat NVARCHAR(75),
	maintenance NVARCHAR(10),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
