/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Entities.OrderAggregate;
using ApplicationCore.Interfaces;
using ApplicationCore.Services;
using Infrastructure.Data;
using Infrastructure.Identity;
using Infrastructure.Logging;
using Infrastructure.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.eShopWeb.Interfaces;
using Microsoft.eShopWeb.Middlewares;
using Microsoft.eShopWeb.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using Web.Middlewares;

namespace Microsoft.eShopWeb
{
    public class Startup
    {
        private IServiceCollection _services;
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureDevelopmentServices(IServiceCollection services)
        {
            // use real database
            services.AddDbContext<CatalogContext>(c =>
                    c.UseSqlServer(Configuration.GetConnectionString("CatalogConnection")));
            services.AddDbContext<SalesContext>(c =>
                    c.UseSqlServer(Configuration.GetConnectionString("SalesConnection")));

            // Add Identity DbContext
            services.AddDbContext<AppIdentityDbContext>(options =>
                options.UseSqlServer(Configuration.GetConnectionString("IdentityConnection")));

            // Add memory cache services
            services.AddMemoryCache();

            var storageConnection = Configuration.GetConnectionString("StorageConnection");
            services.AddSingleton<IUriComposer>(new CloudStorageImageUriComposer(storageConnection));

            ConfigureServices(services);
        }

        public void ConfigureTestingServices(IServiceCollection services)
        {
            // use in-memory database
            services.AddDbContext<CatalogContext>(c =>
                c.UseInMemoryDatabase("Catalog"));
            services.AddDbContext<SalesContext>(c =>
                c.UseInMemoryDatabase("Sales"));

            // Add Identity DbContext
            services.AddDbContext<AppIdentityDbContext>(options =>
                options.UseInMemoryDatabase("Identity"));

            // Add memory cache services
            services.AddMemoryCache();

            ConfigureServices(services);
        }

        public void ConfigureProductionServices(IServiceCollection services)
        {
            // use real database
            services.AddDbContext<CatalogContext>(c =>
                    c.UseSqlServer(Configuration.GetConnectionString("CatalogConnection")));
            services.AddDbContext<SalesContext>(c =>
                    c.UseSqlServer(Configuration.GetConnectionString("SalesConnection")));

            // Add Identity DbContext
            services.AddDbContext<AppIdentityDbContext>(options =>
                options.UseSqlServer(Configuration.GetConnectionString("IdentityConnection")));

            // Add Redis cahce
            services.AddDistributedRedisCache(options =>
            {
                options.Configuration = Configuration.GetConnectionString("RedisConnection");
                options.InstanceName = "master";
            });

            services.AddSingleton<IUriComposer>(new UriComposer(Configuration.Get<CatalogSettings>()));

            ConfigureServices(services);
        }

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddIdentity<ApplicationUser, IdentityRole>()
                .AddEntityFrameworkStores<AppIdentityDbContext>()
                .AddDefaultTokenProviders();

            services.ConfigureApplicationCookie(options =>
            {
                options.Cookie.HttpOnly = true;
                options.ExpireTimeSpan = TimeSpan.FromHours(1);
                options.LoginPath = "/Account/Signin";
                options.LogoutPath = "/Account/Signout";
            });

            //services.Configure<AuthenticationOptions>(o =>
            //{
            //    o.SchemeMap.Remove(IdentityConstants.ApplicationScheme);
            //    o.AddScheme<CookieAuthenticationHandler>(IdentityConstants.ApplicationScheme, "");

            //});

            // Add scoped for IRepository<> and IAsyncRepository<> dynamically, as we have more than one database contexts.
            var dbContextTypes = new[] { typeof(CatalogContext), typeof(SalesContext) };
            foreach (var dbContextType in dbContextTypes)
            {
                var entityTypes = dbContextType.GetProperties()
                    .Select(p => p.PropertyType)
                    .Where(t => t.IsGenericType)
                    .Where(t => t.GetGenericTypeDefinition() == typeof(DbSet<>))
                    .Select(t => t.GetGenericArguments().FirstOrDefault())
                    .Where(t => t != typeof(Order) && t != typeof(OrderItem))
                    .ToArray();
                foreach (var entityType in entityTypes)
                {
                    var repositoryType = typeof(IRepository<>).MakeGenericType(entityType);
                    var asyncRepository = typeof(IAsyncRepository<>).MakeGenericType(entityType);
                    var efRepositoryType = typeof(EfRepository<,>).MakeGenericType(dbContextType, entityType);
                    services.AddScoped(repositoryType, efRepositoryType);
                    services.AddScoped(asyncRepository, efRepositoryType);
                }
            }

            var oDataServiceBaseUrl = Configuration.GetValue<string>("ODataServiceBaseUrl");
            Func<IServiceProvider, ODataOrderRepository> createOrderRepository = p => new ODataOrderRepository(new Uri(oDataServiceBaseUrl));
            services.AddScoped<IRepository<Order>>(createOrderRepository);
            services.AddScoped<IAsyncRepository<Order>>(createOrderRepository);
            services.AddScoped<IOrderRepository>(createOrderRepository);

            services.AddScoped<ICatalogService, CachedCatalogService>();
            services.AddScoped<IBasketService, BasketService>();
            services.AddScoped<IBasketViewModelService, BasketViewModelService>();
            services.AddScoped<IOrderService, OrderService>();

            services.AddScoped<CatalogService>();
            services.Configure<CatalogSettings>(Configuration);

            services.AddScoped(typeof(IAppLogger<>), typeof(LoggerAdapter<>));
            services.AddTransient<IEmailSender, EmailSender>();

            var storageConnection = Configuration.GetConnectionString("StorageConnection");
            services.AddTransient<IStorageService>(p => new CloudStorageService(storageConnection));

            services.AddMvc();

            _services = services;
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app,
            IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseBrowserLink();
                ListAllRegisteredServices(app);
                app.UseDatabaseErrorPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
            }

            app.UseStaticFiles(new StaticFileOptions
            {
                OnPrepareResponse = ctx =>
                {
                    if (Regex.Match(ctx.Context.Request.Path, @"\.(eot|ttf|otf|woff)$").Success)
                        ctx.Context.Response.Headers.Append("Access-Control-Allow-Origin", "*");
                }
            });
            app.UseAuthentication();

            if (env.IsProduction())
            {
                // HomePageCache middleware depends on autentication.
                app.UseMiddleware<HomePageCache>();
            }

            app.UseMiddleware<FixSigninRedirectLocation>();

            app.UseMvc();
        }

        private void ListAllRegisteredServices(IApplicationBuilder app)
        {
            app.Map("/allservices", builder => builder.Run(async context =>
            {
                var sb = new StringBuilder();
                sb.Append("<h1>All Services</h1>");
                sb.Append("<table><thead>");
                sb.Append("<tr><th>Type</th><th>Lifetime</th><th>Instance</th></tr>");
                sb.Append("</thead><tbody>");
                foreach (var svc in _services)
                {
                    sb.Append("<tr>");
                    sb.Append($"<td>{svc.ServiceType.FullName}</td>");
                    sb.Append($"<td>{svc.Lifetime}</td>");
                    sb.Append($"<td>{svc.ImplementationType?.FullName}</td>");
                    sb.Append("</tr>");
                }
                sb.Append("</tbody></table>");
                await context.Response.WriteAsync(sb.ToString());
            }));
        }
    }
}
