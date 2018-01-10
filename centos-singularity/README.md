# Deploying a CentOS HPC VM with Singularity

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbhummerstone%2Fazure-quickstart-templates%2Fcentos-singularity%2Fcentos-singularity%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fbhummerstone%2Fazure-quickstart-templates%2Fcentos-singularity%2Fcentos-singularity%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


This template allows you to deploy a CentOS HPC VM with Singularity installed. By default this uses CentOS HPC 7.3, Singularity 2.3.1 and an A8 VM, but you can change these by passing parameters.

Note that only the following VM SKUs are currently supported:
* Standard_A8
* Standard_A9
* Standard_H16r
* Standard_H16mr

Their availability varies by region, so please double-check before deploying. 