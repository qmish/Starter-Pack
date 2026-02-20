using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService(
        serviceName: Environment.GetEnvironmentVariable("OTEL_SERVICE_NAME") ?? "dotnet-demo"))
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddOtlpExporter())
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddOtlpExporter());

var app = builder.Build();

app.MapGet("/health", () => new
{
    status = "ok",
    service = Environment.GetEnvironmentVariable("OTEL_SERVICE_NAME") ?? "dotnet-demo"
});

app.MapGet("/", () => new
{
    message = "SigNoz .NET demo",
    service = Environment.GetEnvironmentVariable("OTEL_SERVICE_NAME") ?? "dotnet-demo",
    path = "/"
});

app.MapGet("/{*path}", (string path) => new
{
    message = "SigNoz .NET demo",
    service = Environment.GetEnvironmentVariable("OTEL_SERVICE_NAME") ?? "dotnet-demo",
    path = "/" + path
});

app.Run("http://0.0.0.0:" + (Environment.GetEnvironmentVariable("PORT") ?? "8080"));
