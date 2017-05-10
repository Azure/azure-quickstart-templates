# Delete old Version
sudo rm /usr/bin/gele

# Downloads git source
cd $HOME
git clone https://github.com/elementrem/go-elementrem/

# Build elementrem
cd go-elementrem
git checkout Azure
make

# gele path to usr/bin/
cd $HOME
cd go-elementrem/build/bin
sudo cp gele /usr/bin
cd $HOME
rm -rf go-elementrem