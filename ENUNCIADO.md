# Prueba Técnica — Analista Programador

**Duración:** 2 horas 30 minutos · **Puntaje total:** 100 puntos
**Puedes usar:** documentación oficial de Microsoft (learn.microsoft.com). **No** puedes usar IA.

## Contexto

Una empresa opera una red de **15 estaciones de combustible en Panamá**. Cada venta del punto de venta (POS)
se guarda en SQL Server y luego debe sincronizarse con el **ERP** de la empresa a través de la tabla
intermedia `SincronizacionERP`.

Base de datos: `DeltaPractica` en `localhost\SQLEXPRESS`.

| Tabla | Descripción |
|---|---|
| `Estaciones` | Estaciones de servicio (`Activa = 0` = cerrada) |
| `Productos` | Combustibles (por litro), lubricantes y productos de tienda |
| `Clientes` | Clientes corporativos (`Flota`) y de contado |
| `Empleados` | Gerente, supervisores y cajeros (`JefeId` apunta a otro empleado) |
| `Ventas` | Cabecera de cada venta. `ClienteId NULL` = consumidor final. `ReferenciaExterna` = id único del POS |
| `VentaDetalle` | Líneas de cada venta |
| `SincronizacionERP` | Estado del envío de cada venta al ERP: `Pendiente`, `Enviado`, `Error` |

**Entregables:**
- `respuestas/parte_a.sql` con todas las consultas numeradas.
- El proyecto `api/` funcionando (`dotnet run`).
- `respuestas/parte_c.md` con las respuestas escritas.

---

## Parte A — SQL (40 puntos)

1. **(3 pts)** Lista las estaciones **activas** con su provincia, ordenadas por provincia y nombre.
2. **(4 pts)** Total vendido (`Total`) **por provincia** en octubre de 2026, de mayor a menor.
3. **(4 pts)** Estaciones activas que **no tuvieron ventas** en octubre de 2026.
4. **(4 pts)** Clientes que **nunca han comprado**.
5. **(4 pts)** Correos electrónicos **duplicados** en `Clientes` y cuántas veces aparecen.
6. **(5 pts)** Para **cada estación**, el **producto con más litros vendidos** en 2026 (solo combustibles). Si hay empate, muestra ambos.
7. **(4 pts)** Nombre de cada empleado junto al **nombre de su jefe**. El gerente también debe aparecer (con jefe vacío).
8. **(4 pts)** Ventas **mensuales** de 2026 con una columna de **acumulado** (running total) del año.
9. **(4 pts)** Escribe un stored procedure `sp_ReintentarErroresERP` que pase a `Pendiente` todas las filas en `Error`
   con menos de 5 intentos, sume 1 a `Intentos` y devuelva cuántas filas actualizó. Debe usar **transacción** y **TRY...CATCH**.
10. **(4 pts)** La consulta 2 se ejecuta miles de veces al día y está lenta. Crea el **índice** que la mejoraría y
    explica en un comentario por qué elegiste esas columnas.

## Parte B — Web API en .NET (40 puntos)

En la carpeta `api/` hay un proyecto ASP.NET Core vacío, con la cadena de conexión ya configurada.
Usa **Entity Framework Core**.

1. **(6 pts)** Crea el `DbContext` y las entidades necesarias (puedes usar scaffold o escribirlas a mano).
2. **(5 pts)** `GET /api/estaciones` → estaciones activas (`id`, `codigo`, `nombre`, `provincia`).
3. **(7 pts)** `GET /api/estaciones/{id}/ventas?desde=2026-10-01&hasta=2026-10-31` → ventas de la estación en el rango,
   con `total` y cantidad de ventas. Debe devolver **404** si la estación no existe y **400** si `desde > hasta`.
4. **(7 pts)** `GET /api/reportes/top-productos?anio=2026&top=5` → los N productos con más ingresos (`nombre`, `categoria`, `ingresos`).
5. **(12 pts)** `POST /api/ventas` que registre una venta con sus líneas:
   ```json
   {
     "referenciaExterna": "POS-999001",
     "estacionId": 3,
     "clienteId": null,
     "empleadoId": 8,
     "metodoPago": "Tarjeta",
     "lineas": [ { "productoId": 2, "cantidad": 35.5 }, { "productoId": 8, "cantidad": 2 } ]
   }
   ```
   - El precio se toma de `Productos`, **no** del request. El `Total` se calcula en el servidor.
   - Validaciones con **400**: sin líneas, cantidad ≤ 0, producto/estación/empleado inexistente, estación inactiva.
   - **Idempotencia:** si la `referenciaExterna` ya existe → **409 Conflict** (no duplicar).
   - En la **misma transacción**, crear la fila en `SincronizacionERP` con estado `Pendiente`.
   - Responder **201 Created** con el id de la venta.
6. **(3 pts)** Usa `async/await` en todo y registra tus servicios con inyección de dependencias.

## Parte C — Integración y Power Platform (20 puntos, respuesta escrita)

1. **(8 pts)** Diseña el proceso que toma las ventas `Pendiente` de `SincronizacionERP` y las envía al ERP por su API REST.
   Explica: cada cuánto corre, cómo evitas enviar una venta dos veces, qué haces cuando el ERP no responde,
   cómo se entera TI de los errores y dónde guardas las credenciales del ERP.
2. **(8 pts)** Los supervisores necesitan **aprobar notas de crédito** mayores a $500 a clientes de flota.
   Diseña la solución con **SharePoint + Power Apps + Power Automate**: columnas de la lista, pantallas de la app,
   pasos del flujo (incluye qué pasa si el supervisor no responde en 48 horas).
3. **(4 pts)** En la app de Power Apps, `Filter(NotasCredito, Year(Fecha) = 2026)` devuelve resultados incompletos
   cuando la lista pasa de 2,000 elementos. ¿Por qué pasa y cómo lo arreglas?

---
*Al terminar, avísale a tu evaluador para la revisión.*
