# Deploy a VM Scale Set based on a Linux Custom Image (by ID)

This template deploys a VM Scale Set from a user provided Linux Custom Image using the image ID.

The template allows to specify the ID of a custom Linux image previously provisioned. You don't need to copy the disk to any storage account, but just copy the ID of the captured image from the azure portal (from Image-Properties blade):

```bash
"/subscriptions/OOOOOO-WWWWW-ZZZZZ-YYYY-XXXXXXX/resourceGroups/testvm/providers/Microsoft.Compute/images/testvm-image-YYYYYYY"
```

To create a custom Linux image you should first create a Linux VM in Azure, install everything you need and then generalize the image running the command

```bash
sudo waagent -deprovision+user
```

In addition to the VM Scale Set the template creates a public IP address and load balances HTTP traffic on port 80 to each VM. 
A simple autoscale rule based on CPU consumption is also created.
