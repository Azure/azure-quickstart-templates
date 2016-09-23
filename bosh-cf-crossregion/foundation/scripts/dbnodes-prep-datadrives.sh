#
# First fdist the data drive
#
sudo fdisk -u /dev/sdc <<EOF
n
p
1

w
EOF

#
# Then make the ext4 file system
#
sudo mkfs -t ext4 /dev/sdc <<EOF
y
EOF

#
# Mount the file system
#
sudo mkdir /datadrive
sudo mount /dev/sdc /datadrive

#
# Modify /etc/fstab to auto-mount the file system
#
sudo cp /etc/fstab ~/fstab
sudo cp ~/fstab ~/fstab.bak
echo -e "\n\n#\n# MariaDB Auto-Mount Script for Cross Region Cloud Foundry Cluster\n#" | sudo tee -a ~/fstab
echo -e "$(blkid -o export /dev/sdc | grep UUID)\t/datadrive\tauto\tdefaults,nofail,comment=nfsdata\t1 2" | sudo tee -a ~/fstab
sudo cp ~/fstab /etc/fstab