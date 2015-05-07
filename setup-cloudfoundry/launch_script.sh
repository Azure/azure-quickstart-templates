for f in install_bosh_client.sh micro_bosh.yml create_cert.sh setup_devbox.py update_os.sh deploy_micro_bosh.sh mtdownload.js micro_cf.xml
do
   wget $1/$f -O $f
done

\cp * ../../
cd ../../
python setup_devbox.py