using Microsoft.eShopWeb.Services;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Controllers
{
    [Route("")]
    public class CatalogController : Controller
    {
        private readonly ICatalogService _catalogService;

        public CatalogController(ICatalogService catalogService) => _catalogService = catalogService;

        [HttpGet]
        [HttpPost]
        public async Task<IActionResult> Index(int? page, int? brandFilterApplied, int? typesFilterApplied, string keywords)
        {
            var telemetry = new Microsoft.ApplicationInsights.TelemetryClient();
            telemetry.TrackTrace("Microsoft.eShopWeb.Controllers CatalogController Index");

            var itemsPage = 9;
            //var catalogModel = await _catalogService.SearchCatalogItems(page ?? 0, itemsPage, brandFilterApplied, typesFilterApplied, keywords);
            var catalogModel = await _catalogService.GetCatalogItems(page ?? 0, itemsPage, brandFilterApplied, typesFilterApplied);
            return View(catalogModel);
        }
    }
}
