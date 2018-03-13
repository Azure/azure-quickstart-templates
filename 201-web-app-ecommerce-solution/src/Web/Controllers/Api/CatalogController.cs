using Microsoft.eShopWeb.Services;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Controllers.Api
{
    public class CatalogController : BaseApiController
    {
        private readonly ICatalogService _catalogService;

        public CatalogController(ICatalogService catalogService) => _catalogService = catalogService;

        [HttpGet]
        public async Task<IActionResult> List(int? page, int? brandFilterApplied, int? typesFilterApplied, string keywords)
        {
            var itemsPage = 9;
            //var catalogModel = await _catalogService.SearchCatalogItems(page ?? 0, itemsPage, brandFilterApplied, typesFilterApplied, keywords);
            var catalogModel = await _catalogService.GetCatalogItems(page ?? 0, itemsPage, brandFilterApplied, typesFilterApplied);
            return Ok(catalogModel);
        }
    }
}
