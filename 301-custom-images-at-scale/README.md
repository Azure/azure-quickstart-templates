# Custom Images at Scale

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-custom-images-at-scale%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-custom-images-at-scale%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys custom images at scale with options to use VM Scale Sets, regular VMs, or regular VMs in an availability set.  It is designed so that it can be called from other templates, and you can build on top of it.  The individual VMs that get created do not have public IPs, but a machine that can be used as a jump box is available.  (You can delete the extra machine after deployment, but it is required as part of the process.)

In terms of workflow, this template does the following:
- Create a deployment that produces the shared objects which will be used in the other pieces.  This includes the VNet, and the storage accounts for the final VMs to be deployed. (shared-resources.json)
- Create the objects necessary for a VM to use in moving the image around, which can also function as a jump box.
- Create a deployment that runs the download script to get the image onto the VM. (download.json, download.sh)
- Create a loop of deployments (that run in series, not parallel) which run the upload script to push the image into each of the created storage accounts. (upload.json, upload.sh)
- Start the final VM deployments.

For the final VM deployments, the intial option you pass the template determines which design it will use for the final VMs.
- VMSS - This will create the VMs as a series of VM scale sets.  (final_VMSS.json)
- Single - This will create the VMs as a series of individual VMs.  You can further customize them in the template if needed.  (final_Single.json, vm_baseSingle.json)
- SingleAV - This will create the VMs as a series of individual VMs that are all within an availability set.  You cannot exceed 100 total VMs if using this method.  (final_SingleAV.json, vm_baseSingleAV.json)
