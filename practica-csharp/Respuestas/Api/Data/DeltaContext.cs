using Microsoft.EntityFrameworkCore;
using RespuestasApi.Models;

namespace RespuestasApi.Data;

public class DeltaContext(DbContextOptions<DeltaContext> options) : DbContext(options)
{
    // El nombre del DbSet = nombre de la tabla
    public DbSet<Estacion> Estaciones => Set<Estacion>();
    public DbSet<Producto> Productos => Set<Producto>();   // Tema 20
    public DbSet<Venta> Ventas => Set<Venta>();            // Tema 22

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Estacion>().ToTable("Estaciones");
        modelBuilder.Entity<Producto>().ToTable("Productos");
        modelBuilder.Entity<Venta>().ToTable("Ventas");

        // decimales: misma precision que en SQL
        modelBuilder.Entity<Producto>().Property(p => p.PrecioUnitario).HasPrecision(10, 3);
        modelBuilder.Entity<Venta>().Property(v => v.Total).HasPrecision(12, 2);
    }
}
