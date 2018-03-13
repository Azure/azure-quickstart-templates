using Infrastructure.Identity;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.eShopWeb;
using Microsoft.eShopWeb.Interfaces;
using Microsoft.eShopWeb.ViewModels;
using System.Linq;
using System.Threading.Tasks;

namespace Web.ViewComponents
{
    public class Basket : ViewComponent
    {
        private readonly IBasketViewModelService _basketService;
        private readonly SignInManager<ApplicationUser> _signInManager;

        public Basket(IBasketViewModelService basketService,
                        SignInManager<ApplicationUser> signInManager)
        {
            _basketService = basketService;
            _signInManager = signInManager;
        }

        public async Task<IViewComponentResult> InvokeAsync(string userName)
        {
            var vm = new BasketComponentViewModel();
            vm.ItemsCount = (await GetBasketViewModelAsync()).Items.Sum(i => i.Quantity);
            return View(vm);
        }

        private async Task<BasketViewModel> GetBasketViewModelAsync()
        {
            if (_signInManager.IsSignedIn(HttpContext.User))
            {
                return await _basketService.GetOrCreateBasketForUser(User.Identity.Name);
            }
            string anonymousId = GetBasketIdFromCookie();
            if (anonymousId == null) return new BasketViewModel();
            return await _basketService.GetOrCreateBasketForUser(anonymousId);
        }

        private string GetBasketIdFromCookie()
        {
            if (Request.Cookies.ContainsKey(Constants.BASKET_COOKIENAME))
            {
                return Request.Cookies[Constants.BASKET_COOKIENAME];
            }
            return null;
        }
    }
}
