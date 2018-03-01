#!/bin/bash
edit_template(){
# this creates an ansible list for disks in forma ['/dev/sdc',...]
chars=( {c..z} )
n=$1
for ((i=0; i<n; i++))
do
    disks[i]="\/dev\/sd${chars[i]}"
done
disklist="$(echo "'${disks[*]}'" | tr ' ' ,)"
disklist=${disklist//","/"','"}
echo "start customizing ECS at $(date)" |& tee -a /root/install.log
echo "replacing mydisks with disklist $disklist" >> /root/install.log
sed -i -e 's/mydisks/'"$disklist"'/g' /root/ECS-CommunityEdition/deploy.yml


# this creates an ansible list for nodes in formar ['ecs1',...]
n=$2
for ((i=1; i<=n; i++))
do
    hosts[i]=$3$i
done
hostlist="$(echo "'${hosts[*]}'" | tr ' ' ,)"
hostlist=${hostlist//","/"','"}
echo "replacing myhosts with hostlist $hostlist" >> /root/install.log
sed -i -e 's/myhosts/'"$hostlist"'/g' /root/ECS-CommunityEdition/deploy.yml

# this creates an ansible list for members in format ['10.0.0',...]
n=$2
for ((i=4; i<=n+3; i++))
do
    members[i]=10.0.0.$i
done
memberlist="$(echo "'${members[*]}'" | tr ' ' ,)"
memberlist=${memberlist//","/"','"}
echo "replacing mymembers with memberlist $memberlist" >> /root/install.log
sed -i -e 's/mymembers/'"$memberlist"'/g' /root/ECS-CommunityEdition/deploy.yml
echo "replacing ECSUSER with  $4" >> /root/install.log
sed -i -e 's/ECSUSER/'"$4"'/g' /root/ECS-CommunityEdition/deploy.yml
echo "replacing ECSPASSWORD with  $5" >> /root/install.log
sed -i -e 's/ECSPASSWORD/'"$5"'/g' /root/ECS-CommunityEdition/deploy.yml

}
before_reboot(){
yum install git firewalld -y
#for openlogic
sed -i -e 's/#GatewayPorts no/GatewayPorts yes/g' /etc/ssh/sshd_config
systemctl disable rpcbind    
cp ecs.sh /root/ 
chmod +X /root/ecs.sh 
chmod 755 /root/ecs.sh 
cp ecs-installer.service /etc/systemd/system/ 
systemctl daemon-reload 
systemctl enable ecs-installer.service 
git clone https://github.com/emcecs/ecs-communityedition /root/ECS-CommunityEdition 
cp deploy.yml /root/ECS-CommunityEdition 
edit_template $1 $2 $3 $4 $5
echo "$1 $2 $3 $4 $5" >> /root/parameters.txt
myreboot & 
echo $? 
}
myreboot () {
   sleep 60 
   shutdown -r now
} 
after_bootstrap(){
    cd /root/ECS-CommunityEdition
    /usr/bin/step1 |& tee -a /root/install.log
    /usr/bin/step2 |& tee -a /root/install.log
    echo "finished customizing at $(date)" |& tee -a /root/install.log
}

after_waagent(){
    cd /root/ECS-CommunityEdition   
    ./bootstrap.sh -c ./deploy.yml -y |& tee -a /root/install.log
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -d|--DISKNUM)
    DISKNUM="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--NODENUM)
    NODENUM="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--ECSUSER)
    ECSUSER="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--ECSPASSWORD)
    ECSPASSWORD="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--NODEPREFIX)
    NODEPREFIX="$2"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo "DISKNUM = ${DISKNUM}" >> /root/install.log
echo "NODENUM     = ${NODENUM}" >> /root/install.log
echo "NODEPREFIX   = ${NODEPREFIX}" >> /root/install.log
echo "ECSUSER   = ${ECSUSER}" >> /root/install.log
echo "ECSPASSWORD   = ${ECSPASSWORD}" >> /root/install.log
if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

if [ -f /root/rebooting-for-bootstrap ]; then
    after_bootstrap
    rm /root/rebooting-for-bootstrap
    systemctl disable ecs-installer.service
elif [ -f /root/rebooting-for-waagent ]; then
    rm /root/rebooting-for-waagent
    touch /root/rebooting-for-bootstrap
    after_waagent
else
    touch /root/rebooting-for-waagent
    echo "$DISKNUM $NODENUM $NODEPREFIX $ECSUSER $ECSPASSWORD" >> /root/parameters.txt
    before_reboot $DISKNUM $NODENUM $NODEPREFIX $ECSUSER $ECSPASSWORD
fi

