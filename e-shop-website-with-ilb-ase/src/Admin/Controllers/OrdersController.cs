/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Entities.OrderAggregate;
using ApplicationCore.Interfaces;
using ApplicationCore.Specifications;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Linq;
using System.Threading.Tasks;

namespace Admin.Controllers
{
    [Authorize]
    public class OrdersController : Controller
    {
        private readonly IOrderRepository orderRepository;

        public OrdersController(IOrderRepository orderRepository)
        {
            this.orderRepository = orderRepository;
        }

        public async Task<IActionResult> Index(string buyerKey)
        {
            var spec = string.IsNullOrEmpty(buyerKey)
                ? BaseSpecification<Order>.Create(i => true)
                : BaseSpecification<Order>.Create(i => i.BuyerId.Contains(buyerKey));
            spec.AddInclude("OrderItems($select=UnitPrice,Units)");

            var orders = await orderRepository.ListAsync(spec);
            ViewBag.buyerKey = buyerKey;
            return View(orders.OrderByDescending(i => i.OrderDate));
        }

        public async Task<IActionResult> Details(int id)
        {
            var order = await orderRepository.GetByIdWithItemsAsync(id);
            return View(order);
        }
    }
}
