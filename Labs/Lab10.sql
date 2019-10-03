USE AdventureWorksLT2012
GO
/*
Challenge 1: Creating scripts to insert sales orders
You want to create reusable scripts that make it easy to insert sales orders. 
You plan to create a script to insert the order header record, and a separate
script to insert order detail records for a specified order header.
Both scripts will make use of variables to make them easy to reuse.
Tip: Review the documentation for variables and the IF…ELSE block in the Transact-SQL Language Reference.
*/
/*
1. Write code to insert an order header
Your script to insert an order header must enable users to specify values for the order date, due date, and customer ID.
The SalesOrderID should be generated from the next value for the SalesLT.SalesOrderNumber sequence and assigned to a variable.
The script should then insert a record into the SalesLT.SalesOrderHeader table using these values and a hard-coded value of 
‘CARGO TRANSPORT 5’ for the shipping method with default or NULL values for all other columns.
After the script has inserted the record, it should display the inserted SalesOrderID using the PRINT command.
Test your code with the following values:

Order Date   : Today’s date
Due Date     : 7 days from now
Customer ID  : 1

Note: Support for Sequence objects was added to Azure SQL Database in version 12, which became available in some regions in February 2015. If you are using the previous version of Azure SQL database (and the corresponding previous version of the AdventureWorksLT sample database), you will need to adapt your code to insert the sales order header without specifying the SalesOrderID (which is an IDENTITY column in older versions of the sample database), and then assign the most recently generated identity value to the variable you have declared.
*/

-- select * from saleslt.SalesOrderHeader
-- SELECT * FROM sys.sequences


-- DROP SEQUENCE SalesLt.SalesOrderID;
CREATE SEQUENCE SalesLt.SalesOrderID  
    START WITH 71947  
    INCREMENT BY 1 ;  
GO  

CREATE OR ALTER PROCEDURE SalesLT.usp_SALESORDERHEADER_I
(@OrderDate DATETIME, @DueDate DATETIME, @CustomerID INT, @SalesOrderID INT OUT)
AS
BEGIN
	SET NOCOUNT ON;
	SET @SalesOrderID = NEXT VALUE FOR SalesLt.SalesOrderID;

	SET IDENTITY_INSERT SalesLt.SalesOrderHeader ON;
	INSERT INTO SalesLt.SalesOrderHeader
	(SalesOrderID,OrderDate, DueDate, CustomerID, ShipMethod)
	SELECT 
		SalesOrderID = @SalesOrderID
		, OrderDate = @OrderDate
		, DueDate = @DueDate
		, CustomerID = @CustomerID
		, ShipMethod = N'CARGO TRANSPORT 5'
	SET IDENTITY_INSERT SalesLt.SalesOrderHeader OFF;

	PRINT @SalesOrderID;
END
GO


-- Test procedure
DECLARE @OrderDate DATETIME, @DueDate DATETIME, @CustomerID INT, @SalesOrderID INT

SET @OrderDate = GETDATE()
SET @DueDate = @OrderDate + 7
SET @CustomerID = 1

EXEC SalesLT.usp_SALESORDERHEADER_I @OrderDate, @DueDate, @CustomerID, @SalesOrderID OUT

GO

/*
2. Write code to insert an order detail
The script to insert an order detail must enable users to specify a sales order ID, a product ID, a quantity, and a unit price.
It must then check to see if the specified sales order ID exists in the SalesLT.SalesOrderHeader table.
If it does, the code should insert the order details into the SalesLT.SalesOrderDetail table 
(using default values or NULL for unspecified columns).
If the sales order ID does not exist in the SalesLT.SalesOrderHeader table,
the code should print the message ‘The order does not exist’. 
You can test for the existence of a record by using the EXISTS predicate.

Test your code with the following values:
Sales Order ID   : The sales order ID returned by your previous code to insert a sales order header.
Product ID       : 760
Quantity         : 1
Unit Price       : 782.99

Then test it again with the following values:
Sales Order ID   : 0
Product ID       : 760
Quantity         : 1
Unit Price       : 782.99
*/

CREATE OR ALTER PROCEDURE SalesLT.usp_SALESORDERDETAIL_I
(@SalesOrderID INT, @ProductID INT, @OrderQty SMALLINT, @UnitPrice MONEY)
AS
BEGIN
	IF EXISTS(SELECT 1 FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID)
		BEGIN
			INSERT INTO SalesLT.SalesOrderDetail
			(SalesOrderID, ProductID, OrderQty, UnitPrice)
			SELECT
				SalesOrderID = @SalesOrderID
				, ProductID = @ProductID
				, OrderQty = @OrderQty
				, UnitPrice = @UnitPrice
		END
	ELSE
		PRINT 'The order does not exist'
END
GO

-- Test procedure (1)
DECLARE @SalesOrderID INT,  @ProductID INT, @OrderQty SMALLINT, @UnitPrice MONEY

SET @SalesOrderID = 71961
SET @ProductID = 760
SET @OrderQty = 1
SET @UnitPrice = 782.99

EXEC SalesLT.usp_SALESORDERDETAIL_I @SalesOrderID, @ProductID, @OrderQty, @UnitPrice
GO

-- Test procedure (2)
DECLARE @SalesOrderID INT,  @ProductID INT, @OrderQty SMALLINT, @UnitPrice MONEY

SET @SalesOrderID = 0
SET @ProductID = 760
SET @OrderQty = 1
SET @UnitPrice = 782.99

EXEC SalesLT.usp_SALESORDERDETAIL_I @SalesOrderID, @ProductID, @OrderQty, @UnitPrice
GO


/*
Challenge 2: Updating Bike Prices
Adventure Works has determined that the market average price for a bike is $2,000,
and consumer research has indicated that the maximum price any customer would be likely to pay for a bike is $5,000. 
You must write some Transact-SQL logic that incrementally increases the list price for all bike products by 10% until
the average list price for a bike is at least the same as the market average, or until the most expensive bike is priced
above the acceptable maximum indicated by the consumer research.
Tip: Review the documentation for WHILE in the Transact-SQL Language Reference.
*/
/*
1. Write a WHILE loop to update bike prices
The loop should:
 Execute only if the average list price of a product in the ‘Bikes’ parent category is less than the market average.
  Note that the product categories in the Bikes parent category can be determined from the SalesLT.vGetAllCategories view.
 Update all products that are in the ‘Bikes’ parent category, increasing the list price by 10%.
 Determine the new average and maximum selling price for products that are in the ‘Bikes’ parent category.
 If the new maximum price is greater than or equal to the maximum acceptable price, exit the loop; otherwise continue.
*/

DECLARE @MarketAverage  DECIMAL(10,2) 
DECLARE @MaximumPrice   DECIMAL(10,2)
DECLARE @CurrentAverage DECIMAL(10,2)
DECLARE @CurrentMaximum DECIMAL(10,2)

SET @MarketAverage = 2000
SET @MaximumPrice  = 5000

SET @CurrentAverage = (SELECT AVG(p.ListPrice) FROM SalesLT.Product p JOIN SalesLT.vGetAllCategories pc ON p.ProductCategoryID = pc.ProductCategoryID WHERE pc.ParentProductCategoryName = 'Bikes');
SET @CurrentMaximum = (SELECT MAX(p.ListPrice) FROM SalesLT.Product p JOIN SalesLT.vGetAllCategories pc ON p.ProductCategoryID = pc.ProductCategoryID WHERE pc.ParentProductCategoryName = 'Bikes');

SELECT @CurrentAverage, @CurrentMaximum

WHILE @CurrentAverage < @MarketAverage AND @CurrentMaximum < @MaximumPrice
BEGIN
	UPDATE SalesLT.Product
	SET ListPrice = ListPrice * 1.1
	WHERE ProductCategoryID IN
	(
		SELECT ProductCategoryID
		FROM Saleslt.vGetAllCategories 
		WHERE ParentProductCategoryName = 'Bikes'
	);
	SET @CurrentAverage = (SELECT AVG(p.ListPrice) FROM SalesLT.Product p JOIN SalesLT.vGetAllCategories pc ON p.ProductCategoryID = pc.ProductCategoryID WHERE pc.ParentProductCategoryName = 'Bikes');
	SET @CurrentMaximum = (SELECT MAX(p.ListPrice) FROM SalesLT.Product p JOIN SalesLT.vGetAllCategories pc ON p.ProductCategoryID = pc.ProductCategoryID WHERE pc.ParentProductCategoryName = 'Bikes');
	SELECT @CurrentAverage, @CurrentMaximum
END
GO
