# Deploy Shibboleth Identity Provider cluster on Windows

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgopikap%2Fazure-quickstart-templates%2Fmaster%2Fshibboleth-cluster-windows%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fgopikap%2Fazure-quickstart-templates%2Fmaster%2Fshibboleth-cluster-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys Shibboleth Identity Provider on Windows in a clustered configuration. It creates a one or more Windows VM for the front end and a single VM for the backend. It does a silent install of Apache Tomcat and Open JDK on the front end VM's, and then deploys Shibboleth IDP on each of them. It also deploys MySQL on the backend VM.  It configures a load balancer for directing requests to the front end VM's. It also configures NAT rules to allow admin access to each of the VM's. On backend VM's, it configures the database using JPA. After the deployment is successful, you can go to https://your-domain:8443/idp/profile/status (note port number) to check success. Note that, in case of smaller size VM's, it may take a few minutes for the installation script to complete even after the deployment status is shown as succeeded. For further details, please refer to the Shibboleth IDP documentation at https://wiki.shibboleth.net/confluence/display/IDP30/Clustering.

# Notes

## Front End VM's:
This template can instantiate up to 5 front end VM's. This number can be increased easily by copying and pasting the related parts of the template. 

## Port Details:
The template opens HTTP port 8443 for SSL front end access on all the front end VM's. This port is load-balanced using the load balancer.
It also opens ports 6000 to 6004 on the load balancer which are mapped to port 3389 for RDP access on the respective VM's.

## Certificates:
In order to support SSL, this template creates self signed certificates as a part of the installation script. This allows the template to be deployed without having to create your own certificates. In production deployments, you will need to create and use your own certificates instead of the self signed certificates.

# Test Setup
Here are the steps you can follow to create a testing setup including Shibboleth IDP deployed using this template, along with an OpenLDAP test server and a test SP available online.

# Install ADLDS
Install ADLDS as per the instructions described on https://blogs.msdn.microsoft.com/microsoftrservertigerteam/2017/04/10/step-by-step-guide-to-setup-ldaps-on-windows-server/. You would need following settings (with sample values) of the ADLDS instance to configure Shibboleth.
 	
	- Public IP - 125.524.52.54
	- Bind DN - example - john@testorg.com
	- Bind DN credentials - example - JohnZSQ12*(
	- Base DN - cn=Users,DC=testorg,DC=com

## Deploy Shibboleth IDP using this template.

Create a deployment of Shibboleth IDP using this template and RDP into the VM deployed.

## Update ldap.properties inside /opt/conf directory as per the ADLDS configuration. 
    - set idp.authn.LDAP.authenticator = adAuthenticator
	- set idp.authn.LDAP.ldapURL = ldap://125.524.52.54:389
	- set idp.authn.LDAP.returnAttributes= mail,uid,passwordExpirationTime,loginGraceRemaining
	- set idp.authn.LDAP.useStartTLS = false
	- set idp.authn.LDAP.useSSL = false
	- set idp.authn.LDAP.baseDN = cn=Users,DC=testorg,DC=com
	- set idp.authn.LDAP.userFilter= (sAMAccountName={user})
	- set idp.authn.LDAP.bindDN = john@testorg.com
	- set idp.authn.LDAP.bindDNCredential = JohnZSQ12*(
	- set idp.authn.LDAP.dnFormat = %s@testorg.com
	- Comment out idp.authn.LDAP.sslConfig & Comment out idp.authn.LDAP.trustCertificates as SSL is not used here

## Create metadata xml file for service provider. 
    Note: http://testshib.org is used as Service provider and Shibboleth is used as IDP.
	- Download metadata file from - https://www.testshib.org/metadata/testshib-providers.xml inside /opt/conf directory
	- Configure the metadata provider inside /opt/conf/metadata-providers.xml file as follows
	<!-- TestShib -->
	<MetadataProvider id="HTTPMetadataTESTSHIB"
                  xsi:type="FileBackedHTTPMetadataProvider"
                  backingFile="%{idp.home}/metadata/testshib-providers.xml"
                  metadataURL="http://www.testshib.org/metadata/testshib-providers.xml"/>

		
## Set LDAP attribute resolver
	- Set LDAP Attribute Resolver as default attribute resolver. The default configuration for LDAP attribute resolver is present inside attribute-resolver-ldap.xml  We just have to replace existing attribute-resolver.xml with attribute-resolver-ldap.xml
	- These files are present in /opt/conf/ directory
	- Rename attribute-resolver.xml attribute-resolver-orig.xml
	- Rename attribute-resolver-ldap.xml attribute-resolver.xml


## Configure attribute-resolver
	- Configure the mapping of LDAP attributes with Shibboleth attributes
 	- These instructions would vary as per LDAP installation. Following are specific to forumsys ldap
	- Set sourceAttributeId attribute of Attribute with id=eduPersonPrincipalName to uid 
	<resolver:AttributeDefinition id="eduPersonPrincipalName" xsi:type="ad:Prescoped" sourceAttributeID="mail">
        <resolver:Dependency ref="myLDAP" />
        <resolver:AttributeEncoder xsi:type="enc:SAML1ScopedString" name="urn:mace:dir:attribute-def:eduPersonPrincipalName" encodeType="false" />
        <resolver:AttributeEncoder xsi:type="enc:SAML2ScopedString" name="urn:oid:1.3.6.1.4.1.5923.1.1.1.6" friendlyName="eduPersonPrincipalName" encodeType="false" />
    </resolver:AttributeDefinition>
	- In the bottom of same xml we need to configure data connector settings for LDAP. Again these settings vary as per LDAP setup.
		<resolver:DataConnector id="myLDAP" xsi:type="dc:LDAPDirectory"
				ldapURL="ldap://125.524.52.54:389"
				baseDN="cn=Users,DC=testorg,DC=com" 
				principal="john@testorg.com"
				principalCredential="JohnZSQ12*(">
			<dc:FilterTemplate>
				<![CDATA[
					%{idp.attribute.resolver.LDAP.searchFilter}
				]]>
			</dc:FilterTemplate>
		</resolver:DataConnector>
	
## Configure attribute filter
	- After defining attributes you still have to specify which ones you release to service providers. This can be configured using attribute-filter.xml inside /opt/conf directory
	- We set it so that basic attribute like eduPersonPrincipalName, uid and email are sent to all service providers.
	- <AttributeFilterPolicy id="example1">
        <PolicyRequirementRule xsi:type="ANY" />
	
## Comment out following in idp.properties to use Shibboleth.StorageService instead of Shibboleth.JPAStorageService
	- idp.consent.StorageService 
	- idp.consent.userStorageKey
	- idp.consent.userStorageKeyAttribute

## Add following environment variable inside startup.bat of Apache Tomcat.
    - set IDP_HOME=c:/opt/shibboleth-idp

## Restart the servlet container 
    - cd C:\apache-tomcat-8.5.31\bin\
    - shutdown.bat
	- startup.bat
    
## Test your installation
    - Follow the steps on http://testshib.org to test the shibboleth installation as IDP
    - Log files for Shibboleth reside inside /opt/logs directory. The log files can be helpful for debugging any issues that show up during the login process.
