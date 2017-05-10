@{
ModuleVersion = '1.0.0.0'
GUID = 'D051048D-7D07-4AA9-B5BC-30FDA9B47B98'
Author = 'Microsoft Corporation'
CompanyName = 'Microsoft Corporation'
Copyright = '(c) 2016 Microsoft Corporation.'
Description = 'Implements custom and modified resources that support creation of multiple SQL Server Always-On
Availability groups on the same clustered virtual machines in Azure for use by BizTalk Server.

This is an experimental module provided AS IS, and is not supported through any Microsoft standard
support program or service.'

# PS 5.0 is required so we can rely on PsDscRunAsCredential
PowerShellVersion = '5.0'
CLRVersion = '4.0'

FunctionsToExport = '*'
CmdletsToExport = '*'
}
