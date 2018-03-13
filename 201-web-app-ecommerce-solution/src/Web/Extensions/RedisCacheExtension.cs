using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Internal;
using Microsoft.Extensions.Caching.Distributed;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Web.Extensions
{
    public class PageContentCache
    {
        private readonly RequestDelegate _next;
        private readonly IDistributedCache _cache;

        public PageContentCache(RequestDelegate next,
           IDistributedCache cache)
        {
            _next = next;
            _cache = cache;
        }

        public async Task Invoke(HttpContext context)
        {
            string cacheKey;

            if (context.Request.Path.Value == "/" && context.User.Identity.IsAuthenticated == false)
            {
                cacheKey = string.Format("key_{0}_", context.Request.QueryString);
                if (context.Request.ContentLength > 0)
                {
                    cacheKey += string.Format("Brands{0}_Types{1}" , context.Request.Form["BrandFilterApplied"], context.Request.Form["TypesFilterApplied"]);
                }

                var value = await _cache.GetAsync(cacheKey);

                if (value != null)
                {
                    await context.Response.Body.WriteAsync(value, 0, value.Length);
                }
                else
                {
                    using (var memoryStream = new MemoryStream())
                    {
                        var bodyStream = context.Response.Body;
                        context.Response.Body = memoryStream;

                        await _next.Invoke(context);

                        var isHtml = context.Response.ContentType?.ToLower().Contains("text/html");
                        if (context.Response.StatusCode == 200 && isHtml.GetValueOrDefault())
                        {
                            memoryStream.Seek(0, SeekOrigin.Begin);
                            using (var streamReader = new StreamReader(memoryStream))
                            {
                                var responseBody = await streamReader.ReadToEndAsync();

                                var cacheEntryOptions = new DistributedCacheEntryOptions().SetAbsoluteExpiration(TimeSpan.FromMinutes(10));
                                _cache.Set(cacheKey, Encoding.UTF8.GetBytes(responseBody), cacheEntryOptions);

                                using (var amendedBody = new MemoryStream())
                                using (var streamWriter = new StreamWriter(amendedBody))
                                {
                                    streamWriter.Write(responseBody);
                                    amendedBody.Seek(0, SeekOrigin.Begin);
                                    await amendedBody.CopyToAsync(bodyStream);
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                await _next.Invoke(context);
            }
        }
    }

    // Extension method used to add the middleware to the HTTP request pipeline.
    public static class RedisCacheExtension
    {
        public static IApplicationBuilder UsePageContentCache(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<PageContentCache>();
        }
    }
}
