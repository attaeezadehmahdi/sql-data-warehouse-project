/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================

Script Purpose:

    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:

    - These views can be queried directly for analytics and reporting.
===============================================================================
*/


/*
========================================================
Creating customer view (dimension)
========================================================
*/

CREATE VIEW gold.dim_customers AS 
SELECT 
	ROW_NUMBER() OVER(ORDER BY m.cst_id) AS customer_key,
	m.cst_id AS customer_id,
	m.cst_key AS customer_number,
	m.cst_firstname AS first_name,
	m.cst_lastname AS last_name,
	l.cntry AS country,
	m.cst_marital_status AS marital_status,
	CASE 
		WHEN m.cst_gndr = 'n/a' AND az.gen != 'n/a' AND az.gen IS NOT NULL THEN az.gen
		ELSE m.cst_gndr -- Crm is a master of customer info
	END  AS gender,
	az.bdate AS coustomer_birthdate,
	m.cst_create_date AS create_date
FROM  [silver].[crm_cust_info] m
LEFT JOIN [silver].[erp_luc_a101] l
ON m.cst_key = l.cid
LEFT JOIN [silver].[erp_cust_az12] az
ON m.cst_key = az.cid


/*
====================================================
Creating product view (dimension)
====================================================
*/
CREATE VIEW gold.dim_products AS 
SELECT 
	ROW_NUMBER() OVER(ORDER BY cr.prd_id,cr.prd_key) AS product_key,
	cr.prd_id AS product_id,
	cr.prd_key AS product_number,
	cr.prd_line AS product_line,
	cr.prd_nm AS product_name,
	cr.cat_id AS category_id,
	er.cat AS category,
	er.sucat AS subcategory,
	er.maintenance,
	cr.prd_cost AS cost,
	cr.prd_start_dt AS start_date
-- cr.prd_end_dt AS end_date (because it is null only)
FROM [silver].[crm_prd_info] AS cr
LEFT JOIN [silver].[erp_px_cat_g1v2] AS er
ON cr.cat_id = er.id
WHERE cr.prd_end_dt IS NULL -- Filter out all historical data 


/*
=========================================
Creating sales view (fact)
=========================================
*/
CREATE VIEW gold.fact_sales AS 
SELECT  
	s.sls_ord_num AS order_number,
	c.customer_key,
	p.product_key,
	s.sls_order_dt AS order_detail,
	s.sls_ship_dt AS shipping_date, 
	s.sls_due_dt AS due_date,
	s.sls_sales AS sales_amount, 
	s.sls_quantity AS quantity,
	s.sls_price AS price
FROM DataWarehouse.silver.crm_sales_details AS s
LEFT JOIN gold.dim_customers AS c
ON c.customer_id = s.sls_cust_id
LEFT JOIN gold.dim_products AS p
ON s.sls_prd_key = p.product_number
