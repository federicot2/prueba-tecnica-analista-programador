/* =====================================================================
   EJERCICIOS DE SQL SERVER - 20 ejercicios + 1 bonus, de facil a dificil
   Base de datos: DeltaPractica

   COMO TRABAJAR:
   - Escribe tu consulta debajo de cada enunciado, seleccionala y F5.
   - Cada ejercicio dice el RESULTADO ESPERADO (cantidad de filas o un dato).
     Si te da igual, vas bien. Si no, revisa antes de mirar la solucion.
   - Si te trabas, vuelve a la leccion indicada en 01_repaso_sql_server.sql.
   - Soluciones en 03_soluciones.sql (solo despues de intentarlo, eh).
   ===================================================================== */
USE DeltaPractica;
GO

/* ===================== NIVEL 1: BASICO (Lecciones 1 y 2) ===================== */

-- 1. Lista los productos de categoria 'Combustible' (nombre y precio),
--    del mas caro al mas barato.
--    Esperado: 4 filas. Primero Gasolina 95 (1.050).



-- 2. Clientes de tipo 'Flota' con limite de credito mayor a 10,000.
--    Muestra nombre y limite, de mayor a menor limite.
--    Esperado: 5 filas. Primero Minera Centro (60,000).



-- 3. Clientes que NO tienen correo registrado (nombre y RUC).
--    Esperado: 3 filas.



-- 4. Estaciones cuyo nombre contiene "Col".
--    Esperado: 1 fila (Delta Colon 2000).



-- 5. Cuantas ventas hubo en noviembre 2026 (usa rango de fechas, no MONTH()).
--    Esperado: 281.



/* ===================== NIVEL 2: FUNCIONES Y AGREGADOS (Lecciones 3 y 4) ===================== */

-- 6. Cuantas estaciones hay por provincia. Ordena de mas a menos.
--    Esperado: 9 filas. Panama con 4.



-- 7. Venta promedio por metodo de pago, redondeada a 2 decimales.
--    Esperado: 4 filas.



-- 8. Lista todos los productos con una columna "Rango":
--    precio menor a 2 = 'Barato', menor a 15 = 'Medio', el resto = 'Caro'.
--    Esperado: 9 filas. 'Caro' solo el aceite sintetico 5W-30.



-- 9. Meses de 2026 (numero de mes) con MAS de 560 ventas.
--    Esperado: 8 filas (meses 1, 3, 4, 5, 6, 7, 8 y 9).



/* ===================== NIVEL 3: JOINs (Leccion 5) ===================== */

-- 10. Ventas del 15 de noviembre 2026 con: id, fecha, total,
--     nombre de la estacion y nombre del cajero. Ordena por fecha.
--     Esperado: 19 filas.



-- 11. Total de litros vendidos por cada producto combustible
--     (VentaDetalle.Cantidad + Productos). De mayor a menor.
--     Esperado: 4 filas. Primero el Diesel.



-- 12. Productos que NUNCA se han vendido.
--     Esperado: 1 fila (Aditivo de motor).



-- 13. Cada supervisor regional y cuantos cajeros tiene a su cargo.
--     Pista: self join de Empleados.
--     Esperado: 4 filas.



-- 14. TODOS los clientes de tipo 'Flota' con su total comprado en 2026.
--     Los que no compraron deben salir con 0.
--     Esperado: 15 filas. Cooperativa Agricola Herrera con 0.
--     (Ojo con la trampa del ON vs WHERE)



/* ===================== NIVEL 4: SUBCONSULTAS Y CTE (Lecciones 6 y 7) ===================== */

-- 15. Empleados que ganan mas que el salario promedio de la empresa.
--     Esperado: 5 filas (el gerente y los 4 supervisores).



-- 16. Estaciones cuyo total vendido en octubre 2026 es mayor al promedio
--     de octubre de todas las estaciones (que vendieron ese mes).
--     Esperado: 5 filas. Primero Delta Tocumen.



-- 17. Ventas que fallaron al sincronizar con el ERP (Estado = 'Error'):
--     id de venta, fecha, estacion, intentos y el error. Las mas recientes primero.
--     Esperado: 60 filas.



/* ===================== NIVEL 5: FUNCIONES DE VENTANA (Leccion 8) ===================== */

-- 18. Las 3 ventas mas grandes de CADA provincia (provincia, id de venta, total, puesto).
--     Pista: ROW_NUMBER + PARTITION BY.
--     Esperado: 24 filas (8 provincias con ventas x 3).



-- 19. Ranking de estaciones por total vendido en 2026 usando DENSE_RANK.
--     Esperado: 14 filas.



-- 20. Ventas por mes de 2026 con: total del mes, acumulado del anio
--     y diferencia contra el mes anterior.
--     Pista: CTE + SUM() OVER + LAG.
--     Esperado: 11 filas. El mes 1 tiene la diferencia en NULL.



/* ===================== BONUS: STORED PROCEDURE (Leccion 12) ===================== */

-- 21. Crea sp_ResumenCliente que reciba @ClienteId y devuelva:
--     nombre, cantidad de compras, total comprado y fecha de la ultima compra.
--     - Si el cliente no existe, lanza un error con THROW.
--     - Si existe pero nunca compro, debe salir con 0 compras y total 0.
--     Prueba con: EXEC sp_ResumenCliente 1;  EXEC sp_ResumenCliente 21;  EXEC sp_ResumenCliente 999;
--     Al terminar: DROP PROCEDURE sp_ResumenCliente;


