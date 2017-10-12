#!/bin/sh -ex

#configuring pg_hba
PG_HBA_CONF=/etc/postgresql/9.4/main/pg_hba.conf
POSTGRES_CONF=/etc/postgresql/9.4/main/postgresql.conf


sed -i "s|.*listen_addresses.*=.*|listen_addresses='*'|" $POSTGRES_CONF
sed -i "s|.*local.* replication .* postgres .*|local    replication     postgres        trust|" $PG_HBA_CONF
sed -i "s|.*host.* replication .* postgres .*127.0.0.1/32.*|host    replication     postgres    127.0.0.1/32    trust|" $PG_HBA_CONF

if [ "$(cat /etc/postgresql/9.4/main/pg_hba.conf | grep $1)" = "" ]; then
    echo "host    all     postgres    $1    trust" >> $PG_HBA_CONF
    echo "host    replication     postgres    $1    trust" >> $PG_HBA_CONF
fi

service postgresql restart

echo "done!"