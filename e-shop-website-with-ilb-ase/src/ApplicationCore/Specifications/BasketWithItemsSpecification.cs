/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using Microsoft.eShopWeb.ApplicationCore.Entities;

namespace ApplicationCore.Specifications
{
    public class BasketWithItemsSpecification : BaseSpecification<Basket>
    {
        public BasketWithItemsSpecification(int basketId)
            : base(b => b.Id == basketId)
        {
            AddInclude(b => b.Items);
        }

        public BasketWithItemsSpecification(string buyerId)
            : base(b => b.BuyerId == buyerId)
        {
            AddInclude(b => b.Items);
        }
    }
}
