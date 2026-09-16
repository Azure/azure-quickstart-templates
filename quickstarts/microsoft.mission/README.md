# Azure Enclave Quickstart Templates

Welcome to the Azure Enclave quickstart templates. These templates help you deploy foundational infrastructure and services for Azure Enclave environments.

## What is Azure Enclave?

Azure Enclave provides isolated, secure environments for sensitive workloads. It combines infrastructure isolation, network segmentation, and encryption to create a trusted execution environment within Azure. For more details, visit the [Azure Enclave documentation](https://aka.ms/ae/docs).

## Important Note on Template Differences

**The templates in this quickstart repository are different from the templates built-in to the Azure Enclave product.** These quickstart templates are independently maintained and provided as reference implementations and starting points for common infrastructure patterns. The built-in product templates are included with Azure Enclave deployments and may differ in structure, parameters, and capabilities.

Always verify that the template version you choose matches your requirements and use case.

## Available Templates

| Template | Description | Features |
|----------|-------------|----------|
| **azure-enclave-keyvault** | Deploys a secure key management solution within an Azure Enclave environment | Azure Key Vault, Private DNS integration, RBAC, Network isolation |

## Contributing

These templates follow the [Azure Quickstart Templates Contribution Guide](../../1-CONTRIBUTION-GUIDE/README.md). To contribute new templates or modifications, please review that guide for:
- File naming conventions and structure
- Metadata and validation requirements
- Testing and deployment procedures
- Pull request submission guidelines

## License

These templates are provided under the same license as the Azure Quickstart Templates repository.
