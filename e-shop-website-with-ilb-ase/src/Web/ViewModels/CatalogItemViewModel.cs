/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

namespace Microsoft.eShopWeb.ViewModels
{
    public class CatalogItemViewModel
    {
        public int Id { get; set; }

        public string Name { get; set; }

        public string PictureUri { get; set; }

        public decimal Price { get; set; }
    }
}
