using ApplicationCore.Entities.OrderAggregate;

namespace ApplicationCore.Specifications
{
    public class CustomerOrdersWithItemsSpecification : BaseSpecification<Order>
    {
        public CustomerOrdersWithItemsSpecification(string buyerId)
            : base(o => o.BuyerId == buyerId)
        {
            AddInclude(o => o.OrderItems);
            AddInclude("OrderItems.ItemOrdered");
        }
    }
}
