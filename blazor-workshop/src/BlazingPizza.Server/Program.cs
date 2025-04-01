using BlazingPizza.Server;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseSentry(o =>
{
    o.Dsn = Environment.GetEnvironmentVariable("SENTRY_DSN");
    o.Environment = Environment.GetEnvironmentVariable("SENTRY_ENVIRONMENT");
    o.Release = Environment.GetEnvironmentVariable("SENTRY_RELEASE");
    o.Debug = builder.Environment.IsDevelopment();
    o.TracesSampleRate = 1.0;
    o.SendDefaultPii = true;
});
builder.Services.AddControllersWithViews()
    .AddJsonOptions(options => {
        options.JsonSerializerOptions.AddContext<BlazingPizza.OrderContext>();
    });
builder.Services.AddRazorPages();

builder.Services.AddDbContext<PizzaStoreContext>(options =>
    options.UseSqlite("Data Source=pizza.db")
        .UseModel(BlazingPizza.Server.Models.PizzaStoreContextModel.Instance));

builder.Services.AddDefaultIdentity<PizzaStoreUser>(options => options.SignIn.RequireConfirmedAccount = true)
    .AddEntityFrameworkStores<PizzaStoreContext>();


builder.Services.AddIdentityServer()
    .AddApiAuthorization<PizzaStoreUser, PizzaStoreContext>()
    .AddDeveloperSigningCredential();

builder.Services.AddAuthentication()
    .AddIdentityServerJwt();

var app = builder.Build();

var scopeFactory = app.Services.GetRequiredService<IServiceScopeFactory>();
using (var scope = scopeFactory.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<PizzaStoreContext>();
    if (db.Database.EnsureCreated())
    {
        SeedData.Initialize(db);
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseWebAssemblyDebugging();
}
else
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseBlazorFrameworkFiles();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseIdentityServer();
app.UseAuthorization();

app.MapPizzaApi();
app.MapRazorPages();
app.MapControllers();
app.MapFallbackToFile("index.html");

app.Run();
