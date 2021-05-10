sudo apt-get -y update
sudo apt-get -y install -y build-essential autoconf libtool pkg-config python-opengl python-imaging python-pyrex python-pyside.qtopengl idle-python2.7 qt4-dev-tools qt4-designer libqtgui4 libqtcore4 libqt4-xml libqt4-test libqt4-script libqt4-network libqt4-dbus python-qt4 python-qt4-gl libgle3 python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev python-pip libjpeg-dev
pip install Scrapy
scrapy runspider $1
