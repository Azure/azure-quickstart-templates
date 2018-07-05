using Microsoft.eShopWeb.ViewModels;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Interfaces
{
    public interface IBasketViewModelService
    {
        Task<BasketViewModel> GetOrCreateBasketForUser(string userName);
    }
}
