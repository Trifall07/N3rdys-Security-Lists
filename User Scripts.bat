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

title User Scripts - Jerren Trifan
color 1E

set logpath=C:\Users\%USERNAME%\Desktop\ScriptLog.txt

set "user=dir"
 
:Options
cls
echo.
echo Security Settings :
echo.
echo 1. View NetUser Account Details
echo.
echo 2. CHANGE Account Name
echo.
echo 3. CHANGE Account password
echo.
echo 4. Add/Remove Administrator Status
echo.
echo 5. ENABLE a User/Account
echo.
echo 6. DISABLE a User/Account
echo.
echo 7. DELETE a user/account
echo.
echo 8. Exit
echo.
echo.

set/p "option=Enter option #: "
if %option%== 1 goto :NetDetails
if %option%== 2 goto :NameChange
if %option%== 3 goto :PasswordChange
if %option%== 4 goto :AdminStatus
if %option%== 5 goto :EnableUser
if %option%== 6 goto :DisableUser
if %option%== 7 goto :DeleteUser
if %option%== 8 exit
goto :Options


:NetDetails
cls
echo.
echo.
echo Viewing Account Details
echo.
echo -----------------------
echo.
wmic useraccount get name
echo.
set /p user=Enter the User's name:
if %user%==exit (
	goto :Options
) 
cls
@echo User Scripts - 1) Getting Net User Details. >> %logpath%
echo "Attempting to get Net User Details"
echo.
net user %user%
echo.
@echo User Scripts - 1) Net User Details retrieved. >> %logpath%
echo "Net User Details retrieved."
pause
goto :Options

:PasswordChange
cls
echo.
echo.
echo Changing Account Password
echo.
echo -------------------------
echo.
wmic useraccount get name
echo.
set /p user=Enter the User to change password for: 
if %user%==exit (
	goto :Options
)
echo.
set /p pass=Enter the User's new password:
if %user%==exit (
	goto :Options
) 
@echo User Scripts - 2) Attempting to change password for %user% to %pass%. >> %logpath%
echo "Attempting to change password for %user% to %pass%"
echo.
net user %user% %pass%
echo.
@echo User Scripts - 2) Changed password for %user% to %pass% >> %logpath%
echo "Changed password for %user% to %pass%"
pause
goto :Options

:NameChange
cls
echo.
echo.
echo Changing Account Name
echo.
echo ---------------------
echo.
wmic useraccount get name
echo.
set /p user=Enter the User's name: 
echo.
set /p name=Enter new name: 
cls
@echo User Scripts - 3) Attempting to change Username for %user% to %name%. >> %logpath%
echo "Attempting to change Username of %user% to %name%."
echo.
wmic useraccount where name='%user%' rename %name%
echo.
@echo User Scripts - 3) Changed Username for %user% to %name%. >> %logpath%
echo "Changed Username of %user% to %name%."
pause
goto :Options

:EnableUser
cls
echo.
echo.
echo Enabling a User
echo.
echo ---------------
echo.
wmic useraccount get name
echo.
set /p user=Enter the User's name:
if %user%==exit (
	goto :Options
)
cls
echo.
@echo User Scripts - 4) Attempting to Enable %user%'s account. >> %logpath%
echo "Attempting to Enable %user%'s account."
echo. 
net user %user% /active:yes
echo.
@echo User Scripts - 4) %user%'s account has been Enabled. >> %logpath%
echo "%user%'s account has been Enabled."
pause
goto :Options

:DisableUser
cls
echo.
echo.
echo Disabling a User
echo.
echo ----------------
echo.
wmic useraccount get name
echo.
set /p user=Enter the User's name:
if %user%==exit (
	goto :Options
)
cls
echo.
@echo User Scripts - 5) Attempting to Disable %user%'s account. >> %logpath%
echo "Attempting to Disable %user%'s account."
echo.
net user %user% /active:no
echo.
@echo User Scripts - 5) %user%'s account has been Disabled. >> %logpath%
echo "%user%'s account has been Disabled. WRITE THIS DOWN IN LIST" 
pause
goto :Options

:AdminStatus
cls
echo.
echo.
echo Changing Admin Status of a User
echo.
echo -------------------------------
echo.
net localgroup Administrators
echo.
set /p user=Enter the User's name: 
if %user%==exit (
	goto :Options
)
echo.
set /p choice=Add or remove admin access? (a, r): 
if %choice%==exit (
	goto :Options
)
echo.
if %choice%==a (
	@echo User Scripts - 6 (a)) Attempting to add Administrator access to %user%'s account. >> %logpath%
	echo "Attempting to add Administrator access to %user%'s account."
	echo.
	net localgroup administrators %user% /add
	echo.
	@echo User Scripts - 6 (a)) Added Administrator access to %user%'s account. >> %logpath%
	echo "Added Administrator access to %user%'s account."
	) 
if %choice%==r (
	@echo User Scripts - 6 (r)) Attempting to remove Administrator access to %user%'s account. >> %logpath%
	echo "Attempting to remove Administrator access to %user%'s account."
	echo.
	net localgroup administrators %user% /delete
	echo.
	@echo User Scripts - 6 (r)) Removed Administrator access to %user%'s account. >> %logpath%
	echo "Removed Administrator access to %user%'s account."
	) 
pause
goto :Options

:DeleteUser
cls
echo.
echo.
echo DELETING a User
echo.
echo ---------------
echo.
wmic useraccount get name
echo.
set /p user=Enter the User's name:
if %user%==exit (
	goto :Options
) 
echo.
set /p selection=Are you sure you want to DELETE the account, as well as its files? (y,n):
if %selection%==exit (
	goto :Options
) 
echo.
if %selection%==y(
	@echo User Scripts - 7) Attempting to delete %user%'s account. >> %logpath%
	echo "Attempting to delete %user%'s account."
	echo.
	net user %user% /DELETE
	echo.
	@echo User Scripts - 7) Deleted %user%'s account. >> %logpath%
	echo "Deleted %user%'s account."
	) 
if %selection%==n goto :Options
pause
goto :Options