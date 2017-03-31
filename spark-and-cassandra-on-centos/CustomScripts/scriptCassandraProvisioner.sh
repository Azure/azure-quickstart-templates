#!/bin/bash

install_dependencies()
{
	echo "Installing Java 1.8 (openjdk)"
	yum -y install java-1.8.0-openjdk
}

install_cassandra()
{
	echo "Adding YUM Repo for DataStax"
	cd /etc/yum.repos.d/
	touch datastax.repo

	echo '[datastax-ddc]' >> datastax.repo
	echo 'name = DataStax Repo for Apache Cassandra' >> datastax.repo
	echo 'baseurl = http://rpm.datastax.com/datastax-ddc/3.2' >> datastax.repo
	echo 'enabled = 1' >> datastax.repo
	echo 'gpgcheck = 0' >> datastax.repo

	echo "Installing datastax-ddc"
	yum -y -q install datastax-ddc

	echo "Ensuring Cassandra starts on boot"
	/sbin/chkconfig --add cassandra
	/sbin/chkconfig cassandra on

	echo "Starting Cassandra"
	systemctl start cassandra
}

ensure_system_updated()
{
	yum makecache fast

	echo "Updating Operating System"
	yum -y -q update
}

install_dependencies
install_cassandra
ensure_system_updated