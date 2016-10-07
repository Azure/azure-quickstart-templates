#sudo ./install-apigee.sh apigeetrial apigeetrial@apigee.com secret apigeetrial.apigee.net Medium apigeetrial.apigee.net 10.0.0.1:10.0.0.2:10.0.0.3:10.0.0.4:10.0.0.5 $LICENSE $SSH


echo 'executing the install script' >>/tmp/armscript.log

BASE_GIT_URL='https://raw.githubusercontent.com/apigee/microsoft/master/apigee-edge-arm-template/'

USER_NAME=$1
ORG_NAME=$1
APIGEE_ADMIN_EMAIL=$2
APW=$3
VHOST_ALIAS=$4
VHOST_NAME='default'
VHOST_PORT_PROD='9001'
VHOST_PORT_TEST='9002'
EDGE_VERSION='4.15.07.03'





DEPLOYMENT_TOPOLOGY=$5
LB_IP_ALIAS=$6

HOST_NAMES=$7

LICENSE_TEXT=$8
SSH_KEY=$9

LICENSE_TEXT=`echo ${LICENSE_TEXT} | base64 --decode`
SSH_KEY=`echo ${SSH_KEY} | base64 --decode`

echo 'script execution started at:'>>/tmp/armscript.log
echo $(date)>>/tmp/armscript.log

echo "args: $*" >>/tmp/armscript.log
echo 'Inititalized variables, ' $VHOST_ALIAS, $EDGE_VERSION, $DEPLOYMENT_TOPOLOGY, $LB_IP_ALIAS, "Hosts: " $HOST_NAMES  >>/tmp/armscript.log


cd /tmp/apigee
echo 'in tmp/apigee folder' >> /tmp/armscript.log

rm -rf license.txt

#Replace space with new lines before writing to file
echo $LICENSE_TEXT | tr " " "\n"> license.txt
echo $LICENSE_TEXT | tr " " "\n"> ../license.txt

echo $SSH_KEY | tr " " "\n"> ssh_key.pem


#This is all because the spaces in the bellow lines are also converted to new lines!
echo '-----BEGIN RSA PRIVATE KEY-----' > tmp.pem
sed '$d' ssh_key.pem | sed '$d' | sed '$d'| sed '$d'| tail -n+5  >> tmp.pem
echo '-----END RSA PRIVATE KEY-----'>>tmp.pem
rm -rf ssh_key.pem
mv tmp.pem ssh_key.pem
#chown $USER_NAME:$USER_NAME ssh_key.pem
chmod 600 ssh_key.pem
cp -rf ssh_key.pem ../ssh_key.pem
#chown $USER_NAME:$USER_NAME ../ssh_key.pem
chmod 600 ../ssh_key.pem


eval `ssh-agent -s`
ssh-add ssh_key.pem
echo "ssh key added" >armscript.log


if [ "$DEPLOYMENT_TOPOLOGY" == "XSmall" ]; then

	# Relaxing the security settings.

	setenforce 0 >> /tmp/setenforce.out
	cat /etc/selinux/config > /tmp/beforeSelinux.out
	sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true
	cat /etc/selinux/config > /tmp/afterSeLinux.out

	/etc/init.d/iptables save
	/etc/init.d/iptables stop
	chkconfig iptables off

	echo "deploying a 1 node setup" >> /tmp/armscript.log
	cd /tmp/apigee
	


	sed -i.bak s/ADMIN_EMAIL=/ADMIN_EMAIL="${APIGEE_ADMIN_EMAIL}"/g opdk.conf
	sed -i.bak s/APIGEE_ADMINPW=/APIGEE_ADMINPW="${APW}"/g opdk.conf
	sed -i.bak s/APIGEE_LDAPPW=/APIGEE_LDAPPW="${APW}"/g opdk.conf

	echo 'sed commands done' >> /tmp/armscript.log
	cp -fr opdk.conf /tmp/opdk.conf

	unzip apigee-edge-${EDGE_VERSION}.zip
	echo 'unzip done' >> /tmp/armscript.log

	cd apigee-edge-${EDGE_VERSION}
	echo 'in edge folder, installing' >> /tmp/armscript.log
	./apigee-install.sh -j /usr/java/default -r /opt -d /opt

	echo 'installing unpacked edge binaries' >> /tmp/armscript.log
	/opt/apigee4/share/installer/apigee-setup.sh -p aio -f /tmp/opdk.conf



	#/opt/apigee4/share/installer/apigee-setup.sh -p ds -f /tmp/opdk.conf

	#/opt/apigee4/share/installer/apigee-setup.sh -p rmp -f /tmp/opdk.conf

	#/opt/apigee4/share/installer/apigee-setup.sh -p sax -f /tmp/opdk.conf

	
else
	TOPOLOGY_TYPE=""
	#arr=$(echo $IN | tr ";" "\n")
	

	# This sets the delimiter for the array as ':'
	IFS=:
	hosts_ary=($HOST_NAMES)
	hosts_ary_length=${#hosts_ary[@]}
	echo $hosts_ary_length  >>/tmp/armscript.log

	cd /tmp/apigee/
	curl -o /tmp/apigee/apigee_install_scripts.zip "${BASE_GIT_URL}/src/apigee_install_scripts.zip"
	
	#This will override the required install scripts. Think of this as a patch on the install scripts
	unzip -qo apigee_install_scripts.zip
	

	if [ "$DEPLOYMENT_TOPOLOGY" == "Medium"  ]; then
		TOPOLOGY_TYPE=EDGE_5node
		if [ "$hosts_ary_length" -lt 5 ]; then
			echo "Not enough hosts defined: " $DEPLOYMENT_TOPOLOGY >> /tmp/armscript.log
			exit 400
		fi
		TOPOLOGY_TYPE=EDGE_5node
		cp -rf apigee_install_scripts/common/source/instance_EDGE_5node.json apigee_install_scripts/common/source/instance.json
		cp -rf apigee_install_scripts/common/source/host2_EDGE_5node apigee_install_scripts/common/source/host2 
		cp -rf apigee_install_scripts/common/source/hosts_EDGE_5node apigee_install_scripts/common/source/hosts 
	elif [ "$DEPLOYMENT_TOPOLOGY" == "Large"  ]; then
		if [ "$hosts_ary_length" -lt "9" ]; then
			echo "Not enough hosts defined: " $DEPLOYMENT_TOPOLOGY >> /tmp/armscript.log
			exit 400
		fi
		cp -rf apigee_install_scripts/common/source/instance_EDGE_9node.json apigee_install_scripts/common/source/instance.json 
		cp -rf apigee_install_scripts/common/source/host2_EDGE_9node apigee_install_scripts/common/source/host2 
		cp -rf apigee_install_scripts/common/source/hosts_EDGE_9node apigee_install_scripts/common/source/hosts 
		TOPOLOGY_TYPE=EDGE_9node
	else
		echo "unsupported deployment: " $DEPLOYMENT_TOPOLOGY >> /tmp/armscript.log
		exit 400
	fi
	echo "deployment topology: " $TOPOLOGY_TYPE >> /tmp/armscript.log


	c=1
	for i in "${hosts_ary[@]}"
	do
		if [[ ${i} != 'empty' ]]; then
			key='HOST'$c'_INTERNALIP'
			echo $key  >>/tmp/armscript.log
			cd /tmp/apigee/apigee_install_scripts/common/source

			sed -i.bak s/${key}/${i}/g hosts
			sed -i.bak s/${key}/${i}/g host2
			sed -i.bak s/${key}/${i}/g instance.json
			echo $i  >>/tmp/armscript.log

			((c++))
		fi
	done

	cd /tmp/apigee/apigee_install_scripts/common/vars
	sed -i.bak s/APIGEE_ADMIN_EMAIL/$APIGEE_ADMIN_EMAIL/g global.yml
	sed -i.bak s/APIGEE_ADMIN_PASSWORD/$APW/g global.yml
	sed -i.bak s/APIGEE_LDAP_PASSWORD/$APW/g global.yml






	#cd /tmp/apigee/apigee_install_scripts/prerpm_install/playbooks
	cd /tmp
	automation_path='/tmp/apigee/apigee_install_scripts/prerpm_install'
	hosts_path='/tmp/apigee/apigee_install_scripts/common/source'
	host2_path='/tmp/apigee/apigee_install_scripts/common/source'
	#WORKSPACE='/tmp/apigee/apigee_install_scripts/prerpm_install/playbooks'
	key_path='/tmp/ssh_key.pem'
	#key1_path='/tmp/ssh_key1.pem'
	mp_pod_name='gateway'
	resource_path='/tmp/apigee'
	smtp_conf=n

	topology_type=$TOPOLOGY_TYPE
	login_user=$USER_NAME

	# cp -fr $key_path $key1_path
	# chown $USER_NAME:$USER_NAME $key1_path
	# chmod 600 $key1_path



	export ANSIBLE_HOST_KEY_CHECKING=False
	echo 'Path variable, before setting it for ansible- $PATH'
	export PATH=/usr/local/bin:/tmp/apigee/Python-2.7.6:$PATH
	echo 'Path variable, after setting it for ansible- $PATH'
	#cp /tmp/apigee/apigee-edge-4.15.07.03.zip /tmp

	echo "This is right before ansible-playbook"  >>/tmp/armscript.log
	PARAMS="key_pair=new-opdk topology_type=${topology_type} installation_type=$installation_type workspace=${WORKSPACE} smtp_conf=${smtp_conf}  login_user=${login_user} package1_name=${installer}  jdk_version=${java_version} pem_key_path=$key_path mp_pod_name=${mp_pod_name} res_ouput_directory=$resource_path login_user=${login_user} file_system=$filesystem  disk_space=$disk_space apigee_repo_username=${apigee_repo_username} apigee_repo_password=${apigee_repo_password} apigee_stage=${apigee_stage} apigee_repo_url=${apigee_repo_url}"


	/usr/local/bin/ansible-playbook -i ${hosts_path}/hosts  ${automation_path}/playbooks/update-hostnamei.yml -M ${automation_path}/playbooks  -u ${login_user} -e "${PARAMS}" --private-key ${key_path} -vvvv >>/tmp/ansible_output.log
	echo "Host Names updated"  >>/tmp/ansible_output.log
	# /usr/local/bin/ansible-playbook -i ${hosts_path}/hosts  ${automation_path}/playbooks/update_security_config.yml -M ${automation_path}/playbooks  -u ${login_user} -e "${PARAMS}" --private-key ${key_path} -vvvv >>/tmp/ansible_output.log
	# echo "Security Settings updated"  >>/tmp/ansible_output.log
	
	/usr/local/bin/ansible-playbook -i ${hosts_path}/hosts  ${automation_path}/playbooks/mount_disk_azure.yml -M ${automation_path}/playbooks  -u ${login_user} -e "${PARAMS}" --private-key ${key_path} -vvvv >>/tmp/ansible_output.log
	echo "Disks Mounted"  >>/tmp/ansible_output.log
	/usr/local/bin/ansible-playbook -i ${hosts_path}/hosts  ${automation_path}/playbooks/generate_silent_config.yml -M ${automation_path}/playbooks  -u ${login_user} -e "${PARAMS}" --private-key ${key_path} -vvvv >>/tmp/ansible_output.log


	#sudo  path=$path topology_type=$topology_type automation_path=$automation_path hosts_path=$hosts_path login_user=$login_user key_path=$key_path mp_pod_name=$mp_pod_name WORKSPACE=$WORKSPACE resource_path=$resource_path smtp_conf=$smtp_conf res_ouput_directory=$resource_path -H -u apigeetrial bash -c 'export ANSIBLE_HOST_KEY_CHECKING=False; /usr/local/bin/ansible-playbook -i ${hosts_path}/hosts  ${automation_path}/playbooks/generate_silent_config.yml -M ${automation_path}/playbooks  -u ${login_user} -e "automation_path=$automation_path hosts_path=$hosts_path login_user=$login_user key_path=$key1_path mp_pod_name=$mp_pod_name WORKSPACE=$WORKSPACE resource_path=$resource_path smtp_conf=$smtp_conf res_ouput_directory=$resource_path topology_type=$topology_type " --private-key ${key1_path} -vvvv >>/tmp/ansible1_output.log ' 


	echo "Silent Config File generated and puhsed"  >>/tmp/ansible_output.log
	/usr/local/bin/ansible-playbook -i ${hosts_path}/hosts  ${automation_path}/playbooks/installation_setup.yml -M ${automation_path}/playbooks  -u ${login_user}  -e "${PARAMS}" --private-key ${key_path} -vvvv >>/tmp/ansible_output.log
	echo "Installation set up done. Installation will start"  >>/tmp/ansible_output.log
	/usr/local/bin/ansible-playbook -i ${host2_path}/host2  ${automation_path}/playbooks/install_apigee_multinode.yml -M ${automation_path}/playbooks  -u ${login_user}  -e "${PARAMS}" --private-key ${key_path} -vvvv >>/tmp/ansible_output.log
	echo "Apigee installed"  >>/tmp/ansible_output.log
	/usr/local/bin/ansible-playbook -i ${host2_path}/host2  ${automation_path}/playbooks/postgres_master_slave_conf.yml -M ${automation_path}/playbooks -u ${login_user} -e "${PARAMS}" --private-key ${key_path} -vvvv >>/tmp/ansible_output.log
	echo "Postgres Master-Slave setup done"  >>/tmp/ansible_output.log
	/usr/local/bin/ansible-playbook -i ${host2_path}/hosts  ${automation_path}/playbooks/remove_silent_config.yml -M ${automation_path}/playbooks -u ${login_user} -e "${PARAMS}" --private-key ${key_path} -vvvv >>/tmp/ansible_output.log
	echo "Removed Silent Config File"  >>/tmp/ansible_output.log

	echo "Ansible Scripts Executed"  >>/tmp/armscript.log

	VHOST_ALIAS=$LB_IP_ALIAS



fi

echo "removing the apigee installation folders" >>/tmp/armscript.log

# rm -rf /tmp/apigee/apigee_install_scripts
# rm -rf /tmp/license.txt
# rm -rf /tmp/apigee/license.txt
# rm -rf /tmp/ssh_key.pem
# rm -rf /tmp/apigee/ssh_key.pem
#rm -rf /tmp/template_silent.conf
#rm -rf /tmp/apigee/template_silent.conf
#rm -rf /tmp/apigee/opdk.conf
#rm -rf /tmp/opdk.conf

#update the setup-org
echo y| cp -fr /tmp/apigee/setup-org.sh /opt/apigee4/bin/setup-org.sh
echo y | /opt/apigee4/bin/setup-org.sh ${APIGEE_ADMIN_EMAIL} ${APW} ${ORG_NAME} 'test' ${VHOST_NAME} ${VHOST_PORT_TEST} ${VHOST_ALIAS} >>/tmp/armscript.log
echo y| /opt/apigee4/bin/add-env.sh -o ${ORG_NAME} -P "${APW}" -A -e "prod" -v "${VHOST_NAME}" -p ${VHOST_PORT_PROD} -a "${VHOST_ALIAS}" >>/tmp/armscript.log

echo 'script execution ended at:'>>/tmp/armscript.log
echo $(date)>>/tmp/armscript.log
