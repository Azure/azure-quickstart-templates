/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using Microsoft.AspNetCore.Mvc.Rendering;
using System.Collections.Generic;

namespace Microsoft.eShopWeb.ViewModels
{
    public class CatalogIndexViewModel
    {
        public IEnumerable<CatalogItemViewModel> CatalogItems { get; set; }

        public IEnumerable<SelectListItem> Brands { get; set; }

        public IEnumerable<SelectListItem> Types { get; set; }

        public int? BrandFilterApplied { get; set; }

        public int? TypesFilterApplied { get; set; }

        public PaginationInfoViewModel PaginationInfo { get; set; }
    }
}
