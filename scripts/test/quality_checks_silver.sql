/*
===============================================================================
Quality Checks
===============================================================================

Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schema. It includes checks for:
        - Null or duplicate values.
        - Unwanted spaces in string fields.
        - Data standardization and consistency.
        - Invalid date ranges and orders.
        - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/
-- ============================================================================ 
-- Checking 'silver.crm_cust_info'
-- ============================================================================ 
/*

 Checing Primary key for duplicates
 Expected Result: none
*/
USE DataWarehouse;
SELECT
	cst_id,
	COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(cst_id) >1 OR cst_id IS NULL;
SELECT
	*
FROM bronze.crm_cust_info
WHERE cst_id = 29473;
/*
Result

 Result we have null and duplicate value in primary key
 nulls just have cst_key without any attribute
 for duplicate i choose recent data. based on create date

*/
-- Checking for spaces
-- Expected Result: none
SELECT
	*	
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
--- we have extra space 

SELECT
	*	
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)
-- we have extra space 

SELECT
	*	
FROM bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status)
-- we don't have extra space 

SELECT
	*	
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)
-- we don't have extra space 	
/*Result

In First Name and Last Name column we have extra space 
not in other tables.

*/
-- Checking cardinality in gender and martial status
-- Expected Result: M and F for gender, S and M for Martial status.
SELECT DISTINCT 
	cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT 
	cst_marital_status
FROM bronze.crm_cust_info

/*
-- ============================================================================ 
-- Checking 'silver.crm_prd_info'
-- ============================================================================ 
*/

SELECT 
* 
FROM bronze.crm_prd_info
-- Check for nulls and duplicate in primayr key
-- Expectation: no result
SELECT
	prd_id,
	COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL;

SELECT
	SUBSTRING(prd_key,1,5)
FROM bronze.crm_prd_info
-- Check for unwanted space on prd_nm
-- Expectation: no result
SELECT 
* 
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)
-- Check for negative results and nulls 
-- Expectation: no result
SELECT 
* 
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
-- Check for cardinality
SELECT DISTINCT 
	prd_line
FROM bronze.crm_prd_info
-- Check for start date being smaller than end date.
-- Expectation: No result
SELECT 
*
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt
/*
-- ============================================================================ 
-- Checking 'silver.crm_sales_details'
-- ============================================================================ 
*/

SELECT 
*	
FROM bronze.crm_sales_details
WHERE sls_ord_num = 'SO55367'
-- Checing nulls in Sales Order Number
-- Checing for unwanted Space
-- Expectation: no result
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL;

SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);
-- Checking unwanted space 
-- Checing connection with product info throw prd_key
-- Expectation: no result
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key );

SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN(
SELECT sls_prd_key 
FROM silver.crm_prd_info);
-- Checing connection with cutomer info throw cust_id
-- Expectation: no result
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN(
SELECT sls_cust_id 
FROM silver.crm_cust_info);
-- Checking for Invalid Dates sls_order_dt


SELECT 
*
FROM bronze.crm_sales_details
WHERE 	sls_order_dt <= 0
OR LEN(sls_order_dt) != 8
OR sls_order_dt >20300101
OR sls_order_dt <19000101

-- Checking for Invalid Dates sls_ship_dt
SELECT 
*
FROM bronze.crm_sales_details
WHERE 	sls_ship_dt <= 0
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt >20300101
OR sls_ship_dt <19000101
-- Checking for Invalid Dates sls_due_dt
SELECT 
*
FROM bronze.crm_sales_details
WHERE 	sls_due_dt <= 0
OR LEN(sls_due_dt) != 8
OR sls_due_dt >20300101
OR sls_due_dt <19000101
-- Checking for Invalid order  Dates 
-- Expectation: No result
SELECT 
*
FROM bronze.crm_sales_details
WHERE 	sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt
-- Checking for sls_sales	sls_quantity	sls_price
-- bussiness rules sls_sales = sls_quantity * sls_price
SELECT 
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_sales !=  sls_quantity * sls_price
OR  sls_sales  IS NULL OR sls_quantity IS NULL OR  sls_price IS NULL
OR  sls_sales  <= 0 OR sls_quantity <= 0 OR  sls_price <= 0

/*
-- ============================================================================ 
-- Checking 'silver.erp_cust_az12'
-- ============================================================================ 
*/
SELECT
*
FROM [bronze].[erp_cust_az12]
-- Check for null
-- Check for relation with crm customer table
-- Expectation: No result
SELECT 
	cid,
	COUNT(cid)
FROM [bronze].[erp_cust_az12]
GROUP BY cid
HAVING COUNT(cid) > 1 OR cid IS NULL;

SELECT
	REPLACE(erp.cid,'NAS','') AS erp_customer_key,
	crm.cst_key
FROM [bronze].[erp_cust_az12] AS erp
LEFT JOIN [bronze].[crm_cust_info] crm
ON REPLACE(erp.cid,'NAS','') = crm.cst_key
WHERE crm.cst_key IS NULL
-- Check for invalid date data
-- Expectation : no result
SELECT
*
FROM [bronze].[erp_cust_az12]
WHERE DATEDIFF(YEAR,GETDATE(),bdate) > 1
OR bdate < '1900-01-01'
-- Check for data cardinality
-- Expectation : one of (Male or M) and one of (Female or F) 
SELECT DISTINCT
 gen
FROM [bronze].[erp_cust_az12]
/*
-- ============================================================================ 
-- Checking 'silver.erp_luc_a101'
-- ============================================================================ 
*/
SELECT
	*
FROM [bronze].[erp_luc_a101]
-- Check for duplicate and null
-- Check for relation with crm_cust_info
SELECT 
	cid,
	COUNT(cid) 
FROM [bronze].[erp_luc_a101]
GROUP BY cid
HAVING COUNT(cid) > 1 AND cid IS NULL;

SELECT 
	*
FROM [bronze].[erp_luc_a101] erp
WHERE NOT EXISTS
	(
		SELECT 1
		FROM [bronze].[crm_cust_info] crm
		WHERE crm.cst_key = REPLACE(erp.cid,'-','')
		)

-- Checking for cardinality  (Standarsization and consistency)
SELECT DISTINCT
	cntry
FROM [bronze].[erp_luc_a101]

SELECT DISTINCT
	CASE 
		WHEN LOWER(TRIM(cntry)) IN ('usa','united states','us') THEN 'United States'
		WHEN LOWER(TRIM(cntry)) IN ('germany','de') THEN 'Germany'
		WHEN cntry IS NULL OR LEN(TRIM(cntry )) = 0 THEN 'n/a'
		ELSE TRIM(cntry)
	END AS cntry
		
FROM [bronze].[erp_luc_a101]
/*
-- ============================================================================ 
-- Checking 'silver.erp_px_cat_g1v2'
-- ============================================================================ 
*/

SELECT
	*
FROM [silver].[erp_px_cat_g1v2]

SELECT
	*
FROM [bronze].[erp_px_cat_g1v2] 
-- Checing relation to [silver].[crm_prd_info]
SELECT 
*
FROM [bronze].[erp_px_cat_g1v2] erp
WHERE NOT EXISTS
(
SELECT
	1 
FROM [silver].[crm_prd_info] crm 
WHERE crm.cat_id = erp.id
)
--Checking cardinality 
SELECT DISTINCT
	cat
FROM [bronze].[erp_px_cat_g1v2]
--Cheking cardinality
SELECT DISTINCT
	sucat
FROM [bronze].[erp_px_cat_g1v2]

SELECT DISTINCT 
	cat,
	sucat
FROM [bronze].[erp_px_cat_g1v2]
-- Cheking for unwanted space
SELECT
	*
FROM [bronze].[erp_px_cat_g1v2] 
WHERE cat!=TRIM(cat) OR sucat!=TRIM(sucat) OR maintenance != TRIM(maintenance)
