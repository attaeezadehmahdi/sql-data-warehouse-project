/*
=====================================================
Loading Bronze Layer
=====================================================
Description:
Load raw data from CRM and ERP CSV files into Bronze
tables using a full load (Truncate & Insert). The
procedure tracks loading time, displays progress, and
handles errors using TRY...CATCH.
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN 
	DECLARE @Batch_Starttime DATETIME2, @Batch_Endtime DATETIME2,@Start_time DATETIME2,@End_time DATETIME2;
	BEGIN TRY
		
		PRINT'===================================================';
		PRINT'Start Loading Into Bronze Layer';
		PRINT'===================================================';
		PRINT'===================================================';
		PRINT'Start Loading Table From CRM';
		PRINT'===================================================';
		SET @Batch_Starttime = GETDATE();
		SET @Start_time = GETDATE();
		PRINT'>> Truncate table bronze.crm_cust_info ...';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT'>> Full Load table bronze.crm_cust_info ...';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Ata\OneDrive\Desktop\Current Study\SQL Server\DW SQL\DW_FirsProject\datasets\source_crm\cust_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @End_time = GETDATE()
		PRINT 'Loading Time for Table bronze.crm_cust_info is ' + CAST(DATEDIFF(SECOND,@Start_time,@End_time) AS VARCHAR);
		PRINT'>> Truncate table bronze.crm_prd_info ...';
		SET @Start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT'>> Full Load table bronze.crm_prd_info ...';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Ata\OneDrive\Desktop\Current Study\SQL Server\DW SQL\DW_FirsProject\datasets\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @End_time = GETDATE()
		PRINT 'Loading Time for Table bronze.crm_prd_info is ' + CAST(DATEDIFF(SECOND,@Start_time,@End_time) AS VARCHAR);
		SET @Start_time = GETDATE();
		PRINT'>> Truncate table bronze.crm_sales_details ...';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT'>> Full Load table bronze.crm_sales_details ...';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Ata\OneDrive\Desktop\Current Study\SQL Server\DW SQL\DW_FirsProject\datasets\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @End_time = GETDATE()
		PRINT 'Loading Time for Table bronze.crm_sales_details is ' + CAST(DATEDIFF(SECOND,@Start_time,@End_time) AS VARCHAR);
		PRINT'===================================================';
		PRINT'Start Loading Table From ERP';
		PRINT'===================================================';
		SET @Start_time = GETDATE();
		PRINT'>> Truncate table bronze.erp_cust_az12 ...';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT'>> Full Load table bronze.erp_cust_az12 ...';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Ata\OneDrive\Desktop\Current Study\SQL Server\DW SQL\DW_FirsProject\datasets\source_erp\CUST_AZ12.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @End_time = GETDATE()
		PRINT 'Loading Time for Table bronze.erp_cust_az12 is ' + CAST(DATEDIFF(SECOND,@Start_time,@End_time) AS VARCHAR);
		SET @Start_time = GETDATE();
		PRINT'>> Truncate table bronze.erp_luc_a101 ...';
		TRUNCATE TABLE bronze.erp_luc_a101;
		PRINT'>> Full Load table bronze.erp_luc_a101 ...';
		BULK INSERT bronze.erp_luc_a101
		FROM 'C:\Users\Ata\OneDrive\Desktop\Current Study\SQL Server\DW SQL\DW_FirsProject\datasets\source_erp\LOC_A101.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @End_time = GETDATE()
		PRINT 'Loading Time for Table bronze.erp_luc_a101 is ' + CAST(DATEDIFF(SECOND,@Start_time,@End_time) AS VARCHAR);
		SET @Start_time = GETDATE();
		PRINT'>> Truncate table bronze.erp_px_cat_g1v2 ...';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT'>> Full Load table bronze.erp_px_cat_g1v2 ...';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Ata\OneDrive\Desktop\Current Study\SQL Server\DW SQL\DW_FirsProject\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @End_time = GETDATE()
		PRINT 'Loading Time for Table bronze.erp_px_cat_g1v2 is ' + CAST(DATEDIFF(SECOND,@Start_time,@End_time) AS VARCHAR);
		SET @Batch_Endtime = GETDATE()
		PRINT'===================================================';
		PRINT'Finishing  Load Into Bronze Layer';
		PRINT'Total Time is ' + CAST(DATEDIFF(SECOND,@Batch_Starttime,@Batch_Endtime) AS VARCHAR)
		PRINT'===================================================';
		
	END TRY

	BEGIN CATCH
		PRINT'===================================================';
		PRINT('Loding Proccess Faild');
		PRINT'===================================================';
		PRINT'>> Error Message is ' + ERROR_MESSAGE();
		PRINT'>> Error Number is ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT'>> Error Procedure is ' + ERROR_PROCEDURE();
	END CATCH
END


EXEC bronze.load_bronze;
