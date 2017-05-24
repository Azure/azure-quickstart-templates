# Create Application Gateway with enabled Web Application Firewall

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-redirect-pathbased%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-redirect-pathbased%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys an Application Gateway with Path based Redirect functionality. It shows how a redirect config can be associated with a Pathrule in UrlPathMap such that only requests containing that path are redirected.

Mandatory parameters for RedirectConfiguration:
1. targetListener: indicates http/s listener to redirect to OR targetUrl: indicates a particular url/webpage to redirect to
2. redirectType: supported http redirection types - Permanent, Temporary, Found, SeeOther

Optional parameters:
1. includePath: indicates whether to include incoming url’s path in the redirected url. Default = true.
2. includeQueryString: indicates whether to include incoming url's query string in the redirected url. Default = true.

Notes:
1. Supported apiVersion is "2017-04-01" and above
2. If the listener specified as targetListener contains Hostname setting, this would be used as hostname in the redirected url.
3. BackendAddressPool and BackendHttpSettings cannot be specified with a listener in a pathrule when RedirectConfiguration is specified.
4. DefaultRedirectConfiguration can be specified for a UrlPathMap. In that case, DefaultBackendAddressPool and DefaultBackendHttpSettings cannot be specified for that path map.
5. Any to any port/protocol redirection is supported
