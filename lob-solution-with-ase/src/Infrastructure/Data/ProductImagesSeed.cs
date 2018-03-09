/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Interfaces;
using Microsoft.Extensions.Logging;
using System;
using System.IO;
using System.Threading.Tasks;

namespace Infrastructure.Data
{
    public class ProductImagesSeed
    {
        public static async Task SeedAsync(IStorageService storageService, string containerName, string folder, ILoggerFactory loggerFactory, int? retry = 0)
        {
            int retryForAvailability = retry.Value;
            try
            {
                if (!await storageService.ExistsContainerAsync(containerName))
                {
                    var productImagesDir = Path.Combine(Directory.GetCurrentDirectory(), @"wwwroot\images\products");
                    await storageService.UploadFilesAsync(containerName, folder, Directory.GetFiles(productImagesDir));
                }
            }
            catch (Exception ex)
            {
                if (retryForAvailability < 10)
                {
                    retryForAvailability++;
                    var log = loggerFactory.CreateLogger<CatalogContextSeed>();
                    log.LogError(ex.Message);
                    await SeedAsync(storageService, containerName, folder, loggerFactory, retryForAvailability);
                }
            }
        }
    }
}
