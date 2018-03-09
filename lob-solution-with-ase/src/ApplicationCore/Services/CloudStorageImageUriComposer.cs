/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using ApplicationCore.Interfaces;
using Microsoft.WindowsAzure.Storage;

namespace ApplicationCore.Services
{
    public class CloudStorageImageUriComposer : IUriComposer
    {
        private CloudStorageAccount storageAccount;

        public CloudStorageImageUriComposer(string connectionString)
        {
            storageAccount = CloudStorageAccount.Parse(connectionString);
        }

        public string ComposePicUri(string uriTemplate)
        {
            var blobEndpointUri = storageAccount.BlobEndpoint.AbsoluteUri;
            if (!blobEndpointUri.EndsWith("/")) blobEndpointUri += "/";

            return uriTemplate.Replace("http://catalogbaseurltobereplaced/", blobEndpointUri);
        }
    }
}
