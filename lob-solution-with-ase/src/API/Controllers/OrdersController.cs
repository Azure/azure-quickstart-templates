/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Entities.OrderAggregate;
using Infrastructure.Data;
using Microsoft.AspNet.OData;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace API.Controllers
{
    public class OrdersController : ODataController
    {
        private SalesContext salesContext;

        public OrdersController(SalesContext salesContext)
        {
            this.salesContext = salesContext;
        }

        [EnableQuery]
        public IQueryable<Order> Get()
        {
            return salesContext.Orders;
        }

        public async Task<IActionResult> Post([FromBody]Order order)
        {
            salesContext.Add(order);
            await salesContext.SaveChangesAsync();
            return Created(order);
        }

        [AcceptVerbs("POST", "PUT")]
        public async Task<IActionResult> CreateRef(int key, string navigationProperty, [FromBody] Uri link)
        {
            if (navigationProperty != "OrderItems")
                throw new NotSupportedException();

            int itemId;
            var itemIdStr = Regex.Match(link.AbsolutePath, @"\d+").Value;
            if (!int.TryParse(itemIdStr, out itemId))
                throw new ArgumentException("", "link");

            var item = await salesContext.OrderItems.FindAsync(itemId);
            item.Order = await salesContext.Orders.FindAsync(key);
            await salesContext.SaveChangesAsync();

            return StatusCode((int)HttpStatusCode.NoContent);
        }
    }
}
