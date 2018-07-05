using ApplicationCore.Entities.OrderAggregate;
using ApplicationCore.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;

namespace Infrastructure.Data
{
    public class OrderRepository : EfRepository<Order>, IOrderRepository
    {
        public OrderRepository(CatalogContext dbContext) : base(dbContext)
        {
        }

        public Order GetByIdWithItems(int id)
        {
            return _dbContext.Orders
                .Include(o => o.OrderItems)
                .Include("OrderItems.ItemOrdered")
                .FirstOrDefault();
        }

        public Task<Order> GetByIdWithItemsAsync(int id)
        {
            return _dbContext.Orders
                .Include(o => o.OrderItems)
                .Include("OrderItems.ItemOrdered")
                .FirstOrDefaultAsync();
        }
    }
}
