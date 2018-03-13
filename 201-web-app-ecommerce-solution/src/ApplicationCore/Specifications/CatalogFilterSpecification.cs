using Microsoft.eShopWeb.ApplicationCore.Entities;

namespace ApplicationCore.Specifications
{

    public class CatalogFilterSpecification : BaseSpecification<CatalogItem>
    {
        public CatalogFilterSpecification(int? brandId, int? typeId)
            : base(i => (!brandId.HasValue || i.CatalogBrandId == brandId) &&
                (!typeId.HasValue || i.CatalogTypeId == typeId))
        {
        }
    }
}
