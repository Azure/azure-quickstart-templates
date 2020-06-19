# Use Linked Template to Limit Main Template Complexity (App Gateway)

The template [paramlb.json](../nested/paramlb.json) is used to limit the complexity of the main template by encapsulating the deployment of an Application Gateway and only exposing parameters for the things that need to be changed for each deployment.  The template is only referenced one time in [azuredeploy.json](../azuredeploy.json).

The values that need to change for each deployment are listed as parameters:
```
"parameters": {
  "location": {
    "type": "string",
    "defaultValue": "[resourceGroup().location]",
    "metadata": {
      "description": "Azure region for App Gateway"
    }
  },
  "lb_name": {
    "defaultValue": "",
    "type": "String"
  },
  "public_ip": {
    "type": "string",
    "defaultValue": ""
  },
  "vnet_name": {
    "defaultValue": "",
    "type": "String"
  },
  "vnet_resource_group": {
    "defaultValue": "[resourceGroup().name]",
    "type": "String"
  },
  "vnet_subnet_name": {
    "defaultValue": "default",
    "type": "String"
  }
},
```

The purpose of the Application Gateway in this template is to load balance incoming connections on port 80 (http) to all of the back-end nodes.  You can see the `frontendPorts` defined as a single listener on port 80:

```
"frontendPorts": [
  {
    "name": "port_80",
    "properties": {
      "port": 80
    }
  }
],
```
```
"httpListeners": [
  {
    "name": "http-listener",
    "properties": {
      "frontendIPConfiguration": {
        "id": "[concat(resourceId('Microsoft.Network/applicationGateways', parameters('lb_name')), '/frontendIPConfigurations/appGwPublicFrontendIp')]"
      },
      "frontendPort": {
        "id": "[concat(resourceId('Microsoft.Network/applicationGateways', parameters('lb_name')), '/frontendPorts/port_80')]"
      },
      "protocol": "Http",
      "hostNames": [
      ],
      "requireServerNameIndication": false
    }
  }
],
```

A single routing rule is defined:
```
"requestRoutingRules": [
  {
    "name": "http-rule",
    "properties": {
      "ruleType": "Basic",
      "httpListener": {
          "id": "[concat(resourceId('Microsoft.Network/applicationGateways', parameters('lb_name')), '/httpListeners/http-listener')]"
      },
      "backendAddressPool": {
          "id": "[concat(resourceId('Microsoft.Network/applicationGateways', parameters('lb_name')), '/backendAddressPools/default-backend')]"
      },
      "backendHttpSettings": {
          "id": "[concat(resourceId('Microsoft.Network/applicationGateways', parameters('lb_name')), '/backendHttpSettingsCollection/http-setting')]"
        }
    }
  }
],
```

The `backendAddressPools` array is empty.  This property is not writable at creation time.  Instead, we create the Application Gateway first, and then pass a reference to the Application Gateway to the creation of the VMs that will end up being part of the backend pool.

```
"backendAddressPools": [
  {
    "name": "default-backend",
    "properties": {
      "backendAddresses": [
      ],
      "backendIPConfigurations": [
      ]
    }
  }
],
```

When we are creating backend VMs in [azuredeploy.json#L581-L583](../azuredeploy.json#L581-L583) you can see that we are constructing an id for the backend address pool to pass to the VM creation:
```
"loadbalancer_id_or_empty": {
  "value": "[if(equals(parameters('Deploy App Gateway Frontend'),'Yes'),concat(resourceId('Microsoft.Network/applicationGateways','frontend-loadbalancer'),'/backendAddressPools/default-backend'),'')]"
}
```

[Home](../README.md)