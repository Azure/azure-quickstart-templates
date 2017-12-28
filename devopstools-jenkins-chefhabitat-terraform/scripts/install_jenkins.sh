#!/bin/bash
function print_usage() {
  cat <<EOF
Installs Jenkins and exposes it to the public through port 80 (login and cli are disabled)
Command
  $0
Arguments
  --jenkins_fqdn|-jf       [Required] : Jenkins FQDN
  --vm_private_ip|-pi                 : The VM private ip used to configure Jenkins URL. If missing, jenkins_fqdn will be used instead
  --jenkins_release_type|-jrt         : The Jenkins release type (LTS or weekly or verified). By default it's set to LTS
  --jenkins_version_location|-jvl     : Url used to specify the version of Jenkins.
  --artifacts_location|-al            : Url used to reference other scripts/artifacts.
  --sas_token|-st                     : A sas token needed if the artifacts location is private.
EOF
}

function throw_if_empty() {
  local name="$1"
  local value="$2"
  if [ -z "$value" ]; then
    echo "Parameter '$name' cannot be empty." 1>&2
    print_usage
    exit -1
  fi
}

function run_util_script() {
  local script_path="$1"
  shift
  curl --silent "${artifacts_location}${script_path}${artifacts_location_sas_token}" | sudo bash -s -- "$@"
  local return_value=$?
  if [ $return_value -ne 0 ]; then
    >&2 echo "Failed while executing script '$script_path'."
    exit $return_value
  fi
}

#defaults
#artifacts_location="https://raw.githubusercontent.com/Azure/azure-devops-utils/master/"
artifacts_location="https://raw.githubusercontent.com/sysgain/azure-quickstart-templates/msoss-p1/devopstools-jenkins-chefhabitat-terraform"
jenkins_version_location="https://raw.githubusercontent.com/sysgain/azure-quickstart-templates/msoss-p1/devopstools-jenkins-chefhabitat-terraform/scripts/jenkins-verified-ver"
azure_web_page_location="/usr/share/nginx/azure"
jenkins_release_type="LTS"

while [[ $# > 0 ]]
do
  key="$1"
  shift
  case $key in
    --jenkins_fqdn|-jf)
      jenkins_fqdn="$1"
      shift
      ;;
    --vm_private_ip|-pi)
      vm_private_ip="$1"
      shift
      ;;
    --jenkins_release_type|-jrt)
      jenkins_release_type="$1"
      shift
      ;;
    --jenkins_version_location|-jvl)
      jenkins_version_location="$1"
      shift
      ;;
    --artifacts_location|-al)
      artifacts_location="$1"
      shift
      ;;
    --sas_token|-st)
      artifacts_location_sas_token="$1"
      shift
      ;;
    --help|-help|-h)
      print_usage
      exit 13
      ;;
    *)
      echo "ERROR: Unknown argument '$key' to script '$0'" 1>&2
      exit -1
  esac
done

throw_if_empty --jenkins_fqdn $jenkins_fqdn
throw_if_empty --jenkins_release_type $jenkins_release_type
if [[ "$jenkins_release_type" != "LTS" ]] && [[ "$jenkins_release_type" != "weekly" ]] && [[ "$jenkins_release_type" != "verified" ]]; then
  echo "Parameter jenkins_release_type can only be 'LTS' or 'weekly' or 'verified'! Current value is '$jenkins_release_type'"
  exit 1
fi

if [ -z "$vm_private_ip" ]; then
    #use port 80 for public fqdn
    jenkins_url="http://${jenkins_fqdn}/"
else
    #use port 8080 for internal
    jenkins_url="http://${vm_private_ip}:8080/"
fi

jenkins_auth_matrix_conf=$(cat <<EOF
<authorizationStrategy class="hudson.security.ProjectMatrixAuthorizationStrategy">
    <permission>com.cloudbees.plugins.credentials.CredentialsProvider.Create:authenticated</permission>
    <permission>com.cloudbees.plugins.credentials.CredentialsProvider.Delete:authenticated</permission>
    <permission>com.cloudbees.plugins.credentials.CredentialsProvider.ManageDomains:authenticated</permission>
    <permission>com.cloudbees.plugins.credentials.CredentialsProvider.Update:authenticated</permission>
    <permission>com.cloudbees.plugins.credentials.CredentialsProvider.View:authenticated</permission>
    <permission>hudson.model.Computer.Build:authenticated</permission>
    <permission>hudson.model.Computer.Configure:authenticated</permission>
    <permission>hudson.model.Computer.Connect:authenticated</permission>
    <permission>hudson.model.Computer.Create:authenticated</permission>
    <permission>hudson.model.Computer.Delete:authenticated</permission>
    <permission>hudson.model.Computer.Disconnect:authenticated</permission>
    <permission>hudson.model.Hudson.Administer:authenticated</permission>
    <permission>hudson.model.Hudson.ConfigureUpdateCenter:authenticated</permission>
    <permission>hudson.model.Hudson.Read:authenticated</permission>
    <permission>hudson.model.Hudson.RunScripts:authenticated</permission>
    <permission>hudson.model.Hudson.UploadPlugins:authenticated</permission>
    <permission>hudson.model.Item.Build:authenticated</permission>
    <permission>hudson.model.Item.Cancel:authenticated</permission>
    <permission>hudson.model.Item.Configure:authenticated</permission>
    <permission>hudson.model.Item.Create:authenticated</permission>
    <permission>hudson.model.Item.Delete:authenticated</permission>
    <permission>hudson.model.Item.Discover:authenticated</permission>
    <permission>hudson.model.Item.Move:authenticated</permission>
    <permission>hudson.model.Item.Read:authenticated</permission>
    <permission>hudson.model.Item.Workspace:authenticated</permission>
    <permission>hudson.model.Run.Delete:authenticated</permission>
    <permission>hudson.model.Run.Replay:authenticated</permission>
    <permission>hudson.model.Run.Update:authenticated</permission>
    <permission>hudson.model.View.Configure:authenticated</permission>
    <permission>hudson.model.View.Create:authenticated</permission>
    <permission>hudson.model.View.Delete:authenticated</permission>
    <permission>hudson.model.View.Read:authenticated</permission>
    <permission>hudson.scm.SCM.Tag:authenticated</permission>
    <permission>hudson.model.Hudson.Read:anonymous</permission>
    <permission>hudson.model.Item.Discover:anonymous</permission>
    <permission>hudson.model.Item.Read:anonymous</permission>
</authorizationStrategy>
EOF
)

jenkins_location_conf=$(cat <<EOF
<?xml version='1.0' encoding='UTF-8'?>
<jenkins.model.JenkinsLocationConfiguration>
    <adminAddress>address not configured yet &lt;nobody@nowhere&gt;</adminAddress>
    <jenkinsUrl>${jenkins_url}</jenkinsUrl>
</jenkins.model.JenkinsLocationConfiguration>
EOF
)

jenkins_disable_reverse_proxy_warning=$(cat <<EOF
<disabledAdministrativeMonitors>
    <string>hudson.diagnosis.ReverseProxySetupMonitor</string>
</disabledAdministrativeMonitors>
EOF
)

nginx_reverse_proxy_conf=$(cat <<EOF
server {
    listen 80;
    server_name ${jenkins_fqdn};
    error_page 403 /jenkins-on-azure;
    location / {
        proxy_set_header        Host \$host:\$server_port;
        proxy_set_header        X-Real-IP \$remote_addr;
        proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto \$scheme;


        # Fix the “It appears that your reverse proxy set up is broken" error.
        proxy_pass          http://localhost:8080;
        proxy_redirect      http://localhost:8080 http://${jenkins_fqdn};
        proxy_read_timeout  90;
    }
    location /cli {
        rewrite ^ /jenkins-on-azure permanent;
    }

    location ~ /login* {
        rewrite ^ /jenkins-on-azure permanent;
    }
    location /jenkins-on-azure {
      alias ${azure_web_page_location};
    }
}
EOF
)

#update apt repositories
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -

if [ "$jenkins_release_type" == "weekly" ]; then
  sudo sh -c 'echo deb http://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
else
  sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
fi

sudo add-apt-repository ppa:openjdk-r/ppa --yes

echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
sudo apt-get install apt-transport-https
sudo apt-get update --yes

#install openjdk8
sudo apt-get install openjdk-8-jre openjdk-8-jre-headless openjdk-8-jdk --yes

#install jenkins
if [[ ${jenkins_release_type} == 'verified' ]]; then
  jenkins_version=$(curl --silent "${jenkins_version_location}")
  deb_file=jenkins_${jenkins_version}_all.deb
  wget -q "https://pkg.jenkins.io/debian-stable/binary/${deb_file}"
  if [[ -f ${deb_file} ]]; then
    sudo dpkg -i ${deb_file}
    sudo apt-get install -f --yes
  else
    echo "Failed to download ${deb_file}. The initialization is terminated!"
    exit -1
  fi
else
  sudo apt-get install jenkins --yes
  sudo apt-get install jenkins --yes # sometime the first apt-get install jenkins command fails, so we try it twice
fi

#We need to install workflow-aggregator so all the options in the auth matrix are valid
plugins=(azure-vm-agents windows-azure-storage matrix-auth workflow-aggregator azure-app-service tfs)
for plugin in "${plugins[@]}"; do
  run_util_script "/scripts/run-cli-command.sh" -c "install-plugin $plugin -deploy"
done

#allow anonymous read access
inter_jenkins_config=$(sed -zr -e"s|<authorizationStrategy.*</authorizationStrategy>|{auth-strategy-token}|" /var/lib/jenkins/config.xml)
final_jenkins_config=${inter_jenkins_config//'{auth-strategy-token}'/${jenkins_auth_matrix_conf}}
echo "${final_jenkins_config}" | sudo tee /var/lib/jenkins/config.xml > /dev/null

#set up Jenkins URL to private_ip:8080 so JNLP connections can be established
echo "${jenkins_location_conf}" | sudo tee /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml > /dev/null

#disable 'It appears that your reverse proxy set up is broken' warning.
# This is visible when connecting through SSH tunneling
inter_jenkins_config=$(sed -zr -e"s|<disabledAdministrativeMonitors/>|{disable-reverse-proxy-token}|" /var/lib/jenkins/config.xml)
final_jenkins_config=${inter_jenkins_config//'{disable-reverse-proxy-token}'/${jenkins_disable_reverse_proxy_warning}}
echo "${final_jenkins_config}" | sudo tee /var/lib/jenkins/config.xml > /dev/null

#restart jenkins
sudo service jenkins restart

#install nginx
sudo apt-get install nginx --yes

#configure nginx
echo "${nginx_reverse_proxy_conf}" | sudo tee /etc/nginx/sites-enabled/default > /dev/null

#don't show version in headers
sudo sed -i "s|.*server_tokens.*|server_tokens off;|" /etc/nginx/nginx.conf

#install jenkins-on-azure web page
run_util_script "/scripts/install-web-page.sh" -u "${jenkins_fqdn}"  -l "${azure_web_page_location}" -al "${artifacts_location}" -st "${artifacts_location_sas_token}"

#restart nginx
sudo service nginx restart

#install common tools
sudo apt-get install git --yes
sudo apt-get install azure-cli --yes