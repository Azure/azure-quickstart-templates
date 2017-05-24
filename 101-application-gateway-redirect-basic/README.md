# Create Application Gateway with enabled Web Application Firewall

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-redirect-basic%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-redirect-basic%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys an Application Gateway with Basic Redirect functionality. It shows how http requests on port 80 can be redirected to https requests on port 443. Additionally, it also shows how to redirect requests (on port 81) to a fixed url/webpage. 

This functionality can be configured using a setting called RedirectConfiguration. A redirect config can then be associated with a listener in a basic rule.

Mandatory parameters for RedirectConfiguration:
1. targetListener: indicates http/s listener to redirect to OR targetUrl: indicates a particular url/webpage to redirect to
2. redirectType: supported http redirection types - Permanent, Temporary, Found, SeeOther

Optional parameters:
1. includePath: indicates whether to include incoming url’s path in the redirected url. Default = true.
2. includeQueryString: indicates whether to include incoming url's query string in the redirected url. Default = true.

Notes:
1. Supported apiVersion is "2017-04-01" and above
2. If the listener specified as targetListener contains Hostname setting, this would be used as hostname in the redirected url.
3. BackendAddressPool and BackendHttpSettings cannot be specified with a listener in a basic rule when RedirectConfiguration is specified.
4. Any to any port/protocol redirection is supported
