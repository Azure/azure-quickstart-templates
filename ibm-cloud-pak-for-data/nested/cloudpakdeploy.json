{
	"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
	"contentVersion": "1.0.0.0",
	"parameters": {
		"assembly": {
			"type": "string",
			"metadata": {
				"description": "CloudPak assembly to install"
			}
		},
		"cloudPakDeploymentScriptUrl": {
			"type": "string",
			"metadata": {
				"description": "Bastion prep script Url"
			}
		},
		"cloudPakDeploymentScriptFileName": {
			"type": "string",
			"metadata": {
				"description": "Bastion prep script file name"
			}
		},
		"redHatTags": {
			"type": "object",
			"metadata": {
				"description": "Red Hat Tags"
			}
		},
		"adminUsername": {
			"type": "string",
			"metadata": {
				"description": "Admin Username"
			}
		},
		"ocuser": {
			"type": "string",
			"metadata": {
				"description": "OpenShift Username"
			}
		},
		"ocpassword": {
			"type": "securestring",
			"metadata": {
				"description": "OpenShift Password"
			}
		},
		"storageOption": {
			"type": "string",
			"metadata": {
				"description": "Storage for CPD installation"
			}
		},
		"bastionHostname": {
			"type": "string",
			"metadata": {
				"description": "Bastion Hostname"
			}
		},
		"projectName": {
			"type": "string",
			"metadata": {
				"description": "Project name to deploy CloudPak for Data to"
			}
		},
		"location": {
			"type": "string",
			"metadata": {
				"description": "Region where the resources should be created in"
			}
		},
		"clusterName": {
			"type": "string",
			"metadata": {
				"description": "Cluster resources prefix"
			}
		},
		"domainName": {
			"type": "string",
			"metadata": {
				"description": "Domain name created with the App Service"
			}
		}
	},
	"variables": {
	},
	"resources": [
		{
			"type": "Microsoft.Compute/virtualMachines/extensions",
			"name": "[concat(parameters('bastionHostname'), '/deployOpenshift')]",
			"location": "[parameters('location')]",
			"apiVersion": "2019-07-01",
			"tags": {
				"displayName": "DeployCloudPak",
				"app": "[parameters('redHatTags').app]",
				"version": "[parameters('redHatTags').version]",
				"platform": "[parameters('redHatTags').platform]"
			},
			"properties": {
				"publisher": "Microsoft.Azure.Extensions",
				"type": "CustomScript",
				"typeHandlerVersion": "2.0",
				"autoUpgradeMinorVersion": true,
				"settings": {
					"fileUris": [
						"[parameters('cloudPakDeploymentScriptUrl')]"
					]
				},
				"protectedSettings": {
					"commandToExecute": "[concat('bash ', parameters('cloudPakDeploymentScriptFileName'), ' \"', parameters('adminUsername'), '\"', ' \"', parameters('ocpassword'), '\"', ' \"', parameters('projectName'), '\"', ' \"', parameters('storageOption'), '\"', ' \"', parameters('assembly'), '\"', ' \"', parameters('clusterName'), '\"', ' \"', parameters('domainName'), '\"', ' \"', parameters('ocuser'), '\"')]"
				}
			}
		}
	],
	"outputs": {
	}
}
