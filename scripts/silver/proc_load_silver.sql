/*
=======================================================
store procedure: load silver layer (bronze --> silver
=======================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.
Actions Performed:

    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:

    None.

    This stored procedure does not accept any parameters or return any values.

Usage Example:

    EXEC Silver.load_silver;
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN 
	DECLARE @START_TIME DATETIME2, @END_TIME DATETIME2 , @START_BATCH DATETIME2,@END_BATCH DATETIME2
	BEGIN TRY
		PRINT'============================================';
		PRINT'Loanding Data in Silver Layer';
		PRINT'============================================';
		PRINT'--------------------------------------------';
		PRINT'Loading CRM tables';
		PRINT'--------------------------------------------';
		SET @START_BATCH = GETDATE()
		PRINT'Truncate table silver.crm_cust_info';
		SET @START_TIME = GETDATE()
		TRUNCATE TABLE silver.crm_cust_info
		PRINT'Insert into silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (cst_id,cst_key,cst_firstname,cst_lastname,cst_gndr, cst_marital_status,cst_create_date)
		SELECT 
			cst_id,
			cst_key,
		-- Remove Spaces from first name and last name
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
		-- Normalize gender data
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE
					'n/a'
			END AS cst_gndr,
		-- Normalize marital status data
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE
					'n/a'
			END AS cst_marital_status,
			cst_create_date
		FROM(
			SELECT
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_ID ORDER BY cst_create_date DESC) AS duplicate_flag
			FROM bronze.crm_cust_info
		--- Remove Nulls
			WHERE cst_id IS NOT NULL
			) t
		--- Removing Duplicate Value 
		WHERE duplicate_flag = 1
		SET @END_TIME = GETDATE()
		PRINT'Insert Time For Table silver.crm_cust_info Is: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS VARCHAR) + ' Seconds';
		PRINT'Truncate table silver.crm_prd_info';
		SET @START_TIME = GETDATE()
		TRUNCATE TABLE silver.crm_prd_info
		PRINT'Insert into silver.crm_prd_info';
		INSERT INTO  silver.crm_prd_info
		(
			prd_id ,
			cat_id ,
			prd_key,
			prd_nm ,
			prd_cost ,
			prd_line,
			prd_start_dt,
			prd_end_dt 
		)
		SELECT 
			prd_id,
			REPLACE(LEFT(prd_key,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost,
			CASE 
				WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line)) = 'O' THEN 'Other Sales'
				WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'	
			END prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt  ,
			CAST(DATEADD(DAY,-1,LEAD(prd_start_dt,1) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) AS prd_end_dt
		FROM bronze.crm_prd_info
		SET @END_TIME = GETDATE()
		PRINT'Insert Time For Table silver.crm_prd_info Is: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS VARCHAR) + ' Seconds'
		SET @START_TIME = GETDATE()
		PRINT'Truncate table silver.crm_sales_details'
		TRUNCATE TABLE silver.crm_sales_details
		PRINT'Insert into silver.crm_sales_details'
		INSERT INTO silver.crm_sales_details
		(
			sls_ord_num ,
			sls_prd_key ,
			sls_cust_id ,
			sls_order_dt ,
			sls_ship_dt ,
			sls_due_dt ,
			sls_sales ,
			sls_quantity ,
			sls_price 
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CONVERT(DATE,CONVERT(VARCHAR,sls_ship_dt,112)) 
			END AS  sls_ship_dt,
			CASE 
				WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CONVERT(DATE,CONVERT(VARCHAR,sls_due_dt,112)) 
			END AS  sls_due_dt,
			CASE 
				WHEN sls_sales !=  sls_quantity * ABS(sls_price) OR sls_sales  IS NULL OR  sls_sales  <= 0 THEN  sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 THEN ABS(sls_sales)/NULLIF(ABS(sls_quantity),0)
				ELSE sls_price
			END sls_price

		FROM bronze.crm_sales_details
		SET @END_TIME = GETDATE()
		PRINT'Insert Time For Table silver.crm_sales_details Is: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS VARCHAR) + ' Seconds';
		SET @START_TIME = GETDATE()
		PRINT'--------------------------------------------';
		PRINT'Loading ERP tables';
		PRINT'--------------------------------------------';
		PRINT'Truncate table silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT'Insert into silver.erp_cust_az12';
		INSERT INTO [silver].[erp_cust_az12](cid,bdate,gen)
		SELECT 
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
				ELSE cid
			END AS cid,
			CASE 
				WHEN bdate > GETDATE() OR bdate < '1900-01-01' THEN NULL
				ELSE bdate
			END AS bdate,
			CASE 
				WHEN LOWER(TRIM(gen)) IN ('f','female') THEN 'Female'
				WHEN LOWER(TRIM(gen)) IN ('m','male') THEN 'Male'
				ELSE 'n/a'
			END gen
		FROM [bronze].[erp_cust_az12]
		SET @END_TIME = GETDATE()
		PRINT'Insert Time For Table silver.erp_cust_az12 Is: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS VARCHAR) + ' Seconds';
		PRINT'Truncate table silver.erp_luc_a101';
		SET @START_TIME = GETDATE()
		TRUNCATE TABLE silver.erp_luc_a101
		PRINT'Insert into silver.erp_luc_a101';
		INSERT INTO [silver].[erp_luc_a101] (cid,cntry)
		SELECT 
			CASE
				WHEN cid LIKE '%-%' THEN REPLACE(cid,'-','')
				ELSE cid
			END AS cid,
			CASE 
				WHEN LOWER(TRIM(cntry)) IN ('usa','united states','us') THEN 'United States'
				WHEN LOWER(TRIM(cntry)) IN ('germany','de') THEN 'Germany'
				WHEN cntry IS NULL OR LEN(TRIM(cntry )) = 0 THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry
		FROM [bronze].[erp_luc_a101]
		SET @END_TIME = GETDATE()
		PRINT'Insert Time For Table silver.erp_luc_a101 Is: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS VARCHAR) + ' Seconds';
		SET @START_TIME = GETDATE()
		PRINT'Truncate table silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT'Insert into silver.erp_px_cat_g1v2';
		INSERT INTO [silver].[erp_px_cat_g1v2] (id,cat,sucat,maintenance)
		SELECT 
			id,
			cat,
			sucat,
			maintenance
		FROM [bronze].[erp_px_cat_g1v2]
		SET @END_TIME = GETDATE()
		SET @END_BATCH = GETDATE()
		PRINT'Insert Time For Table silver.erp_px_cat_g1v2 Is: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS VARCHAR) + ' Seconds';
		PRINT 'Whole Batch succesfully inserted the total time of insert is ' + CAST(DATEDIFF(SECOND,@START_BATCH,@END_BATCH) AS VARCHAR) + ' Seconds';
	END TRY
	BEGIN CATCH;
		PRINT ' SOMETHING WENT WRONG';
		PRINT'Error is ' + ERROR_MESSAGE();
		PRINT'Error Number is' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT'Error Number is' + CAST(ERROR_STATE() AS VARCHAR);
	END CATCH
END 

