/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Entities.OrderAggregate;
using Infrastructure.Data;
using Microsoft.AspNet.OData.Builder;
using Microsoft.AspNet.OData.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System.Linq;

namespace API
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureDevelopmentServices(IServiceCollection services)
        {
            // use in-memory database
            // ConfigureTestingServices(services);

            // use real database
            ConfigureProductionServices(services);

        }
        public void ConfigureTestingServices(IServiceCollection services)
        {
            // use in-memory database
            services.AddDbContext<SalesContext>(c => c.UseInMemoryDatabase("Sales"));

            ConfigureServices(services);
        }

        public void ConfigureProductionServices(IServiceCollection services)
        {
            // use real database
            services.AddDbContext<SalesContext>(c => c.UseSqlServer(Configuration.GetConnectionString("SalesConnection")));

            ConfigureServices(services);
        }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddOData();
            services.AddMvc();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            var builder = new ODataConventionModelBuilder(app.ApplicationServices);
            builder.EntitySet<Order>("Orders")
                .HasManyBinding(i => i.OrderItems, "OrderItems");

            // Enabling OData routing
            app.UseMvc(routebuilder =>
                {
                    routebuilder.Count().Filter().OrderBy().Expand().Select().MaxTop(null);
                    routebuilder.MapODataServiceRoute("ODataRoute", "", builder.GetEdmModel());
                });
        }
    }
}
