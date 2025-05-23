-- clase 21/5/2025 -- Federico Picado

-- Ejercicio 1 – Pedidos recientes
-- • Mostrar los 10 pedidos más recientes realizados en la tabla Sales.SalesOrderHeader.
-- Incluir la fecha del pedido (OrderDate) y el ID del cliente (CustomerID).
SELECT TOP 2 * FROM Sales.SalesOrderHeader

SELECT TOP 10
    OrderDate AS Fecha_pedido,
    CustomerID AS Cliente
FROM Sales.SalesOrderHeader
ORDER BY OrderDate DESC;

-- Ejercicio 2 – Tiempo entre pedido y envío
-- • Calcular cuántos días pasaron entre la fecha del pedido (OrderDate) y la fecha de envío (ShipDate).
-- Mostrar solo los pedidos donde la diferencia fue mayor a 5 días.

SELECT 
	SalesOrderID,
	DATEDIFF(day, OrderDate, ShipDate ) AS Diferencia_mayor_5
FROM Sales.SalesOrderHeader
WHERE DATEDIFF(day, OrderDate, ShipDate ) > 5;

-- Ejercicio 3 – Agrupar pedidos por mes (año 2013)
-- • Contar cuántos pedidos se hicieron por mes durante el año 2013. Mostrar número y nombre
-- del mes, y total de pedidos.SELECT 	MONTH(OrderDate) AS NumeroMes,
    DATENAME(MONTH, OrderDate) AS NombreMes,	COUNT(SalesOrderID) AS Cantidad_pedidosFROM Sales.SalesOrderHeaderWHERE YEAR(OrderDate)=2013GROUP BY MONTH(OrderDate), DATENAME(MONTH, OrderDate)ORDER BY MONTH(OrderDate);-- Ejercicio 4 – Antigüedad de empleados
-- • Mostrar una lista de empleados con su fecha de contratación (HireDate) y cuántos años
-- llevan trabajando. Ordenar por antigüedad descendente.SELECT TOP 2 * FROM HumanResources.EmployeeSELECT TOP 2 * FROM Person.PersonSELECT 	p.FirstName As Nombre,	p.LastName As Apellido,	DATEDIFF(year, e.HireDate, e.ModifiedDate) AS Años_trabajadosFROM HumanResources.Employee as e	INNER JOIN Person.Person p	ON p.BusinessEntityID=e.BusinessEntityIDORDER BY DATEDIFF(year, e.HireDate, e.ModifiedDate) DESC;-- A la fecha actualSELECT 	p.FirstName As Nombre,	p.LastName As Apellido,	DATEDIFF(year, e.HireDate, GETDATE()) AS Años_trabajadosFROM HumanResources.Employee as e	INNER JOIN Person.Person p	ON p.BusinessEntityID=e.BusinessEntityIDORDER BY Años_trabajados DESC;