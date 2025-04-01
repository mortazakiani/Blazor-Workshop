using BlazingPizza.Client;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Authentication;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.Extensions.DependencyInjection;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });
builder.Services.AddHttpClient<OrdersClient>(client => client.BaseAddress = new Uri(builder.HostEnvironment.BaseAddress))
        .AddHttpMessageHandler<BaseAddressAuthorizationMessageHandler>();
builder.Services.AddScoped<OrderState>();

// Add auth services
builder.Services.AddApiAuthorization<PizzaAuthenticationState>(options => {
    options.AuthenticationPaths.LogOutSucceededPath = "";
});

await builder.Build().RunAsync();


builder.Services.AddSentry(options =>
{
    options.Dsn = Environment.GetEnvironmentVariable("SENTRY_DSN");
    options.Environment = Environment.GetEnvironmentVariable("SENTRY_ENVIRONMENT");
    options.Release = Environment.GetEnvironmentVariable("SENTRY_RELEASE");
    options.Debug = builder.HostEnvironment.IsDevelopment();
    options.TracesSampleRate = 1.0;
});