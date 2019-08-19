-- DROP TABLE SalesLT.DemoTable
CREATE TABLE SalesLT.DemoTable
(
	Id INT IDENTITY(1,1)
	, [Description] NVARCHAR(100) NOT NULL
)
GO

DECLARE @Counter int=1

WHILE @Counter <=5
BEGIN
	INSERT SalesLT.DemoTable(Description)
	VALUES ('ROW '+CONVERT(varchar(5),@Counter))
	SET @Counter=@Counter+1
END

SELECT Description FROM SalesLT.DemoTable
GO

--Testing for existing values
DECLARE @Counter int=1

DECLARE @Description int
SELECT @Description=MAX(ID)+1
FROM SalesLT.DemoTable

WHILE @Counter <=5
BEGIN
	INSERT SalesLT.DemoTable(Description)
	VALUES ('ROW '+CONVERT(varchar(5),@Description))
	SET @Description=@Description+1
	SET @Counter=@Counter+1
END

SELECT Description FROM SalesLT.DemoTable
GO