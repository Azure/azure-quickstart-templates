using Microsoft.Azure.Search;
using Microsoft.Azure.Search.Models;
using Microsoft.eShopWeb.ApplicationCore.Entities;
using Microsoft.Extensions.Configuration;
using System.Linq;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Infrastructure.Services
{
    public class SearchService
    {
        private readonly string INDEX_CATALOG_NAME = "catalog";

        public string SearchServiceName { private set; get; }
        public string SearchServiceAdminApiKey { private set; get; }
        public string SearchServiceQueryApiKey { private set; get; }

        public SearchService(string searchServiceName, string searchServiceAdminApiKey, string searchServiceQueryApiKey)
        {
            SearchServiceName = searchServiceName;
            SearchServiceAdminApiKey = searchServiceAdminApiKey;
            SearchServiceQueryApiKey = searchServiceQueryApiKey;
        }

        // This sample shows how to delete, create, upload documents and query an index
        public void IndexCatalog(IEnumerable<CatalogItem> items)
        {
            SearchServiceClient serviceClient = new SearchServiceClient(SearchServiceName, new SearchCredentials(SearchServiceAdminApiKey));

            // Deleting index...
            if (serviceClient.Indexes.Exists(INDEX_CATALOG_NAME))
            {
                serviceClient.Indexes.Delete(INDEX_CATALOG_NAME);
            }

            // Creating index...
            serviceClient.Indexes.Create(new Index()
            {
                Name = INDEX_CATALOG_NAME,
                Fields = FieldBuilder.BuildForType<CatalogItemSearchIndex>()
            });

            // Uploading documents...
            ISearchIndexClient indexClient = serviceClient.Indexes.GetClient(INDEX_CATALOG_NAME);

            var batch = IndexBatch.Upload(items.Select(o => new CatalogItemSearchIndex // data adapting
            {
                Id = o.Id.ToString(),
                Name = o.Name,
                Description = o.Description,
                Price = (double)o.Price,
                PictureUri = o.PictureUri,
                CatalogBrandId = o.CatalogBrandId,
                CatalogTypeId = o.CatalogTypeId
            }));

            try
            {
                indexClient.Documents.Index(batch);
            }
            catch (IndexBatchException ex)
            {
                throw;
                // Sometimes when your Search service is under load, indexing will fail for some of the documents in
                // the batch. Depending on your application, you can take compensating actions like delaying and
                // retrying. For this simple demo, we just log the failed document keys and continue.
                
                // TODO: log error here
                //var log = _loggerFactory.CreateLogger<SearchService>();
                //log.LogError(ex.Message + ", failed to index some of the documents: {0}", string.Join(", ", ex.IndexingResults.Where(r => !r.Succeeded).Select(r => r.Key)));
            }
        }

        public DocumentSearchResult<CatalogItemSearchIndex> SearchCatalog(int pageIndex, int pageSize, int? brandId, int? typeId, string keywords)
        {
            SearchIndexClient indexClient = new SearchIndexClient(SearchServiceName, INDEX_CATALOG_NAME, new SearchCredentials(SearchServiceQueryApiKey));

            if (string.IsNullOrEmpty(keywords))
            {
                keywords = "*";
            }

            string filter = null;
            if (brandId != null)
            {
                filter = "CatalogBrandId eq " + brandId.Value;
            }
            if (typeId != null)
            {
                if (!string.IsNullOrEmpty(filter))
                {
                    filter += " and ";
                }

                filter += "CatalogTypeId eq " + typeId.Value;
            }

            var parameters = new SearchParameters
            {
                Filter = filter,
                Skip = pageIndex * pageSize,
                Top = pageSize,
                IncludeTotalResultCount = true
            };

            return indexClient.Documents.Search<CatalogItemSearchIndex>(keywords, parameters);
        }
    }

    public class CatalogItemSearchIndex
    {
        [Key]
        [IsFilterable]
        public string Id { get; set; }
        [IsSearchable]
        public string Name { get; set; }
        [IsSearchable]
        public string Description { get; set; }
        public double Price { get; set; }
        public string PictureUri { get; set; }
        [IsFilterable]
        public int CatalogTypeId { get; set; }
        [IsFilterable]
        public int CatalogBrandId { get; set; }
    }
}
