/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Entities.OrderAggregate;
using Infrastructure.Data;
using Microsoft.AspNet.OData;
using Microsoft.AspNetCore.Mvc;
using System.Linq;
using System.Threading.Tasks;

namespace API.Controllers
{
    public class OrderItemsController : ODataController
    {
        private SalesContext salesContext;

        public OrderItemsController(SalesContext salesContext)
        {
            this.salesContext = salesContext;
        }

        [EnableQuery]
        public IQueryable<OrderItem> Get()
        {
            return salesContext.OrderItems;
        }

        public async Task<IActionResult> Post([FromBody]OrderItem orderItem)
        {
            salesContext.Add(orderItem);
            await salesContext.SaveChangesAsync();
            return Created(orderItem);
        }
    }
}
