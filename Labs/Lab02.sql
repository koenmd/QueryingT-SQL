USE AdventureWorksLT2012
GO
/*
Challenge 1: Retrieve Data for Transportation Reports
The logistics manager at Adventure Works has asked you to generate some reports containing details of the company’s customers to help to reduce transportation costs. Tip: Review the documentation for the SELECT and ORDER BY clauses in the Transact-SQL Reference.
*/
/*
1. Retrieve a list of cities
Initially, you need to produce a list of all of you customers' locations.
Write a Transact-SQL query that queries the Address table and retrieves all values for City and StateProvince, removing duplicates.
*/

SELECT DISTINCT City, StateProvince
FROM SalesLT.Address
--ORDER BY City

/*
2. Retrieve the heaviest products
Transportation costs are increasing and you need to identify the heaviest products.
Retrieve the names of the top ten percent of products by weight.
*/

SELECT TOP 10 PERCENT 
	Name
	, Weight
FROM SalesLT.Product
ORDER BY Weight DESC

/*
3. Retrieve the heaviest 100 products not including the heaviest ten
The heaviest ten products are transported by a specialist carrier, 
therefore you need to modify the previous query to list the heaviest 100 products not including the heaviest ten.
*/

SELECT TOP 100  
	Name
	, Weight
FROM SalesLT.Product p
WHERE p.ProductID NOT IN
(
	SELECT TOP 10 ProductID
	FROM SalesLT.Product
	ORDER BY Weight DESC
)
ORDER BY Weight DESC

/*
Challenge 2: Retrieve Product Data
The Production Manager at Adventure Works would like you to create some reports listing details of the products that you sell.
Tip: Review the documentation for the WHERE and LIKE keywords in the Transact-SQL Reference.
*/
/*
1. Retrieve product details for product model 1
Initially, you need to find the names, colors, and sizes of the products with a product model ID 1.
*/

SELECT Name, Color, Size
FROM SalesLT.Product p
WHERE p.ProductModelID = 1

/*
2. Filter products by color and size
Retrieve the product number and name of the products that have a color of 'black', 'red', or 'white' and a size of 'S' or 'M'.
*/
SELECT 
	ProductNumber
	, Name
	, Color
	, Size
FROM SalesLT.Product p
WHERE Color 
--COLLATE Latin1_General_CS_AS 
IN (N'black', N'red', N'white')
OR Size IN (N'S', N'M')

/*
3. Filter products by product number
Retrieve the product number, name, and list price of products whose product number begins 'BK-'.
*/

SELECT
	p.ProductNumber
	, p.Name
	, p.ListPrice
FROM SalesLT.Product p
WHERE p.ProductNumber LIKE 'BK-%'

/*
4. Retrieve specific products by product number
Modify your previous query to retrieve the product number, name, and list price of products whose product number begins 'BK-' 
followed by any character other than 'R’, and ends with a '-' followed by any two numerals.
*/
SELECT
	p.ProductNumber
	, p.Name
	, p.ListPrice
FROM SalesLT.Product p
WHERE p.ProductNumber LIKE 'BK-%'
AND p.ProductNumber NOT LIKE 'BK-R%'
AND p.ProductNumber LIKE '%-[0-9][0-9]'

-- of korter
SELECT
	p.ProductNumber
	, p.Name
	, p.ListPrice
FROM SalesLT.Product p
WHERE p.ProductNumber LIKE 'BK-[^R]%-[0-9][0-9]'

