--1. Ranking de empleados por salario
-- Obtén el ranking de empleados basado en su salario (Rate) dentro de cada departamento (DepartmentID), usando RANK().

SELECT TOP 5 * FROM HumanResources.EmployeePayHistory
SELECT TOP 5 * FROM Person.Person
SELECT TOP 5 * FROM HumanResources.EmployeeDepartmentHistory
SELECT TOP 5 * FROM HumanResources.Department

SELECT 
	p.FirstName,
	p.LastName,
	d.Name,
	RANK () OVER (PARTITION BY edh.DepartmentID ORDER BY eph.rate DESC) AS Ranking_rate,
	eph.rate AS rate
FROM HumanResources.EmployeePayHistory eph
INNER JOIN Person.Person p
	ON p.BusinessEntityID=eph.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory edh
	ON edh.BusinessEntityID= eph.BusinessEntityID
INNER JOIN HumanResources.Department d
	ON d.DepartmentID= edh.DepartmentID

-- RANK le da el mismo lugar si tienen el mismo valor y salta al siguiente rango



-- 2. Orden de ventas por fecha
-- Para cada cliente (CustomerID), muestra sus órdenes (SalesOrderID) y la fecha de la orden, 
-- junto con un número de orden creciente (ROW_NUMBER()) según la fecha de la venta.


SELECT 
	CustomerID AS Cliente,
	SalesOrderID AS ID_venta,
	OrderDate AS Fecha_orden,
	ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS Orden_creciente
FROM Sales.SalesOrderHeader

-- 3. Promedio acumulado de salarios.
-- Para cada empleado, calcula el promedio acumulado (AVG() OVER) de salarios ordenado por la fecha de ingreso (HireDate).

SELECT TOP 5 * FROM HumanResources.EmployeePayHistory
SELECT TOP 5 * FROM Person.Person
SELECT TOP 5 * FROM HumanResources.EmployeeDepartmentHistory
SELECT TOP 5 * FROM HumanResources.Employee

SELECT 
	p.FirstName,
	p.LastName,
	AVG(eph.rate) OVER (PARTITION BY eph.BusinessEntityID) AS Promedio_empleado,
	eph.rate AS rate -- para chequear nomas
FROM HumanResources.EmployeePayHistory eph
INNER JOIN Person.Person p
	ON p.BusinessEntityID=eph.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory edh
	ON edh.BusinessEntityID= eph.BusinessEntityID
INNER JOIN HumanResources.Employee e
	ON e.BusinessEntityID = eph.BusinessEntityID
ORDER BY e.HireDate DESC;


-- 4. Ventas acumuladas por cliente.
--Para cada cliente, muestra cada orden junto con el total acumulado de compras (SubTotal) ordenadas por fecha.

SELECT TOP 5* FROM Sales.SalesOrderHeader

SELECT 
	CustomerID AS Cliente,
	SalesOrderID AS ID_venta,
	OrderDate AS Fecha_orden,
	SUM(SubTotal) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS Total_Acumulado
FROM Sales.SalesOrderHeader


-- 5. Diferencia de salario respecto al anterior.
-- Para cada empleado ordenado por fecha de contratación, muestra la diferencia de su salario respecto al empleado anterior.


WITH empleados_sueldo AS
(
SELECT
	p.FirstName As Nombre,
	p.LastName AS Apellido,
	SUM(eph.rate) OVER (PARTITION BY eph.BusinessEntityID) AS Sueldo,
	e.HireDate AS fecha_contratacion
FROM HumanResources.EmployeePayHistory eph
INNER JOIN Person.Person p
	ON p.BusinessEntityID=eph.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory edh
	ON edh.BusinessEntityID= eph.BusinessEntityID
INNER JOIN HumanResources.Employee e
	ON e.BusinessEntityID = eph.BusinessEntityID
)
SELECT 
    Nombre,
    Apellido,
    Sueldo,
    fecha_contratacion,
    LAG(Sueldo) OVER (
        ORDER BY fecha_contratacion
    ) AS Sueldo_Anterior
FROM empleados_sueldo;

-- aca me quedan repetidos los empleados, tengo que sacar los empleados que hayan cobrado mas de una vez y quedarme con el ultimo? Puede ser una opcion

WITH sueldo_final AS (
    SELECT 
        eph.BusinessEntityID,
        eph.Rate AS Sueldo,
        ROW_NUMBER() OVER (
		PARTITION BY eph.BusinessEntityID 
		ORDER BY eph.RateChangeDate DESC) AS rn
    FROM HumanResources.EmployeePayHistory eph
),
empleados_unicos AS (
    SELECT 
        e.BusinessEntityID,
        p.FirstName AS Nombre,
        p.LastName AS Apellido,
        e.HireDate,
        s.Sueldo
    FROM HumanResources.Employee e
    INNER JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
    INNER JOIN sueldo_final s ON s.BusinessEntityID = e.BusinessEntityID
    WHERE s.rn = 1 -- último sueldo
)
SELECT 
    Nombre,
    Apellido,
    Sueldo,
    HireDate AS fecha_contratacion,
    LAG(Sueldo) OVER (ORDER BY HireDate) AS Sueldo_Anterior
FROM empleados_unicos;


-- 6. Salario máximo y mínimo por departamento.
-- Muestra el salario actual de cada empleado, el salario máximo y el mínimo dentro de su departamento.

SELECT TOP 5 * FROM HumanResources.EmployeePayHistory
SELECT TOP 5 * FROM Person.Person
SELECT TOP 5 * FROM HumanResources.EmployeeDepartmentHistory

-- Primero tengo que obtener la fila de salario más reciente de cada empleado

WITH SalarioActual AS (
    SELECT
        eph.BusinessEntityID,
        eph.Rate AS SalarioActual,
		eph.RateChangeDate,
        ROW_NUMBER() OVER (PARTITION BY eph.BusinessEntityID ORDER BY eph.RateChangeDate DESC) AS rn
    FROM HumanResources.EmployeePayHistory eph
)
-- Despues calcular el min y max por departamento
SELECT
    p.FirstName AS Nombre,
    p.LastName AS Apellido,
    edh.DepartmentID AS Departamento,
    sa.SalarioActual,
	MIN(sa.SalarioActual) OVER (PARTITION BY edh.DepartmentID) AS SalarioMinimo,
    MAX(sa.SalarioActual) OVER (PARTITION BY edh.DepartmentID) AS SalarioMaximo
FROM SalarioActual AS sa
INNER JOIN Person.Person p
    ON p.BusinessEntityID = sa.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory edh
    ON edh.BusinessEntityID = sa.BusinessEntityID
WHERE sa.rn = 1;
	

-- 7. Identificar empleados con salario mayor al promedio del departamento.
-- Lista los empleados cuyo salario (Rate) es mayor al promedio de su departamento usando AVG() OVER (PARTITION BY ...).

WITH SalarioActual AS (
    SELECT
        eph.BusinessEntityID,
        eph.Rate AS SalarioActual,
		eph.RateChangeDate,
        ROW_NUMBER() OVER (PARTITION BY eph.BusinessEntityID ORDER BY eph.RateChangeDate DESC) AS rn
    FROM HumanResources.EmployeePayHistory eph
)
, Promedio_departamento AS(
SELECT
    p.FirstName AS Nombre,
    p.LastName AS Apellido,
    edh.DepartmentID AS Departamento,
    sa.SalarioActual AS Salario_actual,
	AVG(sa.SalarioActual) OVER (PARTITION BY edh.DepartmentID) AS Promedio_departamento
FROM SalarioActual AS sa
INNER JOIN Person.Person p
    ON p.BusinessEntityID = sa.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory edh
    ON edh.BusinessEntityID = sa.BusinessEntityID
WHERE sa.rn = 1
)
SELECT * FROM Promedio_departamento
WHERE Salario_actual > Promedio_departamento

-- 8. Duración entre órdenes consecutivas.
-- Para cada cliente, calcula cuántos días pasaron entre cada orden y la anterior (LAG() o LEAD()).

SELECT 
	CustomerID AS Cliente,
	OrderDate As Compra_actual,
	LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate DESC) AS Compra_anterior
FROM Sales.SalesOrderHeader


SELECT 
    CustomerID AS Cliente,
    OrderDate AS Compra_actual,
    LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC) AS Compra_anterior,
    DATEDIFF(DAY, LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC), OrderDate) AS Diferencia_dias
FROM Sales.SalesOrderHeader;


-- 9. Top 3 productos más vendidos por categoría.
-- Obtén los tres productos más vendidos (por cantidad) en cada categoría de producto usando DENSE_RANK().

SELECT top 5 * FROM Sales.SalesOrderDetail
SELECT top 5 * FROM Production.Product
SELECT top 5 * FROM Production.ProductSubCategory
SELECT top 5 * FROM Production.ProductCategory

-- armo CTE con resumen de los productos vendidos, categoria, nombre y calculo la cantidad vendida de cada producto
WITH cantidad_prod AS (
SELECT 
	pc.ProductCategoryID,
    pc.Name AS Nombre_Categoria,
    p.ProductID,
    p.Name AS Nombre_producto,
    SUM(sod.OrderQty) AS Total_cantidad
from Sales.SalesOrderDetail sod
INNER JOIN Production.Product p
	ON p.ProductID=sod.ProductID
INNER JOIN Production.ProductSubCategory psc
	ON psc.ProductSubcategoryID=p.ProductSubcategoryID
INNER JOIN Production.ProductCategory pc
	ON pc.ProductCategoryID=psc.ProductcategoryID
GROUP BY pc.ProductCategoryID, pc.Name, p.ProductID, p.Name
)
,-- armo el dense_rank, no saltea rango cuando hay empates.
Productos_Rank AS (
    SELECT 
        *,
        DENSE_RANK() OVER (PARTITION BY ProductCategoryID ORDER BY Total_cantidad DESC) AS Ranking_categoria
    FROM cantidad_prod
)
-- Me quedo con los primeros 3
SELECT 
    ProductCategoryID,
    Nombre_Categoria,
    ProductID,
    Nombre_producto,
    Total_cantidad,
    Ranking_categoria
FROM Productos_Rank
WHERE Ranking_categoria <= 3
ORDER BY ProductCategoryID, Ranking_categoria


-- 10. Detección de cambios de tarifa.
-- Para cada empleado, detecta cuándo cambió su tarifa (Rate) respecto a la anterior usando LAG().

SELECT * FROM HumanResources.Employee
SELECT * FROM HumanResources.EmployeePayHistory

WITH Aumentos AS (
SELECT 
	BusinessEntityID AS Empleado,
	LAG(RateChangeDate) OVER (PARTITION BY BusinessEntityID ORDER BY rate) AS Cambio_tarifa
FROM HumanResources.EmployeePayHistory
)
SELECT * FROM Aumentos
WHERE Cambio_tarifa IS NOT NULL

-- Nivel 1: LAG basico 
-- Para cada producto en la tabla Production.Product, muestra el nombre del producto, su precio actual (ListPrice) 
-- y el precio del producto anterior (ordenado por ProductID). Solo productos con precio > 0.

select top 5 * from Production.Product

SELECT 
    ProductID,
    Name,
    ListPrice AS PrecioActual,
    LAG(ListPrice) OVER (ORDER BY ProductID) AS PrecioAnterior
FROM Production.Product
WHERE ListPrice > 0
ORDER BY ProductID

-- Nivel 2: LAG con cálculos
-- Extiende la consulta anterior para calcular la diferencia de precio entre el producto actual y el anterior. 
-- Identifica si el precio subió, bajó o se mantuvo igual.

SELECT 
    ProductID,
    Name,
    ListPrice AS PrecioActual,
    LAG(ListPrice) OVER (ORDER BY ProductID) AS PrecioAnterior,
	ListPrice / NULLIF(LAG(ListPrice) OVER (ORDER BY ProductID), 0) as Diferencias,
	CASE
		WHEN ListPrice / NULLIF(LAG(ListPrice) OVER (ORDER BY ProductID), 0) > 1 THEN 'Subio'
		WHEN ListPrice / NULLIF(LAG(ListPrice) OVER (ORDER BY ProductID), 0) < 1 THEN 'Bajo'
		ELSE 'No hubo cambio'
	END as Estado
FROM Production.Product
WHERE ListPrice > 0
ORDER BY ProductID

-- Nivel 3: LAG con PARTITION
-- "Ahora agrupa por subcategoría (ProductSubcategoryID). 
-- Para cada subcategoría, muestra cómo cambian los precios entre productos consecutivos dentro de esa subcategoría."

with prod_ventas as (
SELECT 
    ProductID,
    Name,
    ListPrice AS PrecioActual,
    LAG(ListPrice) OVER (PARTITION BY ProductSubcategoryID ORDER BY ProductID ) AS PrecioAnterior,
	ListPrice / NULLIF(LAG(ListPrice) OVER (PARTITION BY ProductSubcategoryID ORDER BY ProductID), 0) as Diferencias
FROM Production.Product
WHERE ListPrice > 0
)
Select 
	ProductID,
	Name,
	PrecioActual,
	PrecioAnterior,
	Case 
		WHEN Diferencias >1 THEN 'Subio'
		WHEN Diferencias <1 THEN 'Bajo'
	ELSE 'igual'
	END as cambio
FROM prod_ventas

-- Nivel 4: LAG + LEAD juntos
-- "Para cada producto, muestra el precio anterior, actual y siguiente dentro de su subcategoría. 
-- Identifica los productos que son 'picos' (más caros que el anterior Y el siguiente)."

SELECT 
    ProductID,
    Name,
    ProductSubcategoryID,
    LAG(ListPrice) OVER (PARTITION BY ProductSubcategoryID ORDER BY ProductID) AS PrecioAnterior,
    ListPrice AS PrecioActual,
    LEAD(ListPrice) OVER (PARTITION BY ProductSubcategoryID ORDER BY ProductID) AS PrecioSiguiente,
    CASE 
        WHEN ListPrice > LAG(ListPrice) OVER (PARTITION BY ProductSubcategoryID ORDER BY ProductID)
         AND ListPrice > LEAD(ListPrice) OVER (PARTITION BY ProductSubcategoryID ORDER BY ProductID)
        THEN 'Es un pico'
        ELSE 'No es pico'
    END AS EsPico
FROM Production.Product
WHERE ListPrice > 0 
  AND ProductSubcategoryID IS NOT NULL
ORDER BY ProductSubcategoryID, ProductID;