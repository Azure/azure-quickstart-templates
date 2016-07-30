# Create Windows Virtual Machines with 2 NIC cards connecting to exisitng VNET Subnet's and VM to be stored in existing storage account

This template allows you create Windows virtual machines  with following configurations :
+ 2 NIC Card
+ In Existing Virtual Network Subnet's
+ In Existing Storage Account



## Special Notes

For successful deployment, pay particular attention to these special items:

+ Ensure Storage account , Virtual Network and Subnet's are already created and available in Subscription. Use exact same name while defining parameters during deployment
+ NIC 1 of VM will be associated with Public IP

## Template Parameters

Modify parameters file to change default values.