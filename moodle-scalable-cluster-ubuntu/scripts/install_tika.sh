# Custom Script for Linux

#!/bin/bash

# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

tikavmip=$1

echo $tikavmip     >> /tmp/vars.txt

{

  # make sure the system does automatic update
  sudo apt-get -y update
  sudo apt-get -y install unattended-upgrades

  # download apache tika server
  sudo wget -q http://mirrors.ocf.berkeley.edu/apache/tika/tika-server-1.18.jar --directory-prefix=/usr/share/java/

  # install the required packages
  sudo apt-get install -y openjdk-8-jre openjdk-8-jdk default-jre default-jdk

  # Configure tika
  cat <<EOF > /etc/systemd/system/tika-server.service
[Unit]
Description = Java Service
After network.target = tika-server.service

[Service]
Type = forking
ExecStart = /usr/local/bin/tika-server start
ExecStop = /usr/local/bin/tika-server stop
ExecReload = /usr/local/bin/tika-server reload

[Install]
WantedBy=multi-user.target
EOF

  chmod 777 /etc/systemd/system/tika-server.service

  cat <<EOF > /usr/local/bin/tika-server
#!/bin/sh
SERVICE_NAME=tika-server
PATH_TO_JAR=/usr/share/java/tika-server-1.18.jar
PID_PATH_NAME=/var/run/tika-server-pid
case \$1 in
    start)
        echo "Starting \$SERVICE_NAME ..."
        if [ ! -f \$PID_PATH_NAME ]; then
            nohup java -jar \$PATH_TO_JAR --host=$tikavmip --port=9998 >> /var/log/tika-server.out 2>&1&
                        echo \$! > \$PID_PATH_NAME
            echo "\$SERVICE_NAME started ..."
        else
            echo "\$SERVICE_NAME is already running ..."
        fi
    ;;
    stop)
        if [ -f \$PID_PATH_NAME ]; then
            PID=\$(cat $PID_PATH_NAME);
            echo "\$SERVICE_NAME stoping ..."
            kill \$PID;
            echo "\$SERVICE_NAME stopped ..."
            rm \$PID_PATH_NAME
        else
            echo "\$SERVICE_NAME is not running ..."
        fi
    ;;
    restart)
        if [ -f \$PID_PATH_NAME ]; then
            PID=\$(cat $PID_PATH_NAME);
            echo "\$SERVICE_NAME stopping ...";
            kill \$PID;
            echo "\$SERVICE_NAME stopped ...";
            rm \$PID_PATH_NAME
            echo "\$SERVICE_NAME starting ..."
            nohup java -jar \$PATH_TO_JAR --host=$tikavmip --port=9998 >> /var/log/tika-server.out 2>&1&
                        echo \$! > \$PID_PATH_NAME
            echo "\$SERVICE_NAME started ..."
        else
            echo "\$SERVICE_NAME is not running ..."
        fi
    ;;
esac
EOF
  chmod +x /usr/local/bin/tika-server
  systemctl enable tika-server.service
  systemctl start tika-server.service
}  > /tmp/setup.log
