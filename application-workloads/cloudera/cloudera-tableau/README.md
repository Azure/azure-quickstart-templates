# Refer to install instructions Cloudera + Tableau Quickstart Deployment and Usage Guide.pdf located in the root folder

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cloudera/cloudera-tableau/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cloudera/cloudera-tableau/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cloudera/cloudera-tableau/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cloudera/cloudera-tableau/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cloudera/cloudera-tableau/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/cloudera/cloudera-tableau/CredScanResult.svg)

Deploy a Cloudera Express cluster with the option to unlock Cloudera Enterprise features for a free 60-day trial  
Will also deploy the latest Bring Your Own License version of Tableau  
Important!  You must increase the default 20 cores in the region you are deploying  
Once the trial has concluded, the Cloudera Enterprise features will be disabled until you obtain and upload a license.  

By clicking "Deploy to Azure" you agree to the Terms and Conditions below.  
Deployment to Azure (use this if you are not sure)  

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcloudera%2Fcloudera-tableau%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcloudera%2Fcloudera-tableau%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fcloudera%2Fcloudera-tableau%2Fazuredeploy.json) 

# Readme
This template creates a multi-server Cloudera CDH 5.4.x Apache Hadoop deployment on CentOS virtual machines, and configures the CDH installation for either POC or high availability production cluster.

The template also provisions storage accounts, virtual network, availability set, network interfaces, VMs, disks and other infrastructure and runtime resources required by the installation.

The template expects the following parameters:

| Name   | Description | Default Value |
|:--- |:---|:---|
| adminUsername  | Administrator user name used when provisioning virtual machines | testuser |
| adminPassword  | Administrator password used when provisioning virtual machines | Eur32#1e |
| cmUsername | Cloudera Manager username | cmadmin |
| cmPassword | Cloudera Manager password | cmpassword |
| storageAccountPrefix | Unique namespace for the Storage Account where the Virtual Machine's disks will be placed | defaultStorageAccountPrefix |
| numberOfDataNodes | Number of data nodes to provision in the cluster | 3 |
| dnsNamePrefix | Unique public dns name where the Virtual Machines will be exposed | defaultDnsNamePrefix |
| region | Azure data center location where resources will be provisioned |  |
| masterStorageAccountType | The type of the Storage Account to be created for master nodes | Premium_LRS |
| workerStorageAccountType | The type of the Storage Account to be created for worker nodes | Standard_LRS |
| virtualNetworkName | The name of the virtual network provisioned for the deployment | clouderaVnet |
| subnetName | Subnet name for the virtual network where resources will be provisioned | clouderaSubnet |
| subnet1Name | Subnet name for the virtual network where resources will be provisioned | tableauSubnet |
| tshirtSize | T-shirt size of the Cloudera cluster (Eval, Prod) | Eval |
| vmSize | The size of the VMs deployed in the cluster (Defaults to Standard_DS14) | Standard_DS14 |

Topology
--------

The deployment topology is comprised of a predefined number (as per t-shirt sizing) Cloudera member nodes configured as a cluster, configured using a set number of manager,
name and data nodes. Typical setup for Cloudera uses 3 master nodes with as many data nodes are needed for the size that has been chosen ranging from as
few as 3 to thousands of data nodes.  The current template will scale at the highest end to 200 data nodes when using the large t-shirt size.

The following table outlines the deployment topology characteristics for each supported t-shirt size:

| T-Shirt Size | Member Node VM Size | CPU Cores | Memory | Data Disks | # of Master Node VMs | Services Placement of Master Node |
|:--- |:---|:---|:---|:---|:---|:---|:---|
| Eval | Standard_DS14 | 16 | 112 GB | 10x1000 GB | 1 | 1 (primary, secondary, cloudera manager) |
| Prod | Standard_DS14 | 10 | 112 GB | 10x1000 GB | 3 | 1 primary, 1 standby (HA), 1 cloudera manager |

##Connecting to the cluster
The machines are named according to a specific pattern.  The master node is named based on parameters and using the.

	[dnsNamePrefix]-mn0.[region].cloudapp.azure.com

If the dnsNamePrefix was clouderatest in the West US region, the machine will be located at:

	clouderatest-mn0.westus.cloudapp.azure.com

The rest of the master nodes and data nodes of the cluster use the same pattern, with -mn and -dn extensions followed by their number.  For example:

    clouderatest-mn0.westus.cloudapp.azure.com
	clouderatest-mn1.westus.cloudapp.azure.com
	clouderatest-mn2.westus.cloudapp.azure.com
	clouderatest-dn0.westus.cloudapp.azure.com
	clouderatest-dn1.westus.cloudapp.azure.com
	clouderatest-dn2.westus.cloudapp.azure.com

To connect to the master node via SSH, use the username and password used for deployment

	ssh testuser@[dnsNamePrefix]-mn0.[region].cloudapp.azure.com

Once the deployment is complete, you can navigate to the Cloudera portal to watch the operation and track its status. Be aware that the portal dashboard will report alerts since the services are still being installed.

	http://[dnsNamePrefix]-mn0.[region].cloudapp.azure.com:7180

##Loading sample data and viewing it with a Tableau dashboard (optional)
- Sample data can be loaded into Cloudera Impala and viewed via a Tableau dashboard.
- The following steps can only be executed after all Cloudera and Tableau servers have deployed successfully. 

To generate and load the sample data, connect to the "-mn0" Cloudera master node (referenced above) using PuTTY or another SSH client tool.  Execute the following commands via the command line:

- sudo su - hdfs
- wget https://clouderatableau.blob.core.windows.net/datagen/datagen.tar.gz
- tar -zxf datagen.tar.gz
- cd datagen
- sh datagen.sh 2

Next, connect to the "-dn0" Cloudera worker node (referenced above) using PuTTY or another SSH client tool.  Execute the following commands via the command line:

- sudo su - hdfs
- wget https://clouderatableau.blob.core.windows.net/datagen/datagen.tar.gz
- tar -zxf datagen.tar.gz
- cd datagen
- sh load_data.sh

The sample data should now be accessible in Hadoop Hive (tpch_text_2 database) and Cloudera Impala (tpch_parquet database).

Next, using the Microsoft Azure portal, remote into the Tableau server using the "Connect" button for the Tableau Virtual Machine (VM).  This will establish an RDP session into the Tableau Windows Server.  Follow the registration process and enter the appropriate Tableau license key.  This step must be completed before the dashboard can be deployed.

To complete the process of viewing the Cloudera Impala sample data with a Tableau dashboard, install the Cloudera Impala driver for Windows on the Tableau server:

- Navigate to http://www.cloudera.com/downloads/connectors/impala/odbc.html and select the Windows 64-bit driver.  Follow the registration process and download the driver.
- Copy the driver file to the Tableau server and double-click on it to install.
- Download the sample Tableau dashboard from: https://github.com/jreid143/ClouderaTableau/blob/master/ClouderaTableau/tableau/Cloudera%20Widget%20Dashboard.twbx
- Using Tableau Desktop, deploy the "Cloudera Widget Dashboard.twbx" file to the Tableau Server "Tableau Samples" project.
- Click on the "Cloudera Widget Dashboard" under the "Tableau Samples" project to view the Cloudera Impala sample data.

##Notes, Known Issues & Limitations
- All nodes in the cluster have a public IP address.
- The deployment script is not yet idempotent and cannot handle updates (although it currently works for initial provisioning only)
- SSH key is not yet implemented and the template currently takes a password for the admin user

Version 2016-12-26

END USER LICENSE TERMS AND CONDITIONS

THESE TERMS AND CONDITIONS (THESE “TERMS”) APPLY TO YOUR USE OF THE PRODUCTS (AS DEFINED BELOW) PROVIDED BY CLOUDERA, INC. (“CLOUDERA”).

PLEASE READ THESE TERMS CAREFULLY.

IF YOU (“YOU” OR “CUSTOMER”) PLAN TO USE ANY OF THE PRODUCTS ON BEHALF OF A COMPANY OR OTHER ENTITY, YOU REPRESENT THAT YOU ARE THE EMPLOYEE OR AGENT OF SUCH COMPANY (OR OTHER ENTITY) AND YOU HAVE THE AUTHORITY TO ACCEPT ALL OF THE TERMS AND CONDITIONS SET FORTH IN AN ACCEPTED REQUEST (AS DEFINED BELOW) AND THESE TERMS (COLLECTIVELY, THE “AGREEMENT”) ON BEHALF OF SUCH COMPANY (OR OTHER ENTITY).

BY USING ANY OF THE PRODUCTS, YOU ACKNOWLEDGE AND AGREE THAT:
(A) YOU HAVE READ ALL OF THE TERMS AND CONDITIONS OF THIS AGREEMENT;
(B) YOU UNDERSTAND ALL OF THE TERMS AND CONDITIONS OF THIS AGREEMENT;
(C) YOU AGREE TO BE LEGALLY BOUND BY ALL OF THE TERMS AND CONDITIONS SET FORTH IN THIS AGREEMENT

IF YOU DO NOT AGREE WITH ANY OF THE TERMS OR CONDITIONS OF THESE TERMS, YOU MAY NOT USE ANY PORTION OF THE PRODUCTS.

THE “EFFECTIVE DATE” OF THIS AGREEMENT IS THE DATE YOU FIRST DOWNLOAD ANY OF THE PRODUCTS.

1. Product. For the purpose of this Agreement, “Product” shall mean any of Cloudera’s products and software including but not limited to: Cloudera Manager, Cloudera Enterprise, Cloudera Live, Cloudera Express, Cloudera Director, any cloud-based service, any trial software, and any software related to the foregoing.

2. Entire Agreement. This Agreement includes these Terms, any exhibits or web links attached to or referenced in these Terms and any terms set forth on the Cloudera web site at http://www.cloudera.com/documentation/other/Licenses/Third-Party-Licenses/Third-Party-Licenses.html. The content referenced by the exhibits or web links attached to or referenced in these Terms, and the content on the Cloudera website at http://www.cloudera.com/documentation/other/Licenses/Third-Party-Licenses/Third-Party-Licenses.html are hereby incorporated by reference into this Agreement in their entirety as they appear on the Effective Date of this Agreement, and as may be updated by Cloudera in its sole discretion from time to time.. This Agreement is the entire agreement of the parties regarding the subject matter hereof, superseding all other agreements between them, whether oral or written, regarding the subject matter hereof.

3. License Delivery. Cloudera grants to Customer a nonexclusive, nontransferable, nonsublicensable, revocable and limited license to access and use the applicable Product as defined above in Section 1 solely for Customer’s internal purposes. The Product is delivered via electronic download or online access made available following Customer’s acceptance of this Agreement.

4. License Restrictions. Unless expressly otherwise set forth in this Agreement, Customer will not:

    (a) modify, translate or create derivative works of the Product;
    (b) decompile, reverse engineer or reverse assemble any portion of the Product or attempt to discover any source code or underlying ideas or algorithms of the Product;
    (c) sell, assign, sublicense, rent, lease, loan, provide, distribute or otherwise transfer all or any portion of the Product;
    (d) make, have made, reproduce or copy the Product; (e) remove or alter any trademark, logo, copyright or other proprietary notices associated with the Product; and
    (f) cause or permit any other party to do any of the foregoing.

5. Ownership. As between Cloudera and Customer and subject to the grants under this Agreement, Cloudera owns all right, title and interest in and to: (a) the Product (including, but not limited to, any modifications thereto or derivative works thereof); (b) all ideas, inventions, discoveries, improvements, information, creative works and any other works discovered, prepared or developed by Cloudera in the course of or resulting from the provision of any services under this Agreement; and (c) any and all Intellectual Property Rights embodied in the foregoing. For the purpose of this Agreement, “Intellectual Property Rights” means any and all patents, copyrights, moral rights, trademarks, trade secrets and any other form of intellectual property rights recognized in any jurisdiction, including applications and registrations for any of the foregoing. As between the parties and subject to the terms and conditions of this Agreement, Customer owns all right, title and interest in and to the data generated by the use of the Products by Customer. There are no implied licenses in this Agreement, and Cloudera reserves all rights not expressly granted under this Agreement. No licenses are granted by Cloudera to Customer under this Agreement, whether by implication, estoppels or otherwise, except as expressly set forth in this Agreement.

6. Nondisclosure. “Confidential Information” means all information disclosed (whether in oral, written, or other tangible or intangible form) by Cloudera to Customer concerning or related to this Agreement or Cloudera (whether before, on or after the Effective Date) which Customer knows or should know, given the facts and circumstances surrounding the disclosure of the information by Customer, is confidential information of Cloudera. Confidential Information includes, but is not limited to, the components of the business plans, the Products, inventions, design plans, financial plans, computer programs, know-how, customer information, strategies and other similar information. Customer will, during the term of this Agreement and thereafter, maintain in confidence the Confidential Information and will not use such Confidential Information except as expressly permitted herein. Customer will use the same degree of care in protecting the Confidential Information as Customer uses to protect its own confidential information from unauthorized use or disclosure, but in no event less than reasonable care. Confidential Information will be used by Customer solely for the purpose of carrying out Customer’s obligations under this Agreement. In addition, Customer: (a) will not reproduce Confidential Information, in any form, except as required to accomplish Customer’s obligations under this Agreement; and (b) will only disclose Confidential Information to its employees and consultants who have a need to know such Confidential Information in order to perform their duties under this Agreement and if such employees and consultants have executed a non-disclosure agreement with Customer with terms no less restrictive than the non-disclosure obligations contained in this Section. Confidential Information will not include information that: (i) is in or enters the public domain without breach of this Agreement through no fault of Customer; (ii) Customer can reasonably demonstrate was in its possession prior to first receiving it from Cloudera; (iii) Customer can demonstrate was developed by Customer independently and without use of or reference to the Confidential Information; or (iv) Customer receives from a third-party without restriction on disclosure and without breach of a nondisclosure obligation. Notwithstanding any terms to the contrary in this Agreement, any suggestions, comments or other feedback provided by Customer to Cloudera with respect to the Products (collectively, “Feedback”) will constitute Confidential Information. Further, Cloudera will be free to use, disclose, reproduce, license and otherwise distribute, and exploit the Feedback provided to it as it sees fit, entirely without obligation or restriction of any kind on account of Intellectual Property Rights or otherwise.  Subject to applicable law, in connection with the performance of this Agreement and Customer’s use of the Cloudera Products, (i) Cloudera agrees that it will not require Customer to deliver to Cloudera any personally identifiable information (as defined by the National Institute of Standards and Technology) (“PII”) and (ii) Customer agrees not to deliver any PII to Cloudera.

7. Warranty Disclaimer. Customer represents warrants and covenants that: (a) all of its employees and consultants will abide by the terms of this Agreement; (b) it will comply with all applicable laws, regulations, rules, orders and other requirements, now or hereafter in effect, of any applicable governmental authority, in its performance of this Agreement. Notwithstanding any terms to the contrary in this Agreement, Customer will remain responsible for acts or omissions of all employees or consultants of Customer to the same extent as if such acts or omissions were undertaken by Customer. THE PRODUCTS ARE PROVIDED ON AN “AS IS” OR “AS AVAILABLE” BASIS WITHOUT ANY REPRESENTATIONS, WARRANTIES, COVENANTS OR CONDITIONS OF ANY KIND. CLOUDERA AND ITS SUPPLIERS DO NOT WARRANT THAT ANY OF THE PRODUCTS WILL BE FREE FROM ALL BUGS, ERRORS, OR OMISSIONS. CLOUDERA AND ITS SUPPLIERS DISCLAIM ANY AND ALL OTHER WARRANTIES AND REPRESENTATIONS (EXPRESS OR IMPLIED, ORAL OR WRITTEN) WITH RESPECT TO THE PRODUCTS WHETHER ALLEGED TO ARISE BY OPERATION OF LAW, BY REASON OF CUSTOM OR USAGE IN THE TRADE, BY COURSE OF DEALING OR OTHERWISE, INCLUDING ANY AND ALL (I) WARRANTIES OF MERCHANTABILITY, (II) WARRANTIES OF FITNESS OR SUITABILITY FOR ANY PURPOSE (WHETHER OR NOT CLOUDERA KNOWS, HAS REASON TO KNOW, HAS BEEN ADVISED, OR IS OTHERWISE AWARE OF ANY SUCH PURPOSE), AND (III) WARRANTIES OF NONINFRINGEMENT OR CONDITION OF TITLE. CUSTOMER ACKNOWLEDGES AND AGREES THAT CUSTOMER HAS RELIED ON NO WARRANTIES.

8. Indemnification. Customer will indemnify, defend and hold Cloudera and its directors, officers, employees, suppliers, consultants, contractors, and agents (“Cloudera Indemnitees”) harmless from and against any and all actual or threatened suits, actions, proceedings (at law or in equity), claims (groundless or otherwise), damages, payments, deficiencies, fines, judgments, settlements, liabilities, losses, costs and expenses (including, but not limited to, reasonable attorney fees, costs, penalties, interest and disbursements) resulting from any claim (including third-party claims), suit, action, or proceeding against any Cloudera Indemnitees, whether successful or not, caused by, arising out of, resulting from, attributable to or in any way incidental to:
(a) any breach of this Agreement (including, but not limited to, any breach of any of Customer’s representations, warranties or covenants);
(b) the negligence or willful misconduct of Customer; or
(c) the data and information used in connection with or generated by the use of the Products.

9. Limitation of Liability. EXCEPT FOR ANY ACTS OF FRAUD, GROSS NEGLIGENCE OR WILLFUL MISCONDUCT, IN NO EVENT WILL: (A) CLOUDERA BE LIABLE TO CUSTOMER OR ANY THIRD-PARTY FOR ANY LOSS OF PROFITS, LOSS OF DATA, LOSS OF USE, LOSS OF REVENUE, LOSS OF GOODWILL, ANY INTERRUPTION OF BUSINESS, ANY OTHER COMMERCIAL DAMAGES OR LOSSES, OR FOR ANY INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY, PUNITIVE OR CONSEQUENTIAL DAMAGES OF ANY KIND ARISING OUT OF OR IN CONNECTION WITH THIS AGREEMENT OR THE PRODUCTS (INCLUDING RELATED TO YOUR USE OR INABILITY TO USE THE PRODUCTS), REGARDLESS OF THE FORM OF ACTION, WHETHER IN CONTRACT, TORT, STRICT LIABILITY OR OTHERWISE, EVEN IF CLOUDERA HAS BEEN ADVISED OR IS OTHERWISE AWARE OF THE POSSIBILITY OF SUCH DAMAGES; AND (B) CLOUDERA’S TOTAL LIABILITY ARISING OUT OF OR RELATED TO THIS AGREEMENT EXCEED THE GREATER OF THE AGGREGATE OF THE AMOUNTS PAID OR PAYABLE TO CLOUDERA, IF ANY, UNDER THIS AGREEMENT OR FIVE U.S. DOLLARS. MULTIPLE CLAIMS WILL NOT EXPAND THIS LIMITATION. THE FOREGOING LIMITATIONS, EXCLUSIONS AND DISCLAIMERS SHALL APPLY TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, EVEN IF ANY REMEDY FAILS ITS ESSENTIAL PURPOSE.

10. Third-Party Suppliers. The Product may include software or other code distributed subject to licenses from third-party suppliers (“Third Party Software”). Customer accepts and agrees to the terms of such third-party licenses applicable to the Third Party Software and acknowledges that such third-party suppliers disclaim and make no representation or warranty with respect to the Products or any portion thereof and assume no liability for any claim that may arise with respect to the Products or Customer’s use or inability to use the same. Third Party Software licenses are set forth at this link :http://www.cloudera.com/content/cloudera/en/documentation/Licenses/Third-Party-Licenses/Third-Party-Licenses.html

11. Transaction Data.  Cloudera will maintain commercially reasonable administrative, physical and technical safeguards designed for the protection, confidentiality and integrity of all Transaction Data (as defined below).  All Transaction Data will be handled in accordance with the provisions set forth in the Data Policy found on Cloudera’s website (the “Data Policy”), and Customer agrees to be bound by and comply with the Data Policy.  Transaction Data shall not be considered “Confidential Information” as defined in these Terms, and instead shall be governed by the confidentiality and non-use provisions set forth in the Data Policy.   As between Cloudera and Customer, Customer or its licensors own all right, title, and interest in and to the Transaction Data.  Cloudera obtains no ownership rights under this Agreement from Customer or its licensors to any Transaction Data, including any related Intellectual Property Rights.  In order for Cloudera to provide the Cloudera Online Services, Customer grants to Cloudera certain rights with respect to the Transaction Data, including but not limited to the right to: (i) transmit, store and copy the Transaction Data in order to display the Transaction Data to Customer and its End Users; and (ii) make backups of the Transaction Data in order to prevent data loss.  Customer grants Cloudera the rights to use the Transaction Data as set forth in the Data Policy.  “Transaction Data” means all data that is (i) input into the Products by Customer or any end user, (ii) generated by Cloudera’s systems as a result of Customer’s or its end users’ use of the Products, or (iii) data that is generated for troubleshooting and diagnostics, in each case that is transmitted to Cloudera.  Transaction Data does not include Customer Data.

12. Google Analytics. To improve the product and gather feedback pro-actively from users, Google Analytics will be enabled by default in the product. Users have the option to disable this feature via the ‘Administration -> Properties’ settings in the product. Link to Google Analytics Terms of Service:http://www.google.com/analytics/terms/us.html

13. Diagnostics and Reporting. Customer acknowledges that the product contains a diagnostic functionality as its default configuration. The diagnostic function collects configuration files, node count, software versions, log files and other information regarding Customer’s environment and use of the Products, and reports that information to Cloudera for use to proactively identify potential support issues, to understand Customer’s environment, and to enhance the usability of the Products. While Customer may elect to change the diagnostic function in order to disable regular automatic reporting or to report only on filing of a support ticket, Customer agrees that, no less than once per quarter, it will run the diagnostic function and report the results to Cloudera.

14. Termination. The term of this Agreement commences on the Effective Date and continues for the period stated on Cloudera’s web site, unless terminated for Customer’s breach of any material term herein. Notwithstanding any terms to the contrary in this Agreement, in the event of a breach of Sections 3, 4 or 6, Cloudera may immediately terminate this Agreement. Upon expiration or termination of this Agreement: (a) all rights granted to Customer under this Agreement will immediately cease; and (b) Customer will promptly provide Cloudera with all Confidential Information (including, but not limited to the Products) then in its possession or destroy all copies of such Confidential Information, at Cloudera’s sole discretion and direction. Notwithstanding any terms to the contrary in this Agreement, this sentence and the following Sections will survive any termination or expiration of this Agreement: 4, 6, 7, 8, 9, 10, 13, 15, and 16.

15. Beta Software. In the event that Customer uses the functionality in the Product for the purposes of downloading and installing any Cloudera-provided public beta software, such beta software will be subject either to the Apache 2 license, or to the terms and conditions of the Public Beta License located here: (http://www.cloudera.com/content/www/en-us/legal/terms-and-conditions/ClouderaBetaLicense.html) as applicable.

16. Third Party Resources.  Cloudera Products may include hyperlinks to other web sites or content or resources (“Third Party Resources”), and the functionality of such Cloudera Products may depend upon the availability of such Third Party Resources. Cloudera has no control over any Third Party Resources. You acknowledge and agree that Cloudera is not responsible for the availability of any such Third Party Resources, and does not endorse any advertising, products or other materials on or available from such Third Party Resources. You acknowledge and agree that Cloudera is not liable for any loss or damage which may be incurred by you as a result of the availability of Third Party Resources, or as a result of any reliance placed by you on the completeness, accuracy or existence of any advertising, products or other materials on, or available from, such Third Party Resources.

17.  Miscellaneous. This Agreement will be governed by and construed in accordance with the laws of the State of California applicable to agreements made and to be entirely performed within the State of California, without resort to its conflict of law provisions. The parties agree that any action at law or in equity arising out of or relating to this Agreement will be filed only in the state and federal courts located in Santa Clara County, and the parties hereby irrevocably and unconditionally consent and submit to the exclusive jurisdiction of such courts over any suit, action or proceeding arising out of this Agreement. Upon such determination that any provision is invalid, illegal, or incapable of being enforced, the parties will negotiate in good faith to modify this Agreement so as to effect the original intent of the parties as closely as possible in an acceptable manner to the end that the transactions contemplated hereby are fulfilled. Except for payments due under this Agreement, neither party will be responsible for any failure to perform or delay attributable in whole or in part to any cause beyond its reasonable control, including but not limited to acts of God (fire, storm, floods, earthquakes, etc.), civil disturbances, disruption of telecommunications, disruption of power or other essential services, interruption or termination of service by any service providers being used by Cloudera to link its servers to the Internet, labor disturbances, vandalism, cable cut, computer viruses or other similar occurrences, or any malicious or unlawful acts of any third-party (each a “Force Majeure Event”). In the event of any such delay the date of delivery will be deferred for a period equal to the time lost by reason of the delay. Any notice or communication required or permitted to be given hereunder must be in writing signed or authorized by the party giving notice, and may be delivered by hand, deposited with an overnight courier, sent by confirmed email, confirmed facsimile or mailed by registered or certified mail, return receipt requested, postage prepaid, in each case to the address below or at such other address as may hereafter be furnished in accordance with this Section. No modification, addition or deletion, or waiver of any rights under this Agreement will be binding on a party unless made in an agreement clearly understood by the parties to be a modification or waiver and signed by a duly authorized representative of each party. No failure or delay (in whole or in part) on the part of a party to exercise any right or remedy hereunder will operate as a waiver thereof or effect any other right or remedy. All rights and remedies hereunder are cumulative and are not exclusive of any other rights or remedies provided hereunder or by law. The waiver of one breach or default or any delay in exercising any rights will not constitute a waiver of any subsequent breach or default.

http://www.cloudera.com/content/www/en-us/legal/terms-and-conditions/cloudera-standard-license-v4-2016-05-26.html


