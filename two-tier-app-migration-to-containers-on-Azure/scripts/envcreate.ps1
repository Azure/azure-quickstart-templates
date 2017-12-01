# to Install web deploy
$Url = "https://raw.githubusercontent.com/wmhussain/two-tier-app-migration-containers/master/scripts/WebDeploy_amd64_en-US.msi"
Invoke-WebRequest -Uri "$Url" -OutFile "C:\Packages\WebDeploy_amd64_en-US.msi"
msiexec.exe /i C:\Packages\WebDeploy_amd64_en-US.msi  /qn

sleep 20

# to create a database used by app
[String]$dbname = "cruddb";
 
# Open ADO.NET Connection with Windows authentification to local SQLSERVER.
$con = New-Object Data.SqlClient.SqlConnection;
$con.ConnectionString = "Data Source=.;Initial Catalog=master;Integrated Security=False;User Id=dbuser; Password=dbPassw0rd;";
$con.Open();
 
# Select-Statement for AD group logins
$sql = "SELECT name
        FROM sys.databases
        WHERE name = '$dbname';";
 
# New command and reader.
$cmd = New-Object Data.SqlClient.SqlCommand $sql, $con;
$rd = $cmd.ExecuteReader();
if ($rd.Read())
{   
    Write-Host "Database $dbname already exists";
    Return;
}
 
$rd.Close();
$rd.Dispose();
 
# Create the database.
$sql = "CREATE DATABASE [$dbname];"
$cmd = New-Object Data.SqlClient.SqlCommand $sql, $con;
$cmd.ExecuteNonQuery();     
Write-Host "Database $dbname is created!";
 
 
# Close & Clear all objects.
$cmd.Dispose();
$con.Close();
$con.Dispose();


#To change the default port of default website
set-webbinding -Name 'Default Web Site' -BindingInformation "*:80:" -propertyName "Port" -Value "1234"

#To create a crud website

New-Website -Name crud -Force -PhysicalPath C:\inetpub\crud -Port 80

#To download & deploy Crud app using local database
$Url1 = "https://raw.githubusercontent.com/wmhussain/two-tier-app-migration-containers/master/scripts/DotNetAppSqlDb.deploy.cmd"
$Url2 = "https://raw.githubusercontent.com/wmhussain/two-tier-app-migration-containers/master/scripts/DotNetAppSqlDb.SetParameters.xml"
$Url3 = "https://raw.githubusercontent.com/wmhussain/two-tier-app-migration-containers/master/scripts/DotNetAppSqlDb.zip"

Invoke-WebRequest -Uri "$Url1" -OutFile "C:\Packages\DotNetAppSqlDb.deploy.cmd"
Invoke-WebRequest -Uri "$Url2" -OutFile "C:\Packages\DotNetAppSqlDb.SetParameters.xml"
Invoke-WebRequest -Uri "$Url3" -OutFile "C:\Packages\DotNetAppSqlDb.zip"
cd C:\Packages\
.\DotNetAppSqlDb.deploy.cmd /Y

#Download MongoDB & Install
$Url = "https://fastdl.mongodb.org/win32/mongodb-win32-x86_64-2008plus-3.4.10-signed.msi"
Invoke-WebRequest -Uri "$Url" -OutFile "C:\Packages\mongodb-win32-x86_64-2008plus-3.4.10-signed.msi"
msiexec.exe /i C:\Packages\mongodb-win32-x86_64-2008plus-3.4.10-signed.msi  /qn
sleep 30
mkdir C:\data\db
cd "C:\Program Files\MongoDB\Server\3.4\bin\"
.\mongod.exe --dbpath="C:\data\db" --logpath="C:\data\db\log.txt" --install
net start MongoDB
$env:MONGODB_URL = "mongodb://localhost/meanstacktutorials"

#Download Nodejs Application & Install
$Url1 = "https://nodejs.org/dist/v8.8.1/node-v8.8.1-x64.msi"
Invoke-WebRequest -Uri "$Url1" -OutFile "C:\Packages\node-v8.8.1-x64.msi"
msiexec.exe /i C:\Packages\node-v8.8.1-x64.msi  /qn
sleep 30

#clone Nodejs ToDo app from Github
$Url2 = "https://github.com/evillgenius75/gbb-todo/archive/master.zip"
Invoke-WebRequest -Uri "$Url2" -OutFile "C:\Packages\gbb-todo.zip"
cd "C:\Packages"

#Function to unzip Package
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

#Unzip ToDo Pacakge
Unzip "C:\Packages\gbb-todo.zip" "C:\Packages\gbb-todo"
cd "C:\Packages\gbb-todo-master"

#Build Operation for the application to install all teh required dependencies for application.
npm install

#npm start: to be manually done by use

exit 0
