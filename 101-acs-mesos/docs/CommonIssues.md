# Common Issues

## Index
Look through the following list to help you resolve any common issues:
 1. [MissingSubscriptionRegistration](#MissingSubscriptionRegistration) - this happens if you have never used the new portal to deploy a Compute VM before.

### MissingSubscriptionRegistration

If you get the following error:

	`MissingSubscriptionRegistration: The subscription is not registered to use namespace 'Microsoft.Network'.`
	 
	`MissingSubscriptionRegistration: The subscription is not registered to use namespace 'Microsoft.Storage'.`
	 
	`MissingSubscriptionRegistration: The subscription is not registered to use namespace 'Microsoft.Compute'.``

This means that the user has never used ARM before.

To mitigate, deploy [this template](https://github.com/anhowe/scratch/tree/master/exerciseStgNetCmp) to the same region as you deployed the ACS template.

This will take < 1 min to deploy and will force a registration for your subscription in each of the resource providers.  You will need to delete the resource group afterwards.
