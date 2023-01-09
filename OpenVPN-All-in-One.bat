:: =========================================================
:: ����� ������ �������� �������������� �������� ����������
:: ����� ����� -START USER VARS- � -END USER VARS-
:: ���� ������ ������ ���� �������� � ��������� windows-1251
:: =========================================================

@set "TITLE=OpenVPN-All-in-One by RUSViRTuE v1.1.0 [10.01.2023]"
@echo off
setlocal enableextensions enabledelayedexpansion
mode con:cols=130
TITLE %TITLE%
CALL :InitScript
:: ������ ���� �� ����� �������
set "ThisFile=%~0"
:: ������ ���� �� �����, ������ ����� ����������� ���� ������
set "ScriptDir=%~dp0"
:: ������� �������� ������� \
set "ScriptDir=%ScriptDir:~0,-1%"
:START
chcp 1251>nul
:: ---------------------START USER VARS---------------------
:: ���� �� ����� OpenVPN
set "OpenVPN_DIR=C:\Program Files\OpenVPN"
:: ����� ��� �������� ���� ������ � ������������
:: ��� ������� ������� clean-all ��, ��� � ���� �����, ��������!
set "KEY_DIR=%OpenVPN_DIR%\easy-rsa\keys"
:: ������������� ����� �������� ����� �� � ����� ������� �������� (����������/��������/����� ������������, ������� ����� %KEY_DIR%)
:: �����, ������� ����� ��������������
set "backupfolderin=%OpenVPN_DIR%"
:: ����� ��� �������� �������
set "backupfolderout=C:\_Backup\OpenVPN"
:: ��� ������
set "backupfile=OpenVPN_%Year%-%Month%-%Day%_%Hour%-%Minute%-%Second%_%event%.zip"
:: IP-����� �������. ��� �� ����� ������� ��������� IP (��������, 192.168.1.10) ��� �������� ��� (��������, mydomain.com)
set "IP_SERVER=1.2.3.4"
:: ����, �� ������� ����� �������. �� ��������� 1194
set "ovpnport=1194"
:: �������� �������� ������: tcp ��� udp. ������������� �������� �� ��������� udp
:: �����! ������������ � ��������. ������ ���������� ������� �����������
set ovpn_protocol=udp
:: ��� ����������. �� ������������� ������
set "cipher=AES-256-GCM"
:: ������ ����� � ����� ��� �������� ����� ����������� � ����� �����-������� ��� ������ ������� �� �����������.
:: �� ����������� ��� ������������� �������� TLS. � ��������� ������� ��������� ����� ������
:: ������������ ����� (��������, ��� ������� ����� 4096 ��� �������� ������� �����),
:: �� �������� ����������. ������������� �������� 2048
set "KEY_SIZE=2048"
:: server < network > < mask > - ������������� ����������� ������ ���� �������� (DHCP)
:: � ��������� ��������� � ������ ����. ������ ����� �������� ifconfig � ����� ��������
:: ������ � TLS-��������� � ������ TUN, �������������� ������������� ������������ �����������.
:: ��������: server 10.10.10.0 255.255.255.0
:: �������������� ������� ������� ������ � ��������� ����� 10.10.10.1 � 10.10.10.254.
set "dhcpserver=server 10.10.10.0 255.255.255.0"
:: ���� � ����� �������� ���� ���� ����� ���������������� ������
:: ����� ��������, ���� � �������� ������� OpenVPN ����� ��������� ������ Keenetic ��� �� �� ������ dhcp-������ (����� �������� �.11)
set "pushroute=192.168.1.0 255.255.255.0"
:: ��� �����������. ������������ ������ � ����� ����������� ovpn-�����.
:: ����������� �������� �������� ������
set "organization=Roga-i-Kopyta"
:: ----------------------END USER VARS----------------------

:: --------------------START SYSTEM VARS--------------------
:: ���������� (ON) ��� ��� (OFF) �� ��������� ������ �������� ��� �������� ������ �������
:: ������������ � ��������!
:: ����� ����� �������� �������� � �������� ������ �������
set "enableclientlist=ON"
:: �����, ��� ����� ��������� ��������� ����� ������ �������
set "tempdir=%TEMP%"
set "openvpnbin=%OpenVPN_DIR%\bin"
set "openvpnexe=%openvpnbin%\openvpn.exe"
set "openvpngui=%openvpnbin%\openvpn-gui.exe"
set "openvpnguiprocess=openvpn-gui.exe"
set "opensslexe=%openvpnbin%\openssl.exe"
:: ���� �� �����, ��� ����� ��������� ���������������� ���� openssl-1.0.0.cnf
set "keyconfigdir=%OpenVPN_DIR%\easy-rsa"
:: ��� ����� ������������ OpenSSL
:: ���� ������ ����� �������� ������ � easy-rsa v.2.x
:: ��������� easy-rsa v.3.x, ��������, ����� ��������� �����
:: ���� ���� ����������, �� ������ ��� ��� �������
:: �������� �� ������!
set "KEY_CONFIG=%keyconfigdir%\openssl-1.0.0.cnf"
:: ��� ����� �� ������� ���� ������������
set "indextxt=%KEY_DIR%\index.txt"
set "serverkeysdir=%KEY_DIR%\server-keys"
set "clientkeysdir=%KEY_DIR%\client-keys"
:: ��� ���������� ovpn-�����
set "serverovpn=%serverkeysdir%\%SERVER_NAME%.ovpn"
:: ��� ����������� ����������������� ovpn-�����
set "clientovpn=%clientkeysdir%\%CLIENT_NAME%\%organization%.%CLIENT_NAME%.ovpn"
:: ��� ����������� ������ ovpn-�����
set "clientpasstxt=%clientkeysdir%\%CLIENT_NAME%\pass.txt"
:: ��� ����������� ������� ������ ovpn-�����
set "clientnopasstxt=%clientkeysdir%\%CLIENT_NAME%\nopass.txt"
:: ����� ��������� ������ � ������ �������/������� � ���������� ���������� ����� !..! � %..%
set "servername1txt=%tempdir%\servername1.txt"
set "servername2txt=%tempdir%\servername2.txt"
set "clientname1txt=%tempdir%\clientname1.txt"
set "clientname2txt=%tempdir%\clientname2.txt"
:: ��������� ������ ����� ��������� ������������� ����������. �� ��������� ���� �������
:: ��� ������������ �� ������������� ������������ �������� ������.
:: ��� �������� ����� ����� ������ � ��������� ������������
:: ������
set "KEY_COUNTRY=AA"
:: �������
set "KEY_PROVINCE=Province"
:: �����
set "KEY_CITY=City"
:: �����������
set "KEY_ORG=MyOrg"
:: e-mail
set "KEY_EMAIL=mail@mail.com"
set "KEY_CN=server"
set "KEY_NAME=server"
set "KEY_OU=server"
set "PKCS11_MODULE_PATH=server"
set "PKCS11_PIN=1234"
:: ---------------------END SYSTEM VARS---------------------

if "%clientprocess%" == "ON" set "clientprocess=OFF" & GoTo :clientnxt
if "%backupprocess%" == "ON" set "backupprocess=OFF" & GoTo :backupnxt
if "%enableclientlist2%" == "ON" set "enableclientlist=ON"
if "%enableclientlist2%" == "OFF" set "enableclientlist=OFF"

cls
CALL :OpenVPNver
CALL :servicestatus
CALL :OpenVPNgui
CALL :ShowFirewallState
CALL :CheckFirewallRules
CALL :ShowFirewallRules
echo.
echo.
CALL :EchoColor 3 "	�������� ��������:"&echo.
echo.
if "%openvpnexefile%" == "notexist" (
	echo     1 - ������� �� ���� https://openvpn.net/community-downloads/
	echo.
)
echo    10 - ��������� ��������� ����� [WINDOWS PC] (�������� ���� ����������� ������ � ������������)
echo    11 - ��������� ��������� ����� [Keenetic Router] (�������� ���� ����������� ������ � ������������)
echo.
echo    20 - ������� ���������� *.ovpn-����
echo.
echo    30 - �������� ���������� ����������
echo    31 - �������� ������ �� ���������� ������������
echo.
echo    70 - ������ ���� ��������� IP
echo.
echo    88 - �������������� ����� "%backupfolderin%" � ��������� � "%backupfolderout%"
echo    99 - �������� �� (������� ����� "%KEY_DIR%" �� ����� �������������)
echo.
echo Enter - �����
echo.
CALL :EchoColor 3 "�����: "
set "act="
set /P "act="
if "%openvpnexefile%" == "notexist" (
	IF "%act%" == "1" (
		start "" "https://openvpn.net/community-downloads/"
		GoTo :START
	)
)
IF "%act%" == "10" (
 set ServerType=WindowsPC
 GoTo :SERVER_INIT
) else IF "%act%" == "11" (
 set ServerType=KeeneticRouter
 GoTo :SERVER_INIT
) else IF "%act%" == "20" (
 GoTo :CLIENT-CRT1
) else IF "%act%" == "30" (
 GoTo :REVOKE-CRT1
) else IF "%act%" == "31" (
 GoTo :GENERATENEWCRLPEM
) else IF "%act%" == "40" (
 GoTo :OpenVPNServiceAuto
) else IF "%act%" == "41" (
 CALL :OpenVPNServiceManual
 GoTo :START
) else IF "%act%" == "42" (
 GoTo :RestartOpenVPNService
) else IF "%act%" == "43" (
 CALL :StopOpenVPNService
 GoTo :START
) else IF "%act%" == "44" (
 GoTo :RestartOpenVPNgui
) else IF "%act%" == "45" (
 GoTo :KillOpenVPNgui 
) else IF "%act%" == "50" (
 GoTo :FirewallAllProfilesOn
) else IF "%act%" == "51" (
 GoTo :FirewallDomainProfileOn
) else IF "%act%" == "52" (
 GoTo :FirewallPrivateProfileOn
) else IF "%act%" == "53" (
 GoTo :FirewallPublicProfileOn
) else IF "%act%" == "54" (
 GoTo :FirewallAllProfilesOff
) else IF "%act%" == "55" (
 GoTo :FirewallDomainProfileOff
) else IF "%act%" == "56" (
 GoTo :FirewallPrivateProfileOff
) else IF "%act%" == "57" (
 GoTo :FirewallPublicProfileOff
) else IF "%act%" == "58" (
 GoTo :AddFirewallRules
) else IF "%act%" == "59" (
 GoTo :DeleteFirewallRules
) else IF "%act%" == "70" (
 GoTo :PublicIP
) else IF "%act%" == "88" (
 cls
 set "event=add_manual"
 CALL :backup
 GoTo :START
) else IF "%act%" == "99" (
 set "cleanall=manual"
 cls
 CALL :CLEAN-ALL
 GoTo :START
) else IF "%act%" == "" (
 GoTo :EXIT
) else (
 cls
 CALL :EchoColor 4 "[������] �������� �����"&echo.
 timeout /t 3
 echo.
 GoTo :START
)

:InitScript
:: ------------INIT SCRIPT-----------------
:: �������� ������� �� ������ � ������� ��������������
if exist "C:\Windows\Sysnative\*.*" (set "system32dir=C:\Windows\Sysnative") else (set "system32dir=C:\Windows\System32")
"%system32dir%\reg.exe" query "HKU\S-1-5-19">nul 2>&1
if %ERRORLEVEL% equ 1 GoTo :UACPrompt
GoTo :EOF

:UACPrompt
:: �������� ���� ������� ������� (������������ ������ �������� ������� ������� UAC)
mshta "vbscript:CreateObject("Shell.Application").ShellExecute("%~fs0", "", "", "runas", 1) & Close()"
exit /b

:CHECKOPENVPNFILES
if not exist "%openvpnexe%" (
	echo.
	CALL :EchoColor 4 "[X] %openvpnexe% [�����������]"&echo.&echo.
	CALL :EchoColor 4 "��������� ������������ �������� ���� � ������� � ������� ����� openvpn.exe"&echo.
	CALL :EchoColor 4 "��� ������������� �������������� OpenVPN"&echo.&echo.
	CALL :CHECKOPENVPNMENU
	echo.&pause&GoTo :START
) else (
	if not exist "%opensslexe%" (
		echo.
		CALL :EchoColor 4 "[X] %opensslexe% [�����������]"&echo.&echo.
		CALL :EchoColor 4 "��������� ������������ �������� ���� � ������� � ������� ����� openssl.exe"&echo.
		CALL :EchoColor 4 "��� ������������� �������������� OpenVPN � �� ����� ��������� ��������:"&echo.
		CALL :EchoColor 4 "Customize-EasyRSA 3-Will be installed on local hard drive-Install Now"&echo.&echo.
		CALL :CHECKOPENVPNMENU
		echo.&pause&GoTo :START
	))
CALL :checkopensslcnf
GoTo :EOF

:CHECKOPENVPNMENU
CALL :EchoColor 3 "	�������� ��������"&echo.
echo.
CALL :EchoColor 0 "    1 - ������� �� ���� https://openvpn.net/community-downloads/"&echo.
echo.
echo Enter - ��������� �����
echo.
CALL :EchoColor 3 "�����: "
set "act4="
set /P "act4="
IF "%act4%" == "1" (
start "" "https://openvpn.net/community-downloads/"
 GoTo :START
) else IF "%act%" == "" (
 GoTo :START
) else (
 GoTo :START
)
GoTo :EOF

:CHECKINDEXTXT
if not exist "%indextxt%" (
	echo.
	CALL :EchoColor 4 "[X] ���� %indextxt% [�� ���������]"&echo.
	CALL :EchoColor 4 "[X] ���������� ����������� [�� ����������]"&echo.
	CALL :EchoColor 4 "    ������� ��������� ��������� ��������� �����"&echo.&echo.&pause&GoTo :START
)
GoTo :EOF

:OpenVPNver
cls
if exist "%openvpnexe%" (
	set "openvpnexefile=exist"
	for /f "tokens=2 delims==" %%a in ('"wmic datafile where name='%openvpnexe:\=\\%' get Version /value|find "^=""') do set "ver=%%a"
	CALL :EchoColor 2 "[V] %openvpnexe% [����������]	VER.: !ver!"&echo.
) else (
	set "openvpnexefile=notexist"
	CALL :EchoColor 4 "[X] %openvpnexe% [�����������]"&echo.&echo.
	CALL :EchoColor 4 "��������� ������������ �������� ���� � ������� � ������� �����"&echo.
	CALL :EchoColor 4 "��� ������������� �������������� OpenVPN"&echo.&echo.
	)

GoTo :EOF

:servicestatus
set "service_name=OpenVPNService"
sc query %service_name% >NUL
if "%ERRORLEVEL%" == "1060" (
	CALL :EchoColor 6 "[X] ������ OpenVPNService [�� �����������]"&echo.
	GoTo :EOF
) else (
		CALL :EchoColor 2 "[V] ������ OpenVPNService [�����������]"&echo.
	)

for /f "tokens=* delims=" %%a in ('wmic service where name^=^'%service_name%^' get startmode') do (
    for /f "tokens=* delims=" %%b in ("%%a") do (
        if /i not "%%b"=="startmode" (
            if /i not "%%b"=="" (
                set "type=%%b"
            )
        )
    )
)
:: ���������� %type% � ������� �� �����, ��� ��� � ����� ���� �������
if %type% == Auto CALL :EchoColor 2 "[V] ��� ������� ������ OpenVPNService [�������������]	41 - �������"
if %type% == Manual CALL :EchoColor 6 "[-] ��� ������� ������ OpenVPNService [�������]		40 - �������������"
if %type% == Disabled CALL :EchoColor 4 "[X] ��� ������� ������ OpenVPNService [���������]	40 - �������������"
echo.
chcp 437 >NUL
for /F "tokens=3 delims=: " %%H in ('sc query "OpenVPNService" ^| findstr "STATE"') do set "service_state=%%H"
chcp 1251>nul
if "%service_state%" == "RUNNING" CALL :EchoColor 2 "[V] ��������� ������ OpenVPNService [�����������]	42 - �������������; 43 - ����������"
if "%service_state%" == "STOPPED" CALL :EchoColor 6 "[-] ��������� ������ OpenVPNService [�����������]	42 - �������������"
echo.
GoTo :EOF

:OpenVPNgui
if exist "%openvpngui%" (
	TaskList /FI "ImageName EQ %openvpnguiprocess%" | Find /I "%openvpnguiprocess%">nul
	If !ERRORLEVEL! EQU 0 (
		CALL :EchoColor 2 "[V] OpenVPN GUI [�������]				45 - �������; 44 - �������������"
	) else (
		CALL :EchoColor 6 "[-] OpenVPN GUI [�� �������]				44 - �������������"
		)
) else (
		CALL :EchoColor 4 "[X] OpenVPN GUI [�� ����������]"
	)
echo.
GoTo :EOF

:RestartOpenVPNgui
taskkill /F /IM %openvpnguiprocess%
start "" "%openvpngui%"
GoTo :START

:KillOpenVPNgui
taskkill /F /IM %openvpnguiprocess%
GoTo :START

:ShowFirewallState
chcp 437 >nul
@NetSh AdvFirewall Show domainprofile State|Find /I " ON">nul&&(set DomainProfileState=ON)||(set DomainProfileState=OFF)
@NetSh AdvFirewall Show privateprofile State|Find /I " ON">nul&&(set PrivateProfileState=ON)||(set PrivateProfileState=OFF)
@NetSh AdvFirewall Show publicprofile State|Find /I " ON">nul&&(set PublicProfileState=ON)||(set PublicProfileState=OFF)
chcp 1251>nul
if "%DomainProfileState%" == "ON" CALL :EchoColor 2 "[V] ����������. ������� ������ [�������]		55 - ���������; 54 - ��������� ���"
if "%DomainProfileState%" == "OFF" CALL :EchoColor 6 "[-] ����������. ������� ������ [��������]		51 - ��������; 50 - �������� ���"
echo.
if "%PrivateProfileState%" == "ON" CALL :EchoColor 2 "[V] ����������. ������� ������� [�������]		56 - ���������; 54 - ��������� ���"
if "%PrivateProfileState%" == "OFF" CALL :EchoColor 6 "[-] ����������. ������� ������� [��������]		52 - ��������; 50 - �������� ���"
echo.
if "%PublicProfileState%" == "ON" CALL :EchoColor 2 "[V] ����������. ����� ������� [�������]			57 - ���������; 54 - ��������� ���"
if "%PublicProfileState%" == "OFF" CALL :EchoColor 6 "[-] ����������. ����� ������� [��������]		53 - ��������; 50 - �������� ���"
echo.
GoTo :EOF

:FirewallAllProfilesOn
NetSh Advfirewall set allprofiles state on
GoTo :START

:FirewallDomainProfileOn
NetSh Advfirewall set domainprofile state on
GoTo :START

:FirewallPrivateProfileOn
NetSh Advfirewall set privateprofile state on
GoTo :START

:FirewallPublicProfileOn
NetSh Advfirewall set publicprofile state on
GoTo :START

:FirewallAllProfilesOff
NetSh Advfirewall set allprofiles state off
GoTo :START

:FirewallDomainProfileOff
NetSh Advfirewall set domainprofile state off
GoTo :START

:FirewallPrivateProfileOff
NetSh Advfirewall set privateprofile state off
GoTo :START

:FirewallPublicProfileOff
NetSh Advfirewall set publicprofile state off
GoTo :START

:CheckFirewallRules
netsh advfirewall firewall show rule name="OpenVPN Daemon TCP" >nul
if %ERRORLEVEL% EQU 0 (set TCPRule=OK) else (set TCPRule=NOT_OK)
netsh advfirewall firewall show rule name="OpenVPN Daemon UDP" >nul
if %ERRORLEVEL% EQU 0 (set UDPRule=OK) else (set UDPRule=NOT_OK)
GoTo :EOF

:ShowFirewallRules
if "%TCPRule%" == "OK" (
	if "%UDPRule%" == "OK" (
	CALL :EchoColor 2 "[V] OpenVPN � ���������� ����������� [��������]		59 - �������"
	) else (
		CALL :EchoColor 6 "[-] OpenVPN � ���������� ����������� [�� ��������]	58 - ��������"
		)
) else (
	CALL :EchoColor 6 "[-] OpenVPN � ���������� ����������� [�� ��������]	58 - ��������"
	)
echo.
GoTo :EOF

:AddFirewallRules
if "%TCPRule%" == "NOT_OK" (
	netsh advfirewall firewall add rule name="OpenVPN Daemon TCP" protocol=tcp dir=in action=allow program="%openvpnexe%" localport=any enable=yes profile=any
)
if "%UDPRule%" == "NOT_OK" (
	netsh advfirewall firewall add rule name="OpenVPN Daemon UDP" protocol=udp dir=in action=allow program="%openvpnexe%" localport=any enable=yes profile=any
)
GoTo :START

:DeleteFirewallRules
netsh advfirewall firewall delete rule name="OpenVPN Daemon"
netsh advfirewall firewall delete rule name="OpenVPN Daemon TCP"
netsh advfirewall firewall delete rule name="OpenVPN Daemon UDP"
GoTo :START

:OpenVPNServiceAuto
sc config OpenVPNService start= auto
GoTo :START

:OpenVPNServiceManual
CALL :EchoColor 6 "��������� ���� ������� ������ OpenVPNService - �������"&echo.
sc config OpenVPNService start= demand>nul 2>&1
if %type% == Manual (
	CALL :EchoColor 2 "[V] ��� ������� ������� ��� ������ OpenVPNService [����������]"&echo.
) else (
	CALL :EchoColor 4 "[X] ��� ������� ���������� ��� ������� ������� ��� ������ OpenVPNService ��������� [������]"&echo.
	)
echo.
GoTo :EOF

:RestartOpenVPNService
:: ���������� ������ OpenVPN
net stop OpenVPNService && net start OpenVPNService
sc start OpenVPNService
GoTo :START

:StopOpenVPNService
CALL :EchoColor 6 "��������� ������ OpenVPNService"&echo.
net stop OpenVPNService>nul 2>&1
sc stop OpenVPNService>nul 2>&1
if "%service_state%" == "STOPPED" CALL :EchoColor 2 "[V] C����� OpenVPNService [�����������]"
if "%service_state%" == "RUNNING" CALL :EchoColor 4 "[X] ��� ������� ���������� ������ OpenVPNService ��������� [������]"
echo.
GoTo :EOF

:checkopensslcnf
CALL :EchoColor 6 "�������� ������� ����������������� ����� openssl-1.0.0.cnf"&echo.
if exist "%KEY_CONFIG%" (
	CALL :EchoColor 2 "[V] ���� openssl-1.0.0.cnf [������������]"&echo.
) else (
	CALL :EchoColor 4 "[X] ���� openssl-1.0.0.cnf [�����������]"&echo.
	set "dirtocheck=%keyconfigdir%"
	CALL :checkdir
	CALL :createopensslcnf
	if exist "%KEY_CONFIG%" (
		CALL :EchoColor 2 "[V] ���� openssl-1.0.0.cnf [������]"&echo.
	) else (
		CALL :EchoColor 4 "[X] ���� openssl-1.0.0.cnf [�� ������]"&echo.
		CALL :EchoColor 4 "    ������ ������� ����� ���������."&echo.&echo.&pause&GoTo :START
		)
	)
echo.
GoTo :EOF

:: ===============================================================================================
:: �������� ����������������� ����� openssl-1.0.0.cnf
:: ��� ��� ���������, ��� ���� ����������� ������ 2.5.x � ����
CALL :EchoColor 6 "�������� ����������������� ����� openssl-1.0.0.cnf"&echo.
:createopensslcnf
:: ����������� ������ ���� � ������ ������� ��� ����� @echo off, ����� ����������� �������������� �����
:: ��������� � ������ ������� @echo on, � � ���� ����� @echo off
@echo off
set "Key1=# For use with easy-rsa version 2.0 and OpenSSL 1.0.0*"
set "Key2=init = 0"

FOR /F "usebackq skip=2 tokens=1 delims=[]" %%i In (`Find /N /I "%Key1%" "%ThisFile%"`) DO set /A N=%%i-1
>"%KEY_CONFIG%" (FOR /F "usebackq delims=" %%i In (`More +%N% "%ThisFile%"`) DO (
	Echo %%i|Find /I /V "%Key2%"||(<nul set /P Str=%%i&Exit /B 0)
    ))
GoTo :EOF

# For use with easy-rsa version 2.0 and OpenSSL 1.0.0*

# This definition stops the following lines choking if HOME isn't
# defined.
HOME			= .
RANDFILE		= $ENV::HOME/.rnd
openssl_conf		= openssl_init

[ openssl_init ]
# Extra OBJECT IDENTIFIER info:
#oid_file		= $ENV::HOME/.oid
oid_section		= new_oids
engines			= engine_section

# To use this configuration file with the "-extfile" option of the
# "openssl x509" utility, name here the section containing the
# X.509v3 extensions to use:
# extensions		=
# (Alternatively, use a configuration file that has only
# X.509v3 extensions in its main [= default] section.)

[ new_oids ]

# We can add new OIDs in here for use by 'ca' and 'req'.
# Add a simple OID like this:
# testoid1=1.2.3.4
# Or use config file substitution like this:
# testoid2=${testoid1}.5.6

####################################################################
[ ca ]
default_ca	= CA_default		# The default ca section

####################################################################
[ CA_default ]

dir		= $ENV::KEY_DIR		# Where everything is kept
certs		= $dir			# Where the issued certs are kept
crl_dir		= $dir			# Where the issued crl are kept
database	= $dir/index.txt	# database index file.
new_certs_dir	= $dir			# default place for new certs.

certificate	= $dir/ca.crt	 	# The CA certificate
serial		= $dir/serial 		# The current serial number
crl		= $dir/crl.pem 		# The current CRL
private_key	= $dir/ca.key		# The private key
RANDFILE	= $dir/.rand		# private random number file

x509_extensions	= usr_cert		# The extentions to add to the cert

# Extensions to add to a CRL. Note: Netscape communicator chokes on V2 CRLs
# so this is commented out by default to leave a V1 CRL.
# crl_extensions	= crl_ext

default_days	= 3650			# how long to certify for
default_crl_days= 30			# how long before next CRL
default_md	= sha256		# use public key default MD
preserve	= no			# keep passed DN ordering

# A few difference way of specifying how similar the request should look
# For type CA, the listed attributes must be the same, and the optional
# and supplied fields are just that :-)
policy		= policy_anything

# For the CA policy
[ policy_match ]
countryName		= match
stateOrProvinceName	= match
organizationName	= match
organizationalUnitName	= optional
commonName		= supplied
name			= optional
emailAddress		= optional

# For the 'anything' policy
# At this point in time, you must list all acceptable 'object'
# types.
[ policy_anything ]
countryName		= optional
stateOrProvinceName	= optional
localityName		= optional
organizationName	= optional
organizationalUnitName	= optional
commonName		= supplied
name			= optional
emailAddress		= optional

####################################################################
[ req ]
default_bits		= $ENV::KEY_SIZE
default_keyfile 	= privkey.pem
default_md		= sha256
distinguished_name	= req_distinguished_name
attributes		= req_attributes
x509_extensions	= v3_ca	# The extentions to add to the self signed cert

# Passwords for private keys if not present they will be prompted for
# input_password = secret
# output_password = secret

# This sets a mask for permitted string types. There are several options.
# default: PrintableString, T61String, BMPString.
# pkix	 : PrintableString, BMPString (PKIX recommendation after 2004).
# utf8only: only UTF8Strings (PKIX recommendation after 2004).
# nombstr : PrintableString, T61String (no BMPStrings or UTF8Strings).
# MASK:XXXX a literal mask value.
string_mask = nombstr

# req_extensions = v3_req # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName			= Country Name (2 letter code)
countryName_default		= $ENV::KEY_COUNTRY
countryName_min			= 2
countryName_max			= 2

stateOrProvinceName		= State or Province Name (full name)
stateOrProvinceName_default	= $ENV::KEY_PROVINCE

localityName			= Locality Name (eg, city)
localityName_default		= $ENV::KEY_CITY

0.organizationName		= Organization Name (eg, company)
0.organizationName_default	= $ENV::KEY_ORG

# we can do this but it is not needed normally :-)
#1.organizationName		= Second Organization Name (eg, company)
#1.organizationName_default	= World Wide Web Pty Ltd

organizationalUnitName		= Organizational Unit Name (eg, section)
#organizationalUnitName_default	=

commonName			= Common Name (eg, your name or your server\'s hostname)
commonName_max			= 64

name				= Name
name_max			= 64

emailAddress			= Email Address
emailAddress_default		= $ENV::KEY_EMAIL
emailAddress_max		= 40

# JY -- added for batch mode
organizationalUnitName_default = $ENV::KEY_OU
commonName_default = $ENV::KEY_CN
name_default = $ENV::KEY_NAME


# set-ex3			= set extension number 3

[ req_attributes ]
challengePassword		= A challenge password
challengePassword_min		= 4
challengePassword_max		= 20

unstructuredName		= An optional company name

[ usr_cert ]

# These extensions are added when 'ca' signs a request.

# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.

basicConstraints=CA:FALSE

# Here are some examples of the usage of nsCertType. If it is omitted
# the certificate can be used for anything *except* object signing.

# This is OK for an SSL server.
# nsCertType			= server

# For an object signing certificate this would be used.
# nsCertType = objsign

# For normal client use this is typical
# nsCertType = client, email

# and for everything including object signing:
# nsCertType = client, email, objsign

# This is typical in keyUsage for a client certificate.
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

# This will be displayed in Netscape's comment listbox.
nsComment			= "Easy-RSA Generated Certificate"

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer:always
extendedKeyUsage=clientAuth
keyUsage = digitalSignature


# This stuff is for subjectAltName and issuerAltname.
# Import the email address.
# subjectAltName=email:copy

# Copy subject details
# issuerAltName=issuer:copy

#nsCaRevocationUrl		= http://www.domain.dom/ca-crl.pem
#nsBaseUrl
#nsRevocationUrl
#nsRenewalUrl
#nsCaPolicyUrl
#nsSslServerName

[ server ]

# JY ADDED -- Make a cert with nsCertType set to "server"
basicConstraints=CA:FALSE
nsCertType                     = server
nsComment                      = "Easy-RSA Generated Server Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer:always
extendedKeyUsage=serverAuth
keyUsage = digitalSignature, keyEncipherment

[ v3_req ]

# Extensions to add to a certificate request

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment

[ v3_ca ]


# Extensions for a typical CA


# PKIX recommendation.

subjectKeyIdentifier=hash

authorityKeyIdentifier=keyid:always,issuer:always

# This is what PKIX recommends but some broken software chokes on critical
# extensions.
#basicConstraints = critical,CA:true
# So we do this instead.
basicConstraints = CA:true

# Key usage: this is typical for a CA certificate. However since it will
# prevent it being used as an test self-signed certificate it is best
# left out by default.
# keyUsage = cRLSign, keyCertSign

# Some might want this also
# nsCertType = sslCA, emailCA

# Include email address in subject alt name: another PKIX recommendation
# subjectAltName=email:copy
# Copy issuer details
# issuerAltName=issuer:copy

# DER hex encoding of an extension: beware experts only!
# obj=DER:02:03
# Where 'obj' is a standard or added object
# You can even override a supported extension:
# basicConstraints= critical, DER:30:03:01:01:FF

[ crl_ext ]

# CRL extensions.
# Only issuerAltName and authorityKeyIdentifier make any sense in a CRL.

# issuerAltName=issuer:copy
authorityKeyIdentifier=keyid:always,issuer:always

[ engine_section ]
#
# If you are using PKCS#11
# Install engine_pkcs11 of opensc (www.opensc.org)
# And uncomment the following
# verify that dynamic_path points to the correct location
#
#pkcs11 = pkcs11_section

[ pkcs11_section ]
engine_id = pkcs11
dynamic_path = /usr/lib/engines/engine_pkcs11.so
MODULE_PATH = $ENV::PKCS11_MODULE_PATH
PIN = $ENV::PKCS11_PIN
init = 0
:: ----------------------------------------

:CheckKeyDir
if exist "%KEY_DIR%" FOR /F "usebackq" %%f IN (`Dir "%KEY_DIR%\" /b /A:`) DO (
	CALL :EchoColor 4 "[��������] � ����� %KEY_DIR% ��� ������������ �����"&echo.
	CALL :EchoColor 4 "���������� ������ ����������"&echo.
	CALL :EchoColor 4 "��������� ��������� �������� ����� %KEY_DIR%"&echo.
	echo.
	echo.
	CALL :EchoColor 3 "	�������� ��������"&echo.
	echo.
	echo    99 - �������� �� (������� ����� "%KEY_DIR%" �� ����� �������������^)
	echo.
	echo Enter - ��������� �����
	echo.
	CALL :EchoColor 3 "�����: "
	set "act2="
	set /P "act2="
	IF !act2! == 99 (
		CALL :CLEAN-ALL
		GoTo :EOF
		) else IF "!act2!" == "" (
		GoTo :START
		) else (
		cls
		CALL :EchoColor 4 "[������] �������� �����"&echo.
		timeout /t 3
		echo.
		GoTo :CheckKeyDir
	)
) else (
	set "dirtocheck=%KEY_DIR%"
	CALL :checkdir
	)
GoTo :EOF

:SERVER_INIT
cls
CALL :CHECKOPENVPNFILES
cls
echo.
if "%ServerType%" == "WindowsPC" CALL :EchoColor 6 "��������� ��������� ����� [WINDOWS PC] (�������� ���� ����������� ������ � ������������)"&echo.
if "%ServerType%" == "KeeneticRouter" CALL :EchoColor 6 "��������� ��������� ����� [KEENETIC ROUTER] (�������� ���� ����������� ������ � ������������)"&echo.	
echo.
echo.
CALL :EchoColor 3 "	������� ��� �������"&echo.
echo.
CALL :EchoColor 6 "	���������: ���������� �����, ����� � ������� _.-"&echo.
echo.
echo Enter - ��������� �����
echo.
CALL :EchoColor 3 "��� �������: "
set "SERVER_NAME="
set /P "SERVER_NAME="
echo.
>"%servername1txt%" echo !SERVER_NAME!
if exist "%servername1txt%" (
	CALL :EchoColor 2 "[V] servername1.txt - ��� ������� �� ��������� ���� [���������]"&echo.
) else (
	CALL :EchoColor 4 "[X] servername1.txt - ��� ������� �� ��������� ���� [�� ���������]"&echo.
	CALL :EchoColor 4 "    ������ ������� ����� ���������."&echo.&echo.&pause&GoTo :START
	)
>"%servername2txt%" echo %SERVER_NAME%
rem ��� ������ ����� ����������� �� ������, ����� ��� ������� ������������ �� ^ (������)
if exist "%servername2txt%" (
	CALL :EchoColor 2 "[V] servername2.txt - ��� ������� �� ��������� ���� [���������]"&echo.
) else (
	CALL :EchoColor 4 "[X] servername2.txt - ��� ������� �� ��������� ���� [�� ���������]"&echo.
	CALL :EchoColor 4 "    ������ ������� ����� ���������."&echo.&echo.&pause&GoTo :START
	)
fc /B "%servername1txt%" "%servername2txt%" >nul
if %ERRORLEVEL% NEQ 0 GoTO :SERVERNAMEERROR
del /q "%servername1txt%" "%servername2txt%" >nul
IF "%SERVER_NAME%" == "" GoTo :START
@echo !SERVER_NAME!|>nul findstr/bei "[a-z0-9_.-]*"
IF !ERRORLEVEL! NEQ 0 (
	:SERVERNAMEERROR
	cls
	CALL :EchoColor 4 "[������] ��� ������� �������� ����������� �����/�������"&echo.
	timeout /t 10
	GoTo :SERVER_INIT
) else (
		CALL :EchoColor 2 "[V] �������� ����� ������� [��������]"&echo.
	)
echo.

set "event=before_SERVER_INIT_[%SERVER_NAME%]"
CALL :backup

CALL :CheckKeyDir

set "KEY_CN=%SERVER_NAME%"

set "dirtocheck=%serverkeysdir%"
CALL :checkdir

CALL :EchoColor 6 "�������� ������� ����� index.txt"&echo.
rem:>"%indextxt%"
if exist "%indextxt%" (
	CALL :EchoColor 2 "[V] index.txt [������]"&echo.
) else (
	CALL :EchoColor 4 "[X] index.txt [�� ������]"&echo.&echo.&pause&GoTo :START
	)
echo.

CALL :EchoColor 6 "�������� ����� serial � �������� 01"&echo.
echo 01>"%KEY_DIR%\serial"
if exist "%KEY_DIR%\serial" (
	CALL :EchoColor 2 "[V] serial [������]"&echo.
) else (
	CALL :EchoColor 4 "[X] serial [�� ������]"&echo.&echo.&pause&GoTo :START
	)
echo.

CALL :EchoColor 6 "�������� c���������� ��������������� ������, ��������������� 10 ���"&echo.
"%opensslexe%" req -days 3650 -nodes -new -x509 -keyout "%KEY_DIR%\ca.key" -out "%KEY_DIR%\ca.crt" -config "%KEY_CONFIG%" -subj "/C=%KEY_COUNTRY%/ST=%KEY_PROVINCE%/L=%KEY_CITY%/O=%KEY_ORG%/OU=%KEY_OU%/CN=%KEY_CN%/name=%KEY_NAME%/emailAddress=%KEY_EMAIL%"
if %ERRORLEVEL% NEQ 0 (
	CALL :EchoColor 4 "[X] ������ ��� �������� c���������� ��������������� ������"&echo.&echo.&pause&GoTo :START
)
if exist "%KEY_DIR%\ca.key" (
	CALL :EchoColor 2 "[V] ca.key - ���� ������ ������������ [������]"&echo.
) else (
	CALL :EchoColor 4 "[X] ca.key - ���� ������ ������������ [�� ������]"&echo.&echo.&pause&GoTo :START
	)
if exist "%KEY_DIR%\ca.crt" (
	CALL :EchoColor 2 "[V] ca.crt - �������� ���������� ��������������� ������ [������]"&echo.
	rem CALL :EchoColor 2 "[V] CA certificate created [SUCCESFULLY]"&echo.
) else (
	CALL :EchoColor 4 "[X] ca.crt - �������� ���������� ��������������� ������ [�� ������]"&echo.&echo.&pause&GoTo :START
	)	
echo.

CALL :EchoColor 6 "��������� ����� ����� ��������, ������������ ����"&echo.
CALL :EchoColor 6 "� ����� �������� �������� ����� ��������� ����"&echo.
CALL :EchoColor 6 "������� ����� ������ ��������� �����"&echo.
"%opensslexe%" dhparam -out "%KEY_DIR%/dh%KEY_SIZE%.pem" %KEY_SIZE%
if %ERRORLEVEL% NEQ 0 (
	CALL :EchoColor 4 "[X] ������ ��� ��������� ����� dh%KEY_SIZE%.pem"&echo.&echo.&pause&GoTo :START
)
if exist "%KEY_DIR%\dh%KEY_SIZE%.pem" (
	CALL :EchoColor 2 "[V] dh%KEY_SIZE%.pem - DH-���� (���� ����� ��������) [������]"&echo.
	rem CALL :EchoColor 2 "[V] DH-file created [SUCCESFULLY]"&echo.
) else (
	CALL :EchoColor 4 "[X] dh%KEY_SIZE%.pem - DH-���� (���� ����� ��������) [�� ������]"&echo.&echo.&pause&GoTo :START
	)
echo.

CALL :EchoColor 6 "�������� ������������ ����� HMAC ��� �������������� ������ �� DoS-���� � �����"&echo.
CALL :EchoColor 6 "������ � ������ ������ ������ ����� ����� ����� �����"&echo.
"%openvpnexe%" --genkey secret "%KEY_DIR%\ta.key"
chcp 1251>nul
if %ERRORLEVEL% NEQ 0 CALL :EchoColor 4 "[X] ������ ��� �������� ta.key"&echo.&echo.&pause&GoTo :START
if exist "%KEY_DIR%\ta.key" (
	CALL :EchoColor 2 "[V] ta.key - ���� tls-auth [������]"&echo.
) else (
	CALL :EchoColor 4 "[X] ta.key - ���� tls-auth [�� ������]"&echo.&echo.&pause&GoTo :START
	)
echo.

CALL :EchoColor 6 "�������� ������� �� ����������, ������� ����� ������������ � ������� 10 ���"&echo.
CALL :EchoColor 6 "%SERVER_NAME%.key - ��������� ���� ������� OpenVPN, ���������"&echo.
"%opensslexe%" req -days 3650 -nodes -new -keyout "%KEY_DIR%\%SERVER_NAME%.key" -out "%KEY_DIR%\%SERVER_NAME%.csr" -config "%KEY_CONFIG%" -subj "/C=%KEY_COUNTRY%/ST=%KEY_PROVINCE%/L=%KEY_CITY%/O=%KEY_ORG%/OU=%KEY_OU%/CN=%KEY_CN%/name=%KEY_NAME%/emailAddress=%KEY_EMAIL%"
if %ERRORLEVEL% NEQ 0 (
	CALL :EchoColor 4 "[X] ������ ��� �������� ���������� ����� ������� ��� ���������� �����"&echo.&echo.&pause&GoTo :START
)
if exist "%KEY_DIR%\%SERVER_NAME%.csr" (
	CALL :EchoColor 2 "[V] %SERVER_NAME%.csr - ���� ������� �� ������� ����������� ������� [������]"&echo.
	rem CALL :EchoColor 2 "[V] %SERVER_NAME%.csr - certificate sign request created [SUCCESFULLY]"&echo.
) else (
	CALL :EchoColor 4 "[X] %SERVER_NAME%.csr - ���� ������� �� ������� ����������� ������� [�� ������]"&echo.&echo.&pause&GoTo :START
	)
if exist "%KEY_DIR%\%SERVER_NAME%.key" (
	CALL :EchoColor 2 "[V] %SERVER_NAME%.key - ��������� ���� ������� [������]"&echo.
	rem CALL :EchoColor 2 "[V] %SERVER_NAME%.key - created [SUCCESFULLY]"&echo.
) else (
	CALL :EchoColor 4 "[X] %SERVER_NAME%.key - ��������� ���� ������� [�� ������]"&echo.&echo.&pause&GoTo :START
	)
echo.

CALL :EchoColor 6 "������� ������� �� ���������� � ����� ������ ������������. "&echo.
CALL :EchoColor 6 "�������� ���� ����������/����"&echo.
"%opensslexe%" ca -days 3650 -out "%KEY_DIR%\%SERVER_NAME%.crt" -in "%KEY_DIR%\%SERVER_NAME%.csr" -extensions server -config "%KEY_CONFIG%" -batch
if %ERRORLEVEL% NEQ 0 (
	CALL :EchoColor 4 "[X] ������ ��� ������� ����������� �������"&echo.&echo.&pause&GoTo :START
)
if exist "%KEY_DIR%\%SERVER_NAME%.crt" (
	CALL :EchoColor 2 "[V] %SERVER_NAME%.crt - ���������� ������� [������]"&echo.
	rem CALL :EchoColor 2 "[V] %SERVER_NAME%.crt - server`s certificate created [SUCCESFULLY]"
) else (
	CALL :EchoColor 4 "[X] %SERVER_NAME%.crt - ���������� ������� [�� ������]"&echo.&echo.&pause&GoTo :START
	)
echo.

:: �������� ���� *.old-������, ��������� � ���� ��������, ����� �������� ������ ��� �������� ������ � �������
del /q "%KEY_DIR%\*.old">nul 2>&1

CALL :EchoColor 6 "�������� ����������������� %SERVER_NAME%.ovpn-�����"&echo.
:: ����, �� ������� ����� �������
echo port %ovpnport%>"%serverovpn%"
:: �������� ��� �����������
echo proto %ovpn_protocol%>>"%serverovpn%"
:: ������� ���������������� IP �������
echo dev tun>>"%serverovpn%"
:: ��������� ��������� ����
echo %dhcpserver%>>"%serverovpn%"
if "%ServerType%" == "KeeneticRouter" echo push "route %pushroute%" >>"%serverovpn%"
:: ������� � ���������� ������������ ������� �� ��������
if "%ServerType%" == "WindowsPC" echo client-config-dir ccd>>"%serverovpn%"
:: echo ifconfig 10.10.10.1 10.10.10.2>>"%serverovpn%"
:: ��������� �������� �������� ������ �������
echo client-to-client>>"%serverovpn%"
:: ��������� �������� ping �� ��������� ����� ������ ����� ��������� n-������,
:: ���� �� ������� �� ����������� ������� ������.
:: ���������, ���� � ������� 120 ������ �� ���� �������� �� ������ ������,
:: �� ������� ����� �����������.
echo keepalive 10 120>>"%serverovpn%"
:: �������� ������
echo comp-lzo>>"%serverovpn%"
:: �� ������������ ����� ������ ��� ����������� �������
echo persist-key>>"%serverovpn%"
:: ���������� ������ tun/tap ��������� � ������ persist
echo persist-tun>>"%serverovpn%"
:: �������� ����������. ������ ���� ���������� ������/������
echo cipher %cipher%>>"%serverovpn%"
:: ���� � ����
:: if "%ServerType%" == "WindowsPC" echo log openvpn.log>>"%serverovpn%"
:: ���� � ������-�����, � ������� ���������� ���������� � ������� ����������� � ���������� � ����������� TUN/TAP
:: if "%ServerType%" == "WindowsPC" echo status status.log>>"%serverovpn%"
:: ������� �����������
echo verb 4 >>"%serverovpn%"
:: ���� �������� ����������� � 20, �� � ��� ����� ������������ ������ �� 20 ��������� �� ����� ���������
echo mute 20>>"%serverovpn%"
:: echo sndbuf 0 >>"%serverovpn%"
:: echo rcvbuf 0 >>"%serverovpn%"
if "%ovpn_protocol%" == "udp" echo explicit-exit-notify 1 >>"%serverovpn%"

:: ���������� ca.crt � *.ovpn-����
echo ^<ca^>>>"%serverovpn%"
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%KEY_DIR%\ca.crt" ') do set /a "header_line=%%a-1">nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ca.crt">>"%serverovpn%"
)
echo ^</ca^>>>"%serverovpn%"

:: ���������� %server%.crt � *.ovpn-����
echo ^<cert^>>>"%serverovpn%"
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%KEY_DIR%\%SERVER_NAME%.crt" ') do set /a "header_line=%%a-1">nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\%SERVER_NAME%.crt">>"%serverovpn%"
)
echo ^</cert^>>>"%serverovpn%"

:: ���������� %server%.key � *.ovpn-����
echo ^<key^>>>"%serverovpn%"
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN PRIVATE KEY-----" "%KEY_DIR%\%SERVER_NAME%.key" ') do set /a "header_line=%%a-1">nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\%SERVER_NAME%.key">>"%serverovpn%"
)
echo ^</key^>>>"%serverovpn%"

:: ���������� ta.key � *.ovpn-����
echo ^<tls-auth^>>>"%serverovpn%"
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN OpenVPN Static key V1-----" "%KEY_DIR%\ta.key" ') do set /a "header_line=%%a-1">nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ta.key">>"%serverovpn%"
)
echo ^</tls-auth^>>>"%serverovpn%"

:: ���������� dh%KEY_SIZE%.pem" � *.ovpn-����
echo ^<dh^>>>"%serverovpn%"
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN DH PARAMETERS-----" "%KEY_DIR%\dh%KEY_SIZE%.pem" ') do set /a "header_line=%%a-1">nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\dh%KEY_SIZE%.pem">>"%serverovpn%"
)
echo ^</dh^>>>"%serverovpn%"
:: ========== ��������� �������� %server_name%.ovpn-����� ==========

if exist "%serverovpn%" (
	CALL :EchoColor 2 "[V] %serverovpn% [������]"&echo.
) else (
	CALL :EchoColor 4 "[X] %serverovpn% [�� ������]"&echo.
	CALL :EchoColor 4 "    ���������� ������ ������� [����������]"&echo.&echo.&pause&GoTo :START
	)
echo.

:: [����������] ���� �� ������� ��������� ��� � ����������� ������� �����?
echo f|xcopy /y "%KEY_DIR%\%SERVER_NAME%.key" "%serverkeysdir%\%SERVER_NAME%.key" >nul 2>&1
echo f|xcopy /y "%KEY_DIR%\%SERVER_NAME%.crt" "%serverkeysdir%\%SERVER_NAME%.crt" >nul 2>&1
echo f|xcopy /y "%KEY_DIR%\ca.crt" "%serverkeysdir%\ca.crt" >nul 2>&1
echo f|xcopy /y "%KEY_DIR%\ta.key" "%serverkeysdir%\ta.key" >nul 2>&1
echo f|xcopy /y "%KEY_DIR%\dh%KEY_SIZE%.pem" "%serverkeysdir%\dh%KEY_SIZE%.pem" >nul 2>&1
:: echo f|xcopy /y "%serverovpn%" "%serverkeysdir%\%SERVER_NAME%.ovpn" >nul 2>&1

:: set "dirtocheck=%OpenVPN_DIR%\config\ccd"
:: CALL :checkdir

set "event=after_SERVER_INIT_[%SERVER_NAME%]"
CALL :backup

CALL :EchoColor 3 "================================================================================"&echo.
CALL :EchoColor 2 "[V] ��������� ��������� ����� [���������]"&echo.
echo.
echo ���������� ���� "%serverovpn%" � ����� "\OpenVPN\config\" ��� � "\OpenVPN\config-auto\" � ������������� ������/��������� OpenVPN.
echo ���� � ��� ������ Keenetic, �� ���������� ����� ���������� � ������ � ������������� OpenVPN-�����������.
CALL :EchoColor 3 "================================================================================"&echo.
echo.
pause
GoTo :START

:CLIENT-CRT1
cls
echo.
CALL :CHECKOPENVPNFILES
cls
CALL :CHECKINDEXTXT
echo.
CALL :EchoColor 6 "�������� ����������� ����������������� *.OVPN-�����"&echo.
echo.
if "%enableclientlist%" == "OFF" GoTo :skipclientlist
	
	:: �������� ������ ��������
	CALL :EchoColor 6 "	������ ��������:"&echo.
	echo.
	set "xx="
	Set /A y=0
	FOR /F "usebackq skip=1 tokens=1,7 delims=/" %%i In ("%indextxt%") DO (
		Set /A y+=1
		Set "xx=%%j"
		Call Set "x@@%%xx:~3%%=%%xx:~3%%"
		Echo %%i| >nul 2>nul FindStr /B /I /C:"R"&&Call Set "x@@%%xx:~3%%=%%xx:~3%% [�������]"
	)
	If %y% EQU 0 (CALL :EchoColor 4 "[X] ���������� ����������� [�� �������]"&echo. &echo.)
	
	if "%xx%" == "" GoTo :SKIP
	
	Set /A y=0
	FOR /F "usebackq tokens=2 delims==" %%i In (`Set "x@@"^|Sort`) DO (
		Set /A y+=1
		Call Set "@@%%y%%=%%i"
	)
	
	FOR /L %%i In (1,1,%y%) Do (Set "xx=     %%i"&Call Echo %%xx:~-4%%. %%@@%%i%%)
	
	:SKIP
	CALL :EchoColor 3 "================================================================================"&echo.
	echo.
:skipclientlist

CALL :EchoColor 3 "	������� ��� ������ �������"&echo.
echo.
CALL :EchoColor 6 "	���������: ���������� �����, ����� � ������� _.-"&echo.
echo.
if not defined enableclientlist echo     0 - �������� ������ ��������
if "%enableclientlist%" == "OFF" echo     0 - �������� ������ ��������
if "%enableclientlist%" == "ON" echo    00 - ������ ������ ��������
echo.
echo Enter - ��������� �����
echo.
CALL :EchoColor 3 "��� �������: "
set "CLIENT_NAME="
set /P "CLIENT_NAME="
echo.

:: ������������ VARS � ������ ��������, ����� ������������ ��������� ��� ����������
set "clientprocess=ON" & GoTo :START
:clientnxt

>"%clientname1txt%" echo !CLIENT_NAME!
if exist "%clientname1txt%" (
	CALL :EchoColor 2 "[V] clientname1.txt - ��� ������� �� ��������� ���� [���������]"&echo.
) else (
	CALL :EchoColor 4 "[X] clientname1.txt - ��� ������� �� ��������� ���� [�� ���������]"&echo.
	CALL :EchoColor 4 "    ������ ������� ����� ���������."&echo.&echo.&pause&GoTo :START
	)
>"%clientname2txt%" echo %CLIENT_NAME%
rem ��� ������ ����� ����������� �� ������, ����� ��� ������� ������������ �� ^ (������)
if exist "%clientname2txt%" (
	CALL :EchoColor 2 "[V] clientname2.txt - ��� ������� �� ��������� ���� [���������]"&echo.
) else (
	CALL :EchoColor 4 "[X] clientname2.txt - ��� ������� �� ��������� ���� [�� ���������]"&echo.
	CALL :EchoColor 4 "    ������ ������� ����� ���������."&echo.&echo.&pause&GoTo :START
	)
fc /B "%clientname1txt%" "%clientname2txt%" >nul
if %ERRORLEVEL% NEQ 0 GoTO :CLIENTNAMEERROR
del /q "%clientname1txt%" "%clientname2txt%" >nul
IF "%CLIENT_NAME%" == "0" set "enableclientlist=ON"&set "enableclientlist2=ON"&GoTo :CLIENT-CRT1
IF "%CLIENT_NAME%" == "00" set "enableclientlist=OFF"&set "enableclientlist2=OFF"&GoTo :CLIENT-CRT1
IF "%CLIENT_NAME%" == "" GoTo :START
@echo !CLIENT_NAME!|>nul findstr/bei "[a-z0-9_.-]*"
IF !ERRORLEVEL! NEQ 0 (
	:CLIENTNAMEERROR
	cls
	CALL :EchoColor 4 "[������] ��� ������� �������� ����������� �����/�������"&echo.
	timeout /t 10
	GoTo :CLIENT-CRT1
) else (
		CALL :EchoColor 2 "[V] �������� ����� ������� [��������]"&echo.
	)
echo.

CALL :EchoColor 6 "�������� �� ������������ ����� �������"&echo.
find "CN=%CLIENT_NAME%/" "%indextxt%">nul
if %ERRORLEVEL% EQU 0 (
	cls
	CALL :EchoColor 4 "[������] ������ � ������ %CLIENT_NAME% ��� ����������."&echo.
	CALL :EchoColor 4 "	 ���������� ������ ���."&echo.&echo.&pause&GoTo :CLIENT-CRT1
)

:CLIENT-CRT2
cls
echo.
CALL :EchoColor 6 "�������� ����������� ����������������� *.OVPN-�����"&echo.
echo.
echo.
CALL :EchoColor 0 "��� �������: "
CALL :EchoColor 2 "%CLIENT_NAME%"&echo.
echo.
:: �����: a-z0-9_.,-@#$;:?(+=~`'/*
:: ������: "�%\|[]<>!)^& � �������
:: ����������� ������: "|<>&
:: ������������: ^! (���� ������ ������� ������������� �� ��������������� ������ ��� ������ ^, �� ������ � ����� ����� ������^)
CALL :EchoColor 3 "	������� ������ �������"&echo.
echo.
CALL :EchoColor 6 "	���������: ���������� �����, ����� � ������� _.,@#$;:?(+=~`'/*-"&echo.
echo.
CALL :EchoColor 6 "	�����: ���� ������ ����� �������� ������������� �� ��������������� ������"&echo.
CALL :EchoColor 6 "	��� ������ ^, �� ������ � ����� ����� ������"&echo.
echo.
echo Enter - ��� ������
echo.
CALL :EchoColor 3 "������: "
set "CLIENT_PASS="
set /P "CLIENT_PASS="
IF "%CLIENT_PASS%" == "" (
	set "nodes=-nodes"
	set "passout="
	GoTo :CLIENT-CRT3
) else (
	set "nodes="
	set "passout=-passout file:^"%clientpasstxt%^""
	)
@echo !CLIENT_PASS!|>nul findstr/bei "[a-z0-9_.,@#$;:?(+=~`'/*-]*"
if !ERRORLEVEL! NEQ 0 (
	:CLIENTPASSERROR
	cls
	CALL :EchoColor 4 "[������] ������ ������� �������� ����������� �����/�������"&echo.
	timeout /t 10
	cls
	GoTo :CLIENT-CRT2
)

:CLIENT-CRT3
echo.
set "event=before_adding_client_[%CLIENT_NAME%]"
CALL :backup

set "dirtocheck=%clientkeysdir%\%CLIENT_NAME%"
CALL :checkdir

set "KEY_CN=%CLIENT_NAME%"

if "%CLIENT_PASS%" NEQ "" (
	CALL :EchoColor 6 "���������� ������ ������� %CLIENT_NAME% � %clientpasstxt%"&echo.
	chcp 1251>nul
	>"%clientpasstxt%" echo %CLIENT_PASS%
	if exist "%clientpasstxt%" (
		CALL :EchoColor 2 "[V] pass.txt - ������ ������� %CLIENT_NAME% [��������]"&echo.
		set /p passfromtxt=<"%clientpasstxt%"
		if "%CLIENT_PASS%" NEQ "!passfromtxt!" GoTo :CLIENTPASSERROR
	) else (
		CALL :EchoColor 4 "[X] pass.txt - ������ ������� %CLIENT_NAME% [�� ��������]"&echo.
		pause
		)
) else (
	CALL :EchoColor 6 "������ ��� ������� %CLIENT_NAME% �� �����"&echo.
	rem:>"%clientnopasstxt%"
	if exist "%clientnopasstxt%" (
		CALL :EchoColor 2 "[V] %clientnopasstxt% [������]"&echo.
	) else (
		CALL :EchoColor 4 "[X] %clientnopasstxt% [�� ������]"&echo.
		pause
		)
	)
echo.

CALL :EchoColor 6 "�������� ������� �� ����������, ������� ����� ������������ � ������� 10 ���"&echo.
CALL :EchoColor 6 "%CLIENT_NAME%.key - ��������� ���� ������� OpenVPN, ���������"&echo.
"%opensslexe%" req -days 3650 %nodes% -new -keyout "%KEY_DIR%\%CLIENT_NAME%.key" -out "%KEY_DIR%\%CLIENT_NAME%.csr" -config "%KEY_CONFIG%" -subj "/C=%KEY_COUNTRY%/ST=%KEY_PROVINCE%/L=%KEY_CITY%/O=%KEY_ORG%/OU=%KEY_OU%/CN=%KEY_CN%/name=%KEY_NAME%/emailAddress=%KEY_EMAIL%" %passout%
if %ERRORLEVEL% NEQ 0 CALL :EchoColor 4 "[X] ������ ��� �������� ����������� ����� ������� ��� ���������� �����"&echo.&echo.&pause&GoTo :START
if exist "%KEY_DIR%\%CLIENT_NAME%.csr" (
	CALL :EchoColor 2 "[V] %CLIENT_NAME%.csr - ���� ������� �� ������� ����������� ������� [������]"&echo.
	rem CALL :EchoColor 2 "[V] %CLIENT_NAME%.csr - certificate sign request created [SUCCESFULLY]"&echo.
) else (
	CALL :EchoColor 4 "[X] %CLIENT_NAME%.csr - ���� ������� �� ������� ����������� ������� [�� ������]"&echo.
	rem CALL :EchoColor 4 "[X] %CLIENT_NAME%.csr - certificate sign request [NOT CREATED]"&echo.
	echo.&pause&GoTo :START
	)
if exist "%KEY_DIR%\%CLIENT_NAME%.key" (
	CALL :EchoColor 2 "[V] %CLIENT_NAME%.key - ��������� ���� ������� [������]"&echo.
	rem CALL :EchoColor 2 "[V] %CLIENT_NAME%.key created [SUCCESFULLY]"&echo.
) else (
	CALL :EchoColor 4 "[X] %CLIENT_NAME%.key - ��������� ���� ������� [�� ������]"&echo.
	rem CALL :EchoColor 4 "[X] %CLIENT_NAME%.key [NOT CREATED]"&echo.
	echo.&pause&GoTo :START
	)
echo.

CALL :EchoColor 6 "������� ������� �� ���������� � ����� ������ ������������"&echo.
CALL :EchoColor 6 "�������� ���� ����������/����"&echo.
"%opensslexe%" ca -days 3650 -out "%KEY_DIR%\%CLIENT_NAME%.crt" -in "%KEY_DIR%\%CLIENT_NAME%.csr" -config "%KEY_CONFIG%" -batch
if %ERRORLEVEL% NEQ 0 CALL :EchoColor 4 "[X] ������ ��� ������� ����������� �����������"&echo.&echo.&pause&GoTo :START
if exist "%KEY_DIR%\%CLIENT_NAME%.crt" (
	CALL :EchoColor 2 "[V] %CLIENT_NAME%.crt - ���������� ������� [������]"&echo.
	rem CALL :EchoColor 2 "[V] %CLIENT_NAME%.crt - Client`s certificate created [SUCCESFULLY]"&echo.
) else (
	CALL :EchoColor 4 "[X] %CLIENT_NAME%.crt - ���������� ������� [�� ������]"&echo.
	rem CALL :EchoColor 4 "[X] %CLIENT_NAME%.crt - client`s certificate [NOT CREATED]"&echo.
	echo.&pause&GoTo :START
	)
echo.

:: �������� ���� *.old-������, ��������� � ���� ��������, ����� �������� ������ ��� �������� ������ � �������
del /q "%KEY_DIR%\*.old">nul 2>&1

CALL :EchoColor 6 "�������� ����������� ����������������� ����� %CLIENT_NAME%.ovpn"&echo.
:: ���������, ����� ������ ������� ���������� � ������������� � �������
echo client>"%clientovpn%"
:: ������� ���������������� IP �������
echo dev tun>>"%clientovpn%"
:: �������� ��� �����������
echo proto %ovpn_protocol%>>"%clientovpn%"
:: IP-����� ������� � ������
echo remote %IP_SERVER% %ovpnport%>>"%clientovpn%"
:: ������������� ����� � �������� ��� ������� �� ��������� ����� �����.
:: ��������� ������ ���� ������������ DNS-��� ���������� �����.
:: infinite - ����������
echo resolv-retry infinite>>"%clientovpn%"
:: echo nobind>>"%clientovpn%"
:: ��������� �� ������������ ����� ������ ��� ����������� �������
echo persist-key>>"%clientovpn%"
:: ��������� ��� ��������� ���������� tun/tap ��� ����������� OpenVPN
echo persist-tun>>"%clientovpn%"
:: ���� �������� ������� OpenVPN ��������� ����������� ������ � VPN-�������,
:: � �������� ���� ���������� � ��������� EKU X.509, ������������� � �������� TLS Web Server Authentication
echo remote-cert-tls server>>"%clientovpn%"
:: ��������� �������� ����������. ������ ���� ���������� ������/������
echo cipher %cipher%>>"%clientovpn%"
:: �������� ������
echo comp-lzo>>"%clientovpn%"
:: ������� �����������
echo verb 3 >>"%clientovpn%"
:: ���� �������� ����������� � 20, �� � ��� ����� ������������ ������ �� 20 ��������� �� ����� ���������
echo mute 20>>"%clientovpn%"

:: ���������� ca.crt � *.ovpn-����
echo ^<ca^>>>"%clientovpn%"
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%KEY_DIR%\ca.crt" ') do set /a "header_line=%%a-1">nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ca.crt">>"%clientovpn%"
)
echo ^</ca^>>>"%clientovpn%"

:: ���������� %CLIENT_NAME%.crt � *.ovpn-����
echo ^<cert^>>>"%clientovpn%"
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%KEY_DIR%\%CLIENT_NAME%.crt" ') do set /a "header_line=%%a-1">nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\%CLIENT_NAME%.crt">>"%clientovpn%"
)
echo ^</cert^>>>"%clientovpn%"

:: ���������� %CLIENT_NAME%.key � *.ovpn-����
echo ^<key^>>>"%clientovpn%"
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN PRIVATE KEY-----" "%KEY_DIR%\%CLIENT_NAME%.key" ') do set /a "header_line=%%a-1">nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\%CLIENT_NAME%.key">>"%clientovpn%"
)
echo ^</key^>>>"%clientovpn%"

:: ���������� ta.key � *.ovpn-����
echo ^<tls-auth^>>>"%clientovpn%"

for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN OpenVPN Static key V1-----" "%KEY_DIR%\ta.key" ') do set /a "header_line=%%a-1">nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ta.key">>"%clientovpn%"
)
echo ^</tls-auth^>>>"%clientovpn%"
:: ----------��������� �������� %CLIENT_NAME%.ovpn-�����----------

if exist "%clientovpn%" (
	CALL :EchoColor 2 "[V] %clientovpn% [������]"&echo.
) else (
	CALL :EchoColor 4 "[X] %clientovpn% [�� ������]"&echo.
	CALL :EchoColor 4 "    ���������� ������ ������� [����������]"&echo.&echo.&pause&GoTo :START
	)
echo.

:: [����������] ����� �� ����� ���?
echo f|xcopy /y "%KEY_DIR%\%CLIENT_NAME%.key" "%clientkeysdir%\%CLIENT_NAME%\%CLIENT_NAME%.key" >nul
echo f|xcopy /y "%KEY_DIR%\%CLIENT_NAME%.crt" "%clientkeysdir%\%CLIENT_NAME%\%CLIENT_NAME%.crt" >nul
echo f|xcopy /y "%KEY_DIR%\ca.crt" "%clientkeysdir%\%CLIENT_NAME%\ca.crt" >nul
echo f|xcopy /y "%KEY_DIR%\ta.key" "%clientkeysdir%\%CLIENT_NAME%\ta.key" >nul
echo f|xcopy /y "%KEY_DIR%\dh%KEY_SIZE%.pem" "%clientkeysdir%\%CLIENT_NAME%\dh%KEY_SIZE%.pem" >nul

set "event=after_adding_client_[%CLIENT_NAME%]"
CALL :backup

CALL :EchoColor 3 "================================================================================"&echo.
CALL :EchoColor 2 "[V] �������� ����������� ����������������� *.OVPN-�����"&echo.
CALL :EchoColor 2 "    %clientovpn% [���������]"&echo.
echo.
echo ���������� ���� "%clientovpn%" �� ��������� ������� � ����� "\OpenVPN\config\" ��� � "\OpenVPN\config-auto\" � ������������� ������/��������� OpenVPN.
CALL :EchoColor 3 "================================================================================"&echo.
echo.
pause
GoTo :START

:REVOKE-CRT1
:: ����� ����������� �������
cls
CALL :CHECKOPENVPNFILES
cls
CALL :CHECKINDEXTXT
echo.
	Set /A y=0
	FOR /F "usebackq skip=1 tokens=1,7 delims=/" %%i In ("%indextxt%") DO (
		Set /A y+=1
		Set "xx=%%j"
		Call Set "x@@%%xx:~3%%=%%xx:~3%%"
		Echo %%i| >nul 2>nul FindStr /B /I /C:"R"&&Call Set "x@@%%xx:~3%%=%%xx:~3%% [�������]"
	)
	If %y% EQU 0 (CALL :EchoColor 4 "[X] ���������� ����������� [�� �������]"&echo. &echo. &Pause &GoTo :START)
	
	Set /A y=0
	FOR /F "usebackq tokens=2 delims==" %%i In (`Set "x@@"^|Sort`) DO (
		Set /A y+=1
		Call Set "@@%%y%%=%%i"
	)
	
	CALL :EchoColor 6 "����� ����������� �������"&echo.
	echo.
	echo.
	CALL :EchoColor 3 "	������� �����, ��������������� �����������, ������� ��������� ��������"&echo.
	echo.
	FOR /L %%i In (1,1,%y%) Do (Set "xx=     %%i"&Call Echo %%xx:~-4%%. %%@@%%i%%)

	:StartSelectCrt
		echo.
		echo Enter - ��������� �����
		echo.
		CALL :EchoColor 3 "�����: "
		Set "NN="
		Set /P "NN="
		If "%NN%"=="" GoTo :START
		If 1 LEQ %NN% If %NN% LEQ %y% (Call Set "revokeclient=%%@@%NN%%%" &GoTo :EndSelectCrt)
		CALL :EchoColor 4 "[X] ������� �������� �������� "%NN%", ������� ������:"&echo. &GoTo :StartSelectCrt
	:EndSelectCrt
	call set "revokeclient2=%%revokeclient:~0,-10%%"
	if "%revokeclient%" == "%revokeclient2% [�������]" (
		set "revokeclient=%revokeclient2%"
		CALL :EchoColor 4 "[X] ���������� ������� %revokeclient% ��� ����� [�������]"&echo.&echo.&pause&GoTo :REVOKE-CRT1
	)

:REVOKE-CRT2
cls
echo.
CALL :EchoColor 6 "����� ����������� �������"&echo.
echo.
echo.
CALL :EchoColor 3 " 	�� ������������� ������ �������� ���������� �������: "
CALL :EchoColor 2 "%revokeclient%"
CALL :EchoColor 3 "?"&echo.
echo.
echo    00 - ��
echo.
echo Enter - ���
echo.
CALL :EchoColor 3 "�����: "
set "act3="
set /P "act3="
echo.
IF "%act3%" NEQ "00" GoTo :REVOKE-CRT1

:REVOKE-CRT3
CALL :EchoColor 6 "�������� ������� ����������� %revokeclient%.crt � ����� %KEY_DIR%"&echo.
if exist "%KEY_DIR%\%revokeclient%.crt" (
	CALL :EchoColor 2 "[V] ���������� %KEY_DIR%\%revokeclient%.crt [������]"&echo.
) else (
	CALL :EchoColor 4 "[X] ���������� %KEY_DIR%\%revokeclient%.crt [�� ������]"&echo.&echo.&pause&GoTo :REVOKE-CRT1
	)
echo.

CALL :FINDSERVERNAME

set "event=before_REVOKE_client_[%revokeclient%]"
CALL :backup

CALL :EchoColor 6 "����� ����������� %revokeclient%.crt"&echo.
"%opensslexe%" ca -revoke "%KEY_DIR%\%revokeclient%.crt" -config "%KEY_CONFIG%"
if %ERRORLEVEL% EQU 0 (
	CALL :EchoColor 2 "[V] ���������� %revokeclient%.crt [�������]"&echo.
) else (
	CALL :EchoColor 4 "[X] ���������� %revokeclient%.crt [�� �������]"&echo.&echo.&pause&GoTo :REVOKE-CRT1
	)
echo.

CALL :GENERATECRLPEM
CALL :CHECKSERVEROVPN
CALL :DelCrl-verify
CALL :AddCrl-verify

set "event=after_REVOKE_client_[%revokeclient%]"
CALL :backup

CALL :EchoColor 3 "================================================================================"&echo.
CALL :EchoColor 2 "[V] ����� ����������� ������� %revokeclient% [��������]"&echo.
echo.
echo ��� ���������� ��������� � ���� ���������� ���� "%serverovpn%" � ����� "\OpenVPN\config\" ��� � "\OpenVPN\config-auto\" � ������������� ������/��������� OpenVPN.
echo ���� � ��� ������ Keenetic, �� ���������� ����� ���������� � ������ � ������������� OpenVPN-�����������.
CALL :EchoColor 3 "================================================================================"&echo.
echo.
pause
GoTo :START

:FINDSERVERNAME
:: [����������] ���� ��������� ��� �� �������
CALL :EchoColor 6 "����� ����� ���������� ����������������� *.ovpn-�����"&echo.
:: ��������� � ���������� ������ ������
Set /p serverstr=<"%indextxt%"
:: ������� ��� �������
FOR /F "tokens=13 delims=/=" %%i In ("%serverstr%") DO set "SERVER_NAME=%%i"
CALL :EchoColor 2 "[V] ��������� ��� %SERVER_NAME% [�������]"&echo.
echo.
GoTo :EOF

:GENERATECRLPEM
CALL :EchoColor 6 "��������� ����� crl.pem � ����������� �� ���������� ������������"&echo.
:: CALL :EchoColor 6 "rem generate new crl"&echo.
if exist "%KEY_DIR%\crl.pem" set "crlpemyes=�����˨�" & set "crlpemno=�� �����˨�" || set "crlpemyes=������" & set "crlpemno=�� ������"
"%opensslexe%" ca -gencrl -out "%KEY_DIR%\crl.pem" -config "%KEY_CONFIG%"
if %ERRORLEVEL% EQU 0 (
	CALL :EchoColor 2 "[V] %KEY_DIR%\crl.pem [%crlpemyes%]"&echo.
) else (
	CALL :EchoColor 4 "[X] %KEY_DIR%\crl.pem [%crlpemno%]"&echo.&echo.&pause&GoTo :START
	)
echo.
GoTo :EOF

:CHECKSERVEROVPN
CALL :EchoColor 6 "�������� ������� ���������� ����������������� *.ovpn-�����"&echo.
if exist "%serverovpn%" (
	CALL :EchoColor 2 "[V] ���� %serverovpn% [������]"&echo.
) else (
	CALL :EchoColor 4 "[X] ���� %serverovpn% [�� ������]"&echo.
	CALL :EchoColor 4 "[X] �������� ���������� �� ���������� ������������ [�� �������]"&echo.&echo.&pause&GoTo :START
	)
echo.
GoTo :EOF

:DelCrl-verify
CALL :EchoColor 6 "�������� ���������� ���������� �� ���������� ������������ �� ���������� ovpn-�����"&echo.
:: set input file
set "f_in=%serverovpn%"
:: set output file
set "f_out=%serverovpn%.tmp"
set "f_tmp=%TEMP%\tmp.txt"
:: set word for search
set "word3=<crl-verify>"

find "%word3%" "%f_in%" 2>nul >nul
if %ERRORLEVEL% NEQ 0 (
	CALL :EchoColor 2 "[V] � ����� %serverovpn%"&echo.
	CALL :EchoColor 2 "    ���������� �� ���������� ������������ [�� �������]"&echo.
	set "revokeinfo=no"
	echo.
	GoTo :EOF
)
set nStr=0
for /f "delims=" %%a in ('findstr /nrc:"." "%f_in%"') do echo.%%a>>"%f_tmp%"
for /f "tokens=1 delims=:" %%a in ('findstr /nc:"%word3%" "%f_in%"') do (CALL :sum %%a)
del /q "%f_tmp%">nul 2>&1 
del /q "%f_in%">nul 2>&1 
ren "%f_out%" %SERVER_NAME%.ovpn
set "revokeinfo=yes"
CALL :EchoColor 2 "[V] ���������� ���������� �� ���������� ������������ �� �����"&echo.
CALL :EchoColor 2 "    %serverovpn% [�������]"&echo.
echo.
GoTo :EOF
 
:sum
set /a nFns=%1-1
if %nFns% leq 0 (set /a nStr=%1+2&&exit /b) else (set /a n1=nStr&&set /a n2=nFns)
for /l %%i in (%n1%,1,%n2%) do (
    for /f "tokens=1* delims=:" %%m in ('findstr /brc:"%%i:" "%f_tmp%"') do echo.%%n>>"%f_out%"
)
set /a nStr=%1+2
Exit /B

:AddCrl-verify
CALL :EchoColor 6 "���������� ���������� �� ���������� ������������ � ��������� ovpn-����"&echo.
echo ^<crl-verify^>>>"%f_in%"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN X509 CRL-----" "%KEY_DIR%\crl.pem" ') do set /a "header_line=%%a-1">nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\crl.pem">>"%f_in%"
)
echo ^</crl-verify^>>>"%f_in%"
if "%revokeinfo%" == "yes" (
	CALL :EchoColor 2 "[V] ���������� �� ���������� ������������ � �����"&echo.
	CALL :EchoColor 2 "    %serverovpn% [���������]"&echo.
)
if "%revokeinfo%" == "no" (
	CALL :EchoColor 2 "[V] ���������� �� ���������� ������������ � ����"&echo.
	CALL :EchoColor 2 "    %serverovpn% [���������]"&echo.
)
echo.
GoTo :EOF

:GENERATENEWCRLPEM
cls
echo.
CALL :EchoColor 6 "���������� ������ �� ���������� ������������"&echo.
echo.
CALL :FINDSERVERNAME
set "event=before_GENERATECRLPEM"
CALL :backup
CALL :GENERATECRLPEM
CALL :CHECKSERVEROVPN
CALL :DelCrl-verify
CALL :AddCrl-verify
set "event=after_GENERATECRLPEM"
CALL :EchoColor 3 "================================================================================"&echo.
CALL :EchoColor 2 "[V] ���� crl.pem � ����������� �� ���������� ������������ [�����˨�]"&echo.
CALL :EchoColor 2 "[V] ���� %serverovpn% [�����˨�]"&echo.
echo.
echo ��� ���������� ��������� � ���� ���������� ���� "%serverovpn%" � ����� "\OpenVPN\config\" ��� � "\OpenVPN\config-auto\" � ������������� ������/��������� OpenVPN.
echo ���� � ��� ������ Keenetic, �� ���������� ����� ���������� � ������ � ������������� OpenVPN-�����������.
CALL :EchoColor 3 "================================================================================"&echo.
echo.
pause
GoTo :START
 
:checkdir
CALL :EchoColor 6 "�������� ������� ����� %dirtocheck%"&echo.
if exist "%dirtocheck%" (
	CALL :EchoColor 2 "[V] ����� %dirtocheck% ��� [����������]"&echo.
) else (
	CALL :EchoColor 4 "[X] ����� %dirtocheck% [�����������]"&echo.
	CALL :EchoColor 6 "������� �������� ����� %dirtocheck%"&echo.
	mkdir "%dirtocheck%"
	if %ERRORLEVEL% EQU 0 (
		CALL :EchoColor 2 "[V] ����� %dirtocheck% [�������]"&echo.
	) else (
		CALL :EchoColor 4 "[X] �� ������� ������� %dirtocheck%"&echo.
		CALL :EchoColor 4 "[X] ��������� ����� ������� �� ����� %dirtocheck%"&echo.
		echo.&pause&GoTo :START
		)
	)
echo.
GoTo :EOF

:PublicIP
cls
echo.
CALL :EchoColor 6 "��� ������� ��������� �������� (Public) IP-������..."&echo.
for /f %%a in ('powershell Invoke-RestMethod api.ipify.org') do set "PublicIP=%%a"
cls
echo.
if "%PublicIP%" == "+" (
	CALL :EchoColor 4 "[X] ������� (Public) IP-����� �������� [�� �������]"&echo.&echo.
) else (
	CALL :EchoColor 6 "��� ������� (Public) IP-�����:"
	CALL :EchoColor 2 "%PublicIP%"
	set /p "x=%PublicIP%"<nul|Clip
	echo 	(��� ���������� � ����� ������^)
	)
echo.
CALL :EchoColor 3 "================================================================================"&echo.
echo.
CALL :EchoColor 3 "	�������� ��������"&echo.
echo.
echo     1 - ������� https://2ip.ru/
echo     2 - ������� http://api.ipify.org/
echo.
echo Enter - ��������� �����
echo.
CALL :EchoColor 3 "�����: "
set "act5="
set /P "act5="
IF !act5! == 1 (
	start "" "https://2ip.ru/"
) else IF "!act5!" == "2" (
	start "" "http://api.ipify.org/"
) else IF "!act5!" == "" (
	GoTo :START
) else (
	GoTo :START
)
GoTo :START

:backup
CALL :EchoColor 6 "�������� ������..."&echo.
if not exist "%backupfolderin%" (
	CALL :EchoColor 4 "[X] ����� %backupfolderin% [�� ����������]"&echo.
	CALL :EchoColor 4 "    ��������� ������������ �������� ���� � �������"&echo.&echo.&pause&GoTo :START
)
set "dirtocheck=%backupfolderout%"
CALL :checkdir
for /f "delims=." %%i in ('wmic.exe OS get LocalDateTime ^| find "."') do set sDateTime=%%i
set "Year=%sDateTime:~0,4%"
set "Month=%sDateTime:~4,2%"
set "Day=%sDateTime:~6,2%"
set "Hour=%sDateTime:~8,2%"
set "Minute=%sDateTime:~10,2%"
set "Second=%sDateTime:~12,2%"
set "backupprocess=ON" & GoTo :START
:backupnxt

CALL :backup7z

if not exist "%backupfolderout%\%backupfile%" (CALL :backupwinrar)
if not exist "%backupfolderout%\%backupfile%" (CALL :backupmakecab)
if not exist "%backupfolderout%\%backupfile%" (
	CALL :EchoColor 4 "[X] ����� ������� �� �������"&echo.
	timeout /t 5
)
if exist "%backupfolderout%\%backupfile%" (
	CALL :EchoColor 2 "[V] ����� [������]"&echo.
	CALL :EchoColor 2 "    %backupfolderout%\%backupfile%"&echo.
	echo.
	timeout /t 3 >nul 2>&1
)
if "%event%" == "add_manual" CALL :EchoColor 3 "================================================================================"&echo.&echo.&pause
GoTo :EOF

:backup7z
:: 1. ��������� ����������� 7zip, ���� ����������
if exist "C:\Program Files (x86)\7-Zip\7z.exe" set "SevenZIP=C:\Program Files (x86)\7-Zip\7z.exe" & set "SevenZIP_x32x64=x32"
if exist "C:\Program Files\7-Zip\7z.exe" set "SevenZIP=C:\Program Files\7-Zip\7z.exe" & set "SevenZIP_x32x64=x64"
if defined SevenZIP (
	CALL :EchoColor 6 "��������� ���������� 7zip %SevenZIP_x32x64%"&echo.
	"%SevenZIP%" a -ssw -mx5 "%backupfolderout%\%backupfile%" "%backupfolderin%" "%ThisFile%">nul 2>&1
)
GoTo :EOF

:backupwinrar
:: 2. ��������� ����������� Winrar, ���� ����������
if exist "C:\Program Files (x86)\WinRAR\Rar.exe" set "winrar=C:\Program Files (x86)\WinRAR\Rar.exe" & set "winrar_x32x64=32"
if exist "C:\Program Files\WinRAR\Rar.exe" set "winrar=C:\Program Files\WinRAR\Rar.exe" & set "winrar_x32x64=x64"
if defined winrar (
	CALL :EchoColor 6 "��������� ���������� WinRAR %winrar_x32x64%"&echo.
	"%winrar%" a -m5 -ep1 "%backupfolderout%\%backupfile%" "%backupfolderin%" "%ThisFile%">nul 2>&1
)
GoTo :EOF

:: =======================START backupmakecab=======================
:backupmakecab
:: [����������] ���������� ������������ ������� � �����
:: 3. ��������� � ������� ����������������� � windows ���������� makecab
CALL :EchoColor 6 "��������� � ������� ����������������� � windows ���������� makecab"&echo.
CHCP 1251> NUL
:: =================SYSTEM VARS=================
set "WRAPPER_FLAG=0"
set "DDFDIR1=%tempdir%\DIRECT.DDF"
set "DDFDIR2=%tempdir%\MAKECAB.DDF"
set "MAKECABTEMPDDF=%tempdir%\MAKECAB_TEMP.DDF"
set "TMPBAT=%tempdir%\TMP.BAT"
:: ���� �� ���-�����
set "LOGFILE=%tempdir%\MAKECAB.LOG"
:: ���� �� ���-����� � �������, ������� �� ������� �����������
set "LOGFILEERROR=%tempdir%\MAKECAB_ERROR.LOG"
:: ���� �� �����, �� �������� ����� ������������ ���������� �� ������� �����������
set "MONITORINGTXT=%tempdir%\MAKECAB_MONITORING.TXT"
:: ���� �� �������-����������� �� ���-������ makecab
set "MONITORINGCMD=%tempdir%\MAKECAB_MONITORING.CMD"
:: �������� ����� � ���-�����, �� ������� ����� ���������� ������� ���� || �������� ���������
set "WORD1=Win32Error"
set "WORD2=After/Before"
REM DECO is experimental option
set "DECO_FLAG=0"
set "DECO=>>"
set "LTQUOT=("
set "GTQUOT=)"
REM - - - - - - - - -
:: =============END SYSTEM VARS=============

:: ���� ������� �� ������� ��������� �����
IF NOT "%~1"=="" CALL :MAKE_CAB %* /B& GoTo :END

:: if not exist "%backupfolderout%" mkdir "%backupfolderout%"
CALL :DELETETEMPFILESBEFORESTART

CALL :MAKE_CAB /S:"%backupfolderin%" /D:"%backupfolderout%" /N:"%backupfile%" /DECO:">>>" /DECOF:0
GoTo :END

:MAKE_CAB
:: command line research
BREAK> "%TMPBAT%"
FOR %%X IN ( %* ) DO (
FOR /F "usebackq tokens=1,* delims=:" %%A IN ( '%%~X' ) DO (
IF /i "%%A"=="/W" ECHO @set "WRAPPER_FLAG=1">> "%TMPBAT%"
IF /i "%%A"=="/B" ECHO @set "BM=1">> "%TMPBAT%"
IF /i "%%A"=="/H" ECHO @set "HELP_SCREEN=1">> "%TMPBAT%"
IF NOT "%%~B"=="" (
IF /i "%%A"=="/S" ECHO @set "backupfolderin=%%~B">> "%TMPBAT%"
IF /i "%%A"=="/D" ECHO @set "backupfolderout=%%~B">> "%TMPBAT%"
IF /i "%%A"=="/N" ECHO @set "backupfile=%%~B">> "%TMPBAT%"
IF /i "%%A"=="/W" ECHO @set "WRAPPER_FLAG=%%~B">> "%TMPBAT%"
IF /i "%%A"=="/DECOF" ECHO @set "DECO_FLAG=%%~B">> "%TMPBAT%"
IF /i "%%A"=="/DECO" ECHO @set "DECO=%%~B">> "%TMPBAT%"
 ) ) )
CALL "%TMPBAT%"

IF NOT "%HELP_SCREEN%"=="" CALL :HELP_SCREEN & EXIT /B 1

IF NOT "%DECO%"=="" IF "%DECO_FLAG%"=="" set "DECO_FLAG=1"
IF NOT "%DECO%"=="" IF "%DECO_FLAG%"=="0" set DECO=

IF "%backupfolderin%"=="" GoTo :ERRR
set backupfolderinW=
set PATH_2_DIR=
set DRIVE_OF_DIR=
set FOLDER_2_CAB=

CALL :GET_DIRS "%backupfolderin%" backupfolderin backupfolderinW PATH_2_DIR DRIVE_OF_DIR FOLDER_2_CAB
IF ERRORLEVEL 1 GoTo :ERRR
IF %DECO_FLAG% LSS 2 set "LTQUOT=" & set "GTQUOT="
IF "%FOLDER_2_CAB%"=="" set "FOLDER_2_CAB=%DRIVE_OF_DIR%\"
IF "%backupfolderout%"=="" set backupfolderout=%CD%

if exist "%backupfolderin%\" (
FOR /F "usebackq" %%X IN ( `DIR /B "%backupfolderin%"` ) DO GoTo :MAKECAB_CORE
IF "%DNE%"=="" ECHO DIRECTORY "%backupfolderin%" IS EMPTY& GoTo :ERRR
  ) ELSE (ECHO NO DIRECTORY "%backupfolderin%"& GoTo :ERRR)

:MAKECAB_CORE
set "backupfolderin_BASE=%backupfolderin%"
IF "%WRAPPER_FLAG%"=="" set /A "WRAPPER_FLAG=0"

IF %WRAPPER_FLAG% GTR 0 (
set "WRAPPERDIR=%FOLDER_2_CAB%"
set "backupfolderin=%backupfolderinW%\"
 )

set /A "C=0"
set _DIR=
BREAK> "%DDFDIR2%"

REM --------------------
:: ECHO Generate a DDF file via a recursive directory listing:
REM --------------------
CALL :PROCESSING_FOLDERS "%backupfolderin_BASE%"2>nul >nul

ECHO .New Cabinet> "%DDFDIR1%"
ECHO .set GenerateInf=OFF>> "%DDFDIR1%"
ECHO .set Cabinet=ON>> "%DDFDIR1%"
ECHO .set Compress=ON>> "%DDFDIR1%"
ECHO .set UniqueFiles=ON>> "%DDFDIR1%"
ECHO .set MaxDiskSize=1215751680>> "%DDFDIR1%"
ECHO .set RptFileName=nul>> "%DDFDIR1%"
ECHO .set InfFileName=nul>> "%DDFDIR1%"
ECHO .set MaxErrors=1 >> "%DDFDIR1%"

ECHO+
REM --------------------
:RUN
cls
CALL :CREATEMONITORINGCMD
ECHO ����������� ������������� �����: %backupfolderin%
echo.
if exist "%LOGFILEERROR%" (
	echo ��� ����� �� ����� ���� ��������������, ��� ��� ������ ������ ���������.
	echo ��� �� ����� ��������� � �����:
	echo.
	type "%LOGFILEERROR%"
)

MAKECAB /F "%DDFDIR1%" /f "%DDFDIR2%" /d DiskDirectory1="%backupfolderout%" /d CabinetNameTemplate="%backupfile%" /V1>"%LOGFILE%"
REM --------------------

ECHO+
IF NOT "%BM%"=="" GoTo :EOF
IF NOT "%HELP_SCREEN%"=="" GoTo :EOF
:CHECKMONITORING
if exist "%MONITORINGTXT%" (GoTo :CHECKMONITORING)
if exist "%backupfolderout%\%backupfile%" (
	if exist "%LOGFILEERROR%" (
		cls
		setlocal enabledelayedexpansion
		for /f "usebackq" %%S in (`find /c /v ""^<"%LOGFILEERROR%"`) do (set /a NumStr=%%S)
		echo �� �������������� ������: !NumStr!
		echo.
		type "%LOGFILEERROR%"
		echo.
		echo.
		echo ���-����: %LOGFILEERROR%
		set /p "x=%LOGFILEERROR%"<nul|Clip
		echo (���� ���������� � ����� ������^)
		echo.
		echo.
	)
	if not exist "%LOGFILEERROR%" (
		cls
		echo ������ �� ����������
		echo.
	)
	CALL :DELETETEMPFILESAFTERMAKECAB
	timeout /t 3
	GoTo :EOF	
)
if not exist "%backupfolderout%\%backupfile%" (GoTo :RUN)
GoTo :EOF


:PROCESSING_FOLDERS
CALL :FRESEARCH "%backupfolderin_BASE%"
CALL :PROC "%backupfolderin_BASE%" C
CALL :PROC "%_DIR%" C
GoTo :EOF

:FRESEARCH
set "DIRTREE=%~1\"
FOR /F "usebackq tokens=* delims=" %%X IN (`DIR /AD /B "%DIRTREE%" 2^>NUL`) DO (
CALL :PROC "%DIRTREE%%%~X" C
CALL :FRESEARCH "%DIRTREE%%%~X"
 )
GoTo :EOF

:PROC
(set /A %~2+=1
set "_DIR=%~1\"
set "CUR_DIR=%~1"

CALL set "DESTDIR=%%WRAPPERDIR%%%%_DIR:%backupfolderin_BASE%\=%%"

IF %DECO_FLAG% GTR 0 (
CALL set "DESTDIR=|?%DECO%%LTQUOT%%%DESTDIR%%|?"
CALL set "DESTDIR=%%DESTDIR:\=%GTQUOT%\%DECO%%LTQUOT%%%"
CALL set "DESTDIR=%%DESTDIR:\%DECO%%LTQUOT%|?=\%%"
CALL set "DESTDIR=%%DESTDIR:?%DECO%%LTQUOT%|=%%"
CALL set "DESTDIR=%%DESTDIR:|=%%"
CALL set "DESTDIR=%%DESTDIR:?=%%"
 )

IF %C% GTR 0 (
<NUL set /P=">> %DESTDIR%"

ECHO .set DestinationDir="%DESTDIR%">> "%DDFDIR2%"
  FOR /F "usebackq tokens=* delims=" %%# IN (`DIR /A-D /B "%CUR_DIR%" 2^>NUL`) DO (
  <NUL set /P="."
  ECHO "%_DIR%%%#"  /inf=no>> "%DDFDIR2%"
  )
ECHO+
 )
REM - - - - - - -
 )
GoTo :EOF

:GET_DIRS
IF "%~1"=="" EXIT /B 1
set "DNO=%~dpnx1"
set DNO_2=
set DNO_3=
CALL :RMESL "%DNO%" DNO

(set "%~2=%DNO%"
set "%~5=%~d1")
CALL :GET_PARENTF "%DNO%" DNO DNO_2 DNO_3
(set "%~3=%DNO%"
set "%~4=%DNO_2%"
set "%~6=%DNO_3%")
GoTo :EOF

:GET_PARENTF
set "TMPDNO=%~dp1"
CALL :RMESL "%TMPDNO%" TMPDNO
set "%~2=%TMPDNO%"
REM ============================================
IF "%TMPDNO%"=="%~1" (
ECHO %TMPDNO%| FINDSTR /RC:"^.:$"
IF NOT ERRORLEVEL 1 set "%~2="
 )

CALL :GET_PARENTF2 "%~1" %~3 %~4
GoTo :EOF

:GET_PARENTF2
(set "%2=%~pnx1"
set "%3=%~nx1")
GoTo :EOF

:RMESL
set "TMPDNO=%~dpnx1|?"
set "TMPDNO=%TMPDNO:\\|?=%"
set "TMPDNO=%TMPDNO:\|?=%"
set "TMPDNO=%TMPDNO:|?=%"
set "%~2=%TMPDNO%"
GoTo :EOF

:HELP_SCREEN
ECHO %TITLE%
ECHO+
ECHO Cabmaksc [/S:source_dir] [/D:dest_dir] [/N:cab_name] [/W[:[0-1]]] [/DECO:str] [/DECOF:[0..2]] [/H]
ECHO+
PAUSE
GoTo :EOF

:ERRR
ECHO SOME KIND OF ERROR!
ECHO Poke your rake to the keyboard...
PAUSE>NUL

:CREATEMONITORINGCMD
rem:>"%MONITORINGTXT%"
echo @Echo Off>"%MONITORINGCMD%"
echo CHCP 1251^> NUL>>"%MONITORINGCMD%"
echo echo ���������� ���-����� �� ������...>>"%MONITORINGCMD%"
echo echo �� ���������� ��� ����.>>"%MONITORINGCMD%"
echo echo ������ ��������� �� OEM-866 ��� ����������� ������ � �������� ������� ������, ���������� ���������>>"%MONITORINGCMD%"
echo CHCP 866^> NUL>>"%MONITORINGCMD%"
echo :STARTMONITORING>>"%MONITORINGCMD%"
echo find "%WORD2%" "%logfile%" 2^>nul ^>nul>>"%MONITORINGCMD%"
echo if %%ERRORLEVEL%% EQU 0 (del /q "%MONITORINGTXT%"^&^&exit)>>"%MONITORINGCMD%"
echo find "%WORD1%" "%logfile%" 2^>nul ^>nul>>"%MONITORINGCMD%"
echo if %%ERRORLEVEL%% NEQ 0 (GoTo :STARTMONITORING)>>"%MONITORINGCMD%"
echo :: ����������� ���������� �������� �� ����� 1�, ����� ����������� ��������� ���-����>>"%MONITORINGCMD%"
echo timeout /t 1 2^>nul ^>nul>>"%MONITORINGCMD%"
echo taskkill /F /IM makecab.exe>>"%MONITORINGCMD%"
echo :: ������� �� ������ �� ��������� ����, ������� ����� ������ ���������>>"%MONITORINGCMD%"
echo for /f "tokens=* delims=" %%%%A in ('find /n /i "%WORD1%" "%logfile%"'^) do set "busyfile=%%%%A">>"%MONITORINGCMD%"
echo CALL set "busyfile=%%%%busyfile:*retrying =%%%%">>"%MONITORINGCMD%"
echo type "%DDFDIR2%" ^| ^>"%MAKECABTEMPDDF%" findstr /i /v /l /c:"%%busyfile%%">>"%MONITORINGCMD%"
echo echo %%busyfile%%^>^>"%LOGFILEERROR%">>"%MONITORINGCMD%"
echo del /q "%DDFDIR2%">>"%MONITORINGCMD%"
echo rename "%MAKECABTEMPDDF%" MAKECAB.DDF>>"%MONITORINGCMD%"
echo del /q "%MONITORINGTXT%">>"%MONITORINGCMD%"
echo exit>>"%MONITORINGCMD%"
start "" /min "%MONITORINGCMD%"
GoTo :EOF

:DELETETEMPFILESBEFORESTART
del /q "%DDFDIR1%" "%DDFDIR2%" "%MAKECABTEMPDDF%" "%LOGFILE%" "%LOGFILEERROR%" "%MONITORINGTXT%" "%MONITORINGCMD%" "%TMPBAT%" "%servername1txt%" "%servername2txt%" "%clientname1txt%" "%clientname2txt%" 2>nul >nul
GoTo :EOF

:DELETETEMPFILESAFTERMAKECAB
del /q "%DDFDIR1%" "%MONITORINGCMD%" "%TMPBAT%" "%tempdir%\cab_*" "%tempdir%\inf_*" "%TMPBAT%" 2>nul >nul
GoTo :EOF


:END
GoTo :EOF
:: =======================END backupmakecab=======================

:CLEAN-ALL
:: [����������] �������� openvpngui.exe � �������� ���� �� ������ ������������� ������ � ��������� ��������� ����� ��������
if "%cleanall%" == "manual" CALL :EchoColor 6 "�������� ����� %KEY_DIR%"&echo.&echo.

CALL :EchoColor 6 "�������� ��������� ������ OpenVPNService"&echo.
if "%service_state%" == "RUNNING" (
	CALL :StopOpenVPNService
) else (
	CALL :EchoColor 2 "[V] C����� OpenVPNService [�����������]"&echo.
	)
echo.

CALL :EchoColor 6 "�������� ���� ������� ������ OpenVPNService"&echo.
if not %type% == Manual (
	CALL :OpenVPNServiceManual
) else (
	CALL :EchoColor 2 "[V] ��� ������� ��� ������ OpenVPNService [�������]"&echo.
	)
echo.

set "event=before_CLEAN-ALL"
CALL :backup

if exist "%KEY_DIR%" (
	CALL :EchoColor 2 "[V] ����� %KEY_DIR% [�������]"&echo.&echo.
	rem [Ru] ������� ���������� ����� %KEY_DIR% ��� ������ �������
	rem [En] delete the %KEY_DIR% and any subdirs quietly
	CALL :EchoColor 6 "�������� ����� %KEY_DIR%"&echo.
	rmdir /s /q "%KEY_DIR%" >nul 2>&1
	if %ERRORLEVEL% EQU 0 (
		CALL :EchoColor 2 "[V] ����� %KEY_DIR% [�������]"&echo.
	) else (
		CALL :EchoColor 4 "[X] ����� %KEY_DIR% [�� �������]"&echo.&echo.&pause
		)
) else (
	CALL :EchoColor 4 "[X] ����� %KEY_DIR% [�� �������]"&echo.
	)
if "%cleanall%" == "manual" CALL :EchoColor 3 "================================================================================"&echo.&set "cleanall=auto"&echo.&pause
GoTo :EOF
 
:EXIT
Exit

:: ===========================================================================================================
:: ����� �������� ������. ����������� - �� ��������� ��������������� ����, ��������� ����������� ���������.
:: ������ � �����, ��� ����� ������� ����������
:: https://www.cyberforum.ru/cmd-bat/thread830030.html#post5146726
:: ����� Anonym�us (�� �� Inquisitor), ��������� ���� ��������� ��������� �������,
:: ����� �� ����� �����������, ��� ������������� ���������� �����, ������ �� �������� ������� � �����������.
:: ����������� ��������� ��� (����� "!" � "%"), ��������� ����� �� ��������� - ����������� ���� � ����.
:: �� ���� � ������: ���� ����� ���������� ������ ������ � ������� ����, ������ ����� ������������ �����������.
:: ����� ������ � ������� ���������� - �� �������� ��� XP (���������� findstr � XP ������� 0x08 � ����
:: ���������� �������, ��������������, ������� ������ ����, �� c ����� ������, ������ ������).
:: ������������� �� Win 7 (x86\x64), Win Server 2008r2. ��� XP ������� ����� ������ ����������� �������������.
:: ������������ ��������� ���������:
:: ������� ��������� ����� ������: CyberMuesli, [url]http://forum.oszone.net/showpost.php?p=2164186[/url]
:: ��������� 0x08: jeb, [url]http://www.dostips.com/forum/viewtopic.php?p=6827#p6827[/url]
:: ���� �������� ���������� ����������: Diskretor, [url]http://forum.oszone.net/post-2201046-7.html[/url]
:: ===========================================================================================================
:EchoColor [%1=Color %2="Text" %3=/n (CRLF, optional)] (Support multiple arguments at once)
chcp 866 >nul

If Not Defined multiple If Not "%~4"=="" (
	CALL :EchoWrapper %*
	set multiple=
	Exit /B
)
setLocal EnableDelayedExpansion
If Not Defined BkSpace CALL :EchoColorInit
:: ������������� ��������� ������ �� �������� � ������ ������, ������ ��������� ��������.
set "$Text=%~2"
set "$Text=.%BkSpace%!$Text:\=.%BkSpace%\..\%BkSpace%%BkSpace%%BkSpace%!"
set "$Text=!$Text:/=.%BkSpace%/..\%BkSpace%%BkSpace%%BkSpace%!"
set "$Text=!$Text:"=\"!"
set "$Text=!$Text:^^=^!"
:: ���� XP, ������� ������� �����.
If "%isXP%"=="true" (
	<nul set /P "=.!BkSpace!%~2"
	GoTo :unsupported
)
:: ������ ����� �� stdout, �� �������� ��������� ������ � ��������� ���� � ����.
:: � ������ ������� (����������\������� ������� ����?) ������� ����� as is, ��� ���������.
:: ���� �������������� ����� ������ (���� ��� ��������� ��� �������) ��������� ������ �������,
:: �� ����� ���� ����� ���������. �� �������� ������� ������� ������� ���������� ������.
PushD "%~dp0"
2>nul FindStr /R /P /A:%~1 "^-" "%$Text%\..\%~nx0" nul
If !ERRORLEVEL! GTR 0 <nul set /P "=.!BkSpace!%~2"
PopD
:: ������� ����, ��� ����� � ����� � ������� ������������ ����� ���������� ��������.
For /L %%A In (1,1,!BkSpaces!) Do <nul set /P "=!BkSpace!"
:unsupported
:: ������� CRLF, ���� ������ ������ ��������.
If /I "%~3"=="/n" echo.
EndLocal
chcp 1251>nul
GoTo :EOF

:EchoWrapper
:: ��������� ���������� ���������
setLocal EnableDelayedExpansion
:NextArg
set multiple=true
:: �� �� ��� �������� "^" ��� �������� ����������...
set $Text=
set $Text=%2
set "$Text=!$Text:^^^^=^!"
If Not "%~3"=="" If /I Not "%~3"=="/n" (
	Shift&Shift
	CALL :EchoColor %1 !$Text!
	GoTo :NextArg
) Else (
	Shift&Shift&Shift
	CALL :EchoColor %1 !$Text! %3
	GoTo :NextArg
)
If "%~3"=="" CALL :EchoColor %1 !$Text!
EndLocal
GoTo :EOF

:EchoColorInit
:: �������������� ��� ������ ������� ������������ ������� ������������� ������ ����������
:: �����! ��� XP, � ���� ���������� ��������� findstr, 0x08 � ����� �� ��������, ��������� �� �����. ��������� ������� ����� ��� XP.
For /F "tokens=2 delims=[]" %%A In ('Ver') Do (For /F "tokens=2,3 delims=. " %%B In ("%%A") Do (If "%%B"=="5" set isXP=true))
:: �������� ���������� "0x08 0x20 0x08" � ������� prompt
For /F "tokens=1 delims=#" %%A In ('"Prompt #$H# & Echo On & For %%B In (1) Do rem"') Do set "BkSpace=%%A"
:: ������������ ��������� ���������� �������� ��� ���������� �����, ����� ���������� ������
set ScriptFileName=%~nx0
CALL :StrLen ScriptFileName
set /A "BkSpaces=!strLen!+6"
GoTo :EOF

:StrLen [%1=VarName (not VALUE), ret !strLen!]
:: ��������� ����� ������
set StrLen.S=A!%~1!
set StrLen=0
For /L %%P In (12,-1,0) Do (
	set /A "StrLen|=1<<%%P"
	For %%I In (!StrLen!) Do If "!StrLen.S:~%%I,1!"=="" set /A "StrLen&=~1<<%%P"
)
GoTo :EOF

:: ��� ������ ������ ���� ��������� � �� ������������ �� CRLF.
-