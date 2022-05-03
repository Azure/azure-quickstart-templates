#!/bin/bash

function print_usage() {
  cat <<EOF
Command
  $0
Arguments
  --jenkins_fqdn|-jf               [Required] : Jenkins FQDN
  --jenkins_private_ip|-jpi                   : The VM private ip used to configure Jenkins URL. If missing, jenkins_fqdn will be used instead
  --jenkins_release_type|-jrt                 : The Jenkins release type (LTS or weekly or verified). By default it's set to LTS
  --jenkins_version_location|-jvl             : Url used to specify the version of Jenkins.
  --subscription|-su               [Required] : Azure subscription id
  --tenant|-t                      [Required] : Azure tenant id
  --clientid|-i                    [Required] : Azure service principal client id
  --clientsecret|-s                [Required] : Azure service principal client secret
  --resourcegroup|-rg              [Required] : Azure resource group for the components
  --location|-l                    [Required] : Azure resource group location for the components
  --image_resourcegroup|-irg       [Required] : Azure resource group for the VM image
  --image|-im                                 : VM image name
  --vm_dns|-vd                     [Required] : Unique DNS name for the Virtual Machine
  --vm_username|-vu                [Required] : Username for the Virtual Machine
  --vm_password|-vp                [Required] : Password for the Virtual Machine
  --repository|-rr                 [Required] : Repository targeted by the build
  --oms_workspace_id|-wi           [Required] : OMS workspace id
  --oms_workspace_key|-wk          [Required] : OMS workspace key
  --artifacts_location|-al                    : Url used to reference other scripts/artifacts.
  --sas_token|-st                             : A sas token needed if the artifacts location is private.
EOF
}

function throw_if_empty() {
  local name="$1"
  local value="$2"
  if [ -z "$value" ]; then
    >&2 echo "Parameter '$name' cannot be empty."
    print_usage
    exit -1
  fi
}

function ms_run_util_script() {
  local script_path="$1"
  shift
  curl --silent "${ms_artifacts_location}${script_path}${ms_artifacts_location_sas_token}" | sudo bash -s -- "$@"
  local return_value=$?
  if [ $return_value -ne 0 ]; then
    >&2 echo "Failed while executing script '$script_path'."
    exit $return_value
  fi
}

# set defaults
jenkins_url="http://localhost:8080/"
jenkins_username="admin"
jenkins_password=""
image="myPackerLinuxImage"
job_short_name="BuildVM"
credential_id="vmCred"
credential_description="VM credential"
ms_artifacts_location="https://raw.githubusercontent.com/Azure/azure-devops-utils/v0.28.1/"
ms_artifacts_location_sas_token=""

while [[ $# > 0 ]]
do
  key="$1"
  shift
  case $key in
    --jenkins_fqdn|-jf)
      jenkins_fqdn="$1"
      shift
      ;;
    --jenkins_private_ip|-jpi)
      jenkins_private_ip="$1"
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
    --subscription|-su)
      subscription="$1"
      shift
      ;;
    --tenant|-t)
      tenant="$1"
      shift
      ;;
    --clientid|-i)
      clientid="$1"
      shift
      ;;
    --clientsecret|-s)
      clientsecret="$1"
      shift
      ;;
    --resourcegroup|-rg)
      resourcegroup="$1"
      shift
      ;;
    --location|-l)
      location="$1"
      shift
      ;;
    --image_resourcegroup|-irg)
      image_resourcegroup="$1"
      shift
      ;;
    --image|-im)
      image="$1"
      shift
      ;;
    --vm_dns|-vd)
      vm_dns="$1"
      shift
      ;;
    --vm_username|-vu)
      vm_username="$1"
      shift
      ;;
    --vm_password|-vp)
      vm_password="$1"
      shift
      ;;
    --repository|-rr)
      repository="$1"
      shift
      ;;
    --oms_workspace_id|-wi)
      oms_workspace_id="$1"
      shift
      ;;
    --oms_workspace_key|-wk)
      oms_workspace_key="$1"
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
      >&2 echo "ERROR: Unknown argument '$key' to script '$0'"
      exit -1
  esac
done

throw_if_empty jenkins_username $jenkins_username
if [ "$jenkins_username" != "admin" ]; then
  throw_if_empty jenkins_password $jenkins_password
fi
throw_if_empty --jenkins_fqdn $jenkins_fqdn
throw_if_empty --subscription $subscription
throw_if_empty --tenant $tenant
throw_if_empty --clientid $clientid
throw_if_empty --clientsecret $clientsecret
throw_if_empty --resourcegroup $resourcegroup
throw_if_empty --location $location
throw_if_empty --image_resourcegroup $image_resourcegroup
throw_if_empty --vm_dns $vm_dns
throw_if_empty --vm_username $vm_username
throw_if_empty --vm_password $vm_password
throw_if_empty --repository $repository
throw_if_empty --oms_workspace_id $oms_workspace_id
throw_if_empty --oms_workspace_key $oms_workspace_key

# install jenkins
ms_run_util_script "jenkins/install_jenkins.sh" -jf "${jenkins_fqdn}" -pi "${jenkins_private_ip}" -jrt "${jenkins_release_type}" -jvl "${jenkins_version_location}" -al "${ms_artifacts_location}" -st "${ms_artifacts_location_sas_token}"

# install required plugins
plugins=(credentials envinject)
for plugin in "${plugins[@]}"; do
  ms_run_util_script "jenkins/run-cli-command.sh" -j "$jenkins_url" -ju "$jenkins_username" -jp "$jenkins_password" -c "install-plugin $plugin -deploy"
done

# restart jenkins
sudo service jenkins restart

# wait for instance to be back online
ms_run_util_script "jenkins/run-cli-command.sh" -j "$jenkins_url" -ju "$jenkins_username" -jp "$jenkins_password" -c "version"

# download dependencies
job_xml=$(curl -s ${artifacts_location}/scripts/jenkins/jobs-build-vm.xml${artifacts_location_sas_token})
credentials_xml=$(curl -s ${artifacts_location}/scripts/jenkins/credentials-basic.xml${artifacts_location_sas_token})

# prepare job xml
job_xml=${job_xml//'{insert-repository-url}'/${repository}}
job_xml=${job_xml//'{insert-credentials-id}'/${credential_id}}
job_xml=${job_xml//'{insert-subscription-id}'/${subscription}}
job_xml=${job_xml//'{insert-tenant-id}'/${tenant}}
job_xml=${job_xml//'{insert-client-id}'/${clientid}}
job_xml=${job_xml//'{insert-client-secret}'/${clientsecret}}
job_xml=${job_xml//'{insert-resource-group}'/${resourcegroup}}
job_xml=${job_xml//'{insert-location}'/${location}}
job_xml=${job_xml//'{insert-image-resource-group}'/${image_resourcegroup}}
job_xml=${job_xml//'{insert-image-name}'/${image}}
job_xml=${job_xml//'{insert-dns-name}'/${vm_dns}}
job_xml=${job_xml//'{insert-repository-url}'/${repository}}
job_xml=${job_xml//'{insert-oms-workspace-id}'/${oms_workspace_id}}
job_xml=${job_xml//'{insert-oms-workspace-key}'/${oms_workspace_key}}

# prepare credential xml
credentials_xml=${credentials_xml//'{insert-credentials-id}'/${credential_id}}
credentials_xml=${credentials_xml//'{insert-credentials-description}'/${credential_description}}
credentials_xml=${credentials_xml//'{insert-user-name}'/${vm_username}}
credentials_xml=${credentials_xml//'{insert-user-password}'/${vm_password}}

# add job
echo "${job_xml}" > job.xml
ms_run_util_script "jenkins/run-cli-command.sh" -j "$jenkins_url" -ju "$jenkins_username" -jp "$jenkins_password" -c "create-job ${job_short_name}" -cif "job.xml"

# add credential
echo "${credentials_xml}" > credentials.xml
ms_run_util_script "jenkins/run-cli-command.sh" -j "$jenkins_url" -ju "$jenkins_username" -jp "$jenkins_password" -c "create-credentials-by-xml system::system::jenkins _" -cif "credentials.xml"

# install tools
sudo apt-get install unzip --yes

wget https://releases.hashicorp.com/packer/1.1.3/packer_1.1.3_linux_amd64.zip
unzip packer_1.1.3_linux_amd64.zip -d /usr/bin

wget https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip
unzip terraform_0.11.1_linux_amd64.zip -d /usr/bin

# cleanup
rm job.xml
rm credentials.xml
rm jenkins-cli.jar
rm packer_1.1.3_linux_amd64.zip
rm terraform_0.11.1_linux_amd64.zip
