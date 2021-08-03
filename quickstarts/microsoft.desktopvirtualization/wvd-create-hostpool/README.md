# TODO: clean up readme

---
page_type: resources
languages:
  - md
  - json
  - bicep
description: |
  Bicep port of commonly used ARM templates to deploy WVD backplane located here: https://github.com/Azure/RDS-Templates/tree/master/ARM-wvd-templates/CreateAndProvisionHostPool
products:
  - azure
  - windows-virtual-desktop
---

# Bicep Template to Create and provision new Windows Virtual Desktop hostpool

This is a Bicep port of commonly used ARM templates to deploy WVD backplane located here: <https://github.com/Azure/RDS-Templates/tree/master/ARM-wvd-templates/CreateAndProvisionHostPool>

This template creates virtual machines and registers them as session hosts to a new or existing Windows Virtual Desktop host pool. There are multiple sets of parameters you must enter to successfully deploy the template:

- VM image
- VM configuration
- Domain and network properties

TODO: Clean up README
