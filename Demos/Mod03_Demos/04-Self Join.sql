--note there's no employee table, so we'll create one for this example
-- DROP TABLE SalesLT.Employee
CREATE TABLE SalesLT.Employee
(EmployeeID int IDENTITY PRIMARY KEY,
EmployeeName nvarchar(256),
ManagerID int);
GO
-- Get salesperson from Customer table and generate managers
-- DELETE FROM SalesLT.Employee
IF NOT EXISTS(SELECT 1 FROM SalesLT.Employee)
BEGIN
	INSERT INTO SalesLT.Employee (EmployeeName, ManagerID)
	SELECT DISTINCT Salesperson, NULLIF(CAST(RIGHT(SalesPerson, 1) as INT), 0)
	FROM SalesLT.Customer
	WHERE NOT EXISTS(
		SELECT 1
		FROM SalesLT.Employee eCheck
		WHERE eCheck.EmployeeName = SalesLT.Customer.SalesPerson
	);
	UPDATE SalesLT.Employee
	SET ManagerID = (SELECT MIN(EmployeeID) FROM SalesLT.Employee WHERE ManagerID IS NULL)
	WHERE ManagerID IS NULL
	AND EmployeeID > (SELECT MIN(EmployeeID) FROM SalesLT.Employee WHERE ManagerID IS NULL);
END
GO
 
-- Here's the actual self-join demo
SELECT e.EmployeeName, m.EmployeeName AS ManagerName
FROM SalesLT.Employee AS e
LEFT JOIN SalesLT.Employee AS m
ON e.ManagerID = m.EmployeeID
ORDER BY e.ManagerID;

