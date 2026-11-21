using Microsoft.EntityFrameworkCore;
using PracticaApi.Models;

namespace PracticaApi.Data;

// El DbContext es tu "puerta" a la base de datos.
// Cada DbSet<T> representa una tabla.
public class DeltaContext(DbContextOptions<DeltaContext> options) : DbContext(options)
{
    public DbSet<Estacion> Estaciones => Set<Estacion>();

    // Tema 20: agrega aqui el DbSet de Productos
    // Tema 22: agrega aqui el DbSet de Ventas

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Estacion>().ToTable("Estaciones");

        // Tema 20/22: configura aqui la precision de los decimales (HasPrecision)
    }
}
