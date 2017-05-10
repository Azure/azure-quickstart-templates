openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout myPrivateKey.key -out myCert.pem >null.txt 2>&1 << EndOfMessage
AU
ZJU
ZHCN
Linux
Soft
SShKey
test@abc.com
EndOfMessage

echo '      ssh_certificate: |'
cat myCert.pem|awk '{print "        "$0}'
echo '      ssh_private_key: |'
cat myPrivateKey.key |awk '{print "        "$0}'
chmod 700 myPrivateKey.key
