using Microsoft.AspNetCore.Mvc;
using RespuestasApi.Dtos;
using RespuestasApi.Services;

namespace RespuestasApi.Controllers;

// Tema 16: GET simple con parametro en la ruta
[ApiController]
[Route("api/saludo")]
public class SaludoController : ControllerBase
{
    [HttpGet("{nombre}")]
    public IActionResult Saludar(string nombre)
        => Ok(new { mensaje = $"Hola, {nombre}" });
}

// Temas 17 y 18: query string, body y codigos de estado
[ApiController]
[Route("api/calculadora")]
public class CalculadoraController : ControllerBase
{
    // Tema 17: GET /api/calculadora/itbms?monto=100
    [HttpGet("itbms")]
    public IActionResult Itbms([FromQuery] decimal monto)
    {
        var itbms = Math.Round(monto * 0.07m, 2);
        return Ok(new { monto, itbms, total = monto + itbms });
    }

    // Tema 17: POST /api/calculadora/sumar   body: { "a": 2.5, "b": 4 }
    [HttpPost("sumar")]
    public IActionResult Sumar([FromBody] SumarRequest req)
        => Ok(new { resultado = req.A + req.B });

    // Tema 18: GET /api/calculadora/dividir?a=10&b=0  -> 400
    [HttpGet("dividir")]
    public IActionResult Dividir([FromQuery] decimal a, [FromQuery] decimal b)
    {
        if (b == 0)
            return BadRequest(new { mensaje = "No se puede dividir entre 0" });

        return Ok(new { resultado = a / b });
    }
}

// Tema 19: ciclos de vida de la inyeccion de dependencias
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
        singleton = new[] { singleton1.Id, singleton2.Id },  // iguales, y siempre los mismos
        scoped    = new[] { scoped1.Id, scoped2.Id },        // iguales dentro del request, cambian en el siguiente
        transient = new[] { transient1.Id, transient2.Id }   // siempre distintos
    });
}
