# AzureResourceGraph engine app

Query engine for Azure Resource Graph (ARG). Implements the `queries_{engineName}_ExecuteQuery` contract for the IngestionQueries orchestrator.

## What it provides

- **`azureResourceGraph` dataset** — ADF REST dataset pointing to the ARG API (`/providers/Microsoft.ResourceGraph/resources?api-version=2022-10-01`)
- **`queries_ResourceGraph_ExecuteQuery` pipeline** — Executes a single ARG query via REST POST and writes results as Parquet to the ingestion container

## How it works

1. IngestionQueries dispatches to this pipeline via the ADF REST API
2. The pipeline POSTs the query to the ARG endpoint, appending source metadata columns (`x_SourceName`, `x_SourceType`, `x_SourceProvider`, `x_SourceVersion`) directly in the query text
3. ARG returns results as JSON; the ADF Copy activity uses the provided `translator` to map columns and writes Parquet to the `ingestionPath`

## Dependencies

- **Core app** — provides the `azurerm` linked service (REST service with MSI auth to ARM) and the `ingestion` dataset
- **Data Factory managed identity** — must have **Reader** role on the tenant root management group (or individual subscriptions/management groups) to execute ARG queries across the tenant

## Limitations

- ARG queries are limited to 1,000 rows per page. The current implementation does not paginate, so queries returning more than 1,000 rows will be truncated. Pagination support can be added later if needed.
- ARG query text has a 10 KB limit.
