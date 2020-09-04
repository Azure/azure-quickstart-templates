#!/bin/bash
function print_usage() {
  cat <<EOF
Command
  $0
Arguments
  --vm_user_name|-u               [Required] : VM user name
  --git_url|-g                    [Required] : Git URL with a Dockerfile in it's root
  --registry|-r                   [Required] : Registry url targeted by the pipeline
  --registry_user_name|-ru        [Required] : Registry user name
  --registry_password|-rp         [Required] : Registry password
  --repository|-rr                [Required] : Repository targeted by the pipeline
  --resource_group_name|-gn       [Required] : Name of the resource group which contains the AKS
  --cluster_name|-cn              [Required] : Name of the AKS cluster
  --jenkins_fqdn|-jf              [Required] : Jenkins FQDN
  --service_principal_id|-spid    [Required] : The service principal ID.
  --service_principal_secret|-ss  [Required] : The service principal secret.
  --subscription_id|-subid        [Required] : The subscription ID of the SP.
  --tenant_id|-tid                [Required] : The tenant id of the SP.
  --mongodb_uri|-mu               [Required] : URI of the MongoDB
  --artifacts_location|-al                   : Url used to reference other scripts/artifacts.
  --sas_token|-st                            : A sas token needed if the artifacts location is private.
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
while [[ $# > 0 ]]
do
  key="$1"
  shift
  case $key in
    --vm_user_name|-u)
      vm_user_name="$1"
      shift
      ;;
    --git_url|-g)
      git_url="$1"
      shift
      ;;
    --registry|-r)
      registry="$1"
      shift
      ;;
    --registry_user_name|-ru)
      registry_user_name="$1"
      shift
      ;;
    --registry_password|-rp)
      registry_password="$1"
      shift
      ;;
    --repository|-rr)
      repository="$1"
      shift
      ;;
    --resource_group_name|-gn)
      resource_group_name="$1"
      shift
      ;;
    --cluster_name|-cn)
      cluster_name="$1"
      shift
      ;;
    --jenkins_fqdn|-jf)
      jenkins_fqdn="$1"
      shift
      ;;
    --service_principal_id|-spid)
      service_principal_id="$1"
      shift
      ;;
    --service_principal_secret|-ss)
      service_principal_secret="$1"
      shift
      ;;
    --subscription_id|-subid)
      subscription_id="$1"
      shift
      ;;
    --tenant_id|-tid)
      tenant_id="$1"
      shift
      ;;
    --mongodb_uri|-mu)
      mongodb_uri="$1"
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

throw_if_empty --vm_user_name $vm_user_name
throw_if_empty --git_url $git_url
throw_if_empty --registry $registry
throw_if_empty --registry_user_name $registry_user_name
throw_if_empty --registry_password $registry_password
throw_if_empty --jenkins_fqdn $jenkins_fqdn
throw_if_empty --service_principal_id $service_principal_id
throw_if_empty --service_principal_secret $service_principal_secret
throw_if_empty --subscription_id $subscription_id
throw_if_empty --tenant_id $tenant_id
throw_if_empty --resource_group_name $resource_group_name
throw_if_empty --cluster_name $cluster_name
throw_if_empty --cluster_name $mongodb_uri

#install jenkins
run_util_script "scripts/jenkins/install_jenkins.sh" -jf "${jenkins_fqdn}" -spid "${service_principal_id}" -ss "${service_principal_secret}" -subid "${subscription_id}" -tid "${tenant_id}" -al "${artifacts_location}" -st "${artifacts_location_sas_token}"

#install git
sudo apt-get install git --yes

#install docker if not already installed
if !(command -v docker >/dev/null); then
  sudo curl -sSL https://get.docker.com/ | sh
fi

#make sure jenkins has access to docker cli
sudo gpasswd -a jenkins docker
skill -KILL -u jenkins
sudo service jenkins restart

if [ -z "$repository" ]; then
  repository="hello-world"
fi

job_short_name="hello-world"
job_display_name="Hello World Build & Deploy"
job_description="A pipeline that builds a Docker image, pushed built image to ACR, and deploy configurations to AKS."

echo "Including the pipeline"
run_util_script "scripts/jenkins/add-docker-build-job.sh" -j "http://localhost:8080/" -ju "admin" -jsn "${job_short_name}" -jdn "${job_display_name}" -jd "${job_description}" -g "${git_url}" -r "${registry}" -ru "${registry_user_name}" -rp "${registry_password}" -rr "$repository" -agn "${resource_group_name}" -acn "${cluster_name}" -mu "${mongodb_uri}" -sps "* * * * *" -al "$artifacts_location" -st "$artifacts_location_sas_token"
