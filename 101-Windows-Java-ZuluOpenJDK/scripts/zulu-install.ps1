
 $PARAMS = @("Azul_Zulu_OpenJDK-7-JDK", "Azul_Zulu_OpenJDK-7-JRE",
             "Azul_Zulu_OpenJDK-8-JDK", "Azul_Zulu_OpenJDK-8-JRE",
             "Azul_Zulu_OpenJDK-11-JDK", "Azul_Zulu_OpenJDK-11-JRE",
             "Azul_Zulu_OpenJDK-13-JDK", "Azul_Zulu_OpenJDK-13-JRE")

 $ZULU_PACKS = @("zulu-7-azure-jdk_7.36.0.5-7.0.252-win_x64.msi",
                 "zulu-7-azure-jre_7.36.0.5-7.0.252-win_x64.msi",
                 "zulu-8-azure-jdk_8.44.0.11-8.0.242-win_x64.msi",
                 "zulu-8-azure-jre_8.44.0.11-8.0.242-win_x64.msi",
                 "zulu-11-azure-jdk_11.37.17-11.0.6-win_x64.msi",
                 "zulu-11-azure-jre_11.37.17-11.0.6-win_x64.msi",
                 "zulu-13-azure-jdk_13.29.9-13.0.2-win_x64.msi",
                 "zulu-13-azure-jre_13.29.9-13.0.2-win_x64.msi")

 $PACKAGE_DIRS = @("zulu-7", "zulu-7", "zulu-8", "zulu-8", "zulu-11", "zulu-11", "zulu-13", "zulu-13")
 $VERSIONS = @("7u252", "7u252", "8u242", "8u242", "11.0.6", "11.0.6", "13.0.2", "13.0.2")
 $INSTALL_DIRS = @("zulu-7", "zulu-7-jre", "zulu-8", "zulu-8-jre", "zulu-11", "zulu-11-jre", "zulu-13", "zulu-13-jre")

 for ($idx = 0; $idx -lt $PARAMS.length; $idx++) {
    if ($args[0] -eq $PARAMS[$idx]) {
       $ZULU_PACK = $ZULU_PACKS[$idx]
       $PACKAGE_DIR = $PACKAGE_DIRS[$idx]
       $VERSION = $VERSIONS[$idx]
       $INSTALL_DIR = $INSTALL_DIRS[$idx]
       break
    }
 }

 Invoke-WebRequest -Uri http://repos.azul.com/azure-only/zulu/packages/$PACKAGE_DIR/$VERSION/$ZULU_PACK -OutFile C:\Windows\Temp\$ZULU_PACK
 msiexec /quiet /i C:\Windows\Temp\$ZULU_PACK

 setx /m JAVA_HOME "C:\Program Files\Zulu\$INSTALL_DIR"

