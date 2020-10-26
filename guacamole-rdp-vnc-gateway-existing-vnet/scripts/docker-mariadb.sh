#!/bin/sh

# Parameters
IMAGE_NAME="mariadb:10.1"
CONTAINER_NAME="some-mariadb"
GUACAMOLE_IMAGE_NAME="glyptodon/guacamole:latest"
MYSQL_ROOT_PASSWORD="my-secret-pw"
MYSQL_USER="guacamole_user"
MYSQL_DATABASE="guacamole_db"
MYSQL_PASSWORD="burrito-guacamole-extra-1dollar"

# Remove pre-existing containers
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# Pull the latest version of the Docker image
docker pull $IMAGE_NAME

# Check if the MySQL database has been prepared already
if [ ! -e /mnt/data/mysql/mysql ]; then
    # Initial database contents: generate them from the guacamole image
    TMP_SQL_FILE=/mnt/resource/initdb.sql
    rm -rf $TMP_SQL_FILE $TMP_SQL_FILE.tmp
    docker run --rm $GUACAMOLE_IMAGE_NAME /opt/guacamole/bin/initdb.sh --mysql > $TMP_SQL_FILE

    # Prepend database name to SQL query
    echo "USE $MYSQL_DATABASE; " | cat - $TMP_SQL_FILE > $TMP_SQL_FILE.tmp \
        && mv $TMP_SQL_FILE.tmp $TMP_SQL_FILE

    docker run \
        --name $CONTAINER_NAME \
        -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
        -e MYSQL_DATABASE=$MYSQL_DATABASE \
        -e MYSQL_USER=$MYSQL_USER \
        -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
        -v /mnt/data/mysql:/var/lib/mysql \
        -v $TMP_SQL_FILE:/docker-entrypoint-initdb.d/guacamole.sql \
        $IMAGE_NAME
else
    # Start Docker container
    docker run \
        --name $CONTAINER_NAME \
        -v /mnt/data/mysql:/var/lib/mysql \
        $IMAGE_NAME
fi

# Interactive MySQL session
# docker run --rm --link some-mariadb -it mariadb:10.1 mysql -h some-mariadb -u root -pmy-secret-pw
