# IngestionQueries app

Config-driven data ingestion via query orchestration for FinOps hubs. Reads query definition files from blob storage, dispatches each to the appropriate query engine pipeline, manages file deduplication, and creates ingestion manifests for ADX.

## How it works

1. A daily schedule trigger fires `queries_ExecuteETL`
2. The pipeline reads all `*.json` files from `config/queries/`
3. For each query file, it calls `queries_ETL_ingestion` which:
   - Normalizes the query scope (handles "Tenant" and leading slashes)
   - Computes the ingestion path: `{dataset}/{scope}/{queryType}/{ingestionId}__`
   - Deletes old parquet files from previous runs (same folder, different ingestion ID)
   - Loads the schema mapping from `config/schemas/{dataset}_{version}.json`
   - Dispatches to `queries_{queryEngine}_ExecuteQuery` via ADF REST API
   - Polls for completion
   - Creates a manifest file to trigger ADX ingestion

## Adding a new query engine

A query engine is a separate hub app that provides a single ADF pipeline capable of executing a query and writing results as Parquet.

### Pipeline contract

The pipeline must be named `queries_{engineName}_ExecuteQuery` and accept these parameters:

| Parameter       | Type   | Description                                               |
| --------------- | ------ | --------------------------------------------------------- |
| `query`         | String | The query text to execute                                 |
| `querySource`   | String | Human-readable source name (e.g., "Azure Advisor")        |
| `queryType`     | String | Query type identifier (e.g., "Microsoft-AdvisorCost")     |
| `queryProvider` | String | Provider identifier (e.g., "Microsoft")                   |
| `queryVersion`  | String | Query version (e.g., "1.0")                               |
| `ingestionPath` | String | Full blob path prefix for the output parquet file         |
| `translator`    | Object | ADF TabularTranslator mapping object from the schema file |

The pipeline must:

- Execute the query against its data source
- Write the result as a single Parquet file to the `ingestion` container at the path specified by `ingestionPath`
- Use the `translator` for column mapping
- Append source metadata columns (`x_SourceName`, `x_SourceType`, `x_SourceProvider`, `x_SourceVersion`) to each row

### App registration

The engine app should register with `features: ['DataFactory']` and reference shared resources from Core via `existing` declarations.

See `../AzureResourceGraph/app.bicep` for a reference implementation.

### Hub wiring

In `hub.bicep`, add the engine module with `dependsOn: [core]`:

```bicep
module myEngine 'Microsoft.FinOpsHubs/{EngineName}/app.bicep' = if (enableMyFeature) {
  name: 'Microsoft.FinOpsHubs.{EngineName}'
  dependsOn: [core]
  params: {
    app: newApp(hub, 'Microsoft.FinOpsHubs', '{EngineName}')
  }
}
```

## Query file format

Query files are JSON files uploaded to `config/queries/` by data source apps (e.g., Recommendations). Each file defines a single query:

```json
{
  "dataset": "Recommendations",
  "provider": "Microsoft",
  "query": "advisorresources | where type == 'microsoft.advisor/recommendations' | ...",
  "queryEngine": "ResourceGraph",
  "scope": "Tenant",
  "source": "Azure Advisor",
  "type": "Microsoft-AdvisorCost",
  "version": "1.0"
}
```

| Field         | Description                                                                      |
| ------------- | -------------------------------------------------------------------------------- |
| `dataset`     | Target managed dataset name (determines top-level folder in ingestion container) |
| `provider`    | Publisher/provider identifier                                                    |
| `query`       | The query text passed to the engine pipeline                                     |
| `queryEngine` | Engine name; must match a `queries_{queryEngine}_ExecuteQuery` pipeline          |
| `scope`       | Query scope; "Tenant" is normalized to `tenants/{tenantId}` at runtime           |
| `source`      | Human-readable source name for `x_SourceName`                                    |
| `type`        | Query type identifier; used as subfolder under scope                             |
| `version`     | Query version; determines which schema file to load (`{dataset}_{version}.json`) |

## Schema file format

Schema files live in `config/schemas/` and follow the ADF TabularTranslator format:

```json
{
  "additionalColumns": [],
  "translator": {
    "type": "TabularTranslator",
    "mappings": [{ "source": { "path": "[['ColumnName']" }, "sink": { "path": "ColumnName" } }],
    "collectionReference": "$['data']"
  }
}
```

## Folder structure in ingestion container

```
ingestion/
  {dataset}/
    {scope}/
      {queryType}/
        {ingestionId}__{queryType}.parquet
        manifest.json
```

For recommendations with scope "Tenant":

```
ingestion/
  Recommendations/
    tenants/{tenantId}/
      Microsoft-AdvisorCost/
        20250219-010100_a1b2c3d4__Microsoft-AdvisorCost.parquet
        manifest.json
```

Each run replaces the previous parquet files (same folder path, different ingestion ID prefix).
