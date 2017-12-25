#!/bin/bash -xe


##########################variable define##################################
IP_BASE=9
INVENTORY="inventory.ini"
TMP_INVENTORY="inventory.tmp"
TIDB_ANSIBLE="https://github.com/pingcap/tidb-ansible.git"

###########################################################################

#* --------------------------------------------------------------------- */
#*                         log configure                                 */
#* --------------------------------------------------------------------- */
### Define logging color
COLOR_ORIGIN="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_RED="\033[31m"

### Define logging level
LOGGER_LEVEL="3"

### Define common logger
function logger() {
   cur_level=$1
   cur_type=$2
   cur_color=$3
   shift && shift && shift
   cur_msg=$*

   [[ ${LOGGER_LEVEL} -lt ${cur_level} ]] && return 0

   pre_fix="${cur_color}[${cur_type}][$(date +%F)][$(date +%T)]"
   pos_fix="${COLOR_ORIGIN}"
   echo -e "${pre_fix} ${cur_msg} ${pos_fix}"
}

### Define notice logger
function notice() {
   logger 3 "NOTICE" ${COLOR_GREEN} $*
}

### Define warning logger
function warning() {
   logger 2 "WARNING" ${COLOR_YELLOW} $*
}

### Define fatal logger
function fatal() {
   logger 1 "FATAL" ${COLOR_RED} $*
   exit 1
}
###########################################################################

function print_help() {
echo "\
${1:-TiDB cluster install script.}

Usage:
  ./tidb-cluster-install.sh [OPTIONS] [ARG]

Options:
   -u              Username for tidb cluster vms
   -p              Password for tidb cluster vms
   -v              TiDB install package verison
   -d              The numble of pd instances
   -D              The virtual machine ip address prefix of pd, e.g. (10.0.240.)
   -b              The numble of tidb instances
   -B              The virtual machine ip address prefix of tidb
   -k              The numble of tikv instances
   -K              The virtual machine ip address prefix of tikv
   -m              The virtual machine ip address of monitor
   -h              Display the help message
"
}

if [[ $# -eq 0 ]]
then
    print_help
    exit 1
fi

optstring=":u:p:v:d:D:b:B:k:K:m:h"

while getopts "$optstring" opt; do
	case $opt in
		u)
			USERNAME=${OPTARG}
			;;
		p)
			PASSWORD=${OPTARG}
			;;
		v)
			TIDB_VERSION=${OPTARG}
			;;
		d)
			PD_NUMBLES=${OPTARG}
			;;
		D)
			PD_IP_PREFIX=${OPTARG}
			;;
		b)
			TIDB_NUMBLES=${OPTARG}
			;;
		B)
			TIDB_IP_PREFIX=${OPTARG}
			;;
		k)
			TIKV_NUMBLES=${OPTARG}
			;;
		K)
			TIKV_IP_PREFIX=${OPTARG}
			;;
		m)
			MONITOR_IP_ADDR=${OPTARG}
			;;
		h)
			print_help
			exit 1
			;;
		\?)
			fatal "Invalid option: -$OPTARG" >&2
			;;
		:)
			fatal "Option -$OPTARG requires an argument" >&2
			;;
	esac
done

### Initialize the environment
function init_env() {
	yum install -y git epel-release sshpass
	yum install -y python-pip
	pip install ansible==2.4.0
	chown -R ${USERNAME}.${USERNAME} /mnt/resource
}

### Generate ansible's inventory
function generate_inventory() {
	# clear the tmp inventory file
	:>${TMP_INVENTORY}

	# start to generate tidb inventory
	notice "start to generate tidb inventory, nums: ${TIDB_NUMBLES}, ip_prefix: ${TIDB_IP_PREFIX}"
	generate_part_inventory ${TIDB_NUMBLES} ${TIDB_IP_PREFIX} "[tidb_servers]"

	# start to generate tikv inventory
	notice "start to generate tikv inventory, nums: ${TIKV_NUMBLES}, ip_prefix: ${TIKV_IP_PREFIX}"
	generate_part_inventory ${TIKV_NUMBLES} ${TIKV_IP_PREFIX} "[tikv_servers]"

	# start to generate pd inventory
	notice "start to generate pd inventory, nums: ${PD_NUMBLES}, ip_prefix: ${PD_IP_PREFIX}"
	generate_part_inventory ${PD_NUMBLES} ${PD_IP_PREFIX} "[pd_servers]"

	# deploy monitoring on the first pd server
	generate_monitor_inventory

	# start to generate global variables
	notice "start to generate global variables"
	local start_point=`grep -n "\[all:vars\]" ${INVENTORY}|cut -d: -f1`
	local end_point=`cat ${INVENTORY}|wc -l`
	sed -n "${start_point},${end_point}p" ${INVENTORY} >> ${TMP_INVENTORY}

	# start to adjust some variables
	notice "start to adjust some variables"
	sed -i "s/deploy_dir\(.*\)/deploy_dir = \/mnt\/resource\/deploy/g" ${TMP_INVENTORY}
	sed -i "s/ansible_user\(.*\)/ansible_user = ${USERNAME}/g" ${TMP_INVENTORY}

	# modify tidb version
	sed -i "s/tidb_version\(.*\)/tidb_version = ${TIDB_VERSION}/g" ${TMP_INVENTORY}

	# turn off machine disk benchmark
	sed -i "s/machine_benchmark\(.*\)/machine_benchmark = False/g" ${TMP_INVENTORY}

	# turn off the time zone setting and ntpd check
	sed -i "s/set_timezone\(.*\)/set_timezone = False/g" ${TMP_INVENTORY}
	sed -i "s/enable_ntpd\(.*\)/enable_ntpd = False/g" ${TMP_INVENTORY}

	# modify ansible.cfg timeout option
	sed -i "s/timeout\(.*\)/timeout = 30/g" ansible.cfg

	mv ${TMP_INVENTORY} ${INVENTORY}
}

function generate_part_inventory() {
	local vm_nums=$1
	local ip_prefix=$2
	local group_name=$3
	local ip_suffix

	echo "${group_name}" >> ${TMP_INVENTORY}
	for i in `seq 1 ${vm_nums}`
	do
		# TODO: need to be handled when the number of instances is greater than 245
		ip_suffix=$(( i+IP_BASE ))
		echo "${ip_prefix}.${ip_suffix}" >> ${TMP_INVENTORY}
	done
	printf "\n" >>  ${TMP_INVENTORY}
}

function generate_monitor_inventory() {

>> ${TMP_INVENTORY} cat << EOF
[monitoring_servers]
${MONITOR_IP_ADDR}

[grafana_servers]
${MONITOR_IP_ADDR}

[monitored_servers:children]
tidb_servers
tikv_servers
pd_servers

EOF
}

function deploy_tidb_cluster() {
	local ansible_args="-u ${USERNAME} -e ansible_ssh_pass='${PASSWORD}' -e ansible_become_pass='${PASSWORD}'"
	ansible-playbook local_prepare.yml ${ansible_args}
	ansible-playbook bootstrap.yml ${ansible_args}
	ansible-playbook deploy.yml ${ansible_args}
	ansible-playbook start.yml ${ansible_args}
}

init_env

### change workspace
RELATIVE_WORK_DIR=`echo ${TIDB_ANSIBLE}|awk -F'[/.]' '{if($NF=="git")print $(NF-1);else print $NF}'`
[[ -d ${RELATIVE_WORK_DIR} ]] && rm -rf ${RELATIVE_WORK_DIR}
git clone ${TIDB_ANSIBLE}
cd ${RELATIVE_WORK_DIR}
# this is a temporary workaround, when the upstream solve this problem, delete this code
sed -i "s/min_open_fds\(.*\)/min_open_fds: 1000/g" roles/check_config_dynamic/defaults/main.yml

generate_inventory
deploy_tidb_cluster
