/* =====================================================================
   SOLUCIONES de 02_ejercicios.sql
   Miralas SOLO despues de intentarlo. Hay muchas formas correctas:
   si tu resultado coincide con el esperado, tu solucion tambien vale.
   ===================================================================== */
USE DeltaPractica;
GO

-- ===================== NIVEL 1: BASICO =====================

-- 1
SELECT Nombre, PrecioUnitario
FROM Productos
WHERE Categoria = N'Combustible'
ORDER BY PrecioUnitario DESC;

-- 2
SELECT Nombre, LimiteCredito
FROM Clientes
WHERE Tipo = N'Flota' AND LimiteCredito > 10000
ORDER BY LimiteCredito DESC;

-- 3
SELECT Nombre, Ruc
FROM Clientes
WHERE Email IS NULL;

-- 4
SELECT Nombre, Provincia
FROM Estaciones
WHERE Nombre LIKE N'%Col%';

-- 5
SELECT COUNT(*) AS VentasNoviembre
FROM Ventas
WHERE Fecha >= '2026-11-01' AND Fecha < '2026-12-01';

-- ===================== NIVEL 2: FUNCIONES Y AGREGADOS =====================

-- 6
SELECT Provincia, COUNT(*) AS Estaciones
FROM Estaciones
GROUP BY Provincia
ORDER BY Estaciones DESC, Provincia;

-- 7
SELECT MetodoPago, ROUND(AVG(Total), 2) AS Promedio
FROM Ventas
GROUP BY MetodoPago
ORDER BY Promedio DESC;

-- 8
SELECT Nombre, PrecioUnitario,
       CASE WHEN PrecioUnitario < 2  THEN 'Barato'
            WHEN PrecioUnitario < 15 THEN 'Medio'
            ELSE 'Caro' END AS Rango
FROM Productos
ORDER BY PrecioUnitario;

-- 9
SELECT MONTH(Fecha) AS Mes, COUNT(*) AS Ventas
FROM Ventas
WHERE Fecha >= '2026-01-01' AND Fecha < '2027-01-01'
GROUP BY MONTH(Fecha)
HAVING COUNT(*) > 560
ORDER BY Mes;

-- ===================== NIVEL 3: JOINs =====================

-- 10
SELECT v.Id, v.Fecha, v.Total, e.Nombre AS Estacion, emp.Nombre AS Cajero
FROM Ventas v
JOIN Estaciones e  ON e.Id = v.EstacionId
JOIN Empleados emp ON emp.Id = v.EmpleadoId
WHERE v.Fecha >= '2026-11-15' AND v.Fecha < '2026-11-16'
ORDER BY v.Fecha;

-- 11
SELECT p.Nombre, SUM(d.Cantidad) AS Litros
FROM VentaDetalle d
JOIN Productos p ON p.Id = d.ProductoId
WHERE p.Categoria = N'Combustible'
GROUP BY p.Nombre
ORDER BY Litros DESC;

-- 12
SELECT p.Nombre
FROM Productos p
LEFT JOIN VentaDetalle d ON d.ProductoId = p.Id
WHERE d.Id IS NULL;

-- 13
SELECT jefe.Nombre AS Supervisor, COUNT(emp.Id) AS Cajeros
FROM Empleados jefe
JOIN Empleados emp ON emp.JefeId = jefe.Id
WHERE jefe.Cargo = N'Supervisor Regional'
GROUP BY jefe.Nombre
ORDER BY Cajeros DESC;

-- 14
SELECT c.Nombre, ISNULL(SUM(v.Total), 0) AS Total2026
FROM Clientes c
LEFT JOIN Ventas v ON v.ClienteId = c.Id
                  AND v.Fecha >= '2026-01-01' AND v.Fecha < '2027-01-01'
WHERE c.Tipo = N'Flota'
GROUP BY c.Nombre
ORDER BY Total2026 DESC;

-- ===================== NIVEL 4: SUBCONSULTAS Y CTE =====================

-- 15
SELECT Nombre, Cargo, Salario
FROM Empleados
WHERE Salario > (SELECT AVG(Salario) FROM Empleados)
ORDER BY Salario DESC;

-- 16
WITH Oct AS (
    SELECT EstacionId, SUM(Total) AS TotalOct
    FROM Ventas
    WHERE Fecha >= '2026-10-01' AND Fecha < '2026-11-01'
    GROUP BY EstacionId
)
SELECT e.Nombre, o.TotalOct
FROM Oct o
JOIN Estaciones e ON e.Id = o.EstacionId
WHERE o.TotalOct > (SELECT AVG(TotalOct) FROM Oct)
ORDER BY o.TotalOct DESC;

-- 17
SELECT s.VentaId, v.Fecha, e.Nombre AS Estacion, s.Intentos, s.UltimoError
FROM SincronizacionERP s
JOIN Ventas v     ON v.Id = s.VentaId
JOIN Estaciones e ON e.Id = v.EstacionId
WHERE s.Estado = N'Error'
ORDER BY v.Fecha DESC;

-- ===================== NIVEL 5: FUNCIONES DE VENTANA =====================

-- 18
WITH r AS (
    SELECT e.Provincia, v.Id, v.Total,
           ROW_NUMBER() OVER (PARTITION BY e.Provincia ORDER BY v.Total DESC) AS rn
    FROM Ventas v
    JOIN Estaciones e ON e.Id = v.EstacionId
)
SELECT Provincia, Id AS VentaId, Total, rn AS Puesto
FROM r
WHERE rn <= 3
ORDER BY Provincia, rn;

-- 19
SELECT e.Nombre,
       SUM(v.Total) AS Total2026,
       DENSE_RANK() OVER (ORDER BY SUM(v.Total) DESC) AS Ranking
FROM Ventas v
JOIN Estaciones e ON e.Id = v.EstacionId
WHERE v.Fecha >= '2026-01-01' AND v.Fecha < '2027-01-01'
GROUP BY e.Nombre
ORDER BY Ranking;

-- 20
WITH Mensual AS (
    SELECT MONTH(Fecha) AS Mes, SUM(Total) AS TotalMes
    FROM Ventas
    WHERE Fecha >= '2026-01-01' AND Fecha < '2027-01-01'
    GROUP BY MONTH(Fecha)
)
SELECT Mes, TotalMes,
       SUM(TotalMes) OVER (ORDER BY Mes)            AS Acumulado,
       TotalMes - LAG(TotalMes) OVER (ORDER BY Mes) AS VsMesAnterior
FROM Mensual
ORDER BY Mes;
GO

-- ===================== BONUS: STORED PROCEDURE =====================
CREATE OR ALTER PROCEDURE sp_ResumenCliente
    @ClienteId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Clientes WHERE Id = @ClienteId)
        THROW 50001, 'El cliente no existe', 1;

    SELECT c.Nombre,
           COUNT(v.Id)             AS CantidadCompras,
           ISNULL(SUM(v.Total), 0) AS TotalComprado,
           MAX(v.Fecha)            AS UltimaCompra
    FROM Clientes c
    LEFT JOIN Ventas v ON v.ClienteId = c.Id
    WHERE c.Id = @ClienteId
    GROUP BY c.Nombre;
END;
GO

EXEC sp_ResumenCliente 1;
EXEC sp_ResumenCliente 21;
GO
DROP PROCEDURE IF EXISTS sp_ResumenCliente;
GO
