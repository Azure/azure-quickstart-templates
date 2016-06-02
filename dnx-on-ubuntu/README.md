# DNX on Ubuntu 14.04

This template will install the cross platform .NET execution context (DNX) on an Ubuntu Server installation, which allows you to write .NET apps on Linux!

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdnx-on-ubuntu%2Fazuredeploy.json" target="_blank">
	<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Azure%2azure-quickstart-templates%2master%2dnx-on-ubuntu%2azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

After deploying the VM - SSH into the machine and do the following to see the DNX app in action:

```
cd sampleConsoleApp
dnx run
```

Open up nano to edit the samplecode `nano ~/sampleConsoleApp/main.cs` code - which has syntax highlighting for C# enabled.

```
dnu build --framework dnxcore50
dnx run
```