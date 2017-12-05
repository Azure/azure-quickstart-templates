# Jenkins Blue-green Deployment to VMSS (Preview)

***Disclaimer***: The blue-green deployment to Azure Virtual Machine ScaleSet (VMSS) described here is still in
preview. It may be changed in future as the Azure infrastructure level support is still not finalized.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FArieShout%2Fazure-quickstart-templates%2Fvmss-bg%2F301-jenkins-vmss-blue-green%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FArieShout%2Fazure-quickstart-templates%2Fvmss-bg%2F301-jenkins-vmss-blue-green%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template / guide allows you to deploy and configure a DevOps pipeline to upgrade VMSS images in blue-green
deployment strategy. 

It deploys two VMSS cluster (blue / green) which uses pre-baked Ubuntu 16.04 LTS image with either Tomcat 7 or 8 installed,
an Azure Load Balancer to manage the routing and load balancing to the VMSS clusters, and also an instance of Jenkins 
on Ubuntu 16.04 LTS VM to manage the blue-green deployment to upgrade the images for the VMSS clusters.

## Prerequisites

* Enable [Azure Load Balancer Standard](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-overview)
   for your subscription.

   Follow [the guide](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-overview#preview-sign-up)
   to register the the Standard tier of Azure Load Balancer for your subscription.

   **Note**: Azure Load Balancer Standard is still in preview stage.

* [Azure Service Principal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal).

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

* [Packer](https://www.packer.io/) to bake the Tomcat VM images.

   [A Packer deployment configuration](packer-tomcat.json) is included in the repo. Download it to your machine, and run
   the following commands to bake two VM images with Tomcat 7 or 8 installed. Replace the `<place-holder>` with your 
   environment configuration and run the script lines with Bash.

   ```bash
   image_resource_group="<resource-group-to-store-VM-image>"
   image_location="<location-for-the-image-resource-group>"

   client_id="<service-principal-client-id>"
   client_secret="<service-principal-client-secret>"
   subscription_id="<subscription-id>"
   tenant_id="<tenant-id>"

   # create resource group to store the VM images
   az group create --name "$image_resource_group" --location "$image_location"

   # create VM images using Packer
   for tomcat_version in 7 8; do
       packer build \
           -var "client_id=$client_id" \
           -var "client_secret=$client_secret" \
           -var "subscription_id=$subscription_id" \
           -var "tenant_id=$tenant_id" \
           -var "tomcat_version=$tomcat_version" \
           -var "resource_group=$image_resource_group" \
           -var "location=$image_location" \
           packer-tomcat.json
   done

   # record the image ID for later use
   tomcat7_image_id="$(az image show --resource-group "$image_resource_group" --name tomcat-7 --query id --output tsv)"
   tomcat8_image_id="$(az image show --resource-group "$image_resource_group" --name tomcat-8 --query id --output tsv)"
   ```

## Manual Steps to Setup and Do Blue-green Deployment on VMSS

1. Setup variables for later use. It's likely you only need to customize the `location` and the variables with `$suffix`.

   ```bash
   # resource name suffix for uniqueness
   suffix="$(uuidgen | head -c 8)"
   # resource group name for the VMSS
   resource_group="vmss-bg-$suffix"
   # location for the resource group
   location="Southeast Asia"
   # front-end load balancer name to be created
   lb_name=vmssbg-lb
   # public IP name
   ip_name=vmssbg-ip
   # DNS name for the public IP endpoint
   dns_name="vmssbg$suffix"
   # shared virtual network name
   vnet_name=vmssbg-vnet
   # shared subnet name
   subnet_name=vmssbg-subnet
   # shared network security group name
   nsg_name=vmssbg-nsg
   # admin user name for the VMSS instances
   admin_username=azureuser
   # public key for the SSH authentication on VMSS instances, generate one if not exists
   public_key="$(readlink -f ~/.ssh/id_rsa.pub)"
   ```

1. Create the resource group.

   ```bash
   az group create --name "$resource_group" --location "$location"
   ```

1. Create and setup the shared network security group.

   ```bash
   az network nsg create --resource-group "$resource_group" --name "$nsg_name"
   # for simplicity we opened a wide range of ports, you should tweak the NSG rules on your demand.
   az network nsg rule create \
       --resource-group "$resource_group" \
       --nsg-name "$nsg_name" \
       --name allow-public-access \
       --priority 101 \
       --destination-port-ranges 22-55000
   ```

1. Create the VMSS for blue environment with the `tomcat-7` image. Note that we pass in the `--lb-sku Standard`
   to use the Standard tier Azure Load Balancer.

   ```bash
   az vmss create --resource-group "$resource_group" --name vmss-blue \
       --image "$tomcat7_image_id" \
       --admin-user "$admin_username" \
       --ssh-key-value "$public_key" \
       --instance-count 2 \
       --nsg "$nsg_name" \
       --public-ip-address "$ip_name" \
       --public-ip-address-dns-name "$dns_name" \
       --vnet-name "$vnet_name" \
       --subnet "$subnet_name" \
       --lb "$lb_name" \
       --backend-pool-name blue-bepool \
       --lb-nat-pool-name blue-natpool \
       --lb-sku Standard
   ```

1. Create the backend pool and inbound NAT pool for the green environment.

   **Note**: Currently, management of multiple VMSS backends and NAT pools for Azure Load Balancer is still not
   available on Azure Portal, and the technique is not documented elsewhere. Please consider this as experimental.

   ```bash
   az network lb address-pool create --lb-name "$lb_name" -g "$resource_group" --name green-bepool
   az network lb inbound-nat-pool create \
       --backend-port 22 \
       --frontend-port-range-start 50120 \
       --frontend-port-range-end 50239 \
       --lb-name "$lb_name" \
       --name green-natpool \
       --protocol Tcp \
       --resource-group "$resource_group" \
       --frontend-ip-name loadBalancerFrontEnd
   ```

1. Create the VMSS for the green environment with the `tomcat-7` image.

   ```bash
   az vmss create --resource-group "$resource_group" --name vmss-green \
       --image "$tomcat7_image_id" \
       --admin-username azureuser \
       --instance-count 2 \
       --nsg "$nsg_name" \
       --vnet-name "$vnet_name" \
       --subnet "$subnet_name" \
       --lb "$lb_name" \
       --backend-pool-name green-bepool \
       --lb-nat-pool-name green-natpool
   ```

1. Setup the load balancer probe and initially route the traffic to the blue environment.

   ```bash
   az network lb probe create \
       --resource-group "$resource_group" \
       --lb-name "$lb_name" \
       --name tomcat \
       --port 8080 \
       --protocol Http \
       --path /
   
   az network lb rule create \
       --resource-group "$resource_group" \
       --lb-name "$lb_name" \
       --name tomcat \
       --frontend-port 80 \
       --backend-port 8080 \
       --protocol Tcp \
       --backend-pool-name blue-bepool \
       --probe-name tomcat
   ```

1. Check that you can visit the service endpoint via HTTP.

   ```bash
   ip="$(az network public-ip show --resource-group "$resource_group" --name "$ip_name" --query ipAddress --output tsv)"
   echo "Visit http://$ip"
   ```

By now we have already setup the Azure infrastructure for the VMSS blue-green deployment. The following steps show
how to deploy to the green environment, do online tests and flip the production environment from blue to green.

1. Upgrade the green environment using image `tomcat-8`.

   ```bash
   az vmss update --resource-group "$resource_group" --name vmss-green --set "virtualMachineProfile.storageProfile.imageReference.id=$tomcat8_image_id"
   az vmss update-instances --resource-group "$resource_group" --name vmss-green --instance-ids \*
   ```

1. Setup a temporary load balancer rule to verify the green environment. You can also setup another public IP endpoint
   for testing purpose.

   ```bash
   test_port=$(( ( RANDOM % 100 ) + 30000 ))
   az network lb rule create \
       --resource-group "$resource_group" \
       --lb-name "$lb_name" \
       --name tomcat-test \
       --frontend-port "$test_port" \
       --backend-port 8080 \
       --protocol Tcp \
       --backend-pool-name green-bepool \
       --probe-name tomcat
   ```

1. Wait until we can visit the test endpoint by checking the following command periodically. We can also do other
   tests on this endpoint.

   ```bash
   # periodically check until we get 200 response
   curl -s -D - -o /dev/null "http://$ip:$test_port"
   ```

1. Remove the temporary load balancer rule.

   ```bash
   az network lb rule delete --resource-group "$resource_group" --lb-name "$lb_name" --name tomcat-test
   ```

1. Switch the production environment to green.

   ```bash
   az network lb rule update --resource-group "$resource_group" --lb-name "$lb_name" --name tomcat --backend-pool-name green-bepool
   ```

1. Further test to ensure that the production endpoint works with green environment.

   ```bash
   echo "Visit http://$ip"
   ```

1. Now blue environment is the stage environment and we can prepare for the next deployment on blue.
