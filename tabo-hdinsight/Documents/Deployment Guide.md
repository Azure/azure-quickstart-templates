## To deployed Tabo on your own subscription follow this procedure.
1. Login to the Azure portal by navigating to https://portal.Azure.com . Once logged in click on "resource groups" in the left hand tab on the screen and search for the resource group name you used. 
   Here is the screenshot:

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/HD-Insight/Images/Image1.png"/>

2. Click on the Resource group that is displayed after you searched and you'll navigate to Tabo deployment.
   Here is the screenshot: 
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/HD-Insight/Images/Image2.png"/>

3. Find the Stream Analytics job resource as follows: here below, as highlighted there will be only a single resource with type "Stream Analytics job", Click on it 
   Here is the screenshot:
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/HD-Insight/Images/Image3.png"/>

4. After Clicking on the Stream Analytics job click on the 'Outputs' section
   Here is the screenshot:
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/HD-Insight/Images/Image4.png"/>

5. Click on "Add" and add an output of PowerBI type and output alias "iotout". Make sure to use the same output alias as it is linked with our deployment.
   Here is the screenshot:

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/HD-Insight/Images/Image5.png"/>

6. Click on 'Authorize' and use these credentials:
   **Email - tabo@dynaptsolutions.com**
   **Password - Dynapt@123**

7. Add "Dataset Name" as "iotdata" and "Table Name" as "iottable" in the fields provided as below 
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/HD-Insight/Images/Image6.png"/>	

8. To view the PowerBI Dashboard and Tabo in action, navigate to https://powerbi.microsoft.com and click on 'Sign In' and use these credentials: 
   **Email - tabo@dynaptsolutions.com**
   **Password - Dynapt@123**
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/HD-Insight/Images/Image7.png"/>	
