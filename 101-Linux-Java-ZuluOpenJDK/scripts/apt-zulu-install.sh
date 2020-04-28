#!/bin/bash

 PARAMS=(Azul_Zulu_OpenJDK-7-JDK Azul_Zulu_OpenJDK-7-JRE Azul_Zulu_OpenJDK-7-JRE-Headless
         Azul_Zulu_OpenJDK-8-JDK Azul_Zulu_OpenJDK-8-JRE Azul_Zulu_OpenJDK-8-JRE-Headless
         Azul_Zulu_OpenJDK-11-JDK Azul_Zulu_OpenJDK-11-JRE Azul_Zulu_OpenJDK-11-JRE-Headless
         Azul_Zulu_OpenJDK-13-JDK Azul_Zulu_OpenJDK-13-JRE Azul_Zulu_OpenJDK-13-JRE-Headless)

 ZULU_PACKS=(zulu-7-azure-jdk zulu-7-azure-jre zulu-7-azure-jre-headless
             zulu-8-azure-jdk zulu-8-azure-jre zulu-8-azure-jre-headless
             zulu-11-azure-jdk zulu-11-azure-jre zulu-11-azure-jre-headless
             zulu-13-azure-jdk zulu-13-azure-jre zulu-13-azure-jre-headless)

 ZULU_DIRS=(zulu-7-azure-amd64 zre-7-azure-amd64 zre-hl-7-azure-amd64
            zulu-8-azure-amd64 zre-8-azure-amd64 zre-hl-8-azure-amd64
            zulu-11-azure-amd64 zre-11-azure-amd64 zre-hl-11-azure-amd64
            zulu-13-azure-amd64 zre-13-azure-amd64 zre-hl-13-azure-amd64)

 for idx in ${!PARAMS[@]}
 do
    if [ $1 == ${PARAMS[$idx]} ]
    then
       ZULU_PACK=${ZULU_PACKS[$idx]}
       ZULU_DIR=${ZULU_DIRS[$idx]}
       break
    fi
 done

 apt-get update
 apt-get -y --no-install-recommends install dirmngr gnupg software-properties-common
 apt-get -y dist-upgrade
 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9
 apt-add-repository "deb http://repos.azul.com/azure-only/zulu/apt stable main"
 apt-get update
 apt-get -y --no-install-recommends install $ZULU_PACK
 rm -rf /var/lib/apt/lists/*

 echo "export JAVA_HOME=/usr/lib/jvm/$ZULU_DIR" >> /etc/bash.bashrc

