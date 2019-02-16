using Microsoft.Azure.KeyVault;
using Microsoft.Azure.KeyVault.Models;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.WindowsAzure.Storage.Auth;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace aspnet_mvc_keyvault_storage.Models
{
    public class BlobRepository : IBlobRepository
    {         
        private readonly string _storageAccountName;
        private readonly string _storageAccountUrl;
        private readonly string _keyVaultUrl;
        private readonly string _containerName;

        private static readonly KeyVaultClient _keyVaultClient;
        private static readonly AzureServiceTokenProvider _azureServiceTokenProvider;

        static BlobRepository()
        {
            _azureServiceTokenProvider = new AzureServiceTokenProvider();
            _keyVaultClient = new KeyVaultClient(
                    new KeyVaultClient.AuthenticationCallback(_azureServiceTokenProvider.KeyVaultTokenCallback));
        }

        public BlobRepository(             
            string storageAccountName, string storageAccountUrl, string keyVaultUrl, string containerName)
        {
            _storageAccountName = storageAccountName;
            _storageAccountUrl = storageAccountUrl;
            _keyVaultUrl = keyVaultUrl;
            _containerName = containerName;
        }

        public async Task<CloudBlobContainer> CreateBlobContainer()
        {
            var client = await GetCloudBlobClientAsync();
            var container = client.GetContainerReference(_containerName);
            await container.CreateIfNotExistsAsync();
            return container;
        }

        private async Task<CloudBlobClient> GetCloudBlobClientAsync()
        {

            var secretName = "storageKey";

            SecretBundle secretBundle = null;

            // TODO: Need to cache this                          
            secretBundle = await _keyVaultClient.GetSecretAsync(_keyVaultUrl, secretName)
                .ConfigureAwait(false);                        

            var creds = new StorageCredentials(_storageAccountName, secretBundle.Value);
            var blobClient = new CloudBlobClient(new Uri(_storageAccountUrl), creds);

            return blobClient;
        }

        private async Task<CloudBlobContainer> GetCloudBlobContainerAsync()
        {
            var client = await GetCloudBlobClientAsync();
            var container = client.GetContainerReference(_containerName);
            return container;
        }

        public async Task<List<StorageModel>> GetBlobListAsync()
        {            
            BlobContinuationToken blobContinuationToken = null;

            var items = new List<StorageModel>();
            BlobResultSegment results = null;

            var container = await GetCloudBlobContainerAsync();

            do
            {
                results = await container.ListBlobsSegmentedAsync(null, blobContinuationToken);

                // Get the value of the continuation token returned by the listing call.
                blobContinuationToken = results.ContinuationToken;

                foreach (CloudBlockBlob item in results.Results)
                {
                    items.Add(new StorageModel(item));
                }

            } while (blobContinuationToken != null); // Loop while the continuation token is not null.


            return items;
        }
        
        
        public async Task<StorageModel> GetBlobAsync(string fileName)
        {
            StorageModel model = null;
            var container = await GetCloudBlobContainerAsync();
            var blob = container.GetBlockBlobReference(fileName);
            //Get the properties of the blob
            await blob.FetchAttributesAsync();
            model = new StorageModel(blob);            
            var memStream = new MemoryStream();
            await blob.DownloadToStreamAsync(memStream);
            // Reset to beginning of stream
            memStream.Position = 0;
            model.Contents = await new StreamReader(memStream).ReadToEndAsync();                

            return model;
        }

        
        public async Task<StorageModel> CreateBlobAsync(string fileName, string contents)
        {
            StorageModel model = null;

            var container = await GetCloudBlobContainerAsync();

            var blob = container.GetBlockBlobReference(fileName);

            using (var stream = new MemoryStream(Encoding.Default.GetBytes(contents), false))
            {
                await blob.UploadFromStreamAsync(stream);
            }

            model = new StorageModel(blob);

            return model;
        }

        
        public async Task DeleteAsync(string fileName)
        {
            var container = await GetCloudBlobContainerAsync();
            var blob = container.GetBlockBlobReference(fileName);            
            await blob.DeleteAsync();
        }
    }
}
