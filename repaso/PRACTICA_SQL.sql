/* =====================================================================
   PRACTICA DE SQL SERVER - todo en un solo archivo
   Base de datos: DeltaPractica (localhost\SQLEXPRESS)

   CADA TEMA TRAE:
     QUE ES      -> la idea en una o dos lineas
     COMO SE USA -> la sintaxis y un ejemplo que puedes correr
     EJERCICIO   -> lo que tienes que hacer tu
       USA:      -> las palabras clave que necesitas
       ESPERADO: -> lo que te tiene que dar. Si te da igual, vas bien.

   COMO TRABAJAR:
   - NO ejecutes el archivo completo. Selecciona UN ejemplo y ejecutalo
     (SSMS: F5 / VS Code con mssql: Ctrl+Shift+E).
   - Escribe tu respuesta debajo de "-- Tu respuesta:" y ejecutala.
   - Las respuestas estan en PRACTICA_SQL_respuestas.sql (mismo numero de tema).
     Miralas SOLO despues de intentarlo.

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


/* #####################################################################
   PARTE 1: SELECT - leer datos
   ##################################################################### */

/* ---------------------------------------------------------------------
   TEMA 1. SELECT y alias (AS)
   QUE ES: SELECT elige que columnas ver. AS le pone otro nombre a una
           columna o a una tabla (alias).
   COMO SE USA:  SELECT columna1, columna2 AS NuevoNombre FROM Tabla;
   --------------------------------------------------------------------- */
SELECT Nombre AS Estacion, Provincia
FROM Estaciones;

-- EJERCICIO 1: Muestra el Codigo y el Nombre de todos los productos.
--              La columna Nombre debe salir como "Producto".
--   USA: SELECT, AS
--   ESPERADO: 9 filas, columnas Codigo | Producto.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 2. ORDER BY - ordenar
   QUE ES: ordena el resultado. ASC = de menor a mayor (por defecto),
           DESC = de mayor a menor. Puedes ordenar por varias columnas:
           la segunda solo desempata a la primera.
   COMO SE USA:  ... ORDER BY columna1 DESC, columna2 ASC;
   --------------------------------------------------------------------- */
SELECT Provincia, Nombre
FROM Estaciones
ORDER BY Provincia, Nombre;

-- EJERCICIO 2: Nombre y Salario de los empleados, del salario mas alto al
--              mas bajo. Si dos ganan igual, ordenalos por nombre (A-Z).
--   USA: ORDER BY ... DESC, ... ASC
--   ESPERADO: 33 filas. Primero Ricardo Mendez (4500), luego Ana Castillo
--             y Marta Pinzon (2100) en ese orden.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 3. TOP - solo las primeras N filas
   QUE ES: limita cuantas filas devuelve. Va SIEMPRE con ORDER BY, si no
           el "top" sale en cualquier orden.
   COMO SE USA:  SELECT TOP (N) ... FROM ... ORDER BY ...;
   --------------------------------------------------------------------- */
SELECT TOP (5) Id, Fecha, Total
FROM Ventas
ORDER BY Total DESC;

-- EJERCICIO 3: Los 3 clientes con el limite de credito mas alto (nombre y limite).
--   USA: TOP (3), ORDER BY ... DESC
--   ESPERADO: 3 filas. Minera Centro (60000), Constructora Pacifico (40000),
--             Logistica Canal S.A. (25000).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 4. DISTINCT - sin repetidos
   QUE ES: quita las filas repetidas del resultado.
   COMO SE USA:  SELECT DISTINCT columna FROM Tabla;
   --------------------------------------------------------------------- */
SELECT DISTINCT MetodoPago FROM Ventas;

-- EJERCICIO 4: Lista los cargos distintos que existen en Empleados.
--   USA: DISTINCT
--   ESPERADO: 3 filas (Cajero, Gerente de Operaciones, Supervisor Regional).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 5. Columnas calculadas
   QUE ES: puedes hacer cuentas (+ - * /) con las columnas y mostrar el
           resultado como una columna nueva (ponle nombre con AS).
   COMO SE USA:  SELECT Precio * 1.07 AS PrecioConImpuesto FROM ...;
   --------------------------------------------------------------------- */
SELECT Nombre, PrecioUnitario, PrecioUnitario * 1.07 AS PrecioConITBMS
FROM Productos;

-- EJERCICIO 5: Nombre, Salario y el salario anual (Salario x 12) de cada empleado.
--              Llama a la columna nueva "SalarioAnual".
--   USA: Salario * 12 AS SalarioAnual
--   ESPERADO: 33 filas. Ricardo Mendez: 54000.00
-- Tu respuesta:




/* #####################################################################
   PARTE 2: WHERE - filtrar filas
   ##################################################################### */

/* ---------------------------------------------------------------------
   TEMA 6. WHERE con comparaciones
   QUE ES: WHERE se queda solo con las filas que cumplen la condicion.
           Operadores: =  <> (distinto)  >  <  >=  <=
           Para texto usa N'...' (la N es por las tildes).
   COMO SE USA:  SELECT ... FROM ... WHERE columna >= valor;
   --------------------------------------------------------------------- */
SELECT Nombre, PrecioUnitario
FROM Productos
WHERE Categoria = N'Lubricante';

-- EJERCICIO 6: Cajeros que ganan 800 o mas (nombre y salario).
--   USA: WHERE Cargo = N'Cajero' AND Salario >= 800
--   ESPERADO: 11 filas.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 7. AND / OR y parentesis
   QUE ES: AND = se cumplen las dos. OR = se cumple al menos una.
           AND se evalua ANTES que OR, asi que cuando mezcles, usa
           parentesis o el resultado sale mal.
   COMO SE USA:  WHERE (cond1 OR cond2) AND cond3
   --------------------------------------------------------------------- */
SELECT Nombre, Provincia
FROM Estaciones
WHERE Activa = 1 AND (Provincia = N'Colón' OR Provincia = N'Chiriquí');

-- EJERCICIO 7: Cuantas ventas se pagaron en Efectivo o Yappy Y ademas
--              tienen un Total mayor a 90.
--   USA: COUNT(*), WHERE ( ... OR ... ) AND ...
--   ESPERADO: 200. (Si te da 2586 te olvidaste los parentesis.)
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 8. IN - igual a alguno de una lista
   QUE ES: es un atajo para muchos OR sobre la misma columna.
   COMO SE USA:  WHERE columna IN (valor1, valor2, valor3)
   --------------------------------------------------------------------- */
SELECT Id, Total, MetodoPago
FROM Ventas
WHERE MetodoPago IN (N'Tarjeta', N'Yappy') AND Id <= 10;

-- EJERCICIO 8: Estaciones de las provincias Herrera, Los Santos y Veraguas.
--   USA: IN
--   ESPERADO: 3 filas (Delta Santiago, Delta Chitre, Delta Las Tablas).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 9. BETWEEN - rango
   QUE ES: valor entre un minimo y un maximo, INCLUYENDO los dos extremos.
           (Para FECHAS no lo uses, mira el tema 12.)
   COMO SE USA:  WHERE columna BETWEEN minimo AND maximo
   --------------------------------------------------------------------- */
SELECT Nombre, Salario
FROM Empleados
WHERE Salario BETWEEN 1800 AND 2100;

-- EJERCICIO 9: Productos con precio entre 1 y 1.5 (incluidos).
--   USA: BETWEEN
--   ESPERADO: 3 filas (Gasolina 95, Agua 1L, Cafe americano).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 10. LIKE - buscar texto
   QUE ES: busca por patron.  % = cualquier cantidad de caracteres,
           _ = exactamente un caracter.
   COMO SE USA:  WHERE Nombre LIKE N'Trans%'   (empieza con Trans)
                 WHERE Nombre LIKE N'%Express%' (contiene Express)
                 WHERE Email  LIKE '%.pa'       (termina en .pa)
   --------------------------------------------------------------------- */
SELECT Nombre FROM Clientes WHERE Nombre LIKE N'%Express%';

-- EJERCICIO 10: Productos cuyo nombre EMPIEZA con "Di".
--   USA: LIKE con %
--   ESPERADO: 2 filas (Diesel y Diesel Premium).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 11. IS NULL / IS NOT NULL
   QUE ES: NULL = "no hay dato". NO se compara con = NULL (siempre da
           vacio). Se usa IS NULL o IS NOT NULL.
   COMO SE USA:  WHERE Email IS NULL
   --------------------------------------------------------------------- */
SELECT Nombre, Cargo FROM Empleados WHERE JefeId IS NULL;   -- el que no tiene jefe

-- EJERCICIO 11: Cuantas ventas NO tienen cliente (consumidor final:
--               ClienteId vacio).
--   USA: COUNT(*), IS NULL
--   ESPERADO: 3971
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 12. Filtrar por FECHAS
   QUE ES: la columna Fecha tiene hora. Usa SIEMPRE ">= inicio" y
           "< dia siguiente al final". Asi no pierdes las ventas del
           ultimo dia y SQL puede usar indices.
   COMO SE USA:  WHERE Fecha >= '2026-10-01' AND Fecha < '2026-11-01'  (octubre)
   --------------------------------------------------------------------- */
SELECT COUNT(*) AS VentasOctubre
FROM Ventas
WHERE Fecha >= '2026-10-01' AND Fecha < '2026-11-01';

-- EJERCICIO 12: Cuantas ventas hubo del 1 al 7 de noviembre 2026 (incluido el 7).
--   USA: COUNT(*), Fecha >= ... AND Fecha < ...
--   ESPERADO: 131
-- Tu respuesta:




/* #####################################################################
   PARTE 3: FUNCIONES
   ##################################################################### */

/* ---------------------------------------------------------------------
   TEMA 13. Funciones de texto
   QUE ES: transforman texto.
     UPPER / LOWER      -> mayusculas / minusculas
     LEN(x)             -> cantidad de caracteres
     LEFT(x, n)         -> primeros n caracteres
     CONCAT(a, ' ', b)  -> unir textos
     REPLACE(x, a, b)   -> reemplazar a por b
   --------------------------------------------------------------------- */
SELECT Nombre, LEFT(Codigo, 3) AS Prefijo, CONCAT(Codigo, ' - ', Nombre) AS Completo
FROM Productos;

-- EJERCICIO 13: Nombre de cada estacion en MAYUSCULAS y cuantos caracteres
--               tiene. Ordena del nombre mas largo al mas corto.
--   USA: UPPER, LEN, ORDER BY ... DESC
--   ESPERADO: 15 filas. Primero DELTA COSTA DEL ESTE (20).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 14. Funciones de fecha
   QUE ES:
     GETDATE()                 -> fecha y hora de ahora
     YEAR(f) / MONTH(f) / DAY(f)
     DATEADD(DAY, 30, f)       -> sumar tiempo (DAY, MONTH, YEAR...)
     DATEDIFF(DAY, f1, f2)     -> diferencia entre dos fechas
   --------------------------------------------------------------------- */
SELECT Nombre, FechaIngreso,
       YEAR(FechaIngreso)                      AS AnioIngreso,
       DATEDIFF(YEAR, FechaIngreso, GETDATE()) AS AniosEnLaEmpresa
FROM Empleados
WHERE Cargo = N'Gerente de Operaciones';

-- EJERCICIO 14: Para los Supervisores Regionales: Nombre, FechaIngreso y la
--               fecha de su primer aniversario (FechaIngreso + 1 anio).
--   USA: DATEADD(YEAR, 1, ...)
--   ESPERADO: 4 filas. Ana Castillo: 2014-05-10 -> 2015-05-10
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 15. ISNULL / COALESCE - reemplazar NULL
   QUE ES: si el valor es NULL, muestra otro en su lugar.
     ISNULL(x, 'otro')        -> dos valores
     COALESCE(a, b, c, ...)   -> el primero que NO sea NULL
   --------------------------------------------------------------------- */
SELECT Nombre, ISNULL(CAST(JefeId AS VARCHAR(10)), 'sin jefe') AS Jefe
FROM Empleados
WHERE Cargo <> N'Cajero';

-- EJERCICIO 15: Nombre y Email de todos los clientes. Si no tiene correo
--               debe decir 'SIN CORREO'.
--   USA: ISNULL
--   ESPERADO: 22 filas, 3 con 'SIN CORREO'.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 16. CASE - el "if" de SQL
   QUE ES: devuelve un valor segun condiciones. Se evalua en orden: la
           PRIMERA condicion que se cumpla gana. ELSE = si ninguna.
   COMO SE USA:
     CASE WHEN condicion1 THEN 'A'
          WHEN condicion2 THEN 'B'
          ELSE 'C' END AS NombreColumna
   --------------------------------------------------------------------- */
SELECT Id, Total,
       CASE WHEN Total >= 100 THEN 'Grande'
            WHEN Total >= 40  THEN 'Mediana'
            ELSE 'Pequena' END AS TipoVenta
FROM Ventas
WHERE Id <= 10;

-- EJERCICIO 16: Nombre, LimiteCredito y una columna "Nivel" para cada cliente:
--               20000 o mas = 'Alto', 5000 o mas = 'Medio', el resto = 'Bajo'.
--               Ordena por limite de mayor a menor.
--   USA: CASE WHEN ... THEN ... ELSE ... END
--   ESPERADO: 22 filas: 3 Alto, 10 Medio, 9 Bajo.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 17. CAST - cambiar el tipo de dato
   QUE ES: convierte un valor a otro tipo.
     CAST(Fecha AS DATE)        -> quita la hora
     CAST(Total AS INT)         -> quita los decimales (corta, no redondea)
     CAST(Id AS VARCHAR(10))    -> numero a texto
   --------------------------------------------------------------------- */
SELECT Id, CAST(Id AS VARCHAR(10)) + ' es el id' AS Texto
FROM Ventas
WHERE Id <= 3;

-- EJERCICIO 17: Para las ventas con Id del 1 al 5: Id, la fecha SIN hora
--               y el Total como numero entero.
--   USA: CAST(... AS DATE), CAST(... AS INT)
--   ESPERADO: 5 filas. Id 1: 2026-01-01 | 68
-- Tu respuesta:




/* #####################################################################
   PARTE 4: AGREGADOS - resumir datos
   ##################################################################### */

/* ---------------------------------------------------------------------
   TEMA 18. COUNT, SUM, AVG, MIN, MAX
   QUE ES: funciones que juntan muchas filas en UN valor.
     COUNT(*) cantidad | SUM suma | AVG promedio | MIN minimo | MAX maximo
   COMO SE USA:  SELECT COUNT(*), SUM(Total) FROM Ventas;   -> 1 fila
   --------------------------------------------------------------------- */
SELECT COUNT(*) AS Ventas, SUM(Total) AS Total, AVG(Total) AS Promedio,
       MIN(Total) AS Minima, MAX(Total) AS Maxima
FROM Ventas;

-- EJERCICIO 18: De la tabla Empleados: cuantos son, la planilla total
--               (suma de salarios), el promedio, el minimo y el maximo.
--   USA: COUNT(*), SUM, AVG, MIN, MAX
--   ESPERADO: 1 fila: 33 | 33450.00 | 1013.63 | 650.00 | 4500.00
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 19. COUNT(*) vs COUNT(columna)
   QUE ES: COUNT(*) cuenta TODAS las filas. COUNT(columna) cuenta solo
           donde esa columna NO es NULL. COUNT(DISTINCT col) = valores distintos.
   --------------------------------------------------------------------- */
SELECT COUNT(*)                  AS Ventas,
       COUNT(ClienteId)          AS ConCliente,
       COUNT(DISTINCT ClienteId) AS ClientesDistintos
FROM Ventas;

-- EJERCICIO 19: En Clientes: cuantos hay en total, cuantos tienen correo
--               y cuantos NO tienen correo (todo en una sola consulta).
--   USA: COUNT(*), COUNT(Email), una resta
--   ESPERADO: 1 fila: 22 | 19 | 3
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 20. GROUP BY - un resultado por grupo
   QUE ES: en vez de 1 fila para toda la tabla, da 1 fila POR CADA valor
           distinto de la columna que agrupas.
   REGLA DE ORO: toda columna del SELECT que NO este dentro de un
           agregado (COUNT, SUM...) tiene que estar en el GROUP BY.
   COMO SE USA:  SELECT columna, COUNT(*) FROM ... GROUP BY columna;
   --------------------------------------------------------------------- */
SELECT MetodoPago, COUNT(*) AS Cantidad, SUM(Total) AS Total
FROM Ventas
GROUP BY MetodoPago;

-- EJERCICIO 20: Por cada Cargo: cuantos empleados hay y su salario promedio.
--               Ordena de mas empleados a menos.
--   USA: GROUP BY Cargo, COUNT(*), AVG
--   ESPERADO: 3 filas. Cajero 28 | 750 ; Supervisor Regional 4 | 1987.5 ; Gerente 1 | 4500
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 21. GROUP BY por varias columnas
   QUE ES: un grupo por cada COMBINACION de valores.
   COMO SE USA:  GROUP BY columna1, columna2
   --------------------------------------------------------------------- */
SELECT Categoria, Unidad, COUNT(*) AS Productos
FROM Productos
GROUP BY Categoria, Unidad;

-- EJERCICIO 21: Total vendido por mes (numero de mes) Y metodo de pago,
--               solo de septiembre, octubre y noviembre 2026.
--               Ordena por mes y luego por total de mayor a menor.
--   USA: WHERE con rango de fechas, MONTH(Fecha), GROUP BY MONTH(Fecha), MetodoPago
--   ESPERADO: 12 filas (3 meses x 4 metodos). Primera: 9 | Efectivo | 11806.09
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 22. HAVING - filtrar GRUPOS
   QUE ES: WHERE filtra FILAS (antes de agrupar). HAVING filtra GRUPOS
           (despues de agrupar) y por eso puede usar COUNT, SUM...
   ORDEN EN QUE SQL EJECUTA (te lo pueden preguntar):
     1 FROM/JOIN  2 WHERE  3 GROUP BY  4 HAVING  5 SELECT  6 ORDER BY
   COMO SE USA:  ... GROUP BY columna HAVING COUNT(*) > 10
   --------------------------------------------------------------------- */
SELECT MetodoPago, COUNT(*) AS Cantidad
FROM Ventas
GROUP BY MetodoPago
HAVING COUNT(*) > 1500;

-- EJERCICIO 22: Las estaciones (EstacionId) que tienen MENOS de 400 ventas.
--   USA: GROUP BY EstacionId, HAVING COUNT(*) < 400
--   ESPERADO: 1 fila: EstacionId 14 con 385 ventas.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 23. Encontrar DUPLICADOS (clasico de prueba tecnica)
   QUE ES: agrupas por la columna que se repite y te quedas con los grupos
           que tienen mas de 1 fila.
   --------------------------------------------------------------------- */
SELECT Email, COUNT(*) AS Veces
FROM Clientes
WHERE Email IS NOT NULL
GROUP BY Email
HAVING COUNT(*) > 1;

-- EJERCICIO 23: Que salarios se repiten en Empleados y cuantas personas
--               ganan cada uno. Ordena por salario.
--   USA: GROUP BY Salario, HAVING COUNT(*) > 1
--   ESPERADO: 6 filas. Primera: 650.00 | 5. Ultima: 2100.00 | 2
-- Tu respuesta:




/* #####################################################################
   PARTE 5: JOINs - combinar tablas  (LA MAS IMPORTANTE)
   ##################################################################### */

/* ---------------------------------------------------------------------
   TEMA 24. INNER JOIN
   QUE ES: une dos tablas por una columna en comun y deja SOLO las filas
           que tienen pareja en las dos. JOIN solo = INNER JOIN.
   COMO SE USA:
     SELECT ... FROM TablaA a
     JOIN TablaB b ON b.Id = a.TablaBId
   --------------------------------------------------------------------- */
SELECT v.Id, v.Total, e.Nombre AS Estacion
FROM Ventas v
JOIN Estaciones e ON e.Id = v.EstacionId
WHERE v.Id <= 5;

-- EJERCICIO 24: Nombre de cada empleado con el nombre de su estacion.
--               Ordena por estacion y luego por empleado.
--   USA: Empleados JOIN Estaciones ON ... EstacionId
--   ESPERADO: 28 filas (los 5 jefes no tienen estacion, por eso no salen).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 25. Varios JOINs encadenados
   QUE ES: puedes unir 3, 4 o mas tablas. Cada JOIN con su propio ON.
           Sigue el "camino" de las llaves: Ventas -> VentaDetalle -> Productos
   --------------------------------------------------------------------- */
SELECT v.Id, p.Nombre AS Producto, d.Cantidad
FROM Ventas v
JOIN VentaDetalle d ON d.VentaId = v.Id
JOIN Productos p    ON p.Id = d.ProductoId
WHERE v.Id = 10;

-- EJERCICIO 25: Para la venta Id = 9: Id, nombre de la estacion, nombre del
--               producto, cantidad y subtotal de cada linea.
--   USA: 4 tablas: Ventas, Estaciones, VentaDetalle, Productos
--   ESPERADO: 2 filas, Delta Chitre: Gasolina 95 (95 | 99.75) y Aceite sintetico (1 | 18.90)
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 26. JOIN + GROUP BY
   QUE ES: primero unes las tablas, despues agrupas por una columna de
           cualquiera de ellas.
   --------------------------------------------------------------------- */
SELECT e.Provincia, COUNT(*) AS Ventas
FROM Ventas v
JOIN Estaciones e ON e.Id = v.EstacionId
GROUP BY e.Provincia;

-- EJERCICIO 26: Total vendido (suma de Subtotal) por Categoria de producto.
--               De mayor a menor.
--   USA: VentaDetalle JOIN Productos, GROUP BY p.Categoria, SUM
--   ESPERADO: 3 filas. Combustible 308038.08 | Lubricante 18726.60 | Tienda 1632.00
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 27. LEFT JOIN
   QUE ES: TODAS las filas de la tabla de la IZQUIERDA (la del FROM),
           tengan o no pareja. Si no tienen pareja, las columnas de la
           derecha salen NULL.
   TIP: para contar con LEFT JOIN usa COUNT(columna_derecha), no COUNT(*),
        asi los que no tienen pareja dan 0 y no 1.
   --------------------------------------------------------------------- */
SELECT c.Nombre, COUNT(v.Id) AS Compras
FROM Clientes c
LEFT JOIN Ventas v ON v.ClienteId = c.Id
GROUP BY c.Nombre
ORDER BY Compras;

-- EJERCICIO 27: TODAS las estaciones con cuantos empleados tiene cada una.
--               Ordena de menos empleados a mas.
--   USA: Estaciones LEFT JOIN Empleados, COUNT(emp.Id), GROUP BY
--   ESPERADO: 15 filas. Primera: Delta Changuinola con 0.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 28. "Los que NO tienen": LEFT JOIN + IS NULL
   QUE ES: haces LEFT JOIN y te quedas con las filas donde la derecha
           salio NULL = no tienen pareja.
   --------------------------------------------------------------------- */
SELECT c.Nombre
FROM Clientes c
LEFT JOIN Ventas v ON v.ClienteId = c.Id
WHERE v.Id IS NULL;          -- clientes que nunca compraron

-- EJERCICIO 28: Estaciones que NUNCA han tenido una venta.
--   USA: Estaciones LEFT JOIN Ventas, WHERE v.Id IS NULL
--   ESPERADO: 1 fila (Delta Changuinola).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 29. LA TRAMPA DEL LEFT JOIN: filtro en ON vs en WHERE
   QUE ES: si filtras una columna de la tabla DERECHA en el WHERE, las
           filas sin pareja (NULL) se eliminan y tu LEFT JOIN se vuelve
           un INNER JOIN sin que te des cuenta.
   REGLA: en LEFT JOIN -> filtros de la tabla DERECHA van en el ON.
                          filtros de la tabla IZQUIERDA van en el WHERE.
   --------------------------------------------------------------------- */
-- MAL: la fecha en el WHERE -> desaparecen los clientes que no compraron en octubre
SELECT c.Nombre, COUNT(v.Id) AS ComprasOct
FROM Clientes c
LEFT JOIN Ventas v ON v.ClienteId = c.Id
WHERE v.Fecha >= '2026-10-01' AND v.Fecha < '2026-11-01'
GROUP BY c.Nombre;
-- BIEN: la fecha en el ON -> salen TODOS los clientes, los que no compraron con 0
SELECT c.Nombre, COUNT(v.Id) AS ComprasOct
FROM Clientes c
LEFT JOIN Ventas v ON v.ClienteId = c.Id
                  AND v.Fecha >= '2026-10-01' AND v.Fecha < '2026-11-01'
GROUP BY c.Nombre;

-- EJERCICIO 29: TODAS las estaciones con su cantidad de ventas y total vendido
--               en noviembre 2026. Las que no vendieron deben salir con 0.
--               Ordena por total de mayor a menor.
--   USA: LEFT JOIN con la fecha en el ON, COUNT(v.Id), ISNULL(SUM(v.Total), 0)
--   ESPERADO: 15 filas. Primera Delta Sabanitas (23 | 1432.29),
--             ultima Delta Changuinola (0 | 0.00). Si te salen 14, caiste en la trampa.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 30. SELF JOIN - una tabla unida consigo misma
   QUE ES: cuando una tabla se apunta a si misma (Empleados.JefeId -> Empleados.Id).
           Usas la misma tabla DOS veces con alias distintos.
   --------------------------------------------------------------------- */
SELECT emp.Nombre AS Empleado, jefe.Nombre AS Jefe
FROM Empleados emp
LEFT JOIN Empleados jefe ON jefe.Id = emp.JefeId
WHERE emp.Cargo <> N'Cajero';

-- EJERCICIO 30: Cada cajero con el nombre y el cargo de su jefe.
--               Ordena por jefe y luego por cajero.
--   USA: Empleados emp JOIN Empleados jefe ON jefe.Id = emp.JefeId
--   ESPERADO: 28 filas. Primera: Carlos Rodriguez | Ana Castillo | Supervisor Regional
-- Tu respuesta:




/* #####################################################################
   PARTE 6: SUBCONSULTAS Y CTE
   ##################################################################### */

/* ---------------------------------------------------------------------
   TEMA 31. Subconsulta escalar (devuelve UN valor)
   QUE ES: una consulta dentro de otra, entre parentesis. Si devuelve un
           solo valor, la puedes comparar con > < =.
   --------------------------------------------------------------------- */
SELECT Nombre, Salario
FROM Empleados
WHERE Salario > (SELECT AVG(Salario) FROM Empleados);

-- EJERCICIO 31: Productos cuyo precio es mayor al precio promedio de todos
--               los productos.
--   USA: WHERE PrecioUnitario > (SELECT AVG(...) FROM ...)
--   ESPERADO: 3 filas (los 3 lubricantes/aditivo).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 32. IN con subconsulta
   QUE ES: la subconsulta devuelve una LISTA de valores y IN pregunta si
           el valor esta en esa lista.
   --------------------------------------------------------------------- */
SELECT COUNT(*) AS VentasChiriqui
FROM Ventas
WHERE EstacionId IN (SELECT Id FROM Estaciones WHERE Provincia = N'Chiriquí');

-- EJERCICIO 32: Cuantas ventas se hicieron a clientes de tipo 'Flota'.
--   USA: WHERE ClienteId IN (SELECT Id FROM Clientes WHERE ...)
--   ESPERADO: 1388
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 33. EXISTS / NOT EXISTS
   QUE ES: pregunta "existe al menos una fila que cumpla esto?". La
           subconsulta se conecta con la de afuera (v.EstacionId = e.Id).
           Lo que pongas en el SELECT de adentro da igual: se usa SELECT 1.
   --------------------------------------------------------------------- */
SELECT e.Nombre
FROM Estaciones e
WHERE NOT EXISTS (SELECT 1 FROM Ventas v WHERE v.EstacionId = e.Id);

-- EJERCICIO 33: Clientes de tipo 'Flota' que SI compraron en noviembre 2026.
--   USA: WHERE ... AND EXISTS (SELECT 1 FROM Ventas v WHERE v.ClienteId = c.Id AND fechas)
--   ESPERADO: 14 filas (de los 15 de flota, falta Cooperativa Agricola Herrera).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 34. CTE (WITH) - una subconsulta con nombre
   QUE ES: le pones nombre a una consulta y despues la usas como si fuera
           una tabla. Mas facil de leer que las subconsultas anidadas.
           Vive SOLO para la consulta que va justo despues.
   COMO SE USA:
     WITH NombreCte AS ( SELECT ... )
     SELECT ... FROM NombreCte ...;
   --------------------------------------------------------------------- */
WITH TotalPorEstacion AS (
    SELECT EstacionId, SUM(Total) AS Total
    FROM Ventas
    GROUP BY EstacionId
)
SELECT e.Nombre, t.Total
FROM TotalPorEstacion t
JOIN Estaciones e ON e.Id = t.EstacionId
ORDER BY t.Total DESC;

-- EJERCICIO 34: Clientes cuyo total comprado es MAYOR al promedio de lo que
--               compran los clientes. Muestra nombre y total, de mayor a menor.
--   USA: WITH TotalCliente AS (SELECT ClienteId, SUM(Total) ... GROUP BY ClienteId)
--        y despues comparar con (SELECT AVG(...) FROM TotalCliente)
--   ESPERADO: 9 filas. Primero Agroexport Veraguas (11746.35).
-- Tu respuesta:




/* #####################################################################
   PARTE 7: FUNCIONES DE VENTANA (OVER) - nivel semi-senior
   A diferencia de GROUP BY, NO juntan filas: calculan algo y lo ponen
   AL LADO de cada fila.
   ##################################################################### */

/* ---------------------------------------------------------------------
   TEMA 35. ROW_NUMBER + PARTITION BY ("el ultimo / el mayor de cada uno")
   QUE ES: ROW_NUMBER numera las filas 1, 2, 3... segun un orden.
           PARTITION BY reinicia la numeracion por grupo.
           Despues filtras rn = 1 para quedarte con "el primero de cada grupo".
   COMO SE USA:
     ROW_NUMBER() OVER (PARTITION BY grupo ORDER BY columna DESC) AS rn
   --------------------------------------------------------------------- */
WITH r AS (
    SELECT EstacionId, Id, Total,
           ROW_NUMBER() OVER (PARTITION BY EstacionId ORDER BY Total DESC) AS rn
    FROM Ventas
)
SELECT EstacionId, Id AS VentaId, Total
FROM r
WHERE rn = 1;                 -- la venta mas grande de cada estacion

-- EJERCICIO 35: La ULTIMA compra (la mas reciente) de cada cliente: nombre del
--               cliente, id de venta, fecha y total. Las mas recientes primero.
--   USA: CTE + ROW_NUMBER() OVER (PARTITION BY ClienteId ORDER BY Fecha DESC),
--        WHERE rn = 1, JOIN Clientes
--   ESPERADO: 20 filas. Primera: Mudanzas Express | 5957 | 2026-11-15 21:42
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 36. ROW_NUMBER vs RANK vs DENSE_RANK (empates)
   QUE ES: las tres numeran, cambian en los empates:
     ROW_NUMBER -> 1,2,3,4  (nunca repite)
     RANK       -> 1,2,2,4  (repite y SALTA)
     DENSE_RANK -> 1,2,2,3  (repite SIN saltar)
   --------------------------------------------------------------------- */
SELECT Nombre, LimiteCredito,
       ROW_NUMBER() OVER (ORDER BY LimiteCredito DESC) AS RowNum,
       RANK()       OVER (ORDER BY LimiteCredito DESC) AS Rnk,
       DENSE_RANK() OVER (ORDER BY LimiteCredito DESC) AS DenseRnk
FROM Clientes;

-- EJERCICIO 36: Ranking de los CAJEROS por salario (mayor = puesto 1), donde
--               los que ganan igual comparten puesto y no se salten numeros.
--   USA: DENSE_RANK() OVER (ORDER BY Salario DESC)
--   ESPERADO: 28 filas, puestos del 1 al 5 (850 = 1, ..., 650 = 5).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 37. SUM() OVER () - totales al lado de cada fila / porcentajes
   QUE ES: SUM(x) OVER () = el total general, repetido en cada fila.
           Sirve para calcular "que % del total es esta fila".
           Si ya agrupaste, el total general es SUM(SUM(x)) OVER ().
   --------------------------------------------------------------------- */
SELECT Id, Total, SUM(Total) OVER () AS TotalDeTodas
FROM Ventas
WHERE Id <= 5;

-- EJERCICIO 37: Total vendido por provincia y que porcentaje representa del
--               total general (2 decimales). De mayor a menor.
--   USA: JOIN Estaciones, GROUP BY Provincia,
--        100.0 * SUM(v.Total) / SUM(SUM(v.Total)) OVER (), CAST(... AS DECIMAL(5,2))
--   ESPERADO: 8 filas. Primera: Panama | 94992.53 | 28.93
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 38. LAG / LEAD - la fila anterior / siguiente
   QUE ES: LAG(x) te trae el valor de la fila ANTERIOR, LEAD(x) el de la
           SIGUIENTE, segun el orden que pongas. Ideal para "comparado con
           el mes anterior". La primera fila no tiene anterior -> NULL.
   --------------------------------------------------------------------- */
WITH PorDia AS (
    SELECT CAST(Fecha AS DATE) AS Dia, COUNT(*) AS Ventas
    FROM Ventas
    WHERE Fecha >= '2026-11-01'
    GROUP BY CAST(Fecha AS DATE)
)
SELECT Dia, Ventas, LAG(Ventas) OVER (ORDER BY Dia) AS DiaAnterior
FROM PorDia;

-- EJERCICIO 38: Para la estacion 1 en 2026: ventas por mes (cantidad), las
--               del mes anterior y la diferencia.
--   USA: CTE con GROUP BY MONTH(Fecha), LAG(...) OVER (ORDER BY Mes)
--   ESPERADO: 11 filas. Mes 1: 39 | NULL | NULL ; Mes 2: 37 | 39 | -2
-- Tu respuesta:




/* #####################################################################
   PARTE 8: UNION, MODIFICAR DATOS Y OBJETOS
   ##################################################################### */

/* ---------------------------------------------------------------------
   TEMA 39. UNION / UNION ALL - apilar resultados
   QUE ES: pone el resultado de una consulta DEBAJO de otra. Deben tener
           la misma cantidad de columnas y tipos compatibles.
           UNION quita duplicados (mas lento). UNION ALL deja todo.
   --------------------------------------------------------------------- */
SELECT 'Estacion' AS Tipo, Nombre FROM Estaciones WHERE Provincia = N'Colón'
UNION ALL
SELECT 'Producto', Nombre FROM Productos WHERE Categoria = N'Tienda';

-- EJERCICIO 39: Una sola lista con columna Tipo y Nombre: los supervisores
--               regionales (Tipo 'Supervisor') + los clientes de tipo
--               'Contado' (Tipo 'Cliente contado').
--   USA: UNION ALL
--   ESPERADO: 11 filas (4 supervisores + 7 clientes).
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 40. INSERT, UPDATE, DELETE (dentro de una transaccion)
   QUE ES:
     INSERT INTO Tabla (col1, col2) VALUES (v1, v2);   -> agregar
     UPDATE Tabla SET col = valor WHERE ...;           -> modificar
     DELETE FROM Tabla WHERE ...;                      -> borrar
   UPDATE y DELETE SIEMPRE con WHERE (sin WHERE afecta TODA la tabla).
   BEGIN TRAN ... ROLLBACK deshace todo: practicas sin danar tus datos.
   Selecciona desde BEGIN TRAN hasta ROLLBACK y ejecutalo junto.
   --------------------------------------------------------------------- */
BEGIN TRAN;
    INSERT INTO Productos (Codigo, Nombre, Categoria, Unidad, PrecioUnitario)
    VALUES ('TDA-SODA', N'Soda 600ml', N'Tienda', N'Unidad', 1.100);
    SELECT * FROM Productos WHERE Codigo = 'TDA-SODA';
ROLLBACK;

-- EJERCICIO 40: Dentro de una transaccion:
--   1) Inserta el producto 'TDA-HIELO', 'Bolsa de hielo', 'Tienda', 'Unidad', 2.500
--   2) Subele el precio a 2.750
--   3) Muestralo con un SELECT
--   4) Borralo
--   5) ROLLBACK, y fuera de la transaccion cuenta los productos.
--   USA: BEGIN TRAN, INSERT, UPDATE ... WHERE, SELECT, DELETE ... WHERE, ROLLBACK
--   ESPERADO: el SELECT del paso 3 muestra 2.750 y al final siguen habiendo 9 productos.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 41. TRY / CATCH - manejo de errores en transacciones
   QUE ES: si algo falla dentro del TRY, salta al CATCH. Ahi haces
           ROLLBACK para que sea "todo o nada" (atomicidad, la A de ACID).
     ERROR_NUMBER() / ERROR_MESSAGE() -> que error fue.
   COMO SE USA:
     BEGIN TRY
         BEGIN TRAN;  ...  COMMIT;
     END TRY
     BEGIN CATCH
         IF @@TRANCOUNT > 0 ROLLBACK;
         SELECT ERROR_NUMBER(), ERROR_MESSAGE();
     END CATCH;
   --------------------------------------------------------------------- */
BEGIN TRY
    SELECT 1 / 0 AS Division;          -- error: division entre cero
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Numero, ERROR_MESSAGE() AS Mensaje;
END CATCH;
GO

-- EJERCICIO 41: En una transaccion con TRY/CATCH, intenta insertar una
--               estacion con un Codigo que YA existe (Codigo es UNIQUE).
--               En el CATCH haz ROLLBACK y muestra el numero y el mensaje.
--   USA: BEGIN TRY, BEGIN TRAN, INSERT, COMMIT, BEGIN CATCH, ROLLBACK, ERROR_NUMBER()
--   ESPERADO: error 2627 (Violation of UNIQUE KEY constraint) y Estaciones sigue con 15.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 42. VISTA (VIEW)
   QUE ES: una consulta guardada con nombre. Se usa como si fuera una tabla.
           CREATE debe ser lo primero de su lote: por eso los GO.
   COMO SE USA:
     CREATE OR ALTER VIEW vw_Nombre AS  SELECT ... ;
     GO
     SELECT * FROM vw_Nombre;
   --------------------------------------------------------------------- */
CREATE OR ALTER VIEW vw_EjemploEstaciones AS
SELECT Nombre, Provincia FROM Estaciones WHERE Activa = 1;
GO
SELECT * FROM vw_EjemploEstaciones;
GO
DROP VIEW IF EXISTS vw_EjemploEstaciones;
GO

-- EJERCICIO 42: Crea la vista vw_VentasPorMetodo con: MetodoPago, cantidad
--               de ventas y total. Consultala ordenada por total y luego borrala.
--   USA: CREATE OR ALTER VIEW, GO, SELECT * FROM la vista, DROP VIEW
--   ESPERADO: 4 filas. Primera: Efectivo | 2486 | 124565.73
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 43. STORED PROCEDURE (SP)
   QUE ES: un bloque de codigo guardado que recibe parametros y se
           ejecuta con EXEC. Puede validar, modificar datos, usar
           transacciones. THROW lanza un error hacia la aplicacion.
   COMO SE USA:
     CREATE OR ALTER PROCEDURE sp_Nombre @Param INT AS
     BEGIN
         SET NOCOUNT ON;
         IF @Param <= 0 THROW 50001, 'mensaje', 1;
         SELECT ...;
     END;
     GO
     EXEC sp_Nombre @Param = 5;
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE sp_EjemploVentasEstacion
    @EstacionId INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Estaciones WHERE Id = @EstacionId)
        THROW 50001, 'La estacion no existe', 1;
    SELECT COUNT(*) AS Ventas, SUM(Total) AS Total
    FROM Ventas WHERE EstacionId = @EstacionId;
END;
GO
EXEC sp_EjemploVentasEstacion @EstacionId = 1;
GO
DROP PROCEDURE IF EXISTS sp_EjemploVentasEstacion;
GO

-- EJERCICIO 43: Crea sp_TopProductos que reciba @Top INT y devuelva los @Top
--               productos con mas dinero vendido (suma de Subtotal).
--               Si @Top es 0 o negativo, lanza un error con THROW.
--               Pruebalo con 3 y con 0, y al final borralo.
--   USA: CREATE OR ALTER PROCEDURE, IF ... THROW, SELECT TOP (@Top), EXEC, DROP PROCEDURE
--   ESPERADO: con 3 -> Diesel 94549.32 | Gasolina 95 75700.80 | Diesel Premium 73537.20
--             con 0 -> error 50001.
-- Tu respuesta:



/* ---------------------------------------------------------------------
   TEMA 44. FUNCION ESCALAR
   QUE ES: devuelve UN valor y se usa DENTRO de un SELECT o WHERE.
           A diferencia del SP, NO puede modificar datos.
           Se llama con el esquema adelante: dbo.fn_Nombre(...)
   COMO SE USA:
     CREATE OR ALTER FUNCTION fn_Nombre (@x INT) RETURNS INT AS
     BEGIN RETURN (SELECT ...); END;
   --------------------------------------------------------------------- */
CREATE OR ALTER FUNCTION fn_EjemploDoble (@x INT)
RETURNS INT
AS
BEGIN
    RETURN @x * 2;
END;
GO
SELECT Id, dbo.fn_EjemploDoble(Id) AS Doble FROM Estaciones;
GO
DROP FUNCTION IF EXISTS fn_EjemploDoble;
GO

-- EJERCICIO 44: Crea fn_VentasEstacion(@EstacionId) que devuelva cuantas
--               ventas tiene esa estacion. Usala en un SELECT sobre
--               Estaciones (nombre + ventas, de mas a menos) y luego borrala.
--   USA: CREATE OR ALTER FUNCTION ... RETURNS INT, dbo.fn_VentasEstacion(Id), DROP FUNCTION
--   ESPERADO: 15 filas. Ultima: Delta Changuinola con 0.
-- Tu respuesta:




/* =====================================================================
   FIN. Si sacaste los 44, estas listo para el examen de prueba (ENUNCIADO.md).
   ===================================================================== */
