/* =====================================================================
   RESPUESTAS de PRACTICA_SQL.sql
   Miralas SOLO despues de intentarlo. Hay muchas formas correctas:
   si tu resultado coincide con el "Esperado", tu solucion tambien vale.
   ===================================================================== */
USE DeltaPractica;
GO

/* ===================== PARTE 1: SELECT ===================== */

-- Tema 1. SELECT + alias
SELECT Codigo, Nombre AS Producto
FROM Productos;

-- Tema 2. ORDER BY
SELECT Nombre, Salario
FROM Empleados
ORDER BY Salario DESC, Nombre ASC;

-- Tema 3. TOP
SELECT TOP (3) Nombre, LimiteCredito
FROM Clientes
ORDER BY LimiteCredito DESC;

-- Tema 4. DISTINCT
SELECT DISTINCT Cargo
FROM Empleados;

-- Tema 5. Columnas calculadas
SELECT Nombre, Salario, Salario * 12 AS SalarioAnual
FROM Empleados;

/* ===================== PARTE 2: WHERE ===================== */

-- Tema 6. Comparaciones (=, <>, >, <, >=, <=)
SELECT Nombre, Salario
FROM Empleados
WHERE Cargo = N'Cajero' AND Salario >= 800;

-- Tema 7. AND / OR con parentesis
SELECT COUNT(*) AS Ventas
FROM Ventas
WHERE (MetodoPago = N'Efectivo' OR MetodoPago = N'Yappy')
  AND Total > 90;
-- Sin parentesis: "Efectivo OR (Yappy AND Total > 90)" -> cuenta TODO el efectivo (2586, mal)

-- Tema 8. IN
SELECT Nombre, Provincia
FROM Estaciones
WHERE Provincia IN (N'Herrera', N'Los Santos', N'Veraguas');

-- Tema 9. BETWEEN
SELECT Nombre, PrecioUnitario
FROM Productos
WHERE PrecioUnitario BETWEEN 1 AND 1.5;

-- Tema 10. LIKE
SELECT Nombre
FROM Productos
WHERE Nombre LIKE N'Di%';

-- Tema 11. IS NULL
SELECT COUNT(*) AS VentasConsumidorFinal
FROM Ventas
WHERE ClienteId IS NULL;

-- Tema 12. Rango de fechas
SELECT COUNT(*) AS VentasPrimeraSemanaNov
FROM Ventas
WHERE Fecha >= '2026-11-01' AND Fecha < '2026-11-08';

/* ===================== PARTE 3: FUNCIONES ===================== */

-- Tema 13. Funciones de texto
SELECT UPPER(Nombre) AS NombreMayus, LEN(Nombre) AS Largo
FROM Estaciones
ORDER BY Largo DESC;

-- Tema 14. Funciones de fecha
SELECT Nombre, FechaIngreso, DATEADD(YEAR, 1, FechaIngreso) AS PrimerAniversario
FROM Empleados
WHERE Cargo = N'Supervisor Regional';

-- Tema 15. ISNULL
SELECT Nombre, ISNULL(Email, 'SIN CORREO') AS Correo
FROM Clientes;

-- Tema 16. CASE
SELECT Nombre, LimiteCredito,
       CASE WHEN LimiteCredito >= 20000 THEN 'Alto'
            WHEN LimiteCredito >= 5000  THEN 'Medio'
            ELSE 'Bajo' END AS Nivel
FROM Clientes
ORDER BY LimiteCredito DESC;

-- Tema 17. CAST
SELECT Id, CAST(Fecha AS DATE) AS Dia, CAST(Total AS INT) AS TotalEntero
FROM Ventas
WHERE Id <= 5;

/* ===================== PARTE 4: AGREGADOS ===================== */

-- Tema 18. COUNT, SUM, AVG, MIN, MAX
SELECT COUNT(*)     AS Empleados,
       SUM(Salario) AS Planilla,
       AVG(Salario) AS Promedio,
       MIN(Salario) AS Minimo,
       MAX(Salario) AS Maximo
FROM Empleados;

-- Tema 19. COUNT(*) vs COUNT(columna)
SELECT COUNT(*)            AS Clientes,
       COUNT(Email)        AS ConCorreo,
       COUNT(*) - COUNT(Email) AS SinCorreo
FROM Clientes;

-- Tema 20. GROUP BY
SELECT Cargo, COUNT(*) AS Cantidad, AVG(Salario) AS SalarioPromedio
FROM Empleados
GROUP BY Cargo
ORDER BY Cantidad DESC;

-- Tema 21. GROUP BY varias columnas
SELECT MONTH(Fecha) AS Mes, MetodoPago, SUM(Total) AS Total
FROM Ventas
WHERE Fecha >= '2026-09-01' AND Fecha < '2026-12-01'
GROUP BY MONTH(Fecha), MetodoPago
ORDER BY Mes, Total DESC;

-- Tema 22. HAVING
SELECT EstacionId, COUNT(*) AS Ventas
FROM Ventas
GROUP BY EstacionId
HAVING COUNT(*) < 400;

-- Tema 23. Duplicados (GROUP BY + HAVING)
SELECT Salario, COUNT(*) AS Empleados
FROM Empleados
GROUP BY Salario
HAVING COUNT(*) > 1
ORDER BY Salario;

/* ===================== PARTE 5: JOINs ===================== */

-- Tema 24. INNER JOIN
SELECT emp.Nombre AS Empleado, e.Nombre AS Estacion
FROM Empleados emp
INNER JOIN Estaciones e ON e.Id = emp.EstacionId
ORDER BY e.Nombre, emp.Nombre;

-- Tema 25. Varios JOINs
SELECT v.Id, e.Nombre AS Estacion, p.Nombre AS Producto, d.Cantidad, d.Subtotal
FROM Ventas v
JOIN Estaciones e   ON e.Id = v.EstacionId
JOIN VentaDetalle d ON d.VentaId = v.Id
JOIN Productos p    ON p.Id = d.ProductoId
WHERE v.Id = 9;

-- Tema 26. JOIN + GROUP BY
SELECT p.Categoria, SUM(d.Subtotal) AS TotalVendido
FROM VentaDetalle d
JOIN Productos p ON p.Id = d.ProductoId
GROUP BY p.Categoria
ORDER BY TotalVendido DESC;

-- Tema 27. LEFT JOIN
SELECT e.Nombre AS Estacion, COUNT(emp.Id) AS Empleados
FROM Estaciones e
LEFT JOIN Empleados emp ON emp.EstacionId = e.Id
GROUP BY e.Nombre
ORDER BY Empleados, e.Nombre;

-- Tema 28. LEFT JOIN + IS NULL ("los que NO tienen")
SELECT e.Nombre
FROM Estaciones e
LEFT JOIN Ventas v ON v.EstacionId = e.Id
WHERE v.Id IS NULL;

-- Tema 29. LA TRAMPA: filtro de la tabla derecha va en el ON
SELECT e.Nombre, COUNT(v.Id) AS VentasNov, ISNULL(SUM(v.Total), 0) AS TotalNov
FROM Estaciones e
LEFT JOIN Ventas v ON v.EstacionId = e.Id
                  AND v.Fecha >= '2026-11-01' AND v.Fecha < '2026-12-01'
GROUP BY e.Nombre
ORDER BY TotalNov DESC;
-- Si pones la fecha en el WHERE, Delta Changuinola desaparece (14 filas en vez de 15).

-- Tema 30. SELF JOIN
SELECT emp.Nombre AS Cajero, jefe.Nombre AS Jefe, jefe.Cargo AS CargoJefe
FROM Empleados emp
JOIN Empleados jefe ON jefe.Id = emp.JefeId
WHERE emp.Cargo = N'Cajero'
ORDER BY jefe.Nombre, emp.Nombre;

/* ===================== PARTE 6: SUBCONSULTAS Y CTE ===================== */

-- Tema 31. Subconsulta escalar
SELECT Nombre, PrecioUnitario
FROM Productos
WHERE PrecioUnitario > (SELECT AVG(PrecioUnitario) FROM Productos);

-- Tema 32. IN con subconsulta
SELECT COUNT(*) AS VentasFlota
FROM Ventas
WHERE ClienteId IN (SELECT Id FROM Clientes WHERE Tipo = N'Flota');

-- Tema 33. EXISTS
SELECT c.Nombre
FROM Clientes c
WHERE c.Tipo = N'Flota'
  AND EXISTS (SELECT 1 FROM Ventas v
              WHERE v.ClienteId = c.Id
                AND v.Fecha >= '2026-11-01' AND v.Fecha < '2026-12-01');

-- Tema 34. CTE (WITH)
WITH TotalCliente AS (
    SELECT ClienteId, SUM(Total) AS TotalComprado
    FROM Ventas
    WHERE ClienteId IS NOT NULL
    GROUP BY ClienteId
)
SELECT c.Nombre, t.TotalComprado
FROM TotalCliente t
JOIN Clientes c ON c.Id = t.ClienteId
WHERE t.TotalComprado > (SELECT AVG(TotalComprado) FROM TotalCliente)
ORDER BY t.TotalComprado DESC;

/* ===================== PARTE 7: FUNCIONES DE VENTANA ===================== */

-- Tema 35. ROW_NUMBER + PARTITION BY
WITH r AS (
    SELECT ClienteId, Id, Fecha, Total,
           ROW_NUMBER() OVER (PARTITION BY ClienteId ORDER BY Fecha DESC) AS rn
    FROM Ventas
    WHERE ClienteId IS NOT NULL
)
SELECT c.Nombre, r.Id AS VentaId, r.Fecha, r.Total
FROM r
JOIN Clientes c ON c.Id = r.ClienteId
WHERE r.rn = 1
ORDER BY r.Fecha DESC;

-- Tema 36. RANK / DENSE_RANK
SELECT Nombre, Salario,
       DENSE_RANK() OVER (ORDER BY Salario DESC) AS Puesto
FROM Empleados
WHERE Cargo = N'Cajero'
ORDER BY Puesto, Nombre;

-- Tema 37. SUM() OVER: porcentaje del total
SELECT e.Provincia,
       SUM(v.Total) AS Total,
       CAST(100.0 * SUM(v.Total) / SUM(SUM(v.Total)) OVER () AS DECIMAL(5,2)) AS Porcentaje
FROM Ventas v
JOIN Estaciones e ON e.Id = v.EstacionId
GROUP BY e.Provincia
ORDER BY Total DESC;

-- Tema 38. LAG
WITH PorMes AS (
    SELECT MONTH(Fecha) AS Mes, COUNT(*) AS Ventas
    FROM Ventas
    WHERE EstacionId = 1 AND Fecha >= '2026-01-01' AND Fecha < '2027-01-01'
    GROUP BY MONTH(Fecha)
)
SELECT Mes, Ventas,
       LAG(Ventas) OVER (ORDER BY Mes)          AS MesAnterior,
       Ventas - LAG(Ventas) OVER (ORDER BY Mes) AS Diferencia
FROM PorMes
ORDER BY Mes;

/* ===================== PARTE 8: UNION, MODIFICAR DATOS, OBJETOS ===================== */

-- Tema 39. UNION ALL
SELECT 'Supervisor' AS Tipo, Nombre FROM Empleados WHERE Cargo = N'Supervisor Regional'
UNION ALL
SELECT 'Cliente contado', Nombre FROM Clientes WHERE Tipo = N'Contado';

-- Tema 40. INSERT / UPDATE / DELETE dentro de una transaccion
BEGIN TRAN;
    INSERT INTO Productos (Codigo, Nombre, Categoria, Unidad, PrecioUnitario)
    VALUES ('TDA-HIELO', N'Bolsa de hielo', N'Tienda', N'Unidad', 2.500);

    UPDATE Productos SET PrecioUnitario = 2.750 WHERE Codigo = 'TDA-HIELO';

    SELECT Codigo, Nombre, PrecioUnitario FROM Productos WHERE Codigo = 'TDA-HIELO';

    DELETE FROM Productos WHERE Codigo = 'TDA-HIELO';
ROLLBACK;
SELECT COUNT(*) AS Productos FROM Productos;   -- 9
GO

-- Tema 41. TRY / CATCH
BEGIN TRY
    BEGIN TRAN;
        INSERT INTO Estaciones (Codigo, Nombre, Provincia, Activa, FechaApertura)
        SELECT TOP (1) Codigo, N'Duplicada', N'Panamá', 1, GETDATE() FROM Estaciones;
    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    SELECT ERROR_NUMBER() AS NumeroError, ERROR_MESSAGE() AS Mensaje;
END CATCH;
GO

-- Tema 42. VISTA
CREATE OR ALTER VIEW vw_VentasPorMetodo AS
SELECT MetodoPago, COUNT(*) AS Cantidad, SUM(Total) AS Total
FROM Ventas
GROUP BY MetodoPago;
GO
SELECT * FROM vw_VentasPorMetodo ORDER BY Total DESC;
GO
DROP VIEW IF EXISTS vw_VentasPorMetodo;
GO

-- Tema 43. STORED PROCEDURE
CREATE OR ALTER PROCEDURE sp_TopProductos
    @Top INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Top <= 0
        THROW 50001, 'El parametro @Top debe ser mayor a 0', 1;

    SELECT TOP (@Top) p.Nombre, SUM(d.Subtotal) AS TotalVendido
    FROM VentaDetalle d
    JOIN Productos p ON p.Id = d.ProductoId
    GROUP BY p.Nombre
    ORDER BY TotalVendido DESC;
END;
GO
EXEC sp_TopProductos @Top = 3;
-- EXEC sp_TopProductos 0;   -- debe dar el error 50001
GO
DROP PROCEDURE IF EXISTS sp_TopProductos;
GO

-- Tema 44. FUNCION ESCALAR
CREATE OR ALTER FUNCTION fn_VentasEstacion (@EstacionId INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM Ventas WHERE EstacionId = @EstacionId);
END;
GO
SELECT Nombre, dbo.fn_VentasEstacion(Id) AS Ventas
FROM Estaciones
ORDER BY Ventas DESC, Nombre;
GO
DROP FUNCTION IF EXISTS fn_VentasEstacion;
GO
