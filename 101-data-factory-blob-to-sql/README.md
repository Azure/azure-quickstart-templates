# Azure Data Factory Data Copy Activity

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnavalev%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-blob-2-sql%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates a very simple Data Factory pipeline that copies data from a file in a Blob Storage into a SQL Database table. Prior to  executing this make sure you have a Storage Account and a SQL Database provisioned. 

## Prerequisites:
1. Azure Storage
2. Source CSV file within a blob container 
3. Azure SQL Database
4. Target table in the database

Data Factory result diagram:
![alt tag](images/adfDiagram.PNG)
