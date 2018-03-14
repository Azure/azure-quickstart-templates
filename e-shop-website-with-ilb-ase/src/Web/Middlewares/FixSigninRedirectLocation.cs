/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Primitives;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Web.Middlewares
{
    public class FixSigninRedirectLocation
    {
        private readonly RequestDelegate _next;

        public FixSigninRedirectLocation(RequestDelegate next)
        {
            _next = next;
        }

        public async Task Invoke(HttpContext context)
        {
            await _next.Invoke(context);
            if (context.Response.StatusCode != 302) return;

            var location = context.Response.Headers["Location"].FirstOrDefault();
            if (location.StartsWith("/")) return;

            var locationUri = new Uri(location);
            if (locationUri.Authority == context.Request.Host.Value
                && locationUri.Scheme == context.Request.Scheme
                && locationUri.AbsolutePath == "/Account/Signin")
            {
                context.Response.Headers["Location"] = new StringValues(locationUri.PathAndQuery);
            }
        }
    }
}
