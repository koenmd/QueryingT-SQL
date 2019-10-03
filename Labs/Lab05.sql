USE AdventureWorksLT2012
GO
/*
Challenge 1: Retrieve Product Information
Your reports are returning the correct records, but you would like to modify how these records are displayed. Tip: Review the documentation for Built-In Functions in the Transact-SQL Reference.
*/
/*
1. Retrieve the name and approximate weight of each product
Write a query to return the product ID of each product, together with the product name formatted as upper case and a column named ApproxWeight with the weight of each product rounded to the nearest whole unit.
*/

SELECT
	ProductID
	, ProductName = UPPER(Name)
	, ApproxWeight = ROUND(Weight,0)
FROM SalesLT.Product p
ORDER BY ProductID

/*
2. Retrieve the year and month in which products were first sold
Extend your query to include columns named SellStartYear and SellStartMonth containing the year and month in which Adventure Works started selling each product.
The month should be displayed as the month name (for example, ‘January’).
*/

SELECT
	ProductID
	, ProductName = UPPER(Name)
	, ApproxWeight = ROUND(Weight,0)
	, SellStartYear = YEAR(p.SellStartDate)
	, SellStartMonth = DATENAME(m,p.SellStartDate)
	--, SellStartDate
FROM SalesLT.Product p
ORDER BY ProductID

/*
3. Extract product types from product numbers
Extend your query to include a column named ProductType that contains the leftmost two characters from the product number.
*/

SELECT
	ProductID
	, ProductName = UPPER(Name)
	, ApproxWeight = ROUND(Weight,0)
	, SellStartYear = YEAR(p.SellStartDate)
	, SellStartMonth = DATENAME(m,p.SellStartDate)
	--, SellStartDate
	, ProductType = LEFT(p.ProductNumber,2)
FROM SalesLT.Product p
ORDER BY ProductID

/*
4. Retrieve only products with a numeric size
Extend your query to filter the product returned so that only products with a numeric size are included.
*/

SELECT
	ProductID
	, ProductName = UPPER(Name)
	, ApproxWeight = ROUND(Weight,0)
	, SellStartYear = YEAR(p.SellStartDate)
	, SellStartMonth = DATENAME(m,p.SellStartDate)
	--, SellStartDate
	, ProductType = LEFT(p.ProductNumber,2)
	, Size
FROM SalesLT.Product p
WHERE ISNUMERIC(p.Size) = 1
ORDER BY ProductID

/*
Challenge 2: Rank Customers by Revenue
The sales manager would like a list of customers ranked by sales. Tip: Review the documentation for Ranking Functions in the Transact-SQL Reference.
*/
/*
1. Retrieve companies ranked by sales totals
Write a query that returns a list of company names with a ranking of their place in a list of highest TotalDue values from the SalesOrderHeader table.
*/

SELECT
	c.CompanyName
	, TotalDue = SUM(h.TotalDue)
	, Rang = RANK() OVER(ORDER BY SUM(h.TotalDue) DESC)
FROM SalesLT.Customer c
JOIN saleslt.SalesOrderHeader h on h.CustomerID = c.CustomerID
GROUP BY c.CompanyName
ORDER BY Rang




/*
Challenge 3: Aggregate Product Sales
The product manager would like aggregated information about product sales. Tip: Review the documentation for the GROUP BY clause in the Transact-SQL Reference.
*/
/*
1. Retrieve total sales by product
Write a query to retrieve a list of the product names and the total revenue calculated as the sum of the LineTotal from the SalesLT.SalesOrderDetail table
, with the results sorted in descending order of total revenue.
*/

SELECT
	p.Name
	, TotalRevenue = SUM(d.LineTotal)
FROM SalesLT.Product p
JOIN SalesLT.SalesOrderDetail d ON d.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC

/*
2. Filter the product sales list to include only products that cost over $1,000
Modify the previous query to include sales totals for products that have a list price of more than $1000.
*/

SELECT
	p.Name
	, TotalRevenue = SUM(d.LineTotal)
FROM SalesLT.Product p
JOIN SalesLT.SalesOrderDetail d ON d.ProductID = p.ProductID
WHERE p.ListPrice > 1000
GROUP BY p.Name
ORDER BY TotalRevenue DESC

/*
3. Filter the product sales groups to include only total sales over $20,000
Modify the previous query to only include only product groups with a total sales value greater than $20,000.
*/

SELECT
	p.Name
	, TotalRevenue = SUM(d.LineTotal)
FROM SalesLT.Product p
JOIN SalesLT.SalesOrderDetail d ON d.ProductID = p.ProductID
WHERE p.ListPrice > 1000
AND p.ProductCategoryID IN
(
	SELECT pcheck.ProductCategoryID
	FROM SalesLT.Product pCheck
	JOIN SalesLT.SalesOrderDetail dCheck ON pCheck.ProductID = dCheck.ProductID
	GROUP BY pcheck.ProductCategoryID
	HAVING SUM(dCheck.LineTotal)>20000
)
GROUP BY p.Name, p.ProductCategoryID
ORDER BY TotalRevenue DESC

