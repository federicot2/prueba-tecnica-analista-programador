# Respuestas: Práctica de C#, .NET Web API y APIs REST

Míralas **solo después de intentarlo**. Hay muchas formas correctas: si tu resultado coincide con el ESPERADO, tu solución también vale.

Todo este código está probado y funcionando en:
- `Respuestas/Consola`: temas 1 a 13 y 24. Córrelo con `dotnet run`.
- `Respuestas/Api`: temas 16 a 23. Córrelo con `dotnet run`; escucha en `http://localhost:5200`, así que puede estar prendida al mismo tiempo que la tuya.

---

# PARTE 1: C# esencial

### Tema 1
```csharp
var gas95 = new Producto(1, "Gasolina 95", 1.05m, "Combustible");
Console.WriteLine($"{gas95.Nombre}: {gas95.PrecioConItbms()}");     // Gasolina 95: 1.12

// (abajo del archivo)
class Producto
{
    public int Id { get; }
    public string Nombre { get; }
    public decimal Precio { get; }
    public string Categoria { get; }

    public Producto(int id, string nombre, decimal precio, string categoria)
    {
        Id = id;
        Nombre = nombre;
        Precio = precio;
        Categoria = categoria;
    }

    public decimal PrecioConItbms() => Math.Round(Precio * 1.07m, 2);
}
```
> 1.05 × 1.07 = 1.1235 → redondeado a 2 decimales = **1.12**.

### Tema 2
```csharp
var r1 = new ResumenEstacion("Delta Tocumen", 4, 203.75m);
var r2 = new ResumenEstacion("Delta Tocumen", 4, 203.75m);
var r3 = r1 with { Ventas = 5 };
Console.WriteLine(r1 == r2);   // True
Console.WriteLine(r3);         // ResumenEstacion { Nombre = Delta Tocumen, Ventas = 5, Total = 203.75 }

// (abajo)
record ResumenEstacion(string Nombre, int Ventas, decimal Total);
```
> Con una `class` normal, `r1 == r2` daría **False**, porque compara si son el mismo objeto en memoria y no los datos.

### Tema 3
```csharp
var precios = new Dictionary<string, decimal>
{
    ["GAS-91"] = 0.98m,
    ["GAS-95"] = 1.05m,
    ["DIE-REG"] = 0.92m
};
Console.WriteLine(BuscarPrecio(precios, "GAS-95"));   // 1.05
Console.WriteLine(BuscarPrecio(precios, "XYZ"));      // -1

var codigos = new List<string> { "GAS-91", "GAS-95", "DIE-REG" };
codigos.Add("DIE-PRE");
codigos.Remove("GAS-91");
Console.WriteLine($"{codigos.Count} -> {string.Join(", ", codigos)}");   // 3 -> GAS-95, DIE-REG, DIE-PRE

// (abajo)
static decimal BuscarPrecio(Dictionary<string, decimal> precios, string codigo)
    => precios.TryGetValue(codigo, out var precio) ? precio : -1;
```

### Tema 4
```csharp
string? email = null;
int? clienteId = null;
Console.WriteLine(email?.ToUpper() ?? "SIN CORREO");                                   // SIN CORREO
Console.WriteLine(clienteId.HasValue ? $"Cliente {clienteId}" : "Consumidor final");   // Consumidor final
```
> `email?.ToUpper()` da `null` porque `email` es null, y entonces `??` pone `"SIN CORREO"`. Es lo mismo que `ISNULL(UPPER(Email), 'SIN CORREO')` en SQL.

### Tema 5
```csharp
try
{
    ValidarCantidad(-5);
    Console.WriteLine("No deberia llegar aqui");
}
catch (ArgumentOutOfRangeException ex)
{
    Console.WriteLine($"Error: {ex.Message}");
}
finally
{
    Console.WriteLine("Validacion terminada");
}

// (abajo)
static void ValidarCantidad(decimal cantidad)
{
    if (cantidad <= 0)
        throw new ArgumentOutOfRangeException(nameof(cantidad), "La cantidad debe ser mayor a 0");
}
```
> `nameof(cantidad)` escribe `"cantidad"`. Si renombras la variable, se actualiza solo. Por eso el mensaje termina en `(Parameter 'cantidad')`.

### Tema 6
```csharp
List<ICalculadoraImpuesto> calculadoras = [new Itbms7(), new Exento()];
foreach (var c in calculadoras)
    Console.WriteLine($"{c.GetType().Name}: {c.Calcular(100m)}");

// (abajo)
interface ICalculadoraImpuesto
{
    decimal Calcular(decimal monto);
}
class Itbms7 : ICalculadoraImpuesto
{
    public decimal Calcular(decimal monto) => Math.Round(monto * 0.07m, 2);
}
class Exento : ICalculadoraImpuesto
{
    public decimal Calcular(decimal monto) => 0;
}
```
> El `foreach` no sabe qué clase concreta tiene cada elemento: solo sabe que cumple el contrato `ICalculadoraImpuesto`. Eso es **polimorfismo**, y es exactamente lo que hace la inyección de dependencias.

---

# PARTE 2: LINQ y async

### Tema 7
```csharp
var idsEfectivo = ventas
    .Where(v => v.MetodoPago == "Efectivo")
    .OrderByDescending(v => v.Total)
    .Select(v => v.Id)
    .ToList();
Console.WriteLine(string.Join(", ", idsEfectivo));   // 4, 1, 8
```

### Tema 8
```csharp
Console.WriteLine(ventas.Any(v => v.Total > 150));               // True
Console.WriteLine(ventas.Count(v => v.MetodoPago == "Yappy"));   // 2
var venta99 = ventas.FirstOrDefault(v => v.Id == 99);
Console.WriteLine(venta99 is null ? "No existe" : venta99.ToString());   // No existe
```
> Con `First(v => v.Id == 99)` el programa se cae con `InvalidOperationException`. Usa `FirstOrDefault` y revisa si es null.

### Tema 9
```csharp
Console.WriteLine($"{ventas.Sum(v => v.Total)} | {ventas.Average(v => v.Total)} | {ventas.Max(v => v.Total)}");
// 574.00 | 71.75 | 200.00
```

### Tema 10
```csharp
var porMetodo = ventas
    .GroupBy(v => v.MetodoPago)
    .Select(g => new { Metodo = g.Key, Cantidad = g.Count(), Total = g.Sum(v => v.Total) })
    .OrderByDescending(x => x.Total);
foreach (var m in porMetodo)
    Console.WriteLine($"{m.Metodo}: {m.Cantidad} | {m.Total}");
```
> Es el mismo patrón que en SQL: `SELECT MetodoPago, COUNT(*), SUM(Total) FROM Ventas GROUP BY MetodoPago ORDER BY SUM(Total) DESC`.

### Tema 11
```csharp
var porEstacion = ventas
    .Join(estaciones, v => v.EstacionId, e => e.Id, (v, e) => new { e.Nombre, v.Total })
    .GroupBy(x => x.Nombre)
    .Select(g => new { Estacion = g.Key, Total = g.Sum(x => x.Total) })
    .OrderByDescending(x => x.Total);
foreach (var e in porEstacion)
    Console.WriteLine($"{e.Estacion}: {e.Total}");
```

### Tema 12
```csharp
var consulta = ventas.Where(v => v.Total > 100);     // todavia NO se ejecuta
var foto = consulta.ToList();                         // aqui SI se ejecuta: 2 ventas (120 y 200)
ventas.Add(new VentaDemo(9, 4, "Tarjeta", 150m, new DateTime(2026, 11, 5)));
Console.WriteLine($"consulta: {consulta.Count()} | foto: {foto.Count}");   // consulta: 3 | foto: 2
ventas.RemoveAt(ventas.Count - 1);
```
**Por qué dan distinto:** `consulta` no guarda resultados, guarda **la receta**. Cada vez que la usas (`Count()`), se vuelve a ejecutar sobre la lista **actual**, que ya tiene la venta de 150. `foto` es una `List` creada con `ToList()` **antes** de agregarla: es una copia de ese momento.

**Respuesta de 10/10 para "IEnumerable vs IQueryable":**
> "Los dos son de ejecución diferida. `IEnumerable` ejecuta la consulta en memoria, con LINQ to Objects. `IQueryable` construye un árbol de expresión que el proveedor, por ejemplo EF Core, traduce a SQL, y la ejecuta la base de datos. El `DbSet` es `IQueryable`. Por eso los filtros y proyecciones tienen que ir **antes** del `ToList()`: si hago `db.Ventas.ToList().Where(...)`, traigo la tabla completa a memoria y filtro en C#, lo cual es lentísimo con muchos registros. Si hago `db.Ventas.Where(...).ToListAsync()`, el filtro va en el `WHERE` y solo viajan las filas necesarias."

### Tema 13
```csharp
var sw = Stopwatch.StartNew();
await EnviarAlErpAsync(1);
await EnviarAlErpAsync(2);
await EnviarAlErpAsync(3);
Console.WriteLine($"Uno por uno: ~{sw.ElapsedMilliseconds} ms");     // ~1500

sw.Restart();
var resultados = await Task.WhenAll(EnviarAlErpAsync(1), EnviarAlErpAsync(2), EnviarAlErpAsync(3));
Console.WriteLine($"En paralelo: ~{sw.ElapsedMilliseconds} ms");     // ~500
Console.WriteLine(string.Join(", ", resultados));

// (abajo)
static async Task<string> EnviarAlErpAsync(int ventaId)
{
    await Task.Delay(500);
    return $"Venta {ventaId} enviada";
}
```
> **Ojo:** `Task.WhenAll` sirve con llamadas independientes, como varias APIs. Con EF Core **no** lances varias consultas en paralelo sobre el **mismo** `DbContext`: no es thread-safe y lanza excepción.

---

# PARTE 3: APIs REST

### Tema 14
| # | Verbo + URL | Código |
|---|---|---|
| 1 | `GET /api/estaciones/3/ventas` | **200** (o **404** si la estación no existe) |
| 2 | `POST /api/ventas` | **201** Created |
| 3 | `POST /api/ventas` (referencia repetida) | **409** Conflict |
| 4 | `GET /api/productos/999` | **404** Not Found |
| 5 | `POST /api/productos` (precio negativo) | **400** Bad Request |
| 6 | `DELETE /api/clientes/7` | **204** No Content |
| 7 | `GET ...` y la BD se cae | **500** Internal Server Error |
| 8 | `GET /api/reportes/...` como cajero | **403** Forbidden |

9. **401 vs 403:**
   - **401**: "no sé quién eres". No mandaste token o no es válido, así que tienes que autenticarte.
   - **403**: "sé quién eres, pero no tienes permiso". Ya estás autenticado, pero tu rol no alcanza.

10. **POST no es idempotente** porque cada llamada crea un registro nuevo. Si el POS no recibe la respuesta (se cortó la red) y **reintenta**, se duplicaría la venta. Se resuelve con una **llave de idempotencia**: el POS manda una `referenciaExterna` única por venta.
    - La API revisa si esa referencia ya existe y responde **409**, o devuelve la venta ya creada, en vez de duplicarla.
    - Además, en la BD va un **índice UNIQUE** en `ReferenciaExterna`, como última defensa por si llegan dos requests al mismo tiempo.

### Tema 15
```csharp
public record ProductoDto(int Id, string Codigo, string Nombre, string Categoria, decimal PrecioUnitario);
public record CrearProductoRequest(string Codigo, string Nombre, string Categoria, string Unidad, decimal PrecioUnitario);
```
**¿Por qué el de entrada no tiene `Id`?** Porque el Id lo genera la base de datos (`IDENTITY`). Si lo aceptas, el cliente podría intentar elegir o pisar un Id. El request tiene **solo** lo que el cliente puede decidir.

**JSON del producto 7** (camelCase):
```json
{
  "id": 7,
  "codigo": "TDA-AGUA",
  "nombre": "Agua 1L",
  "categoria": "Tienda",
  "precioUnitario": 1.25
}
```

**3 razones para no devolver la entidad:**
1. Expone datos internos o sensibles.
2. Acopla la API a la estructura de la BD: si cambia una columna, se rompe el contrato con los clientes.
3. Las navegaciones crean ciclos (`Estacion` → `Ventas` → `Estacion`...) que rompen la serialización o devuelven datos de más.

Extra: al **recibir**, usar la entidad permite *over-posting*, es decir, que el cliente mande campos que no debería, como `Id` o `Total`.

---

# PARTE 4: Web API + EF Core

### Tema 16: `Controllers/SaludoController.cs`
```csharp
using Microsoft.AspNetCore.Mvc;

namespace PracticaApi.Controllers;

[ApiController]
[Route("api/saludo")]
public class SaludoController : ControllerBase
{
    [HttpGet("{nombre}")]
    public IActionResult Saludar(string nombre)
        => Ok(new { mensaje = $"Hola, {nombre}" });
}
```

### Temas 17 y 18: `Controllers/CalculadoraController.cs`
```csharp
using Microsoft.AspNetCore.Mvc;

namespace PracticaApi.Controllers;

[ApiController]
[Route("api/calculadora")]
public class CalculadoraController : ControllerBase
{
    // 17a
    [HttpGet("itbms")]
    public IActionResult Itbms([FromQuery] decimal monto)
    {
        var itbms = Math.Round(monto * 0.07m, 2);
        return Ok(new { monto, itbms, total = monto + itbms });
    }

    // 17b
    [HttpPost("sumar")]
    public IActionResult Sumar([FromBody] SumarRequest req)
        => Ok(new { resultado = req.A + req.B });

    // 18
    [HttpGet("dividir")]
    public IActionResult Dividir([FromQuery] decimal a, [FromQuery] decimal b)
    {
        if (b == 0)
            return BadRequest(new { mensaje = "No se puede dividir entre 0" });

        return Ok(new { resultado = a / b });
    }
}

public record SumarRequest(decimal A, decimal B);
```
> El JSON llega como `{ "a": 2.5, "b": 4 }`, en minúscula, y se mapea solo a `A` y `B`, porque ASP.NET no distingue mayúsculas al leer el JSON.

### Tema 19
**`Services/Contadores.cs`**
```csharp
namespace PracticaApi.Services;

public class Contador
{
    public string Id { get; } = Guid.NewGuid().ToString()[..8];
}
public class ContadorSingleton : Contador { }
public class ContadorScoped : Contador { }
public class ContadorTransient : Contador { }
```
**`Program.cs`** (antes de `builder.Build()`)
```csharp
using PracticaApi.Services;
// ...
builder.Services.AddSingleton<ContadorSingleton>();
builder.Services.AddScoped<ContadorScoped>();
builder.Services.AddTransient<ContadorTransient>();
```
**`Controllers/DiController.cs`**
```csharp
using Microsoft.AspNetCore.Mvc;
using PracticaApi.Services;

namespace PracticaApi.Controllers;

[ApiController]
[Route("api/di")]
public class DiController(
    ContadorSingleton singleton1, ContadorSingleton singleton2,
    ContadorScoped scoped1, ContadorScoped scoped2,
    ContadorTransient transient1, ContadorTransient transient2) : ControllerBase
{
    [HttpGet]
    public IActionResult Get() => Ok(new
    {
        singleton = new[] { singleton1.Id, singleton2.Id },
        scoped    = new[] { scoped1.Id, scoped2.Id },
        transient = new[] { transient1.Id, transient2.Id }
    });
}
```
**Resultado real de dos llamadas:**
```
1ª: {"singleton":["99dd3e6f","99dd3e6f"],"scoped":["3546d866","3546d866"],"transient":["8e257920","88d80bf2"]}
2ª: {"singleton":["99dd3e6f","99dd3e6f"],"scoped":["ce068a65","ce068a65"],"transient":["3bc5aae1","80ef5be8"]}
```
- **Singleton:** el mismo Id siempre.
- **Scoped:** el mismo dentro del request, distinto en el siguiente.
- **Transient:** distinto en cada inyección.

> En un proyecto real registrarías **interfaz → clase**: `AddScoped<IVentasService, VentasService>()`. Aquí se usaron clases solas para simplificar.

**Respuesta de 10/10 para el simulacro:**
> "Singleton crea una sola instancia para toda la vida de la aplicación. Scoped crea una por request HTTP, compartida por todos los que la piden en ese request. Transient crea una nueva cada vez que se inyecta. El `DbContext` se registra como Scoped porque no es thread-safe, así que no puede ser Singleton. Además lleva el *change tracking* del request: todos los servicios del mismo request comparten el contexto y sus cambios se guardan juntos en un `SaveChanges`. Una trampa común es inyectar un Scoped dentro de un Singleton (*captive dependency*): el Scoped queda vivo para siempre."

### Tema 20
**`Models/Producto.cs`**
```csharp
namespace PracticaApi.Models;

public class Producto
{
    public int Id { get; set; }
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Categoria { get; set; } = "";
    public string Unidad { get; set; } = "";
    public decimal PrecioUnitario { get; set; }
}
```
**`Data/DeltaContext.cs`**
```csharp
public DbSet<Estacion> Estaciones => Set<Estacion>();
public DbSet<Producto> Productos => Set<Producto>();

protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Estacion>().ToTable("Estaciones");
    modelBuilder.Entity<Producto>().ToTable("Productos");

    modelBuilder.Entity<Producto>().Property(p => p.PrecioUnitario).HasPrecision(10, 3);
}
```
> `= "";` evita el warning de nullable: le dice a C# "esto nunca es null".

### Tema 21: `Controllers/ProductosController.cs`
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PracticaApi.Data;
using PracticaApi.Models;

namespace PracticaApi.Controllers;

[ApiController]
[Route("api/productos")]
public class ProductosController(DeltaContext db) : ControllerBase
{
    // 21a
    [HttpGet]
    public async Task<ActionResult<List<ProductoDto>>> Listar([FromQuery] string? categoria)
    {
        IQueryable<Producto> query = db.Productos;

        if (!string.IsNullOrWhiteSpace(categoria))
            query = query.Where(p => p.Categoria == categoria);

        var lista = await query
            .OrderBy(p => p.Id)
            .Select(p => new ProductoDto(p.Id, p.Codigo, p.Nombre, p.Categoria, p.PrecioUnitario))
            .ToListAsync();

        return Ok(lista);
    }

    // 21b
    [HttpGet("{id:int}")]
    public async Task<ActionResult<ProductoDto>> Obtener(int id)
    {
        var p = await db.Productos.FindAsync(id);

        if (p is null)
            return NotFound(new { mensaje = $"No existe el producto {id}" });

        return Ok(new ProductoDto(p.Id, p.Codigo, p.Nombre, p.Categoria, p.PrecioUnitario));
    }

    // (el POST del tema 23 va aqui)
}

public record ProductoDto(int Id, string Codigo, string Nombre, string Categoria, decimal PrecioUnitario);
public record CrearProductoRequest(string Codigo, string Nombre, string Categoria, string Unidad, decimal PrecioUnitario);
```
El SQL que vas a ver en la terminal con `?categoria=Lubricante` muestra que el filtro se hizo en la BD:
```sql
SELECT [p].[Id], [p].[Codigo], [p].[Nombre], [p].[Categoria], [p].[PrecioUnitario]
FROM [Productos] AS [p]
WHERE [p].[Categoria] = @categoria
ORDER BY [p].[Id]
```

### Tema 22
**`Models/Venta.cs`**
```csharp
namespace PracticaApi.Models;

public class Venta
{
    public int Id { get; set; }
    public int EstacionId { get; set; }
    public int? ClienteId { get; set; }
    public int EmpleadoId { get; set; }
    public DateTime Fecha { get; set; }
    public decimal Total { get; set; }
    public string MetodoPago { get; set; } = "";
    public string ReferenciaExterna { get; set; } = "";

    public Estacion Estacion { get; set; } = null!;
}
```
**En `Estacion.cs`** agrega: `public List<Venta> Ventas { get; set; } = [];`

**En `DeltaContext.cs`** agrega:
```csharp
public DbSet<Venta> Ventas => Set<Venta>();
// en OnModelCreating:
modelBuilder.Entity<Venta>().ToTable("Ventas");
modelBuilder.Entity<Venta>().Property(v => v.Total).HasPrecision(12, 2);
```
**`Controllers/ReportesController.cs`**
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PracticaApi.Data;

namespace PracticaApi.Controllers;

[ApiController]
[Route("api/reportes")]
public class ReportesController(DeltaContext db) : ControllerBase
{
    [HttpGet("ventas-por-provincia")]
    public async Task<ActionResult<List<ProvinciaTotalDto>>> VentasPorProvincia([FromQuery] int anio)
    {
        if (anio < 2000 || anio > 2100)
            return BadRequest(new { mensaje = "Anio invalido" });

        var desde = new DateTime(anio, 1, 1);
        var hasta = desde.AddYears(1);

        var datos = await db.Ventas
            .Where(v => v.Fecha >= desde && v.Fecha < hasta)
            .GroupBy(v => v.Estacion.Provincia)
            .OrderByDescending(g => g.Sum(v => v.Total))
            .Select(g => new ProvinciaTotalDto(g.Key, g.Count(), g.Sum(v => v.Total)))
            .ToListAsync();

        return Ok(datos);
    }
}

public record ProvinciaTotalDto(string Provincia, int Ventas, decimal Total);
```
> El `OrderByDescending` va **antes** del `Select`. Si ordenas después, sobre la propiedad del record (`x => x.Total`), EF puede no saber traducirlo a SQL y te da error.
>
> Usar `v.Fecha >= desde && v.Fecha < hasta`, en vez de `v.Fecha.Year == anio`, es la misma regla que en SQL: así se puede usar el índice.

### Tema 23: el POST, dentro de `ProductosController`
```csharp
[HttpPost]
public async Task<IActionResult> Crear([FromBody] CrearProductoRequest req)
{
    if (string.IsNullOrWhiteSpace(req.Codigo) || string.IsNullOrWhiteSpace(req.Nombre))
        return BadRequest(new { mensaje = "Codigo y nombre son obligatorios" });

    if (req.PrecioUnitario <= 0)
        return BadRequest(new { mensaje = "El precio debe ser mayor a 0" });

    if (await db.Productos.AnyAsync(p => p.Codigo == req.Codigo))
        return Conflict(new { mensaje = $"Ya existe un producto con codigo {req.Codigo}" });

    var producto = new Producto
    {
        Codigo = req.Codigo,
        Nombre = req.Nombre,
        Categoria = req.Categoria,
        Unidad = req.Unidad,
        PrecioUnitario = req.PrecioUnitario
    };

    db.Productos.Add(producto);
    await db.SaveChangesAsync();          // aqui se hace el INSERT y producto.Id queda lleno

    var dto = new ProductoDto(producto.Id, producto.Codigo, producto.Nombre,
                              producto.Categoria, producto.PrecioUnitario);
    return CreatedAtAction(nameof(Obtener), new { id = producto.Id }, dto);
}
```
**Resultados reales:**
```
23a -> 201 {"id":18,"codigo":"TDA-HIELO",...}   header Location: http://localhost:5100/api/productos/18
23b -> 409 {"mensaje":"Ya existe un producto con codigo TDA-HIELO"}
23c -> 400 {"mensaje":"El precio debe ser mayor a 0"}
23d -> 400 {"mensaje":"Codigo y nombre son obligatorios"}
```
> El Id que te salga puede no ser 10, aunque solo haya 9 productos. `IDENTITY` no reutiliza números: si se insertó y borró antes, sigue contando.
>
> El chequeo con `AnyAsync` puede fallar si llegan **dos requests idénticos al mismo tiempo**: los dos ven "no existe" y los dos insertan. La defensa real es la restricción **UNIQUE** en `Codigo`, que `Productos` sí tiene. En ese caso `SaveChangesAsync` lanza `DbUpdateException`, que puedes atrapar y convertir también en 409.

---

# PARTE 5

### Tema 24
```csharp
using var http = new HttpClient { BaseAddress = new Uri("http://localhost:5100") };
try
{
    var combustibles = await http.GetFromJsonAsync<List<ProductoDto>>("api/productos?categoria=Combustible");
    Console.WriteLine($"{combustibles!.Count} productos: {string.Join(", ", combustibles.Select(p => p.Nombre))}");

    var respuesta = await http.GetAsync("api/productos/99");
    Console.WriteLine($"Producto 99 -> {(int)respuesta.StatusCode} {respuesta.StatusCode}");
}
catch (HttpRequestException)
{
    Console.WriteLine("La API no esta corriendo. Levantala con 'dotnet run' en la carpeta Api.");
}

// (abajo)
record ProductoDto(int Id, string Codigo, string Nombre, string Categoria, decimal PrecioUnitario);
```
> `GetFromJsonAsync` **lanza excepción** si la respuesta no es 2xx. Por eso el 404 se pide con `GetAsync`, que te deja revisar el `StatusCode` sin que explote.
