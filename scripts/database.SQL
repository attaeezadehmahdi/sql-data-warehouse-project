/*
===============================================================
Creating Databases and Schemas (Bronze, Silver, Gold)
===============================================================
Explanation: First, switch to the master database
and check if the DataWarehouse database already exists
in our SQL Server instance. If it exists, set it to SINGLE_USER
mode and roll back active connections so we can recreate the database.
Then create the DataWarehouse database, switch to it,
and create three schemas: bronze, silver, and gold.
*/
USE master;
GO 
IF EXISTS 
(
	SELECT 1
	FROM sys.databases
	WHERE name = 'DataWarehouse'
)
BEGIN 
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END
GO
CREATE DATABASE DataWarehouse;
GO 
USE DataWarehouse;
GO
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO 
CREATE SCHEMA gold;
