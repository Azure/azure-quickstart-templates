using ApplicationCore.Entities.OrderAggregate;
using System;
using System.Collections.Generic;

namespace Microsoft.eShopWeb.ViewModels
{
    public class OrderViewModel
    {
        public int OrderNumber { get; set; }
        public DateTimeOffset OrderDate { get; set; }
        public decimal Total { get; set; }
        public string Status { get; set; }

        public Address ShippingAddress { get; set; } 

        public List<OrderItemViewModel> OrderItems { get; set; } = new List<OrderItemViewModel>();

    }

}
