sudo yum install -y mdadm
sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/sdc /dev/sdd
sudo mkdir -p /etc/mdadm
sudo mdadm --detail --scan > /etc/mdadm/mdadm.conf
