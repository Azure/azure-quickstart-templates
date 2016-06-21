for f in concourse.yml bosh.yml create_cert.sh setup_devbox.py init.sh deploy_bosh.sh
do
   wget $1/$f -O $f
done

\cp * ../../
cd ../../
python setup_devbox.py
