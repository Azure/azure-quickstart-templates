# accepts a blob uri (MUST HAVE https:// at the beginning) and a key
# $1 - Source VHD image storage account
# $2 - Source VHD image storage key
# $3 - List of accounts to upload to storage account
# $4 - List of accounts to upload to storage key

apt-get -y update
apt-get -y install python3-pip
pip3 install blobxfer

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

blobxfer $sa_name $container_name /mnt/ --remoteresource $blob_name --storageaccountkey $2 --download --no-computefilemd5

sa_domain=$(echo "$3" | cut -f3 -d/)
sa_name=$(echo $sa_domain | cut -f1 -d.)

blobxfer $sa_name "sas" . --remoteresource . --storageaccountkey $4 --download --no-computefilemd5

filelist=$(ls *.sa)
for entry in ${filelist}
do
  key=$(<${entry})
  account=${entry%.sa}
  blobxfer ${account} "vhds" "/mnt/$blob_name" --remoteresource "$blob_name" --storageaccountkey ${key:2} --upload --no-computefilemd5 --autovhd
done



