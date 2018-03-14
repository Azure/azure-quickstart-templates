/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

namespace Microsoft.eShopWeb.ViewModels
{
    public class PaginationInfoViewModel
    {
        public int TotalItems { get; set; }

        public int ItemsPerPage { get; set; }

        public int ActualPage { get; set; }

        public int TotalPages { get; set; }

        public string Previous { get; set; }

        public string Next { get; set; }
    }
}
