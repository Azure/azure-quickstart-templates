# Snippet - Supported Reserved IP Use Cases

This template demonstrates the currently supported use case for Reserved IP.  A Reserved IP is simply a statically allocated Public IP.  

There is currently only one supported use case: assign a Reserved IP to the front end of the Azure Load Balancer.  

This template goes one step further: it both creates a new Reserved IP and assigns it to a load balancer and it uses a previously existing Reserved IP and assigns it to a separate load balancer.

# Parameters

Three parameters are needed in support of the "previously existing Reserved IP" use case:

1. Existing\_IP\_Subscription_ID - subscription ID of the subscription with the previously existing Reserved IP
2. Existing\_IP\_Reserved\_RG\_Name - name of the resource group with the previously existing Reserved IP
3. Existing\_IP\_Reserved\_Name - name of the previously existing Reserved IP



Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsebastus%2Fazure-quickstart-templates%2Fmaster%2Freservedip%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
