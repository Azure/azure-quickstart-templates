# Use Linked Template to Limit Main Template Complexity (App Gateway)

The template [paramappgateway.json](../nested/paramappgateway.json) is used to limit the complexity of the main template by encapsulating the deployment of an Application Gateway and only exposing parameters for the things that need to be changed for each deployment.  The template is only referenced one time in [azuredeploy.json#L521](../azuredeploy.json#L521).

The values that need to change for each deployment are listed as parameters: [paramappgateway.json#L4-L35](../nested/paramappgateway.json#L4-L35).

The purpose of the Application Gateway in this template is to load balance incoming connections on port 80 (http) to all of the back-end nodes.  You can see the `frontendPorts` defined as a single listener on port 80: 

Frontend Port Definition: [paramappgateway.json#L70-L77](../nested/paramappgateway.json#L70-L77).

HTTP Listener Definition: [paramappgateway.json#L95-L109](../nested/paramappgateway.json#L95-L109).

A single routing rule is defined: [paramappgateway.json#L110-L126](../nested/paramappgateway.json#L110-L126).

The `backendAddressPools` properties are empty: [paramappgateway.json#L78-L82](../nested/paramappgateway.json#L78-L82).  These properties is not writable at creation time.  Instead, we create the Application Gateway first, and then pass a reference to the Application Gateway to the creation of the VMs that will end up being part of the backend pool.

When we are creating backend VMs you can see that we are constructing an id for the backend address pool to pass to the VM creation only if the Application Gateway has been deployed: in [azuredeploy.json#L600-L602](../azuredeploy.json#L600-L602).

[Home](../README.md)
