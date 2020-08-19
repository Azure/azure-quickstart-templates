# Send email with Logic app

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-logic-app-sendgrid/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-logic-app-sendgrid/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-logic-app-sendgrid/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-logic-app-sendgrid/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-logic-app-sendgrid/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-logic-app-sendgrid/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-logic-app-sendgrid%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-logic-app-sendgrid%2Fazuredeploy.json)

This template allows you to create a Logic app that sends an email. You can add an additional triggers or actions to customize it to your needs.  

After deployment you can open the outputs of the deployment, or open the Logic App that was deployed to get the URI you need to trigger this Logic App.  An HTTP POST to that URL will trigger the Logic App and expects the following format:

`HTTP POST`

`Content-Type: application/json`

Body:
```
{
  "from": "my@email.com",
  "to": "your@email.com",
  "subject": "Email Subject",
  "emailbody": "Hello world"
}
```


