USERNAME=$1
PASSWORD=$2
JPASSWORD=$3
SRC="/var/lib/jenkins"
DTRDNS="$4"
#echo $USERNAME
#echo $PASSWORD
#echo $DTRDNS
curl https://packages.docker.com/1.11/install.sh | sh
cd /tmp
#curl https://raw.githubusercontent.com/sysgain/CloudTry-CloudBees/jenkins-plugin-update/cb-soln/Templates/Job/config.xml > /var/lib/jenkins/config.xml
#curl https://raw.githubusercontent.com/sysgain/CloudTry-CloudBees/master/cb-soln/Templates/Job/dtr-creds.xml > /var/lib/jenkins/credentials.xml
###############################################Create jobs for jenkins, pulling xml files from git#############################################################

BaseURL=https://raw.githubusercontent.com/SattaRavi/example-voting-app/master
FileName="job-config.xml"
for i in job-config.xml result/job-config.xml vote/job-config.xml worker/job-config.xml
do 
echo $BaseURL/$i
wget $BaseURL/$i
j=`echo $i | awk -F"/" '{print $1}'`
echo $j
mv $FileName master_"$j"_"$FileName"
sleep 5
done

################################################################################################################################################################
wget https://raw.githubusercontent.com/sysgain/CloudTry-CloudBees/jenkins-plugin-update/cb-soln/Templates/Job/config.xml
wget https://raw.githubusercontent.com/sysgain/CloudTry-CloudBees/master/cb-soln/Templates/Job/dtr-creds.xml
mv /tmp/config.xml /tmp/config1.xml
mv /tmp/dtr-creds.xml /tmp/credentials.xml
chown jenkins:jenkins *.xml
mv /tmp/*.xml $SRC/
cd $SRC
chown jenkins:jenkins config1.xml credentials.xml
sed -i 's/admin/'$USERNAME'/g' /var/lib/jenkins/credentials.xml
sed -i 's/Sysga1n4205!/'$PASSWORD'/g' /var/lib/jenkins/credentials.xml
################################################################################################################################################################
DOMAIN_NAME=$DTRDNS
openssl s_client -connect $DOMAIN_NAME:443 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM | sudo tee /usr/local/share/ca-certificates/$DOMAIN_NAME.crt
sudo update-ca-certificates
sudo usermod -aG docker jenkins
sleep 5
sudo service docker restart
cd /var/lib/jenkins/
curl -X POST -H "Content-Type:application/xml" -d @config1.xml "http://localhost/createItem?name=CloudTryPipeline0" --user admin:$JPASSWORD
sleep 5
curl -X POST -H "Content-Type:application/xml" -d @master_job-config.xml_job-config.xml "http://localhost/createItem?name=Job-Master" --user admin:$JPASSWORD
sleep 5
curl -X POST -H "Content-Type:application/xml" -d @master_result_job-config.xml "http://localhost/createItem?name=Job-Result" --user admin:$JPASSWORD
sleep 5
curl -X POST -H "Content-Type:application/xml" -d @master_vote_job-config.xml "http://localhost/createItem?name=Job-Vote" --user admin:$JPASSWORD
sleep 5
curl -X POST -H "Content-Type:application/xml" -d @master_worker_job-config.xml "http://localhost/createItem?name=Job-Worker" --user admin:$JPASSWORD
sudo service jenkins restart