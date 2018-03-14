/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using Microsoft.eShopWeb.ApplicationCore.Entities;

namespace ApplicationCore.Entities.BuyerAggregate
{
    public class PaymentMethod : BaseEntity
    {
        public string Alias { get; set; }

        public string CardId { get; set; } // actual card data must be stored in a PCI compliant system, like Stripe

        public string Last4 { get; set; }
    }
}
