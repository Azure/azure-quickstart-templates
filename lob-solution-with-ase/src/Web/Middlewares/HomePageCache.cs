/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Primitives;
using System;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Middlewares
{
    public class HomePageCache
    {
        private readonly RequestDelegate _next;
        private readonly IDistributedCache _cache;

        public HomePageCache(RequestDelegate next, IDistributedCache cache)
        {
            _next = next;
            _cache = cache;
        }

        public async Task Invoke(HttpContext context)
        {
            if (context.Request.Path.Value != "/" || context.User.Identity.IsAuthenticated)
            {
                await _next.Invoke(context);
                return;
            }

            var cacheKey = GetCacheKey(context);
            var value = await _cache.GetAsync(cacheKey);
            if (value != null)
            {
                context.Response.Headers.Add("X-Cache", new StringValues(_cache.GetType().Name));
                await context.Response.Body.WriteAsync(value, 0, value.Length);
                return;
            }

            using (var memoryStream = new MemoryStream())
            {
                var bodyStream = context.Response.Body;
                context.Response.Body = memoryStream;

                await _next.Invoke(context);

                var isHtml = context.Response.ContentType?.ToLower().Contains("text/html");
                if (context.Response.StatusCode == 200 && isHtml.GetValueOrDefault())
                {
                    var cacheEntryOptions = new DistributedCacheEntryOptions().SetAbsoluteExpiration(TimeSpan.FromMinutes(10));
                    var data = memoryStream.ToArray();
                    _cache.Set(cacheKey, data, cacheEntryOptions);
                }

                memoryStream.Seek(0, SeekOrigin.Begin);
                await memoryStream.CopyToAsync(bodyStream);
            }
        }

        private string GetCacheKey(HttpContext context)
        {
            var cacheKey = string.Format("key_{0}_", context.Request.QueryString);
            if (context.Request.ContentLength > 0)
                cacheKey += string.Format("Brands{0}_Types{1}", context.Request.Form["BrandFilterApplied"], context.Request.Form["TypesFilterApplied"]);
            return cacheKey;
        }
    }
}
