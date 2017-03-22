#!/bin/bash

#TODO - Add github account/password to parameters and support github account setup

# If you want to export the job you can run the following command 
# java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://user:password@localhost:8080 get-job "Build Hello World" > jenkins_job.xml

# This script to configure Jenkins automatically with a groovy script 
# Default values

function print_usage() {
  cat <<EOF

Usage: 

        -ou :   (REQUIRED) The oracle username used to download the JDK 
        -op :   (REQUIRED) The password associated with this username 
        -ju :   (REQUIRED) the jenkins username that will create the intial job
        -jp :   (REQUIRED) the jenkins user password 

Example:
        ./init_jenkins.sh -ou oracleuser@oracle.com -op oraclepassword -ju jenkins -jp Passw0rd

EOF
}

ORACLE_USER=""
ORACLE_PASSWORD=""
JENKINS_USER=""
JENKINS_PWD=""
APTLY_REPO_NAME=""
WORKDIR="/opt/azure_jenkins_config"

while [[ $# -gt 1 ]]
do
key="$1"
case $key in
   -ou)
   ORACLE_USER="$2"
   shift
   ;;
   -op)
   ORACLE_PASSWORD="$2"
   shift
   ;;
   -ar)
   APTLY_REPO_NAME="$2"
   shift
   ;;
   -ju)
   JENKINS_USER="$2"
   shift
   ;;
   -jp)
   JENKINS_PWD="$2"
   shift
   ;;
   *)

   ;;
esac
shift
done

#parameter checks
if [ -z $ORACLE_USER ]
then
    echo "parameter -ou missing."
    print_usage
    exit 1  
fi

if [ -z $ORACLE_PASSWORD ]
then
    echo "parameter -op missing."
    print_usage
    exit 1  
fi

if [ -z $JENKINS_USER]
then
    echo "parameter -ju missing."
    print_usage
    exit 1  
fi

if [ -z $JENKINS_PWD ]
then
    echo "parameter -jp missing."
    print_usage
    exit 1  
fi

# Installing Aptly
$WORKDIR/setup_aptly.sh -ar $APTLY_REPO_NAME
# Pausing to allow nginx to start completely
sleep 10

# Verify that we can login to Jenkins
error_check=$(sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_USER:$JENKINS_PWD@localhost:8080 who-am-i 2> /dev/null)

if [ -z "$error_check" ]
then
        echo -e "\e[31mError\e[0m - Jenkins Authentication Error \n"
        echo "Your Jenkins credentials do not match the Jenkins user \n"
        echo "Please run the script again with the following command: \n"
        echo "init_jenkins.sh -ju %YOUR_JENKINS_USERNAME% -jp %JENKINS_USER_PASSWORD%"
else
        echo -e "\e[33mAuthenticated\e[0m"
        # This script to configure the following stuff from Jenkins automatically: JDK, Oracle user and password, Gradle
        sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_USER:$JENKINS_PWD@localhost:8080 groovy $WORKDIR/init.groovy $ORACLE_USER $ORACLE_PASSWORD

        sudo service jenkins stop 
        sudo service jenkins start 
fi

