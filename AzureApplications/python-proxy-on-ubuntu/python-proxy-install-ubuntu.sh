#Install pip
apt-get update
apt-get install python-pip python-dev build-essential -y
pip install proxy.py

host=`ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`

init_script="/etc/init/pythonproxy.conf"
echo "#Python Proxy"                                >  $init_script
echo ""                                             >> $init_script
echo "description \"A http proxy service\""         >> $init_script
echo "author \"Yue Zhang<yuezha@microsoft.com>\""   >> $init_script
echo ""                                             >> $init_script
echo "exec proxy.py --host $host --port 8888"                                   >> $init_script

service pythonproxy start

