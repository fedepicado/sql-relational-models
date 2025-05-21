-- Una función Window es una función que se aplica a un conjunto de filas. Window es el-- término que usa el estándar SQL para describir el contexto en el que opera la función. SQL usa-- una cláusula llamada OVER en la que se proporciona la especificación de la ventana.

-- OVER con ORDER BY- ROW_NUMBER()

SELECT 
	CustomerID, 
	SalesOrderID,
	ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNumber
FROM Sales.SalesOrderHeader;

-- OVER con PARTITION BY

SELECT CustomerID, SalesOrderID,
ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY SalesOrderID)
AS RowNumber
FROM Sales.SalesOrderHeader;

--
SELECT DISTINCT OrderDate,
ROW_NUMBER() OVER(ORDER BY OrderDate) AS RowNumber
FROM Sales.SalesOrderHeader
ORDER BY RowNumber;


--Ejercicio : A partir del problema anterior con el distinct se pide;
-- • Resolver el problema para que me queden numeradas las ordenes de fechas
-- distintas (es decir un numero por fecha sin repetir fechas.
-- • Obtener la a segunda fecha más antigua.

WITH FechasUnicas AS (
    SELECT DISTINCT OrderDate
    FROM Sales.SalesOrderHeader
)
SELECT 
    OrderDate,
    ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNumber
FROM FechasUnicas;

-------- 
WITH FechasUnicas AS (
    SELECT DISTINCT OrderDate
    FROM Sales.SalesOrderHeader
),
FechasNumeradas AS 
(
    SELECT 
        OrderDate,
        ROW_NUMBER() OVER (ORDER BY OrderDate) AS RowNumber
    FROM FechasUnicas
)
SELECT OrderDate AS SegundaFechaMasAntigua
FROM FechasNumeradas
WHERE RowNumber = 2;


-- Ranking Functions, seguir