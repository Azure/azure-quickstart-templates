#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
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
#
# Trent Swanson (Full Scale 180 Inc)
#

help()
{
    echo "Usage: $(basename $0) [-v es_version] [-t target_host] [-m] [-s] [-h]"
    echo "Options:"
    echo "  -v    elasticsearch version to target (default: 2.3.1)"
    echo "  -t    target host (default: http://10.0.1.4:9200)"
    echo "  -m    install marvel (default: no)"
    echo "  -s    install sense (default: no)"
    echo "  -h    this help message"
}

error()
{
    echo "$1" >&2
    exit 3
}

install_java() {
    add-apt-repository -y ppa:webupd8team/java
    apt-get -q -y update  > /dev/null
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
    apt-get -q -y install oracle-java8-installer  > /dev/null
}

install_kibana() {
    # default - ES 2.3.1
	kibana_url="https://download.elastic.co/kibana/kibana/kibana-4.5.0-linux-x64.tar.gz"
	
	if [[ "${ES_VERSION}" == "2.2.2" ]]; 
    then
		kibana_url="https://download.elastic.co/kibana/kibana/kibana-4.4.2-linux-x64.tar.gz"
	fi
    
    if [[ "${ES_VERSION}" == "2.1.2" ]]; 
    then
        kibana_url="https://download.elastic.co/kibana/kibana/kibana-4.3.3-linux-x64.tar.gz"
    fi
    
    if [[ "${ES_VERSION}" == "1.7.5" ]]; 
    then
        kibana_url="https://download.elastic.co/kibana/kibana/kibana-4.1.6-linux-x64.tar.gz"
    fi
    
    groupadd -g 999 kibana
    useradd -u 999 -g 999 kibana

    mkdir -p /opt/kibana
    curl -s -o kibana.tar.gz ${kibana_url}
    tar xvf kibana.tar.gz -C /opt/kibana/ --strip-components=1 > /dev/null

    chown -R kibana: /opt/kibana
    mv /opt/kibana/config/kibana.yml /opt/kibana/config/kibana.yml.bak

    if [[ "${ES_VERSION}" == \2* ]];
    then
        echo "elasticsearch.url: \"$ELASTICSEARCH_URL\"" >> /opt/kibana/config/kibana.yml
    else
        cat /opt/kibana/config/kibana.yml.bak | sed "s|http://localhost:9200|${ELASTICSEARCH_URL}|" >> /opt/kibana/config/kibana.yml 
    fi

    # install the marvel plugin for 2.x
    if [ ${INSTALL_MARVEL} -ne 0 ];
    then
		if [[ "${ES_VERSION}" == \2* ]];
        then
            /opt/kibana/bin/kibana plugin --install elasticsearch/marvel/${ES_VERSION}
        fi

        # for 1.x marvel is installed only within the cluster, not on the kibana node 
    fi
    
    # install the sense plugin for 2.x
    if [ ${INSTALL_SENSE} -ne 0 ];
    then
        if [[ "${ES_VERSION}" == \2* ]];
        then
            /opt/kibana/bin/kibana plugin --install elastic/sense
        fi
                
        # for 1.x sense is not supported 
    fi

# Add upstart task and start kibana service
cat << EOF > /etc/init/kibana.conf
    # kibana
    description "Elasticsearch Kibana Service"

    start on starting
    script
        /opt/kibana/bin/kibana
    end script
EOF

    chmod +x /etc/init/kibana.conf
    service kibana start
}

###############

if [ "${UID}" -ne 0 ];
then
    error "You must be root to run this script."
fi

ES_VERSION="2.3.1"
INSTALL_MARVEL=0
INSTALL_SENSE=0
ELASTICSEARCH_URL="http://10.0.1.4:9200"

while getopts :v:t:msh optname; do
  case ${optname} in
    v) ES_VERSION=${OPTARG};;
    m) INSTALL_MARVEL=1;;
    s) INSTALL_SENSE=1;;
    t) ELASTICSEARCH_URL=${OPTARG};; 
    h) help; exit 1;;
   \?) help; error "Option -${OPTARG} not supported.";;
    :) help; error "Option -${OPTARG} requires an argument.";;
  esac
done

install_java
install_kibana
