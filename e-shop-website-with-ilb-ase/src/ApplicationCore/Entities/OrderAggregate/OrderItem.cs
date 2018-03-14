/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using Microsoft.eShopWeb.ApplicationCore.Entities;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace ApplicationCore.Entities.OrderAggregate
{
    [Microsoft.OData.Client.Key("Id")]
    public class OrderItem : BaseEntity
    {
        public Order Order { get; set; }

        public CatalogItemOrdered ItemOrdered { get; set; }

        [DisplayName("Unit Price")]
        [DataType(DataType.Currency)]
        public decimal UnitPrice { get; set; }

        public int Units { get; set; }

        public OrderItem() { }

        public OrderItem(CatalogItemOrdered itemOrdered, decimal unitPrice, int units)
        {
            ItemOrdered = itemOrdered;
            UnitPrice = unitPrice;
            Units = units;
        }
    }
}
