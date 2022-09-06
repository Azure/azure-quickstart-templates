#!/bin/bash

#
# run the script with the follow command:
# ./nva.sh -p 10800 -p 800 -P 10801 -V 801 -n 10.0.1.100
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Script to create VXLAN tunnels with Azure load balancer"
   echo
   echo "Syntax: scriptName -p INTERNAL_VXLAN_PORT -v INTERNAL_VNI -P EXTERNAL_VXLAN_PORT -V EXTERNAL_VNI -n IP_ADRESS_LOAD_BALANCER"
   echo "        ./nva.sh -p 10800 -v 800 -P 10801 -V 801 -n 10.0.1.100"
   echo "parameters:"
   echo "-p   internal port VXLAN"
   echo "-v   internal VNI"
   echo "-P   external port VXLAN"
   echo "-V   external VNI"
   echo
}

while getopts ":hp:v:P:V:n:" options
do
    case "${options}" in
        h) # display Help
            help
            exit 2;;
        p) tunnel_internal_port=${OPTARG}
            ;;
        v) 
            tunnel_internal_vni=${OPTARG}
            ;;
        P) 
            tunnel_external_port=${OPTARG}
            ;;
        V) 
            tunnel_external_vni=${OPTARG}
            ;;
        n) nva_lb_ip=${OPTARG}
            ;;
       \?) # Invalid option
            echo 'Error: Invalid option'
            help
            exit 2;;
    esac
done
### example of variables assignment
### tunnel_internal_port=10800
### tunnel_internal_vni=800
### tunnel_external_port=10801
### tunnel_external_vni=801
### nva_lb_ip=10.0.1.100
#
if [ "${UID}" -ne 0 ];
then
    echo "Script executed without root permissions"
    echo "You must be root to run this script." >&2
    exit 3
fi
#
sleep 1m

# eliminate debconf warnings
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

sudo apt-get -y update
sudo apt-get -y install unattended-upgrades
# sudo apt-get install net-tools
# 
### enable IP forwarding
sudo sed -i -e '$a\net.ipv4.ip_forward = 1' /etc/sysctl.conf
sysctl -p 

### install and start nginx
sudo apt-get -y install nginx 
sudo systemctl enable nginx 
sudo systemctl start nginx
### change the homepage of nginx
echo '<style> h1 { color: blue; } </style> <h1>' > /var/www/html/index.nginx-debian.html
cat /etc/hostname >> /var/www/html/index.nginx-debian.html
echo ' </h1>' >> /var/www/html/index.nginx-debian.html
sed -i '/^#/! s/listen 80/listen 8080/g'  /etc/nginx/sites-enabled/default
sed -i '/^#/! s/listen \[::]:80/listen \[::]:8080/g' /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

### create a file to setup the VXLAN tunnels
cat <<EOF > /usr/local/bin/nvavnisetup.sh
tunnel_internal_port=$tunnel_internal_port
tunnel_internal_vni=$tunnel_internal_vni
tunnel_external_port=$tunnel_external_port
tunnel_external_vni=$tunnel_external_vni
nva_lb_ip=$nva_lb_ip

# internal tunnel
ip link add name vxlan\${tunnel_internal_vni} type vxlan id \${tunnel_internal_vni} remote \${nva_lb_ip} dstport \${tunnel_internal_port}
ip link set vxlan\${tunnel_internal_vni} up

# external tunnel
ip link add name vxlan\${tunnel_external_vni} type vxlan id \${tunnel_external_vni} remote \${nva_lb_ip} dstport \${tunnel_external_port}
ip link set vxlan\${tunnel_external_vni} up

# bridge both VXLAN interfaces together (works arounding routing between them)
ip link add br-tunnel type bridge
ip link set vxlan\${tunnel_internal_vni} master br-tunnel
ip link set vxlan\${tunnel_external_vni} master br-tunnel
ip link set br-tunnel up
EOF

### create a file to start the VXLAN tunnels as service
cat <<EOF > /etc/systemd/system/nvavxlan.service
[Unit]
Description=vni service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash /usr/local/bin/nvavnisetup.sh

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 744 /usr/local/bin/nvavnisetup.sh
sudo chmod 664 /etc/systemd/system/nvavxlan.service
# sudo systemctl daemon-reload
sudo systemctl start nvavxlan.service
sudo systemctl enable nvavxlan.service
# sudo systemctl restart nvavxlan.service
exit 0

