export CHEF_ENV=testchef
export PATH=/opt/chefdk/embedded/bin:$PATH
cd /home/adminuser/delivery-cluster
rake setup:cluster
