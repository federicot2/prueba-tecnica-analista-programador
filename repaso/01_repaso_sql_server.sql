/* =====================================================================
   REPASO DE SQL SERVER - De lo basico a consultas de prueba tecnica
   Base de datos: DeltaPractica (localhost\SQLEXPRESS)

   COMO USAR ESTE ARCHIVO EN SSMS:
   - Abre el archivo (File > Open > File) o copialo en una New Query.
   - NO lo ejecutes todo de una. Selecciona con el mouse UN ejemplo
     y presiona F5: se ejecuta solo lo seleccionado.
   - Lee el comentario, adivina el resultado, ejecuta y compara.
   - Modifica los ejemplos: cambia filtros, columnas, ordenes. Asi se aprende.
   - Tranquilo: este archivo NO cambia tus datos (los INSERT/UPDATE/DELETE
     van dentro de una transaccion que se deshace con ROLLBACK).

   TABLAS:
   Estaciones(Id, Codigo, Nombre, Provincia, Activa, FechaApertura)
   Productos(Id, Codigo, Nombre, Categoria, Unidad, PrecioUnitario)
   Clientes(Id, Nombre, Ruc, Email, Tipo, LimiteCredito, FechaRegistro)
   Empleados(Id, Nombre, Cargo, EstacionId, JefeId, Salario, FechaIngreso)
   Ventas(Id, EstacionId, ClienteId, EmpleadoId, Fecha, Total, MetodoPago, ReferenciaExterna)
   VentaDetalle(Id, VentaId, ProductoId, Cantidad, PrecioUnitario, Subtotal)
   SincronizacionERP(Id, VentaId, Estado, Intentos, UltimoError, FechaCreacion, FechaEnvio)
   ===================================================================== */
USE DeltaPractica;
GO


/* =====================================================================
   LECCION 1: SELECT - leer datos
   ===================================================================== */

-- 1.1 Todas las columnas de una tabla (* = todas)
SELECT * FROM Estaciones;

-- 1.2 Solo algunas columnas (en una prueba real, evita SELECT *: trae solo lo que necesitas)
SELECT Nombre, Provincia FROM Estaciones;

-- 1.3 Alias: renombrar columnas (AS) y tablas (la "e")
SELECT e.Nombre AS Estacion, e.Provincia AS Provincia
FROM Estaciones AS e;

-- 1.4 ORDER BY: ordenar. ASC = ascendente (por defecto), DESC = descendente
SELECT Nombre, PrecioUnitario
FROM Productos
ORDER BY PrecioUnitario DESC;

-- 1.5 Ordenar por varias columnas: primero provincia, y dentro de cada provincia por nombre
SELECT Provincia, Nombre
FROM Estaciones
ORDER BY Provincia, Nombre;

-- 1.6 TOP: solo las primeras N filas (siempre con ORDER BY, si no el "top" es al azar)
SELECT TOP (5) Id, Fecha, Total
FROM Ventas
ORDER BY Total DESC;        -- las 5 ventas mas grandes

-- 1.7 DISTINCT: valores sin repetir
SELECT DISTINCT Provincia FROM Estaciones;
SELECT DISTINCT MetodoPago FROM Ventas;

-- 1.8 Columnas calculadas
SELECT Nombre,
       PrecioUnitario,
       PrecioUnitario * 1.07 AS PrecioConITBMS   -- ITBMS (impuesto) 7% en Panama
FROM Productos;


/* =====================================================================
   LECCION 2: WHERE - filtrar filas
   ===================================================================== */

-- 2.1 Igualdad y desigualdad (=, <>, >, <, >=, <=)
SELECT * FROM Estaciones WHERE Provincia = N'Panamá';
SELECT * FROM Estaciones WHERE Provincia <> N'Panamá';
SELECT * FROM Productos  WHERE PrecioUnitario > 5;

-- 2.2 AND / OR (usa parentesis cuando mezcles, para no equivocarte)
SELECT * FROM Productos
WHERE Categoria = N'Lubricante' AND PrecioUnitario < 15;

SELECT * FROM Estaciones
WHERE Activa = 1 AND (Provincia = N'Colón' OR Provincia = N'Chiriquí');

-- 2.3 IN: igual a cualquiera de una lista (mas limpio que muchos OR)
SELECT * FROM Estaciones
WHERE Provincia IN (N'Colón', N'Chiriquí', N'Coclé');

-- 2.4 BETWEEN: rango INCLUSIVO en ambos extremos
SELECT * FROM Productos WHERE PrecioUnitario BETWEEN 1 AND 2;

-- 2.5 LIKE: buscar texto.  % = cualquier cantidad de caracteres,  _ = exactamente uno
SELECT * FROM Clientes WHERE Nombre LIKE N'Trans%';     -- empieza con "Trans"
SELECT * FROM Clientes WHERE Email  LIKE '%.pa';        -- termina con ".pa"
SELECT * FROM Clientes WHERE Nombre LIKE N'%Express%';  -- contiene "Express"

-- 2.6 NULL: se compara con IS NULL / IS NOT NULL. NUNCA con = NULL (siempre da vacio)
SELECT * FROM Clientes WHERE Email IS NULL;
SELECT * FROM Clientes WHERE Email = NULL;   -- ERROR LOGICO: devuelve 0 filas. Pruebalo.

-- 2.7 FECHAS: usa rangos >= y < (asi SQL puede usar indices y no pierdes las horas del ultimo dia)
SELECT COUNT(*) AS VentasOctubre
FROM Ventas
WHERE Fecha >= '2026-10-01' AND Fecha < '2026-11-01';

-- Por que no BETWEEN '2026-10-01' AND '2026-10-31'? Porque Fecha tiene hora:
-- una venta del 31-oct a las 15:00 es MAYOR que '2026-10-31 00:00' y quedaria fuera.
SELECT COUNT(*) AS ConBetween_PierdeVentas
FROM Ventas
WHERE Fecha BETWEEN '2026-10-01' AND '2026-10-31';


/* =====================================================================
   LECCION 3: FUNCIONES UTILES
   ===================================================================== */

-- 3.1 Texto
SELECT Nombre,
       UPPER(Nombre)               AS Mayusculas,
       LEN(Nombre)                 AS Largo,
       LEFT(Codigo, 3)             AS Prefijo,
       CONCAT(Codigo, ' - ', Nombre) AS CodigoNombre,
       REPLACE(Nombre, N'Delta ', N'') AS SinMarca
FROM Estaciones;

-- 3.2 Fechas
SELECT GETDATE()                              AS Ahora,
       YEAR(GETDATE())                        AS Anio,
       MONTH(GETDATE())                       AS Mes,
       DATEADD(DAY, 30, GETDATE())            AS En30Dias,
       DATEDIFF(DAY, '2026-01-01', GETDATE()) AS DiasDesdeInicioDeAnio,
       FORMAT(GETDATE(), 'dd/MM/yyyy')        AS Formateada,
       CAST(GETDATE() AS DATE)                AS SoloFecha;

-- Antiguedad de cada empleado en anios
SELECT Nombre, FechaIngreso,
       DATEDIFF(YEAR, FechaIngreso, GETDATE()) AS AniosEnLaEmpresa
FROM Empleados
ORDER BY FechaIngreso;

-- 3.3 Numeros
SELECT Total,
       ROUND(Total, 0)   AS Redondeado,
       CEILING(Total)    AS HaciaArriba,
       FLOOR(Total)      AS HaciaAbajo
FROM Ventas
WHERE Id <= 5;

-- 3.4 ISNULL / COALESCE: reemplazar NULL por otro valor
SELECT Nombre,
       ISNULL(Email, 'sin correo')        AS Email1,
       COALESCE(Email, Ruc, 'nada')       AS Email2  -- COALESCE toma el primer valor no NULL
FROM Clientes;

-- 3.5 CASE: el "if" de SQL
SELECT Id, Total,
       CASE
           WHEN Total >= 100 THEN 'Grande'
           WHEN Total >= 40  THEN 'Mediana'
           ELSE 'Pequena'
       END AS TipoVenta
FROM Ventas
WHERE Id <= 20;

-- 3.6 CAST / CONVERT: cambiar tipo de dato
SELECT CAST(Total AS INT)                AS TotalEntero,
       CAST(Id AS VARCHAR(10)) + ' venta' AS Texto,
       CONVERT(VARCHAR(10), Fecha, 103)  AS FechaDDMMYYYY
FROM Ventas
WHERE Id <= 5;


/* =====================================================================
   LECCION 4: AGREGACIONES - COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING
   ===================================================================== */

-- 4.1 Agregados sobre toda la tabla (devuelven UNA fila)
SELECT COUNT(*)   AS CantidadVentas,
       SUM(Total) AS TotalVendido,
       AVG(Total) AS Promedio,
       MIN(Total) AS VentaMinima,
       MAX(Total) AS VentaMaxima
FROM Ventas;

-- 4.2 COUNT(*) vs COUNT(columna): COUNT(columna) NO cuenta los NULL
SELECT COUNT(*)          AS TodasLasVentas,
       COUNT(ClienteId)  AS VentasConCliente,      -- ignora las de consumidor final (NULL)
       COUNT(DISTINCT ClienteId) AS ClientesDistintos
FROM Ventas;

-- 4.3 GROUP BY: un resultado POR GRUPO
SELECT MetodoPago, COUNT(*) AS Cantidad, SUM(Total) AS Total
FROM Ventas
GROUP BY MetodoPago
ORDER BY Total DESC;

-- REGLA: toda columna del SELECT que NO este dentro de un agregado (SUM, COUNT...)
-- debe estar en el GROUP BY. Esto da ERROR (pruebalo):
-- SELECT MetodoPago, Fecha, COUNT(*) FROM Ventas GROUP BY MetodoPago;

-- 4.4 Agrupar por varias columnas
SELECT YEAR(Fecha) AS Anio, MONTH(Fecha) AS Mes, SUM(Total) AS Total
FROM Ventas
GROUP BY YEAR(Fecha), MONTH(Fecha)
ORDER BY Anio, Mes;

-- 4.5 HAVING: filtra GRUPOS (despues de agrupar). WHERE filtra FILAS (antes de agrupar)
-- Metodos de pago con mas de 1,500 ventas:
SELECT MetodoPago, COUNT(*) AS Cantidad
FROM Ventas
GROUP BY MetodoPago
HAVING COUNT(*) > 1500;

-- WHERE y HAVING juntos: solo ventas de 2026-10 (WHERE), metodos con total > 7000 (HAVING)
SELECT MetodoPago, SUM(Total) AS Total
FROM Ventas
WHERE Fecha >= '2026-10-01' AND Fecha < '2026-11-01'
GROUP BY MetodoPago
HAVING SUM(Total) > 7000;

-- 4.6 Clasico: encontrar DUPLICADOS
SELECT Email, COUNT(*) AS Veces
FROM Clientes
WHERE Email IS NOT NULL
GROUP BY Email
HAVING COUNT(*) > 1;

/* ORDEN EN QUE SQL EJECUTA UNA CONSULTA (memorizalo, lo preguntan):
   1. FROM / JOIN   2. WHERE   3. GROUP BY   4. HAVING   5. SELECT   6. ORDER BY
   Por eso un alias creado en el SELECT se puede usar en ORDER BY pero NO en WHERE. */


/* =====================================================================
   LECCION 5: JOINs - combinar tablas
   ===================================================================== */

-- 5.1 INNER JOIN: solo filas que tienen pareja en AMBAS tablas
SELECT v.Id, v.Fecha, v.Total, e.Nombre AS Estacion
FROM Ventas v
INNER JOIN Estaciones e ON e.Id = v.EstacionId
WHERE v.Id <= 10;

-- 5.2 Varios JOINs encadenados: venta -> detalle -> producto
SELECT v.Id AS VentaId, v.Fecha, p.Nombre AS Producto, d.Cantidad, d.Subtotal
FROM Ventas v
JOIN VentaDetalle d ON d.VentaId = v.Id          -- JOIN solo = INNER JOIN
JOIN Productos p    ON p.Id = d.ProductoId
WHERE v.Id <= 10
ORDER BY v.Id;

-- 5.3 JOIN + GROUP BY: total vendido por provincia
SELECT e.Provincia, SUM(v.Total) AS Total
FROM Ventas v
JOIN Estaciones e ON e.Id = v.EstacionId
GROUP BY e.Provincia
ORDER BY Total DESC;

-- 5.4 LEFT JOIN: TODAS las filas de la izquierda, tengan o no pareja. Sin pareja = NULL
SELECT c.Nombre, v.Id AS VentaId
FROM Clientes c
LEFT JOIN Ventas v ON v.ClienteId = c.Id
WHERE c.Id IN (1, 21, 22);    -- el 21 y 22 nunca compraron: VentaId sale NULL

-- 5.5 Patron "los que NO tienen": LEFT JOIN + IS NULL
SELECT c.Nombre
FROM Clientes c
LEFT JOIN Ventas v ON v.ClienteId = c.Id
WHERE v.Id IS NULL;

-- 5.6 LA TRAMPA: filtro de la tabla DERECHA en WHERE vs en ON
-- MAL: la fecha en WHERE elimina las filas NULL -> el LEFT JOIN se vuelve INNER JOIN (13 filas)
SELECT e.Nombre, ISNULL(SUM(v.Total), 0) AS TotalOct
FROM Estaciones e
LEFT JOIN Ventas v ON v.EstacionId = e.Id
WHERE e.Activa = 1
  AND v.Fecha >= '2026-10-01' AND v.Fecha < '2026-11-01'
GROUP BY e.Nombre;

-- BIEN: la fecha en el ON -> aparecen todas, Las Tablas con 0 (14 filas)
SELECT e.Nombre, ISNULL(SUM(v.Total), 0) AS TotalOct
FROM Estaciones e
LEFT JOIN Ventas v ON v.EstacionId = e.Id
                  AND v.Fecha >= '2026-10-01' AND v.Fecha < '2026-11-01'
WHERE e.Activa = 1
GROUP BY e.Nombre;
-- REGLA: en LEFT JOIN, filtros de la tabla derecha -> ON. De la izquierda -> WHERE.

-- 5.7 SELF JOIN: una tabla unida consigo misma (empleado y su jefe)
-- LEFT para que el gerente (sin jefe) tambien aparezca
SELECT emp.Nombre AS Empleado, emp.Cargo, jefe.Nombre AS Jefe
FROM Empleados emp
LEFT JOIN Empleados jefe ON jefe.Id = emp.JefeId
ORDER BY emp.Id;

/* Otros JOINs que conviene saber definir:
   RIGHT JOIN = como LEFT pero al reves (casi no se usa, se reescribe como LEFT).
   FULL JOIN  = todo de ambos lados, NULL donde no hay pareja.
   CROSS JOIN = todas las combinaciones (producto cartesiano). */


/* =====================================================================
   LECCION 6: SUBCONSULTAS
   ===================================================================== */

-- 6.1 Subconsulta escalar (devuelve UN valor): ventas mayores al promedio
SELECT Id, Total
FROM Ventas
WHERE Total > (SELECT AVG(Total) FROM Ventas)
ORDER BY Total;

-- 6.2 IN con subconsulta: ventas de estaciones de Chiriqui
SELECT COUNT(*) AS VentasChiriqui
FROM Ventas
WHERE EstacionId IN (SELECT Id FROM Estaciones WHERE Provincia = N'Chiriquí');

-- 6.3 EXISTS / NOT EXISTS: "existe al menos una fila que cumpla"
-- Estaciones activas sin ventas en octubre (otra forma, muy usada)
SELECT e.Nombre
FROM Estaciones e
WHERE e.Activa = 1
  AND NOT EXISTS (SELECT 1 FROM Ventas v
                  WHERE v.EstacionId = e.Id
                    AND v.Fecha >= '2026-10-01' AND v.Fecha < '2026-11-01');

-- 6.4 Subconsulta en el FROM (tabla derivada): promedio de ventas por estacion
SELECT AVG(t.TotalEstacion) AS PromedioPorEstacion
FROM (SELECT EstacionId, SUM(Total) AS TotalEstacion
      FROM Ventas GROUP BY EstacionId) AS t;

-- 6.5 Segundo salario mas alto (pregunta clasica)
SELECT MAX(Salario) AS SegundoMasAlto
FROM Empleados
WHERE Salario < (SELECT MAX(Salario) FROM Empleados);


/* =====================================================================
   LECCION 7: CTE (WITH) - subconsultas con nombre, mas legibles
   ===================================================================== */

-- 7.1 Misma idea que 6.4 pero legible
WITH TotalesPorEstacion AS (
    SELECT EstacionId, SUM(Total) AS TotalEstacion
    FROM Ventas
    GROUP BY EstacionId
)
SELECT e.Nombre, t.TotalEstacion
FROM TotalesPorEstacion t
JOIN Estaciones e ON e.Id = t.EstacionId
WHERE t.TotalEstacion > (SELECT AVG(TotalEstacion) FROM TotalesPorEstacion)
ORDER BY t.TotalEstacion DESC;
-- OJO: el CTE vive solo durante la consulta que va justo despues del WITH.

-- 7.2 CTE recursivo: la cadena de mando de un cajero hasta el gerente
WITH Cadena AS (
    SELECT Id, Nombre, Cargo, JefeId, 0 AS Nivel
    FROM Empleados WHERE Id = 10                       -- empezamos en un cajero
    UNION ALL
    SELECT j.Id, j.Nombre, j.Cargo, j.JefeId, c.Nivel + 1
    FROM Empleados j
    JOIN Cadena c ON j.Id = c.JefeId                   -- subimos al jefe
)
SELECT Nivel, Nombre, Cargo FROM Cadena ORDER BY Nivel;


/* =====================================================================
   LECCION 8: FUNCIONES DE VENTANA (OVER) - las que separan junior de semi-senior
   A diferencia de GROUP BY, NO juntan filas: calculan algo y lo ponen al lado de cada fila.
   ===================================================================== */

-- 8.1 ROW_NUMBER: numerar filas
SELECT Id, Total,
       ROW_NUMBER() OVER (ORDER BY Total DESC) AS Puesto
FROM Ventas
WHERE Fecha >= '2026-11-01';

-- 8.2 PARTITION BY: reinicia la numeracion por grupo (top por estacion)
-- La venta mas grande de CADA estacion:
WITH r AS (
    SELECT EstacionId, Id, Fecha, Total,
           ROW_NUMBER() OVER (PARTITION BY EstacionId ORDER BY Total DESC) AS rn
    FROM Ventas
)
SELECT e.Nombre, r.Id AS VentaId, r.Fecha, r.Total
FROM r
JOIN Estaciones e ON e.Id = r.EstacionId
WHERE r.rn = 1;

-- 8.3 ROW_NUMBER vs RANK vs DENSE_RANK (mira los salarios repetidos)
SELECT Nombre, Salario,
       ROW_NUMBER() OVER (ORDER BY Salario DESC) AS RowNum,    -- 1,2,3,4 (nunca repite)
       RANK()       OVER (ORDER BY Salario DESC) AS Rnk,       -- 1,2,2,4 (repite y salta)
       DENSE_RANK() OVER (ORDER BY Salario DESC) AS DenseRnk   -- 1,2,2,3 (repite sin saltar)
FROM Empleados
ORDER BY Salario DESC;
-- Si piden "incluye empates" -> RANK o DENSE_RANK. Si piden "solo uno" -> ROW_NUMBER.

-- 8.4 Agregado como ventana: total de la estacion al lado de cada venta y % que representa
SELECT Id, EstacionId, Total,
       SUM(Total) OVER (PARTITION BY EstacionId) AS TotalEstacion,
       CAST(100.0 * Total / SUM(Total) OVER (PARTITION BY EstacionId) AS DECIMAL(6,3)) AS Porcentaje
FROM Ventas
WHERE EstacionId = 1 AND Fecha >= '2026-11-01';

-- 8.5 Running total (acumulado) por dia de noviembre
WITH PorDia AS (
    SELECT CAST(Fecha AS DATE) AS Dia, SUM(Total) AS TotalDia
    FROM Ventas
    WHERE Fecha >= '2026-11-01'
    GROUP BY CAST(Fecha AS DATE)
)
SELECT Dia, TotalDia,
       SUM(TotalDia) OVER (ORDER BY Dia) AS Acumulado
FROM PorDia
ORDER BY Dia;

-- 8.6 LAG / LEAD: valor de la fila anterior / siguiente (comparar con el dia anterior)
WITH PorDia AS (
    SELECT CAST(Fecha AS DATE) AS Dia, SUM(Total) AS TotalDia
    FROM Ventas
    WHERE Fecha >= '2026-11-01'
    GROUP BY CAST(Fecha AS DATE)
)
SELECT Dia, TotalDia,
       LAG(TotalDia) OVER (ORDER BY Dia)            AS DiaAnterior,
       TotalDia - LAG(TotalDia) OVER (ORDER BY Dia) AS Diferencia
FROM PorDia
ORDER BY Dia;


/* =====================================================================
   LECCION 9: UNION / UNION ALL - apilar resultados
   ===================================================================== */
-- UNION quita duplicados (mas lento). UNION ALL deja todo (mas rapido).
-- Las consultas deben tener la misma cantidad de columnas y tipos compatibles.
SELECT 'Estacion' AS Tipo, Nombre FROM Estaciones WHERE Provincia = N'Colón'
UNION ALL
SELECT 'Cliente', Nombre FROM Clientes WHERE Tipo = N'Flota' AND Id <= 3;


/* =====================================================================
   LECCION 10: MODIFICAR DATOS - INSERT, UPDATE, DELETE
   Todo dentro de BEGIN TRAN ... ROLLBACK para que tus datos queden intactos.
   Selecciona DESDE "BEGIN TRAN" HASTA "ROLLBACK" y ejecuta junto.
   ===================================================================== */
BEGIN TRAN;

    -- INSERT de una fila (Id es IDENTITY: no se envia, SQL lo genera)
    INSERT INTO Productos (Codigo, Nombre, Categoria, Unidad, PrecioUnitario)
    VALUES ('TDA-SODA', N'Soda 600ml', N'Tienda', N'Unidad', 1.100);

    SELECT SCOPE_IDENTITY() AS IdGenerado;     -- el Id que se acaba de crear

    -- INSERT de varias filas
    INSERT INTO Productos (Codigo, Nombre, Categoria, Unidad, PrecioUnitario)
    VALUES ('TDA-PAN', N'Pan de queso', N'Tienda', N'Unidad', 0.900),
           ('TDA-JUGO', N'Jugo natural', N'Tienda', N'Unidad', 2.000);

    -- UPDATE: SIEMPRE con WHERE (sin WHERE actualiza TODA la tabla)
    UPDATE Productos
    SET PrecioUnitario = PrecioUnitario * 1.05      -- sube 5%
    WHERE Categoria = N'Combustible';

    -- UPDATE con JOIN: pasar a Pendiente las sincronizaciones con Error de la estacion 1
    UPDATE s
    SET s.Estado = N'Pendiente'
    FROM SincronizacionERP s
    JOIN Ventas v ON v.Id = s.VentaId
    WHERE v.EstacionId = 1 AND s.Estado = N'Error';

    -- DELETE: SIEMPRE con WHERE
    DELETE FROM Productos WHERE Codigo = 'TDA-JUGO';

    -- Ver como quedo (solo dentro de esta transaccion)
    SELECT * FROM Productos;
    -- @@ROWCOUNT dice cuantas filas afecto la ultima instruccion

ROLLBACK;   -- deshace TODO lo de arriba. Cambia a COMMIT para guardarlo de verdad.

SELECT * FROM Productos;   -- comprobado: sigue igual que antes

/* DELETE vs TRUNCATE:
   DELETE   -> borra fila por fila, acepta WHERE, dispara triggers, se puede deshacer.
   TRUNCATE -> vacia la tabla completa, muy rapido, reinicia el IDENTITY, no acepta WHERE. */


/* =====================================================================
   LECCION 11: TRANSACCIONES + TRY/CATCH (manejo de errores)
   ACID: Atomicidad (todo o nada), Consistencia, Aislamiento, Durabilidad.
   ===================================================================== */
BEGIN TRY
    BEGIN TRAN;

        UPDATE Productos SET PrecioUnitario = 0.999 WHERE Codigo = 'GAS-91';

        -- Esto falla: Codigo es UNIQUE y 'GAS-95' ya existe
        INSERT INTO Productos (Codigo, Nombre, Categoria, Unidad, PrecioUnitario)
        VALUES ('GAS-95', N'Duplicado', N'Combustible', N'Litro', 1);

    COMMIT;
    PRINT 'Todo OK';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;     -- deshace tambien el UPDATE: "todo o nada"
    SELECT ERROR_NUMBER()  AS NumeroError,
           ERROR_MESSAGE() AS Mensaje;
    -- En un SP real aqui harias THROW; para que el error llegue a la aplicacion
END CATCH;

SELECT Codigo, PrecioUnitario FROM Productos WHERE Codigo = 'GAS-91';  -- sigue en 0.980
GO


/* =====================================================================
   LECCION 12: VISTAS, STORED PROCEDURES Y FUNCIONES
   (CREATE debe ser lo primero de su lote: por eso los GO)
   Al final de la leccion se borran para dejar la BD limpia.
   ===================================================================== */

-- 12.1 VISTA: una consulta guardada con nombre. Se usa como si fuera una tabla.
CREATE OR ALTER VIEW vw_ResumenEstaciones AS
SELECT e.Id, e.Nombre, e.Provincia,
       COUNT(v.Id)              AS CantidadVentas,
       ISNULL(SUM(v.Total), 0)  AS TotalVendido
FROM Estaciones e
LEFT JOIN Ventas v ON v.EstacionId = e.Id
GROUP BY e.Id, e.Nombre, e.Provincia;
GO

SELECT * FROM vw_ResumenEstaciones ORDER BY TotalVendido DESC;
GO

-- 12.2 STORED PROCEDURE con parametros
CREATE OR ALTER PROCEDURE sp_VentasPorEstacion
    @EstacionId INT,
    @Desde DATE,
    @Hasta DATE
AS
BEGIN
    SET NOCOUNT ON;   -- evita los mensajes "(n rows affected)"

    IF NOT EXISTS (SELECT 1 FROM Estaciones WHERE Id = @EstacionId)
    BEGIN
        THROW 50001, 'La estacion no existe', 1;
    END

    SELECT CAST(Fecha AS DATE) AS Dia, COUNT(*) AS Ventas, SUM(Total) AS Total
    FROM Ventas
    WHERE EstacionId = @EstacionId
      AND Fecha >= @Desde AND Fecha < DATEADD(DAY, 1, @Hasta)   -- incluye todo el dia "Hasta"
    GROUP BY CAST(Fecha AS DATE)
    ORDER BY Dia;
END;
GO

EXEC sp_VentasPorEstacion @EstacionId = 3, @Desde = '2026-11-01', @Hasta = '2026-11-07';
-- EXEC sp_VentasPorEstacion 99, '2026-11-01', '2026-11-07';   -- prueba el error
GO

-- 12.3 FUNCION ESCALAR: devuelve un valor y se usa DENTRO de un SELECT
CREATE OR ALTER FUNCTION fn_TotalCliente (@ClienteId INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN (SELECT ISNULL(SUM(Total), 0) FROM Ventas WHERE ClienteId = @ClienteId);
END;
GO

SELECT Nombre, dbo.fn_TotalCliente(Id) AS TotalComprado
FROM Clientes
ORDER BY TotalComprado DESC;
GO

/* SP vs FUNCION (pregunta tipica):
   - SP: se llama con EXEC, puede hacer INSERT/UPDATE/DELETE, manejar transacciones,
         devolver varios resultados. No se puede usar dentro de un SELECT.
   - Funcion: devuelve un valor o una tabla, se usa dentro de SELECT/WHERE,
         NO puede modificar datos. */

-- Limpieza: borramos lo creado en esta leccion
DROP VIEW IF EXISTS vw_ResumenEstaciones;
DROP PROCEDURE IF EXISTS sp_VentasPorEstacion;
DROP FUNCTION IF EXISTS fn_TotalCliente;
GO


/* =====================================================================
   LECCION 13: INDICES - rendimiento
   ===================================================================== */
/* - CLUSTERED: ordena fisicamente la tabla. Solo UNO por tabla (normalmente la PK).
   - NONCLUSTERED: estructura aparte, como el indice de un libro. Puede haber varios.
   - Aceleran SELECT con WHERE/JOIN/ORDER BY sobre esas columnas.
   - Hacen mas lentos INSERT/UPDATE/DELETE (hay que mantener el indice) y ocupan espacio.
   - INCLUDE: columnas extra guardadas en el indice para no ir a la tabla ("indice cubriente").

   TIP: en SSMS activa "Include Actual Execution Plan" (Ctrl+M) antes de ejecutar
   y mira la pestana "Execution plan": "Index Seek" = bien, "Table/Index Scan" = recorre todo. */

-- Ver los indices que ya tiene una tabla
EXEC sp_helpindex 'Clientes';

-- Crear un indice (ejemplo) y luego borrarlo
CREATE NONCLUSTERED INDEX IX_Clientes_Tipo
ON Clientes (Tipo)
INCLUDE (Nombre, LimiteCredito);

SELECT Nombre, LimiteCredito FROM Clientes WHERE Tipo = N'Flota';

DROP INDEX IX_Clientes_Tipo ON Clientes;

/* Errores que impiden usar un indice (SARGability):
   MAL:  WHERE YEAR(Fecha) = 2026          (funcion sobre la columna)
   BIEN: WHERE Fecha >= '2026-01-01' AND Fecha < '2027-01-01'
   MAL:  WHERE Nombre LIKE '%Delta'        (comodin al inicio)
   BIEN: WHERE Nombre LIKE 'Delta%' */


/* =====================================================================
   FIN. Ahora resuelve 02_ejercicios.sql sin mirar las soluciones.
   ===================================================================== */
