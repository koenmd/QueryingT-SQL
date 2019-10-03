USE AdventureWorksLT2012
GO
/*
Challenge 1: Generate Invoice Reports
Adventure Works Cycles sells directly to retailers, who must be invoiced for their orders. You have been tasked with writing a query to generate a list of invoices to be sent to customers. Tip: Review the documentation for the FROM clause in the Transact-SQL Reference.
*/
/*
1. Retrieve customer orders
As an initial step towards generating the invoice report, write a query that returns the company name from the SalesLT.Customer table,
and the sales order ID and total due from the SalesLT.SalesOrderHeader table.
*/

SELECT
	c.CompanyName
	, h.SalesOrderID, h.TotalDue
FROM SalesLT.Customer c
JOIN SalesLT.SalesOrderHeader h ON h.CustomerID = c.CustomerID 
ORDER BY CompanyName, SalesOrderID

/*
2. Retrieve customer orders with addresses
Extend your customer orders query to include the Main Office address for each customer, including the full street address, city, state or province, postal code, and country or region 
Tip: Note that each customer can have multiple addressees in the SalesLT.Address table, so the database developer has created the SalesLT.CustomerAddress table to enable a many-to-many relationship between customers and addresses. 
Your query will need to include both of these tables, and should filter the join to SalesLT.CustomerAddress so that only Main Office addresses are included.
*/

SELECT
	c.CompanyName
	, FullAddress = a.AddressLine1 + COALESCE(N' ' + a.AddressLine2, N'')
	, a.City
	, a.StateProvince
	, a.PostalCode
	, a.CountryRegion
	, h.SalesOrderID, h.TotalDue
FROM SalesLT.Customer c
JOIN SalesLT.CustomerAddress ca ON c.CustomerID = ca.CustomerID
	and ca.AddressType = N'Main Office' 
JOIN SalesLT.Address a ON a.AddressID = ca.AddressID
JOIN SalesLT.SalesOrderHeader h ON h.CustomerID = c.CustomerID 
ORDER BY CompanyName, SalesOrderID


/*
Challenge 2: Retrieve Sales Data
As you continue to work with the Adventure Works customer and sales data, you must create queries for reports that have been requested by the sales team.
*/
/*
1. Retrieve a list of all customers and their orders
The sales manager wants a list of all customer companies and their contacts (first name and last name)
, showing the sales order ID and total due for each order they have placed. 
Customers who have not placed any orders should be included at the bottom of the list with NULL values for the order ID and total due.
*/

SELECT 
	c.CompanyName, c.FirstName, c.LastName
	, h.SalesOrderID, h.TotalDue
FROM SalesLT.Customer c
LEFT JOIN SalesLT.SalesOrderHeader h ON c.CustomerID =h.CustomerID
ORDER BY SalesOrderID DESC

/*
2. Retrieve a list of customers with no address
A sales employee has noticed that Adventure Works does not have address information for all customers. 
You must write a query that returns a list of customer IDs, company names, contact names (first name and last name), and phone numbers for customers with no address stored in the database.
*/

SELECT 
	c.CustomerID
	, c.CompanyName
	, ContactName = CONCAT(c.FirstName,N' ',c.LastName)
	, c.Phone
FROM SalesLT.Customer c
LEFT JOIN SalesLT.CustomerAddress ca ON c.CustomerID = ca.CustomerID
LEFT JOIN SalesLT.Address a ON a.AddressID = ca.AddressID
WHERE a.AddressID IS NULL

/*
3. Retrieve a list of customers and products without orders
Some customers have never placed orders, and some products have never been ordered. 
Create a query that returns a column of customer IDs for customers who have never placed an order,
and a column of product IDs for products that have never been ordered. 
Each row with a customer ID should have a NULL product ID (because the customer has never ordered a product) 
and each row with a product ID should have a NULL customer ID (because the product has never been ordered by a customer).
*/

SELECT 
	c.CustomerID
	, ProductId = CAST(NULL AS INT)
FROM SalesLT.Customer c
LEFT JOIN SalesLT.SalesOrderHeader h ON c.CustomerID = h.CustomerID
WHERE h.SalesOrderID IS NULL
UNION ALL
SELECT
	CustomerID = CAST(NULL AS INT)
	, ProductId = p.ProductID
FROM SalesLT.Product p 
LEFT JOIN Saleslt.SalesOrderDetail od ON od.ProductID = p.ProductID
WHERE od.SalesOrderDetailID IS NULL
GO
