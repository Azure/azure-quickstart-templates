import math


def generate_template(location, datacenterIndex, vmSize, nodeCount, adminUsername, adminPassword, locations):
    resources = []

    resources.append(availabilitySet(location, datacenterIndex))
    resources.append(virtualNetwork(location, datacenterIndex))

    for nodeIndex in range(0, nodeCount):
        resources.append(publicIPAddress(location, datacenterIndex, nodeIndex))
        resources.append(networkInterface(location, datacenterIndex, nodeIndex))

        storageAccountIndex = int(math.floor(nodeIndex / 40.0))
        # Check if we've attached 40 drives to the current storage account.  If so, we'll need to make a new one.
        if (nodeIndex % 40) == 0:
            resources.append(storageAccount(location, datacenterIndex, storageAccountIndex))

        resources.append(virtualmachine(location, datacenterIndex, nodeIndex, storageAccountIndex, vmSize, adminUsername, adminPassword))
        resources.append(extension(location, datacenterIndex, nodeIndex, locations))

    return resources


def availabilitySet(location, datacenterIndex):
    name = "dc" + str(datacenterIndex)

    resource = {
        "apiVersion": "2015-06-15",
        "type": "Microsoft.Compute/availabilitySets",
        "name": name,
        "location": location,
        "properties": {
            "platformFaultDomainCount": 3,
            "platformUpdateDomainCount": 18
        }
    }
    return resource


def virtualNetwork(location, datacenterIndex):
    name = "dc" + str(datacenterIndex)

    resource = {
        "apiVersion": "2015-06-15",
        "type": "Microsoft.Network/virtualNetworks",
        "name": name,
        "location": location,
        "properties": {
            "addressSpace": {
                "addressPrefixes": [
                    "10." + str(datacenterIndex) + ".0.0/16"
                ]
            },
            "subnets": [
                {
                    "name": "subnet",
                    "properties": {
                        "addressPrefix": "10." + str(datacenterIndex) + ".0.0/24"
                    }
                }
            ]
        }
    }
    return resource


def publicIPAddress(location, datacenterIndex, nodeIndex):
    name = "dc" + str(datacenterIndex) + "vm" + str(nodeIndex)

    resource = {
        "apiVersion": "2015-06-15",
        "type": "Microsoft.Network/publicIPAddresses",
        "name": name,
        "location": location,
        "properties": {
            "publicIPAllocationMethod": "Dynamic",
            "dnsSettings": {
                "domainNameLabel": "[concat('" + name + "', variables('uniqueString'))]"
            }
        }
    }
    return resource


def networkInterface(location, datacenterIndex, nodeIndex):
    virtualNetworkName = "dc" + str(datacenterIndex)
    name = "dc" + str(datacenterIndex) + "vm" + str(nodeIndex)

    resource = {
        "apiVersion": "2015-06-15",
        "type": "Microsoft.Network/networkInterfaces",
        "name": name,
        "location": location,
        "dependsOn": [
            "Microsoft.Network/virtualNetworks/" + virtualNetworkName,
            "Microsoft.Network/publicIPAddresses/" + name
        ],
        "properties": {
            "ipConfigurations": [
                {
                    "name": "ipConfig",
                    "properties": {
                        "publicIPAddress": {
                            "id": "[resourceId('Microsoft.Network/publicIPAddresses','" + name + "')]"
                        },
                        "privateIPAllocationMethod": "Dynamic",
                        "subnet": {
                            "id": "[concat(resourceId('Microsoft.Network/virtualNetworks', '" + virtualNetworkName + "'), '/subnets/subnet')]"
                        }
                    }
                }
            ]
        }
    }
    return resource


def storageAccount(location, datacenterIndex, storageAccountIndex):
    name = "dc" + str(datacenterIndex) + "sa" + str(storageAccountIndex)

    resource = {
        "apiVersion": "2015-06-15",
        "type": "Microsoft.Storage/storageAccounts",
        "name": "[concat('" + name + "', variables('uniqueString'))]",
        "location": location,
        "properties": {
            "accountType": "Standard_LRS"
        }
    }
    return resource


def virtualmachine(location, datacenterIndex, nodeIndex, storageAccountIndex, vmSize, adminUsername, adminPassword):
    availabilitySetName = "dc" + str(datacenterIndex)
    name = "dc" + str(datacenterIndex) + "vm" + str(nodeIndex)
    storageAccountName = "dc" + str(datacenterIndex) + "sa" + str(storageAccountIndex)

    resource = {
        "apiVersion": "2015-06-15",
        "type": "Microsoft.Compute/virtualMachines",
        "name": name,
        "location": location,
        "dependsOn": [
            "Microsoft.Compute/availabilitySets/" + availabilitySetName,
            "Microsoft.Network/networkInterfaces/" + name,
            "[concat('Microsoft.Storage/storageAccounts/" + storageAccountName + "', variables('uniqueString'))]"
        ],
        "properties": {
            "availabilitySet": {
                "id": "[resourceId('Microsoft.Compute/availabilitySets', '" + availabilitySetName + "')]"
            },
            "hardwareProfile": {
                "vmSize": vmSize
            },
            "osProfile": {
                "computername": name,
                "adminUsername": adminUsername,
                "adminPassword": adminPassword
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
                        "uri": "[concat('http://" + storageAccountName + "', variables('uniqueString'), '.blob.core.windows.net/vhds/" + name + "-osdisk.vhd')]"
                    },
                    "caching": "ReadWrite",
                    "createOption": "FromImage"
                }
            },
            "networkProfile": {
                "networkInterfaces": [
                    {
                        "id": "[resourceId('Microsoft.Network/networkInterfaces','" + name + "')]"
                    }
                ]
            }
        }
    }
    return resource


def extension(location, datacenterIndex, nodeIndex, locations):
    data_center_name = "dc" + str(datacenterIndex) + '-' + location
    name = "dc" + str(datacenterIndex) + "vm" + str(nodeIndex)

    resource = {
        "type": "Microsoft.Compute/virtualMachines/extensions",
        "name": name + "/installdsenode",
        "apiVersion": "2015-06-15",
        "location": location,
        "dependsOn": [
            "Microsoft.Compute/virtualMachines/" + name
        ],
        "properties": {
            "publisher": "Microsoft.OSTCExtensions",
            "type": "CustomScriptForLinux",
            "typeHandlerVersion": "1.4",
            "autoUpgradeMinorVersion": True,
            "settings": {
                "fileUris": [
                    "https://raw.githubusercontent.com/DSPN/azure-resource-manager-dse/master/extensions/node.sh"
                ],
                "commandToExecute": "[concat('bash node.sh " + locations[0] + " ', variables('uniqueString'), ' " + data_center_name + "')]"
            }
        }
    }
    return resource
