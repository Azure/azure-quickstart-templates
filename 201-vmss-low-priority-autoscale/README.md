### Autoscale a Low-priority VM Scale Set ###

The following template deploys a Low-priority VM Scale Set integrated with Azure autoscale.

The template deploys a low-priority VMSS with a desired count of VMs in the scale set. The scale set uses a Standard load balancer with multiple placement groups. When eviction occurs, the VMs will be deleted.

The Autoscale rules are configured as follows
- Based on Instance Count
    - When the low-priority VMs become evicted, auto-scale will try to deploy new instances to hit the target instance count. 
- Based on CPU Performance
    - sample for CPU (\\Processor\\PercentProcessorTime) in each VM every 1 Minute
    - if the Percent Processor Time is greater than 50% for 5 Minutes, then the scale out action (add more VM instances, one at a time) is triggered
    - once the scale out action is completed, the cool down period is 1 Minute


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-low-priority-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-low-priority-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>