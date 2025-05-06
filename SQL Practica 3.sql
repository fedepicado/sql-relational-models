-- 1.Usando subconsultas, obtener Id y nombre de los productos que hayan sido vendidos durante el año 2013
SELECT TOP 5 * FROM Production.Product

SELECT TOP 5 * FROM Sales.SalesOrderDetail 
SELECT TOP 5 * FROM Sales.SalesOrderHeader

SELECT 
    p.ProductID, 
    p.Name AS Nombre
FROM Production.Product p
WHERE p.ProductID IN (
    SELECT DISTINCT sod.ProductID
    FROM Sales.SalesOrderDetail sod
    INNER JOIN Sales.SalesOrderHeader soh 
		ON sod.SalesOrderID = soh.SalesOrderID
    WHERE YEAR(soh.OrderDate) = 2013
)

-- 2. Usando subconsultas, obtener Id y nombre de los productos que no hayan sido vendidos nunca.

SELECT TOP 5 * FROM Production.Product
SELECT TOP 5 * FROM Sales.SalesOrderDetail
SELECT TOP 5 * FROM Sales.SalesOrderHeader

SELECT 
    p.ProductID, 
    p.Name
FROM Production.Product p
WHERE p.ProductID NOT IN (
    SELECT DISTINCT sod.ProductID
    FROM Sales.SalesOrderDetail sod
    INNER JOIN Sales.SalesOrderHeader soh 
		ON sod.SalesOrderID = soh.SalesOrderID
)

-- 3. Obtener los productos vendidos de mayor precio unitario, entre los vendidos en el año 2013.

SELECT TOP 5 * FROM Production.Product
SELECT TOP 5 * FROM Sales.SalesOrderDetail
SELECT TOP 5 * FROM Sales.SalesOrderHeader

SELECT 
    p.ProductID, 
    p.Name, 
    sod.UnitPrice
FROM Production.Product p
INNER JOIN Sales.SalesOrderDetail sod 
	ON p.ProductID = sod.ProductID
INNER JOIN Sales.SalesOrderHeader soh 
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE YEAR(soh.OrderDate) = 2013
  AND sod.UnitPrice = (
    SELECT MAX(sod2.UnitPrice)
    FROM Sales.SalesOrderDetail sod2
    INNER JOIN Sales.SalesOrderHeader soh2 
		ON sod2.SalesOrderID = soh2.SalesOrderID
    WHERE YEAR(soh2.OrderDate) = 2013
)

-- 4. Mostrar los departamentos que tengan máxima cantidad de empleados.

SELECT TOP 5 * FROM HumanResources.EmployeeDepartmentHistory
SELECT TOP 5 * FROM HumanResources.Department

SELECT 
    d.Name AS Departamento,
    COUNT(*) AS CantidadEmpleados
FROM 
    HumanResources.EmployeeDepartmentHistory edh
INNER JOIN 
    HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
GROUP BY 
    d.Name
HAVING COUNT(*) = (
        SELECT MAX(ConteoEmpleados)
        FROM (
            SELECT 
                DepartmentID,
                COUNT(*) AS ConteoEmpleados
            FROM HumanResources.EmployeeDepartmentHistory
            GROUP BY DepartmentID
        ) AS Subconsulta
)


-- 5. Hallar los empleados que con menor antiguedad dentro de cada departamento.

SELECT TOP 5 * FROM HumanResources.EmployeeDepartmentHistory
SELECT TOP 5 * FROM HumanResources.Department


SELECT 
    edh.BusinessEntityID,
    d.Name AS Departamento,
    edh.StartDate
FROM HumanResources.EmployeeDepartmentHistory edh
INNER JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
WHERE edh.StartDate = (
    SELECT MIN(edh2.StartDate)
    FROM HumanResources.EmployeeDepartmentHistory edh2
    WHERE edh2.DepartmentID = edh.DepartmentID
)

-- 6. Hallar las provincias que tengan más cantidad de domicilios que los que tiene la provincia con Id 58.

SELECT TOP 5 * FROM Person.Address
SELECT TOP 5 * FROM Person.StateProvince

SELECT 
    sp.StateProvinceID, 
    sp.Name, 
    COUNT(a.AddressID) AS CantidadDomicilios
FROM Person.Address a
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
GROUP BY sp.StateProvinceID, sp.Name
HAVING COUNT(a.AddressID) > (
    SELECT COUNT(a2.AddressID) 
	FROM Person.Address a2
	WHERE a2.StateProvinceID =58
)


-- 7. Hallar año y mes de fechas de modificación coincidentes entre los registros de la tabla Person
-- para el tipo de persona “EM” y los registros de la tabla Address para la provincia con nombre “Washington”.

SELECT TOP 5 * FROM Person.Person 
SELECT TOP 5 * FROM Person.Address
SELECT TOP 5 * FROM Person.StateProvince


SELECT DISTINCT 
    YEAR(p.ModifiedDate) AS Año,
    MONTH(p.ModifiedDate) AS Mes
FROM Person.Person p
WHERE p.PersonType = 'EM'
AND EXISTS (
    SELECT 1
    FROM Person.Address a
    INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
    WHERE sp.Name = 'Washington'
      AND YEAR(a.ModifiedDate) = YEAR(p.ModifiedDate)
      AND MONTH(a.ModifiedDate) = MONTH(p.ModifiedDate)
)

-- 8. Determinar si existen empleados y clientes con mismo Id, usando subconsultas

SELECT TOP 5 * FROM HumanResources.Employee 
SELECT TOP 5 * FROM Sales.Customer

-- Con INTERSECT
SELECT e.BusinessEntityID
FROM HumanResources.Employee e
INTERSECT
SELECT c.CustomerID
FROM Sales.Customer c

-- Subconsulta

SELECT BusinessEntityID
FROM HumanResources.Employee
WHERE BusinessEntityID IN 
	(SELECT CustomerID	
	FROM Sales.Customer)

-- 9. Mostrar los años de las ventas registradas y de las compras registradas. Identificar para cada
-- año, si corresponde a ventas ó a compras.


SELECT TOP 5 * FROM Sales.SalesOrderHeader
SELECT TOP 5 * FROM Purchasing.PurchaseOrderHeader

SELECT DISTINCT 
    YEAR(OrderDate) AS Año,
    'Venta' AS Tipo
FROM Sales.SalesOrderHeader
UNION
SELECT DISTINCT 
    YEAR(ShipDate) AS Año,
    'Compra' AS Tipo
FROM Purchasing.PurchaseOrderHeader

-- 10. Para la anterior consulta, ordenarla por año descendente

SELECT DISTINCT 
    YEAR(OrderDate) AS Año,
    'Venta' AS Tipo
FROM Sales.SalesOrderHeader
UNION
SELECT DISTINCT 
    YEAR(ShipDate) AS Año,
    'Compra' AS Tipo
FROM Purchasing.PurchaseOrderHeader
ORDER BY Año DESC

-- 11. Para cada venta, encontrar la denominación del producto de mayor precio total (precio x
-- cantidad) de su propia orden.

SELECT 
    T.SalesOrderID,
    T.ProductName,
    T.PrecioTotal
FROM (
    SELECT 
        sod.SalesOrderID,
        p.Name AS ProductName,
        sod.UnitPrice * sod.OrderQty AS PrecioTotal,
        ROW_NUMBER() OVER (
            PARTITION BY sod.SalesOrderID 
            ORDER BY sod.UnitPrice * sod.OrderQty DESC
        ) AS rn
    FROM Sales.SalesOrderDetail sod
    INNER JOIN Production.Product p
        ON sod.ProductID = p.ProductID
) AS T
WHERE T.rn = 1

-- 12. Encontrar el nombre de los productos que no pertenezcan a la subcategoría “Wheels”. Usar EXISTS.

SELECT TOP 5 * FROM Production.Product p
SELECT TOP 5 * FROM Production.ProductSubcategory

SELECT p.Name
FROM Production.Product p
WHERE NOT EXISTS (
    SELECT 1 
    FROM Production.ProductSubcategory sc
    WHERE sc.ProductSubcategoryID = p.ProductSubcategoryID 
      AND sc.Name = 'Wheels'
)

-- 13. Encontrar el nombre de los productos cuyo precio de lista es mayor o igual al máximo precio
-- de lista de cualquier subcategoría de producto.

SELECT TOP 5 * FROM Production.Product p

SELECT p.Name
FROM Production.Product p
WHERE p.ListPrice >= (
    SELECT MAX(p2.ListPrice)
    FROM Production.Product p2
    WHERE p2.ProductSubcategoryID = p.ProductSubcategoryID
)


-- 14. Encontrar los nombres de los empleados que también sean vendedores. Usar subconsultas
--anidadas.

SELECT 
    p.FirstName, 
    p.LastName
FROM Person.Person p
WHERE p.BusinessEntityID IN (
    SELECT BusinessEntityID
    FROM HumanResources.Employee
    WHERE BusinessEntityID IN (
        SELECT BusinessEntityID
        FROM Sales.SalesPerson
    )
)