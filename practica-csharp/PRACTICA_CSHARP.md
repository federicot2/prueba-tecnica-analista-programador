# Práctica de C#, .NET Web API y APIs REST

Cada tema trae:

- **Qué es**: la idea en pocas líneas.
- **Cómo se usa**: la sintaxis y un ejemplo.
- **Ejercicio**: lo que tienes que hacer tú.
  - **USA:** lo que necesitas.
  - **ESPERADO:** lo que te tiene que dar. Si te da igual, vas bien.

Las respuestas están en [`PRACTICA_CSHARP_respuestas.md`](PRACTICA_CSHARP_respuestas.md), con el mismo número de tema. También hay proyectos ya resueltos y probados en `Respuestas/`. Míralas **solo después de intentarlo**.

> 💡 En VS Code, para ver este archivo bonito: clic derecho en la pestaña → **Open Preview** (o `Ctrl+Shift+V`).

## Dónde se hace cada parte

| Parte | Temas | Dónde escribes | Cómo lo corres |
|---|---|---|---|
| 1. C# esencial | 1 a 6 | `Consola/Program.cs` | `dotnet run` en la carpeta `Consola` |
| 2. LINQ y async | 7 a 13 | `Consola/Program.cs` | igual |
| 3. APIs REST (teoría) | 14 y 15 | en papel o en un `.md` | — |
| 4. Web API + EF Core | 16 a 23 | carpeta `Api/` | `dotnet run` en `Api` y pruebas con `Api/PracticaApi.http` |
| 5. Consumir una API | 24 | `Consola/Program.cs` | con la API corriendo |

**Para correr:** en VS Code abre la terminal (`` Ctrl+` ``), entra a la carpeta y ejecuta `dotnet run`. Si `dotnet` no se reconoce, cierra y vuelve a abrir VS Code.

**Para probar la API:** instala la extensión **REST Client** en VS Code, abre `Api/PracticaApi.http` y haz clic en **Send Request** encima de cada petición. También puedes usar Postman.

---

# PARTE 1: C# esencial

## Tema 1. Clases, propiedades y constructor

**Qué es:** una **clase** es un molde para crear objetos. Tiene **propiedades** (los datos), un **constructor** (lo que se ejecuta al hacer `new`) y **métodos** (lo que el objeto sabe hacer).

**Cómo se usa:**
```csharp
class Cliente
{
    public int Id { get; }                 // propiedad de solo lectura
    public string Nombre { get; set; }     // propiedad de lectura y escritura

    public Cliente(int id, string nombre)  // constructor
    {
        Id = id;
        Nombre = nombre;
    }

    public string Saludo() => $"Hola, {Nombre}";   // metodo
}

var c = new Cliente(1, "Minera Centro");
Console.WriteLine(c.Saludo());   // Hola, Minera Centro
```
> Para dinero usa siempre **`decimal`** (con `m` al final: `1.05m`), nunca `double`: `double` tiene errores de redondeo.

**Ejercicio 1:** crea la clase `Producto` con `Id`, `Nombre`, `Precio` (decimal) y `Categoria`, un constructor que reciba los cuatro, y un método `PrecioConItbms()` que devuelva el precio + 7%, redondeado a 2 decimales. Crea la Gasolina 95 (precio 1.05) e imprime su precio con ITBMS.
- **USA:** `class`, constructor, `decimal`, `Math.Round(valor, 2)`
- **ESPERADO:** `Gasolina 95: 1.12`

---

## Tema 2. Records

**Qué es:** un `record` es una clase pensada para **guardar datos**. En una línea te da: constructor, propiedades, `ToString()` bonito y **comparación por valor** (dos records con los mismos datos son iguales). Es lo ideal para **DTOs**.

**Cómo se usa:**
```csharp
record Punto(int X, int Y);

var a = new Punto(1, 2);
var b = new Punto(1, 2);
Console.WriteLine(a == b);           // True  (con una clase normal daria False)
var c = a with { Y = 5 };            // copia cambiando solo Y
Console.WriteLine(c);                // Punto { X = 1, Y = 5 }
```

**Ejercicio 2:** crea `record ResumenEstacion(string Nombre, int Ventas, decimal Total)`. Crea dos iguales ("Delta Tocumen", 4, 203.75) y compáralos con `==`. Después crea una copia con `with` que tenga 5 ventas e imprímela.
- **USA:** `record`, `==`, `with`
- **ESPERADO:**
  ```
  True
  ResumenEstacion { Nombre = Delta Tocumen, Ventas = 5, Total = 203.75 }
  ```

---

## Tema 3. List y Dictionary

**Qué es:**
- `List<T>`: una lista de elementos que puede crecer. `Add`, `Remove`, `Count`, acceso por índice `[0]`.
- `Dictionary<TKey, TValue>`: pares **clave → valor**. Buscar por clave es instantáneo. Usa `TryGetValue` para buscar sin que explote si la clave no existe.

**Cómo se usa:**
```csharp
var nombres = new List<string> { "Ana", "Luis" };
nombres.Add("Marta");
Console.WriteLine(nombres.Count);           // 3

var stock = new Dictionary<string, int> { ["TDA-AGUA"] = 50, ["TDA-CAFE"] = 20 };
if (stock.TryGetValue("TDA-AGUA", out var cantidad))
    Console.WriteLine(cantidad);            // 50
// stock["NO-EXISTE"]  -> lanza KeyNotFoundException
```

**Ejercicio 3:**
1. Crea un diccionario de precios: `GAS-91 = 0.98`, `GAS-95 = 1.05`, `DIE-REG = 0.92`.
2. Crea el método `static decimal BuscarPrecio(Dictionary<string, decimal> precios, string codigo)` que devuelva el precio, o `-1` si el código no existe. Pruébalo con `GAS-95` y con `XYZ`.
3. Crea una lista con `GAS-91, GAS-95, DIE-REG`, agrega `DIE-PRE`, quita `GAS-91` e imprime la cantidad y los elementos.
- **USA:** `Dictionary`, `TryGetValue`, `List`, `Add`, `Remove`, `string.Join(", ", lista)`
- **ESPERADO:**
  ```
  1.05
  -1
  3 -> GAS-95, DIE-REG, DIE-PRE
  ```

---

## Tema 4. Nulos: `?`, `?.` y `??`

**Qué es:** `null` = "no hay valor" (como `NULL` en SQL).
- `string?` / `int?`: el `?` en el tipo dice "esto puede ser null". En la BD, `Email` y `ClienteId` pueden ser NULL, así que en C# son `string?` e `int?`.
- `x?.Algo`: si `x` es null, no explota y da null.
- `x ?? "otro"`: si `x` es null, usa "otro" (como `ISNULL` en SQL).
- `int?` tiene `.HasValue` y `.Value`.

**Cómo se usa:**
```csharp
string? apodo = null;
Console.WriteLine(apodo?.Length);              // (vacio, no explota)
Console.WriteLine(apodo ?? "sin apodo");       // sin apodo
int? jefeId = 3;
Console.WriteLine(jefeId.HasValue);            // True
```

**Ejercicio 4:** declara `string? email = null;` e `int? clienteId = null;`.
1. Imprime el email en mayúsculas, o `SIN CORREO` si es null, en **una sola línea**.
2. Imprime `Cliente X` si `clienteId` tiene valor, o `Consumidor final` si no.
- **USA:** `?.`, `??`, `.HasValue`, operador ternario `condicion ? a : b`
- **ESPERADO:**
  ```
  SIN CORREO
  Consumidor final
  ```

---

## Tema 5. Excepciones: try / catch / finally / throw

**Qué es:** una **excepción** es un error en tiempo de ejecución.
- `throw new XxxException("mensaje")`: lanzas un error.
- `try { }`: el código que puede fallar.
- `catch (TipoException ex) { }`: qué hacer si falla. Atrapa el tipo **más específico** que puedas.
- `finally { }`: se ejecuta **siempre**, falle o no. Sirve para cerrar o limpiar cosas.

Excepciones típicas: `ArgumentException`, `ArgumentNullException`, `ArgumentOutOfRangeException`, `InvalidOperationException`, `KeyNotFoundException`.

**Cómo se usa:**
```csharp
try
{
    int[] numeros = { 1, 2, 3 };
    Console.WriteLine(numeros[10]);
}
catch (IndexOutOfRangeException ex)
{
    Console.WriteLine($"Error: {ex.Message}");
}
finally
{
    Console.WriteLine("Siempre me ejecuto");
}
```

**Ejercicio 5:** crea `static void ValidarCantidad(decimal cantidad)` que lance `ArgumentOutOfRangeException` con el mensaje `"La cantidad debe ser mayor a 0"` si la cantidad es ≤ 0. Llámalo con `-5` dentro de un `try`, atrapa la excepción e imprime el mensaje. En el `finally` imprime `Validacion terminada`.
- **USA:** `throw new ArgumentOutOfRangeException(nameof(cantidad), "mensaje")`, `try`, `catch`, `finally`
- **ESPERADO:**
  ```
  Error: La cantidad debe ser mayor a 0 (Parameter 'cantidad')
  Validacion terminada
  ```

---

## Tema 6. Interfaces

**Qué es:** una **interfaz** es un **contrato**: dice *qué* métodos debe tener una clase, pero no *cómo* los hace. Varias clases pueden cumplir el mismo contrato de formas distintas. Es la base de la **inyección de dependencias**: el controller pide `IServicio` y no le importa qué clase concreta le dan. Por convención el nombre empieza con **I**.

**Cómo se usa:**
```csharp
interface INotificador
{
    void Enviar(string mensaje);
}
class NotificadorEmail : INotificador
{
    public void Enviar(string mensaje) => Console.WriteLine($"Email: {mensaje}");
}
class NotificadorSms : INotificador
{
    public void Enviar(string mensaje) => Console.WriteLine($"SMS: {mensaje}");
}

INotificador n = new NotificadorSms();   // la variable es de tipo INTERFAZ
n.Enviar("Venta registrada");            // SMS: Venta registrada
```

**Ejercicio 6:** crea la interfaz `ICalculadoraImpuesto` con `decimal Calcular(decimal monto)`, y dos clases que la implementen: `Itbms7` (7% redondeado a 2 decimales) y `Exento` (siempre 0). Mete una de cada una en una `List<ICalculadoraImpuesto>`, recórrela con `foreach` y calcula el impuesto de 100.
- **USA:** `interface`, `class X : ICalculadoraImpuesto`, `List<ICalculadoraImpuesto>`, `c.GetType().Name`
- **ESPERADO:**
  ```
  Itbms7: 7.00
  Exento: 0
  ```

---

# PARTE 2: LINQ y async

> En `Consola/Program.cs` ya están las listas `estaciones` (4) y `ventas` (8). No las cambies.

## Tema 7. Where / OrderBy / Select

**Qué es:** **LINQ** es como SQL pero en C#, sobre listas (o sobre la BD con EF Core).

| SQL | LINQ |
|---|---|
| `WHERE` | `.Where(x => condicion)` |
| `ORDER BY` / `DESC` | `.OrderBy(x => x.Campo)` / `.OrderByDescending(...)` |
| desempate | `.ThenBy(...)` |
| `SELECT columnas` | `.Select(x => new { x.A, x.B })` |
| `TOP (n)` | `.Take(n)` |

`x => ...` es una **lambda**: una función corta. Se lee "para cada x, devuelve...". Al final, `.ToList()` ejecuta y te da una lista.

**Cómo se usa:**
```csharp
var grandes = ventas
    .Where(v => v.Total > 50)
    .OrderBy(v => v.Fecha)
    .Select(v => new { v.Id, v.Total })
    .ToList();
```

**Ejercicio 7:** obtén los **Id** de las ventas en `Efectivo`, de la más grande a la más chica, e imprímelos separados por coma.
- **USA:** `Where`, `OrderByDescending`, `Select(v => v.Id)`, `ToList`, `string.Join`
- **ESPERADO:** `4, 1, 8`

---

## Tema 8. Any / Count / First / FirstOrDefault / Single

**Qué es:**
- `Any(cond)`: ¿hay **al menos uno**? Devuelve `bool` (como `EXISTS`).
- `Count(cond)`: cuántos cumplen.
- `First(cond)`: el primero; si no hay ninguno, **lanza excepción**.
- `FirstOrDefault(cond)`: el primero, o **null** si no hay. Es el más usado.
- `Single(cond)`: exactamente uno; si hay 0 o más de 1, lanza excepción.

**Cómo se usa:**
```csharp
bool hayCredito = ventas.Any(v => v.MetodoPago == "Credito");
var primera = ventas.FirstOrDefault(v => v.EstacionId == 2);   // venta 3
```

**Ejercicio 8:** imprime:
1. ¿Hay alguna venta mayor a 150?
2. ¿Cuántas ventas son con Yappy?
3. Busca la venta con Id 99. Si no existe, imprime `No existe`.
- **USA:** `Any`, `Count`, `FirstOrDefault`, `is null`
- **ESPERADO:**
  ```
  True
  2
  No existe
  ```

---

## Tema 9. Sum / Average / Min / Max

**Qué es:** las funciones de agregado de SQL, pero en LINQ: `.Sum(v => v.Total)`, `.Average(...)`, `.Min(...)`, `.Max(...)`.

**Cómo se usa:**
```csharp
var menor = ventas.Min(v => v.Total);   // 15.75
```

**Ejercicio 9:** imprime en una línea el total vendido, el promedio y la venta máxima, separados por ` | `.
- **USA:** `Sum`, `Average`, `Max`
- **ESPERADO:** `574.00 | 71.75 | 200.00`

---

## Tema 10. GroupBy

**Qué es:** el `GROUP BY` de SQL. `.GroupBy(v => v.Campo)` devuelve **grupos**. Cada grupo tiene `.Key` (el valor por el que agrupaste) y adentro todos sus elementos, sobre los que puedes usar `Count()`, `Sum()`...

**Cómo se usa:**
```csharp
var porEstacion = ventas
    .GroupBy(v => v.EstacionId)
    .Select(g => new { EstacionId = g.Key, Cantidad = g.Count() });
foreach (var x in porEstacion)
    Console.WriteLine($"{x.EstacionId}: {x.Cantidad}");
```

**Ejercicio 10:** por cada método de pago: cantidad de ventas y total. Ordénalo del total más alto al más bajo.
- **USA:** `GroupBy(v => v.MetodoPago)`, `Select(g => new { g.Key, ... })`, `g.Count()`, `g.Sum(...)`, `OrderByDescending`
- **ESPERADO:**
  ```
  Credito: 1 | 200.00
  Tarjeta: 2 | 180.00
  Efectivo: 3 | 148.00
  Yappy: 2 | 46.00
  ```

---

## Tema 11. Join

**Qué es:** el `INNER JOIN` de SQL. Une dos listas por una clave en común.
```
lista1.Join(lista2, x1 => clave1, x2 => clave2, (x1, x2) => resultado)
```
Igual que en SQL, si un elemento no tiene pareja **no sale**. Para un LEFT JOIN se usa `GroupJoin`, pero en EF Core casi siempre usarás **navegaciones** (tema 22) en vez de `Join`.

**Cómo se usa:**
```csharp
var conNombre = ventas.Join(estaciones,
        v => v.EstacionId,                 // clave en ventas
        e => e.Id,                         // clave en estaciones
        (v, e) => new { v.Id, e.Nombre }); // que quieres de cada par
```

**Ejercicio 11:** total vendido por **nombre** de estación, de mayor a menor.
- **USA:** `Join` con `estaciones`, después `GroupBy` por nombre, `Sum`, `OrderByDescending`
- **ESPERADO:** (Delta Colón 2000 no sale porque no tiene ventas)
  ```
  Delta Boquete: 280.00
  Delta Tocumen: 203.75
  Delta Chitré: 90.25
  ```

---

## Tema 12. Ejecución diferida: IEnumerable vs IQueryable

**Qué es:** una consulta LINQ **no se ejecuta cuando la escribes**, sino cuando la **recorres** (`foreach`, `ToList()`, `Count()`, `First()`...). A eso se le llama **ejecución diferida**.

- `IEnumerable<T>`: la consulta se ejecuta **en memoria** (C#). Si viene de la BD, primero trae **todas** las filas y después filtra.
- `IQueryable<T>`: la consulta se **traduce a SQL** y la ejecuta **la base de datos**. Solo viajan las filas que necesitas. Un `DbSet` de EF Core es `IQueryable`.

**La trampa (la del simulacro):**
```csharp
// MAL: ToList() trae TODA la tabla Ventas a memoria y DESPUES filtra en C#
var malo = db.Ventas.ToList().Where(v => v.EstacionId == 3);

// BIEN: el Where se convierte en WHERE de SQL, viajan solo las ventas de la estacion 3
var bueno = await db.Ventas.Where(v => v.EstacionId == 3).ToListAsync();
```
**Regla:** `ToList()` / `ToListAsync()` va **al final**, después de `Where`, `Select`, `OrderBy`...

**Cómo se usa (diferida, en memoria):**
```csharp
var numeros = new List<int> { 1, 2, 3 };
var mayores = numeros.Where(n => n > 1);   // NO se ejecuta todavia
numeros.Add(10);
Console.WriteLine(mayores.Count());        // 3  (2, 3 y 10: se ejecuto AHORA)
```

**Ejercicio 12:**
1. Crea `consulta = ventas.Where(v => v.Total > 100)` **sin** `ToList`.
2. Crea `foto = consulta.ToList()`.
3. Agrega a `ventas` una venta nueva: `new VentaDemo(9, 4, "Tarjeta", 150m, new DateTime(2026, 11, 5))`.
4. Imprime `consulta.Count()` y `foto.Count`.
5. Borra la venta agregada con `ventas.RemoveAt(ventas.Count - 1)` para no afectar lo demás.

Explica con tus palabras por qué dan distinto.
- **USA:** `Where` sin `ToList`, `ToList`, `Add`, `Count()`
- **ESPERADO:** `consulta: 3 | foto: 2`

---

## Tema 13. async / await

**Qué es:** cuando tu código espera algo lento (la BD, otra API, un archivo), `await` **libera el hilo** mientras espera, en vez de dejarlo bloqueado. En una API eso significa poder atender más requests a la vez.
- Un método async devuelve `Task` (sin resultado) o `Task<T>` (con resultado), y por convención termina en `Async`.
- `await tarea`: espera el resultado sin bloquear.
- `Task.WhenAll(t1, t2, t3)`: lanza varias tareas **a la vez** y espera a que terminen todas.
- **Nunca** uses `.Result` ni `.Wait()`: bloquean el hilo y pueden congelar la app (deadlock).

**Cómo se usa:**
```csharp
static async Task<int> ConsultarStockAsync(string codigo)
{
    await Task.Delay(300);     // simula una llamada lenta
    return 50;
}

var stock = await ConsultarStockAsync("TDA-AGUA");
```

**Ejercicio 13:** crea `static async Task<string> EnviarAlErpAsync(int ventaId)` que espere 500 ms (`Task.Delay(500)`) y devuelva `"Venta {ventaId} enviada"`.
1. Envía las ventas 1, 2 y 3 **una por una** (tres `await` seguidos) y mide el tiempo.
2. Envíalas **en paralelo** con `Task.WhenAll` y mide el tiempo.
3. Imprime los 3 resultados del paso 2.
- **USA:** `async Task<string>`, `await`, `Task.Delay`, `Task.WhenAll`, `Stopwatch.StartNew()`, `sw.ElapsedMilliseconds`, `sw.Restart()`
- **ESPERADO:** (los ms pueden variar un poco)
  ```
  Uno por uno: ~1500 ms
  En paralelo: ~500 ms
  Venta 1 enviada, Venta 2 enviada, Venta 3 enviada
  ```

---

# PARTE 3: APIs REST (teoría que siempre preguntan)

## Tema 14. Verbos HTTP y códigos de estado

**Qué es:** una API REST expone **recursos** (estaciones, productos, ventas) en URLs, y el **verbo** dice qué hacer con ellos.

| Verbo | Para qué | Ejemplo | Respuesta típica |
|---|---|---|---|
| `GET` | leer (no cambia nada) | `GET /api/productos/5` | 200 |
| `POST` | crear | `POST /api/productos` | 201 Created |
| `PUT` | reemplazar completo | `PUT /api/productos/5` | 200 o 204 |
| `PATCH` | modificar una parte | `PATCH /api/productos/5` | 200 o 204 |
| `DELETE` | borrar | `DELETE /api/productos/5` | 204 No Content |

| Código | Significa | Cuándo |
|---|---|---|
| **200** OK | todo bien | GET exitoso |
| **201** Created | se creó | POST exitoso (con la URL del nuevo en el header `Location`) |
| **204** No Content | bien, sin cuerpo | DELETE / PUT exitoso |
| **400** Bad Request | el cliente mandó algo inválido | validación falló |
| **401** Unauthorized | no estás autenticado | falta el token o el login |
| **403** Forbidden | estás autenticado pero no tienes permiso | no eres admin |
| **404** Not Found | no existe | id inexistente |
| **409** Conflict | choca con algo que ya existe | código o referencia duplicada |
| **500** Internal Server Error | el servidor falló | excepción no controlada (es culpa tuya, no del cliente) |

**Idempotente** = llamarlo 1 o 10 veces deja el mismo resultado. `GET`, `PUT` y `DELETE` lo son; `POST` **no**: cada llamada crea otro registro. Por eso en integraciones se usa una **referencia externa** única y se devuelve **409** si ya existe.

**Ejercicio 14:** escribe el **verbo + URL** y el **código de respuesta** para cada caso:
1. Listar las ventas de la estación 3.
2. Registrar una venta nueva, y salió bien.
3. Registrar una venta cuya `referenciaExterna` ya existe.
4. Pedir el producto 999, que no existe.
5. Crear un producto con precio negativo.
6. Borrar el cliente 7, y salió bien.
7. La BD se cayó en medio de un GET.
8. Un cajero intenta entrar al endpoint de reportes, que es solo para gerentes (el cajero sí inició sesión).
9. ¿Qué diferencia hay entre 401 y 403?
10. ¿Por qué `POST` no es idempotente, y cómo lo resuelves cuando el POS reintenta enviar la misma venta?
- **USA:** las dos tablas de arriba
- **ESPERADO:** compara con las respuestas.

---

## Tema 15. JSON y DTOs

**Qué es:**
- **JSON** es el formato en que viajan los datos: `{ "id": 5, "nombre": "Agua 1L", "precio": 1.25 }`. ASP.NET convierte tus objetos C# a JSON y de vuelta, solo. Por defecto pasa los nombres a **camelCase**: `PrecioUnitario` → `precioUnitario`.
- Un **DTO** (Data Transfer Object) es una clase o record que define **exactamente** lo que entra o sale de la API. Es **distinto** de la entidad de EF.

**¿Por qué no devolver la entidad directo?**
1. **Expones de más:** columnas internas, o datos sensibles como salarios o contraseñas.
2. **Te amarras a la BD:** si cambias una columna, rompes a todos los que consumen tu API.
3. **Ciclos:** `Estacion.Ventas` → `Venta.Estacion` → ... y el serializador JSON explota o devuelve megas de datos.
4. **Seguridad al recibir (over-posting):** si recibes la entidad en un POST, el cliente podría mandar campos que no debería, como `Id` o `Total`.

**Cómo se usa:**
```csharp
public record EstacionDto(int Id, string Codigo, string Nombre, string Provincia);   // salida
public record CrearClienteRequest(string Nombre, string Ruc, string? Email);         // entrada

// En EF Core proyectas directo al DTO: SQL solo trae esas columnas
var lista = await db.Estaciones.Select(e => new EstacionDto(e.Id, e.Codigo, e.Nombre, e.Provincia)).ToListAsync();
```

**Ejercicio 15:**
1. Escribe el record `ProductoDto` (salida) con `Id, Codigo, Nombre, Categoria, PrecioUnitario`, y el record `CrearProductoRequest` (entrada) con `Codigo, Nombre, Categoria, Unidad, PrecioUnitario`. ¿Por qué el de entrada **no** tiene `Id`?
2. Escribe a mano el JSON que devolvería la API para el producto 7 (Agua 1L, código TDA-AGUA, categoría Tienda, precio 1.25).
3. Nombra 3 razones para no devolver la entidad directo.
- **USA:** `record`, camelCase
- **ESPERADO:** los records los usas en los temas 21 y 23. El resto, compáralo con las respuestas.

---

# PARTE 4: Web API con ASP.NET Core + EF Core

> Trabajas en la carpeta `Api/`. Ya tiene:
> - `Program.cs` con los controllers y el `DbContext` registrados.
> - `Models/Estacion.cs` y `Data/DeltaContext.cs`, que solo tienen Estaciones. Tú agregas el resto.
> - `Controllers/EjemplosController.cs`, con un ejemplo de cada tema que **ya funciona**.
> - `PracticaApi.http`, con todas las pruebas y lo que deben devolver.
>
> Levántala con `dotnet run` dentro de `Api/` (escucha en `http://localhost:5100`). Para detenerla: `Ctrl+C`. **Cada vez que cambies código**, detenla y vuelve a correrla.
>
> En la terminal vas a ver el SQL que genera EF Core. Es muy útil para entender el tema 12.

## Tema 16. Controller y GET simple

**Qué es:** un **controller** es una clase que agrupa endpoints.
- `[ApiController]`: activa comportamientos de API, como el 400 automático si el JSON viene mal.
- `[Route("api/xxx")]`: la URL base.
- `[HttpGet("...")]`, `[HttpPost]`...: el verbo y el resto de la ruta de cada método.
- Hereda de `ControllerBase`, que te da `Ok()`, `NotFound()`, `BadRequest()`...

**Cómo se usa:** mira `Hola()` en `EjemplosController.cs`:
```csharp
[ApiController]
[Route("api/ejemplos")]
public class EjemplosController : ControllerBase
{
    [HttpGet("hola")]                               // GET /api/ejemplos/hola
    public IActionResult Hola() => Ok(new { mensaje = "Hola desde la API" });
}
```

**Ejercicio 16:** crea `Controllers/SaludoController.cs` con `GET /api/saludo/{nombre}` que devuelva un JSON con el saludo.
- **USA:** `[ApiController]`, `[Route("api/saludo")]`, `[HttpGet("{nombre}")]`, `Ok(new { mensaje = ... })`
- **ESPERADO:** `GET /api/saludo/Ana` → **200** `{"mensaje":"Hola, Ana"}`

---

## Tema 17. Parámetros: ruta, query string y body

**Qué es:** hay 3 formas de mandarle datos a un endpoint:

| Dónde | Ejemplo de URL / request | En C# | Se usa para |
|---|---|---|---|
| **Ruta** | `/api/productos/5` | `[HttpGet("{id:int}")]` + parámetro `int id` | identificar **un** recurso |
| **Query string** | `/api/productos?categoria=Tienda` | `[FromQuery] string? categoria` | filtros, paginación, opciones |
| **Body** (JSON) | `POST` con `{ "a": 2, "b": 3 }` | `[FromBody] MiRequest req` | datos para crear o modificar |

`{id:int}` es una **restricción**: si mandas `/api/productos/abc`, ni siquiera entra (404).

**Cómo se usa:** mira `Doble`, `Repetir` y `Eco` en `EjemplosController.cs`.

**Ejercicio 17:** crea `CalculadoraController` (`[Route("api/calculadora")]`) con:
- **a)** `GET /api/calculadora/itbms?monto=100`, que devuelva el monto, el ITBMS (7%, redondeado a 2) y el total.
- **b)** `POST /api/calculadora/sumar`, con body `{ "a": 2.5, "b": 4 }`, que devuelva la suma. Crea el record `SumarRequest(decimal A, decimal B)`.
- **USA:** `[FromQuery] decimal monto`, `[HttpPost("sumar")]`, `[FromBody] SumarRequest req`
- **ESPERADO:**
  - a) **200** `{"monto":100,"itbms":7.00,"total":107.00}`
  - b) **200** `{"resultado":6.5}`

---

## Tema 18. Devolver el código de estado correcto

**Qué es:** cada método del controller devuelve un **resultado** con su código HTTP:

| Método | Código |
|---|---|
| `Ok(objeto)` | 200 |
| `CreatedAtAction(nameof(Obtener), new { id }, objeto)` | 201 + header `Location` |
| `NoContent()` | 204 |
| `BadRequest(new { mensaje })` | 400 |
| `NotFound(new { mensaje })` | 404 |
| `Conflict(new { mensaje })` | 409 |

Usa `IActionResult` como tipo de retorno, o `ActionResult<T>` si quieres indicar qué devuelve el 200. **Valida primero y sal rápido** con `return BadRequest(...)`, y deja el caso feliz al final.

**Cómo se usa:** mira `Edad` en `EjemplosController.cs`.

**Ejercicio 18:** en `CalculadoraController` agrega `GET /api/calculadora/dividir?a=10&b=4`. Si `b` es 0, devuelve **400** con un mensaje.
- **USA:** `if (b == 0) return BadRequest(new { mensaje = "..." });`, `Ok(...)`
- **ESPERADO:**
  - `?a=10&b=0` → **400** `{"mensaje":"No se puede dividir entre 0"}`
  - `?a=10&b=4` → **200** `{"resultado":2.5}`

---

## Tema 19. Inyección de dependencias (DI) y ciclos de vida

**Qué es:** en vez de hacer `new MiServicio()` dentro del controller, lo **registras** en `Program.cs` y ASP.NET te lo **pasa en el constructor**. Ventajas: bajo acoplamiento, fácil de cambiar la implementación y fácil de testear con mocks.

**Los 3 ciclos de vida (pregunta segura):**

| Registro | Cuántas instancias | Ejemplo de uso |
|---|---|---|
| `AddSingleton` | **una sola** para toda la app, mientras esté corriendo | configuración, caché en memoria |
| `AddScoped` | **una por request HTTP**: todos los que la pidan en el mismo request reciben la misma | **`DbContext`**, servicios de negocio |
| `AddTransient` | **una nueva cada vez** que alguien la pide, incluso dentro del mismo request | servicios livianos y sin estado |

> ⚠️ Transient **no** es "uno por request": eso es Scoped. Transient es "uno por **inyección**".
>
> **¿Por qué `DbContext` es Scoped?** Porque **no es thread-safe**, así que no se puede compartir entre requests (por eso no Singleton). Además lleva el seguimiento de los cambios del request y todo se guarda junto en un `SaveChanges`. Si fuera Transient, cada servicio tendría su propio contexto y los cambios no se guardarían juntos.

**Cómo se usa:**
```csharp
// Program.cs
builder.Services.AddScoped<IVentasService, VentasService>();

// En el controller (constructor primario de C# 12)
public class VentasController(IVentasService ventas) : ControllerBase { ... }
```

**Ejercicio 19:** demuestra los 3 ciclos de vida.
1. Crea la carpeta `Services` con una clase `Contador` que tenga `public string Id { get; } = Guid.NewGuid().ToString()[..8];` (cada instancia nueva tiene un Id distinto).
2. Crea 3 clases vacías que hereden de ella: `ContadorSingleton`, `ContadorScoped` y `ContadorTransient`.
3. Regístralas en `Program.cs`, cada una con su ciclo de vida.
4. Crea `DiController` con `GET /api/di` que reciba **dos** de cada una en el constructor y devuelva sus Ids.
- **USA:** `AddSingleton`, `AddScoped`, `AddTransient`, constructor con 6 parámetros
- **ESPERADO:** llama **dos veces** a `GET /api/di`:
  - `singleton`: los 2 Ids iguales, **y los mismos en la segunda llamada**.
  - `scoped`: los 2 Ids iguales entre sí, **pero distintos en la segunda llamada**.
  - `transient`: los 2 Ids **distintos** siempre.

---

## Tema 20. EF Core: entidades y DbContext

**Qué es:** **Entity Framework Core** es un **ORM**: mapea tablas a clases, para que consultes la BD con LINQ en vez de escribir SQL a mano.
- **Entidad** = una clase por tabla, una propiedad por columna (mismo nombre). La propiedad `Id` se reconoce sola como llave primaria.
- **`DbContext`** = la conexión a la BD. Tiene un `DbSet<T>` por tabla.
- Tipos: `nvarchar`/`varchar` → `string`; columna que acepta NULL → `string?` / `int?`; `decimal(10,3)` → `decimal` + `HasPrecision(10, 3)`; `date` → `DateOnly`; `datetime2` → `DateTime`; `bit` → `bool`.
- Hay dos formas de trabajar:
  - **Database First**: la BD ya existe, la mapeas a mano o con `dotnet ef dbcontext scaffold`. Es lo que haces aquí.
  - **Code First**: escribes las clases y EF crea la BD con migraciones (`dotnet ef migrations add`, `dotnet ef database update`).

**Cómo se usa:** mira `Models/Estacion.cs` y `Data/DeltaContext.cs`.
```csharp
public DbSet<Estacion> Estaciones => Set<Estacion>();
// ...
modelBuilder.Entity<Estacion>().ToTable("Estaciones");
```

**Ejercicio 20:** crea `Models/Producto.cs` para la tabla `Productos`, con las columnas `Id, Codigo, Nombre, Categoria, Unidad, PrecioUnitario`. Agrega su `DbSet` en `DeltaContext`, mapéala a la tabla `Productos` y configura la precisión de `PrecioUnitario` (en la BD es `decimal(10,3)`).
- **USA:** clase con propiedades `{ get; set; }`, `DbSet<Producto>`, `ToTable`, `.Property(p => p.PrecioUnitario).HasPrecision(10, 3)`
- **ESPERADO:** `dotnet build` sin errores. Lo pruebas en el tema 21.

---

## Tema 21. EF Core: consultar async y devolver DTOs

**Qué es:** inyectas el `DbContext` en el controller y consultas con LINQ **async**:

| Método | Qué hace |
|---|---|
| `ToListAsync()` | ejecuta y trae una lista |
| `FirstOrDefaultAsync(cond)` | el primero o null |
| `FindAsync(id)` | busca por llave primaria |
| `AnyAsync(cond)` | ¿existe? (`SELECT CASE WHEN EXISTS...`) |
| `CountAsync()` / `SumAsync(...)` | agregados en SQL |

Necesitas `using Microsoft.EntityFrameworkCore;` para los métodos `...Async`.

Arma la consulta como `IQueryable` (puedes ir agregando `Where` según los filtros), proyecta al DTO con `Select`, y **al final** `ToListAsync()`.

**Cómo se usa:** mira `Estaciones` y `Estacion` en `EjemplosController.cs`. Mira también la terminal: ahí sale el `SELECT ... WHERE ...` que generó EF.

**Ejercicio 21:** crea `ProductosController` (`[Route("api/productos")]`) con:
- **a)** `GET /api/productos?categoria=Lubricante`: lista ordenada por Id. Si no mandan categoría, devuelve todos.
- **b)** `GET /api/productos/{id}`: un producto, o **404** si no existe.

Devuelve siempre `ProductoDto`, el del tema 15.
- **USA:** constructor `(DeltaContext db)`, `IQueryable<Producto> query = db.Productos;`, `Where` condicional, `Select(p => new ProductoDto(...))`, `ToListAsync`, `FindAsync`, `NotFound`
- **ESPERADO:**
  - `?categoria=Lubricante` → **200**, 3 productos: Lubricante 20W-50 1qt, Aceite sintético 5W-30, Aditivo de motor
  - sin categoría → **200**, 9 productos
  - `/api/productos/5` → **200** `{"id":5,"codigo":"LUB-2050","nombre":"Lubricante 20W-50 1qt",...}`
  - `/api/productos/99` → **404**

---

## Tema 22. EF Core: relaciones (navegaciones) + GroupBy

**Qué es:** una **propiedad de navegación** representa la llave foránea como un objeto:
```csharp
public class Venta   { public int EstacionId { get; set; }  public Estacion Estacion { get; set; } = null!; }
public class Estacion { public List<Venta> Ventas { get; set; } = []; }
```
EF las conecta solo por convención (`EstacionId` + `Estacion`). Con eso:
- **Dentro de una consulta**, `v.Estacion.Provincia` hace el **JOIN** automáticamente, sin escribir `Join`.
- `Include(v => v.Estacion)` carga la entidad relacionada cuando traes **entidades completas**. Si proyectas con `Select`, no hace falta.
- `GroupBy` + `Select` con `Count()` / `Sum()` se traduce a `GROUP BY` en SQL.

**Cómo se usa:**
```csharp
var porEstacion = await db.Ventas
    .Where(v => v.Fecha >= desde && v.Fecha < hasta)
    .GroupBy(v => v.Estacion.Nombre)
    .Select(g => new { Estacion = g.Key, Total = g.Sum(v => v.Total) })
    .ToListAsync();
```

**Ejercicio 22:**
1. Crea `Models/Venta.cs` con `Id, EstacionId, ClienteId (int?), EmpleadoId, Fecha, Total, MetodoPago, ReferenciaExterna` y la navegación `Estacion`. En `Estacion` agrega `List<Venta> Ventas`. Agrega el `DbSet`, `ToTable("Ventas")` y `HasPrecision(12, 2)` para `Total`.
2. Crea `ReportesController` con `GET /api/reportes/ventas-por-provincia?anio=2026`, que devuelva provincia, cantidad de ventas y total, de mayor a menor total. Si el año no está entre 2000 y 2100, devuelve 400.

Es la misma consulta que el tema 37 de `PRACTICA_SQL.sql`, pero con LINQ.
- **USA:** rango de fechas `new DateTime(anio, 1, 1)` y `.AddYears(1)`, `GroupBy(v => v.Estacion.Provincia)`, `OrderByDescending(g => g.Sum(...))`, `Select` al record `ProvinciaTotalDto(string Provincia, int Ventas, decimal Total)`
- **ESPERADO:** **200**, 8 provincias. Primera `{"provincia":"Panamá","ventas":1715,"total":94992.53}`, última Veraguas (428 | 22044.68).

---

## Tema 23. POST: validar, guardar y responder 201 / 400 / 409

**Qué es:** el flujo de un POST bien hecho:
1. **Validar** la entrada → **400** si algo está mal.
2. **Validar reglas de negocio** contra la BD (¿ya existe?) → **409** si choca.
3. Crear la entidad a partir del request y hacer `db.Add(...)`.
4. `await db.SaveChangesAsync()`: aquí se hace el `INSERT`, y EF llena el `Id` generado.
5. Responder **201** con `CreatedAtAction(...)`, que pone la URL del nuevo en el header `Location`.

**Transacciones:** un solo `SaveChangesAsync()` ya es **atómico**: si guardas 3 cosas y una falla, no se guarda ninguna. Si necesitas **varios** `SaveChanges` como una sola unidad, por ejemplo guardar la venta, usar su Id y después guardar otra tabla, usa una transacción explícita:
```csharp
await using var tx = await db.Database.BeginTransactionAsync();
db.Ventas.Add(venta);
await db.SaveChangesAsync();          // ya tienes venta.Id
db.Sincronizaciones.Add(new SincronizacionErp { VentaId = venta.Id, Estado = "Pendiente" });
await db.SaveChangesAsync();
await tx.CommitAsync();               // si algo fallo antes, al salir sin Commit se hace ROLLBACK
```
(Esto lo vas a necesitar en el `POST /api/ventas` del examen de prueba.)

**Cómo se usa:**
```csharp
[HttpPost]
public async Task<IActionResult> Crear([FromBody] CrearClienteRequest req)
{
    if (string.IsNullOrWhiteSpace(req.Nombre))
        return BadRequest(new { mensaje = "El nombre es obligatorio" });

    if (await db.Clientes.AnyAsync(c => c.Ruc == req.Ruc))
        return Conflict(new { mensaje = "Ya existe un cliente con ese RUC" });

    var cliente = new Cliente { Nombre = req.Nombre, Ruc = req.Ruc, Email = req.Email };
    db.Clientes.Add(cliente);
    await db.SaveChangesAsync();

    return CreatedAtAction(nameof(Obtener), new { id = cliente.Id }, new ClienteDto(cliente.Id, cliente.Nombre));
}
```

**Ejercicio 23:** en `ProductosController` agrega `POST /api/productos`, que reciba `CrearProductoRequest` (del tema 15):
- **400** si `Codigo` o `Nombre` vienen vacíos.
- **400** si `PrecioUnitario` es ≤ 0.
- **409** si ya existe un producto con ese `Codigo`.
- **201** con el `ProductoDto` creado y el header `Location` apuntando a `GET /api/productos/{id}`.
- **USA:** `string.IsNullOrWhiteSpace`, `AnyAsync`, `db.Productos.Add`, `SaveChangesAsync`, `CreatedAtAction(nameof(Obtener), new { id = ... }, dto)`
- **ESPERADO:** las pruebas 23a a 23d de `PracticaApi.http`:
  - 23a → **201** (la primera vez)
  - 23b → **409**
  - 23c → **400** precio
  - 23d → **400** nombre
- **Al terminar**, deja la BD como estaba. En SSMS: `DELETE FROM Productos WHERE Id > 9;`

---

# PARTE 5: Consumir una API

## Tema 24. HttpClient

**Qué es:** `HttpClient` es la clase de .NET para **llamar a otra API**, por ejemplo la del ERP. Con `System.Net.Http.Json` tienes atajos que convierten el JSON solos:

| Método | Qué hace |
|---|---|
| `GetFromJsonAsync<T>(url)` | GET y convierte el JSON a `T` |
| `PostAsJsonAsync(url, objeto)` | POST mandando el objeto como JSON |
| `GetAsync(url)` | GET y te da la respuesta completa (`StatusCode`, headers...) |
| `resp.IsSuccessStatusCode` | ¿fue 2xx? |
| `resp.EnsureSuccessStatusCode()` | lanza excepción si no fue 2xx |

> En una app real **no** hagas `new HttpClient()` en cada llamada, porque se agotan los sockets. Regístralo con `builder.Services.AddHttpClient<ErpClient>(...)`, que es `IHttpClientFactory`. Si el otro servidor no responde, lanza `HttpRequestException`. Lo normal es **reintentar** con espera creciente y, si sigue fallando, registrar el error (como `SincronizacionERP.Intentos` / `UltimoError`).

**Cómo se usa:**
```csharp
using var http = new HttpClient { BaseAddress = new Uri("http://localhost:5100") };
var estaciones = await http.GetFromJsonAsync<List<EstacionDto>>("api/ejemplos/estaciones");
Console.WriteLine(estaciones!.Count);   // 14 (las activas)
```

**Ejercicio 24:** con **tu API corriendo** (tema 21 terminado), en `Consola/Program.cs`:
1. Llama a `GET /api/productos?categoria=Combustible` e imprime cuántos son y sus nombres.
2. Llama a `GET /api/productos/99` e imprime el código de estado.
3. Envuelve todo en `try/catch (HttpRequestException)` e imprime un mensaje si la API no está corriendo.

Necesitas declarar `record ProductoDto(...)` también en la consola.
- **USA:** `HttpClient`, `BaseAddress`, `GetFromJsonAsync<List<ProductoDto>>`, `GetAsync`, `(int)resp.StatusCode`, `try/catch`
- **ESPERADO:**
  ```
  4 productos: Gasolina 91, Gasolina 95, Diésel, Diésel Premium
  Producto 99 -> 404 NotFound
  ```
  Con la API apagada, tu mensaje de error.

---

**FIN.** Si sacaste los 24, ya puedes hacer la **Parte B** de `ENUNCIADO.md` (el examen de prueba) sin mirar nada. 💪
