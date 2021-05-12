# Deploy an Azure SignalR Service

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.signalrservice/signalr/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.signalrservice/signalr/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.signalrservice/signalr/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.signalrservice/signalr/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.signalrservice/signalr/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.signalrservice/signalr/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.signalrservice%2Fsignalr%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.signalrservice%2Fsignalr%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.signalrservice%2Fsignalr%2Fazuredeploy.json)

This template allows you to create an Azure SignalR Service. Azure SignalR Service is an Azure managed service that helps developers build web applications with real-time features. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/azure-signalr/signalr-quickstart-azure-signalr-service-arm-template) article.

## Good candidates for SignalR

- Apps that require high frequency updates from the server. Examples are gaming, social networks, voting, auction, maps, and GPS apps.
- Dashboards and monitoring apps. Examples include company dashboards, instant sales updates, or travel alerts.
- Collaborative apps. Whiteboard apps and team meeting software are examples of collaborative apps.
- Apps that require notifications. Social networks, email, chat, games, travel alerts, and many other apps use notifications.
- SignalR provides an API for creating server-to-client remote procedure calls (RPC). The RPCs call JavaScript functions on clients from server-side .NET Core code.

## Features of SignalR for ASP.NET Core

- Handles connection management automatically.
- Sends messages to all connected clients simultaneously. For example, a chat room.
- Sends messages to specific clients or groups of clients.
- Scales to handle increasing traffic.

## Notes

- [Introduction to ASP.NET Core SignalR](https://docs.microsoft.com/aspnet/core/signalr/introduction?view=aspnetcore-3.0)
- [Integrate Azure SignalR Service with ASP.NET Core Identity](https://docs.microsoft.com/azure/azure-signalr/signalr-authenticate-oauth)
- [Build a Serverless Real-time App with Authentication](https://docs.microsoft.com/azure/azure-signalr/signalr-tutorial-authenticate-azure-functions)
- For more details about SignalR, see [Azure SignalR Service documentation](https://docs.microsoft.com/azure/azure-signalr)

SignalR also enables completely new types of web applications that require high frequency updates from the server, for example, real-time gaming.

SignalR provides a simple API for creating server-to-client remote procedure calls (RPC) that call JavaScript functions in client browsers (and other client platforms) from server-side .NET code. SignalR also includes an API for connection management such as connect and disconnect events, and grouping connections. For more information, see the [Introduction to SignalR](https://docs.microsoft.com/aspnet/signalr/overview/getting-started/introduction-to-signalr).

To learn how to build Azure SignalR Service applications, see [Microsoft Learn SignalR modules](https://docs.microsoft.com/learn/modules/automatic-update-of-a-webapp-using-azure-functions-and-signalr/).
