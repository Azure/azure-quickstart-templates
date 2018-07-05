# eCommerce website

The e-commerce website includes simple order processing workflows with the help of Azure services. Leveraging Functions and Web App, developers can focus on building personalized experience and let Azure take care of the infrastructure plumbing required for a performant and resilient experience.

## Deploy Components to Azure ##

1. Click the **Deploy to Azure** button.

   <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-ecommerce-solution%2Fazuredeploy.json" target="_blank">
     <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
   </a>

   <a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-ecommerce-solution%2Fazuredeploy.json" target="_blank">
     <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
   </a>

2. Fill in the deployment settings.

   - **Resource group**: Recommended to create a new group.

   - **Name Prefix**: Provide the prefix name for all resources.

   - **Administrator Login**: Provide the admin login name for the database.

   - **Administrator Login Password**: Provide the admin login password for the database, it must meet the complexity requirements, e.g. `Jan232@18`

   - **Repository URL**: Provide the repository URL of this repo or your own fork.

   - **Branch**: Leave it as `master`.

   - Check **I agree to the terms and conditions stated above**.

3. Click **Purchase**.

> **Note:** The static files (JS/CSS) hosted on CDN might not take effect immediately, so you might see the page layout of the newly created website is messing up until hours later.


## How to Use the eCommerce Website ##

1. Open the website in browser.

2. Sign in with this default credential.

   User Name                | Password
   ------------------------ | ---------
   demouser@microsoft.com   | Pass@word1

3. Use the BRAND/TYPE dropdowns to filter the products.

   ![](images/web-filter.jpg)

4. Choose a product and click "ADD TO BASKET".
5. Modify the "Quality" if need and click "CHECKOUT".
6. Click "My orders" on the top right of the page.
7. You would see the order status is "Pending".

   ![](images/web-order-pending.jpg)

8. Once you refresh the page around 1 min later, the status would be changed to "Paid" automatically (pretend third-party payment).

   ![](images/web-order-paid.jpg)
