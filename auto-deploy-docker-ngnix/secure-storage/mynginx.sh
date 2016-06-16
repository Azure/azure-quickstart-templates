echo "=== Starting  execution Custom script ==="
mkdir -p /home/docker-nginx/html
echo "... Folder created"
docker run -i -v /home/docker-nginx/html:/home microsoft/azure-cli azure storage blob download -a EXISTING_STORAGE_ACCOUNTNAME -k "EXISTING_SCRIPT_STORAGE_ACCOUNT_KEY" --container proxseesafe -b "index.html" -d /home
echo "... File downloaded"
docker run --name docker-nginx -p 80:80 -d -v /home/docker-nginx/html:/usr/share/nginx/html nginx
echo "=== End of Custom script ==="