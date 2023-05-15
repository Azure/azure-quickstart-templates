# Tenant Level Deployment Templates

This folder contains sample templates that must be deployed at the tenant scope.  From the tenant scope, you can create deployments at multiple child scopes using nested deployments.

For for more information see the documentation for [subscription](https://docs.microsoft.com/azure/azure-resource-manager/deploy-to-subscription), [managementGroup](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-to-management-group) and [tenant](https://docs.microsoft.com/azure/azure-resource-manager/templates/deploy-to-tenant) deployments.

In order to deploy a template at the tenant scope, the principal deploying the template must have permissions to deploy resources at the tenant scope.  This includes not only the appropriate deployment actions (Microsoft.Resources/deployments/*) but permission to create the resources in the template.  For example, to create a management group, the principal must have **Contributor** permission at the tenant scope.  In order to create role assignments, **Owner** permissions are required.

To provide these initial assignments, a **Global Administrator** for the AAD must assign the **User Access Administrator** role to a principal that can then assign the roles necessary for deployment.  The **Global Administrator** does not automatically have permission to assign roles, so the global admin must call the elevateAccess api first.  Once a principal has the **User Access Administrator** role (which is granted by calling the elevateAccess api), that principal can perform subsequent role assignments.

The **Global Administrator** must do the following to enable template deployments:

- Grant the **User Access Administrator** role to a principal which can be done [via REST](https://docs.microsoft.com/rest/api/authorization/globaladministrator/elevateaccess#code-try-0) or the [Azure Portal](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties) - this will grant the user executing this command permission to perform the next step - initially this step is performed by the aad global admin granting that global admin permissions to assign roles.

- Assign the **Owner** role to the principal that needs to perform role assignments.  Note if the template being deployed does not require owner permissions like the other tenant samples in the repo, then **Contributor** permission may be sufficient.  In this case, we are assigning another principal (or self) the permission to assign roles.

```PowerShell
New-AzRoleAssignment -SignInName "[userId]" -Scope "/" -RoleDefinitionName "Owner"
```

```bash
az role assignment create --role "Owner" --assignee "[userId]" --scope "/"
```

Now, with owner (or contributor) permissions, the principal with the above roles assigned, can now deploy tenant level templates.
