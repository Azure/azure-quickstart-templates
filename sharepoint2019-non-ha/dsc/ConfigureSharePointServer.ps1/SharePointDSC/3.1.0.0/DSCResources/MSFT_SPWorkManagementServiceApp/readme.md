# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to provision and manage an instance of the Work
Management Services Service Application. It will identify an instance of the
work management service application through the application display name.
Currently the resource will provision the app if it does not yet exist, and
will change the application pool associated to the app if it does not match
the configuration.

Remarks

- Parameters MinimumTimeBetweenEwsSyncSubscriptionSearches,
  MinimumTimeBetweenProviderRefreshes, MinimumTimeBetweenSearchQueries are in
  minutes.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the service application is provisioned.

NOTE:
You cannot use this resource with SharePoint 2016/2019, since the Work
Management functionality has been removed in SharePoint 2016/2019.
More information:
https://technet.microsoft.com/en-us/library/mt346112(v=office.16).aspx
