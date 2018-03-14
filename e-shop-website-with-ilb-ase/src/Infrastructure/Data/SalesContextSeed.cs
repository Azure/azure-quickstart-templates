/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Entities.OrderAggregate;
using Microsoft.eShopWeb.ApplicationCore.Entities;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Infrastructure.Data
{
    public class SalesContextSeed
    {
        static Random random = new Random();

        public static async Task SeedAsync(CatalogContext catalogContext, SalesContext salesContext,
            ILoggerFactory loggerFactory, int? retry = 0)
        {
            int retryForAvailability = retry.Value;
            try
            {
                // Only run this if using a real database
                // context.Database.Migrate();

                if (!salesContext.Orders.Any())
                {
                    var products = catalogContext.CatalogItems.ToArray();

                    var orders = GetRandomOrders(24, products);
                    salesContext.Orders.AddRange(orders);
                    await salesContext.SaveChangesAsync();
                }
            }
            catch (Exception ex)
            {
                if (retryForAvailability < 10)
                {
                    retryForAvailability++;
                    var log = loggerFactory.CreateLogger<CatalogContextSeed>();
                    log.LogError(ex.Message);
                    await SeedAsync(catalogContext, salesContext, loggerFactory, retryForAvailability);
                }
            }
        }

        static IEnumerable<Order> GetRandomOrders(int count, IEnumerable<CatalogItem> products)
        {
            var buyers = new[] {
                "rong@contoso.com",
                "chrisg@contoso.com",
                "robb@contoso.com",
                "alisal@contoso.com",
                "marga@contoso.com",
                "stevenw@contoso.com",
                "danj@contoso.com",
                "chrisj@contoso.com",
                "carolt@contoso.com"
            };

            for (int i = 0; i < count; i++)
            {
                var order = new Order
                {
                    BuyerId = buyers[random.Next() % buyers.Length],
                    OrderDate = DateTimeOffset.Now.AddDays(-random.Next(60) + random.Next(100) / 100.0),
                    ShipToAddress = new Address("123 Main St.", "Kent", "OH", "United States", "44240"),
                    OrderItems = GetOrderItems(random.Next(2, 6), products).ToList()
                };
                foreach (var item in order.OrderItems)
                    item.Order = order;
                yield return order;
            }
        }

        static IEnumerable<OrderItem> GetOrderItems(int count, IEnumerable<CatalogItem> products)
        {
            var selectedProducts = products
                .OrderBy(i => random.Next())
                .Take(count);

            foreach (var product in selectedProducts)
            {
                yield return new OrderItem
                {
                    ItemOrdered = new CatalogItemOrdered
                    {
                        CatalogItemId = product.Id,
                        ProductName = product.Name,
                        PictureUri = product.PictureUri
                    },
                    UnitPrice = product.Price,
                    Units = random.Next(1, 6)
                };
            }
        }
    }
}
