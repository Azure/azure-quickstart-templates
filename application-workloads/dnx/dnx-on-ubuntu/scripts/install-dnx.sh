admin_username=$1

# Go to the home dir of the admin user
cd /home/${admin_username}

# Download and install DNVM
echo "Downloading DNVM installation script ..."
curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_BRANCH=dev sh && source ~/.dnx/dnvm/dnvm.sh
dnvm upgrade -r coreclr

# Set up sample hello world application
mkdir /home/${admin_username}/sampleConsoleApp
cat > /home/${admin_username}/sampleConsoleApp/main.cs <<EOL
namespace DnxApp
{
    using System;

    public class Program
    {
        public static void Main(string[] args)
        {
            Console.WriteLine("Hello world from DNX !");
        }
    }
}
EOL

cat > /home/${admin_username}/sampleConsoleApp/project.json <<EOL
{
  "version": "1.0.0-*",
  "description": "DNX Console application",
  "compilationOptions": {
    "emitEntryPoint": true
  },
  "dependencies": {
  },
  "commands": {
    "ConsoleApp1": "ConsoleApp1"
  },
  "frameworks": {
    "dnx451": { },
    "dnxcore50": {
      "dependencies": {
        "Microsoft.CSharp": "4.0.1-beta-23516",
        "System.Collections": "4.0.11-beta-23516",
        "System.Console": "4.0.0-beta-23516",
      }
    }
  }
}
EOL

# Restore .NET dependencies and build the application
cd /home/${admin_username}/sampleConsoleApp
dnu restore
dnu build --framework dnxcore50
