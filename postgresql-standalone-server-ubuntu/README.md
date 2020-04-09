# PostgreSQL Server on Ubuntu VM

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/postgresql-standalone-server-ubuntu/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/postgresql-standalone-server-ubuntu/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/postgresql-standalone-server-ubuntu/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/postgresql-standalone-server-ubuntu/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/postgresql-standalone-server-ubuntu/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/postgresql-standalone-server-ubuntu/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpostgresql-standalone-server-ubuntu%2Fazuredeploy.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/></a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpostgresql-standalone-server-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
</a>

This template uses the Azure Linux CustomScript extension to deploy a PostgreSQL server. It creates an Ubuntu VM, does a silent install of PostgreSQL server, version:9.3.5, and the basic configuration is below: port is 1999, data directory is /opt/pgsql_data, installation directory is /opt/pgsql, user is postgres.

## Setting up and testing PostgreSQL Database 

For security reasons, PostgreSQL uses a non-root user to initialize, start, or shut down the database. Here it uses postgres as the user.

You can verify the deployment by connecting to the Postgres database:

$sudo su - postgres

### Create a Postgres database:

$createdb events

Connect to the events database that you just created:

$psql -d events

### Create a new example Postgres table 

By using the following command:

CREATE TABLE potluck (name VARCHAR(20), food VARCHAR(30),   confirmed CHAR(1), signup_date DATE);

### Add data to a table:

INSERT INTO potluck (name, food, confirmed, signup_date) VALUES('John', 'Casserole', 'Y', '2012-04-11');

### Exit the database:

\q

## Resources 

[To learn more about PostgreSQL, visit the PostgreSQL website](http://www.postgresql.org/)

[Microsoft Learn Modules on PostgreSQL](https://docs.microsoft.com/en-us/learn/browse/?term=postgresql)

[Microsoft Learn Modules on Linux Virtual Machine](https://docs.microsoft.com/en-us/learn/browse/?term=Virtual%20Machine)