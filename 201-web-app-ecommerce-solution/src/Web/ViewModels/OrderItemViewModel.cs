using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Microsoft.eShopWeb.ViewModels
{
    public class OrderItemViewModel
    {
        public int ProductId { get; set; }

        public string ProductName { get; set; }

        public decimal UnitPrice { get; set; }

        public decimal Discount { get; set; }

        public int Units { get; set; }

        public string PictureUrl { get; set; }
    }
}
