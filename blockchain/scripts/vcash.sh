#!/bin/bash

set -e 

date
ps axjf

echo $1

#################################################################
# From_Source                                                 #
#################################################################
if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running Vcash   #
#################################################################
sudo apt-get update
#################################################################
# Build Vcash from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
VCASH_ROOT=$(pwd)
#################################################################
# Install all necessary packages for building Vcash           #
#################################################################
sudo apt-get -y install git build-essential
sudo apt-get update

file=test/bin/gcc-*/release/link-static/stack
if [ ! -e "$file" ]
then
    rm -rf .git
    git init .
    git remote add -t \* -f origin https://github.com/john-connor/vcash.git
    git checkout master
fi

mkdir -p deps/openssl/
cd deps/openssl/
wget --no-check-certificate "https://openssl.org/source/openssl-1.0.1q.tar.gz"
tar -xzf openssl-*.tar.gz
rm -rf openssl-*.tar.gz
cd openssl-*
./config --prefix=$VCASH_ROOT/deps/openssl/
make depend && make && make install
cd $VCASH_ROOT

mkdir -p deps/db/
cd deps/db/
wget --no-check-certificate "https://download.oracle.com/berkeley-db/db-4.8.30.tar.gz"
tar -xzf db-4.8.30.tar.gz
rm -rf db-4.8.30.tar.gz
cd db-4.8.30/build_unix/
../dist/configure --enable-cxx --prefix=$VCASH_ROOT/deps/db/
make && make install
cd $VCASH_ROOT

cd deps
wget "https://sourceforge.net/projects/boost/files/boost/1.53.0/boost_1_53_0.tar.gz"
tar -xzf boost_1_53_0.tar.gz
rm -rf boost_1_53_0.tar.gz
mv boost_1_53_0 boost
cd boost
./bootstrap.sh
./bjam link=static toolset=gcc cxxflags=-std=gnu++0x --with-system release
cd $VCASH_ROOT

cd test
../deps/boost/bjam toolset=gcc cxxflags="-std=gnu++0x -fpermissive" release
cd $VCASH_ROOT

sudo cp test/bin/gcc-*/release/link-static/stack /usr/bin/vcashd

else
#################################################################
# Install Vcash from PPA                                      #
#################################################################
    sudo add-apt-repository -y ppa:Vcash/Vcash
    sudo apt-get update
    sudo apt-get install -y Vcash
fi

file=/etc/init.d/vcash

if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo nohup vcashd >/dev/null 2>&1 &' | sudo tee /etc/init.d/vcash
	sudo chmod +x /etc/init.d/vcash
	sudo update-rc.d vcash defaults
fi

echo "vcashd is starting..."

sudo nohup /usr/bin/vcashd >/dev/null 2>&1 &

exit 0

