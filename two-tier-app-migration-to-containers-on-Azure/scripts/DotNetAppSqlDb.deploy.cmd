@rem ---------------------------------------------------------------------------------
@rem Copyright 2008 Microsoft Corporation. All rights reserved.
@rem This is provided as sample to deploy the package using msdeploy.exe
@rem For information about IIS Web Deploy technology,
@rem please visit https://go.microsoft.com/?linkid=9278654
@rem Note: This batch file assumes the package and setparametsrs.xml are in the same folder with this file
@rem ---------------------------------------------------------------------------------
@if %_echo%!==! echo off
setlocal
@rem ---------------------------------------------------------------------------------
@rem Please Make sure you have Web Deploy install in your machine. 
@rem Alternatively, you can explicit set the MsDeployPath to the location it is on your machine
@rem set MSDeployPath="C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\"
@rem ---------------------------------------------------------------------------------
                      
@rem ---------------------------------------------------------------------------------
@rem if user does not set MsDeployPath environment variable, we will try to retrieve it from registry.
@rem ---------------------------------------------------------------------------------
if "%MSDeployPath%" == "" (
for /F "usebackq tokens=1,2,*" %%h  in (`reg query "HKLM\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" /s  ^| findstr -i "InstallPath"`) do (
if /I "%%h" == "InstallPath" ( 
if /I "%%i" == "REG_SZ" ( 
if not "%%j" == "" ( 
if "%%~dpj" == "%%j" ( 
set MSDeployPath=%%j
))))))

@rem ------------------------------------------

@rem ------------------------------------------

                      
if not exist "%MSDeployPath%msdeploy.exe" (
echo. msdeploy.exe is not found on this machine. Please install Web Deploy before execute the script. 
echo. Please visit https://go.microsoft.com/?linkid=9278654
goto :usage
)

set RootPath=%~dp0
if /I "%_DeploySetParametersFile%" == "" (
set _DeploySetParametersFile=%RootPath%DotNetAppSqlDb.SetParameters.xml
)

@rem ------------------------------------------

@rem ------------------------------------------

                      
set _ArgTestDeploy=
set _ArgDestinationType=auto
set _ArgComputerNameWithQuote=""
set _ArgUserNameWithQuote=""
set _ArgPasswordWithQuote=""
set _ArgEncryptPasswordWithQuote=""
set _ArgIncludeAclsWithQuote="False"
set _ArgAuthTypeWithQuote=""
set _ArgtempAgentWithQuote=""
set _ArgLocalIIS=
set _ArgLocalIISVersion=
set _HaveArgMSDeployAdditonalFlags=
                      
                      
@rem ---------------------------------------------------------------------------------
@rem Simple Parse the arguments
@rem ---------------------------------------------------------------------------------
:NextArgument
set _ArgCurrent=%~1
set _ArgFlagFirst=%_ArgCurrent:~0,1%
set _ArgFlag=%_ArgCurrent:~0,3%
set _ArgValue=%_ArgCurrent:~3%

if /I "%_ArgFlag%" == "" goto :GetStarted
if /I "%_ArgFlag%" == "~0,3" goto :GetStarted
if /I "%_ArgFlag%" == "/T" set _ArgTestDeploy=true&goto :ArgumentOK
if /I "%_ArgFlag%" == "/Y" set _ArgTestDeploy=false&goto :ArgumentOK
if /I "%_ArgFlag%" == "/L" set _ArgLocalIIS=true&goto :ArgumentOK

if /I "%_ArgFlag%" == "/M:" set _ArgComputerNameWithQuote="%_ArgValue%"&goto :ArgumentOK
if /I "%_ArgFlag%" == "/U:" set _ArgUserNameWithQuote="%_ArgValue%"&goto :ArgumentOK
if /I "%_ArgFlag%" == "/P:" set _ArgPasswordWithQuote="%_ArgValue%"&goto :ArgumentOK
if /I "%_ArgFlag%" == "/E:" set _ArgEncryptPasswordWithQuote="%_ArgValue%"&goto :ArgumentOK
if /I "%_ArgFlag%" == "/I:" set _ArgIncludeAclsWithQuote="%_ArgValue%"&goto :ArgumentOK
if /I "%_ArgFlag%" == "/A:" set _ArgAuthTypeWithQuote="%_ArgValue%"&goto :ArgumentOK
if /I "%_ArgFlag%" == "/G:" set _ArgtempAgentWithQuote="%_ArgValue%"&goto :ArgumentOK

@rem Any addition flags, pass through to the msdeploy
if "%_HaveArgMSDeployAdditonalFlags%" == "" (
goto :Assign_ArgMsDeployAdditionalFlags
)
set _ArgMsDeployAdditionalFlags=%_ArgMsDeployAdditionalFlags:&=^&% %_ArgCurrent:&=^&%
set _HaveArgMSDeployAdditonalFlags=1
goto :ArgumentOK


:Assign_ArgMsDeployAdditionalFlags
set _ArgMsDeployAdditionalFlags=%_ArgCurrent:&=^&%
set _HaveArgMSDeployAdditonalFlags=1
goto :ArgumentOK

:ArgumentOK
shift
goto :NextArgument

:GetStarted
@rem ------------------------------------------

@rem ------------------------------------------
if /I "%_ArgTestDeploy%" == "" goto :usage
if /I "%_ArgDestinationType%" == ""  goto :usage

set _Destination=%_ArgDestinationType%
if not %_ArgComputerNameWithQuote% == "" set _Destination=%_Destination%,computerName=%_ArgComputerNameWithQuote%
if not %_ArgUserNameWithQuote% == "" set _Destination=%_Destination%,userName=%_ArgUserNameWithQuote%
if not %_ArgPasswordWithQuote% == "" set _Destination=%_Destination%,password=%_ArgPasswordWithQuote%
if not %_ArgAuthTypeWithQuote% == "" set _Destination=%_Destination%,authtype=%_ArgAuthTypeWithQuote%
if not %_ArgEncryptPasswordWithQuote% == "" set _Destination=%_Destination%,encryptPassword=%_ArgEncryptPasswordWithQuote%
if not %_ArgIncludeAclsWithQuote% == "" set _Destination=%_Destination%,includeAcls=%_ArgIncludeAclsWithQuote%
if not %_ArgtempAgentWithQuote% == "" set _Destination=%_Destination%,tempAgent=%_ArgtempAgentWithQuote%

@rem ------------------------------------------

@rem ------------------------------------------

                      
@rem ---------------------------------------------------------------------------------
@rem add -whatif when -T is specified                      
@rem ---------------------------------------------------------------------------------
if /I "%_ArgTestDeploy%" NEQ "false" (
set _MsDeployAdditionalFlags=-whatif %_MsDeployAdditionalFlags%
)

@rem ------------------------------------------

@rem ------------------------------------------

@rem ---------------------------------------------------------------------------------
@rem add flags for IISExpress when -L is specified                      
@rem ---------------------------------------------------------------------------------

if /I "%_ArgLocalIIS%" == "true" (
call :SetIISExpressArguments
)
if /I "%_ArgLocalIIS%" == "true" (
if not exist "%IISExpressPath%%IISExpressManifest%" (
echo. IISExpress is not found on this machine. Please install through Web Platform Installer before execute the script. 
echo. or remove /L flag
echo. Please visit https://go.microsoft.com/?linkid=9278654
goto :usage
)
if not exist "%IISExpressUserProfileDirectory%" (
echo. %IISExpressUserProfileDirectory% is not exists
echo. IISExpress is found on the machine. But the user have run IISExpress at least once.
echo. Please visit https://go.microsoft.com/?linkid=9278654 for detail
goto :usage
)
                      
set _MsDeployAdditionalFlags=%_MsDeployAdditionalFlags% -appHostConfigDir:%IISExpressUserProfileDirectory% -WebServerDir:"%IISExpressPath%" -webServerManifest:"%IISExpressManifest%"
)

@rem ---------------------------------------------------------------------------------
@rem check the existence of the package file
@rem ---------------------------------------------------------------------------------
if not exist "%RootPath%DotNetAppSqlDb.zip" (
echo "%RootPath%DotNetAppSqlDb.zip" does not exist. 
echo This batch file relies on this deploy source file^(s^) in the same folder.
goto :usage
)

@rem ---------------------------------------------

@rem ---------------------------------------------

@rem ---------------------------------------------------------------------------------
@rem Execute msdeploy.exe command line
@rem ---------------------------------------------------------------------------------
call :CheckParameterFile
echo. Start executing msdeploy.exe
echo -------------------------------------------------------
if  not exist "%_DeploySetParametersFile%" (
set _MSDeployCommandline="%MSDeployPath%msdeploy.exe" -source:package='%RootPath%DotNetAppSqlDb.zip' -dest:%_Destination% -verb:sync -disableLink:AppPoolExtension -disableLink:ContentExtension -disableLink:CertificateExtension
) else (
set _MSDeployCommandline="%MSDeployPath%msdeploy.exe" -source:package='%RootPath%DotNetAppSqlDb.zip' -dest:%_Destination% -verb:sync -disableLink:AppPoolExtension -disableLink:ContentExtension -disableLink:CertificateExtension -setParamFile:"%_DeploySetParametersFile%"
)

if "%_HaveArgMSDeployAdditonalFlags%" == "" (
goto :MSDeployWithOutArgMsDeployAdditionalFlag
) 
goto :MSDeployWithArgMsDeployAdditionalFlag
goto :eof

@rem ---------------------------------------------------------------------------------
@rem MSDeployWithArgMsDeployAdditionalFlag
@rem ---------------------------------------------------------------------------------
:MSDeployWithArgMsDeployAdditionalFlag
echo. %_MSDeployCommandline% %_MsDeployAdditionalFlags% %_ArgMsDeployAdditionalFlags:&=^&%
%_MSDeployCommandline% %_MsDeployAdditionalFlags% %_ArgMsDeployAdditionalFlags:&=^&%
goto :eof

@rem ---------------------------------------------------------------------------------
@rem MSDeployWithOutArgMsDeployAdditionalFlag
@rem ---------------------------------------------------------------------------------
:MSDeployWithOutArgMsDeployAdditionalFlag
echo. %_MSDeployCommandline% %_MsDeployAdditionalFlags%
%_MSDeployCommandline% %_MsDeployAdditionalFlags%
goto :eof

@rem ---------------------------------------------------------------------------------
@rem Find and set IISExpress argument.
@rem ---------------------------------------------------------------------------------
:SetIISExpressArguments
                      
if "%IISExpressPath%" == "" (
for /F "usebackq tokens=1,2,*" %%h  in (`reg query "HKLM\SOFTWARE\Microsoft\IISExpress" /s  ^| findstr -i "InstallPath"`) do (
if /I "%%h" == "InstallPath" ( 
if /I "%%i" == "REG_SZ" ( 
if not "%%j" == "" ( 
if "%%~dpj" == "%%j" ( 
set IISExpressPath=%%j
))))))

if "%IISExpressPath%" == "" (
for /F "usebackq tokens=1,2,*" %%h  in (`reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\IISExpress" /s  ^| findstr -i "InstallPath"`) do (
if /I "%%h" == "InstallPath" ( 
if /I "%%i" == "REG_SZ" ( 
if not "%%j" == "" ( 
if "%%~dpj" == "%%j" ( 
set IISExpressPath=%%j
))))))

if "%PersonalDocumentFolder%" == "" (
for /F "usebackq tokens=2*" %%i  in (`reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Personal`) do (
set PersonalDocumentFolder=%%j
))

if "%IISExpressManifest%" == "" (
for /F "usebackq tokens=1,2,*" %%h  in (`reg query "HKLM\SOFTWARE\Microsoft\IISExpress" /s  ^| findstr -i "Manifest"`) do (
if /I "%%h" == "Manifest" ( 
if /I "%%i" == "REG_SZ" ( 
if not "%%j" == "" ( 
set IISExpressManifest=%%j
)))))

if "%IISExpressManifest%" == "" (
for /F "usebackq tokens=1,2,*" %%h  in (`reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\IISExpress" /s  ^| findstr -i "Manifest"`) do (
if /I "%%h" == "Manifest" ( 
if /I "%%i" == "REG_SZ" ( 
if not "%%j" == "" ( 
set IISExpressManifest=%%j
)))))
                      
set IISExpressUserProfileDirectory="%PersonalDocumentFolder%\IISExpress\config"

@rem ---------------------------------------------

@rem ---------------------------------------------

goto :eof                      
                      
@rem ---------------------------------------------------------------------------------
@rem CheckParameterFile -- check if the package's setparamters.xml exists or not
@rem ---------------------------------------------------------------------------------
:CheckParameterFile
if exist "%_DeploySetParametersFile%" (
echo SetParameters from:
echo "%_DeploySetParametersFile%"
echo You can change IIS Application Name, Physical path, connectionString
echo or other deploy parameters in the above file.
) else (
echo SetParamterFiles does not exist in package location.
echo Use package embedded defaultValue to deploy.
)
echo -------------------------------------------------------
goto :eof

@rem ---------------------------------------------------------------------------------
@rem Usage
@rem ---------------------------------------------------------------------------------
:usage
echo =========================================================
if not exist "%RootPath%DotNetAppSqlDb.deploy-readme.txt" (
echo Usage:%~nx0 [/T^|/Y] [/M:ComputerName] [/U:userName] [/P:password] [/G:tempAgent] [additional msdeploy flags ...]
echo Required flags:
echo /T  Calls msdeploy.exe with the "-whatif" flag, which simulates deployment. 
echo /Y  Calls msdeploy.exe without the "-whatif" flag, which deploys the package to the current machine or destination server 
echo Optional flags:  
echo. By Default, this script deploy to the current machine where this script is invoked which will use current user credential without tempAgent. 
echo.   Only pass these arguments when in advance scenario.
echo /M:  Msdeploy destination name of remote computer or proxy-URL. Default is local.
echo /U:  Msdeploy destination user name. 
echo /P:  Msdeploy destination password.
echo /G:  Msdeploy destination tempAgent. True or False. Default is false.
echo /A:  specifies the type of authentication to be used. The possible values are NTLM and Basic. If the wmsvc provider setting is specified, the default authentication type is Basic
otherwise, the default authentication type is NTLM.
echo /L:  Deploy to Local IISExpress User Instance.  

echo.[additional msdeploy flags]: note: " is required for passing = through command line.
echo  "-skip:objectName=setAcl" "-skip:objectName=dbFullSql"
echo.Alternative environment variable _MsDeployAdditionalFlags is also honored.
echo.
echo. Please make sure MSDeploy is installed in the box https://go.microsoft.com/?linkid=9278654
echo.
echo In addition, you can change IIS Application Name, Physical path, 
echo connectionString and other deploy parameters in the following file:
echo "%_DeploySetParametersFile%"
echo.
echo For more information about this batch file, visit https://go.microsoft.com/fwlink/?LinkID=183544 
) else (
start notepad "%RootPath%DotNetAppSqlDb.deploy-readme.txt"
)
echo =========================================================
goto :eof
