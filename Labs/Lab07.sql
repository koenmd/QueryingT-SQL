USE AdventureWorksLT2012
GO
/*
Challenge 1: Retrieve Product Information
Adventure Works sells many products that are variants of the same product model. You must write queries that retrieve information about these products
*/
/*
1. Retrieve product model descriptions
Retrieve the product ID, product name, product model name, and product model summary 
for each product from the SalesLT.Product table and the SalesLT.vProductModelCatalogDescription view.
*/

SELECT
	p.ProductID
	, p.Name
	, [product model name] = v.Name
	, v.Summary
FROM SalesLT.Product p
JOIN SalesLT.vProductModelCatalogDescription v ON p.ProductModelID = v.ProductModelID

/*
2. Create a table of distinct colors Tip: Review the documentation for Variables in Transact-SQL Language Reference.
Create a table variable and populate it with a list of distinct colors from the SalesLT.Product table.
Then use the table variable to filter a query that returns the product ID, name, and color from the SalesLT.Product table 
so that only products with a color listed in the table variable are returned.
*/

DECLARE @Colors TABLE(Color NVARCHAR(15))

INSERT INTO @Colors
SELECT
	DISTINCT p.Color
FROM SalesLT.Product p
WHERE p.Color IS NOT NULL;

SELECT p.ProductID, p.Name, p.Color
FROM SalesLT.Product p
JOIN @Colors c ON c.Color = p.Color
ORDER BY p.Color, p.Name
GO

/*
3. Retrieve product parent categories
The AdventureWorksLT database includes a table-valued function named dbo.ufnGetAllCategories, 
which returns a table of product categories (for example ‘Road Bikes’) 
and parent categories (for example ‘Bikes’). 
Write a query that uses this function to return a list of all products including their parent category and category.
*/

SELECT
	p.ProductID, p.Name, c.ProductCategoryName, c.ParentProductCategoryName
FROM SalesLT.Product p
JOIN dbo.ufnGetAllCategories() c ON c.ProductCategoryID = p.ProductCategoryID
ORDER BY ParentProductCategoryName, ProductCategoryName, ProductID, Name
GO


/*
Challenge 2: Retrieve Customer Sales Revenue
Each Adventure Works customer is a retail company with a named contact.
You must create queries that return the total revenue for each customer, 
including the company and customer contact names. 
Tip: Review the documentation for the WITH common_table_expression syntax in the Transact-SQL language reference.
*/
/*
1. Retrieve sales revenue by customer and contact
Retrieve a list of customers in the format Company (Contact Name) together with the total revenue for that customer.
Use a derived table or a common table expression to retrieve the details for each sales order, 
and then query the derived table or CTE to aggregate and group the data.
*/

;WITH Sales AS
(
	SELECT
		h.CustomerID, SUM(h.TotalDue) AS Total
	FROM SalesLT.SalesOrderHeader h
	GROUP BY h.CustomerID
)
SELECT
	c.CompanyName
	, c.FirstName, c.LastName
	, Total = COALESCE(s.Total, 0)
FROM SalesLT.Customer c
LEFT JOIN Sales s ON s.CustomerID = c.CustomerID
ORDER BY c.CompanyName
GO
