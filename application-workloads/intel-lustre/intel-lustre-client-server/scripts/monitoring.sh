#!/bin/bash

# ./monitoring_configure.sh -n MGS -i 1 -d 4 -m 10.1.0.4 -l 10.1.0.4 -f scratch -g 10.1.0.5 -h 10.1.0.6
# ./monitoring_configure.sh -n MDS -i 1 -d 4 -m 10.1.0.4 -l 10.1.0.5 -f scratch -g 10.1.0.5 -h 10.1.0.6
# ./monitoring_configure.sh -n OSS -i 1 -d 4 -m 10.1.0.4 -l 10.1.0.6 -f scratch -g 10.1.0.5 -h 10.1.0.6

log()
{
	echo "$1"
	logger "$1"
}

# Initialize local variables
# Get today's date into YYYYMMDD format
NOW=$(date +"%Y%m%d%H%M")

# Get command line parameters
while getopts "n:i:d:m:l:f:g:h:" opt; do
	log "Option $opt set with value ${OPTARG})"
	case "$opt" in
	n)	NODETYPE=$OPTARG
		;;
	i)	NODEINDEX=$OPTARG
		;;
	d)	NODETYPEDISKCOUNT=$OPTARG
		;;
	m)	MGSIP=$OPTARG
		;;
	l)	LOCALIP=$OPTARG
		;;
	f)	FILESYSTEMNAME=$OPTARG
		;;
	g)	MDSIP0=$OPTARG
		;;
	h)	OSSIP0=$OPTARG
		;;
	esac
done

fatal() {
    msg=${1:-"Unknown Error"}
    log "FATAL ERROR: $msg"
    exit 1
}

# You must be root to run this script
if [ "${UID}" -ne 0 ]; then
    fatal "You must be root to run this script."
fi

if [[ -z ${NODETYPE} ]]; then
    fatal "No node type specified, can't proceed."
fi

if [[ -z ${NODEINDEX} ]]; then
    fatal "No node index specified, can't proceed."
fi

if [[ -z ${NODETYPEDISKCOUNT} ]]; then
    fatal "No node type disk count specified, can't proceed."
fi

if [[ -z ${MGSIP} ]]; then
    fatal "No MGS IP specified, can't proceed."
fi

if [[ -z ${LOCALIP} ]]; then
    fatal "No local IP specified, can't proceed."
fi

if [[ -z ${FILESYSTEMNAME} ]]; then
    fatal "No filesystem name specified, can't proceed."
fi

if [[ -z ${MDSIP0} ]]; then
    fatal "No MDSIP0 specified, can't proceed."
fi

if [[ -z ${OSSIP0} ]]; then
    fatal "No OSSIP0 specified, can't proceed."
fi

log "MONITORING CONFIGURE: NOW=$NOW NODETYPE=$NODETYPE NODEINDEX=$NODEINDEX NODETYPEDISKCOUNT=$NODETYPEDISKCOUNT MGSIP=$MGSIP LOCALIP=$LOCALIP FILESYSTEMNAME=$FILESYSTEMNAME MDSIP0=$MDSIP0 OSSIP0=$OSSIP0"

add_to_fstab() {
	device="${1}"
	mount_point="${2}"
	filesystem_type="${3}"

	if grep -q "$device" /etc/fstab
	then
		log "Not adding $device to /etc/fstab (it's  already there)"
	else
		line="$device $mount_point $filesystem_type defaults 0 0"
		log $line
		echo -e "${line}" >> /etc/fstab
	fi
}

setup_ganglia_collector() {

	# Device /dev/sdd on MGS node is reserved for the Ganglia round-robin database files
	device="/dev/sdd"
	device_label="GANGLIA_RRDS"

	# Format volume (if necessary) as ext4 (i.e. not lustre)
	mount_ganglia="/mnt/ganglia/"
	mount_rrds="/mnt/ganglia/rrds"

	# Check device label
	label=$(blkid -c/dev/null -o value -s LABEL $device)

	if [ -z "$label" ];
	then
		# Format the device ext4
		log "Formatting $device with label $device_label..."
		mke2fs -j -L "$device_label" $device
	else
		log "Device $device is already formatted with label $label"
	fi

	# Store ganglia RRDs here in /mnt/ganglia/rrds
	mkdir -p $mount_ganglia

	# Add to /etc/fstab so that mount persists across reboots
	add_to_fstab $device $mount_ganglia "ext4"

	# Mount
	mount -a
	log "Mounted $device with label $device_label as $mount_ganglia"

	mkdir -p $mount_rrds
	chown ganglia.ganglia $mount_rrds

	line="rrd_rootdir $mount_rrds"
	if grep -q "$line" /etc/ganglia/gmetad.conf
	then
		log "Not adding $line to /etc/ganglia/gmetad.conf (it's already there)"
	else
		log "${line}"
		echo -e  "${line}" >> /etc/ganglia/gmetad.conf
	fi

	# Point ganglia_web to the proper RRDs location
	if grep -q "$mount_rrds" /etc/ganglia/conf.php
	then
		log "Not adding $mount_rrds to /etc/ganglia/conf.php (it's already there)"
	else
		# Use , instead of / in the sed command since / is used in the $mount_rrds variable
		sed -i "s,<?php.*$,<?php\n\$conf['rrds'] = \"$mount_rrds\";," /etc/ganglia/conf.php
	fi
}

setup_ganglia() {
	master_ip="${1}"
	cluster_name="${2}"
	is_collector="${3}"

	# Configure gmond on the local node
	# Multicast is disabled and unicast will be used to send metrics to master_ip

	# Comment out lines that start with "mcast_join"" or "bind"
	sed -i '/mcast_join/s/^/#/' /etc/ganglia/gmond.conf
	sed -i '/bind/s/^/#/' /etc/ganglia/gmond.conf

	# Replace substrings for cluster name, send interval, and udp send channel host
	sed -i "s/name\s*=\s*\"unspecified\"/name = \"$cluster_name\"/" /etc/ganglia/gmond.conf
	sed -i "s/owner\s*=\s*\"unspecified\"/owner = \"$cluster_name\"/" /etc/ganglia/gmond.conf
	sed -i "s/send_metadata_interval\s*=\s*0/send_metadata_interval = 10/" /etc/ganglia/gmond.conf
	sed -i "s/udp_send_channel\s*{.*$/udp_send_channel {\n host = $master_ip/" /etc/ganglia/gmond.conf

	# Disable modules (by appending -disabled to its config file name) that result in many /var/log/messages errors
	if [ -e /etc/ganglia/conf.d/netstats.pyconf ]; then
		mv /etc/ganglia/conf.d/netstats.pyconf /etc/ganglia/conf.d/netstats.pyconf-disabled
	fi

	if [ -e /etc/ganglia/conf.d/diskstat.pyconf ]; then
		mv /etc/ganglia/conf.d/diskstat.pyconf /etc/ganglia/conf.d/diskstat.pyconf-disabled
	fi

	service gmond restart
	chkconfig gmond on

	# Allow gmond service time to start before starting the gmetad
	sleep 10

	if [ "$is_collector" = true ] ; then
		service gmetad restart
		chkconfig gmetad on
	fi
}

setup_ganglia_web() {
	# Comment out the Deny from all line
	sed -i '/Deny from all/s/^/#/' /etc/httpd/conf.d/ganglia.conf

	if grep -q "strip_domainname" /etc/ganglia/conf.php
	then
		log "Not adding strip_domainname to /etc/ganglia/conf.php (it's already there)"
	else
		sed -i "s/<?php.*$/<?php\n\$conf['strip_domainname'] = true;/" /etc/ganglia/conf.php
	fi

	service httpd restart
	chkconfig httpd on
}

ganglia_gmetad_add_source() {
	ip_to_poll="${1}"
	cluster_name="${2}"

	line="gridname \"$FILESYSTEMNAME\""
	if grep -q "$line" /etc/ganglia/gmetad.conf
	then
		log "Not adding $line to /etc/ganglia/gmetad.conf (it's already there)"
	else
		log "${line}"
		echo -e  "${line}" >> /etc/ganglia/gmetad.conf
	fi

	line="data_source \"$cluster_name\" $ip_to_poll"
	if grep -q "$line" /etc/ganglia/gmetad.conf
	then
		log "Not adding $line to /etc/ganglia/gmetad.conf (it's already there)"
	else
		log "${line}"
		echo -e  "${line}" >> /etc/ganglia/gmetad.conf

		service gmetad restart
		chkconfig gmetad on
	fi
}

setup_lmt_collector() {
	mgs_ip="${MGSIP}"

	# LMT collector is the MGS node (master LMT server)
	line="cerebrod_speak_message_config $mgs_ip"
	if grep -q "$line" /etc/cerebro.conf
	then
		log "Not adding $line to /etc/cerebro.conf (it's already there)"
	else
		log "${line}"
		echo -e  "${line}" >> /etc/cerebro.conf

		line="cerebrod_listen_message_config $mgs_ip"
		log "${line}"
		echo -e "${line}" >> /etc/cerebro.conf

		service cerebrod restart
		chkconfig cerebrod on
	fi
}

setup_lmt_agent() {
	mgs_ip="${1}"

	# LMT agent is on MDS and OSS nodes
	line="cerebrod_speak_message_config $mgs_ip"
	if grep -q "$line" /etc/cerebro.conf
	then
		log "Not adding $line to /etc/cerebro.conf (it's already there)"
	else
		log "${line}"
		echo -e  "${line}" >> /etc/cerebro.conf

		service cerebrod restart
		chkconfig cerebrod on
	fi
}

configure_mgs() {
	log "Configure monitoring on MGS"

	setup_ganglia_collector
	setup_ganglia $MGSIP "MGS" false
	setup_ganglia_web
	ganglia_gmetad_add_source $MDSIP0 "MDS"
	ganglia_gmetad_add_source $OSSIP0 "OSS"

	setup_lmt_collector $MGSIP
}

configure_mds() {
	log "Configuring monitoring on MDS"

	setup_ganglia $MDSIP0 "MDS" false

	setup_lmt_agent $MGSIP
}

configure_oss() {
	log "Configure monitoring on OSS"

	setup_ganglia $OSSIP0 "OSS" false

	setup_lmt_agent $MGSIP
}

# Make a copy of the original files
log "Backup up previous versions of the configuration files with $NOW and .backup extension"
cp /etc/httpd/conf.d/ganglia.conf /etc/httpd/conf.d/ganglia.conf_$NOW.backup
cp /etc/ganglia/conf.php /etc/ganglia/conf.php_$NOW.backup
cp /etc/ganglia/gmetad.conf /etc/ganglia/gmetad.conf_$NOW.backup
cp /etc/cerebro.conf /etc/cerebro.conf_$NOW.backup

if [ "$NODETYPE" == "MGS" ]; then
	configure_mgs
fi

if [ "$NODETYPE" == "MDS" ]; then
	configure_mds
fi

if [ "$NODETYPE" == "OSS" ]; then
	configure_oss
fi
