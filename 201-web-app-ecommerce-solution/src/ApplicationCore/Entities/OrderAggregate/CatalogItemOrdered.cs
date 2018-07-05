namespace ApplicationCore.Entities.OrderAggregate
{
    /// <summary>
    /// Represents the item that was ordered. If catalog item details change, details of
    /// the item that was part of a completed order should not change.
    /// </summary>
    public class CatalogItemOrdered // ValueObject
    {
        public CatalogItemOrdered(int catalogItemId, string productName, string pictureUri)
        {
            CatalogItemId = catalogItemId;
            ProductName = productName;
            PictureUri = pictureUri;
        }
        private CatalogItemOrdered()
        {
            // required by EF
        }
        public int CatalogItemId { get; private set; }
        public string ProductName { get; private set; }
        public string PictureUri { get; private set; }
    }
}
