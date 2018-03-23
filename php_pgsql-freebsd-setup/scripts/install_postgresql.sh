#!/bin/sh

install_postgresql_service() {
	echo "Start installing PostgreSQL..."
	pkg install -y postgresql93-server postgresql93-client
	if [ $? == 0 ];then
		echo 'postgresql_enable="YES"' >> /etc/rc.conf
		echo 'postgresql_data="/stripe/postgres/data"' >> /etc/rc.conf
		chown -R pgsql:pgsql /stripe/	
		su pgsql -c '/usr/local/bin/initdb -D /stripe/postgres/data/'
		echo 'host    all             all             0.0.0.0/0               md5' >> /stripe/postgres/data/pg_hba.conf
		cp ./postgresql.conf /stripe/postgres/data/postgresql.conf
	fi
	echo "Done installing PostgreSQL..."
}

install_pgbouncer_service() {
	echo "Start installing pgbouncer..."
	pkg install -y pgbouncer
	if [ $? == 0 ];then
		echo 'kern.ipc.semmni=512' >> /boot/loader.conf
		echo 'kern.ipc.semmns=1024' >> /boot/loader.conf
		echo 'kern.ipc.semmnu=512' >> /boot/loader.conf

		echo 'pgbouncer_enable="yes"' >> /etc/rc.conf

		sed -i -e '/^[^#]/d' /etc/sysctl.conf
		echo 'kern.ipc.shm_use_phys=1' >> /etc/sysctl.conf
		echo 'kern.ipc.shmmax=6442450944' >> /etc/sysctl.conf
		echo 'kern.ipc.soacceptqueue=4096' >> /etc/sysctl.conf
		echo 'net.inet.tcp.msl=1000' >> /etc/sysctl.conf

		cp ./pgbouncer.ini /usr/local/etc/pgbouncer.ini		
	fi
	echo "Done installing pgbouncer..."
}

setup_datadisks(){
	datadisks=''
	for i in $(seq 2 $(($numofdisks+1)))
		do
			temp=" /dev/da$i"
			datadisks=${datadisks}${temp}
	done

	kldload geom_stripe
	gstripe label -v st0 $datadisks 
	bsdlabel -wB /dev/stripe/st0
	newfs -U /dev/stripe/st0a
	mkdir /stripe
	mount /dev/stripe/st0a /stripe
	echo "/dev/stripe/st0a /stripe ufs rw 2 2"  >> /etc/fstab
	echo 'geom_stripe_load="YES"' >> /boot/loader.conf
	mkdir -p /stripe/postgres/data
}

env ASSUME_ALWAYS_YES=YES pkg bootstrap
pkg update

numofdisks=$1
setup_datadisks

install_pgbouncer_service

service pgbouncer restart

install_postgresql_service

echo "/sbin/reboot" | at + 1 minute

