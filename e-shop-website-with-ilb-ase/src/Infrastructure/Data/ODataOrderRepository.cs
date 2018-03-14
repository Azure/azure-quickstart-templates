/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Entities.OrderAggregate;
using ApplicationCore.Interfaces;
using Infrastructure.OData;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Infrastructure.Data
{
    public class ODataOrderRepository : ODataClientRepository<Order>, IOrderRepository
    {
        public ODataOrderRepository(Uri serviceRoot)
         : base(serviceRoot) { }

        public Order GetByIdWithItems(int id)
        {
            return GetByIdWithItemsAsync(id).Result;
        }

        public async Task<Order> GetByIdWithItemsAsync(int id)
        {
            var query = base.CreateQuery()
                .Expand("OrderItems($select=Id,UnitPrice,Units,ItemOrdered)")
                .Where2(i => i.Id == id)
                .Take2(1);
            var result = await query.ExecuteAsync();
            return result.FirstOrDefault();
        }

        public override async Task<Order> AddAsync(Order entity)
        {
            container.AddObject("Orders", entity);
            foreach (var item in entity.OrderItems)
            {
                container.AddObject("OrderItems", item);
                container.AddLink(entity, "OrderItems", item);
            }
            await container.SaveChangesAsync();
            return entity;
        }
    }
}
