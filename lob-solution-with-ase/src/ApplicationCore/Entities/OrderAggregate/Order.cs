/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Interfaces;
using Microsoft.eShopWeb.ApplicationCore.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace ApplicationCore.Entities.OrderAggregate
{
    [Microsoft.OData.Client.Key("Id")]
    public class Order : BaseEntity, IAggregateRoot
    {
        public Order()
        {
            OrderItems = new List<OrderItem>();
        }

        public Order(string buyerId, Address shipToAddress, List<OrderItem> items)
        {
            ShipToAddress = shipToAddress;
            OrderItems = items;
            BuyerId = buyerId;
        }

        [DisplayName("Buyer")]
        public string BuyerId { get; set; }

        [DisplayName("Order Date")]
        public DateTimeOffset OrderDate { get; set; } = DateTimeOffset.Now;


        [DisplayName("Ship To")]
        public Address ShipToAddress { get; set; }

        public IList<OrderItem> OrderItems { get; set; }

        [DataType(DataType.Currency)]
        public decimal Total
        {
            get { return OrderItems.Sum(i => i.UnitPrice * i.Units); }
        }
    }
}
