// =====================================================================
// PRACTICA C# - Partes 1 y 2 (temas 1 a 13) y tema 24
// La explicacion de cada tema esta en ../PRACTICA_CSHARP.md
//
// Correr:  dotnet run      (desde esta carpeta, en la terminal de VS Code)
// Escribe cada ejercicio debajo de su "Tu respuesta" y vuelve a correr.
// Las clases, interfaces y metodos que crees van ABAJO DEL TODO del archivo.
// =====================================================================
using System.Diagnostics;
using System.Globalization;
using System.Net.Http.Json;

CultureInfo.CurrentCulture = CultureInfo.InvariantCulture; // punto decimal siempre

// ---------------------------------------------------------------------
// Tema 1. Clases
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 1 ==");
// Tu respuesta:
var c = new Producto(1,"Gasolina 95",1.05m,"95");
Console.WriteLine(c.PrecioConItbms());

// ---------------------------------------------------------------------
// Tema 2. Records
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 2 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 3. List y Dictionary
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 3 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 4. Nulos
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 4 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 5. Excepciones
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 5 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 6. Interfaces
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 6 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Datos para LINQ (Temas 7 a 12) - NO los cambies, los ESPERADO salen de aqui
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
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 8. Any / Count / FirstOrDefault
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 8 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 9. Sum / Average / Max
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 9 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 10. GroupBy
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 10 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 11. Join
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 11 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 12. Ejecucion diferida
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 12 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 13. async / await
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 13 ==");
// Tu respuesta:


// ---------------------------------------------------------------------
// Tema 24. HttpClient (lo haces al final: necesita tu API corriendo en :5100)
// ---------------------------------------------------------------------
Console.WriteLine("== Tema 24 ==");
// Tu respuesta:




// =====================================================================
// AQUI ABAJO VAN TUS CLASES, RECORDS, INTERFACES Y METODOS static
// =====================================================================

record EstacionDemo(int Id, string Nombre, string Provincia);
record VentaDemo(int Id, int EstacionId, string MetodoPago, decimal Total, DateTime Fecha);

class Producto
{
    public int Id {get;}
    public string Nombre {get;set;}
    public decimal Precio {get; set;}
    public string Categoria {get;set;}

    public Producto (int id, string nombre, decimal precio, string categoria)
    {
        Id=id;
        Nombre=nombre;
        Precio=precio;
        Categoria=categoria;
    }

    public string PrecioConItbms() => $"Gasolina 95:, {(Math.Round(Precio * 1.07m, 2))}";

}