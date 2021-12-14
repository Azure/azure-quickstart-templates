# Required prerequisites

Before testing this quickstart template, you must create a Windows machine
(virtual or physical) outside of Azure and install the Arc agent
to project it into Azure.

The simplest approach to building this prereq is to follow the docs page
for Azure Arc-enabled servers.

[Enable Arc-enabled servers agent](https://docs.microsoft.com/en-us/azure/azure-arc/servers/learn/quick-enable-hybrid-vm)

After you have an Arc-enabled machine ready, you can deploy this sample
in to the same resource group and use the "machineName" parameter to specify
the machine where the configuration will be applied.