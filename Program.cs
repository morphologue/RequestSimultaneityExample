using Microsoft.AspNetCore.Server.Kestrel.Core;

var builder = WebApplication.CreateBuilder(args);

builder
    .WebHost
    .UseUrls("https://+:443")
    .ConfigureKestrel((_, options) =>
    {
        options.ListenAnyIP(443, listenOptions =>
        {
            listenOptions.Protocols = Enum.Parse<HttpProtocols>($"Http{Environment.GetEnvironmentVariable("HTTP_VERSION")}");
            listenOptions.UseHttps("localhost.pfx");
        });
    });

var app = builder.Build();

app.UseDefaultFiles();
app.UseStaticFiles();

app.MapPost("/sink", async () =>
{
    await Task.Delay(100);
    return "Done";
});

app.Run();
