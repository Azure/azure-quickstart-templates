# accepts a blob uri (MUST HAVE https:// at the beginning) and a key

#wget https://bootstrap.pypa.io/get-pip.py
#python get-pip.py
#pip install azure-servicemanagement-legacy
#pip install azure-storage
#pip install requests
pip install blobxfer

sa_domain=$(echo "$1" | cut -f3 -d/)
sa_name=$(echo $sa_domain | cut -f1 -d.)
container_name=$(echo "$1" | cut -f4 -d/)
blob_name=$(echo "$1" | cut -f5 -d/)
echo ""
echo "sa name, container name, blob name:"
echo $sa_name
echo $container_name
echo $blob_name

echo "$container_name,$blob_name" > /mnt/config.txt

blobxfer $sa_name $container_name /mnt/ --remoteresource $blob_name --storageaccountkey $2 --download
