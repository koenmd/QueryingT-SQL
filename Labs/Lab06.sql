USE AdventureWorksLT2012
GO
/*
Challenge 1: Retrieve Product Price Information
Adventure Works products each have a standard cost price that indicates the cost of manufacturing the product, and a list price that indicates the recommended selling price for the product. This data is stored in the SalesLT.Product table. Whenever a product is ordered, the actual unit price at which it was sold is also recorded in the SalesLT.SalesOrderDetail table. You must use subqueries to compare the cost and list prices for each product with the unit prices charged in each sale. Tip: Review the documentation for subqueries in Subquery Fundamentals.
*/
/*
1. Retrieve products whose list price is higher than the average unit price
Retrieve the product ID, name, and list price for each product where the list price is higher than the average unit price 
for all products that have been sold.
*/

SELECT
	p.ProductID
	, p.Name
	, p.ListPrice
FROM SalesLT.Product p
WHERE p.ListPrice >
(
	SELECT AVG(UnitPrice) FROM SalesLT.SalesOrderDetail
)
ORDER BY ProductID


/*
2. Retrieve Products with a list price of $100 or more that have been sold for less than $100
Retrieve the product ID, name, and list price for each product where the list price is $100 or more, and the product has been sold for less than $100.
*/

SELECT
	p.ProductID
	, p.Name
	, p.ListPrice
FROM SalesLT.Product p
WHERE p.ListPrice >= 100
AND p.ProductID IN
(
	SELECT d.ProductID
	FROM SalesLT.SalesOrderDetail d
	WHERE d.ProductID = p.ProductID
	AND d.UnitPrice < 100
)
ORDER BY ProductID

/*
3. Retrieve the cost, list price, and average selling price for each product
Retrieve the product ID, name, cost, and list price for each product along with the average unit price for which that product has been sold.
*/

SELECT
	p.ProductID
	, p.Name
	, p.StandardCost
	, p.ListPrice
	, AvgUnitPrice = AVG(d.UnitPrice)
FROM SalesLT.Product p
JOIN saleslt.SalesOrderDetail d ON d.ProductID = p.ProductID
GROUP BY p.ProductID
	, p.Name
	, p.StandardCost
	, p.ListPrice
ORDER BY p.ProductID

/*
4. Retrieve products that have an average selling price that is lower than the cost
Filter your previous query to include only products where the cost price is higher than the average selling price.
*/

SELECT
	p.ProductID
	, p.Name
	, p.StandardCost
	, p.ListPrice
	, AvgUnitPrice = AVG(d.UnitPrice)
FROM SalesLT.Product p
JOIN saleslt.SalesOrderDetail d ON d.ProductID = p.ProductID
GROUP BY p.ProductID
	, p.Name
	, p.StandardCost
	, p.ListPrice
HAVING p.StandardCost > AVG(d.UnitPrice)
ORDER BY p.ProductID


/*
Challenge 2: Retrieve Customer Information
The AdventureWorksLT database includes a table-valued user-defined function named dbo.ufnGetCustomerInformation. You must use this function to retrieve details of customers based on customer ID values retrieved from tables in the database. Tip: Review the documentation for the APPLY operator in Using APPLY.
*/
/*
1. Retrieve customer information for all sales orders
Retrieve the sales order ID, customer ID, first name, last name, and total due for all sales orders from the SalesLT.SalesOrderHeader table 
and the dbo.ufnGetCustomerInformation function.
*/

SELECT
	h.SalesOrderID
	, h.CustomerID
	, c.FirstName
	, c.LastName
FROM SalesLT.SalesOrderHeader h
CROSS APPLY dbo.ufnGetCustomerInformation(h.CustomerId) c

/*
2. Retrieve customer address information
Retrieve the customer ID, first name, last name, address line 1 and city for all customers 
from the SalesLT.Address and SalesLT.CustomerAddress tables, and the dbo.ufnGetCustomerInformation function.
*/

SELECT 
	c.CustomerID
	, c.FirstName
	, c.LastName
	, a.AddressLine1
	, a.City
FROM SalesLT.Address a
JOIN SalesLT.CustomerAddress ca ON ca.AddressID = a.AddressID
CROSS APPLY dbo.ufnGetCustomerInformation(ca.CustomerId) c
ORDER BY c.CustomerID
