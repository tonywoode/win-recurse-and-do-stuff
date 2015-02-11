@echo off
SETLOCAL

:: This script recurses through a directory tree, un 7zipping any 7zip files it finds
:: putting the extracted files in the same dir as the 7zip was, and then deletes the 7zip
:: it doesn't really check much (not sure 7zips errorlevels work well) but it does overwrite
:: existing files which should help if you have to re-run it. At the end it just counts the number
:: of lines in the Done file against the ToDO file, this doesn't guarantee everything in the done
:: worked ok, mind......
::
::set the directory and indeed cd to it to make sure we're in it
set rootDir="E:\PSX_Jap"
cd %rootDir%
::we shall write to some temp files, delete them if they're already there
if exist Done.txt (echo.Found and so deleting Done.txt) & del Done.txt
if exist Problems.txt (echo.Found and so deleting Problems.txt) & del Problems.txt
::now recurse, printing out all 7zips we find. We SHOULD do for /r [path] %%g in (fileset) do(statement)
::but because we'vejust CD-ed to the rootDir we can omit path
(for /r %%G in (*.7z) do echo %%G) > FilesToUn7Zip.txt

echo.******************************
echo.Here are the files I'll Un7Zip, saved as FilesToUn7Zip.txt
echo.******************************
echo.
echo.
type FilesToUn7Zip.txt | more 
echo.
echo.

setlocal enableextensions
set count=0
for /r %%H in (*.7z) do set /a count+=1
echo.The number of files is: %count%
echo.now let's un 7zip the lot, deleting as we go
echo.you sure you want to do this? Close me now if not
pause
::remember this: http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/percent.mspx?mfr=true

for /r %%I in (*.7z) do (
						::very important this bit! Tell 7Z WHERE to extract the files....
						set outputDir="%%~dpI"
						"C:\Program Files\7-Zip\7z.exe" x "%%I" -o"%%~dpI" -aoa 
						::the aoa is assume overwrite always http://sevenzip.sourceforge.jp/chm/cmdline/switches/overwrite.htm, don't use -y for this it doesn't assume yes it assumes skip. 
						if %errorlevel% NEQ 0 (echo."Problem with %%~dpI" > Problems.txt)
						if %errorlevel% EQU 0 (
												(echo.%%I >> Done.txt) & del "%%I"
												)
						)
						
::now its done let's count the lines in the files we made
::http://stackoverflow.com/questions/5664761/how-to-count-no-of-lines-in-text-file-and-store-the-value-into-a-variable-using

setlocal EnableDelayedExpansion
set "cmd=findstr /R /N "^^" FilesToUn7Zip.txt | find /C ":""
for /f %%a in ('!cmd!') do set number=%%a


set "cmd=findstr /R /N "^^" Done.txt | find /C ":""
for /f %%a in ('!cmd!') do set number2=%%a


echo.Done. There are %number% files in the source and %number2% files in the done file, so I hope those match

pause 
ENDLOCAL