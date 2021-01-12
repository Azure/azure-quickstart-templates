{
	"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
	"contentVersion": "1.0.0.0",
	"parameters": {
		"_artifactsLocation": {
			"type": "string",
			"metadata": {
				"description": "The base URL where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated."
			}
		},
		"_artifactsLocationSasToken": {
			"type": "securestring",
			"metadata": {
				"description": "Token for the base URL where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated."
			}
		},
		"location": {
			"type": "string",
			"metadata": {
				"description": "Region where the resources should be created in"
			}
		},
		"openshiftDeploymentScriptUrl": {
			"type": "string",
			"metadata": {
				"description": "Bastion prep script Url"
			}
		},
		"openshiftDeploymentScriptFileName": {
			"type": "string",
			"metadata": {
				"description": "Bastion prep script file name"
			}
		},
		"masterInstanceCount": {
			"type": "int",
			"metadata": {
				"description": "Number of OpenShift Master nodes"
			}
		},
		"workerInstanceCount": {
			"type": "int",
			"metadata": {
				"description": "Number of OpenShift nodes"
			}
		},
		"adminUsername": {
			"type": "string",
			"minLength": 1,
			"metadata": {
				"description": "Administrator username on all VMs"
			}
		},
		"openshiftUsername": {
			"type": "securestring",
			"minLength": 1,
			"metadata": {
				"description": "Administrator password for OpenShift Console"
			}
		},
		"openshiftPassword": {
			"type": "securestring",
			"minLength": 1,
			"metadata": {
				"description": "Administrator password for OpenShift Console"
			}
		},
		"aadClientId": {
			"type": "string",
			"metadata": {
				"description": "Azure AD Client ID"
			}
		},
		"aadClientSecret": {
			"type": "securestring",
			"metadata": {
				"description": "Azure AD Client Secret"
			}
		},
		"redHatTags": {
			"type": "object",
			"metadata": {
				"description": "Red Hat Tags"
			}
		},
		"pullSecret": {
			"type": "securestring",
			"minLength": 1,
			"metadata": {
				"description": "OCP Pull Secret"
			}
		},
		"virtualNetworkName": {
			"type": "string",
			"metadata": {
				"description": "Virtual Network Cluster is deployed in"
			}
		},
		"virtualNetworkCIDR": {
			"type": "string",
			"metadata": {
				"description": "Virtual Network address prefix"
			}
		},
		"pxSpecUrl" : {
			"type": "string",
			"metadata": {
				"description": "Portworx Spec URL"
			}
		},
		"storageOption": {
			"type": "string",
			"metadata": {
				"description": "nfs or glusterfs"
			}
		},
		"bastionHostname": {
			"type": "string",
			"metadata": {
				"description": "Bastion Hostname"
			}
		},
		"nfsIpAddress": {
			"type": "string",
			"metadata": {
				"description": "NFS Hostname"
			}
		},
		"singleZoneOrMultiZone": {
			"type": "string",
			"metadata": {
				"description": "Deploy to a Single AZ or multiple AZs"
			}
		},
		"dnsZone": {
			"type": "string",
			"metadata": {
				"description": "Domain name created with the App Service"
			}
		},
		"dnsZoneRG": {
			"type": "string",
			"metadata": {
				"description": "Resource Group that contains the domain name"
			}
		},
		"masterInstanceType": {
			"type": "string",
			"metadata": {
				"description": "OpenShift Master VM size. Use VMs with Premium Storage support only."
			}
		},
		"workerInstanceType": {
			"type": "string",
			"metadata": {
				"description": "OpenShift Node VM(s) size. Use VMs with Premium Storage support only."
			}
		},
		"clusterName": {
			"type": "string",
			"metadata": {
				"description": "Cluster resources prefix"
			}
		},
		"networkResourceGroup": {
			"type": "string",
			"metadata": {
				"description": "Resource Group for Vnet."
			}
		},
		"masterSubnetName": {
			"type": "string",
			"metadata": {
				"description": "Name of new or existing master subnet"
			}
		},
		"workerSubnetName": {
			"type": "string",
			"metadata": {
				"description": "Name of new or existing worker subnet"
			}
		},
		"enableFips": {
			"type": "bool",
            "metadata": {
                "description": "Enable FIPS encryption"
            }
		},
		"privateOrPublic": {
			"type": "string",
			"metadata": {
				"description": "Public or private facing endpoints"
			}
		},
		"sshPublicKey": {
			"type": "string",
			"metadata": {
				"description": "SSH public key for all VMs"
			}
		}
	},
	"variables": {
		"singlequote": "'",
		"tenantId": "[subscription().tenantId]",
		"subscriptionId": "[subscription().subscriptionId]",
		"resourceGroupName": "[resourceGroup().name]",
		"cidr-prefix": "[split(parameters('virtualNetworkCIDR'), '.')[0]]",
		"clusterNetworkCidr": "[concat(variables('cidr-prefix'), '.128.0.0/14')]",
		"hostAddressPrefix": 23,
		"serviceNetworkCidr": "192.30.0.0/16"
	},
	"resources": [{
		"type": "Microsoft.Compute/virtualMachines/extensions",
		"name": "[concat(parameters('bastionHostname'), '/deployOpenshift')]",
		"location": "[parameters('location')]",
		"apiVersion": "2019-07-01",
		"tags": {
			"displayName": "DeployOpenshift",
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
					"[parameters('openshiftDeploymentScriptUrl')]"
				]
			},
			"protectedSettings": {
				"commandToExecute": "[concat('bash ', parameters('openshiftDeploymentScriptFileName'), ' \"', parameters('adminUsername'), '\" ', '\"', parameters('openshiftPassword'), '\" ', '\"', parameters('sshPublicKey'), '\" ', '\"', parameters('workerInstanceCount'), '\" ', '\"', parameters('masterInstanceCount'), '\" ', '\"', variables('subscriptionId'), '\" ', '\"', variables('tenantId'), '\" ', '\"', parameters('aadClientId'), '\" ', '\"', parameters('aadClientSecret'), '\" ', '\"', variables('resourceGroupName'), '\" ', '\"', parameters('location'), '\" ', ' \"', parameters('virtualNetworkName'), '\"', ' \"', parameters('pxSpecUrl'), '\"', ' \"', parameters('storageOption'), '\"', ' \"', parameters('nfsIpAddress'), '\"', ' \"', parameters('singleZoneOrMultiZone'), '\"', ' \"', parameters('_artifactsLocation'), '\"', ' \"', parameters('_artifactsLocationSasToken'), '\"', ' \"', parameters('dnsZone'), '\"', ' \"', parameters('masterInstanceType'), '\"', ' \"', parameters('workerInstanceType'), '\"', ' \"', parameters('clusterName'), '\"', ' \"', variables('clusterNetworkCidr'), '\"', ' \"', variables('hostAddressPrefix'), '\"', ' \"', parameters('virtualNetworkCIDR'), '\"', ' \"', variables('serviceNetworkCidr'), '\"', ' \"', parameters('dnsZoneRG'), '\"', ' \"', parameters('networkResourceGroup'), '\"', ' \"', parameters('masterSubnetName'), '\"', ' \"', parameters('workerSubnetName'), '\" ', variables('singlequote'), parameters('pullSecret'), variables('singlequote'), ' \"', parameters('enableFips'), '\"', ' \"', parameters('privateOrPublic'), '\"', ' \"', parameters('openshiftUsername'), '\"')]"
			}
		}
	}],
	"outputs": {}
}
