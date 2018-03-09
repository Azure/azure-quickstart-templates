/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Entities.OrderAggregate;

namespace ApplicationCore.Specifications
{
    public class CustomerOrdersWithItemsSpecification : BaseSpecification<Order>
    {
        public CustomerOrdersWithItemsSpecification(string buyerId)
            : base(o => o.BuyerId == buyerId)
        {
            // AddInclude(o => o.OrderItems);
            // AddInclude($"{nameof(Order.OrderItems)}.{nameof(OrderItem.ItemOrdered)}");

            AddInclude("OrderItems($select=Id,UnitPrice,Units,ItemOrdered)");
        }
    }
}
