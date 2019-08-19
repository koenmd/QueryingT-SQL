SELECT Name, StandardCost, ListPrice
FROM SalesLT.Product;
GO

SELECT Name, ListPrice - StandardCost
FROM SalesLT.Product;
GO

SELECT Name, ListPrice - StandardCost AS Markup
FROM SalesLT.Product;
GO

SELECT ProductNumber, Color, Size, Color + ', ' + Size AS ProductDetails
FROM SalesLT.Product; 
GO

SELECT ProductID + ': ' + Name
FROM SalesLT.Product; 
GO