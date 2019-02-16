using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace aspnet_mvc_keyvault_storage.Models
{
    public interface IBlobRepository
    {        
        Task<List<StorageModel>> GetBlobListAsync();

        Task<StorageModel> CreateBlobAsync(string fileName, string contents);

        Task<StorageModel> GetBlobAsync(string fileName);

        Task DeleteAsync(string fileName);
    }
}
