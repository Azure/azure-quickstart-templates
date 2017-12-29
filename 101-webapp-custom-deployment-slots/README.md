# Deploy a Web App with custom deployment slots

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-custom-deployment-slots%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-custom-deployment-slots%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template provides an easy way to deploy web app with custom deployment slots/environments on Azure Web Apps.<br>
The `environments` parameter (array) can be used to specify different slot/environment names, and a slot will be created for every item listed in the array.

To specify multiple environments, say N, follow this simple rule:<br>
Add N - 1 items, as depicted in the below example, with N = 5. There's always a default "nameless" slot created by default:

// Environments -> Deployment slots will be created for every environment listed here

```javascript
    "environments": {
      "value": [
        "Dev",
        "Next",
        "Preview",
        "Future"
        // A default, "nameless" slot will be created; so don't list it here
      ]
     }
```

Please note that different app service plans has different caps on the number of slots that can be created.<br>
For example, at the time of this writing, a *Standard* plan puts a cap of **5** and a *Premium* plan **20**. The *Free*, *Shared* or *Basic* plans are not allowed to have any slots.
