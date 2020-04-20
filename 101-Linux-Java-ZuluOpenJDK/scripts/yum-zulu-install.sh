#!/bin/bash

 PARAMS=(Azul_Zulu_OpenJDK-7-JDK Azul_Zulu_OpenJDK-7-JRE Azul_Zulu_OpenJDK-7-JRE-Headless
         Azul_Zulu_OpenJDK-8-JDK Azul_Zulu_OpenJDK-8-JRE Azul_Zulu_OpenJDK-8-JRE-Headless
         Azul_Zulu_OpenJDK-11-JDK Azul_Zulu_OpenJDK-11-JRE Azul_Zulu_OpenJDK-11-JRE-Headless
         Azul_Zulu_OpenJDK-13-JDK Azul_Zulu_OpenJDK-13-JRE Azul_Zulu_OpenJDK-13-JRE-Headless)

 ZULU_PACKS=(zulu-7-azure-jdk zulu-7-azure-jre zulu-7-azure-jre-headless
             zulu-8-azure-jdk zulu-8-azure-jre zulu-8-azure-jre-headless
             zulu-11-azure-jdk zulu-11-azure-jre zulu-11-azure-jre-headless
             zulu-13-azure-jdk zulu-13-azure-jre zulu-13-azure-jre-headless)

 ZULU_DIRS=(zulu-7-azure zre-7-azure zre-hl-7-azure
            zulu-8-azure zre-8-azure zre-hl-8-azure
            zulu-11-azure zre-11-azure zre-hl-11-azure
            zulu-13-azure zre-13-azure zre-hl-13-azure)

 for idx in ${!PARAMS[@]}
 do
    if [ $1 == ${PARAMS[$idx]} ]
    then
       ZULU_PACK=${ZULU_PACKS[$idx]}
       ZULU_DIR=${ZULU_DIRS[$idx]}
       break
    fi
 done

 rpm --import http://repos.azul.com/azul-repo.key
 curl http://repos.azul.com/azure-only/zulu-azure.repo -o /etc/yum.repos.d/zulu-azure.repo
 yum -q -y update
 yum -q -y upgrade
 yum -q -y install $ZULU_PACK

 echo "export JAVA_HOME=/usr/lib/jvm/$ZULU_DIR" >> /etc/bash.bashrc

