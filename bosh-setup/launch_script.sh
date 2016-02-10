for f in bosh.yml setup_dns.py create_cert.sh setup_devbox.py init.sh deploy_bosh.sh 98-msft-love-cf
do
   wget $1/$f -O $f
done

\cp * ../../
cd ../../
python setup_devbox.py
