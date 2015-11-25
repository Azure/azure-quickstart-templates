# accepts a storage account name and a key
container_name=$(cut -f1 -d, /mnt/config.txt)
blob_name=$(cut -f2 -d, /mnt/config.txt)
blobxfer $1 $container_name "/mnt/$blob_name" --storageaccountkey $2 --upload
