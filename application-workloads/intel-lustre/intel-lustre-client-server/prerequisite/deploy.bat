@echo off
set "file=.\Parameters.txt"
set /A i=0

for /F "usebackq delims=" %%a in ("%file%") do (
set /A i+=1
REM call echo %%i%%
call set array[%%i%%]=%%a
call set n=%%i%%
)
set SubscriptionName=%%array[1]%%
set ResourceGrpName=%%array[2]%%
set location=%%array[3]%%
set VNETName=%%array[4]%%
set Subnet1=%%array[5]%%
set Range1=%%array[6]%%
set Subnet2=%%array[7]%%
set Range2=%%array[8]%%

call azure account set %SubscriptionName%
call azure config mode arm
call azure group create -n %ResourceGrpName% -l %location%
call azure network vnet create -g %ResourceGrpName% -n %VNETName% -l %location%
call azure network vnet subnet create -e %VNETName% -g %ResourceGrpName% -n %Subnet1% -a %Range1%
call azure network vnet subnet create -e %VNETName% -g %ResourceGrpName% -n %Subnet2% -a %Range2%