#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# This will install ASPNET-Core on an Ubuntu machine
admin_username=$1

# Get package dependencies
apt-get -y update
apt-get install -y unzip curl

# Download the DNX pre-reqs
apt-get install -y libunwind8 gettext libssl-dev libcurl4-openssl-dev zlib1g libicu-dev uuid-dev


wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/dnx-on-ubuntu/scripts/install-dnx.sh -P /home/${admin_username}
sudo -u ${admin_username} /bin/bash /home/${admin_username}/install-dnx.sh ${admin_username}

# Nano syntax highlighting for C#
cat > /usr/share/nano/csharp.nanorc <<EOL
syntax "C# source" "\.cs$"
color green "\<(bool|byte|sbyte|char|decimal|double|float|int|uint|long|ulong|new|object|short|ushort|string|base|this|void)\>"
color red "\<(as|break|case|catch|checked|continue|default|do|else|finally|fixed|for|foreach|goto|if|is|lock|return|switch|throw|try|unchecked|while)\>"
color cyan "\<(abstract|class|const|delegate|enum|event|explicit|extern|implicit|in|internal|interface|namespace|operator|out|override|params|private|protected|public|readonly|ref|sealed|sizeof|static|struct|typeof|using|virtual|volatile)\>"
color red ""[^\"]*""
color yellow "\<(true|false|null)\>"
color blue "//.*"
color blue start="/\*" end="\*/"
color brightblue start="/\*\*" end="\*/"
color brightgreen,green " +$"
EOL

sudo echo "include \"/usr/share/nano/csharp.nanorc\"" > /etc/nanorc
