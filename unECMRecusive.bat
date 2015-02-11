@echo off
SETLOCAL

:: This script recurses through a directory tree, un ecm-ing any ecm files it finds
:: putting the extracted files in the same dir as the ecm was, and then deletes the ecm
:: it doesn't really check much (not sure unecm errorlevels work at all). At the end it just counts the number
:: of lines in the Done file against the ToDO file, this doesn't guarantee everything in the done
:: worked ok, mind......
::


::set the script dir for where to find ecm tools - default is in script dir in a folder called "ecm tools"
set scriptDir=%~dp0
set unECM=%scriptDir%\"ecm tools\unecm.exe"

::set the directory and indeed cd to it to make sure we're in it
set rootDir="E:\PSX_Jap"
cd %rootDir%
::we shall write to some temp files, delete them if they're already there
if exist unECMDone.txt (echo.Found and so deleting unECMDone.txt) & del unECMDone.txt
if exist unECMProblems.txt (echo.Found and so deleting unECMProblems.txt) & del unECMProblems.txt
::now recurse, printing out all 7zips we find. We SHOULD do for /r [path] %%g in (fileset) do(statement)
::but because we'vejust CD-ed to the rootDir we can omit path
(for /r %%G in (*.ecm) do echo %%G) > FilesToUnECM.txt

echo.******************************
echo.Here are the files I'll Un7Zip, saved as FilesToUnECM.txt
echo.******************************
echo.
echo.
type FilesToUnECM.txt | more 
echo.
echo.

setlocal enableextensions
set count=0
for /r %%H in (*.ecm) do set /a count+=1
echo.The number of files is: %count%
echo.now let's un unECM the lot, deleting as we go
echo.you sure you want to do this? Close me now if not
pause
::remember this: http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/percent.mspx?mfr=true

for /r %%I in (*.ecm) do (
echo.here's what I'm sending it "%%I"
						"E:\PSX_Jap\ecm tools\unecm.exe" "%%I"
						if %errorlevel% NEQ 0 (echo."Problem with %%~dpI" > unECMProblems.txt)
						if %errorlevel% EQU 0 (
												(echo.%%I >> unECMDone.txt) & del "%%I"	
												)
						)
						
						
::now its done let's count the lines in the files we made
::http://stackoverflow.com/questions/5664761/how-to-count-no-of-lines-in-text-file-and-store-the-value-into-a-variable-using

setlocal EnableDelayedExpansion
set "cmd=findstr /R /N "^^" FilesToUnECM.txt | find /C ":""
for /f %%a in ('!cmd!') do set number=%%a


set "cmd=findstr /R /N "^^" unECMDone.txt | find /C ":""
for /f %%a in ('!cmd!') do set number2=%%a


echo.Done. There are %number% files in the source and %number2% files in the done file, so I hope those match

pause 
ENDLOCAL