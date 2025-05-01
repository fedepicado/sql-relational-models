-- 1. La tabla Employee no contiene el nombre de los empleados. Ese dato se encuentra en la tabla 
--Person. La columna que relaciona ambas tablas es BusinessEntityID
-- a) Si existe una FK entre ambas tablas, cómo podemos corroborar su existencia?

-- RTA: Consultar el modelo de datos ya que la existencia de una FK es una restricción  definida a nivel estructural.
-- Una FK asegura la integridad referencial entre dos tablas, indicando que una columna en una tabla (como BusinessEntityID en Employee)
-- debe coincidir con una clave primaria en otra tabla.


SELECT p.BusinessEntityID, p.FirstName as Nombre 
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
WHERE YEAR(soh.OrderDate) = 2011 AND MONTH(soh.OrderDate) IN (6, 7);



