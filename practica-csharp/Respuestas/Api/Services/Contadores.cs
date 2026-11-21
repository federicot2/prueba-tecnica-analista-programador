namespace RespuestasApi.Services;

// Tema 19: cada instancia nueva genera un Id distinto.
// Si dos inyecciones muestran el mismo Id, es la MISMA instancia.
public class Contador
{
    public string Id { get; } = Guid.NewGuid().ToString()[..8];
}

public class ContadorSingleton : Contador { }
public class ContadorScoped : Contador { }
public class ContadorTransient : Contador { }
