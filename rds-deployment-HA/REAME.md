# Provide High Availability to RDG and RDWA Server on top of Remote Desktop Sesson Collection deployment

This template deploys the following resources:

<ul><li>a number of RD Gateway/RD Web Access vm (number defined by 'numberOfWebGwInstances' parameter)</li></ul>

The template will join all new vms to the domain.
Deploy RDS roles in the deployment.
Join new VM's to the exisitng web and Gateway farm of basic RDS deplyment.
Post configurations for web/Gateway VM's such as defining the Machine keys for IIS modules.