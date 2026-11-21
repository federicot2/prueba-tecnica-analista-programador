/* =====================================================================
   PRUEBA TECNICA - Base de datos de practica "DeltaPractica"
   Red de estaciones de combustible en Panama (datos ficticios).
   Ejecutar completo: borra y vuelve a crear la base de datos.
   ===================================================================== */
USE master;
GO
IF DB_ID('DeltaPractica') IS NOT NULL
BEGIN
    ALTER DATABASE DeltaPractica SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DeltaPractica;
END
GO
CREATE DATABASE DeltaPractica;
GO
USE DeltaPractica;
GO
SET NOCOUNT ON;

/* ----------------------------- TABLAS ------------------------------ */
CREATE TABLE Estaciones (
    Id             INT IDENTITY(1,1) PRIMARY KEY,
    Codigo         VARCHAR(10)  NOT NULL UNIQUE,
    Nombre         NVARCHAR(100) NOT NULL,
    Provincia      NVARCHAR(50) NOT NULL,
    Activa         BIT NOT NULL DEFAULT 1,
    FechaApertura  DATE NOT NULL
);

CREATE TABLE Productos (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    Codigo          VARCHAR(20) NOT NULL UNIQUE,
    Nombre          NVARCHAR(100) NOT NULL,
    Categoria       NVARCHAR(30) NOT NULL,      -- Combustible | Lubricante | Tienda
    Unidad          NVARCHAR(10) NOT NULL,      -- Litro | Unidad
    PrecioUnitario  DECIMAL(10,3) NOT NULL
);

CREATE TABLE Clientes (
    Id             INT IDENTITY(1,1) PRIMARY KEY,
    Nombre         NVARCHAR(150) NOT NULL,
    Ruc            VARCHAR(30) NOT NULL,
    Email          VARCHAR(150) NULL,
    Tipo           NVARCHAR(20) NOT NULL,       -- Flota | Contado
    LimiteCredito  DECIMAL(12,2) NOT NULL DEFAULT 0,
    FechaRegistro  DATE NOT NULL
);

CREATE TABLE Empleados (
    Id            INT IDENTITY(1,1) PRIMARY KEY,
    Nombre        NVARCHAR(100) NOT NULL,
    Cargo         NVARCHAR(50) NOT NULL,
    EstacionId    INT NULL REFERENCES Estaciones(Id),
    JefeId        INT NULL REFERENCES Empleados(Id),
    Salario       DECIMAL(10,2) NOT NULL,
    FechaIngreso  DATE NOT NULL
);

CREATE TABLE Ventas (
    Id                 INT IDENTITY(1,1) PRIMARY KEY,
    EstacionId         INT NOT NULL REFERENCES Estaciones(Id),
    ClienteId          INT NULL REFERENCES Clientes(Id),   -- NULL = consumidor final
    EmpleadoId         INT NOT NULL REFERENCES Empleados(Id),
    Fecha              DATETIME2(0) NOT NULL,
    Total              DECIMAL(12,2) NOT NULL DEFAULT 0,
    MetodoPago         NVARCHAR(20) NOT NULL,              -- Efectivo | Tarjeta | Credito | Yappy
    ReferenciaExterna  VARCHAR(50) NOT NULL UNIQUE         -- id unico del POS (idempotencia)
);

CREATE TABLE VentaDetalle (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    VentaId         INT NOT NULL REFERENCES Ventas(Id),
    ProductoId      INT NOT NULL REFERENCES Productos(Id),
    Cantidad        DECIMAL(10,3) NOT NULL,
    PrecioUnitario  DECIMAL(10,3) NOT NULL,
    Subtotal        DECIMAL(12,2) NOT NULL
);

-- Tabla intermedia (staging) para la integracion con el ERP
CREATE TABLE SincronizacionERP (
    Id             INT IDENTITY(1,1) PRIMARY KEY,
    VentaId        INT NOT NULL UNIQUE REFERENCES Ventas(Id),
    Estado         NVARCHAR(20) NOT NULL,       -- Pendiente | Enviado | Error
    Intentos       INT NOT NULL DEFAULT 0,
    UltimoError    NVARCHAR(400) NULL,
    FechaCreacion  DATETIME2(0) NOT NULL,
    FechaEnvio     DATETIME2(0) NULL
);
GO

/* ----------------------------- DATOS ------------------------------- */
INSERT INTO Estaciones (Codigo, Nombre, Provincia, Activa, FechaApertura) VALUES
('EST-001', N'Delta Vía España',        N'Panamá',          1, '2015-03-10'),
('EST-002', N'Delta Transístmica',      N'Panamá',          1, '2016-07-22'),
('EST-003', N'Delta Costa del Este',    N'Panamá',          1, '2019-01-15'),
('EST-004', N'Delta Tocumen',           N'Panamá',          1, '2017-11-02'),
('EST-005', N'Delta La Chorrera',       N'Panamá Oeste',    1, '2018-05-30'),
('EST-006', N'Delta Arraiján',          N'Panamá Oeste',    1, '2020-02-18'),
('EST-007', N'Delta Colón 2000',        N'Colón',           1, '2014-09-09'),
('EST-008', N'Delta Sabanitas',         N'Colón',           1, '2021-06-01'),
('EST-009', N'Delta David Centro',      N'Chiriquí',        1, '2013-04-12'),
('EST-010', N'Delta Boquete',           N'Chiriquí',        1, '2022-08-25'),
('EST-011', N'Delta Santiago',          N'Veraguas',        1, '2016-12-05'),
('EST-012', N'Delta Chitré',            N'Herrera',         1, '2018-10-19'),
('EST-013', N'Delta Penonomé',          N'Coclé',           1, '2019-07-07'),
('EST-014', N'Delta Las Tablas',        N'Los Santos',      1, '2023-03-03'),
('EST-015', N'Delta Changuinola',       N'Bocas del Toro',  0, '2012-01-20');

INSERT INTO Productos (Codigo, Nombre, Categoria, Unidad, PrecioUnitario) VALUES
('GAS-91',  N'Gasolina 91',            N'Combustible', N'Litro',  0.980),
('GAS-95',  N'Gasolina 95',            N'Combustible', N'Litro',  1.050),
('DIE-REG', N'Diésel',                 N'Combustible', N'Litro',  0.920),
('DIE-PRE', N'Diésel Premium',         N'Combustible', N'Litro',  0.990),
('LUB-2050',N'Lubricante 20W-50 1qt',  N'Lubricante',  N'Unidad', 12.500),
('LUB-0530',N'Aceite sintético 5W-30', N'Lubricante',  N'Unidad', 18.900),
('TDA-AGUA',N'Agua 1L',                N'Tienda',      N'Unidad',  1.250),
('TDA-CAFE',N'Café americano',         N'Tienda',      N'Unidad',  1.500),
('ADI-MOT', N'Aditivo de motor',       N'Lubricante',  N'Unidad',  7.750);

INSERT INTO Clientes (Nombre, Ruc, Email, Tipo, LimiteCredito, FechaRegistro) VALUES
(N'Transportes del Istmo S.A.',     '155601234-2-2015', 'compras@transistmo.pa',   N'Flota',   15000, '2020-01-10'),
(N'Logística Canal S.A.',           '155612345-2-2016', 'flota@logcanal.pa',       N'Flota',   25000, '2020-03-05'),
(N'Distribuidora Chiriquí',         '4-123-4567',       'admin@dischiriqui.pa',    N'Flota',    8000, '2021-02-14'),
(N'Taxis Unidos de Panamá',         '155623456-2-2018', 'pagos@taxisunidos.pa',    N'Flota',    5000, '2021-06-20'),
(N'Constructora Pacífico',          '155634567-2-2010', 'compras@cpacifico.pa',    N'Flota',   40000, '2019-11-11'),
(N'Agroexport Veraguas',            '9-876-5432',       NULL,                      N'Flota',    6000, '2022-01-30'),
(N'Mudanzas Express',               '8-765-4321',       'info@mudanzasexp.pa',     N'Contado',     0, '2022-04-18'),
(N'Buses Coclé',                    '155645678-2-2019', 'flota@busescocle.pa',     N'Flota',   12000, '2021-09-09'),
(N'Farmacias Salud Total',          '155656789-2-2014', 'compras@saludtotal.pa',   N'Flota',    7000, '2023-01-05'),
(N'Seguridad Alfa',                 '155667890-2-2017', 'admin@seguridadalfa.pa',  N'Flota',    9000, '2022-07-07'),
(N'Courier Rápido',                 '8-111-2222',       'info@mudanzasexp.pa',     N'Contado',     0, '2023-05-12'),   -- email duplicado
(N'Hotel Brisas del Mar',           '155678901-2-2012', NULL,                      N'Contado',     0, '2023-08-21'),
(N'Panaderías La Espiga',           '155689012-2-2020', 'pedidos@laespiga.pa',     N'Flota',    3000, '2024-02-02'),
(N'Ambulancias Vida',               '155690123-2-2021', 'ops@ambvida.pa',          N'Flota',   10000, '2024-03-15'),
(N'Turismo Bocas',                  '1-222-3333',       'reservas@turbocas.pa',    N'Contado',     0, '2024-06-30'),
(N'Minera Centro',                  '155601111-2-2011', 'compras@mineracentro.pa', N'Flota',   60000, '2020-10-10'),
(N'Refrigeración Polar',            '8-333-4444',       'compras@cpacifico.pa',    N'Contado',     0, '2024-09-09'),   -- email duplicado
(N'Fumigaciones Verdes',            '155602222-2-2022', 'admin@fverdes.pa',        N'Flota',    4000, '2025-01-20'),
(N'Escuela de Manejo Segura',       '155603333-2-2023', 'info@manejosegura.pa',    N'Contado',     0, '2025-04-04'),
(N'Grúas 24/7',                     '8-555-6666',       'servicio@gruas247.pa',    N'Flota',    5000, '2025-07-17'),
(N'Eventos Gala',                   '8-777-8888',       'gala@eventos.pa',         N'Contado',     0, '2025-10-01'),   -- sin compras
(N'Cooperativa Agrícola Herrera',   '6-999-0000',       NULL,                      N'Flota',    7500, '2026-02-10');   -- sin compras

-- Empleados: 1 gerente, 4 supervisores, 28 cajeros (2 por estacion activa)
INSERT INTO Empleados (Nombre, Cargo, EstacionId, JefeId, Salario, FechaIngreso) VALUES
(N'Ricardo Méndez',  N'Gerente de Operaciones', NULL, NULL, 4500, '2012-02-01'),
(N'Ana Castillo',    N'Supervisor Regional',    NULL, 1,    2100, '2014-05-10'),
(N'Luis Herrera',    N'Supervisor Regional',    NULL, 1,    1950, '2015-08-20'),
(N'Marta Pinzón',    N'Supervisor Regional',    NULL, 1,    2100, '2016-01-15'),
(N'Jorge Sánchez',   N'Supervisor Regional',    NULL, 1,    1800, '2018-03-03');

DECLARE @nombres TABLE (i INT, n NVARCHAR(50));
INSERT INTO @nombres VALUES
(1,N'Carlos'),(2,N'María'),(3,N'José'),(4,N'Lucía'),(5,N'Pedro'),(6,N'Rosa'),(7,N'Juan'),
(8,N'Elena'),(9,N'Miguel'),(10,N'Sofía'),(11,N'Andrés'),(12,N'Carmen'),(13,N'Diego'),(14,N'Paula');
DECLARE @apellidos TABLE (i INT, a NVARCHAR(50));
INSERT INTO @apellidos VALUES
(0,N'González'),(1,N'Rodríguez'),(2,N'Pérez'),(3,N'Batista'),(4,N'Vega'),(5,N'Ríos'),(6,N'Moreno');

;WITH t AS (SELECT TOP (28) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS k FROM sys.all_objects)
INSERT INTO Empleados (Nombre, Cargo, EstacionId, JefeId, Salario, FechaIngreso)
SELECT n.n + N' ' + a.a,
       N'Cajero',
       ((t.k - 1) % 14) + 1,                       -- estacion 1..14
       2 + (((t.k - 1) % 14) % 4),                 -- supervisor 2..5
       650 + ((t.k % 5) * 50),
       DATEADD(DAY, t.k * 97, '2018-01-01')
FROM t
JOIN @nombres n   ON n.i = ((t.k - 1) % 14) + 1
JOIN @apellidos a ON a.i = t.k % 7
ORDER BY t.k;
-- Cajeros: Id 6..19 -> estaciones 1..14 ; Id 20..33 -> estaciones 1..14

/* Ventas generadas de forma deterministica: ene-2026 a mediados de nov-2026 */
IF OBJECT_ID('tempdb..#gen') IS NOT NULL DROP TABLE #gen;
;WITH n AS (
    SELECT TOP (6000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
SELECT n.n,
       (n.n % 14) + 1 AS EstacionId,
       CASE WHEN n.n % 3 = 0 THEN (n.n % 20) + 1 END AS ClienteId,
       DATEADD(MINUTE, 360 + (n.n * 37) % 960, CAST(DATEADD(DAY, (n.n * 7) % 319, '2026-01-01') AS DATETIME2(0))) AS Fecha,
       CASE n.n % 4 WHEN 0 THEN N'Efectivo' WHEN 1 THEN N'Tarjeta' WHEN 2 THEN N'Yappy' ELSE N'Credito' END AS MetodoPago,
       'POS-' + RIGHT('000000' + CAST(n.n AS VARCHAR(6)), 6) AS Ref
INTO #gen
FROM n;

-- La estacion 14 (Las Tablas) estuvo cerrada por mantenimiento en octubre 2026
DELETE FROM #gen WHERE EstacionId = 14 AND Fecha >= '2026-10-01' AND Fecha < '2026-11-01';

INSERT INTO Ventas (EstacionId, ClienteId, EmpleadoId, Fecha, Total, MetodoPago, ReferenciaExterna)
SELECT EstacionId,
       ClienteId,
       CASE WHEN n % 2 = 0 THEN 5 + EstacionId ELSE 19 + EstacionId END,
       Fecha,
       0,
       CASE WHEN MetodoPago = N'Credito' AND ClienteId IS NULL THEN N'Efectivo' ELSE MetodoPago END,
       Ref
FROM #gen
ORDER BY Fecha, n;

-- Linea 1: combustible
INSERT INTO VentaDetalle (VentaId, ProductoId, Cantidad, PrecioUnitario, Subtotal)
SELECT v.Id, p.Id, q.Cant, p.PrecioUnitario, ROUND(q.Cant * p.PrecioUnitario, 2)
FROM Ventas v
JOIN #gen g ON g.Ref = v.ReferenciaExterna
CROSS APPLY (SELECT CAST(10 + (g.n * 13) % 60 + CASE WHEN g.ClienteId IS NOT NULL THEN 40 ELSE 0 END AS DECIMAL(10,3)) AS Cant) q
JOIN Productos p ON p.Id = CASE
        WHEN g.EstacionId IN (9,10,11) AND g.n % 3 <> 0 THEN 3    -- interior: mas diesel
        ELSE (g.n % 4) + 1 END;

-- Linea 2 (1 de cada 5 ventas): lubricante o tienda
INSERT INTO VentaDetalle (VentaId, ProductoId, Cantidad, PrecioUnitario, Subtotal)
SELECT v.Id, p.Id, q.Cant, p.PrecioUnitario, ROUND(q.Cant * p.PrecioUnitario, 2)
FROM Ventas v
JOIN #gen g ON g.Ref = v.ReferenciaExterna
CROSS APPLY (SELECT CAST(1 + g.n % 3 AS DECIMAL(10,3)) AS Cant) q
JOIN Productos p ON p.Id = 5 + (g.n % 4)
WHERE g.n % 5 = 0;

UPDATE v SET Total = d.Total
FROM Ventas v
JOIN (SELECT VentaId, SUM(Subtotal) AS Total FROM VentaDetalle GROUP BY VentaId) d ON d.VentaId = v.Id;

-- Staging ERP: lo viejo enviado, lo reciente pendiente, algunos con error
INSERT INTO SincronizacionERP (VentaId, Estado, Intentos, UltimoError, FechaCreacion, FechaEnvio)
SELECT v.Id,
       CASE WHEN v.Fecha >= '2026-11-10' THEN N'Pendiente'
            WHEN v.Id % 97 = 0 THEN N'Error'
            ELSE N'Enviado' END,
       CASE WHEN v.Fecha >= '2026-11-10' THEN 0
            WHEN v.Id % 97 = 0 THEN 3
            ELSE 1 END,
       CASE WHEN v.Fecha < '2026-11-10' AND v.Id % 97 = 0 THEN N'ERP timeout: no se recibio respuesta en 30s' END,
       DATEADD(MINUTE, 1, v.Fecha),
       CASE WHEN v.Fecha < '2026-11-10' AND v.Id % 97 <> 0 THEN DATEADD(MINUTE, 15, v.Fecha) END
FROM Ventas v;

DROP TABLE #gen;
GO

/* ------------------------- VERIFICACION ---------------------------- */
SELECT 'Estaciones' AS Tabla, COUNT(*) AS Filas FROM Estaciones UNION ALL
SELECT 'Productos', COUNT(*) FROM Productos UNION ALL
SELECT 'Clientes', COUNT(*) FROM Clientes UNION ALL
SELECT 'Empleados', COUNT(*) FROM Empleados UNION ALL
SELECT 'Ventas', COUNT(*) FROM Ventas UNION ALL
SELECT 'VentaDetalle', COUNT(*) FROM VentaDetalle UNION ALL
SELECT 'SincronizacionERP', COUNT(*) FROM SincronizacionERP;
GO
