## Run the test
New-AzResourceGroupDeployment -ResourceGroupName testgrp1 -TemplateParameterFile .\azuredeploy.parameters.json -TemplateFile .\azuredeploy.json -Debug