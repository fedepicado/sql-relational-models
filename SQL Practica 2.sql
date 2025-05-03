-- 1. La tabla Employee no contiene el nombre de los empleados. Ese dato se encuentra en la tabla 
--Person. La columna que relaciona ambas tablas es BusinessEntityID
-- a) Si existe una FK entre ambas tablas, cómo podemos corroborar su existencia?

-- RTA: Consultar el modelo de datos ya que la existencia de una FK es una restricción  definida a nivel estructural.
-- Una FK asegura la integridad referencial entre dos tablas, indicando que una columna en una tabla (como BusinessEntityID en Employee)
-- debe coincidir con una clave primaria en otra tabla.


SELECT p.BusinessEntityID,
p.FirstName as Nombre 
FROM Person.Person p INNER JOIN HumanResources.Employee e 
	ON e.BusinessEntityID = p.BusinessEntityID


-- b) Obtener el nombre, apellido, cargo y fecha de nacimiento de todos los empleados.

SELECT
	p.FirstName as Nombre, 
	p.LastName as Apellido,
	e.JobTitle as Cargo,
	e.BirthDate as Fecha_de_nacimiento
FROM Person.Person p INNER JOIN HumanResources.Employee e 
	ON e.BusinessEntityID = p.BusinessEntityID

-- c) Obtener el nombre y apellido de los empleados que nacieron durante el año 1986 y su “género” es F.

SELECT
	p.FirstName as Nombre, 
	p.LastName as Apellido
FROM Person.Person p INNER JOIN HumanResources.Employee e 
	ON e.BusinessEntityID = p.BusinessEntityID
WHERE YEAR(e.BirthDate) = 1986 and e.Gender = 'F'

-- d) Contar la cantidad de empleados cuyo nombre comience con la letra “J” y hayan nacido después del año 1977.

SELECT
	COUNT(p.BusinessEntityID) as Cantidad_Empleados
FROM Person.Person p INNER JOIN HumanResources.Employee e 
	ON e.BusinessEntityID = p.BusinessEntityID
WHERE YEAR(e.BirthDate) > 1977 and p.FirstName LIKE 'J%'

-- e) Para las mismas condiciones del punto anterior, cuántos empleados están registrados según su género?

SELECT
	e.Gender,
	COUNT(p.BusinessEntityID) as Cantidad_Empleados
FROM Person.Person p 
INNER JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
WHERE YEAR(e.BirthDate) > 1977 AND p.FirstName LIKE 'J%'
GROUP BY e.Gender


-- 2. La tabla Customers tampoco contiene el nombre de los clientes. La columna que las relaciona es, PersonID
-- a) Obtener nombre, apellido, storeId para aquellos clientes que estén en el TerritoryID = 4 ó
-- que pertenezcan al tipo de persona 4 (PersonType). Persona 4 asumo SC

SELECT 
    p.FirstName AS Nombre,
    p.LastName AS Apellido,
    c.StoreID AS Tienda
FROM Sales.Customer c
INNER JOIN Person.Person p 
    ON c.PersonID = p.BusinessEntityID
WHERE c.TerritoryID = 4 OR p.PersonType = 'SC' 

-- b) ¿cuáles son el nombre, apellido y número de orden de venta (SaleOrderID) para los
-- clientes que pertenecen al tipo de persona 4?

SELECT 
    p.FirstName AS Nombre,
    p.LastName AS Apellido,
    s.SalesOrderID AS NumeroVenta
FROM Sales.Customer c
INNER JOIN Person.Person p 
    ON c.PersonID = p.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader s
	ON c.CustomerID = s.CustomerID
WHERE c.TerritoryID = 4 OR p.PersonType = 'SC' 

-- 3. La tabla Product contiene los productos y la tabla ProductModel, los modelos.
-- a) Encontrar la descripción del producto, su tamaño y la descripción del modelo relacionado,
-- para aquellos productos que no tengan color indicado y para los cuales el nivel seguro de
-- stock (SafetyStockLevel) sea menor estricto a 1000. 

SELECT 
	pd.Description AS Descripcion, 
	p.Size as Tamaño
FROM Production.Product p 
INNER JOIN Production.ProductDescription pd
	ON p.ProductID = pd.ProductDescriptionID
WHERE p.Size IS NULL AND p.SafetyStockLevel < 1000


-- b) Obtener todas las ventas de los meses de junio y julio del 2011. Mostrar el nombre y
-- apellido del cliente, el nro de venta, su fecha, nombre y modelo del producto vendido.

SELECT p.FirstName ,
	p.LastName ,
	soh.SalesOrderNumber as NumeroVenta,
	pm.Name as nombreModeloProducto,
	soh.OrderDate 
FROM Person.Person p 
INNER JOIN Sales.Customer c 
	ON p.BusinessEntityID = c.PersonID
INNER JOIN Sales.SalesOrderHeader soh 
	ON c.CustomerID = soh.CustomerID
INNER JOIN Sales.SalesOrderDetail sod 
	ON soh.SalesOrderID = sod.SalesOrderID 
INNER JOIN Production.Product p2 
	ON sod.ProductID = p2.ProductID
INNER JOIN  Production.ProductModel pm 
	ON p2.ProductModelID  = pm.ProductModelID 
WHERE YEAR(soh.OrderDate) = 2011 AND MONTH(soh.OrderDate) IN (6, 7)

-- 4. Mostrar todos la descripción de los productos y el id de la orden de venta. Incluir aquellos
-- productos que nunca se hayan vendido.

SELECT 
    pd.Description AS DescripcionProducto,
    soh.SalesOrderID AS ID_Oden_Venta
FROM Production.Product p
LEFT JOIN Production.ProductModel pm 
    ON p.ProductModelID = pm.ProductModelID
LEFT JOIN Production.ProductModelProductDescriptionCulture pdpc 
    ON pm.ProductModelID = pdpc.ProductModelID
LEFT JOIN Production.ProductDescription pd 
    ON pdpc.ProductDescriptionID = pd.ProductDescriptionID
LEFT JOIN Sales.SalesOrderDetail sod 
    ON p.ProductID = sod.ProductID
LEFT JOIN Sales.SalesOrderHeader soh 
    ON sod.SalesOrderID = soh.SalesOrderID


-- 5. Mostrar la descripción de los productos que nunca hayan sido vendidos


SELECT 
    pd.Description AS DescripcionProducto
FROM Production.Product p
INNER JOIN Production.ProductModel pm 
    ON p.ProductModelID = pm.ProductModelID
INNER JOIN Production.ProductModelProductDescriptionCulture pdpc 
    ON pm.ProductModelID = pdpc.ProductModelID
INNER JOIN Production.ProductDescription pd 
    ON pdpc.ProductDescriptionID = pd.ProductDescriptionID
LEFT JOIN Sales.SalesOrderDetail sod 
    ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL


-- 6. En la tabla SalesPerson se modelan los vendedores. Mostrar el id de todos los vendedores
-- junto al id de la venta, para aquellas con numero de revisión igual a 9 y que se hayan vendido
-- en el 2013. Incluir a aquellos vendedores que no hayan efectuados.

SELECT 
    sp.BusinessEntityID,
    soh.SalesOrderID
FROM Sales.SalesPerson sp
LEFT JOIN Sales.SalesOrderHeader soh
    ON sp.BusinessEntityID = soh.SalesPersonID
    AND soh.RevisionNumber = 9 
    AND YEAR(soh.OrderDate) = 2013

-- 7. Modificar la resolución del punto anterior para agregar el nombre del vendedor, que se
-- encuentra en la tabla Person.

SELECT 
	p.FirstName as Nombre_vendedor,
    sp.BusinessEntityID,
    soh.SalesOrderID
FROM Sales.SalesPerson sp
INNER JOIN Person.Person p
	ON sp.BusinessEntityID = p. BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader soh
    ON sp.BusinessEntityID = soh.SalesPersonID
    AND soh.RevisionNumber = 9 
    AND YEAR(soh.OrderDate) = 2013

-- 8.Mostrar todas los valores de BusinessEntityID de la tabla SalesPerson junto a cada valor
-- ProductID de la tabla Product -> Producto cartesiano

SELECT 
    sp.BusinessEntityID,
    p.ProductID
FROM Sales.SalesPerson sp
CROSS JOIN Production.Product p


-- 9. Calcular para los tipos de contacto, cuántas personas asociadas están registradas. Ordenar el
-- resultado por cantidad, descendente. (esquema Person)

SELECT 
    pct.ContactTypeID AS TipoContacto,
    COUNT(*) AS CantidadPersonas
FROM Person.Person p 
INNER JOIN Person.BusinessEntityContact pbec
    ON p.BusinessEntityID = pbec.BusinessEntityID
INNER JOIN Person.ContactType pct
    ON pbec.ContactTypeID = pct.ContactTypeID 
GROUP BY pct.ContactTypeID
ORDER BY CantidadPersonas DESC

-- La consulta no arroja resultados, reviso las tablas

SELECT TOP 5 * FROM Person.Person
SELECT TOP 5 * FROM Person.BusinessEntityContact
SELECT TOP 5 * FROM Person.ContactType

-- Existen relaciones existentes?

SELECT TOP 10 
    p.BusinessEntityID, 
    pbec.ContactTypeID
FROM Person.Person p
INNER JOIN Person.BusinessEntityContact pbec
    ON p.BusinessEntityID = pbec.BusinessEntityID;

-- La tabla Person.BusinessEntityContact no tiene coincidencias con la tabla Person.Person, al menos no mediante el BusinessEntityID
-- La tabla BusinessEntityContact se usa para vincular contactos con cualquier entidad comercial (puede ser una empresa o persona), 
-- y no todos esos BusinessEntityID necesariamente están en la tabla Person

SELECT 
    pct.Name AS TipoContacto,
    COUNT(*) AS CantidadContactos
FROM Person.BusinessEntityContact bec
INNER JOIN Person.ContactType pct
    ON bec.ContactTypeID = pct.ContactTypeID
GROUP BY pct.Name
ORDER BY CantidadContactos DESC

-- 10. Mostrar nombre y apellido de los empleados del estado de “Oregon” (esquemas Person y
-- HumanResources)

SELECT TOP 5 * FROM Person.Person
SELECT TOP 5 * FROM HumanResources.Employee -- es necesario pasar por la tabla empleados para filtrar cualquier otra persona.
SELECT TOP 5 * FROM Person.BusinessEntityAddress
SELECT TOP 5 * FROM Person.Address
SELECT TOP 5 * FROM Person.StateProvince


SELECT 
    p.FirstName AS Nombre,
    p.LastName AS Apellido
FROM Person.Person p
INNER JOIN HumanResources.Employee e
    ON p.BusinessEntityID = e.BusinessEntityID
INNER JOIN Person.BusinessEntityAddress bea
    ON p.BusinessEntityID = bea.BusinessEntityID
INNER JOIN Person.Address a
    ON bea.AddressID = a.AddressID
INNER JOIN Person.StateProvince sp
    ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.Name = 'Oregon'

-- 11.  Calcular la suma de las ventas (SalesQuota) históricas por persona y año. Mostrar el apellido
-- de la persona. (esquemas Sales (SalesPersonQuotaHistory) y Person)

SELECT TOP 5 * FROM Sales.SalesPersonQuotaHistory
SELECT TOP 5 * FROM Sales.SalesPerson
SELECT TOP 5 * FROM Person.Person
SELECT TOP 5 * FROM HumanResources.Employee 

SELECT 
    p.LastName AS Apellido,
    YEAR(sq.QuotaDate) AS Año,
    SUM(sq.SalesQuota) AS TotalSalesQuota
FROM Sales.SalesPersonQuotaHistory sq
INNER JOIN Sales.SalesPerson sp
    ON sq.BusinessEntityID = sp.BusinessEntityID
INNER JOIN Person.Person p
    ON sp.BusinessEntityID = p.BusinessEntityID
GROUP BY p.LastName, YEAR(sq.QuotaDate)
ORDER BY p.LastName, Año


--12. Calcular el total vendido por territorio, para aquellos que tengan más de 100 ventas a nivel
-- producto. Considerar precio unitario y cantidad vendida. (esquema Sales).

SELECT TOP 5 * FROM Sales.SalesOrderDetail
SELECT TOP 5 * FROM Sales.SalesOrderHeader

SELECT 
    soh.TerritoryID,
    SUM(sod.OrderQty * sod.UnitPrice) AS TotalVendido
FROM Sales.SalesOrderDetail sod
INNER JOIN Sales.SalesOrderHeader soh
    ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY soh.TerritoryID
HAVING COUNT(sod.SalesOrderDetailID) > 100
ORDER BY TotalVendido DESC

--13. Mostrar para cada provincia (id y nombre), la cantidad de domicilios que tenga registrados,
-- sólo para aquellas provincias que tengan más de 1000 domicilios.

SELECT TOP 5 * FROM Person.Address
SELECT TOP 5 * FROM Person.StateProvince

SELECT 
    sp.StateProvinceID,
    sp.Name AS Provincia,
    COUNT(a.AddressID) AS CantidadDomicilios
FROM Person.Address a
INNER JOIN Person.StateProvince sp
    ON a.StateProvinceID = sp.StateProvinceID
GROUP BY sp.StateProvinceID, sp.Name
HAVING COUNT(a.AddressID) > 1000
ORDER BY CantidadDomicilios DESC