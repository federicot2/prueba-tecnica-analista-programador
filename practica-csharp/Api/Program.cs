using Microsoft.EntityFrameworkCore;
using PracticaApi.Data;

var builder = WebApplication.CreateBuilder(args);

// Activa los controllers (las clases en la carpeta Controllers)
builder.Services.AddControllers();

// Registra el DbContext para que se pueda inyectar en los controllers.
// La cadena de conexion "DeltaDb" esta en appsettings.json
builder.Services.AddDbContext<DeltaContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DeltaDb")));

// Tema 19: registra aqui tus servicios (AddSingleton / AddScoped / AddTransient)


var app = builder.Build();

app.MapControllers();

app.Run();
