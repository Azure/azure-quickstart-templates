cd /opt/splunk
sudo tar -cf splunketccfg.tar ./etc/*.cfg
python dobackup.py
