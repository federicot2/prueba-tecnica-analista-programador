# Guía: cómo hacer una API REST en C# (ASP.NET Core + EF Core)

Esta guía explica **desde cero** cómo se arma una API REST en .NET: qué es cada pieza, qué hace y cómo se prueba.
Al final tienes un **CRUD completo de Productos** (listar, ver, crear, editar, borrar) contra la base `DeltaPractica`, ya probado.

> Para verla bonita en VS Code: `Ctrl + Shift + V`.

**Índice**
1. [Qué es una API REST](#1-qué-es-una-api-rest)
2. [Cómo viaja una petición](#2-cómo-viaja-una-petición-request--response)
3. [Crear el proyecto](#3-crear-el-proyecto)
4. [Program.cs: el arranque](#4-programcs-el-arranque-de-la-api)
5. [El controller](#5-el-controller-donde-viven-los-endpoints)
6. [Recibir datos: ruta, query y body](#6-recibir-datos-ruta-query-string-y-body)
7. [Responder: códigos de estado](#7-responder-códigos-de-estado)
8. [DTOs](#8-dtos-lo-que-entra-y-sale)
9. [Conectar a SQL Server con EF Core](#9-conectar-a-sql-server-con-ef-core)
10. [CRUD completo de Productos](#10-crud-completo-de-productos-el-ejemplo-entero)
11. [async / await](#11-async--await-por-qué-todo-lleva-await)
12. [Inyección de dependencias](#12-inyección-de-dependencias-di)
13. [Cómo probar la API](#13-cómo-probar-la-api)
14. [Errores comunes](#14-errores-comunes-y-cómo-arreglarlos)
15. [Cómo explicarlo en la entrevista](#15-cómo-explicarlo-en-la-entrevista)
16. [Ejercicio final](#16-ejercicio-final-crud-de-estaciones)

---

## 1. Qué es una API REST

**Qué es:** una API es un programa que **no tiene pantalla**. Otro programa (una app, Power Automate, el ERP, una página web) le manda una **petición** por HTTP y la API **responde con datos**, casi siempre en **JSON**.

**Analogía:** la API es el **mesero** de un restaurante.
- El cliente (la app) no entra a la cocina (la base de datos).
- Le pide al mesero: *"tráeme el producto 5"*.
- El mesero va a la cocina, trae el plato y se lo entrega en un formato que el cliente entiende (JSON).

**REST** es la forma estándar de diseñar esa API:
- Cada cosa es un **recurso** con su URL: `/api/productos`, `/api/productos/5`.
- Lo que quieres hacer lo dice el **verbo HTTP**:

| Verbo | Qué hace | Ejemplo | SQL equivalente |
|---|---|---|---|
| `GET` | Leer | `GET /api/productos/5` | `SELECT` |
| `POST` | Crear | `POST /api/productos` | `INSERT` |
| `PUT` | Reemplazar / editar | `PUT /api/productos/5` | `UPDATE` |
| `PATCH` | Editar solo una parte | `PATCH /api/productos/5` | `UPDATE` de una columna |
| `DELETE` | Borrar | `DELETE /api/productos/5` | `DELETE` |

> **Regla de oro:** la URL dice **QUÉ** (sustantivo, en plural), el verbo dice **QUÉ HACER**.
> ✅ `DELETE /api/productos/5`  ❌ `GET /api/borrarProducto?id=5`

---

## 2. Cómo viaja una petición (request → response)

Una **petición** (request) tiene 4 partes:
```
POST http://localhost:5100/api/productos        <- verbo + URL
Content-Type: application/json                   <- headers (info extra)

{ "codigo": "TDA-HIELO", "nombre": "Bolsa de hielo", "precioUnitario": 2.5 }   <- body (los datos)
```

Una **respuesta** (response) tiene 3 partes:
```
HTTP/1.1 201 Created                             <- código de estado
Location: http://localhost:5100/api/productos/19 <- headers
                                                 
{ "id": 19, "codigo": "TDA-HIELO", ... }         <- body (JSON)
```

**Qué pasa por dentro de tu API cuando llega esa petición:**
```
Petición HTTP
   │
   ▼
Program.cs (pipeline)  ──> busca qué controller atiende esa URL + verbo  (routing)
   │
   ▼
Controller (ProductosController.Crear)
   │   1. valida los datos          -> si están mal: 400
   │   2. usa el DbContext          -> EF Core genera el SQL
   ▼
SQL Server (tabla Productos)
   │
   ▼
Controller arma la respuesta (DTO) -> 201 + JSON
```

---

## 3. Crear el proyecto

En la terminal de VS Code:
```
dotnet new webapi --use-controllers -o MiApi
cd MiApi
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet run
```

| Comando | Qué hace |
|---|---|
| `dotnet new webapi --use-controllers -o MiApi` | Crea una API con controllers en la carpeta `MiApi` |
| `dotnet add package ...SqlServer` | Instala EF Core para hablar con SQL Server |
| `dotnet run` | Compila y levanta la API. La terminal te dice la URL: `Now listening on: http://localhost:5xxx` |

> La plantilla trae un ejemplo `WeatherForecastController` (el clima). Bórralo, no sirve para nada.
> En tu práctica **no necesitas crear nada**: la carpeta `Api/` ya está creada y conectada (puerto 5100).

**Estructura que vas a usar:**
```
MiApi/
├── Program.cs              <- arranque: registra servicios y levanta la API
├── appsettings.json        <- configuración (la cadena de conexión a SQL)
├── Models/                 <- entidades: una clase por tabla
├── Data/DeltaContext.cs    <- el DbContext: la puerta a la base de datos
├── Dtos/                   <- lo que entra y sale por la API
└── Controllers/            <- los endpoints
```

---

## 4. Program.cs: el arranque de la API

```csharp
using Microsoft.EntityFrameworkCore;
using PracticaApi.Data;

var builder = WebApplication.CreateBuilder(args);        // 1. crea el "constructor" de la app

// 2. REGISTRAR SERVICIOS (lo que la app va a poder usar)
builder.Services.AddControllers();                       //    activa los controllers
builder.Services.AddDbContext<DeltaContext>(options =>   //    registra el DbContext
    options.UseSqlServer(builder.Configuration.GetConnectionString("DeltaDb")));

var app = builder.Build();                               // 3. construye la app

// 4. PIPELINE (por dónde pasa cada petición)
app.MapControllers();                                    //    conecta las URLs con los controllers

app.Run();                                               // 5. arranca y se queda escuchando
```

**Qué hace cada parte:**
- **Antes de `Build()`** → registras **servicios** (`builder.Services.Add...`). Es como decirle: *"cuando alguien pida un DeltaContext, sabes cómo crearlo"*.
- **Después de `Build()`** → armas el **pipeline** (`app.Use...` / `app.Map...`): los pasos por los que pasa cada request (HTTPS, autenticación, controllers...).
- `GetConnectionString("DeltaDb")` lee esto de **appsettings.json**:
```json
{
  "ConnectionStrings": {
    "DeltaDb": "Server=localhost\\SQLEXPRESS;Database=DeltaPractica;Trusted_Connection=True;TrustServerCertificate=True"
  }
}
```

> Si te olvidas de `AddControllers()` o `MapControllers()`, todas las URLs dan **404**.

---

## 5. El controller: donde viven los endpoints

**Qué es:** una clase que agrupa los endpoints de un recurso. Cada **método** público = un **endpoint** (una URL + un verbo).

```csharp
using Microsoft.AspNetCore.Mvc;

namespace PracticaApi.Controllers;

[ApiController]                       // activa validaciones automáticas y lectura del JSON
[Route("api/saludo")]                 // URL base de este controller
public class SaludoController : ControllerBase     // ControllerBase te da Ok(), NotFound(), etc.
{
    [HttpGet]                         // GET /api/saludo
    public IActionResult Hola()
    {
        return Ok(new { mensaje = "Hola desde la API" });   // 200 + JSON
    }

    [HttpGet("{nombre}")]             // GET /api/saludo/Ana
    public IActionResult HolaA(string nombre)
    {
        return Ok(new { mensaje = $"Hola, {nombre}" });
    }
}
```

| Pieza | Qué hace |
|---|---|
| `[ApiController]` | Lee el JSON del body solo, y si viene mal devuelve 400 automático |
| `[Route("api/saludo")]` | Prefijo de la URL para todo el controller |
| `: ControllerBase` | Hereda los métodos de respuesta: `Ok`, `NotFound`, `BadRequest`... |
| `[HttpGet]`, `[HttpPost]`, `[HttpPut("{id}")]`, `[HttpDelete("{id}")]` | Qué verbo y qué parte de la URL atiende el método |
| `IActionResult` | "Devuelvo una respuesta HTTP" (cualquier código) |
| `new { mensaje = ... }` | Objeto anónimo: se convierte a JSON `{"mensaje":"..."}` |

> **El nombre de la clase debe terminar en `Controller`** y el archivo va en `Controllers/`. Un archivo por controller.
> El JSON sale en **camelCase** automáticamente: la propiedad `PrecioUnitario` sale como `"precioUnitario"`.

---

## 6. Recibir datos: ruta, query string y body

Hay 3 lugares de donde la API saca los datos:

```csharp
[ApiController]
[Route("api/ejemplos")]
public class EjemplosController : ControllerBase
{
    // 1) RUTA: va dentro de la URL. Para identificar UN recurso (el id).
    //    GET /api/ejemplos/doble/21
    [HttpGet("doble/{numero:int}")]                 // :int = solo acepta números
    public IActionResult Doble(int numero) => Ok(new { numero, doble = numero * 2 });

    // 2) QUERY STRING: después del ?. Para FILTROS u opciones.
    //    GET /api/ejemplos/repetir?texto=hola&veces=3
    [HttpGet("repetir")]
    public IActionResult Repetir([FromQuery] string texto, [FromQuery] int veces = 2)
        => Ok(new { resultado = string.Concat(Enumerable.Repeat(texto, veces)) });

    // 3) BODY: JSON dentro de la petición. Para CREAR o EDITAR (POST/PUT).
    //    POST /api/ejemplos/eco   con body { "mensaje": "probando" }
    [HttpPost("eco")]
    public IActionResult Eco([FromBody] EcoRequest req)
        => Ok(new { recibido = req.Mensaje, largo = req.Mensaje.Length });
}

public record EcoRequest(string Mensaje);           // el JSON se convierte a este record
```

| De dónde | Atributo | Cuándo usarlo | Ejemplo |
|---|---|---|---|
| Ruta | `[FromRoute]` (implícito si está en `{}`) | El id del recurso | `/api/productos/5` |
| Query | `[FromQuery]` | Filtros, búsquedas, paginación | `/api/productos?categoria=Tienda` |
| Body | `[FromBody]` | Datos para crear/editar | `{ "nombre": "..." }` |

> El nombre del parámetro **debe coincidir**: `{numero}` en la ruta ↔ `int numero` en el método. En el JSON no importan mayúsculas: `"mensaje"` llena `Mensaje`.
> Estos ejemplos ya están funcionando en `Api/Controllers/EjemplosController.cs`.

---

## 7. Responder: códigos de estado

El código le dice al cliente **qué pasó**, sin tener que leer el mensaje. Es lo que más preguntan.

| Código | Método en C# | Cuándo |
|---|---|---|
| **200 OK** | `Ok(datos)` | Todo bien, aquí están los datos (GET, PUT) |
| **201 Created** | `CreatedAtAction(...)` | Se creó algo nuevo (POST) |
| **204 No Content** | `NoContent()` | Todo bien pero no hay nada que devolver (DELETE) |
| **400 Bad Request** | `BadRequest(...)` | El cliente mandó datos inválidos (precio 0, falta el nombre) |
| **401 Unauthorized** | `Unauthorized()` | No sé quién eres (falta token / login) |
| **403 Forbidden** | `Forbid()` | Sé quién eres, pero no tienes permiso |
| **404 Not Found** | `NotFound(...)` | No existe (producto 99) |
| **409 Conflict** | `Conflict(...)` | Choca con lo que ya existe (código repetido, tiene ventas) |
| **500 Internal Server Error** | (automático si hay excepción) | Se cayó tu código. **Nunca** lo devuelvas a propósito |

**Truco para recordarlo:** 2xx = salió bien · 4xx = **el cliente** se equivocó · 5xx = **el servidor** se equivocó.

```csharp
[HttpGet("edad/{edad:int}")]
public IActionResult Edad(int edad)
{
    if (edad < 0)
        return BadRequest(new { mensaje = "La edad no puede ser negativa" });   // 400

    return Ok(new { edad, mayorDeEdad = edad >= 18 });                        // 200
}
```

> **Patrón:** primero los `return` de error (validaciones), y al final el `return Ok(...)`. Se llama *guard clauses* y hace el código fácil de leer.

---

## 8. DTOs: lo que entra y sale

**Qué es:** un **DTO** (*Data Transfer Object*) es una clase pequeña (casi siempre un `record`) que define **exactamente** qué datos entran o salen por la API.

**Por qué no devolver la entidad directo:**
1. **Seguridad:** la entidad puede tener columnas que no quieres mostrar (contraseña, costo interno).
2. **Contrato estable:** si cambias la tabla, la API no cambia para quien la usa.
3. **Ciclos:** `Estacion` tiene `Ventas`, y cada `Venta` tiene `Estacion`... el JSON se vuelve infinito y explota.
4. **Validación:** en el POST no quieres que el cliente mande el `Id`; SQL lo genera.

```csharp
// SALIDA: lo que devuelve el GET
public record ProductoDto(int Id, string Codigo, string Nombre, string Categoria, decimal PrecioUnitario);

// ENTRADA del POST: sin Id (lo genera SQL)
public record CrearProductoRequest(string Codigo, string Nombre, string Categoria, string Unidad, decimal PrecioUnitario);

// ENTRADA del PUT: sin Id (viene en la URL) y sin Codigo (no se puede cambiar)
public record ActualizarProductoRequest(string Nombre, string Categoria, string Unidad, decimal PrecioUnitario);
```

---

## 9. Conectar a SQL Server con EF Core

**Qué es EF Core:** un **ORM**. Tú escribes C# con LINQ y él **genera el SQL** por ti:
```csharp
db.Productos.Where(p => p.Categoria == "Tienda").ToListAsync()
// EF genera:  SELECT ... FROM Productos WHERE Categoria = N'Tienda'
```
> En tu `Api/` el SQL que genera EF sale en la terminal. Míralo, ayuda mucho a entender.

Necesitas 3 piezas:

**9.1 La entidad** (`Models/Producto.cs`): una clase = una tabla, una propiedad = una columna.
```csharp
namespace PracticaApi.Models;

public class Producto
{
    public int Id { get; set; }                       // "Id" = llave primaria (EF lo sabe solo)
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Categoria { get; set; } = "";
    public string Unidad { get; set; } = "";
    public decimal PrecioUnitario { get; set; }       // dinero = decimal
}
```
> `= "";` evita los avisos de nulos. Si una columna acepta NULL usa `?`: `int? ClienteId`.

**9.2 El DbContext** (`Data/DeltaContext.cs`): la puerta a la base. Un `DbSet` por tabla.
```csharp
using Microsoft.EntityFrameworkCore;
using PracticaApi.Models;

namespace PracticaApi.Data;

public class DeltaContext(DbContextOptions<DeltaContext> options) : DbContext(options)
{
    public DbSet<Estacion> Estaciones => Set<Estacion>();
    public DbSet<Producto> Productos => Set<Producto>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Producto>().ToTable("Productos");
        modelBuilder.Entity<Producto>().Property(p => p.PrecioUnitario).HasPrecision(10, 3);  // igual que DECIMAL(10,3) en SQL
    }
}
```

**9.3 Registrarlo** en `Program.cs` (ya lo viste en el punto 4): `builder.Services.AddDbContext<DeltaContext>(...)`.

**Las operaciones de EF que vas a usar:**

| C# | Qué hace | SQL |
|---|---|---|
| `await db.Productos.ToListAsync()` | Trae todos | `SELECT *` |
| `await db.Productos.FindAsync(id)` | Busca por llave primaria (o `null`) | `SELECT ... WHERE Id = @id` |
| `.Where(p => ...)` | Filtra | `WHERE` |
| `.OrderBy(p => p.Nombre)` | Ordena | `ORDER BY` |
| `.Select(p => new Dto(...))` | Elige columnas | `SELECT col1, col2` |
| `await ...AnyAsync(p => ...)` | ¿Existe alguno? | `SELECT CASE WHEN EXISTS(...)` |
| `db.Productos.Add(x)` | Marca para insertar | (nada todavía) |
| `db.Productos.Remove(x)` | Marca para borrar | (nada todavía) |
| cambiar `x.Nombre = ...` | EF detecta el cambio solo | (nada todavía) |
| `await db.SaveChangesAsync()` | **Ejecuta** todo lo marcado, en una transacción | `INSERT` / `UPDATE` / `DELETE` |

> **Clave:** `Add`, `Remove` y cambiar propiedades **no tocan la base**. Solo `SaveChangesAsync()` lo hace, y todo junto en **una transacción**: o se guarda todo, o nada.

---

## 10. CRUD completo de Productos (el ejemplo entero)

**CRUD** = **C**reate, **R**ead, **U**pdate, **D**elete. Es lo que hace el 90% de las APIs.
Este controller está **probado contra tu base**. Va en `Controllers/ProductosController.cs` (necesitas la entidad `Producto` y el `DbSet` del punto 9).

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PracticaApi.Data;
using PracticaApi.Models;

namespace PracticaApi.Controllers;

[ApiController]
[Route("api/productos")]
public class ProductosController(DeltaContext db) : ControllerBase   // <- DI: .NET te pasa el DbContext
{
    // ============ READ: listar (con filtro opcional) ============
    // GET /api/productos              GET /api/productos?categoria=Lubricante
    [HttpGet]
    public async Task<IActionResult> Listar([FromQuery] string? categoria)
    {
        IQueryable<Producto> query = db.Productos;          // todavía NO va a la base

        if (!string.IsNullOrWhiteSpace(categoria))
            query = query.Where(p => p.Categoria == categoria);   // se agrega el WHERE

        var lista = await query
            .OrderBy(p => p.Id)
            .Select(p => new ProductoDto(p.Id, p.Codigo, p.Nombre, p.Categoria, p.PrecioUnitario))
            .ToListAsync();                                  // AQUÍ se ejecuta el SELECT

        return Ok(lista);                                    // 200 + lista en JSON
    }

    // ============ READ: uno por id ============
    // GET /api/productos/5
    [HttpGet("{id:int}")]
    public async Task<IActionResult> Obtener(int id)
    {
        var p = await db.Productos.FindAsync(id);
        if (p is null)
            return NotFound(new { mensaje = $"No existe el producto {id}" });   // 404

        return Ok(new ProductoDto(p.Id, p.Codigo, p.Nombre, p.Categoria, p.PrecioUnitario));
    }

    // ============ CREATE ============
    // POST /api/productos   (body: CrearProductoRequest)
    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] CrearProductoRequest req)
    {
        // 1. validar -> 400
        if (string.IsNullOrWhiteSpace(req.Codigo) || string.IsNullOrWhiteSpace(req.Nombre))
            return BadRequest(new { mensaje = "Codigo y nombre son obligatorios" });

        if (req.PrecioUnitario <= 0)
            return BadRequest(new { mensaje = "El precio debe ser mayor a 0" });

        // 2. ¿ya existe? -> 409
        if (await db.Productos.AnyAsync(p => p.Codigo == req.Codigo))
            return Conflict(new { mensaje = $"Ya existe un producto con codigo {req.Codigo}" });

        // 3. DTO -> entidad
        var producto = new Producto
        {
            Codigo = req.Codigo,
            Nombre = req.Nombre,
            Categoria = req.Categoria,
            Unidad = req.Unidad,
            PrecioUnitario = req.PrecioUnitario
        };

        // 4. guardar
        db.Productos.Add(producto);
        await db.SaveChangesAsync();                         // INSERT; SQL genera el Id y EF lo pone en producto.Id

        // 5. responder 201 + header Location con la URL del nuevo producto
        var dto = new ProductoDto(producto.Id, producto.Codigo, producto.Nombre,
                                  producto.Categoria, producto.PrecioUnitario);
        return CreatedAtAction(nameof(Obtener), new { id = producto.Id }, dto);
    }

    // ============ UPDATE ============
    // PUT /api/productos/10   (body: ActualizarProductoRequest)
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarProductoRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Nombre))
            return BadRequest(new { mensaje = "El nombre es obligatorio" });

        if (req.PrecioUnitario <= 0)
            return BadRequest(new { mensaje = "El precio debe ser mayor a 0" });

        var producto = await db.Productos.FindAsync(id);     // 1. buscarlo
        if (producto is null)
            return NotFound(new { mensaje = $"No existe el producto {id}" });

        producto.Nombre = req.Nombre;                        // 2. cambiarle los datos
        producto.Categoria = req.Categoria;                  //    (EF anota qué cambió)
        producto.Unidad = req.Unidad;
        producto.PrecioUnitario = req.PrecioUnitario;

        await db.SaveChangesAsync();                         // 3. UPDATE solo de lo que cambió

        return Ok(new ProductoDto(producto.Id, producto.Codigo, producto.Nombre,
                                  producto.Categoria, producto.PrecioUnitario));
    }

    // ============ DELETE ============
    // DELETE /api/productos/10
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Eliminar(int id)
    {
        var producto = await db.Productos.FindAsync(id);
        if (producto is null)
            return NotFound(new { mensaje = $"No existe el producto {id}" });

        db.Productos.Remove(producto);

        try
        {
            await db.SaveChangesAsync();                     // DELETE
        }
        catch (DbUpdateException)                            // la FK de VentaDetalle no deja borrarlo
        {
            return Conflict(new { mensaje = "No se puede borrar: el producto tiene ventas" });
        }

        return NoContent();                                  // 204: borrado, no hay nada que devolver
    }
}

// DTOs (puedes ponerlos aquí o en Dtos/Dtos.cs)
public record ProductoDto(int Id, string Codigo, string Nombre, string Categoria, decimal PrecioUnitario);
public record CrearProductoRequest(string Codigo, string Nombre, string Categoria, string Unidad, decimal PrecioUnitario);
public record ActualizarProductoRequest(string Nombre, string Categoria, string Unidad, decimal PrecioUnitario);
```

**Resumen de lo que hace cada endpoint:**

| Endpoint | Pasos | Respuestas posibles |
|---|---|---|
| `GET /api/productos` | filtrar → ordenar → DTO → lista | 200 |
| `GET /api/productos/{id}` | buscar → DTO | 200 / 404 |
| `POST /api/productos` | validar → ¿existe? → crear → guardar | 201 / 400 / 409 |
| `PUT /api/productos/{id}` | validar → buscar → cambiar → guardar | 200 / 400 / 404 |
| `DELETE /api/productos/{id}` | buscar → borrar → guardar | 204 / 404 / 409 |

> **Ojo:** el producto `TDA-AGUA` (Id 7) **ya existe** en la base. Para probar el POST usa un código nuevo como `TDA-HIELO`.
> No le hagas PUT ni DELETE a los productos 1 a 9: son los datos originales y los ejercicios de SQL dependen de ellos. Prueba siempre con el que creaste.

---

## 11. async / await: por qué todo lleva `await`

**Qué es:** cuando la API va a la base de datos, **espera** la respuesta. Con `async/await`, mientras espera, el hilo queda **libre para atender otras peticiones**. Sin eso, cada petición bloquea un hilo y con mucha gente la API se pone lenta.

```csharp
public async Task<IActionResult> Obtener(int id)      // 1. async + Task<...>
{
    var p = await db.Productos.FindAsync(id);        // 2. await en todo lo que vaya a la base
    ...
}
```

**Reglas:**
- Todo lo que tenga `Async` al final (`ToListAsync`, `FindAsync`, `SaveChangesAsync`) lleva `await`.
- Si el método usa `await`, se declara `async Task<IActionResult>`.
- ❌ Nunca uses `.Result` o `.Wait()`: bloquea el hilo y puede congelar la app.
- Si te olvidas del `await`, compila pero te devuelve un `Task` en vez del dato, o la base se usa en dos lugares a la vez y explota.

---

## 12. Inyección de dependencias (DI)

**Qué es:** en vez de que el controller haga `new DeltaContext(...)`, **se lo pide** en el constructor y .NET se lo entrega. Tú lo registraste en `Program.cs` (`AddDbContext`), y .NET lo crea cuando hace falta.

```csharp
public class ProductosController(DeltaContext db) : ControllerBase   // "necesito un DeltaContext"
```
> Esa forma `class X(DeltaContext db)` es un **constructor primario**. Es lo mismo que escribir el constructor a mano y guardar `db` en un campo.

**Por qué es bueno:**
- El controller no sabe **cómo** se crea la conexión: solo la usa.
- En los tests puedes pasarle una base falsa.
- .NET controla **cuánto vive** cada objeto.

**Los 3 ciclos de vida (pregunta clásica):**

| Registro | Cuánto vive | Ejemplo típico |
|---|---|---|
| `AddSingleton<T>()` | **Una** instancia para toda la app, mientras esté prendida | Configuración, caché |
| `AddScoped<T>()` | **Una por petición** HTTP | **DbContext** (`AddDbContext` lo registra Scoped) |
| `AddTransient<T>()` | **Una nueva cada vez** que alguien la pide | Servicios livianos sin estado |

**Si la lógica crece, se pasa a un servicio:**
```csharp
// Services/IItbmsService.cs
public interface IItbmsService { decimal ConItbms(decimal monto); }
public class ItbmsService : IItbmsService
{
    public decimal ConItbms(decimal monto) => Math.Round(monto * 1.07m, 2);
}

// Program.cs
builder.Services.AddScoped<IItbmsService, ItbmsService>();   // "cuando pidan IItbmsService, da un ItbmsService"

// En cualquier controller
public class CalculadoraController(IItbmsService itbms) : ControllerBase { ... }
```
> El controller depende de la **interfaz**, no de la clase. Mañana cambias `ItbmsService` y el controller ni se entera.

---

## 13. Cómo probar la API

Primero levántala **en una terminal** y déjala corriendo:
```
cd C:\Users\Federico\OneDrive\Desktop\PruebaTecnicaDelta\practica-csharp\Api
dotnet run
```
Espera a ver `Now listening on: http://localhost:5100`. **Si cambias el código**, para la API con `Ctrl + C` y vuelve a hacer `dotnet run`.

**Opción A: archivo `.http` en VS Code (recomendado)**
1. Instala la extensión **REST Client** (de Huachao Mao).
2. Abre `Api/PracticaApi.http` y haz clic en **Send Request** encima de cada petición.
3. La respuesta sale a la derecha, con el código y el JSON.

Pega esto al final de tu `PracticaApi.http` para probar el CRUD:
```http
### CRUD 1. Listar -> 200, 9 productos
GET {{host}}/api/productos

### CRUD 2. Filtrar -> 200, 3 lubricantes
GET {{host}}/api/productos?categoria=Lubricante

### CRUD 3. Uno -> 200, Lubricante 20W-50 1qt
GET {{host}}/api/productos/5

### CRUD 4. No existe -> 404
GET {{host}}/api/productos/99

### CRUD 5. Crear -> 201 (mira el header Location: ahí está el Id nuevo)
POST {{host}}/api/productos
Content-Type: application/json

{ "codigo": "TDA-HIELO", "nombre": "Bolsa de hielo", "categoria": "Tienda", "unidad": "Unidad", "precioUnitario": 2.5 }

### CRUD 6. Crear repetido -> 409
POST {{host}}/api/productos
Content-Type: application/json

{ "codigo": "TDA-HIELO", "nombre": "Otra", "categoria": "Tienda", "unidad": "Unidad", "precioUnitario": 2.5 }

### CRUD 7. Editar -> 200 (CAMBIA el 19 por el Id que te dio el paso 5)
PUT {{host}}/api/productos/19
Content-Type: application/json

{ "nombre": "Bolsa de hielo 5kg", "categoria": "Tienda", "unidad": "Unidad", "precioUnitario": 3 }

### CRUD 8. Borrar uno con ventas -> 409
DELETE {{host}}/api/productos/1

### CRUD 9. Borrar -> 204 (CAMBIA el 19 por tu Id). Mándalo 2 veces: la segunda da 404
DELETE {{host}}/api/productos/19
```

**Resultados que obtuve yo** (tu Id puede ser otro, porque SQL nunca reusa un Id):
```
GET    /api/productos/5    -> 200 {"id":5,"codigo":"LUB-2050","nombre":"Lubricante 20W-50 1qt","categoria":"Lubricante","precioUnitario":12.500}
GET    /api/productos/99   -> 404 {"mensaje":"No existe el producto 99"}
POST   /api/productos      -> 201 Location: http://localhost:5100/api/productos/19
                                  {"id":19,"codigo":"TDA-HIELO","nombre":"Bolsa de hielo","categoria":"Tienda","precioUnitario":2.5}
POST   (repetido)          -> 409 {"mensaje":"Ya existe un producto con codigo TDA-HIELO"}
PUT    /api/productos/19   -> 200 {"id":19,...,"nombre":"Bolsa de hielo 5kg",...,"precioUnitario":3}
DELETE /api/productos/1    -> 409 {"mensaje":"No se puede borrar: el producto tiene ventas"}
DELETE /api/productos/19   -> 204 (sin body)
DELETE (otra vez)          -> 404
```

**Opción B: el navegador.** Solo sirve para **GET**: abre `http://localhost:5100/api/productos`.

**Opción C: Postman.** Igual que el `.http`: eliges el verbo, pones la URL, y en **Body → raw → JSON** pegas el JSON.

**Opción D: curl** (en la terminal):
```
curl http://localhost:5100/api/productos/5
curl -X POST http://localhost:5100/api/productos -H "Content-Type: application/json" -d "{\"codigo\":\"TDA-X\",\"nombre\":\"X\",\"categoria\":\"Tienda\",\"unidad\":\"Unidad\",\"precioUnitario\":1}"
```

> Al terminar, deja la base como estaba (en SSMS): `DELETE FROM Productos WHERE Id > 9;`

---

## 14. Errores comunes y cómo arreglarlos

| Lo que ves | Por qué pasa | Arreglo |
|---|---|---|
| **404** en una URL que sí programaste | El `[Route]` no coincide, la clase no termina en `Controller`, o no reiniciaste la API | Revisa la ruta y haz `Ctrl+C` + `dotnet run` |
| **405 Method Not Allowed** | La URL existe pero con otro verbo (mandaste POST y es GET) | Revisa `[HttpGet]` / `[HttpPost]` |
| **415 Unsupported Media Type** | Falta el header `Content-Type: application/json` | Agrégalo en la petición |
| **400** con `"errors": {...}` que no programaste | `[ApiController]` no pudo leer el JSON (falta el body, o un texto donde va número) | Revisa el JSON |
| **500** | Excepción en tu código. El detalle sale en la **terminal** donde corre la API | Lee el error en la terminal |
| `Invalid object name 'Producto'` | EF buscó una tabla con otro nombre | `ToTable("Productos")` o el `DbSet` en plural |
| `A second operation was started on this context` | Te faltó un `await` | Pon `await` en cada `...Async()` |
| `The process cannot access the file ... because it is being used` | La API ya está corriendo en otra terminal | `Ctrl+C` en la otra terminal |
| Error raro de `obj` / "Root element is missing" | OneDrive dañó los archivos temporales | Borra las carpetas `obj` y `bin` y corre otra vez |

---

## 15. Cómo explicarlo en la entrevista

Si te preguntan **"¿cómo harías un endpoint para crear una venta?"**, responde con esta estructura:

> *"Haría un `POST /api/ventas` en un `VentasController`. Recibo un **DTO** con los datos, **valido** (si algo falta devuelvo **400**), reviso que no exista por la referencia externa para que sea **idempotente** (si ya existe, **409**), mapeo el DTO a la entidad, la agrego al **DbContext** que recibo por **inyección de dependencias**, y llamo a `SaveChangesAsync`, que guarda todo en **una transacción**. Todo es **async** para no bloquear hilos. Devuelvo **201 Created** con la URL del recurso nuevo. Y nunca devuelvo la entidad directo, sino un DTO."*

**Palabras que tienen que salir:** DTO · validación · códigos de estado · DbContext · inyección de dependencias · async/await · transacción · idempotencia.

**Preguntas típicas y respuesta corta:**
- *¿PUT vs POST?* → POST **crea** (cada vez uno nuevo). PUT **reemplaza** uno que ya existe, con id en la URL. PUT es **idempotente**: mandarlo 2 veces deja lo mismo.
- *¿PUT vs PATCH?* → PUT manda el objeto **completo**, PATCH solo los campos que cambian.
- *¿Qué es idempotente?* → que repetir la petición no cambia el resultado. GET, PUT y DELETE lo son; POST no (por eso se usa una referencia única para evitar duplicados).
- *¿400 vs 404 vs 409?* → 400 = datos mal escritos · 404 = no existe · 409 = choca con algo que ya existe.
- *¿401 vs 403?* → 401 = no te identificaste · 403 = te identificaste pero no tienes permiso.
- *¿Por qué `IQueryable` y no `List` para filtrar?* → con `IQueryable` el `Where` se convierte en SQL y la base filtra. Con `List` traes toda la tabla a memoria y filtras en C#.

---

## 16. Ejercicio final: CRUD de Estaciones

Ahora hazlo tú solo, en tu `Api/`, con un controller nuevo `EstacionesCrudController` en la ruta `api/estaciones-crud`. La entidad `Estacion` y su `DbSet` ya existen.

| Endpoint | Qué hace | Respuestas |
|---|---|---|
| `GET /api/estaciones-crud?provincia=Chiriquí` | Lista activas, filtro opcional por provincia, ordenadas por nombre | 200 |
| `GET /api/estaciones-crud/{id}` | Una estación | 200 / 404 |
| `POST /api/estaciones-crud` | Crea. Codigo, nombre y provincia obligatorios; codigo único. `FechaApertura` = la de hoy (`DateOnly.FromDateTime(DateTime.Today)`) y `Activa = true` | 201 / 400 / 409 |
| `PUT /api/estaciones-crud/{id}` | Cambia nombre y provincia | 200 / 400 / 404 |
| `DELETE /api/estaciones-crud/{id}` | **Borrado lógico:** no la borres, pon `Activa = false` (las estaciones tienen ventas) | 204 / 404 |

- **USA:** todo lo del punto 10, más `DateOnly`.
- **ESPERADO:**
  - `GET ...?provincia=Chiriquí` da 200 con solo estaciones de Chiriquí.
  - Crear `{ "codigo": "EST-99", "nombre": "Estación Prueba", "provincia": "Panamá" }` da 201, y repetirlo da 409.
  - El PUT cambia el nombre y devuelve 200.
  - Después del DELETE da 204, y la estación **ya no sale en el GET de la lista** (porque filtras `Activa`).
- **Al terminar:** `DELETE FROM Estaciones WHERE Id > 15;` en SSMS.

> **Pregunta extra para la entrevista:** ¿por qué borrado lógico? Porque si borras la estación de verdad, pierdes el historial de sus ventas (o la FK no te deja). En sistemas reales casi nunca se borra: se **desactiva**.

Cuando lo tengas, pégamelo y te lo reviso. 💪
