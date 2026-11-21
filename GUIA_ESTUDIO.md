# Guía Prueba Técnica – Analista Programador (Delta)

Nov 20, 2026 · Versión editable: [Claude Docs](https://claude.ai/artifact/De3rTV9ugEepD9vC1GfDaC)

## 1. .NET / C#

Lo que más evalúan: POO, async/await, LINQ, inyección de dependencias y construir una Web API con EF Core.

| Tema | Lo que debes poder decir en 1 frase |
| --- | --- |
| Encapsulamiento | Ocultar el estado interno y exponerlo solo con propiedades o métodos controlados. |
| Herencia | Una clase reutiliza y extiende otra (`class Camion : Vehiculo`). |
| Polimorfismo | Mismo método, distinto comportamiento según el tipo real (`virtual`/`override`, interfaces). |
| Abstracción | Exponer el qué, no el cómo (interfaces, clases abstractas). |
| interface vs abstract class | Interface = contrato sin estado, se implementan varias. Abstracta = puede tener estado y código base, solo se hereda una. |
| class vs struct | Class = tipo referencia. Struct = tipo valor, se copia. |
| string vs StringBuilder | String es inmutable; para concatenar en bucles usa StringBuilder. |
| async/await | Libera el hilo mientras espera I/O (BD, HTTP). Devuelve `Task<T>`. Nunca `.Result` ni `.Wait()`: causan deadlocks. |
| Ejecución diferida LINQ | La consulta no corre hasta que la recorres (`ToList`, `foreach`, `First`). |
| IEnumerable vs IQueryable | IEnumerable filtra en memoria; IQueryable traduce a SQL y filtra en la BD. |
| Lifetimes de DI | Transient = nueva cada vez. Scoped = una por request (DbContext). Singleton = una para toda la app. |
| Middleware | Pipeline que procesa cada request en orden: auth, logging, errores. |
| Code First vs Database First | Code First: las clases generan la BD con migraciones. Database First: scaffold desde una BD existente. |
| Problema N+1 | Una consulta por cada elemento de una lista. Se arregla con `Include` o proyectando con `Select`. |
| SOLID (S y D) | S: una clase, una responsabilidad. D: depender de interfaces, no de clases concretas (por eso existe DI). |

**Plantilla de endpoint para memorizar:**

```csharp
[ApiController]
[Route("api/[controller]")]
public class ClientesController : ControllerBase
{
    private readonly AppDbContext _db;
    public ClientesController(AppDbContext db) => _db = db;

    [HttpGet("{id}")]
    public async Task<IActionResult> Get(int id)
    {
        var c = await _db.Clientes.FindAsync(id);
        return c is null ? NotFound() : Ok(c);
    }

    [HttpPost]
    public async Task<IActionResult> Create(ClienteDto dto)
    {
        var c = new Cliente { Nombre = dto.Nombre, Email = dto.Email };
        _db.Clientes.Add(c);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Get), new { id = c.Id }, c);
    }
}
```

En `Program.cs`: `builder.Services.AddDbContext<AppDbContext>(o => o.UseSqlServer(cs));` y `builder.Services.AddScoped<IClienteService, ClienteService>();`.

## 2. SQL (SQL Server)

Casi seguro te ponen a escribir queries: domina JOINs, GROUP BY/HAVING y funciones de ventana.

| Tema | Clave |
| --- | --- |
| INNER JOIN | Solo filas que coinciden en ambas tablas. |
| LEFT JOIN | Todo lo de la izquierda; NULL si no hay match. Con `WHERE b.Id IS NULL` encuentras los que no tienen relación. |
| WHERE vs HAVING | WHERE filtra filas antes de agrupar; HAVING filtra grupos después del GROUP BY. |
| Orden lógico | FROM, JOIN, WHERE, GROUP BY, HAVING, SELECT, ORDER BY. Por eso no puedes usar un alias del SELECT en el WHERE. |
| CTE | `WITH x AS (...)` hace legibles las subconsultas; también permite recursión. |
| ROW\_NUMBER / RANK / DENSE\_RANK | ROW\_NUMBER no repite; RANK repite y salta (1,1,3); DENSE\_RANK repite sin saltar (1,1,2). |
| Transacción | `BEGIN TRAN` + `COMMIT` o `ROLLBACK`, dentro de `TRY...CATCH`. ACID: atomicidad, consistencia, aislamiento, durabilidad. |
| Índice clustered | Ordena físicamente la tabla; solo uno (normalmente la PK). |
| Índice non-clustered | Estructura aparte que apunta a las filas; varios. Aceleran lecturas, frenan INSERT/UPDATE. |
| Stored procedure vs función | SP puede modificar datos y devolver varios resultados; una función devuelve un valor o tabla y se usa dentro de un SELECT. |
| DELETE vs TRUNCATE | DELETE borra fila a fila, admite WHERE y dispara triggers; TRUNCATE vacía la tabla entera, más rápido. |
| Normalización | 1FN: valores atómicos. 2FN: sin dependencias parciales de la PK. 3FN: sin dependencias transitivas. |

**Queries clásicas:**

```sql
-- Clientes sin pedidos
SELECT c.* FROM Clientes c
LEFT JOIN Pedidos p ON p.ClienteId = c.Id
WHERE p.Id IS NULL;

-- Duplicados por email
SELECT Email, COUNT(*) AS Veces
FROM Clientes GROUP BY Email HAVING COUNT(*) > 1;

-- Segundo salario más alto
SELECT MAX(Salario) FROM Empleados
WHERE Salario < (SELECT MAX(Salario) FROM Empleados);

-- Mejor venta por estación
WITH v AS (
  SELECT EstacionId, Fecha, Monto,
         ROW_NUMBER() OVER (PARTITION BY EstacionId ORDER BY Monto DESC) AS rn
  FROM Ventas
)
SELECT * FROM v WHERE rn = 1;

-- Acumulado de ventas por día
SELECT Fecha, Monto,
       SUM(Monto) OVER (ORDER BY Fecha) AS Acumulado
FROM Ventas;

-- Stored procedure con transacción
CREATE PROCEDURE sp_RegistrarVenta @EstacionId INT, @Monto DECIMAL(12,2)
AS
BEGIN
  BEGIN TRY
    BEGIN TRAN;
      INSERT INTO Ventas (EstacionId, Fecha, Monto) VALUES (@EstacionId, GETDATE(), @Monto);
      UPDATE Estaciones SET TotalVendido = TotalVendido + @Monto WHERE Id = @EstacionId;
    COMMIT;
  END TRY
  BEGIN CATCH
    ROLLBACK;
    THROW;
  END CATCH
END;
```

## 3. APIs e integración con ERP

La idea central: una integración buena valida, registra todo, reintenta sin duplicar y avisa cuando falla.

| Código HTTP | Significado |
| --- | --- |
| 200 OK | Todo bien, con respuesta. |
| 201 Created | Recurso creado (POST). |
| 204 No Content | Bien, sin cuerpo (DELETE, PUT). |
| 400 Bad Request | Datos inválidos del cliente. |
| 401 Unauthorized | No autenticado (falta o expiró el token). |
| 403 Forbidden | Autenticado pero sin permiso. |
| 404 Not Found | No existe el recurso. |
| 409 Conflict | Choque de estado, por ejemplo un duplicado. |
| 500 Internal Server Error | Falló el servidor. |

- **Verbos:** GET lee, POST crea, PUT reemplaza completo, PATCH actualiza parcial, DELETE borra. GET, PUT y DELETE son idempotentes; POST no.
- **Autenticación:** API Key (simple), Basic (usuario y clave en Base64), OAuth 2.0 (token emitido por un servidor de identidad como Entra ID), JWT (token firmado con header, payload con claims y firma; se valida la firma y la expiración).
- **REST vs SOAP:** REST usa JSON y verbos HTTP; SOAP usa XML con contrato WSDL. Muchos ERP antiguos exponen SOAP.
- **Consumir APIs en .NET:** `IHttpClientFactory` (evita agotar sockets), `GetFromJsonAsync<T>`, `PostAsJsonAsync`, y reintentos con Polly.

```csharp
public class ErpClient(HttpClient http)
{
    public async Task<FacturaDto?> GetFactura(string id) =>
        await http.GetFromJsonAsync<FacturaDto>($"api/facturas/{id}");
}
// Program.cs
builder.Services.AddHttpClient<ErpClient>(c =>
    c.BaseAddress = new Uri(builder.Configuration["Erp:Url"]!));
```

**Formas de integrar con un ERP (SAP, Dynamics 365, etc.):**

1. API REST u OData expuesta por el ERP (SAP Service Layer, Dynamics Web API).
2. Servicios web SOAP.
3. Tablas intermedias (staging) en SQL que el ERP o un job procesa.
4. Archivos planos (CSV, XML) por SFTP, procesados en lote.
5. Middleware o colas (Azure Service Bus, Logic Apps, Power Automate) para desacoplar.

**Buenas prácticas que debes mencionar:** idempotencia (una clave única por transacción para no duplicar facturas), log de cada envío y respuesta, reintentos con espera creciente, mapeo y validación de datos antes de enviar, alertas por correo cuando falla, y credenciales fuera del código (Key Vault o variables de entorno).

## 4. Power Platform (SharePoint, Power Automate, Power Apps)

El caso típico que piden: una lista de SharePoint como datos, una app de Power Apps como formulario y un flujo de Power Automate que aprueba y notifica.

**SharePoint**

- Lista = datos en filas y columnas (texto, número, fecha, elección, persona, lookup). Biblioteca = documentos con metadatos.
- Permisos por sitio, lista o elemento; romper herencia solo si hace falta.
- Límite de vista de 5,000 elementos: indexar columnas que se filtran.

**Power Automate**

| Tipo de flujo | Se dispara cuando |
| --- | --- |
| Automatizado | Ocurre un evento (se crea un elemento, llega un correo). |
| Instantáneo | Alguien pulsa un botón o se llama desde Power Apps. |
| Programado | A una hora fija (todos los días a las 6:00). |
| Escritorio (RPA) | Automatiza una app de escritorio sin API. |

- Acciones clave: Condition, Switch, Apply to each, Start and wait for an approval, Send an email, Update item, HTTP (premium).
- Expresiones: `formatDateTime(utcNow(),'yyyy-MM-dd')`, `concat()`, `triggerOutputs()?['body/Title']`, `outputs('Accion')`.
- Manejo de errores: "Configure run after" (ejecutar si falló) y el patrón Try/Catch con Scopes.
- Conectores estándar (SharePoint, Outlook, Teams) vs premium (SQL Server, HTTP, Dataverse): los premium requieren licencia.

**Power Apps**

| Canvas | Model-driven |
| --- | --- |
| Diseñas la pantalla libremente, pixel a pixel. | La interfaz se genera a partir del modelo de datos. |
| Cualquier fuente: SharePoint, SQL, Excel, Dataverse. | Solo Dataverse. |
| Ideal para apps móviles y formularios simples. | Ideal para procesos complejos tipo CRM. |

- **Delegación:** si una función no se puede delegar a la fuente, Power Apps solo procesa los primeros 500 registros (máximo 2,000). Usar funciones delegables (`Filter` con `=`, `StartsWith`) y columnas indexadas.
- **Power Fx esencial:**

```
Filter(Solicitudes, Estado = "Pendiente" && Solicitante.Email = User().Email)
LookUp(Empleados, Id = 5)
Patch(Solicitudes, Defaults(Solicitudes), {Title: txtTitulo.Text, Monto: Value(txtMonto.Text)})
SubmitForm(frmSolicitud); Navigate(scrExito, ScreenTransition.Fade)
ClearCollect(colCarrito, Productos)
```

## 5. Ejercicios prácticos

Intenta cada uno sin mirar la solución; las soluciones están al final de la sección.

**Esquema para los ejercicios SQL:** `Estaciones(Id, Nombre, Provincia)`, `Productos(Id, Nombre, PrecioLitro)`, `Ventas(Id, EstacionId, ProductoId, Fecha, Litros, Monto)`.

- [ ] **SQL 1.** Total vendido por provincia en 2026, de mayor a menor.
- [ ] **SQL 2.** Estaciones que no vendieron nada en octubre de 2026.
- [ ] **SQL 3.** Producto más vendido (en litros) de cada estación.
- [ ] **SQL 4.** Estaciones cuyas ventas del mes superan el promedio de todas las estaciones.
- [ ] **C# 1.** Dada una lista de ventas, devuelve con LINQ el top 3 de estaciones por monto total.
- [ ] **C# 2.** Escribe un método que diga si una cadena es palíndromo ignorando espacios y mayúsculas.
- [ ] **C# 3.** Haz FizzBuzz del 1 al 100 (sí, todavía lo piden).
- [ ] **C# 4.** Crea un servicio que llame a una API externa de tipo de cambio, con manejo de errores, y regístralo con DI.
- [ ] **Power Platform.** Diseña una solicitud de vacaciones: lista, app y flujo de aprobación con correo al aprobar o rechazar.

### Soluciones

```sql
-- SQL 1
SELECT e.Provincia, SUM(v.Monto) AS Total
FROM Ventas v JOIN Estaciones e ON e.Id = v.EstacionId
WHERE v.Fecha >= '2026-01-01' AND v.Fecha < '2027-01-01'
GROUP BY e.Provincia
ORDER BY Total DESC;

-- SQL 2
SELECT e.* FROM Estaciones e
WHERE NOT EXISTS (
  SELECT 1 FROM Ventas v
  WHERE v.EstacionId = e.Id
    AND v.Fecha >= '2026-10-01' AND v.Fecha < '2026-11-01');

-- SQL 3
WITH t AS (
  SELECT EstacionId, ProductoId, SUM(Litros) AS L,
         RANK() OVER (PARTITION BY EstacionId ORDER BY SUM(Litros) DESC) AS r
  FROM Ventas GROUP BY EstacionId, ProductoId)
SELECT EstacionId, ProductoId, L FROM t WHERE r = 1;

-- SQL 4
WITH m AS (
  SELECT EstacionId, SUM(Monto) AS Total FROM Ventas
  WHERE Fecha >= '2026-10-01' AND Fecha < '2026-11-01'
  GROUP BY EstacionId)
SELECT * FROM m WHERE Total > (SELECT AVG(Total) FROM m);
```

Tip: usar rangos `>=` y `<` en fechas en vez de `YEAR(Fecha) = 2026` permite que SQL use el índice.

```csharp
// C# 1
var top3 = ventas.GroupBy(v => v.EstacionId)
    .Select(g => new { EstacionId = g.Key, Total = g.Sum(v => v.Monto) })
    .OrderByDescending(x => x.Total).Take(3).ToList();

// C# 2
bool EsPalindromo(string s)
{
    var limpio = new string(s.Where(char.IsLetterOrDigit).Select(char.ToLower).ToArray());
    return limpio.SequenceEqual(limpio.Reverse());
}

// C# 3
for (int i = 1; i <= 100; i++)
    Console.WriteLine(i % 15 == 0 ? "FizzBuzz" : i % 3 == 0 ? "Fizz" : i % 5 == 0 ? "Buzz" : i.ToString());

// C# 4
public interface ITipoCambioService { Task<decimal?> ObtenerAsync(string moneda); }

public class TipoCambioService(HttpClient http, ILogger<TipoCambioService> log) : ITipoCambioService
{
    public async Task<decimal?> ObtenerAsync(string moneda)
    {
        try
        {
            var r = await http.GetFromJsonAsync<TasaDto>($"rates/{moneda}");
            return r?.Valor;
        }
        catch (HttpRequestException ex)
        {
            log.LogError(ex, "Fallo consultando tipo de cambio {Moneda}", moneda);
            return null;
        }
    }
}
// Program.cs
builder.Services.AddHttpClient<ITipoCambioService, TipoCambioService>(c =>
    c.BaseAddress = new Uri("https://api.ejemplo.com/"));
```

**Power Platform:** lista `Vacaciones` (Empleado: persona, Desde, Hasta: fecha, Estado: elección Pendiente/Aprobada/Rechazada, Comentario). App Canvas con `EditForm` conectado a la lista y `SubmitForm`. Flujo automatizado "Cuando se crea un elemento": obtener el jefe con Office 365 Users (Get manager), "Start and wait for an approval", condición sobre `Outcome`, "Update item" con el Estado y "Send an email" al empleado.

## 6. Preguntas de entrevista con respuesta modelo

Responde con estructura: definición corta, un ejemplo real y por qué importa.

| Pregunta | Respuesta modelo (resumida) |
| --- | --- |
| ¿Qué diferencia hay entre .NET Framework y .NET (Core)? | Framework es solo Windows y está en mantenimiento; .NET 8/9 es multiplataforma, open source, más rápido y es donde va todo lo nuevo. |
| ¿Cómo proteges una API? | HTTPS, autenticación con JWT u OAuth (Entra ID), autorización por roles, validación de entrada, rate limiting y secretos fuera del código. |
| ¿Cómo evitas SQL injection? | Consultas parametrizadas o EF Core; nunca concatenar texto del usuario en el SQL. |
| Una consulta va lenta, ¿qué haces? | Revisar el plan de ejecución, buscar table scans, crear o ajustar índices, evitar funciones sobre columnas en el WHERE y traer solo las columnas necesarias. |
| ¿Cómo integrarías las ventas de las estaciones con el ERP? | Un servicio recibe o lee las ventas, valida y guarda en staging, envía al ERP por su API con clave de idempotencia, registra la respuesta, reintenta los fallos y alerta si persisten. |
| ¿Qué es la delegación en Power Apps? | Que el filtro lo resuelva la fuente de datos; si no es delegable solo se procesan los primeros 500 a 2,000 registros y los resultados salen incompletos. |
| ¿Cuándo usarías Power Apps en vez de .NET? | Para apps internas de formularios y aprobaciones que se necesitan rápido; .NET cuando hay lógica compleja, mucho volumen, integraciones exigentes o usuarios externos. |
| ¿Cómo manejas errores en un flujo de Power Automate? | Scopes Try/Catch con "Configure run after", registrar el error en una lista y notificar por correo o Teams. |
| ¿Qué haces si un usuario pide algo poco claro? | Reunirme con él, entender el proceso actual y el problema, documentar los requerimientos y criterios de aceptación, y validarlos con un prototipo antes de construir. |
| ¿Cómo depuras un error en producción? | Reproducirlo, revisar logs con el contexto, aislar la causa, corregir en desarrollo con prueba, desplegar y monitorear; después documentar. |
| Git: ¿merge vs rebase? | Merge une ramas con un commit de merge y conserva la historia; rebase reescribe tus commits encima de otra rama para una historia lineal. No hacer rebase de ramas compartidas. |
| Háblame de un proyecto donde integraste sistemas | Usa STAR: Situación, Tarea, Acción (qué hiciste tú y con qué tecnología) y Resultado con un número. |

**Preguntas para hacerles a ellos al final:** qué ERP usan y cómo se integra hoy, cómo es el equipo de TI, qué proyectos tendría el puesto en los primeros 3 meses, y si usan Azure DevOps o GitHub.
