namespace RespuestasApi.Models;

// Tema 20/22: una clase por tabla. Los nombres de propiedad = nombres de columna.

public class Estacion
{
    public int Id { get; set; }
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Provincia { get; set; } = "";
    public bool Activa { get; set; }
    public DateOnly FechaApertura { get; set; }

    public List<Venta> Ventas { get; set; } = [];      // Tema 22: navegacion 1 -> muchos
}

public class Producto                                   // Tema 20
{
    public int Id { get; set; }
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Categoria { get; set; } = "";
    public string Unidad { get; set; } = "";
    public decimal PrecioUnitario { get; set; }
}

public class Venta                                      // Tema 22
{
    public int Id { get; set; }
    public int EstacionId { get; set; }
    public int? ClienteId { get; set; }                 // puede ser NULL -> int?
    public int EmpleadoId { get; set; }
    public DateTime Fecha { get; set; }
    public decimal Total { get; set; }
    public string MetodoPago { get; set; } = "";
    public string ReferenciaExterna { get; set; } = "";

    public Estacion Estacion { get; set; } = null!;     // navegacion muchos -> 1
}
