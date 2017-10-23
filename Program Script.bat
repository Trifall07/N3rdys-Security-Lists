@echo off

echo Checking for Administrative permissions.
net sessions
if %errorlevel%==0 (
echo Permissions are correct.
) else (
echo No Administrative permissions.
pause
exit
)

title User Scripts - Jerren Trifan - Version 1.0
color 1E

set logpath=C:\Users\%USERNAME%\Desktop\ScriptLog.txt

set "user=dir"
 
:Options
cls
echo.
echo Security Settings :
echo.
echo 1. UltraSearch
echo.
echo 2. OSForensics
echo.
echo 3. Malware Bytes
echo.
echo 4. SysInternals Suite
echo.
echo 5. CCleaner
echo.
echo 6. Nessus
echo.
echo 7. Exit
echo.
echo.

set /p "option=Enter option #: "
if %option%== 1 goto :UltraSearch
if %option%== 2 goto :OSForensics
if %option%== 3 goto :MalwareBytes
if %option%== 4 goto :SysInternals
if %option%== 5 goto :CCleaner
if %option%== 6 goto :Nessus
if %option%== 7 exit
goto :Options


:UltraSearch
cls
echo.
echo Opening UltraSearch through default browser.
explorer "https://www.jam-software.de/ultrasearch/?language=EN"
echo.
pause
goto :Options

:OSForensics
cls
echo.
echo Opening OSForensics through default browser.
explorer "https://www.osforensics.com/download.html"
echo.
pause
goto :Options

:MalwareBytes
cls
echo.
echo Opening Malware Bytes through default browser.
explorer "https://www.malwarebytes.com/mwb-download/thankyou"
echo.
pause
goto :Options

:SysInternals
cls
echo.
echo Opening SysInternals Suite through default browser.
explorer "https://docs.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite"
echo.
pause
goto :Options

:CCleaner
cls
echo.
echo Opening CCleaner through default browser.
explorer "https://www.piriform.com/ccleaner/download/standard"
echo.
pause
goto :Options

:Nessus
cls
echo.
echo Opening Nessus through default browser.
explorer "https://www.tenable.com/products/nessus/select-your-operating-system"
echo.
pause
goto :Options
