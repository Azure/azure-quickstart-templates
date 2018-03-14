/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.eShopWeb.ViewModels;
using Microsoft.Extensions.Caching.Memory;
using System;

namespace Microsoft.eShopWeb.Services
{
    public class CachedCatalogService : ICatalogService
    {
        private readonly IMemoryCache _cache;
        private readonly CatalogService _catalogService;
        private static readonly string _brandsKey = "brands";
        private static readonly string _typesKey = "types";
        private static readonly string _itemsKeyTemplate = "items-{0}-{1}-{2}-{3}";
        private static readonly TimeSpan _defaultCacheDuration = TimeSpan.FromSeconds(30);

        public CachedCatalogService(IMemoryCache cache,
            CatalogService catalogService)
        {
            _cache = cache;
            _catalogService = catalogService;
        }

        public async Task<IEnumerable<SelectListItem>> GetBrands()
        {
            return await _cache.GetOrCreateAsync(_brandsKey, async entry =>
                    {
                        entry.SlidingExpiration = _defaultCacheDuration;
                        return await _catalogService.GetBrands();
                    });
        }

        public async Task<CatalogIndexViewModel> GetCatalogItems(int pageIndex, int itemsPage, int? brandId, int? typeId)
        {
            string cacheKey = String.Format(_itemsKeyTemplate, pageIndex, itemsPage, brandId, typeId);
            return await _cache.GetOrCreateAsync(cacheKey, async entry =>
            {
                entry.SlidingExpiration = _defaultCacheDuration;
                return await _catalogService.GetCatalogItems(pageIndex, itemsPage, brandId, typeId);
            });
        }

        public async Task<IEnumerable<SelectListItem>> GetTypes()
        {
            return await _cache.GetOrCreateAsync(_typesKey, async entry =>
            {
                entry.SlidingExpiration = _defaultCacheDuration;
                return await _catalogService.GetTypes();
            });
        }
    }
}
