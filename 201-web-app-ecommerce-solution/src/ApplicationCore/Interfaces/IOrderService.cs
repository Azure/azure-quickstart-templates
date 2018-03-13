using ApplicationCore.Entities.OrderAggregate;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ApplicationCore.Interfaces
{
    public interface IOrderService
    {
        Task<int> CreateOrderAsync(int basketId, Address shippingAddress, string Status);
    }
}
