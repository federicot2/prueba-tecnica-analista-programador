# Prueba Técnica — Analista Programador (práctica)

Entorno de práctica para una prueba técnica de **Analista Programador**: .NET, SQL Server, APIs,
integración con ERP y Power Platform (SharePoint, Power Automate, Power Apps).

## Contenido

| Ruta | Qué es |
|---|---|
| [`GUIA_ESTUDIO.md`](GUIA_ESTUDIO.md) | Cheat sheet de los 4 temas, ejercicios con soluciones y preguntas de entrevista |
| [`ENUNCIADO.md`](ENUNCIADO.md) | Prueba simulada: 2 h 30 min, 100 puntos (SQL, Web API .NET, integración y Power Platform) |
| [`db/01_crear_base_datos.sql`](db/01_crear_base_datos.sql) | Crea la BD `DeltaPractica`: 15 estaciones, ~6,000 ventas de 2026, staging ERP (datos ficticios) |
| [`api/`](api/) | Proyecto ASP.NET Core (.NET 10) con EF Core y la cadena de conexión configurada |
| [`respuestas/`](respuestas/) | Donde se escriben las respuestas de la prueba |

## Requisitos
- SQL Server 2022 Express → `localhost\SQLEXPRESS`, autenticación de Windows
- SSMS 22 o VS Code con la extensión SQL Server (mssql)
- .NET 10 SDK + `dotnet-ef` (`dotnet tool install --global dotnet-ef`)
- Postman (opcional)

## Cómo empezar
1. Crea la base de datos (también sirve para reiniciarla, borra y recrea todo):
   ```
   sqlcmd -S localhost\SQLEXPRESS -E -C -i db\01_crear_base_datos.sql
   ```
   O ábrelo en SSMS: Server name `localhost\SQLEXPRESS`, *Windows Authentication*,
   marca **Trust server certificate** y ejecuta el script.
2. Lee `ENUNCIADO.md` y pon un cronómetro de **2 h 30 min**.
3. **SQL:** respuestas en `respuestas/parte_a.sql`.
4. **API:** en `api/` ejecuta `dotnet run` (http://localhost:5045) y prueba con `DeltaApi.http` o Postman.
   Scaffold opcional de las entidades (desde `api/`):
   ```
   dotnet ef dbcontext scaffold "Name=ConnectionStrings:DeltaDb" Microsoft.EntityFrameworkCore.SqlServer -o Models
   ```
5. **Escrito:** `respuestas/parte_c.md`.
