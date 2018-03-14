/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Interfaces;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Infrastructure.Services
{
    public class CloudStorageService : IStorageService
    {
        private CloudStorageAccount storageAccount;

        public CloudStorageService(string connectionString)
        {
            storageAccount = CloudStorageAccount.Parse(connectionString);
        }

        public Task<bool> ExistsContainerAsync(string containerName)
        {
            var blobClient = storageAccount.CreateCloudBlobClient();
            var container = blobClient.GetContainerReference(containerName);
            return container.ExistsAsync();
        }

        public async Task<Uri> UploadFilesAsync(string containerName, string folder, IEnumerable<string> files)
        {
            var container = await GetOrCreateCloudBlobContainer(containerName);
            foreach (var file in files)
            {
                var blob = container.GetBlockBlobReference(Path.Combine(folder, Path.GetFileName(file)));
                await blob.UploadFromFileAsync(file);
            }
            return container.Uri;
        }

        private async Task<CloudBlobContainer> GetOrCreateCloudBlobContainer(string containerName)
        {
            var blobClient = storageAccount.CreateCloudBlobClient();
            var container = blobClient.GetContainerReference(containerName);
            await container.CreateIfNotExistsAsync();

            var permissions = await container.GetPermissionsAsync();
            permissions.PublicAccess = BlobContainerPublicAccessType.Blob;
            await container.SetPermissionsAsync(permissions);
            return container;
        }
    }
}
