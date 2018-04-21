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
# This scripts installs, configures and secures a MariaDB server
#

MYSQL_USER=$1
MYSQL_PASSWORD=$2
LOG_FILE=$3

SLEEP_INTERVAL=10

log() {
  echo "$(date): $*" >> "${LOG_FILE}"
}

#
# Prepare disk for MariaDB server
#

log "Preparing disk for MariaDB server ..."

bash ./prepare-mysql-disks.sh >> "${LOG_FILE}" 2>&1

status=$?
if [ ${status} -ne 0 ]; then
  log "Preparing disk for MariaDB server ... Failed" & exit status;
fi

log "Preparing disk for MariaDB server ... Successful"


#
# Install MariaDB sever and configure it
#

log "Installing MariaDB server packages ..."

n=0
until [ ${n} -ge 5 ]
do
    sudo sudo yum install -y mariadb-server >> "${LOG_FILE}" 2>&1 && break
    n=$((n+1))
    sleep ${SLEEP_INTERVAL}
done
if [ ${n} -ge 5 ]; then
  log "Installing MariaDB server packages ... Failed" & exit 1;
fi

log "Installing MariaDB server packages ... Successful"

log "Updating MariaDB server configurations ..."

sudo systemctl stop mariadb

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
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
EOF

log "Updating MariaDB server configurations ... Successful"


#
# Start MariaDB server and make sure it starts properly
#

log "Starting MariaDB server ..."

sudo systemctl enable mariadb
sudo systemctl start mariadb

# Wait till MariaDB server starts
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
  log "Starting MariaDB server ... Failed"
  exit 1
fi

log "Starting MariaDB server ... Successful"


#
# Create User with proper permission for to access MariaDB server
#

log "Creating User ${MYSQL_USER} for MySQL server ..."

mysql -u root -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD'"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'localhost' WITH GRANT OPTION"

mysql -u root -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION"

log "Creating User ${MYSQL_USER} for MySQL server ... Successful"


#
# Secure MariaDB server
#

log "Securing MariaDB server ..."

SECURE_MARIADB=$(expect -c "
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

echo "$SECURE_MARIADB" >> "${LOG_FILE}" 2>&1

log "Securing MariaDB server ... Successful"

exit 0
