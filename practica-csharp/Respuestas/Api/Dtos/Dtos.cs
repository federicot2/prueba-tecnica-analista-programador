namespace RespuestasApi.Dtos;

// DTO = lo que entra o sale por la API. Nunca devuelvas la entidad directo.

public record SumarRequest(decimal A, decimal B);                                   // Tema 17

public record ProductoDto(int Id, string Codigo, string Nombre, string Categoria, decimal PrecioUnitario); // Tema 21

public record CrearProductoRequest(string Codigo, string Nombre, string Categoria,    // Tema 23
                                   string Unidad, decimal PrecioUnitario);

public record ProvinciaTotalDto(string Provincia, int Ventas, decimal Total);       // Tema 22
