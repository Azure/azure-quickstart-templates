/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using System.ComponentModel;

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
        public CatalogItemOrdered() { }

        public int CatalogItemId { get; set; }

        [DisplayName("Product")]
        public string ProductName { get; set; }

        public string PictureUri { get; set; }
    }
}
