/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using ApplicationCore.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.eShopWeb.ViewModels;
using Microsoft.AspNetCore.Identity;
using Infrastructure.Identity;
using System;
using System.Collections.Generic;
using ApplicationCore.Entities.OrderAggregate;
using Microsoft.AspNetCore.Authorization;
using Microsoft.eShopWeb.Interfaces;

namespace Microsoft.eShopWeb.Controllers
{
    [Route("[controller]/[action]")]
    public class BasketController : Controller
    {
        private readonly IBasketService _basketService;
        private readonly IUriComposer _uriComposer;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly IAppLogger<BasketController> _logger;
        private readonly IOrderService _orderService;
        private readonly IBasketViewModelService _basketViewModelService;

        public BasketController(IBasketService basketService,
            IBasketViewModelService basketViewModelService,
            IOrderService orderService,
            IUriComposer uriComposer,
            SignInManager<ApplicationUser> signInManager,
            IAppLogger<BasketController> logger)
        {
            _basketService = basketService;
            _uriComposer = uriComposer;
            _signInManager = signInManager;
            _logger = logger;
            _orderService = orderService;
            _basketViewModelService = basketViewModelService;
        }

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var basketModel = await GetBasketViewModelAsync();

            return View(basketModel);
        }

        [HttpPost]
        public async Task<IActionResult> Index(Dictionary<string, int> items)
        {
            var basketViewModel = await GetBasketViewModelAsync();
            await _basketService.SetQuantities(basketViewModel.Id, items);

            return View(await GetBasketViewModelAsync());
        }


        // POST: /Basket/AddToBasket
        [HttpPost]
        public async Task<IActionResult> AddToBasket(CatalogItemViewModel productDetails)
        {
            if (productDetails?.Id == null)
            {
                return RedirectToAction("Index", "Catalog");
            }
            var basketViewModel = await GetBasketViewModelAsync();

            await _basketService.AddItemToBasket(basketViewModel.Id, productDetails.Id, productDetails.Price, 1);

            return RedirectToAction("Index");
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Checkout(Dictionary<string, int> items)
        {
            var basketViewModel = await GetBasketViewModelAsync();
            await _basketService.SetQuantities(basketViewModel.Id, items);

            await _orderService.CreateOrderAsync(basketViewModel.Id, new Address("123 Main St.", "Kent", "OH", "United States", "44240"));

            await _basketService.DeleteBasketAsync(basketViewModel.Id);

            return View("Checkout");
        }

        private async Task<BasketViewModel> GetBasketViewModelAsync()
        {
            if (_signInManager.IsSignedIn(HttpContext.User))
            {
                return await _basketViewModelService.GetOrCreateBasketForUser(User.Identity.Name);
            }
            string anonymousId = GetOrSetBasketCookie();
            return await _basketViewModelService.GetOrCreateBasketForUser(anonymousId);
        }

        private string GetOrSetBasketCookie()
        {
            if (Request.Cookies.ContainsKey(Constants.BASKET_COOKIENAME))
            {
                return Request.Cookies[Constants.BASKET_COOKIENAME];
            }
            string anonymousId = Guid.NewGuid().ToString();
            var cookieOptions = new CookieOptions();
            cookieOptions.Expires = DateTime.Today.AddYears(10);
            Response.Cookies.Append(Constants.BASKET_COOKIENAME, anonymousId, cookieOptions);
            return anonymousId;
        }
    }
}
