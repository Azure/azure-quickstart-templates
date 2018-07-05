using ApplicationCore.Interfaces;
using ApplicationCore.Services;
using Infrastructure.Data;
using Infrastructure.Identity;
using Infrastructure.Interfaces;
using Infrastructure.Logging;
using Infrastructure.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.eShopWeb.Interfaces;
using Microsoft.eShopWeb.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Text;
using Web.Extensions;

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
            // use in-memory database
            //ConfigureTestingServices(services);

            // use real database
            ConfigureProductionServices(services);
        }

        public void ConfigureTestingServices(IServiceCollection services)
        {
            // use in-memory database
            services.AddDbContext<CatalogContext>(c =>
                c.UseInMemoryDatabase("Catalog"));

            // Add Identity DbContext
            services.AddDbContext<AppIdentityDbContext>(options =>
                options.UseInMemoryDatabase("Identity"));

            ConfigureServices(services);
        }

        public void ConfigureProductionServices(IServiceCollection services)
        {
            // use real database
            services.AddDbContext<CatalogContext>(c =>
            {
                try
                {
                    // Requires LocalDB which can be installed with SQL Server Express 2016
                    // https://www.microsoft.com/en-us/download/details.aspx?id=54284
                    c.UseSqlServer(Configuration.GetConnectionString("CatalogConnection"));
                }
                catch (System.Exception ex)
                {
                    var message = ex.Message;
                }
            });

            // Add Identity DbContext
            services.AddDbContext<AppIdentityDbContext>(options =>
                options.UseSqlServer(Configuration.GetConnectionString("IdentityConnection")));

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

            services.AddScoped(typeof(IRepository<>), typeof(EfRepository<>));
            services.AddScoped(typeof(IAsyncRepository<>), typeof(EfRepository<>));

            services.AddScoped<ICatalogService, CachedCatalogService>();
            services.AddScoped<IBasketService, BasketService>();
            services.AddScoped<IBasketViewModelService, BasketViewModelService>();
            services.AddScoped<IOrderService, OrderService>();
            services.AddScoped<IOrderRepository, OrderRepository>();
            services.AddScoped<CatalogService>();
            services.AddScoped(providier => new SearchService(Configuration["SearchServiceName"], Configuration["SearchServiceAdminApiKey"], Configuration["SearchServiceQueryApiKey"]));
            services.AddScoped<ICloudStorageService, CloudStorageService>(providier => new CloudStorageService(Configuration.GetConnectionString("StorageConnection")));
            services.Configure<CatalogSettings>(Configuration);
            services.AddSingleton<IUriComposer>(new UriComposer(Configuration.Get<CatalogSettings>()));

            services.AddScoped(typeof(IAppLogger<>), typeof(LoggerAdapter<>));
            services.AddTransient<IEmailSender, EmailSender>();

            services.AddDistributedRedisCache(options =>
            {
                options.Configuration = Configuration["CacheConnection"];
                options.InstanceName = "eShopOnWebCacheInstance";
            });

            services.AddSingleton<IAppsettingsService, AppSettingsService>();

            services.AddMvc();

            services.AddSingleton<IConfiguration>(Configuration);

            _services = services;
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app,
            IHostingEnvironment env)
        {
            app.UseDeveloperExceptionPage();
            app.UseBrowserLink();
            ListAllRegisteredServices(app);
            app.UseDatabaseErrorPage();
            app.UseStaticFiles();
            app.UseAuthentication();
            app.UsePageContentCache();
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
