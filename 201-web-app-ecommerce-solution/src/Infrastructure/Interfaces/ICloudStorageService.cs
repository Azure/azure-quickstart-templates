using Microsoft.eShopWeb.ApplicationCore.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Infrastructure.Interfaces
{
    public interface ICloudStorageService
    {
        Task CreateQueueMessage(string Message);

        Task<Uri> UploadFile(string filepath);

        Task UploadFiles(IEnumerable<CatalogItem> items);
    }
}
