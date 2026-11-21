using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PracticaApi.Data;

namespace PracticaApi.Controllers;

// =====================================================================
// EJEMPLOS de los temas 16 a 23. Pruebalos con PracticaApi.http.
// Tus ejercicios van en controllers NUEVOS (crea un archivo por controller).
// =====================================================================
[ApiController]
[Route("api/ejemplos")]
public class EjemplosController(DeltaContext db) : ControllerBase
{
    // Tema 16: GET simple  ->  GET /api/ejemplos/hola
    [HttpGet("hola")]
    public IActionResult Hola() => Ok(new { mensaje = "Hola desde la API" });

    // Tema 17: parametro en la RUTA  ->  GET /api/ejemplos/doble/21
    [HttpGet("doble/{numero:int}")]
    public IActionResult Doble(int numero) => Ok(new { numero, doble = numero * 2 });

    // Tema 17: parametro en la QUERY STRING  ->  GET /api/ejemplos/repetir?texto=hola&veces=3
    [HttpGet("repetir")]
    public IActionResult Repetir([FromQuery] string texto, [FromQuery] int veces = 2)
        => Ok(new { resultado = string.Concat(Enumerable.Repeat(texto, veces)) });

    // Tema 17: datos en el BODY (JSON)  ->  POST /api/ejemplos/eco
    [HttpPost("eco")]
    public IActionResult Eco([FromBody] EcoRequest req) => Ok(new { recibido = req.Mensaje, largo = req.Mensaje.Length });

    // Tema 18: codigos de estado  ->  GET /api/ejemplos/edad/15
    [HttpGet("edad/{edad:int}")]
    public IActionResult Edad(int edad)
    {
        if (edad < 0)
            return BadRequest(new { mensaje = "La edad no puede ser negativa" });   // 400

        return Ok(new { edad, mayorDeEdad = edad >= 18 });                        // 200
    }

    // Tema 21: EF Core - listar con filtro, async y DTO  ->  GET /api/ejemplos/estaciones?provincia=Colón
    [HttpGet("estaciones")]
    public async Task<IActionResult> Estaciones([FromQuery] string? provincia)
    {
        var query = db.Estaciones.Where(e => e.Activa);          // IQueryable: aun no va a la BD

        if (!string.IsNullOrWhiteSpace(provincia))
            query = query.Where(e => e.Provincia == provincia);

        var lista = await query
            .OrderBy(e => e.Nombre)
            .Select(e => new EstacionDto(e.Id, e.Codigo, e.Nombre, e.Provincia))
            .ToListAsync();                                      // AQUI se ejecuta el SELECT

        return Ok(lista);
    }

    // Tema 21: buscar por Id y 404  ->  GET /api/ejemplos/estaciones/3   y   /api/ejemplos/estaciones/99
    [HttpGet("estaciones/{id:int}")]
    public async Task<IActionResult> Estacion(int id)
    {
        var e = await db.Estaciones.FindAsync(id);

        if (e is null)
            return NotFound(new { mensaje = $"No existe la estacion {id}" });     // 404

        return Ok(new EstacionDto(e.Id, e.Codigo, e.Nombre, e.Provincia));
    }
}

public record EcoRequest(string Mensaje);
public record EstacionDto(int Id, string Codigo, string Nombre, string Provincia);
