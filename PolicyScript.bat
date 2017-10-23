@echo off

echo Checking for Administrative permissions.
net sessions
if %errorlevel%==0 (
echo Permissions are correct.
) else (
echo Not Administrative permissions.
pause
exit
)

title Policy Scripts - Jerren Trifan
color 1E

set logpath=C:\Users\%USERNAME%\Desktop\ScriptLog.txt
set sharepath=C:\Users\%USERNAME%\Desktop\SharedFiles.txt

set runall=false

set "user=dir"
 
:Options
cls
echo.
echo Security Settings:
echo.
echo 1. Disable Remote Desktop
echo.
echo 2. Automatically Update Windows
echo.
echo 3. Change password policies
echo.
echo 4. Enable Firewall
echo.
echo 5. Set Basic Firewall Rules
echo.
echo 6. Set all Audits
echo.	
echo 7. Log Net Shared Files
echo.
echo 8. Stop Services
echo.
echo 9. Block Ports
echo.
echo 10. Change Local Policies
echo.
echo 11. Flush DNS and Clear Host File
echo.
echo 12. Run All Commands
echo.
echo 13. Disable Unneeded Windows Features
echo.
echo 14. Sticky Keys Backup
echo.
echo 15. Exit
echo.
echo.

set /p option=Enter option # : 
if %option%== 1 goto :RemoteDesktop
if %option%== 2 goto :AutomaticUpdates
if %option%== 3 goto :PasswordPolicies
if %option%== 4 goto :EnableFirewall
if %option%== 5 goto :BasicFirewallRules
if %option%== 6 goto :Audit
if %option%== 7 goto :NetShare
if %option%== 8 goto :Services
if %option%== 9 goto :BlockPorts
if %option%== 10 goto :LocalPolicies
if %option%== 11 goto :DNSHost
if %option%== 12 goto :RunAll
if %option%== 13 goto :WindowsFeatures
if %option%== 14 goto :StickyKeys
if %option%== 15 exit
goto :Options


:RemoteDesktop
cls
echo.
@echo 1) Attempting to disable Remote Desktop >> %logpath%
echo "Attempting to disable Remote Desktop"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowTSConnections /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fAllowToGetHelp /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="remote desktop" new enable=no
@echo 1) Remote Desktop Disabled. >> %logpath%
echo "Remote Desktop has been disabled."
if %runall%==true (
	goto :AutomaticUpdates
)
pause
goto :Options

:AutomaticUpdates
cls
echo.
@echo 2) Attempting to enable Automatic Windows Updates >> %logpath%
echo "Attempting to enable Automatic Windows Updates"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 3 /f
echo "Enabled Automatic Windows Updates"
@echo 2) Enabled Automatic Windows Updates >> %logpath%
if %runall%==true (
	goto :PasswordPolicies
)
pause
goto :Options

:PasswordPolicies
cls
@echo 3) Attempting to change password policies >> %logpath%
echo "Changing Password Policies"
REM 8 digit pass
net accounts /minpwlen:8
REM Max age of 30
net accounts /maxpwage:30
REM Min age of 5
net accounts /minpwage:5
REM Password History 5
net accounts /uniquepw:5
REM Account Lockout Threshold
net accounts /lockoutthreshold:5
REM Accoutn Lockout Duration
net accounts /lockoutduration:30
REM Account Lockout Window
net accounts /lockoutwindow:30
echo "The latest policy is: "
net accounts
@echo 3) Password Policies changed. >> %logpath%
PAUSE
echo.
echo "SET PASSWORD COMPLEXITY: Account Policies -> Password Policy -> Password Must meet complexity requirements -> Enabled"
echo "SET REVERSE ENCRYPTION: Account Policies -> Password Policy -> Store passwords using reversible encryption to disabled -> Disabled"
echo.
start secpol.msc /wait
@echo 3) Changed Password Complexity manually. >> %logpath%
if %runall%==true (
	goto :EnableFirewall
)
pause
goto :Options

:EnableFirewall
cls
@echo 4) Attempting to turn on Firewall >> %logpath%
netsh advfirewall set allprofiles state on
@echo 4) Enabled Windows Firewall >> %logpath%
echo.
if %runall%==true (
	goto :BasicFirewallRules
)
pause
goto :Options

:BasicFirewallRules
cls
@echo 5) Attempting to add Basic Firewall Rules. >> %logpath%
echo Attempting to add Basic Firewall Rules.
echo.
netsh advfirewall firewall set rule name="Remote Assistance (DCOM-In)" new enable=no 
netsh advfirewall firewall set rule name="Remote Assistance (PNRP-In)" new enable=no 
netsh advfirewall firewall set rule name="Remote Assistance (RA Server TCP-In)" new enable=no 
netsh advfirewall firewall set rule name="Remote Assistance (SSDP TCP-In)" new enable=no 
netsh advfirewall firewall set rule name="Remote Assistance (SSDP UDP-In)" new enable=no 
netsh advfirewall firewall set rule name="Remote Assistance (TCP-In)" new enable=no 
netsh advfirewall firewall set rule name="Telnet Server" new enable=no 
netsh advfirewall firewall set rule name="netcat" new enable=no
netsh advfirewall firewall set rule name="Remote Desktop - Shadow (TCP-In)" new enable=no 
netsh advfirewall firewall set rule name="Remote Desktop - User Mode (TCP-In)" new enable=no 
netsh advfirewall firewall set rule name="Remote Desktop - User Mode (UDP-In)" new enable=no 
netsh advfirewall firewall set rule name="Remote Desktop - User Mode (TCP-In)" new enable=no
netsh advfirewall firewall set rule name="Network Discovery (UPnP-In)" new enable=no
netsh advfirewall firewall set rule name="Network Discovery (SSDP-In)" new enable=no
echo.
@echo 5) Basic Firewall Rules added. >> %logpath%
echo Basic Firewall Rules added.
if %runall%==true (
	goto :Audit
)
pause
goto :Options

:Audit
cls
echo.
@echo 6) Attempting to changed auditing for all categories. >> %logpath%
echo Attempting to changed auditing for all categories.
auditpol /set /category:* /success:enable
auditpol /set /category:* /failure:enable
@echo 6) Auditing for all categories has been enabled for success and failure. >> %logpath%
echo Auditing for all categories has been enabled for success and failure.
if %runall%==true (
	goto :NetShare
)
pause
goto :Options

:NetShare
cls
echo.
@echo 7) Attempting to get shared network files. >> %logpath%
echo Attempting to get shared network files.

For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
@echo %mydate%_%mytime% > %sharepath%
net share >> %sharepath%
echo Network files obtained. Output is located in SharedFiles.txt on the Desktop.
@echo 7) Network files obtained. Output is located in SharedFiles.txt on the Desktop. >> %logpath%
echo.
if %runall%==true (
	goto :Services
)
pause
goto :Options




:Services
cls
echo.
echo Attempting to disable Remote Access, Telephony, tlntsvr, p2pimsvc, simptcp, msftpsvc services.
@echo 8) Attempting to disable Remote Access, Telephony, tlntsvr, p2pimsvc, simptcp, msftpsvc services. >> %logpath%

	net stop RemoteRegistry
	sc config RemoteRegistry start= disabled

	net stop RemoteAccess
	sc config RemoteAccess start= disabled

	net stop iphlpsvc
	sc config iphlpsvc start= disabled
	
	net stop Telephony
	sc config Telephony start= disabled

	net stop tlntsvr
	sc config tlntsvr start= disabled

	net stop p2pimsvc
	sc config p2pimsvc start= disabled
	
	net stop simptcp
	sc config simptcp start= disabled	

	net stop SSDPSRV
	sc config SSDPSRV start= disabled

	net stop msftpsvc
	sc config msftpsvc start= disabled

echo RemoteAccess RemoteRegistry iphlpsvc Telephony tlntsvr p2pimsvc simptcp SSDPSRV services have been disabled.
@echo 8) RemoteAccess RemoteRegistry iphlpsvc Telephony tlntsvr p2pimsvc simptcp SSDPSRV services have been disabled. >> %logpath%
echo.
if %runall%==true (
	goto :LocalPolicies
)
pause
goto :Options


:BlockPorts
cls
echo.
@echo 9)  Attempting to block ports. >> %logpath%
echo Attempting to block ports.

netsh advfirewall firewall add rule name=”BlockFTP1” protocol=TCP dir=in remoteport=20 action=block
netsh advfirewall firewall add rule name=”BlockFTP2” protocol=TCP dir=in remoteport=21 action=block
netsh advfirewall firewall add rule name=”BlockFTP3” protocol=TCP dir=out remoteport=20 action=block
netsh advfirewall firewall add rule name=”BlockFTP4” protocol=TCP dir=out remoteport=21 action=block

netsh advfirewall firewall add rule name=”BlockSSH1” protocol=TCP dir=out remoteport=22 action=block
netsh advfirewall firewall add rule name=”BlockSSH2” protocol=TCP dir=in remoteport=22 action=block

netsh advfirewall firewall add rule name=”BlockSMTP1” protocol=TCP dir=out remoteport=25 action=block
netsh advfirewall firewall add rule name=”BlockSMTP2” protocol=TCP dir=in remoteport=25 action=block

netsh advfirewall firewall add rule name=”BlockTelnet1” protocol=TCP dir=out remoteport=23 action=block
netsh advfirewall firewall add rule name=”BlockTelnet2” protocol=TCP dir=in remoteport=23 action=block

netsh advfirewall firewall add rule name=”BlockRPC1” protocol=TCP dir=out remoteport=135 action=block
netsh advfirewall firewall add rule name=”BlockRPC2” protocol=TCP dir=in remoteport=135 action=block

netsh advfirewall firewall add rule name=”BlockSNMP1” protocol=UDP dir=out remoteport=161 action=block
netsh advfirewall firewall add rule name=”BlockSNMP2” protocol=UDP dir=in remoteport=161 action=block

netsh advfirewall firewall add rule name=”BlockLDAP1” protocol=TCP dir=out remoteport=389 action=block
netsh advfirewall firewall add rule name=”BlockLDAP2” protocol=TCP dir=in remoteport=389 action=block

netsh advfirewall firewall add rule name=”BlockRIP1” protocol=UDP dir=out remoteport=520 action=block
netsh advfirewall firewall add rule name=”BlockRIP2” protocol=UDP dir=in remoteport=520 action=block

netsh advfirewall firewall add rule name=”BlockPTP1” protocol=TCP dir=out remoteport=411 action=block
netsh advfirewall firewall add rule name=”BlockPTP2” protocol=TCP dir=in remoteport=411 action=block
netsh advfirewall firewall add rule name=”BlockPTP3” protocol=TCP dir=out remoteport=412 action=block
netsh advfirewall firewall add rule name=”BlockPTP4” protocol=TCP dir=in remoteport=412 action=block

netsh advfirewall firewall add rule name=”BlockRDP1” protocol=TCP dir=out remoteport=3389 action=block
netsh advfirewall firewall add rule name=”BlockRDP2” protocol=TCP dir=in remoteport=3389 action=block

netsh advfirewall firewall add rule name=”BlockSSDP1” protocol=UDP dir=out remoteport=1900 action=block
netsh advfirewall firewall add rule name=”BlockSSDP2” protocol=UDP dir=in remoteport=1900 action=block

netsh advfirewall firewall add rule name=”BlockSOCKS1” protocol=TCP dir=out remoteport=1080 action=block
netsh advfirewall firewall add rule name=”BlockSOCKS2” protocol=TCP dir=in remoteport=1080 action=block

@echo 9)  Port blocking rules have been added to the firewall. >> %logpath%
@echo 9)  Ports blocked : 20(FTP),21(FTP),22(SSH),23(TelNet),25(SMTP),135(RPC),161(SNMP),389(LDAP),411(PTP),412(PTP),520(RIP),1080(SOCKS),1900(SSDP). >> %logpath%

echo Port blocking rules have been added to the firewall. Blocked ports have been added to ScriptLog.txt.
echo.
if %runall%==true (
	goto :LocalPolicies
)
pause
goto :Options


:LocalPolicies
cls
@echo 10) Attempting to change local security policies. >> %logpath%
echo Attempting to change local security policies.
echo.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DisableCad /t REG_DWORD /d 0 /f
echo Changed CTRL + ALT + DEL on Login to Enabled.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername /t REG_DWORD /d 1 /f
echo Changed Display last username to Disabled.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ValidateAdminCodeSignatures /t REG_DWORD /d 1 /f
echo Changed Only elevate executables that are signed and validated to Enabled.
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowRemoteRPC /t REG_DWORD /d 0 /f
echo Changed RemoteRPC to Disabled.
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymous /t REG_DWORD /d 1 /f
echo Changed Restrict anonymous from changing Sam account to Enabled.
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymoussam /t REG_DWORD /d 1 /f
echo Changed Restrict anonymous from changing Sam account and shares to Enabled.
reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" /v AddPrinterDrivers /t REG_DWORD /d 1 /f
echo Changed Prevent print driver installs 
reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f
echo Changed Limit local account use of blank passwords to console
reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v auditbaseobjects /t REG_DWORD /d 1 /f
echo Changed Auditing access of Global System Objects
reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v fullprivilegeauditing /t REG_DWORD /d 1 /f
echo Changed Auditing Backup and Restore
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
echo Changed UAC to Enabled (1)
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
echo Changed UAC to Enabled (2)

echo.
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
echo Changed UAC setting Prompt on Secure Desktop
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableInstallerDetection /t REG_DWORD /d 1 /f
echo Changed Enable Installer Detection
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v undockwithoutlogon /t REG_DWORD /d 0 /f
echo Changed Undock without logon
reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v MaximumPasswordAge /t REG_DWORD /d 15 /f
echo Changed Maximum Machine Password Age
reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v DisablePasswordChange /t REG_DWORD /d 1 /f
echo Changed Disable machine account password changes
reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v RequireStrongKey /t REG_DWORD /d 1 /f
echo Changed Require Strong Session Key
reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v RequireSignOrSeal /t REG_DWORD /d 1 /f
echo Changed Require Sign/Seal
reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v SignSecureChannel /t REG_DWORD /d 1 /f
echo Changed Sign Channel
reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v SealSecureChannel /t REG_DWORD /d 1 /f
echo Changed Seal Channel

echo.
reg ADD HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths /v Machine /t REG_MULTI_SZ /d "" /f
echo Remotely accessible registry paths cleared
reg ADD HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedPaths /v Machine /t REG_MULTI_SZ /d "" /f
echo Remotely accessible registry paths and sub-paths cleared
reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v NullSessionShares /t REG_MULTI_SZ /d "" /f
echo Restict anonymous access to named pipes and shares
reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v UseMachineId /t REG_DWORD /d 0 /f
echo Allow to use Machine ID for NTLM

echo.
#Internet explorer stuff
reg ADD "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v EnabledV8 /t REG_DWORD /d 1 /f
echo Changed Smart Screen for IE8
reg ADD "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 1 /f
echo Changed Smart Screen for IE9+
echo.
reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f
reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 1 /f
echo Changed Windows Explorer settings
reg ADD HKLM\SYSTEM\CurrentControlSet\Control\CrashControl /v CrashDumpEnabled /t REG_DWORD /d 0 /f
echo Disabled Dump file creation
reg ADD HKCU\SYSTEM\CurrentControlSet\Services\CDROM /v AutoRun /t REG_DWORD /d 1 /f
echo Disabled Autorun


reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v DisablePasswordCaching /t REG_DWORD /d 1 /f 
echo Disabled Internet Explorer Password Caching

echo.
reg ADD "HKCU\Software\Microsoft\Internet Explorer\Main" /v DoNotTrack /t REG_DWORD /d 1 /f
reg ADD "HKCU\Software\Microsoft\Internet Explorer\Download" /v RunInvalidSignatures /t REG_DWORD /d 1 /f
reg ADD "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN\Settings" /v LOCALMACHINE_CD_UNLOCK /t REG_DWORD /d 1 /t
reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonBadCertRecving /t REG_DWORD /d /1 /f
reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnOnPostRedirect /t REG_DWORD /d 1 /f
reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonZoneCrossing /t REG_DWORD /d 1 /f
echo Disabled Internet Tracking

echo.

schtasks /Delete /TN *
echo Deleted system Tasks.

echo.
@echo 10) Changed local security policies. >> %logpath%
echo Changes to local security policies is complete.
echo.
if %runall%==true (
	goto :DNSHost
)
pause
goto :Options


:DNSHost
cls
echo.
@echo 11) Attempting to Flush DNS and clear hosts file. >> %logpath%
echo Attempting to Flush DNS and clear hosts file.
ipconfig /flushdns
attrib -r -s C:\WINDOWS\system32\drivers\etc\hosts
echo > C:\Windows\System32\drivers\etc\hosts

@echo 11) DNS Flushed and Host file cleared. >> %logpath%
echo DNS Flushed and Host file cleared.
if %runall%==true (
	set runall=false
	echo.
	@echo 13) Run All Scripts has finished. >> %logpath%
	echo Run-all scripts has finished.	
	echo.
	pause
	goto :Options
)
pause
goto :Options

:WindowsFeatures
cls
echo.
@echo 12) Attempting to disable unneeded Windows Features. >> %logpath%
echo Attempting to disable unneeded Windows Features.

REM online list of windows features to disable.

dism /online /disable-feature /featurename:IIS-WebServerRole
dism /online /disable-feature /featurename:IIS-WebServer
dism /online /disable-feature /featurename:IIS-CommonHttpFeatures 
dism /online /disable-feature /featurename:IIS-HttpErrors 

dism /online /disable-feature /featurename:IIS-HttpRedirect 
dism /online /disable-feature /featurename:IIS-ApplicationDevelopment
dism /online /disable-feature /featurename:IIS-NetFxExtensibility
dism /online /disable-feature /featurename:IIS-NetFxExtensibility45

dism /online /disable-feature /featurename:IIS-HealthAndDiagnostics 
dism /online /disable-feature /featurename:IIS-HttpLogging 
dism /online /disable-feature /featurename:IIS-LoggingLibraries 
dism /online /disable-feature /featurename:IIS-RequestMonitor 

dism /online /disable-feature /featurename:IIS-HttpTracing 
dism /online /disable-feature /featurename:IIS-Security 
dism /online /disable-feature /featurename:IIS-URLAuthorization 
dism /online /disable-feature /featurename:IIS-RequestFiltering 
echo 25% Complete
dism /online /disable-feature /featurename:IIS-IPSecurity 
dism /online /disable-feature /featurename:IIS-Performance 
dism /online /disable-feature /featurename:IIS-HttpCompressionDynamic 
dism /online /disable-feature /featurename:IIS-WebServerManagementTools 

dism /online /disable-feature /featurename:IIS-ManagementScriptingTools 
dism /online /disable-feature /featurename:IIS-IIS6ManagementCompatibility 
dism /online /disable-feature /featurename:IIS-Metabase 
dism /online /disable-feature /featurename:IIS-HostableWebCore 

dism /online /disable-feature /featurename:IIS-StaticContent 
dism /online /disable-feature /featurename:IIS-DefaultDocument 
dism /online /disable-feature /featurename:IIS-DirectoryBrowsing 
dism /online /disable-feature /featurename:IIS-WebDAV 

dism /online /disable-feature /featurename:IIS-WebSockets 
dism /online /disable-feature /featurename:IIS-ApplicationInit 
dism /online /disable-feature /featurename:IIS-ASPNET 
dism /online /disable-feature /featurename:IIS-ASPNET45 
echo 50% Complete
dism /online /disable-feature /featurename:IIS-ASP 
dism /online /disable-feature /featurename:IIS-CGI 
dism /online /disable-feature /featurename:IIS-ISAPIExtensions 
dism /online /disable-feature /featurename:IIS-ISAPIFilter 

dism /online /disable-feature /featurename:IIS-ServerSideIncludes 
dism /online /disable-feature /featurename:IIS-CustomLogging 
dism /online /disable-feature /featurename:IIS-BasicAuthentication 
dism /online /disable-feature /featurename:IIS-HttpCompressionStatic 
echo 75% Complete
dism /online /disable-feature /featurename:IIS-ManagementConsole 
dism /online /disable-feature /featurename:IIS-ManagementService 
dism /online /disable-feature /featurename:IIS-WMICompatibility 
dism /online /disable-feature /featurename:IIS-LegacyScripts 

dism /online /disable-feature /featurename:IIS-LegacySnapIn 
dism /online /disable-feature /featurename:IIS-FTPServer 
dism /online /disable-feature /featurename:IIS-FTPSvc 
dism /online /disable-feature /featurename:IIS-FTPExtensibility 

dism /online /disable-feature /featurename:TFTP 
dism /online /disable-feature /featurename:TelnetClient 
dism /online /disable-feature /featurename:TelnetServer 

echo 100% Complete
@echo 12) Disabled unneeded Windows Features. >> %logpath%
echo Disabled unneeded Windows Features.
echo.
pause
goto :Options



:RunAll
cls
set /p choice=Are you sure you would like to run all scripts (excluding StickyKeys and Windows Features)? (y,n):
if %choice%==y (
	echo Running All Policy Scripts
	set runall=true
	goto :RemoteDesktop
)
echo.
pause
goto :Options

:StickyKeys
cls
echo Sticky Keys Backup
echo.
set /p "stickykeys=Do you want to use sticky keys as a backup for your password? (y,n) :"
pause
echo The value of stickykeys is :%stickykeys%
pause
if %stickykeys%==y (
	pause
	echo.
	echo Enabling Sticky Keys Backup.	
	echo.
	pause
	REM Sticky keys helper
	takeown /f cmd.exe >NUL
	takeown /f sethc.exe >NUL
	icacls cmd.exe /grant %USERNAME%:F >NUL
	icacls sethc.exe /grant %USERNAME%:F >NUL
	move sethc.exe sethc.old.exe
	copy cmd.exe sethc.exe
	echo.
	echo Sticky Keys Backup has been enabled. 	
	echo Press shift 5 times at the login screen and use "net user [user] [pass]" to change the password of a user.
	echo This prevents you from getting locked out of your computer.
	echo.
	pause
	goto :Options
) else (
	echo else reached
	pause
	goto :Options
)
echo hi
pause
echo.
pause
goto :Options