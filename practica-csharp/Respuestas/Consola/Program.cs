// =====================================================================
// RESPUESTAS - Parte 1 (C#), Parte 2 (LINQ y async) y Tema 24 (HttpClient)
// Correr:  dotnet run      (desde esta carpeta)
// =====================================================================
using System.Diagnostics;
using System.Globalization;
using System.Net.Http.Json;

CultureInfo.DefaultThreadCurrentCulture = CultureInfo.InvariantCulture; // punto decimal siempre
CultureInfo.CurrentCulture = CultureInfo.InvariantCulture;

// ---------------------------------------------------------------------
// Tema 1. Clases
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 1 ==");
var gas95 = new Producto(1, "Gasolina 95", 1.05m, "Combustible");
Console.WriteLine($"{gas95.Nombre}: {gas95.PrecioConItbms()}");          // 1.12

// ---------------------------------------------------------------------
// Tema 2. Records
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 2 ==");
var r1 = new ResumenEstacion("Delta Tocumen", 4, 203.75m);
var r2 = new ResumenEstacion("Delta Tocumen", 4, 203.75m);
var r3 = r1 with { Ventas = 5 };
Console.WriteLine(r1 == r2);                                              // True
Console.WriteLine(r3);  // ResumenEstacion { Nombre = Delta Tocumen, Ventas = 5, Total = 203.75 }

// ---------------------------------------------------------------------
// Tema 3. List y Dictionary
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 3 ==");
var precios = new Dictionary<string, decimal>
{
    ["GAS-91"] = 0.98m,
    ["GAS-95"] = 1.05m,
    ["DIE-REG"] = 0.92m
};
Console.WriteLine(BuscarPrecio(precios, "GAS-95"));                       // 1.05
Console.WriteLine(BuscarPrecio(precios, "XYZ"));                          // -1

var codigos = new List<string> { "GAS-91", "GAS-95", "DIE-REG" };
codigos.Add("DIE-PRE");
codigos.Remove("GAS-91");
Console.WriteLine($"{codigos.Count} -> {string.Join(", ", codigos)}");    // 3 -> GAS-95, DIE-REG, DIE-PRE

// ---------------------------------------------------------------------
// Tema 4. Nulos
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 4 ==");
string? email = null;
int? clienteId = null;
Console.WriteLine(email?.ToUpper() ?? "SIN CORREO");                      // SIN CORREO
Console.WriteLine(clienteId.HasValue ? $"Cliente {clienteId}" : "Consumidor final"); // Consumidor final

// ---------------------------------------------------------------------
// Tema 5. Excepciones
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 5 ==");
try
{
    ValidarCantidad(-5);
    Console.WriteLine("No deberia llegar aqui");
}
catch (ArgumentOutOfRangeException ex)
{
    Console.WriteLine($"Error: {ex.Message}");   // Error: La cantidad debe ser mayor a 0 (Parameter 'cantidad')
}
finally
{
    Console.WriteLine("Validacion terminada");
}

// ---------------------------------------------------------------------
// Tema 6. Interfaces
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 6 ==");
List<ICalculadoraImpuesto> calculadoras = [new Itbms7(), new Exento()];
foreach (var c in calculadoras)
    Console.WriteLine($"{c.GetType().Name}: {c.Calcular(100m)}");         // Itbms7: 7.00 / Exento: 0

// ---------------------------------------------------------------------
// Datos para LINQ (Temas 7 a 12)
// ---------------------------------------------------------------------
var estaciones = new List<EstacionDemo>
{
    new(1, "Delta Tocumen", "Panamá"),
    new(2, "Delta Chitré", "Herrera"),
    new(3, "Delta Boquete", "Chiriquí"),
    new(4, "Delta Colón 2000", "Colón"),
};
var ventas = new List<VentaDemo>
{
    new(1, 1, "Efectivo", 45.50m,  new DateTime(2026, 11, 1)),
    new(2, 1, "Tarjeta",  120.00m, new DateTime(2026, 11, 1)),
    new(3, 2, "Yappy",    30.25m,  new DateTime(2026, 11, 2)),
    new(4, 3, "Efectivo", 80.00m,  new DateTime(2026, 11, 2)),
    new(5, 1, "Yappy",    15.75m,  new DateTime(2026, 11, 3)),
    new(6, 2, "Tarjeta",  60.00m,  new DateTime(2026, 11, 3)),
    new(7, 3, "Credito",  200.00m, new DateTime(2026, 11, 4)),
    new(8, 1, "Efectivo", 22.50m,  new DateTime(2026, 11, 4)),
};

// ---------------------------------------------------------------------
// Tema 7. Where / OrderBy / Select
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 7 ==");
var idsEfectivo = ventas
    .Where(v => v.MetodoPago == "Efectivo")
    .OrderByDescending(v => v.Total)
    .Select(v => v.Id)
    .ToList();
Console.WriteLine(string.Join(", ", idsEfectivo));                        // 4, 1, 8

// ---------------------------------------------------------------------
// Tema 8. Any / Count / FirstOrDefault
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 8 ==");
Console.WriteLine(ventas.Any(v => v.Total > 150));                        // True
Console.WriteLine(ventas.Count(v => v.MetodoPago == "Yappy"));            // 2
var venta99 = ventas.FirstOrDefault(v => v.Id == 99);
Console.WriteLine(venta99 is null ? "No existe" : venta99.ToString());   // No existe

// ---------------------------------------------------------------------
// Tema 9. Sum / Average / Max
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 9 ==");
Console.WriteLine($"{ventas.Sum(v => v.Total)} | {ventas.Average(v => v.Total)} | {ventas.Max(v => v.Total)}");
// 574.00 | 71.75 | 200.00

// ---------------------------------------------------------------------
// Tema 10. GroupBy
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 10 ==");
var porMetodo = ventas
    .GroupBy(v => v.MetodoPago)
    .Select(g => new { Metodo = g.Key, Cantidad = g.Count(), Total = g.Sum(v => v.Total) })
    .OrderByDescending(x => x.Total);
foreach (var m in porMetodo)
    Console.WriteLine($"{m.Metodo}: {m.Cantidad} | {m.Total}");
// Credito: 1 | 200.00 / Tarjeta: 2 | 180.00 / Efectivo: 3 | 148.00 / Yappy: 2 | 46.00

// ---------------------------------------------------------------------
// Tema 11. Join
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 11 ==");
var porEstacion = ventas
    .Join(estaciones, v => v.EstacionId, e => e.Id, (v, e) => new { e.Nombre, v.Total })
    .GroupBy(x => x.Nombre)
    .Select(g => new { Estacion = g.Key, Total = g.Sum(x => x.Total) })
    .OrderByDescending(x => x.Total);
foreach (var e in porEstacion)
    Console.WriteLine($"{e.Estacion}: {e.Total}");
// Delta Boquete: 280.00 / Delta Tocumen: 203.75 / Delta Chitré: 90.25  (Colón no sale: INNER)

// ---------------------------------------------------------------------
// Tema 12. Ejecucion diferida
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 12 ==");
var consulta = ventas.Where(v => v.Total > 100);      // todavia NO se ejecuta
var foto = consulta.ToList();                          // aqui SI se ejecuta (2 ventas)
ventas.Add(new VentaDemo(9, 4, "Tarjeta", 150m, new DateTime(2026, 11, 5)));
Console.WriteLine($"consulta: {consulta.Count()} | foto: {foto.Count}"); // consulta: 3 | foto: 2
ventas.RemoveAt(ventas.Count - 1);

// ---------------------------------------------------------------------
// Tema 13. async / await
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 13 ==");
var sw = Stopwatch.StartNew();
await EnviarAlErpAsync(1);
await EnviarAlErpAsync(2);
await EnviarAlErpAsync(3);
Console.WriteLine($"Uno por uno: ~{sw.ElapsedMilliseconds / 100 * 100} ms");      // ~1500 ms

sw.Restart();
var resultados = await Task.WhenAll(EnviarAlErpAsync(1), EnviarAlErpAsync(2), EnviarAlErpAsync(3));
Console.WriteLine($"En paralelo: ~{sw.ElapsedMilliseconds / 100 * 100} ms");      // ~500 ms
Console.WriteLine(string.Join(", ", resultados));     // Venta 1 enviada, Venta 2 enviada, Venta 3 enviada

// ---------------------------------------------------------------------
// Tema 24. HttpClient (necesita la API de respuestas corriendo en :5200)
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 24 ==");
using var http = new HttpClient { BaseAddress = new Uri("http://localhost:5200") };
try
{
    var combustibles = await http.GetFromJsonAsync<List<ProductoDto>>("api/productos?categoria=Combustible");
    Console.WriteLine($"{combustibles!.Count} productos: {string.Join(", ", combustibles.Select(p => p.Nombre))}");
    // 4 productos: Gasolina 91, Gasolina 95, Diésel, Diésel Premium

    var respuesta = await http.GetAsync("api/productos/99");
    Console.WriteLine($"Producto 99 -> {(int)respuesta.StatusCode} {respuesta.StatusCode}");  // 404 NotFound
}
catch (HttpRequestException)
{
    Console.WriteLine("La API no esta corriendo. Levantala con 'dotnet run' en Respuestas/Api.");
}

// =====================================================================
// Metodos y tipos
// =====================================================================
static decimal BuscarPrecio(Dictionary<string, decimal> precios, string codigo)
    => precios.TryGetValue(codigo, out var precio) ? precio : -1;

static void ValidarCantidad(decimal cantidad)
{
    if (cantidad <= 0)
        throw new ArgumentOutOfRangeException(nameof(cantidad), "La cantidad debe ser mayor a 0");
}

static async Task<string> EnviarAlErpAsync(int ventaId)
{
    await Task.Delay(500);            // simula que el ERP tarda medio segundo en responder
    return $"Venta {ventaId} enviada";
}

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

record ResumenEstacion(string Nombre, int Ventas, decimal Total);

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

record EstacionDemo(int Id, string Nombre, string Provincia);
record VentaDemo(int Id, int EstacionId, string MetodoPago, decimal Total, DateTime Fecha);
record ProductoDto(int Id, string Codigo, string Nombre, string Categoria, decimal PrecioUnitario);
