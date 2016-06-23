import base64
import json


def generate_template(locations, nodeCount, adminUsername, adminPassword):
    # We're going to create all these resources in resourceGroup().location

    resources = []
    resources.append(virtualNetwork)
    resources.append(publicIPAddress)
    resources.append(networkInterface)
    resources.append(storageAccount)
    resources.append(virtualmachine(adminUsername, adminPassword))
    resources.append(extension(locations, nodeCount, adminUsername, adminPassword))
    return resources


virtualNetwork = {
    "apiVersion": "2015-06-15",
    "type": "Microsoft.Network/virtualNetworks",
    "name": "opscenter",
    "location": "[resourceGroup().location]",
    "properties": {
        "addressSpace": {
            "addressPrefixes": [
                "10.0.0.0/16"
            ]
        },
        "subnets": [
            {
                "name": "subnet",
                "properties": {
                    "addressPrefix": "10.0.1.0/24"
                }
            }
        ]
    }
}


publicIPAddress = {
    "apiVersion": "2015-06-15",
    "type": "Microsoft.Network/publicIPAddresses",
    "name": "opscenter",
    "location": "[resourceGroup().location]",
    "properties": {
        "publicIPAllocationMethod": "Dynamic",
        "dnsSettings": {
            "domainNameLabel": "[concat('opscenter', variables('uniqueString'))]"
        }
    }
}

networkInterface = {
    "apiVersion": "2015-06-15",
    "type": "Microsoft.Network/networkInterfaces",
    "name": "opscenter",
    "location": "[resourceGroup().location]",
    "dependsOn": [
        "Microsoft.Network/virtualNetworks/opscenter",
        "Microsoft.Network/publicIPAddresses/opscenter"
    ],
    "properties": {
        "ipConfigurations": [
            {
                "name": "ipConfig",
                "properties": {
                    "publicIPAddress": {
                        "id": "[resourceId('Microsoft.Network/publicIPAddresses','opscenter')]"
                    },
                    "privateIPAllocationMethod": "Dynamic",
                    "subnet": {
                        "id": "[concat(resourceId('Microsoft.Network/virtualNetworks', 'opscenter'), '/subnets/subnet')]"
                    }
                }
            }
        ]
    }
}

storageAccount = {
    "apiVersion": "2015-06-15",
    "type": "Microsoft.Storage/storageAccounts",
    "name": "[concat('opscenter', variables('uniqueString'))]",
    "location": "[resourceGroup().location]",
    "properties": {
        "accountType": "Standard_LRS"
    }
}


def virtualmachine(username, password):
    return {
        "apiVersion": "2015-06-15",
        "type": "Microsoft.Compute/virtualMachines",
        "name": "opscenter",
        "location": "[resourceGroup().location]",
        "dependsOn": [
            "Microsoft.Network/networkInterfaces/opscenter",
            "[concat('Microsoft.Storage/storageAccounts/opscenter', variables('uniqueString'))]"
        ],
        "properties": {
            "hardwareProfile": {
                "vmSize": "Standard_A1"
            },
            "osProfile": {
                "computername": "opscenter",
                "adminUsername": username,
                "adminPassword": password
            },
            "storageProfile": {
                "imageReference": {
                    "publisher": "Canonical",
                    "offer": "UbuntuServer",
                    "sku": "14.04.4-LTS",
                    "version": "latest"
                },
                "osDisk": {
                    "name": "osdisk",
                    "vhd": {
                        "uri": "[concat('http://opscenter', variables('uniqueString'), '.blob.core.windows.net/vhds/opscenter-osdisk.vhd')]"
                    },
                    "caching": "ReadWrite",
                    "createOption": "FromImage"
                }
            },
            "networkProfile": {
                "networkInterfaces": [
                    {
                        "id": "[resourceId('Microsoft.Network/networkInterfaces','opscenter')]"
                    }
                ]
            }
        }
    }


def extension(locations, nodeCount, adminUsername, adminPassword):
    resource = {
        "type": "Microsoft.Compute/virtualMachines/extensions",
        "name": "opscenter/installopscenter",
        "apiVersion": "2015-06-15",
        "location": "[resourceGroup().location]",
        "dependsOn": [
            "Microsoft.Compute/virtualMachines/opscenter"
        ],
        "properties": {
            "publisher": "Microsoft.OSTCExtensions",
            "type": "CustomScriptForLinux",
            "typeHandlerVersion": "1.3",
            "autoUpgradeMinorVersion": True,
            "settings": {
                "fileUris": [
                    "https://raw.githubusercontent.com/DSPN/azure-resource-manager-dse/master/extensions/opsCenter.sh"
                ],
                "commandToExecute": "[concat('bash opsCenter.sh " + locations[0] + " ', variables('uniqueString'))]"
            }
        }
    }
    return resource
