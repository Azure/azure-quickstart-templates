using Infrastructure.Interfaces;
using Microsoft.eShopWeb.ApplicationCore.Entities;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using Microsoft.WindowsAzure.Storage.Queue;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Infrastructure.Services
{
    public class CloudStorageService: ICloudStorageService
    {
        private string _storageConnection;
        private CloudBlobContainer _container;

        public CloudStorageService(string AzureStorageConnectionString)
        {
            _storageConnection = AzureStorageConnectionString;
        }

        private async Task<CloudBlobContainer> GetCloudBlobContainer()
        {
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(_storageConnection);
            CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();
            CloudBlobContainer container = blobClient.GetContainerReference("productimages");
            await container.CreateIfNotExistsAsync();

            BlobContainerPermissions permissions = await container.GetPermissionsAsync();
            permissions.PublicAccess = BlobContainerPublicAccessType.Blob;
            await container.SetPermissionsAsync(permissions);

            return container;
        }

        public async Task<Uri> UploadFile(string filepath)
        {
            if (_container == null)
            {
                _container = await GetCloudBlobContainer();
            }

            CloudBlockBlob blob = _container.GetBlockBlobReference(Path.GetFileName(filepath));

            await blob.UploadFromFileAsync(filepath);

            return blob.StorageUri.PrimaryUri;
        }

        public async Task UploadFiles(IEnumerable<CatalogItem> items)
        {
            foreach(CatalogItem item in items)
            {
                var path = Path.Combine(Directory.GetCurrentDirectory(), @"wwwroot", item.PictureUri);

                if (File.Exists(path))
                {
                    item.PictureUri = (await UploadFile(path)).AbsoluteUri;
                }
            }
        }

        private async Task<CloudQueue> getCloudQueue()
        {
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(_storageConnection);
            // Create the CloudQueueClient object for the storage account.
            CloudQueueClient queueClient = storageAccount.CreateCloudQueueClient();

            // Get a reference to the CloudQueue named "messagequeue"
            CloudQueue messageQueue = queueClient.GetQueueReference("ordertransactions");

            // Create the CloudQueue if it does not exist.
            await messageQueue.CreateIfNotExistsAsync();

            return messageQueue;
        }

        public async Task CreateQueueMessage(string Message)
        {
            var cloudQueue = await getCloudQueue();

            // Create a message and add it to the queue.
            CloudQueueMessage message = new CloudQueueMessage(Message);
            await cloudQueue.AddMessageAsync(message);
        }
    }
}
