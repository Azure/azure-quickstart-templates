## To deployed Tabo on your own subscription follow this procedure.

1. Login to the Azure portal by navigating to https://portal.azure.com . Once logged in click on "resource groups" in the left hand tab on the screen and search for the resource group name you used when deploying Kalpa from our webpage. 
Here is the screenshot:

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image1"/>

2. Click on the Resource group that is displayed after you searched and you'll navigate to Kalpa deployment.
Here is the screenshot:

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image2"/>

3. Find the Stream Analytics job resource as follows: here below, As highlighted there will be only a single resource with type "Stream Analytics job", Click on it.
Here is the screenshot:

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image3"/>

4. After Clicking on the Stream Analytics job click on the "Outputs" section.
Here is the screenshot:

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image4"/>

5. Click on "Add" and then in Sink select "PowerBI" from the drop down and then in output alias provide the name "Salesout". Make sure to use the same output alias as it is linked with our deployment.
Here is the screenshot:

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image5"/>

6. Click on "Authorize" and use these credentials:
   **Email - Kalpa@dynaptsolutions.com**
   **Password - Dynapt@123**

7. Now Fill according to below table and click on create to create the output, After this click on Start on the Stream Analytics Job.

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image6"/>

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image7"/>

8. Click on the Azure SQL Datawarehouse Component in the Deployment resource group as below. 

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image8"/>

9. Copy the 'Server name' and keep it handy to be used when connecting this to Power BI Service.

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image9"/>

10. Connect to PowerBI Dashboard and Kalpa in action, navigate to https://powerbi.microsoft.com and click on "Sign In" and use these credentials: 
    **Email - Kalpa@dynaptsolutions.com**
    **Password - Dynapt@123**

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image10"/>

11. Once Inside logged in to PowerBI, Click on 'Get Data'.

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image11"/>

12. Click on Get in the Databases section.

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image12"/>

13. Click on Azure SQL Datawarehouse and click on Connect.

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/kalpa-hdinsight/Images/Image13"/>

Paste the "server name" we copied earlier in the Server field and type the value for Database name as "dadwdb", Click on Next and enter the Username as "azureuser" and Password as "Password@123".