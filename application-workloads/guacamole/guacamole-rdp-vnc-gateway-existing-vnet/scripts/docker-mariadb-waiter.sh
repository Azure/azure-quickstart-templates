#!/bin/sh

# This script waits for MariaDB to be ready to accept connections

# Parameters
IMAGE_NAME="mariadb:10.1"
CONTAINER_NAME="some-mariadb"

# Wait at least 60 seconds
sleep 60

# Keep polling database until ready
while ! docker run --rm --link $CONTAINER_NAME $IMAGE_NAME mysqladmin ping -h $CONTAINER_NAME --silent; do
    sleep 5
done

# Wait 5 more seconds before sending the green light
sleep 5
