using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.eShopWeb.ViewModels;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Services
{
    public interface ICatalogService
    {
        Task<CatalogIndexViewModel> SearchCatalogItems(int pageIndex, int itemsPage, int? brandId, int? typeId, string keywords);
        Task<CatalogIndexViewModel> GetCatalogItems(int pageIndex, int itemsPage, int? brandId, int? typeId);
        Task<IEnumerable<SelectListItem>> GetBrands();
        Task<IEnumerable<SelectListItem>> GetTypes();
    }
}
