using Microsoft.AspNetCore.Mvc;

namespace aspnet_mvc_keyvault_storage.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {                        
            return View();
        }
    }
}
