openssl genrsa -out bosh.key 2048 >/dev/null 2>&1
openssl req -new -x509 -days 365 -key bosh.key -out bosh_cert.pem >/dev/null 2>&1 << EndOfMessage
AU
ZJU
ZHCN
Linux
Soft
SShKey
test@abc.com
EndOfMessage
