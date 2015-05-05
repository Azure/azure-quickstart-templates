mkfs.ext3 /dev/sdc
mkdir /mnt/sdc
mount /dev/sdc /mnt/sdc
wget #preparedboshdvos# -O /mnt/sdc/bosh_os.tar
tar -xf /mnt/sdc/bosh_os.tar -C /mnt/sdc
sed  -i "s/root=UUID=[^ ]*/root=\/dev\/sdc/" /boot/grub/grub.cfg
sync
reboot