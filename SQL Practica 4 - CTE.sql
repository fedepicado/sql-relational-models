-- 1. Usando CTE calcular el máximo, el minimo y el promedio de los productos en
-- las locaciones. Es decir si en una locación hay 3 en otra 5 y en otra hay 6 el
-- máximo es 6, el minimo es 3 y el promedio es 4.6. Nota usar tabla ProductInventory.


WITH Locacion_productos
AS
(
SELECT 
	LocationID,
	COUNT(*) AS Cantidad_Productos
FROM Production.ProductInventory
GROUP BY LocationID
)
SELECT 
	MAX(Cantidad_Productos) AS Maximo,
	MIN(Cantidad_Productos) AS Minimo, 
	AVG(Cantidad_Productos) AS Promedio
FROM Locacion_productos;


--2. Transformar la siguiente consulta en una consulta CTE que evite poner en el
-- select consultas internas.

SELECT SalesOrderID, CustomerID,
(SELECT COUNT(*) FROM Sales.SalesOrderHeader
WHERE CustomerID = S.CustomerID) AS CountOfSales,
(SELECT AVG(TotalDue) FROM Sales.SalesOrderHeader
WHERE CustomerID = S.CustomerID) AS AvgSale,
(SELECT MIN(TotalDue) FROM Sales.SalesOrderHeader
WHERE CustomerID = S.CustomerID) AS LowestSale,
(SELECT MAX(TotalDue) FROM Sales.SalesOrderHeader
WHERE CustomerID = S.CustomerID) AS HighestSale
FROM Sales.SalesOrderHeader AS S;

-- Esta consulta para cada SalesOrderID muestra la orden, el cliente, cuantas ordenes hizo, min, max, avg.

--Con la tabla resumen primero agrupo por cliente y luego calculo las metricas.
WITH Resumen (CustomerID,Cantidad_Ventas,Minimo, Maximo, Promedio ) AS
(
SELECT 
CustomerID,
COUNT(*) AS Cantidad_Ventas,
MIN(TotalDue) AS Minimo,
MAX(TotalDue) AS Maximo,
AVG(TotalDue) AS Promedio
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
)
-- Con el join recupero cada SalesOrderID
SELECT SalesOrderID, r.CustomerID, r.Cantidad_Ventas, r.Minimo, r.Maximo, r.Promedio
FROM Resumen AS r
INNER JOIN Sales.SalesOrderHeader AS soh 
    ON r.CustomerID = soh.CustomerID;


-- 3. Realizar una consulta (usando CTE) que devuelva una lista de los clientes junto
-- con los productos solicitados en el pedido más reciente.


-- pienso para cada cliente cuando fue la ultima compra

WITH UltimaCompra AS (
    SELECT 
        CustomerID,
        MAX(OrderDate) AS UltimaFecha
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
),
-- En un mismo dia puede haber mas de un pedido, como encuentro el pedido mas reciente? Esto no lo habia visto. 
UltimoPedido AS (
    SELECT 
        soh.SalesOrderID, 
        soh.CustomerID
    FROM Sales.SalesOrderHeader soh
    INNER JOIN UltimaCompra uc ON soh.CustomerID = uc.CustomerID AND soh.OrderDate = uc.UltimaFecha
    WHERE soh.SalesOrderID = (
        SELECT MAX(SalesOrderID)
        FROM Sales.SalesOrderHeader 
        WHERE CustomerID = soh.CustomerID AND OrderDate = uc.UltimaFecha
    )
),
-- Saco Id de los productos
ProductosPedido AS (
    SELECT 
        up.CustomerID,
        pod.ProductID
    FROM UltimoPedido up
    INNER JOIN Sales.SalesOrderDetail pod 
        ON up.SalesOrderID = pod.SalesOrderID
)

-- Saco nombre de los productos
SELECT 
    pp.CustomerID,
    p.Name AS NombreProducto
FROM ProductosPedido pp
INNER JOIN Production.Product p 
    ON pp.ProductID = p.ProductID
ORDER BY pp.CustomerID;

-- 4. Para cada empleado obtener el promedio de Rate de pago (sacado de
-- EmployeePayHistory junto con el mismo promedio pero para todos los de su
-- departamento actual (usar Departament y EmployeeDepartamentHistory). Debe
-- devolver algo asi: [BusinessEntityID], promedio, promediodepartamento. 

SELECT 
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'HumanResources'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT TOP 3 * FROM HumanResources.Department
SELECT TOP 3 * FROM HumanResources.EmployeePayHistory
SELECT TOP 3 * FROM HumanResources.EmployeeDepartmentHistory

-- primero creo CTE para encontrar el promedio de Rate para cada empleado
-- Luego calculo el promedio de Rate para un departamento

WITH Prom_Empleados (BusinessEntityID, DepartmentID, Promedio_Rate)
AS
(
SELECT 
	eph.BusinessEntityID,
	edh.DepartmentID,
	AVG(Rate) AS Promedio_Rate
FROM HumanResources.EmployeePayHistory as eph
JOIN HumanResources.EmployeeDepartmentHistory as edh
	ON eph.BusinessEntityID = edh.BusinessEntityID
GROUP BY eph.BusinessEntityID, edh.DepartmentID
)
, 
-- Segundo CTE
Prom_Departamento (DepartmentID,Prom_Departamento)
AS
(
SELECT 
	pe.DepartmentID,
	AVG(Promedio_Rate) AS Prom_Departamento
FROM Prom_Empleados pe
GROUP BY pe.DepartmentID
)

SELECT 
	pe.BusinessEntityID,
	pe.Promedio_Rate,
	pd.Prom_Departamento
FROM Prom_Empleados pe
JOIN Prom_Departamento pd
	ON pe.DepartmentID = pd.DepartmentID;






