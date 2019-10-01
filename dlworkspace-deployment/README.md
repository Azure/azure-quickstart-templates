# DLWorkspace deployment using ARM Template

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/dlworkspace-deployment/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/dlworkspace-deployment/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/dlworkspace-deployment/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/dlworkspace-deployment/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/dlworkspace-deployment/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/dlworkspace-deployment/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdlworkspace-deployment%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdlworkspace-deployment%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

## DLWorkspace Overview

Deep Learning Workspace (DLWorkspace) is an open source toolkit that allows AI scientists to spin up an AI cluster in turn-key fashion. This template will spin up a DLWorkspace cluster in Azure. Once setup, the DLWorkspace cluster in Azure provides web UI and/or restful API that allows AI scientist to run job (interactive exploration, training, inferencing, data analystics) on the cluster with resource allocated by DL Workspace cluster for each job (e.g., a single node job with a couple of GPUs with GPU Direct connection, or a distributed job with multiple GPUs per node). DLWorkspace also provides unified job template and operating environment that allows AI scientists to easily share their job and setting among themselves and with outside community. DLWorkspace out-of-box supports all major deep learning toolkits (TensorFlow, CNTK, Caffe, MxNet, etc..).

For more information about the DLWorkspace toolkit, visit https://github.com/Microsoft/DLWorkspace/tree/master

