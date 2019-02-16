using aspnet_mvc_keyvault_storage.Models;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.AzureAD.UI;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;

namespace aspnet_mvc_keyvault_storage
{
    public class Startup
    {
        private readonly IConfiguration _config;
        private readonly ILogger _logger;

        public Startup(IConfiguration configuration, ILogger<Startup> logger)
        {
            _config = configuration;
            _logger = logger;
        }
        

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.Configure<CookiePolicyOptions>(options =>
            {
                // This lambda determines whether user consent for non-essential cookies is needed for a given request.
                options.CheckConsentNeeded = context => true;
                options.MinimumSameSitePolicy = SameSiteMode.None;
            });

            services.AddAuthentication(AzureADDefaults.AuthenticationScheme)
                .AddAzureAD(options => _config.Bind("AzureAd", options));

            services.AddMvc(options =>
            {
                var policy = new AuthorizationPolicyBuilder()
                    .RequireAuthenticatedUser()
                    .Build();
                options.Filters.Add(new AuthorizeFilter(policy));
            })
            .SetCompatibilityVersion(CompatibilityVersion.Version_2_1);

            var storageAccountName = _config["StorageAccountName"];
            var storageAccountUrl = _config["StorageAccountUrl"];
            var keyVaultUrl = _config["KeyVaultUrl"];
            var containerName = _config["ContainerName"];

            // Add the custom repository class 
            services.AddScoped<IBlobRepository, BlobRepository>(provider => new BlobRepository(
                storageAccountName,
                storageAccountUrl,
                keyVaultUrl,
                containerName));

            _logger.LogInformation("Pre-creating container");

            try
            { 
                var blobRepository = new BlobRepository(
                    storageAccountName,
                    storageAccountUrl,
                    keyVaultUrl,
                    containerName);

                //Pre-create the blob container
            
                blobRepository.CreateBlobContainer().GetAwaiter().GetResult();
            }
            catch(Exception oops)
            {
                _logger.LogError(oops, "Error Pre-creating container. {0}, {1}, {2}, {3}", storageAccountName, storageAccountUrl, keyVaultUrl, containerName);
                //This error is non-recoverable.
                throw oops;
            }
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Home/Error");
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();
            app.UseCookiePolicy();

            app.UseAuthentication();

            app.UseMvc(routes =>
            {
                routes.MapRoute(
                    name: "default",
                    template: "{controller=Home}/{action=Index}/{id?}");
            });
           
            
        }
    }
}
