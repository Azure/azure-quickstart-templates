/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.eShopWeb.ViewModels
{
    public class BasketViewModel
    {
        public int Id { get; set; }

        public List<BasketItemViewModel> Items { get; set; } = new List<BasketItemViewModel>();

        public string BuyerId { get; set; }

        public decimal Total()
        {
            return Math.Round(Items.Sum(x => x.UnitPrice * x.Quantity), 2);
        }
    }
}
