using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RespuestasApi.Data;
using RespuestasApi.Dtos;

namespace RespuestasApi.Controllers;

[ApiController]
[Route("api/reportes")]
public class ReportesController(DeltaContext db) : ControllerBase
{
    // Tema 22: GET /api/reportes/ventas-por-provincia?anio=2026
    // Es la misma consulta que el tema 37 de PRACTICA_SQL.sql, pero con LINQ.
    [HttpGet("ventas-por-provincia")]
    public async Task<ActionResult<List<ProvinciaTotalDto>>> VentasPorProvincia([FromQuery] int anio)
    {
        if (anio < 2000 || anio > 2100)
            return BadRequest(new { mensaje = "Anio invalido" });

        var desde = new DateTime(anio, 1, 1);
        var hasta = desde.AddYears(1);                          // rango >= y <, igual que en SQL

        var datos = await db.Ventas
            .Where(v => v.Fecha >= desde && v.Fecha < hasta)
            .GroupBy(v => v.Estacion.Provincia)                 // la navegacion hace el JOIN
            .OrderByDescending(g => g.Sum(v => v.Total))
            .Select(g => new ProvinciaTotalDto(g.Key, g.Count(), g.Sum(v => v.Total)))
            .ToListAsync();

        return Ok(datos);
    }
}
