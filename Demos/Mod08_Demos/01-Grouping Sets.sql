SELECT cat.ParentProductCategoryName, cat.ProductCategoryName, count(prd.ProductID) AS Products
FROM SalesLT.vGetAllCategories as cat
LEFT JOIN SalesLT.Product AS prd
ON prd.ProductCategoryID = cat.ProductcategoryID
GROUP BY cat.ParentProductCategoryName, cat.ProductCategoryName
--GROUP BY GROUPING SETS(cat.ParentProductCategoryName, cat.ProductCategoryName, ())
--GROUP BY ROLLUP (cat.ParentProductCategoryName, cat.ProductCategoryName)
--GROUP BY CUBE (cat.ParentProductCategoryName, cat.ProductCategoryName)
ORDER BY cat.ParentProductCategoryName, cat.ProductCategoryName;
GO

CREATE OR ALTER VIEW SalesLT.vSalesOrders
AS
SELECT 
	CustomerName = CONCAT(c.Firstname + ' ', c.LastName)
	, SalesPersonName = c.SalesPerson
	, h.SalesOrderID
	, h.SalesOrderNumber
	, Amount = SUM(d.LineTotal)
FROM SalesLT.SalesOrderHeader h
JOIN SalesLT.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
JOIN SalesLT.Customer c ON c.CustomerID = h.CustomerID
GROUP BY CONCAT(c.Firstname + ' ', c.LastName), c.SalesPerson
, h.SalesOrderID, h.SalesOrderNumber
GO

SELECT GROUPING_ID(SalesPersonName) AS SalesPersonGroup,
	 GROUPING_ID(CustomerName) AS CustomerGroup,
	 SalesPersonName, CustomerName, SUM(Amount) AS TotalAmount
FROM SalesLT.vSalesOrders
GROUP BY CUBE(SalesPersonName, CustomerName)
ORDER BY SalesPersonName, CustomerName;
