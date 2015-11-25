wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install azure-servicemanagement-legacy
pip install azure-storage
pip install requests
pip install blobxfer

blobxfer.py $1 $2 /mnt/ --remotesource $3 --storageaccountkey $4 --download
