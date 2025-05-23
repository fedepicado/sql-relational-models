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
	RANK () OVER (
	PARTITION BY edh.DepartmentID
	ORDER BY eph.rate DESC) AS Ranking_rate,
	eph.rate AS rate
FROM HumanResources.EmployeePayHistory eph
INNER JOIN Person.Person p
	ON p.BusinessEntityID=eph.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory edh
	ON edh.BusinessEntityID= eph.BusinessEntityID
INNER JOIN HumanResources.Department d
	ON d.DepartmentID= edh.DepartmentID

-- RANK le da el mismo lugar si tienen el mismo valor. 


-- 2. Orden de ventas por fecha
-- Para cada cliente (CustomerID), muestra sus órdenes (SalesOrderID) y la fecha de la orden, 
-- junto con un número de orden creciente (ROW_NUMBER()) según la fecha de la venta.


SELECT 
	CustomerID AS Cliente,
	SalesOrderID AS ID_venta,
	OrderDate AS Fecha_orden,
	ROW_NUMBER() OVER (
	PARTITION BY CustomerID
	ORDER BY OrderDate
	) AS Orden_creciente
FROM Sales.SalesOrderHeader

-- 3. Promedio acumulado de salarios.
-- Para cada empleado, calcula el promedio acumulado (AVG() OVER) de salarios ordenado por la fecha de ingreso (HireDate).

SELECT TOP 5 * FROM Sales.SalesOrderDetail

SELECT TOP 5 * FROM Sales.SalesOrderHeader



-- 4. Ventas acumuladas por cliente.
--Para cada cliente, muestra cada orden junto con el total acumulado de compras (SubTotal) ordenadas por fecha.

-- 5. Diferencia de salario respecto al anterior.
-- Para cada empleado ordenado por fecha de contratación, muestra la diferencia de su salario respecto al empleado anterior.

-- 6. Salario máximo y mínimo por departamento.
-- Muestra el salario actual de cada empleado, el salario máximo y el mínimo dentro de su departamento.

-- 7. Identificar empleados con salario mayor al promedio del departamento.
-- Lista los empleados cuyo salario (Rate) es mayor al promedio de su departamento usando AVG() OVER (PARTITION BY ...).


-- 8. Duración entre órdenes consecutivas.
-- Para cada cliente, calcula cuántos días pasaron entre cada orden y la anterior (LAG() o LEAD()).
-- 9. Top 3 productos más vendidos por categoría.
-- Obtén los tres productos más vendidos (por cantidad) en cada categoría de producto usando DENSE_RANK().


-- 10. Detección de cambios de tarifa.
-- Para cada empleado, detecta cuándo cambió su tarifa (Rate) respecto a la anterior usando LAG().