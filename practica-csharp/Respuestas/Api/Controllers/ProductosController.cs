using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RespuestasApi.Data;
using RespuestasApi.Dtos;
using RespuestasApi.Models;

namespace RespuestasApi.Controllers;

[ApiController]
[Route("api/productos")]
public class ProductosController(DeltaContext db) : ControllerBase
{
    // Tema 21: GET /api/productos?categoria=Lubricante
    [HttpGet]
    public async Task<ActionResult<List<ProductoDto>>> Listar([FromQuery] string? categoria)
    {
        IQueryable<Producto> query = db.Productos;              // IQueryable: el filtro va a SQL

        if (!string.IsNullOrWhiteSpace(categoria))
            query = query.Where(p => p.Categoria == categoria);

        var lista = await query
            .OrderBy(p => p.Id)
            .Select(p => new ProductoDto(p.Id, p.Codigo, p.Nombre, p.Categoria, p.PrecioUnitario))
            .ToListAsync();                                     // aqui se ejecuta la consulta

        return Ok(lista);
    }

    // Tema 21: GET /api/productos/5   y   /api/productos/99 -> 404
    [HttpGet("{id:int}")]
    public async Task<ActionResult<ProductoDto>> Obtener(int id)
    {
        var p = await db.Productos.FindAsync(id);

        if (p is null)
            return NotFound(new { mensaje = $"No existe el producto {id}" });

        return Ok(new ProductoDto(p.Id, p.Codigo, p.Nombre, p.Categoria, p.PrecioUnitario));
    }

    // Tema 23: POST /api/productos  -> 201 / 400 / 409
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
        await db.SaveChangesAsync();                            // INSERT + SQL genera el Id

        var dto = new ProductoDto(producto.Id, producto.Codigo, producto.Nombre,
                                  producto.Categoria, producto.PrecioUnitario);
        return CreatedAtAction(nameof(Obtener), new { id = producto.Id }, dto);
    }
}
