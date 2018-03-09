/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

namespace Microsoft.eShopWeb.ApplicationCore.Entities
{
    public class BasketItem : BaseEntity
    {
        public decimal UnitPrice { get; set; }

        public int Quantity { get; set; }

        public int CatalogItemId { get; set; }
    }
}
