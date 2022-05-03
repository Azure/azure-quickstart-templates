#!/bin/bash
sudo apt-get update
#install the necessary tools
sudo apt-get install gcc make libreadline6-dev zlib1g-dev -y
#download postgresql source code
wget https://ftp.postgresql.org/pub/source/v9.3.5/postgresql-9.3.5.tar.bz2 -P /tmp 2>/dev/null
cd /tmp
tar jxvf postgresql-9.3.5.tar.bz2
cd postgresql-9.3.5

#install postgresql
./configure --prefix=/opt/postgresql-9.3.5
sudo make install-world 2> /dev/null

#create postgres user for postgresql
sudo ln -s /opt/postgresql-9.3.5 /opt/pgsql
sudo mkdir -p /opt/pgsql_data
sudo useradd -m postgres
sudo chown -R postgres.postgres /opt/pgsql_data

#/tmp/postgres.sh contains the steps of setup the user postgres' environment, initialize the database
sudo touch /home/postgres/.bash_profile
sudo chown postgres.postgres /home/postgres/.bash_profile
cat >> /tmp/postgres.sh <<EOF
cat >> /home/postgres/.bash_profile <<EOFF
export PGPORT=1999
export PGDATA=/opt/pgsql_data
export LANG=en_US.utf8
export PGHOME=/opt/pgsql
export PATH=\\\$PATH:\\\$PGHOME/bin
export MANPATH=\\\$MANPATH:\\\$PGHOME/share/man
export DATA=\`date +"%Y%m%d%H%M"\`
export PGUSER=postgres
alias rm='rm -i'
alias ll='ls -lh'
EOFF
source /home/postgres/.bash_profile

#initialize the database
initdb -D \$PGDATA -E UTF8 --locale=C -U postgres 2> /dev/null
EOF

#su to postgres to execute /tmp/postgres.sh
sudo su - postgres -s /bin/bash /tmp/postgres.sh
#instead we can use sudo su - postgres -c "initdb -D \$PGDATA -E UTF8 --locale=C -U postgres"

#postgresql configuration
cd /tmp/postgresql-9.3.5/contrib/start-scripts
sudo cp linux /etc/init.d/postgresql
sudo sed -i '32s#usr/local#opt#' /etc/init.d/postgresql
sudo sed -i '35s#usr/local/pgsql/data#opt/pgsql_data#' /etc/init.d/postgresql
sudo chmod +x /etc/init.d/postgresql

#start postgresql
sudo /etc/init.d/postgresql start

