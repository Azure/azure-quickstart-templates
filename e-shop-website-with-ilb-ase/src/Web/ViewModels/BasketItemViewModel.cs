/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

namespace Microsoft.eShopWeb.ViewModels
{
    public class BasketItemViewModel
    {
        public int Id { get; set; }

        public int CatalogItemId { get; set; }

        public string ProductName { get; set; }

        public decimal UnitPrice { get; set; }

        public decimal OldUnitPrice { get; set; }

        public int Quantity { get; set; }

        public string PictureUrl { get; set; }
    }
}
