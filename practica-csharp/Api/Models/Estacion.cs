namespace PracticaApi.Models;

// Ejemplo de entidad: una clase por tabla, una propiedad por columna.
// Tema 20: crea Producto.cs igual a esta.  Tema 22: crea Venta.cs.
public class Estacion
{
    public int Id { get; set; }
    public string Codigo { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Provincia { get; set; } = "";
    public bool Activa { get; set; }
    public DateOnly FechaApertura { get; set; }
}
