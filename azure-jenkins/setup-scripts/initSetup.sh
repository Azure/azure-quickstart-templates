#! /bin/bash

CURRENT_USER=$(whoami)
SETUP_SCRIPTS_LOCATION="/tmp/azurejenkinslog/"
SETUP_SCRIPT="initSetup.sh"
SETUP_SCRIPT_LOG="initsetupbm.log"
CONFIG_JENKINS_JOB_SCRIPT="config_storage.sh"
SET_AZURE_CREDENTIAL_SCRIPT="set_azure_credentials.sh"
SOURCE_URI="https://raw.githubusercontent.com/azure-quickstart-templates/master/azure-jenkins/setup-scripts/"
temp=$(mktemp)

if [ ! -f $SETUP_SCRIPTS_LOCATION ]; then
    sudo mkdir $SETUP_SCRIPTS_LOCATION
    if [ ! -f $SETUP_SCRIPTS_LOCATION$SETUP_SCRIPT_LOG ]; then

       echo "Downloading azure configuration scripts.... " > $temp

       #downloading jenkins azure storage job configuration script
       sudo curl -o $SETUP_SCRIPTS_LOCATION$CONFIG_JENKINS_JOB_SCRIPT $SOURCE_URI$CONFIG_JENKINS_JOB_SCRIPT
       #downloading service princeple script
       sudo curl -o $SETUP_SCRIPTS_LOCATION$SET_AZURE_CREDENTIAL_SCRIPT $SOURCE_URI$SET_AZURE_CREDENTIAL_SCRIPT

       echo "Download is complete. " >> $temp

       echo "Now running intial setup script $SETUP_SCRIPTS_LOCATION$SETUP_SCRIPT" >>  $temp
       echo "Start configuring Azure jenkins download job, upload job" >> $temp

       #making sure script has execution right	
       sudo chmod +x $SETUP_SCRIPTS_LOCATION$CONFIG_JENKINS_JOB_SCRIPT
       echo "Adding execution right to $SETUP_SCRIPTS_LOCATION$CONFIG_JENKINS_JOB_SCRIPT" >> $temp

       #open a new terminal to run the interactive jenkins jobsetup script	
       sudo gnome-terminal -e $SETUP_SCRIPTS_LOCATION$CONFIG_JENKINS_JOB_SCRIPT
       
       sleep 10

       #open a new terminal to run the interactive script	
       #sudo gnome-terminal -e $SETUP_SCRIPTS_LOCATION$SET_AZURE_CREDENTIAL_SCRIPT
       
   else
       echo "$CURRENT_USER has already setup, no need to setup anymore"
   fi
   else
      echo "$CURRENT_USER has already setup, no need to setup anymore"
fi

sudo cp $temp $SETUP_SCRIPTS_LOCATION$SETUP_SCRIPT_LOG
