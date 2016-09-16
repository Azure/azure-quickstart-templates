# Send email with Logic app

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-logic-app-sendgrid%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-logic-app-sendgrid%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

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