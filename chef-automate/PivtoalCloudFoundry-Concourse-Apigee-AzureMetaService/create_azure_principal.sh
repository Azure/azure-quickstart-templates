#!/bin/sh
#
# this script is 'opinionated' and makes the following assumption
#
#   1.  everything will be created against the selected ("Default") Azure subscription
#   2.  current User has sufficient privileges to create AAD application and service principal
#   3.  Azure CLI is installed on the machine this script is run
#
#   This script will return clientID, tenantID, client-secret that can be used to
#   populate Azure marketplace offer of Pivotal cloud foundry.

usage ()
{
  echo "$0 <azure subscription name>"
  echo '           This script creates a new Azure Service Principal under this subscription, '
  echo '           returning a clientID, tenantID, client-secret that can be used to'
  echo '           populate Azure marketplace offer of Pivotal Cloud Foundry.'
  echo
  echo '           e.g. "Pay-As-You-Go" is a common subscription name.  '
  echo
  echo '           Note that Azure Free Trials do not have sufficient'
  echo '           quota and are currently not supported.'
  echo
}

if [ "$#" -ne 1 ]
then
  usage
  exit
fi

# ensure ARM mode
#
azure config mode arm

# start with http://aka.ms/devicelogin
# will spin here until login completes
azure login

# capture output for values
#
# "id"			SUBSCRIPTION-ID
# "tenandId"		TENANT-ID
#
azure account list --json

NAME=`azure account list | grep Enabled | grep true | awk -F '[[:space:]][[:space:]]+' '{ print $2 }'`
SUBSCRIPTIONID=`azure account list | grep "$1" | grep true | awk -F '[[:space:]][[:space:]]+' '{ print $3 }'`

if [ -z $SUBSCRIPTIONID ]; then
  echo "Subscription $1 not found."
  exit
fi

TENANTID=`azure account list --json | grep -A6 ${SUBSCRIPTIONID} | tail -1 | awk -F':' '{ print $2 }' | tr -d ',' | tr -d '"' `

# for multiple subscriptions, select the appropriate
#
azure account set $SUBSCRIPTIONID

# change all of this from default value
#


# create unique SP using mmdd
#

#SPVER=`date +"%m%d"`
SPVER=`date +"%m%d%S"`

PCFBOSHNAME="PCFBOSHv${SPVER}"
IDURIS="http://PCFBOSHv${SPVER}"
HOMEPAGE="http://PCFBOSHv${SPVER}"

# client-secret		CLIENT-SECRET
#
CLIENTSECRET=`openssl rand -base64 16 | tr -dc _A-z-a-z-0-9`

# "application Id"	 CLIENT-ID
#

CLIENTID=`azure ad app create --name "$PCFBOSHNAME" --password "$CLIENTSECRET" --identifier-uris ""$IDURIS"" --home-page ""$HOMEPAGE"" | grep  "AppId:" | awk -F':' '{ print $3 } ' | tr -d ' '`


# create Service Principle
#

SPNAME="http://PCFBOSHv${SPVER}"

sleep 10

azure ad sp create $CLIENTID

sleep 10

azure role assignment create --roleName "Contributor"  --spn "$SPNAME" --subscription $SUBSCRIPTIONID


echo "{"
echo "  \"\$schema\": \"http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#\","
echo "  \"contentVersion\": \"1.0.0.0\","
echo "  \"parameters\": {"
echo "     \"SUBSCRIPTION_ID\": {"
echo "       \"value\": \"$SUBSCRIPTIONID\""
echo "    },"
echo "     \"tenantID\": {"
echo "       \"value\": \"$TENANTID\""
echo "    },"
echo "     \"clientID\": {"
echo "       \"value\": \"$CLIENTID\""
echo "    },"
echo "     \"CLIENTSECRET\": {"
echo "       \"value\": \"$CLIENTSECRET\""
echo "    }"
echo "  }"
echo "}"
