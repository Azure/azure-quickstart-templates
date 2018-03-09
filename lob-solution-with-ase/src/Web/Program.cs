/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Interfaces;
using Infrastructure.Data;
using Infrastructure.Identity;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;

namespace Microsoft.eShopWeb
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var host = BuildWebHost(args);

            using (var scope = host.Services.CreateScope())
            {
                var services = scope.ServiceProvider;
                var loggerFactory = services.GetRequiredService<ILoggerFactory>();
                try
                {
                    var storageService = services.GetRequiredService<IStorageService>();
                    ProductImagesSeed.SeedAsync(storageService, "images", "products", loggerFactory).Wait();

                    var catalogContext = services.GetRequiredService<CatalogContext>();
                    catalogContext.Database.EnsureCreated();
                    CatalogContextSeed.SeedAsync(catalogContext, loggerFactory).Wait();

                    var salesContext = services.GetRequiredService<SalesContext>();
                    salesContext.Database.EnsureCreated();
                    SalesContextSeed.SeedAsync(catalogContext, salesContext, loggerFactory).Wait();

                    var identityContext = services.GetRequiredService<AppIdentityDbContext>();
                    identityContext.Database.EnsureCreated();

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
