##GETTING STARTED
###Notes and Prerequisites
- Apprenda Licensing for the Apprenda Azure Certified Image is free for the first month (trial period). After the first month the cost is $0.10/hour
- You are responsible for the cost of operating the Virtual Machine in Azure. Consult the Azure Pricing details for the Tier of your choice to get an estimate of the cost. We recommend using at least an A4 workload for the Apprenda virtual machine for optimal performance.

###Completing the Installation
1.	Once the Virtual Machine boots, log in using the Administrator local account you created (the instance is not part of an Active Directory Domain) and the password you entered in the customization settings. Don’t use the ‘apprendamanager’ and ‘apprendasystem’ local accounts for logging in as those are reserved for Apprenda
2.	Ensure that the Virtual Machine has Internet connectivity
3.	When you first log in, a Scheduled Task will execute that will start the process of finalizing the SQL Server installation and the installation of Apprenda
4.	The Scheduled Task will start a PowerShell script that will ask for your confirmation to continue. The script will then ask to validate that the SQL Server was successfully installed. Finally, the PowerShell will ask you for your email address to create the first account in Apprenda
a.	The SQL Server Instance will be <computername>\apprendasql a. SQL Authentication Username is apprendadbuser, Password is @pp|23n|}4
b.	SQL Management Studio is already installed



###Accessing the Developer Portal and SOC
1.	One the PowerShell script is finished, you can launch Chrome (the Apprenda image does not contain Internet Explorer) with the following URLs (links to both are created in the desktop)
  1.	Operator Portal (https://apps.apprenda.<computername>/SOC)
  2.  Username is the email address you entered in the PowerShell script, Password is apprendaadmin
b.	Developer Portal (https://apps.apprenda.<computername>/Developer)
ii.	ii. Username is the email address you entered in the PowerShell script, Password is apprendaadmin
2.	Use the following link to TimeCard.zip to create your first application in the Apprenda Developer Portal: http://docs.apprenda.com/sites/default/files/TimeCard.zip
3.	Don’t forget to configure or enable the following services and components
a.	Windows Updates
b.	Windows Firewall
c.	Windows SmartScreen

For a useful video of how this VHD is being utilized in Microsoft Azure Marketplace as an Azure Certified Image, follow this link: https://www.youtube.com/watch?v=rmnO5KhDYus

###START HERE. THEN TAKE APPRENDA HOME.

With the Apprenda 5.5 Express Azure Certified Image you can experience most of the functionality of the Apprenda Enterprise Private PaaS, before installing the platform within your enterprise IT environment or in Microsoft Azure. Everything you do with this image of Apprenda can be deployed on your own compute capacity in the private, public, or hosted cloud. When you're ready, click here for more information.
##ADDITIONAL RESOURCES
1. Sign up for the monthly free tutorial
2. Arrange a Proof-of-Concept (PoC) for your organization

##About Apprenda
Apprenda is the leading enterprise Platform as a Service (PaaS) powering the next generation of enterprise software development in public, private and hybrid clouds. As a foundational software layer and application run-time environment, Apprenda abstracts away the complexities of building and delivering modern software applications, enabling enterprises to turn ideas into innovations faster. With Apprenda, enterprises can securely deliver an entire ecosystem of data, services, applications and APIs to both internal and external customers across any infrastructure. From the world’s largest banks like JPMorgan Chase to healthcare organizations including McKesson and AmerisourceBergen, Apprenda’s clients are part of a new class of software-defined enterprises, disrupting industries and winning with software. For more information, visit Apprenda at www.apprenda.com.
