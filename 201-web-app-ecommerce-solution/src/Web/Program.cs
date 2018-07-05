using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore;
using Microsoft.Extensions.DependencyInjection;
using Infrastructure.Data;
using System;
using Microsoft.Extensions.Logging;
using Infrastructure.Identity;
using Microsoft.AspNetCore.Identity;
using Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Builder;
using Infrastructure.Interfaces;

namespace Microsoft.eShopWeb
{
    public class Program
    {
        public static IConfiguration Configuration { get; set; }

        public static void Main(string[] args)
        {
            var host = BuildWebHost(args);

            using (var scope = host.Services.CreateScope())
            {
                var services = scope.ServiceProvider;
                var loggerFactory = services.GetRequiredService<ILoggerFactory>();
                try
                {
                    var catalogContext = services.GetRequiredService<CatalogContext>();
                    catalogContext.Database.MigrateAsync().Wait();

                    var searchSvc = services.GetRequiredService<SearchService>();
                    var storageSvc = services.GetRequiredService<ICloudStorageService>();

                    CatalogContextSeed.SeedAsync(catalogContext, searchSvc, storageSvc, loggerFactory).Wait();

                    var appIdentityDbContext = services.GetRequiredService<AppIdentityDbContext>();
                    appIdentityDbContext.Database.MigrateAsync().Wait();

                    var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();
                    AppIdentityDbContextSeed.SeedAsync(userManager).Wait();
                }
                catch (Exception ex)
                {
                    var logger = loggerFactory.CreateLogger<Program>();
                    logger.LogError(ex, "An error occurred seeding the DB.");
                }
            }

            host.Run();
        }

        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
            .UseApplicationInsights()
            .UseUrls("http://0.0.0.0:5106")
            .UseStartup<Startup>()
            .Build();
    }
}
