@echo off
setlocal enableextensions enabledelayedexpansion
TITLE OpenVPN-All-in-One by RUSViRTuE v1.0.2 [26.12.2022]
:START
:: -------------VARS--------------
:: �������� ���祭�� ��६�����
:: IP-���� �ࢥ�. ����� 㪠���� � ������� IP (���ਬ��, 192.168.1.10), � �������� ��� (���ਬ��, mydomain.com)
set "IP_SERVER=1.2.3.4"
:: ����, �� ���஬ �㤥� �����
set "ovpnport=1194"
:: server < network > < mask > - ��⮬���᪨ ��ᢠ����� ���� �ᥬ �����⠬ (DHCP)
:: � 㪠������ ��������� � ��᪮� ��. ������ ���� ������� ifconfig � ����� ࠡ�⠥��
:: ⮫쪮 � TLS-�����⠬� � ०��� TUN, ᮮ⢥��⢥��� �ᯮ�짮����� ���䨪�⮢ ��易⥫쭮.
:: ���ਬ��: server 10.10.10.0 255.255.255.0
:: ������稢訥�� ������� ������ ���� � ��������� ����� 10.10.10.1 � 10.3.0.254.
set "dhcpserver=server 10.10.10.0 255.255.255.0"
:: ���� � ��᪠ ����譥� �� �㤠 �㤥� ��७��ࠢ������ ��䨪
:: �㤥� ࠡ����, �᫨ � ����⢥ �ࢥ� OpenVPN �㤥� ����㯠�� ���� Keenetic
set "pushroute=192.168.1.0 255.255.255.0"
:: ������������ ��⠢��� �� 㬮�砭�� udp
:: �����! ���⢨⥫�� � ॣ�����. ���쪮 �����쪨�� �㪢��� ����᪠����
set ovpn_protocol=udp
:: ��� ��஢����. �� ४��������� ������
set "cipher=AES-256-GCM"
:: ����� ��� �࠭���� ����� ����� OpenVPN
:: ��⮬���᪨ �㤥� �������� ��� ����� %OpenVPN_DIR% 
:: �� � ��᫥ ������� ����⢨� (����������/㤠�����/��� ���䨪�⮢, ���⪠ ����� %KEY_DIR%)
Set "backupfolder=C:\_Backup\OpenVPN"
:: ���� �� ����� OpenVPN
set "OpenVPN_DIR=C:\Program Files\OpenVPN"
set "openvpnexe=%OpenVPN_DIR%\bin\openvpn.exe"
set "openvpngui=%OpenVPN_DIR%\bin\openvpn-gui.exe"
set "openvpnguiprocess=openvpn-gui.exe"
:: ���� �� 䠩�� ���䨣��樨 OpenSSL
:: ���� ��⭨� 㬥�� ࠡ���� ⮫쪮 � easy-rsa v.2.x
:: �����প� easy-rsa v.3.x, ��������, �㤥� ��������� �����
:: �᫨ 䠩� ��������, � ��⭨� ᠬ ��� ᮧ����
:: �������� �� ������!
set "KEY_CONFIG=%OpenVPN_DIR%\easy-rsa\openssl-1.0.0.cnf"
:: openssl-easyrsa.cnf - �� �ଠ� easy-rsa v.3.x
:: ���� ��⭨� �� 㬥�� � ��� ࠡ����. ��ப� �� ���� �᪮�����஢���!
:: set "KEY_CONFIG=%OpenVPN_DIR%\easy-rsa\openssl-easyrsa.cnf"
:: ����� ��� �࠭���� ��� ���祩 � ���䨪�⮢
:: �� ����᪥ ������� clean-all ���, �� � �⮩ �����, 㤠�����!
set "KEY_DIR=%OpenVPN_DIR%\easy-rsa\keys"
:: ������ ���� � ���� ��� ᮧ����� 䠩�� ���䨪�� � 䠩�� ����-������� ��� ����� ��䨪� �� ����஢��.
:: �� ����������� ��� �ᯮ�짮����� �ࢥ஬ TLS. � �������� ����� ��楤�� ����� ������
:: ����⥫쭮� �६� (���ਬ��, �� ࠧ��� ���� 4096 ��� �������� ����⪨ �����),
:: �� �������� ������⭮. ������������ ���祭�� 2048
set "KEY_SIZE=2048"
:: ����� ��������� �ந�����묨 ���祭�ﬨ. �� ��⠢���� ���� ����묨
:: ��࠭�
set "KEY_COUNTRY=RU"
:: �������
set "KEY_PROVINCE=Msk"
:: ��த
set "KEY_CITY=Msk"
:: �࣠������. �㤥� �ᯮ�짮������ � ���������� ������᪮�� ovpn-䠩��
set "KEY_ORG=MyOrg"
:: e-mail
set "KEY_EMAIL=mail@mail.ru"
set "KEY_CN=server"
set "KEY_NAME=server"
set "KEY_OU=server"
set "PKCS11_MODULE_PATH=server"
set "PKCS11_PIN=1234"
:: -----------END USER`s VARS------------
:: ����� ���� �� �⮣� ��⭨��
Set "FileIn=%~0"

cls
call :InitScript
call :OpenVPNver
call :servicestatus
call :OpenVPNgui
call :ShowFirewallState
call :CheckFirewallRules
call :ShowFirewallRules
call :checkopensslcnf
echo.
echo.
echo �롥�� ����⢨�:
echo.
echo 10 - ����ன�� �ࢥ୮� ��� [WINDOWS PC] (ᮧ����� ��� ����室���� ���祩 � ���䨪�⮢)
echo 11 - ����ன�� �ࢥ୮� ��� [Keenetic Router] (ᮧ����� ��� ����室���� ���祩 � ���䨪�⮢)
echo.
echo 20 - ������� ������᪨� *.ovpn-䠩�
echo.
echo 30 - �⮧���� ������᪨� ���䨪��
::echo 31 - ���᮪ �⮧������ ���䨪�⮢
echo.
echo 70 - ������ ᢮� �㡫��� IP
echo.
echo 88 - ������� ��� ����� OpenVPN � "%backupfolder%"
echo 99 - ������ ��� (������� ����� "%KEY_DIR%" � �ᥬ� ���䨪�⠬�)
echo.
echo 0  - ��室
set /P act=""
IF %act% == 10 (
 set ServerType=WindowsPC
 call :CheckCAkeyInKeyDir
 goto SERVER_INIT
) else IF %act% == 11 (
 set ServerType=KeeneticRouter
 call :CheckCAkeyInKeyDir
 goto SERVER_INIT
) else IF %act% == 20 (
 goto CLIENT-CRT
) else IF %act% == 30 (
 goto REVOKE-CRT
) else IF %act% == 40 (
 goto OpenVPNServiceAuto
) else IF %act% == 41 (
 call :OpenVPNServiceManual
 goto START
) else IF %act% == 42 (
 goto RestartOpenVPNService
) else IF %act% == 43 (
 call :StopOpenVPNService
 goto START
) else IF %act% == 44 (
 call :RestartOpenVPNgui
) else IF %act% == 45 (
 call :KillOpenVPNgui 
) else IF %act% == 50 (
 goto FirewallAllProfilesOn
) else IF %act% == 51 (
 goto FirewallDomainProfileOn
) else IF %act% == 52 (
 goto FirewallPrivateProfileOn
) else IF %act% == 53 (
 goto FirewallPublicProfileOn
) else IF %act% == 54 (
 goto FirewallAllProfilesOff
) else IF %act% == 55 (
 goto FirewallDomainProfileOff
) else IF %act% == 56 (
 goto FirewallPrivateProfileOff
) else IF %act% == 57 (
 goto FirewallPublicProfileOff
) else IF %act% == 58 (
 goto AddFirewallRules
) else IF %act% == 59 (
 goto DeleteFirewallRules
) else IF %act% == 70 (
 goto PublicIP
) else IF %act% == 88 (
 set "event=add_manual"
 call :backup
 goto START
) else IF %act% == 99 (
 call :CLEAN-ALL
 goto START
) else IF %act% == 0 (
 goto EXIT
) else (
 cls
 CALL :EchoColor 4 "[������] �������� �����"
 echo.
 timeout /t 3
 echo.
 goto START
)

:InitScript
:: ------------INIT SCRIPT-----------------
::�஢�ઠ ����饭 �� �ਯ� � �ࠢ��� �����������
"!system32dir!\reg.exe" query "HKU\S-1-5-19">nul 2>&1
if %errorlevel% equ 1 goto UACPrompt

IF NOT EXIST "%KEY_DIR%" mkdir "%KEY_DIR%"
IF NOT EXIST "%KEY_DIR%\index.txt" (
:: �������� ���⮣� 䠩�� index.txt
echo. 2>"%KEY_DIR%\index.txt"
:: �������� 䠩�� serial � �����ᮬ 01
echo 01>"%KEY_DIR%\serial"
)
goto :EOF

:UACPrompt
::������� �ࠢ ����᪠ �ਯ� (�⮡ࠦ����� ������ ����஫� ����� ����ᥩ UAC)
mshta "vbscript:CreateObject("Shell.Application").ShellExecute("%~fs0", "", "", "runas", 1) & Close()"
exit /b

:OpenVPNver
if not exist "%openvpnexe%" (
	CALL :EchoColor 4 "[X] %openvpnexe% [�����������]"
	echo.
	CALL :EchoColor 4 "�஢���� �ࠢ��쭮��� 㪠����� ��� � �ਯ� � ����稥 䠩��"
	echo.
	CALL :EchoColor 4 "�� ����室����� �����⠭���� OpenVPN"
	echo.
	CALL :EchoColor 4 "������ ������� ����� ���������"
	echo.
	pause
	exit
)
for /f "tokens=2 delims==" %%a in ('"wmic datafile where name='%openvpnexe:\=\\%' get Version /value|find "^=""') do set "ver=%%a"
CALL :EchoColor 2 "[V] %openvpnexe% [����������]	VER.: %ver%"
echo.
GOTO :eof

:servicestatus
set "service_name=OpenVPNService"
sc query %service_name% >NUL
if %errorlevel%==1060 (
	CALL :EchoColor 6 "[-] ��㦡� OpenVPNService [�� �����������]"
	echo.
	GOTO :eof
	) else (
		CALL :EchoColor 2 "[V] ��㦡� OpenVPNService [�����������]"
		echo.
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
if %type%==Auto (CALL :EchoColor 2 "[V] ��� ����᪠ �㦡� OpenVPNService [�������������]	41 - ������")
if %type%==Manual (CALL :EchoColor 6 "[-] ��� ����᪠ �㦡� OpenVPNService [�������]		40 - ��⮬���᪨")
if %type%==Disabled (CALL :EchoColor 4 "[X] ��� ����᪠ �㦡� OpenVPNService [���������]	40 - ��⮬���᪨")
echo.
chcp 437 >NUL
for /F "tokens=3 delims=: " %%H in ('sc query "OpenVPNService" ^| findstr "STATE"') do set service_state=%%H
chcp 866 >NUL
if "%service_state%"=="RUNNING" (CALL :EchoColor 2 "[V] ����ﭨ� �㦡� OpenVPNService [�����������]	42 - ��१�������; 43 - ��⠭�����")
if "%service_state%"=="STOPPED" (CALL :EchoColor 6 "[-] ����ﭨ� �㦡� OpenVPNService [�����������]	42 - ��१�������")
echo.
GOTO :eof

:OpenVPNgui
TaskList /FI "ImageName EQ %openvpnguiprocess%" | Find /I "%openvpnguiprocess%">nul
If %ErrorLevel% NEQ 0 (
	CALL :EchoColor 6 "[-] OpenVPN GUI [�� �������]				44 - ��१�������"
	) else (
	CALL :EchoColor 2 "[V] OpenVPN GUI [�������]				45 - �������; 44 - ��१�������"
)
echo.
GOTO :eof

:RestartOpenVPNgui
taskkill /F /IM %openvpnguiprocess%
start "" "%openvpngui%"
GOTO :eof

:KillOpenVPNgui
taskkill /F /IM %openvpnguiprocess%
GOTO :eof

:ShowFirewallState
chcp 437 >NUL
@NetSh AdvFirewall Show domainprofile State|Find /I " ON">Nul&&(set DomainProfileState=ON)||(set DomainProfileState=OFF)
@NetSh AdvFirewall Show privateprofile State|Find /I " ON">Nul&&(set PrivateProfileState=ON)||(set PrivateProfileState=OFF)
@NetSh AdvFirewall Show publicprofile State|Find /I " ON">Nul&&(set PublicProfileState=ON)||(set PublicProfileState=OFF)
chcp 866 >NUL
if %DomainProfileState%==ON (CALL :EchoColor 2 "[V] �࠭������. ��䨫� ������ [�������]		55 - �몫����; 54 - �몫���� ���")
if %DomainProfileState%==OFF (CALL :EchoColor 6 "[-] �࠭������. ��䨫� ������ [��������]		51 - �������; 50 - ������� ���")
echo.
if %PrivateProfileState%==ON (CALL :EchoColor 2 "[V] �࠭������. ����� ��䨫� [�������]		56 - �몫����; 54 - �몫���� ���")
if %PrivateProfileState%==OFF (CALL :EchoColor 6 "[-] �࠭������. ����� ��䨫� [��������]		52 - �������; 50 - ������� ���")
echo.
if %PublicProfileState%==ON (CALL :EchoColor 2 "[V] �࠭������. ��騩 ��䨫� [�������]			57 - �몫����; 54 - �몫���� ���")
if %PublicProfileState%==OFF (CALL :EchoColor 6 "[-] �࠭������. ��騩 ��䨫� [��������]		53 - �������; 50 - ������� ���")
echo.
GoTo :EOF

:FirewallAllProfilesOn
NetSh Advfirewall set allprofiles state on
goto START

:FirewallDomainProfileOn
NetSh Advfirewall set domainprofile state on
goto START

:FirewallPrivateProfileOn
NetSh Advfirewall set privateprofile state on
goto START

:FirewallPublicProfileOn
NetSh Advfirewall set publicprofile state on
goto START

:FirewallAllProfilesOff
NetSh Advfirewall set allprofiles state off
goto START

:FirewallDomainProfileOff
NetSh Advfirewall set domainprofile state off
goto START

:FirewallPrivateProfileOff
NetSh Advfirewall set privateprofile state off
goto START

:FirewallPublicProfileOff
NetSh Advfirewall set publicprofile state off
goto START

:CheckFirewallRules
netsh advfirewall firewall show rule name="OpenVPN Daemon TCP" >nul
if %ERRORLEVEL%==0 (set TCPRule=OK) else (set TCPRule=NOT_OK)
netsh advfirewall firewall show rule name="OpenVPN Daemon UDP" >nul
if %ERRORLEVEL%==0 (set UDPRule=OK) else (set UDPRule=NOT_OK)
GoTo :EOF

:ShowFirewallRules
if %TCPRule%==OK (
	if %UDPRule%==OK (
	CALL :EchoColor 2 "[V] OpenVPN � �᪫�祭�� �࠭������ [��������]		59 - �������"
	) else (
	CALL :EchoColor 6 "[-] OpenVPN � �᪫�祭�� �࠭������ [�� ��������]	58 - ��������"
	)
) else (
	CALL :EchoColor 6 "[-] OpenVPN � �᪫�祭�� �࠭������ [�� ��������]	58 - ��������"
)
echo.
GoTo :EOF

:AddFirewallRules
if %TCPRule%==NOT_OK (
	netsh advfirewall firewall add rule name="OpenVPN Daemon TCP" protocol=tcp dir=in action=allow program="%OpenVPN_DIR%\bin\openvpn.exe" localport=any enable=yes profile=any
)
if %UDPRule%==NOT_OK (
	netsh advfirewall firewall add rule name="OpenVPN Daemon UDP" protocol=udp dir=in action=allow program="%OpenVPN_DIR%\bin\openvpn.exe" localport=any enable=yes profile=any
)
goto START

:DeleteFirewallRules
netsh advfirewall firewall delete rule name="OpenVPN Daemon"
netsh advfirewall firewall delete rule name="OpenVPN Daemon TCP"
netsh advfirewall firewall delete rule name="OpenVPN Daemon UDP"
goto START

:OpenVPNServiceAuto
sc config OpenVPNService start= auto
goto START

:OpenVPNServiceManual
sc config OpenVPNService start= demand
GoTo :EOF

:RestartOpenVPNService
:: ��१���� �㦡� OpenVPN
net stop OpenVPNService && net start OpenVPNService
sc start OpenVPNService
goto START

:StopOpenVPNService
:: ��⠭���� �㦡� OpenVPN
net stop OpenVPNService
sc stop OpenVPNService
GoTo :EOF

:checkopensslcnf
if not exist "%KEY_CONFIG%" (
	CALL :EchoColor 4 "[X] 䠩� openssl-1.0.0.cnf [�����������]"
	echo.
	echo ������� 䠩� openssl-1.0.0.cnf
	call :Createopensslcnf
)
if exist "%KEY_CONFIG%" (
	CALL :EchoColor 2 "[V] 䠩� openssl-1.0.0.cnf [������������]"
	echo.
	) else (
	CALL :EchoColor 4 "[X] 䠩� openssl-1.0.0.cnf �� 㤠���� ᮧ����. ����� ��⭨�� �㤥� �����襭�"
	echo.
	timeout /t 5
	exit
	)
GoTo :EOF

:: ----------------------------------------
:: �������� ���䨣��樮����� 䠩�� openssl-1.0.0.cnf
:: �� ��� �����ᢨ�, ��� �᫨ ��⠭������ ����� 2.5.x � ���
:Createopensslcnf
:: ��易⥫쭮 ������ ���� � ��砫� ��⭨�� ��� ����� @echo off, ���� �����४⭮ �ᯮ������� ⥪��
:: �����⨬� � ��砫� 㪠���� @echo on, � � �⮩ ��� @echo off
@echo off
    Set "Key1=# For use with easy-rsa version 2.0 and OpenSSL 1.0.0*"
    Set "Key2=init = 0"
 
    FOR /F "usebackq skip=2 tokens=1 delims=[]" %%i In (`Find /N /I "%Key1%" "%FileIn%"`) DO Set /A N=%%i-1
 
    >"%KEY_CONFIG%" (FOR /F "usebackq delims=" %%i In (`More +%N% "%FileIn%"`) DO (
        Echo %%i|Find /I /V "%Key2%"||(<nul Set /P Str=%%i&Exit /B 0)
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


# SET-ex3			= SET extension number 3

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

:CheckCAkeyInKeyDir
cls
if exist "%KEY_DIR%\ca.key" (
	CALL :EchoColor 6 "[��������] � ����� %KEY_DIR% 㦥 ���������� ���䨪���"
	echo.
	CALL :EchoColor 6 "�� �த������� ࠡ��� ��� ��������� ���묨"
	echo.
	CALL :EchoColor 6 "������������ ������ ����� %KEY_DIR%"
	echo.
	echo.
	echo �롥�� ����⢨�:
	echo.
	echo 99  - ������ ��� (������� ����� "%KEY_DIR%" � �ᥬ� ���䨪�⠬�^)
	echo 100 - �த������ ����ன�� �ࢥ୮� ��� (�� ४���������^)
	echo.
	echo 00  - �������� �����
	echo 0   - ��室
	
	set /P act2=""
	IF !act2! == 100 (
		goto SERVER_INIT
		) else IF !act2! == 99 (
		call :CLEAN-ALL
		call :InitScript
		goto SERVER_INIT
		) else IF !act2! == 00 (
		goto START
		) else IF !act2! == 0 (
		goto EXIT
		) else (
		cls
		CALL :EchoColor 4 "[������] �������� �����"
		echo.
		timeout /t 3
		echo.
		goto CheckCAkeyInKeyDir
	)
)
GoTo :EOF

:SERVER_INIT
set "event=before_SERVER_INIT"
call :backup

:: �������� c���䨪�� 㤮�⮢����饣� 業��, ����⢨⥫쭮�� 10 ���
echo.
CALL :EchoColor 3 "�������� enter, �᫨ �� �ॡ���� ������ ���祭�� � [] - 8 ࠧ"
echo.
CALL :EchoColor 3 "������������ ��⠢��� �� 㬮�砭��"
echo.
echo.
"%OpenVPN_DIR%\bin\openssl.exe" req -days 3650 -nodes -new -x509 -keyout "%KEY_DIR%\ca.key" -out "%KEY_DIR%\ca.crt" -config "%KEY_CONFIG%"
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] ca.key - ���� 業�� ���䨪�樨 ᮧ��� [�������]"
	echo.
	CALL :EchoColor 2 "[V] ca.crt - ��୥��� ���䨪�� 㤮�⮢����饣� 業�� ᮧ��� [�������]"
	::CALL :EchoColor 2 "[V] CA certificate succesfully created"
	echo.
	)
echo.

:: ������� ���� ���� ��������, ��������饣� ��� � ����� ��஭�� ������� ��騩 ᥪ��� ����
"%OpenVPN_DIR%\bin\openssl.exe" dhparam -out "%KEY_DIR%/dh%KEY_SIZE%.pem" %KEY_SIZE%
if ERRORLEVEL 0 echo 
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] dh%KEY_SIZE%.pem - DH-䠩� (���� ���� ��������) ᮧ��� [�������]"
	::CALL :EchoColor 2 "[V] DH file succesfully created"
	echo.
	)
echo.

:: ��������  ����᪮�� ���� HMAC ��� �������⥫쭮� ����� �� DoS-�⠪ � �㤠
:: ��ࢥ� � ����� ������ ������ ����� ����� �⮣� ����
"%OpenVPN_DIR%\bin\openvpn.exe" --genkey --secret "%KEY_DIR%\ta.key"
chcp 866 >nul
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] ta.key - ���� tls-auth ᮧ��� [�������]"
	echo.
	)
	
:addsrvname
echo.
echo 00  - �������� �����
echo 0   - ��室
echo.
set /P SRV_NAME="������ ��� �ࢥ� (ࠧ�襭� ������᪨� �㪢�, ���� � ᨬ���� _.-): "
@echo %SRV_NAME%|>nul findstr/bei "[a-z0-9_.-]*"
IF ERRORLEVEL 1 (
	cls
	CALL :EchoColor 4 "[������] ��� ������� �������� ����������� �����/�������"
	timeout /t 10
	cls
	goto addsrvname
	)
IF %SRV_NAME%==00 goto START
IF %SRV_NAME%==0 goto EXIT
set "KEY_CN=%SRV_NAME%"
set "SRV_FILE1=%KEY_DIR%\%SRV_NAME%"
set "SRV_FILE2=%KEY_DIR%\%SRV_NAME%\%SRV_NAME%"

set "event=before_adding_%SRV_NAME%"
call :backup

:: �������� ����� �� ���䨪��, ����� �㤥� ����⢨⥫�� � �祭�� 10 ���
:: %SRV_NAME%.key - �ਢ��� ���� �ࢥ� OpenVPN, ᥪ���
echo.
CALL :EchoColor 3 "�������� enter, �᫨ �� �ॡ���� ������ ���祭�� � [] - 10 ࠧ"
echo.
CALL :EchoColor 3 "������������ ��⠢��� �� 㬮�砭��"
echo.
echo.
"%OpenVPN_DIR%\bin\openssl.exe" req -days 3650 -nodes -new -keyout "%SRV_FILE1%.key" -out "%SRV_FILE1%.csr" -config "%KEY_CONFIG%"
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] %SRV_NAME%.csr - 䠩� ����� �� ������� ���䨪�� ᮧ��� [�������]"
	echo.
	::CALL :EchoColor 2 "[V] %SRV_NAME%.csr - certificate sign request succesfully created"
	CALL :EchoColor 2 "[V] %SRV_NAME%.key - �ਢ��� ���� �ࢥ� OpenVPN ᮧ��� [�������]"
	::CALL :EchoColor 2 "[V] %SRV_NAME%.key succesfully created"
	echo.
	)

:: ������� ����� �� ���䨪�� � ��襬 業�� ���䨪�樨, ᮧ��� ���� ���䨪��/����
echo.
CALL :EchoColor 3 "������ ��������� �㪢� y � enter ������ ��� ������ ���䨪��"
echo.
"%OpenVPN_DIR%\bin\openssl.exe" ca -days 3650 -out "%SRV_FILE1%.crt" -in "%SRV_FILE1%.csr" -extensions server -config "%KEY_CONFIG%"
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] %SRV_NAME%.crt - ����䨪�� �ࢥ� ᮧ��� [�������]"
	::CALL :EchoColor 2 "[V] %SRV_NAME%.crt - Server`s certificate succesfully created"
	echo.
	)

:: �������� ��� *.old-䠩���, ᮧ������ � �⮬ �����, �⮡� �������� �訡�� �� ᮧ����� 䠩��� � ���饬
del /q "%KEY_DIR%\*.old"
IF NOT ERRORLEVEL 0 echo ERROR!

IF NOT EXIST "%KEY_DIR%\%SRV_NAME%" mkdir "%KEY_DIR%\%SRV_NAME%"

::-----------------------------------------
:: �������� %SRV%.ovpn-䠩��
:: ����, �� ���஬ �㤥� �����
echo port %ovpnport%>"%SRV_FILE2%.ovpn"
:: ��⮪�� ��� ������祭��
echo proto %ovpn_protocol%>>"%SRV_FILE2%.ovpn"
:: ������� ������⨧��㥬� IP �㭭���
echo dev tun>>"%SRV_FILE2%.ovpn"
:: ����뢠�� ������ ��
echo %dhcpserver%>>"%SRV_FILE2%.ovpn"
if %ServerType%==KeeneticRouter (echo push "route %pushroute%">>"%SRV_FILE2%.ovpn")
:: ��⠫�� � ���ᠭ�ﬨ ���䨣��権 ������� �� �����⮢
if %ServerType%==WindowsPC (echo client-config-dir ccd>>"%SRV_FILE2%.ovpn")
:: echo ifconfig 10.10.10.1 10.10.10.2>>"%SRV_FILE2%.ovpn"
:: ����蠥� ������� �����⠬ ����� ⮭����
echo client-to-client>>"%SRV_FILE2%.ovpn"
:: ����뢠�� ���뫠�� ping �� 㤠����� ����� �㭥�� ��᫥ 㪠������ n-ᥪ㭤,
:: �᫨ �� �㭭��� �� ��।������ ������� ��䨪.
:: ����뢠��, �᫨ � �祭�� 120 ᥪ㭤 �� �뫮 ����祭� �� ������ �����,
:: � �㭭��� �㤥� ��१���饭.
echo keepalive 10 120>>"%SRV_FILE2%.ovpn"
:: ����砥� ᦠ⨥
echo comp-lzo>>"%SRV_FILE2%.ovpn"
:: �� ����⠢��� 䠩�� ���祩 �� ��१���᪥ �㭭���
echo persist-key>>"%SRV_FILE2%.ovpn"
:: ��⨢���� ࠡ��� tun/tap ���ன�� � ०��� persist
echo persist-tun>>"%SRV_FILE2%.ovpn"
:: ������ ��஢����. ������ ���� ��������� ������/�ࢥ�
echo cipher %cipher%>>"%SRV_FILE2%.ovpn"
if %ServerType%==WindowsPC (echo status status.log>>"%SRV_FILE2%.ovpn")
:: ���� � ����
if %ServerType%==WindowsPC (echo log openvpn.log>>"%SRV_FILE2%.ovpn")
:: ���� � �����-䠩��, � ���஬ ᮤ�ন��� ���ଠ�� � ⥪��� ᮥ�������� � ���ଠ�� � ����䥩�� TUN/TAP
if %ServerType%==WindowsPC (echo status status.log>>"%SRV_FILE2%.ovpn")
:: �஢��� ����஢����
echo verb 4 >>"%SRV_FILE2%.ovpn"
:: �᫨ ���祭�� ��⠭������ � 20, � � ��� �㤥� �����뢠���� ⮫쪮 �� 20 ᮮ�饭�� �� ����� ��⥣�ਨ
echo mute 20>>"%SRV_FILE2%.ovpn"
::echo sndbuf 0 >>"%SRV_FILE2%.ovpn"
::echo rcvbuf 0 >>"%SRV_FILE2%.ovpn"
if %ovpn_protocol%==udp (echo explicit-exit-notify 1 >>"%SRV_FILE2%.ovpn")

:: ��⥣��� ca.crt � *.ovpn-䠩�
echo ^<ca^>>>"%SRV_FILE2%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%KEY_DIR%\ca.crt" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ca.crt">>"%SRV_FILE2%.ovpn"
)
echo ^</ca^>>>"%SRV_FILE2%.ovpn"

:: ��⥣��� %server%.crt � *.ovpn-䠩�
echo ^<cert^>>>"%SRV_FILE2%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%SRV_FILE1%.crt" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%SRV_FILE1%.crt">>"%SRV_FILE2%.ovpn"
)
echo ^</cert^>>>"%SRV_FILE2%.ovpn"

:: ��⥣��� %server%.key � *.ovpn-䠩�
echo ^<key^>>>"%SRV_FILE2%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN PRIVATE KEY-----" "%SRV_FILE1%.key" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%SRV_FILE1%.key">>"%SRV_FILE2%.ovpn"
)
echo ^</key^>>>"%SRV_FILE2%.ovpn"

:: ��⥣��� ta.key � *.ovpn-䠩�
echo ^<tls-auth^>>>"%SRV_FILE2%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN OpenVPN Static key V1-----" "%KEY_DIR%\ta.key" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ta.key">>"%SRV_FILE2%.ovpn"
)
echo ^</tls-auth^>>>"%SRV_FILE2%.ovpn"

:: ��⥣��� dh%KEY_SIZE%.pem" � *.ovpn-䠩�
echo ^<dh^>>>"%SRV_FILE2%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN DH PARAMETERS-----" "%KEY_DIR%\dh%KEY_SIZE%.pem" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\dh%KEY_SIZE%.pem">>"%SRV_FILE2%.ovpn"
)
echo ^</dh^>>>"%SRV_FILE2%.ovpn"
:: ����砭�� ᮧ����� %SRV%.ovpn-䠩��
::-----------------------------------------

echo f|xcopy /y "%SRV_FILE1%.key" "%SRV_FILE2%.key" >nul 2>&1
echo f|xcopy /y "%SRV_FILE1%.crt" "%SRV_FILE2%.crt" >nul 2>&1
echo f|xcopy /y "%KEY_DIR%\ca.crt" "%KEY_DIR%\%SRV_NAME%\ca.crt" >nul 2>&1
echo f|xcopy /y "%KEY_DIR%\ta.key" "%KEY_DIR%\%SRV_NAME%\ta.key" >nul 2>&1
echo f|xcopy /y "%KEY_DIR%\dh%KEY_SIZE%.pem" "%KEY_DIR%\%SRV_NAME%\dh%KEY_SIZE%.pem" >nul 2>&1
echo f|xcopy /y "%SRV_FILE2%.ovpn" "%OpenVPN_DIR%\config\%SRV_NAME%.ovpn" >nul 2>&1

IF NOT EXIST "%OpenVPN_DIR%\config\ccd" mkdir "%OpenVPN_DIR%\config\ccd"

set "event=after_adding_%SRV_NAME%"
call :backup
goto START

:CLIENT-CRT
echo.
echo 00  - �������� �����
echo 0   - ��室
echo.
set /P CLIENT_NAME="������ ��� ������ (ࠧ�襭� ������᪨� �㪢�, ���� � ᨬ���� _.-): "
@echo %CLIENT_NAME%|>nul findstr/bei "[a-z0-9_.-]*"
IF ERRORLEVEL 1 (
	cls
	CALL :EchoColor 4 "[������] ��� ������� �������� ����������� �����/�������"
	timeout /t 10
	cls
	goto CLIENT-CRT
	)
IF %CLIENT_NAME%==00 goto START
IF %CLIENT_NAME%==0 goto EXIT
set "KEY_CN=%CLIENT_NAME%"
set "CLIENT_FILE1=%KEY_DIR%\%CLIENT_NAME%"
set "CLIENT_FILE2=%KEY_DIR%\%CLIENT_NAME%\%CLIENT_NAME%"

set "event=before_adding_%CLIENT_NAME%"
call :backup

:: �������� ����� �� ���䨪��, ����� �㤥� ����⢨⥫�� � �祭�� 10 ���
:: %CLIENT_NAME%.key - �ਢ��� ���� ������ OpenVPN, ᥪ���
echo.
CALL :EchoColor 3 "�������� enter, �᫨ �� �ॡ���� ������ ���祭�� � [] - 10 ࠧ"
echo.
CALL :EchoColor 3 "������������ ��⠢��� �� 㬮�砭��"
echo.
echo.
"%OpenVPN_DIR%\bin\openssl.exe" req -days 3650 -nodes -new -keyout "%KEY_DIR%\%CLIENT_NAME%.key" -out "%KEY_DIR%\%CLIENT_NAME%.csr" -config "%KEY_CONFIG%"
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] %CLIENT_NAME%.csr - 䠩� ����� �� ������� ���䨪�� ������ ᮧ��� [�������]"
	echo.
	::CALL :EchoColor 2 "[V] %CLIENT_NAME%.csr - certificate sign request succesfully created"
	CALL :EchoColor 2 "[V] %CLIENT_NAME%.key - �ਢ��� ���� ������ ᮧ��� [�������]"
	::CALL :EchoColor 2 "[V] %CLIENT_NAME%.key succesfully created"
	echo.
	)

:: ������� ����� �� ���䨪�� � ��襬 業�� ���䨪�樨, ᮧ��� ���� ���䨪��/����
echo.
CALL :EchoColor 3 "������ ��������� �㪢� y � enter ������ ��� ������ ���䨪��"
echo.
"%OpenVPN_DIR%\bin\openssl.exe" ca -days 3650 -out "%KEY_DIR%\%CLIENT_NAME%.crt" -in "%KEY_DIR%\%CLIENT_NAME%.csr" -config "%KEY_CONFIG%"
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] %CLIENT_NAME%.crt - ����䨪�� ������ ᮧ��� [�������]"
	::CALL :EchoColor 2 "[V] %CLIENT_NAME%.crt - Client`s certificate succesfully created"
	echo.
	)
	
:: �������� ��� *.old-䠩���, ᮧ������ � �⮬ �����, �⮡� �������� �訡�� �� ᮧ����� 䠩��� � ���饬
del /q "%KEY_DIR%\*.old"
IF NOT ERRORLEVEL 0 echo ERROR!

IF NOT EXIST "%KEY_DIR%\%CLIENT_NAME%" mkdir "%KEY_DIR%\%CLIENT_NAME%"

::-----------------------------------------
:: �������� %CLIENT_NAME%.ovpn-䠩��
:: ����뢠��, �⮡� ������ ����ࠫ ���ଠ�� � ������⨧�樨 � �ࢥ�
echo client>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: ������� ������⨧��㥬� IP �㭭���
echo dev tun>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: ��⮪�� ��� ������祭��
echo proto %ovpn_protocol%>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: IP-���� �ࢥ� � ���⮬
echo remote %IP_SERVER% %ovpnport%>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: ��⠭�������� �६� � ᥪ㭤�� ��� ����� �� 㤠������ ����� ���.
:: ���㠫쭮 ⮫쪮 �᫨ �ᯮ������ DNS-��� 㤠������� ���.
:: infinite - ��᪮��筮
echo resolv-retry infinite>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
::echo nobind>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: ����뢠�� �� ����⠢��� 䠩�� ���祩 �� ��१���᪥ �㭭���
echo persist-key>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: ��⠢��� ��� ��������� ���ன�⢠ tun/tap �� ��१���᪥ OpenVPN
echo persist-tun>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: ���� 㪠����� ������� OpenVPN ࠧ���� ������祭�� ⮫쪮 � VPN-�ࢥ��,
:: � ���ண� ���� ���䨪�� � ��ਡ�⮬ EKU X.509, ��⠭������� � ���祭�� TLS Web Server Authentication
echo remote-cert-tls server>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: ����뢠�� ������ ��஢����. ������ ���� ��������� ������/�ࢥ�
echo cipher %cipher%>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: ����砥� ᦠ⨥
echo comp-lzo>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: �஢��� ����஢����
echo verb 3 >>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: �᫨ ���祭�� ��⠭������ � 20, � � ��� �㤥� �����뢠���� ⮫쪮 �� 20 ᮮ�饭�� �� ����� ��⥣�ਨ
echo mute 20>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"

:: ��⥣��� ca.crt � *.ovpn-䠩�
echo ^<ca^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%KEY_DIR%\ca.crt" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ca.crt">>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
)
echo ^</ca^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"

:: ��⥣��� %CLIENT_NAME%.crt � *.ovpn-䠩�
echo ^<cert^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%CLIENT_FILE1%.crt" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%CLIENT_FILE1%.crt">>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
)
echo ^</cert^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"

:: ��⥣��� %CLIENT_NAME%.key � *.ovpn-䠩�
echo ^<key^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN PRIVATE KEY-----" "%CLIENT_FILE1%.key" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%CLIENT_FILE1%.key">>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
)
echo ^</key^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"

:: ��⥣��� ta.key � *.ovpn-䠩�
echo ^<tls-auth^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN OpenVPN Static key V1-----" "%KEY_DIR%\ta.key" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ta.key">>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
)
echo ^</tls-auth^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: ����砭�� ᮧ����� %CLIENT_NAME%.ovpn-䠩��
::-----------------------------------------

echo f|xcopy /y "%KEY_DIR%\%CLIENT_NAME%.key" "%KEY_DIR%\%CLIENT_NAME%\%CLIENT_NAME%.key" >nul
echo f|xcopy /y "%KEY_DIR%\%CLIENT_NAME%.crt" "%KEY_DIR%\%CLIENT_NAME%\%CLIENT_NAME%.crt" >nul
echo f|xcopy /y "%KEY_DIR%\ca.crt" "%KEY_DIR%\%CLIENT_NAME%\ca.crt" >nul
echo f|xcopy /y "%KEY_DIR%\ta.key" "%KEY_DIR%\%CLIENT_NAME%\ta.key" >nul
echo f|xcopy /y "%KEY_DIR%\dh%KEY_SIZE%.pem" "%KEY_DIR%\%CLIENT_NAME%\dh%KEY_SIZE%.pem" >nul

set "event=after_adding_%CLIENT_NAME%"
call :backup
goto START

:REVOKE-CRT
:: ��� ���䨪�� ���짮��⥫�
cls
Set /p revokeuser="������ ��� ���䨪�� ���짮��⥫�, ����� �ॡ���� �⮧����: "
if not exist "%KEY_DIR%\%revokeuser%.crt" (
	CALL :EchoColor 4 "[X] ����䨪�� %KEY_DIR%\%revokeuser%.crt [�� ������]"
	echo.
	pause
	goto REVOKE-CRT
	)
set "event=before_REVOKE_%revokeuser%"
call :backup
"%OpenVPN_DIR%\bin\openssl.exe" ca -revoke "%KEY_DIR%\%revokeuser%.crt" -config "%KEY_CONFIG%"
rem generate new crl
"%OpenVPN_DIR%\bin\openssl.exe" ca -gencrl -out "%KEY_DIR%\crl.pem" -config "%KEY_CONFIG%"
CALL :EchoColor 2 "[V] ����䨪�� %revokeuser% �⮧��� [�������]
echo.
echo.
call :DelCrl-verify
call :AddCrl-verify
set "event=after_REVOKE_%revokeuser%"
call :backup
goto START

:DelCrl-verify
Set /p revokeserver="������ ��� ���䨪�� �ࢥ�, � ����� �ॡ���� �������� ����� �� 㤠������ ������᪨� ���䪠��: "
if not exist "%KEY_DIR%\%revokeserver%\%revokeserver%.ovpn" (
	CALL :EchoColor 4 "[X] ���� %KEY_DIR%\%revokeserver%\%revokeserver%.ovpn [�� ������]"
	echo.
	pause
	goto DelCrl-verify
	)
::set input file
set "f_in=%KEY_DIR%\%revokeserver%\%revokeserver%.ovpn"
::set output file
set "f_out=%KEY_DIR%\%revokeserver%\%revokeserver%_tmp.ovpn"
set "f_tmp=tmp.txt"
::set word for search
set "word=<crl-verify>"

find "%word%" "%f_in%" 2>nul >nul
if %errorlevel% NEQ 0 exit /b
set nStr=0
for /f "delims=" %%a in ('findstr /nrc:"." "%f_in%"') do echo.%%a>>"%f_tmp%"
for /f "tokens=1 delims=:" %%a in ('findstr /nc:"%word%" "%f_in%"') do (call :sum %%a)
del "%f_tmp%"
del "%f_in%"
ren "%f_out%" %revokeserver%.ovpn
exit /b
 
:sum
set /a nFns=%1-1
if %nFns% leq 0 (set /a nStr=%1+2&&exit /b) else (set /a n1=nStr&&set /a n2=nFns)
for /l %%i in (%n1%,1,%n2%) do (
    for /f "tokens=1* delims=:" %%m in ('findstr /brc:"%%i:" "%f_tmp%"') do echo.%%n>>"%f_out%"
)
set /a nStr=%1+2
exit /b

:AddCrl-verify
:: ��⥣��� crl-verify � *.ovpn-䠩�
echo ^<crl-verify^>>>"%f_in%"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN X509 CRL-----" "%KEY_DIR%\crl.pem" ') do set /a "header_line=%%a-1" 1>nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\crl.pem">>"%f_in%"
)
echo ^</crl-verify^>>>"%f_in%"
echo.
echo �������� 䠩� "%KEY_DIR%\%revokeserver%\%revokeserver%.ovpn" � ����� "%OpenVPN_DIR%\config\"
echo ��� � "%OpenVPN_DIR%\config-auto\"
echo.
echo � ��१������ �㦡�/�ணࠬ�� OpenVPN
echo.
echo �᫨ � ��� ���� Keenetic, � ᮤ�ন��� 䠩�� ᪮����� � ���� � ��१������ OpenVPN-������祭��
echo.
pause
goto :EOF

:PublicIP
cls
Echo ���� ����� ����祭�� ���譥�� (Public) IP...
for /f %%a in ('powershell Invoke-RestMethod api.ipify.org') do set "PublicIP=%%a"
echo ��� Public IP: %PublicIP%
set /p "x=%PublicIP%"<nul|Clip
echo 㦥 ᪮��஢�� � ���� ������
pause
goto START

:backup
IF NOT EXIST "%backupfolder%" mkdir "%backupfolder%"
for /f "delims=." %%i in ('wmic.exe OS get LocalDateTime ^| find "."') do set sDateTime=%%i
set "Year=%sDateTime:~0,4%"
set "Month=%sDateTime:~4,2%"
set "Day=%sDateTime:~6,2%"
set "Hour=%sDateTime:~8,2%"
set "Minute=%sDateTime:~10,2%"
set "Second=%sDateTime:~12,2%"
set "backupfile=%backupfolder%\OpenVPN_%Year%-%Month%-%Day%_%Hour%-%Minute%-%Second%_(%event%).zip"
powershell "Compress-Archive -Path '%OpenVPN_DIR%' -DestinationPath '%backupfile%' -CompressionLevel Optimal"
IF NOT EXIST "%backupfile%" (call :backupPSold)
GoTo :EOF

:backupPSold
powershell "Add-Type -Assembly """System.IO.Compression.FileSystem""" ;[System.IO.Compression.ZipFile]::CreateFromDirectory("""%OpenVPN_DIR%""", """%backupfile%""");"
GoTo :EOF

:CLEAN-ALL
cls
call :StopOpenVPNService
call :OpenVPNServiceManual
set "event=before_CLEAN-ALL"
call :backup
:: [Ru] ������� ᮤ�ন��� ����� %KEY_DIR% ��� �뢮�� �����
:: [En] delete the %KEY_DIR% and any subdirs quietly
rmdir /s /q "%KEY_DIR%"
if ERRORLEVEL 0 CALL :EchoColor 2 "[V] �� ���䨪��� �ᯥ譮 㤠����!"
echo.
timeout /t 3
goto :EOF
 
:EXIT
Exit

:EchoColor [%1=Color %2="Text" %3=/n (CRLF, optional)] (Support multiple arguments at once)
:: �뢮� 梥⭮�� ⥪��. ��࠭�祭�� - �� �뢮����� ��᪫��⥫�� ����, ��⠫�� ᯥ�ᨬ���� ࠧ�襭�.
:: ����� � �����, 祬 ����� ����஬ ��ࠬ��஢
If Not Defined multiple If Not "%~4"=="" (
	Call :EchoWrapper %*
	Set multiple=
	Exit /B
)
SetLocal EnableDelayedExpansion
If Not Defined BkSpace Call :EchoColorInit
:: ��࠭�஢���� �室�饣� ⥪�� �� ������ � ����� ��襩, ��⪠ �������� ᨬ�����.
Set "$Text=%~2"
Set "$Text=.%BkSpace%!$Text:\=.%BkSpace%\..\%BkSpace%%BkSpace%%BkSpace%!"
Set "$Text=!$Text:/=.%BkSpace%/..\%BkSpace%%BkSpace%%BkSpace%!"
Set "$Text=!$Text:"=\"!"
Set "$Text=!$Text:^^=^!"
:: �᫨ XP, �뢮��� ����� ⥪��.
If "%isXP%"=="true" (
	<nul Set /P "=.!BkSpace!%~2"
	GoTo :unsupported
)
:: ������ ⥪�� �� stdout, �� ᮧ����� �६����� 䠩��� � �ᯮ���� ��� � ����.
:: � ��砥 ��㤠� (�஡�����\᫨誮� ������ ����?) �뢮��� ⥪�� as is, ��� ��梥⪨.
:: �᫨ १�������� ����� ��ப� (���� 㦥 ����騥�� ⠬ ᨬ����) �ॢ�蠥� �ਭ� ���᮫�, � �뢮� ⮦� �㤥� ��㤠��. �� ������� ⥪���� ������ ���⪨ �ணࠬ��� �����.
PushD "%~dp0"
2>nul FindStr /R /P /A:%~1 "^-" "%$Text%\..\%~nx0" nul
If !ErrorLevel! GTR 0 <nul Set /P "=.!BkSpace!%~2"
PopD
:: ���ࠥ� ����, ��� 䠩�� � ���� � ������� ����⠭��� ࠭�� ������⢠ ᨬ�����.
For /L %%A In (1,1,!BkSpaces!) Do <nul Set /P "=!BkSpace!"
:unsupported
:: �뢮��� CRLF, �᫨ 㪠��� ��⨩ ��㬥��.
If /I "%~3"=="/n" Echo.
EndLocal
GoTo :EOF

:EchoWrapper
:: ��ࠡ�⪠ ��㬥�⮢ �����񤭮
SetLocal EnableDelayedExpansion
:NextArg
Set multiple=true
:: �� � �� 㤢����� "^" �� ��।�� ��㬥�⮢...
Set $Text=
Set $Text=%2
Set "$Text=!$Text:^^^^=^!"
If Not "%~3"=="" If /I Not "%~3"=="/n" (
	Shift&Shift
	Call :EchoColor %1 !$Text!
	GoTo :NextArg
) Else (
	Shift&Shift&Shift
	Call :EchoColor %1 !$Text! %3
	GoTo :NextArg
)
If "%~3"=="" Call :EchoColor %1 !$Text!
EndLocal
GoTo :EOF

:EchoColorInit
:: ��ࠡ��뢠��� �� ��ࢮ� ����᪥ த�⥫�᪮� �㭪樨 ���樠������ �㦭�� ��६�����
:: �����! ��� XP, � ᨫ� ॠ����樨 ⠬�譥�� findstr, 0x08 � ����� �� ࠡ�⠥�, ��������� �� ���. �⪫�砥� 梥⭮� �뢮� ��� XP.
For /F "tokens=2 delims=[]" %%A In ('Ver') Do (For /F "tokens=2,3 delims=. " %%B In ("%%A") Do (If "%%B"=="5" Set isXP=true))
:: ����砥� ��������� "0x08 0x20 0x08" � ������� prompt
For /F "tokens=1 delims=#" %%A In ('"Prompt #$H# & Echo On & For %%B In (1) Do rem"') Do Set "BkSpace=%%A"
:: ������뢠�� �ॡ㥬�� ������⢮ ᨬ����� ��� ���������� �ᥣ�, �஬� �뢮������ ⥪��
Set ScriptFileName=%~nx0
Call :StrLen ScriptFileName
Set /A "BkSpaces=!strLen!+6"
GoTo :EOF

:StrLen [%1=VarName (not VALUE), ret !strLen!]
:: ����祭�� ����� ��ப�
Set StrLen.S=A!%~1!
Set StrLen=0
For /L %%P In (12,-1,0) Do (
	Set /A "StrLen|=1<<%%P"
	For %%I In (!StrLen!) Do If "!StrLen.S:~%%I,1!"=="" Set /A "StrLen&=~1<<%%P"
)
GoTo :EOF

:: �� ��ப� ������ ���� ��᫥���� � �� ����稢����� �� CRLF.
-