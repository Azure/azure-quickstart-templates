# We need four params: (1) PASSWORD (2) MASTERFQDN (3) MASTERPRIVATEIP (4) SLEEP

echo $(date) " - Starting Script"

PASSWORD=$1
MASTERFQDN=$2
MASTERPRIVATEIP=$3
SLEEP=$4

# Implement delay timer to stagger joining of Controller replicas to cluster

echo $(date) "Sleeping for $SLEEP"
sleep $SLEEP

INTERLOCK_CONFIG='
ListenAddr = ":8080"
DockerURL = "'$MASTERPRIVATEIP':2376"
TLSCACert = "/certs/ca.pem"
TLSCert = "/certs/cert.pem"
TLSKey = "/certs/key.pem"
PollInterval = "2s"
[[Extensions]]
Name = "nginx"
ConfigPath = "/etc/nginx/nginx.conf"
PidPath = "/etc/nginx/nginx.pid"
MaxConn = 1024
Port = 80
SSLCertPath = ""
SSLCert = ""
SSLPort = 443
SSLOpts = ""
User = "www-data"
WorkerProcesses = 2
RLimitNoFile = 65535
ProxyConnectTimeout = 600
ProxySendTimeout = 600
ProxyReadTimeout = 600
SendTimeout = 600
SSLCiphers = "HIGH:!aNULL:!MD5"
SSLProtocols = "SSLv3 TLSv1 TLSv1.1 TLSv1.2"'

# Retrieve Fingerprint from Master Controller

curl --insecure https://$MASTERFQDN/ca > ca.pem

FPRINT=$(openssl x509 -in ca.pem -noout -sha256 -fingerprint | awk -F= '{ print $2 }' )

echo $FPRINT

# Load the predownloaded Tar File

echo $(date) " - Loading docker install Tar"

docker load < /opt/ucp/ucp-1.1.2_dtr-2.0.2.tar.gz

# Start installation of UCP and join Controller replica to master Controller

echo $(date) " - Loading complete.  Starting UCP Install of replica Controller"

docker run --rm -i \
    --name ucp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e UCP_ADMIN_USER=admin \
    -e UCP_ADMIN_PASSWORD=$PASSWORD \
    docker/ucp:1.1.2 \
    join --replica --san $MASTERFQDN --url https://${MASTERFQDN}:443 --fingerprint "${FPRINT}"

if [ $? -eq 0 ]
then
 echo $(date) " - UCP installed and started on the master(replica) Controller"
else
 echo $(date) " -- UCP installation failed"
fi


# Configure NginX for Interlock  

echo $(date) " - Initiating NginX and interlock configuration on the master"

docker run -d \
 -e INTERLOCK_CONFIG="$INTERLOCK_CONFIG" \
 -v ucp-node-certs:/certs \
 -p 8080:8080 \
 --restart=always \
 ehazlett/interlock:1.2.0 \
 -D run

if [ $? -eq 0 ]
then
echo $(date) " - NginX and interlock config complete"
else
 echo $(date) " -- NginX and interlock config failed"
fi

