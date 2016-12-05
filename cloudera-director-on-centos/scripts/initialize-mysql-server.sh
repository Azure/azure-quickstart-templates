#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This scripts installs, configures and secures a MySQL server
#

MYSQL_USER=$1
MYSQL_PASSWORD=$2
LOG_FILE=$3

SLEEP_INTERVAL=10

log() {
  echo "$(date): $*" >> "${LOG_FILE}"
}

#
# Prepare disk for MySQL server
#

log "Preparing disk for MySQL server ..."

bash ./prepare-mysql-disks.sh >> "${LOG_FILE}" 2>&1

status=$?
if [ ${status} -ne 0 ]; then
  log "Preparing disk for MySQL server ... Failed" & exit status;
fi

log "Preparing disk for MySQL server ... Successful"


#
# Install MySQL sever and configure it
#

log "Installing MySQL server packages ..."

n=0
until [ ${n} -ge 5 ]
do
    sudo sudo yum install -y mysql-server >> "${LOG_FILE}" 2>&1 && break
    n=$((n+1))
    sleep ${SLEEP_INTERVAL}
done
if [ ${n} -ge 5 ]; then
  log "Installing MySQL server packages ... Failed" & exit 1;
fi

log "Installing MySQL server packages ... Successful"

log "Updating MySQL server configurations ..."

sudo service mysqld stop

sudo cat > /etc/my.cnf <<EOF
[mysqld]
transaction-isolation = READ-COMMITTED
# Disabling symbolic-links is recommended to prevent assorted security risks;
# to do so, uncomment this line:
# symbolic-links = 0

key_buffer = 16M
key_buffer_size = 32M
max_allowed_packet = 32M
thread_stack = 256K
thread_cache_size = 64
query_cache_limit = 8M
query_cache_size = 64M
query_cache_type = 1

max_connections = 550
#expire_logs_days = 10
#max_binlog_size = 100M

#log_bin should be on a disk with enough free space. Replace '/var/lib/mysql/mysql_binary_log' with an appropriate path for your system
#and chown the specified folder to the mysql user.
log_bin=/var/lib/mysql/mysql_binary_log

# For MySQL version 5.1.8 or later. Comment out binlog_format for older versions.
binlog_format = mixed

read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 4G
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_log_file_size = 512M

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

sql_mode=STRICT_ALL_TABLES
EOF

log "Updating MySQL server configurations ... Successful"


#
# Start MySQL server and make sure it starts properly
#

log "Starting MySQL server ..."

sudo /sbin/chkconfig mysqld on
sudo service mysqld start

# Wait till MySQL server starts
i=0
until [ ${i} -ge 5 ]
do
  i=$((i+1))
  mysql -u root -e "SHOW DATABASES"
  if [ $? -eq 0 ]; then
    break;
  fi
  sleep ${SLEEP_INTERVAL}
done

if [ ${i} -ge 5 ]; then
  log "Starting MySQL server ... Failed"
  exit 1
fi

log "Starting MySQL server ... Successful"


#
# Create User with proper permission for to access MySQL server
#

log "Creating User ${MYSQL_USER} for MySQL server ..."

mysql -u root -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD'"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'localhost' WITH GRANT OPTION"

mysql -u root -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION"

log "Creating User ${MYSQL_USER} for MySQL server ... Successful"


#
# Secure MySQL server
#

log "Securing MySQL server ..."

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL" >> "${LOG_FILE}" 2>&1

log "Securing MySQL server ... Successful"

exit 0
