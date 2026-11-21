using Microsoft.EntityFrameworkCore;
using RespuestasApi.Data;
using RespuestasApi.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

// Tema 20: registrar el DbContext (Scoped por defecto: uno por request)
builder.Services.AddDbContext<DeltaContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DeltaDb")));

// Tema 19: los tres ciclos de vida
builder.Services.AddSingleton<ContadorSingleton>();
builder.Services.AddScoped<ContadorScoped>();
builder.Services.AddTransient<ContadorTransient>();

var app = builder.Build();

app.MapControllers();

app.Run();
