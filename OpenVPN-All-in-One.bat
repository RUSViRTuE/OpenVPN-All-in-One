@echo off
setlocal enableextensions enabledelayedexpansion
TITLE OpenVPN-All-in-One by RUSViRTuE v1.0.2 [26.12.2022]
:START
:: -------------VARS--------------
:: Заполните значения переменных
:: IP-адрес сервера. Можно указать и локальный IP (например, 192.168.1.10), и доменное имя (например, mydomain.com)
set "IP_SERVER=1.2.3.4"
:: Порт, на котором будем слушать
set "ovpnport=1194"
:: server < network > < mask > - автоматически присваивает адреса всем клиентам (DHCP)
:: в указанном диапазоне с маской сети. Данная опция заменяет ifconfig и может работаеть
:: только с TLS-клиентами в режиме TUN, соответственно использование сертификатов обязательно.
:: Например: server 10.10.10.0 255.255.255.0
:: Подключившиеся клиенты получат адреса в диапазоне между 10.10.10.1 и 10.3.0.254.
set "dhcpserver=server 10.10.10.0 255.255.255.0"
:: Сеть и маска домашней сети куда будет перенаправляться трафик
:: Будет работать, если в качестве сервера OpenVPN будет выступать роутер Keenetic
set "pushroute=192.168.1.0 255.255.255.0"
:: Рекомендуется оставить по умолчанию udp
:: ВАЖНО! чувствителен к регистру. Только маленькими буквами допускается
set ovpn_protocol=udp
:: Тип шифрования. Не рекомендуется менять
set "cipher=AES-256-GCM"
:: Папка для хранения бэкапов папки OpenVPN
:: Автоматически будет делаться бэкап папки %OpenVPN_DIR% 
:: до и после каждого действия (добавление/удаление/отзыв сертификатов, очистка папки %KEY_DIR%)
Set "backupfolder=C:\_Backup\OpenVPN"
:: Путь до папки OpenVPN
set "OpenVPN_DIR=C:\Program Files\OpenVPN"
set "openvpnexe=%OpenVPN_DIR%\bin\openvpn.exe"
set "openvpngui=%OpenVPN_DIR%\bin\openvpn-gui.exe"
set "openvpnguiprocess=openvpn-gui.exe"
:: Путь до файла конфигурации OpenSSL
:: Пока батник умеет работать только с easy-rsa v.2.x
:: Поддержка easy-rsa v.3.x, возможно, будет добавлена позже
:: Если файл отсутсвует, то батник сам его создаст
:: ЗНАЧЕНИЕ НЕ МЕНЯТЬ!
set "KEY_CONFIG=%OpenVPN_DIR%\easy-rsa\openssl-1.0.0.cnf"
:: openssl-easyrsa.cnf - это формат easy-rsa v.3.x
:: Пока батник не умеет с ним работать. Строку не надо раскомментировать!
:: set "KEY_CONFIG=%OpenVPN_DIR%\easy-rsa\openssl-easyrsa.cnf"
:: Папка для хранения всех ключей и сертификатов
:: При запуске команды clean-all всё, что в этой папке, удалится!
set "KEY_DIR=%OpenVPN_DIR%\easy-rsa\keys"
:: Размер ключа в битах для создания файла сертификата и файла Диффи-Хелмана для защиты трафика от расшифровки.
:: Он понадобится для использования сервером TLS. В некоторых случаях процедура может занять
:: значительное время (например, при размере ключа 4096 бит занимает десятки минут),
:: но делается однократно. Рекомендуется значение 2048
set "KEY_SIZE=2048"
:: Можно заполнить произвольными значениями. Не оставлять поля пустыми
:: Страна
set "KEY_COUNTRY=RU"
:: Область
set "KEY_PROVINCE=Msk"
:: Город
set "KEY_CITY=Msk"
:: Организация. Будет использоваться в назвавании клиентского ovpn-файла
set "KEY_ORG=MyOrg"
:: e-mail
set "KEY_EMAIL=mail@mail.ru"
set "KEY_CN=server"
set "KEY_NAME=server"
set "KEY_OU=server"
set "PKCS11_MODULE_PATH=server"
set "PKCS11_PIN=1234"
:: -----------END USER`s VARS------------
:: Полный путь до этого батника
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
echo Выберите действие:
echo.
echo 10 - Настройка серверной части [WINDOWS PC] (создание всех необходимых ключей и сертификатов)
echo 11 - Настройка серверной части [Keenetic Router] (создание всех необходимых ключей и сертификатов)
echo.
echo 20 - Создать клиентский *.ovpn-файл
echo.
echo 30 - Отозвать клиентский сертификат
::echo 31 - Список отозванных сертификатов
echo.
echo 70 - Узнать свой публичный IP
echo.
echo 88 - Создать бэкап папки OpenVPN в "%backupfolder%"
echo 99 - Очистить всё (Удалить папку "%KEY_DIR%" со всеми сертификатами)
echo.
echo 0  - Выход
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
 CALL :EchoColor 4 "[ОШИБКА] НЕВЕРНЫЙ ВЫБОР"
 echo.
 timeout /t 3
 echo.
 goto START
)

:InitScript
:: ------------INIT SCRIPT-----------------
::Проверка запущен ли скрипт с правами администратора
"!system32dir!\reg.exe" query "HKU\S-1-5-19">nul 2>&1
if %errorlevel% equ 1 goto UACPrompt

IF NOT EXIST "%KEY_DIR%" mkdir "%KEY_DIR%"
IF NOT EXIST "%KEY_DIR%\index.txt" (
:: Создание пустого файла index.txt
echo. 2>"%KEY_DIR%\index.txt"
:: Создание файла serial с индексом 01
echo 01>"%KEY_DIR%\serial"
)
goto :EOF

:UACPrompt
::Элевация прав запуска скрипта (отображается диалог контроля учетных записей UAC)
mshta "vbscript:CreateObject("Shell.Application").ShellExecute("%~fs0", "", "", "runas", 1) & Close()"
exit /b

:OpenVPNver
if not exist "%openvpnexe%" (
	CALL :EchoColor 4 "[X] %openvpnexe% [ОТСУТСТВУЕТ]"
	echo.
	CALL :EchoColor 4 "Проверьте правильность указания пути в скрипте и наличие файла"
	echo.
	CALL :EchoColor 4 "При необходимости переустановите OpenVPN"
	echo.
	CALL :EchoColor 4 "РАБОТА СКРИПТА БУДЕТ ЗАВЕРШЕНА"
	echo.
	pause
	exit
)
for /f "tokens=2 delims==" %%a in ('"wmic datafile where name='%openvpnexe:\=\\%' get Version /value|find "^=""') do set "ver=%%a"
CALL :EchoColor 2 "[V] %openvpnexe% [УСТАНОВЛЕН]	VER.: %ver%"
echo.
GOTO :eof

:servicestatus
set "service_name=OpenVPNService"
sc query %service_name% >NUL
if %errorlevel%==1060 (
	CALL :EchoColor 6 "[-] Служба OpenVPNService [НЕ УСТАНОВЛЕНА]"
	echo.
	GOTO :eof
	) else (
		CALL :EchoColor 2 "[V] Служба OpenVPNService [УСТАНОВЛЕНА]"
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
if %type%==Auto (CALL :EchoColor 2 "[V] Тип запуска службы OpenVPNService [АВТОМАТИЧЕСКИ]	41 - Вручную")
if %type%==Manual (CALL :EchoColor 6 "[-] Тип запуска службы OpenVPNService [ВРУЧНУЮ]		40 - Автоматически")
if %type%==Disabled (CALL :EchoColor 4 "[X] Тип запуска службы OpenVPNService [ОТКЛЮЧЕНА]	40 - Автоматически")
echo.
chcp 437 >NUL
for /F "tokens=3 delims=: " %%H in ('sc query "OpenVPNService" ^| findstr "STATE"') do set service_state=%%H
chcp 866 >NUL
if "%service_state%"=="RUNNING" (CALL :EchoColor 2 "[V] Состояние службы OpenVPNService [ВЫПОЛНЯЕТСЯ]	42 - Перезапустить; 43 - Остановить")
if "%service_state%"=="STOPPED" (CALL :EchoColor 6 "[-] Состояние службы OpenVPNService [ОСТАНОВЛЕНА]	42 - Перезапустить")
echo.
GOTO :eof

:OpenVPNgui
TaskList /FI "ImageName EQ %openvpnguiprocess%" | Find /I "%openvpnguiprocess%">nul
If %ErrorLevel% NEQ 0 (
	CALL :EchoColor 6 "[-] OpenVPN GUI [НЕ ЗАПУЩЕН]				44 - Перезапустить"
	) else (
	CALL :EchoColor 2 "[V] OpenVPN GUI [ЗАПУЩЕН]				45 - Закрыть; 44 - Перезапустить"
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
if %DomainProfileState%==ON (CALL :EchoColor 2 "[V] Брандмауэр. Профиль домена [ВКЛЮЧЕН]		55 - Выключить; 54 - Выключить ВСЕ")
if %DomainProfileState%==OFF (CALL :EchoColor 6 "[-] Брандмауэр. Профиль домена [ВЫКЛЮЧЕН]		51 - Включить; 50 - Включить ВСЕ")
echo.
if %PrivateProfileState%==ON (CALL :EchoColor 2 "[V] Брандмауэр. Частный профиль [ВКЛЮЧЕН]		56 - Выключить; 54 - Выключить ВСЕ")
if %PrivateProfileState%==OFF (CALL :EchoColor 6 "[-] Брандмауэр. Частный профиль [ВЫКЛЮЧЕН]		52 - Включить; 50 - Включить ВСЕ")
echo.
if %PublicProfileState%==ON (CALL :EchoColor 2 "[V] Брандмауэр. Общий профиль [ВКЛЮЧЕН]			57 - Выключить; 54 - Выключить ВСЕ")
if %PublicProfileState%==OFF (CALL :EchoColor 6 "[-] Брандмауэр. Общий профиль [ВЫКЛЮЧЕН]		53 - Включить; 50 - Включить ВСЕ")
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
	CALL :EchoColor 2 "[V] OpenVPN в исключения Брандмауэра [ДОБАВЛЕН]		59 - Удалить"
	) else (
	CALL :EchoColor 6 "[-] OpenVPN в исключения Брандмауэра [НЕ ДОБАВЛЕН]	58 - Добавить"
	)
) else (
	CALL :EchoColor 6 "[-] OpenVPN в исключения Брандмауэра [НЕ ДОБАВЛЕН]	58 - Добавить"
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
:: Перезапуск службы OpenVPN
net stop OpenVPNService && net start OpenVPNService
sc start OpenVPNService
goto START

:StopOpenVPNService
:: Остановка службы OpenVPN
net stop OpenVPNService
sc stop OpenVPNService
GoTo :EOF

:checkopensslcnf
if not exist "%KEY_CONFIG%" (
	CALL :EchoColor 4 "[X] файл openssl-1.0.0.cnf [ОТСУТСТВУЕТ]"
	echo.
	echo Создаем файл openssl-1.0.0.cnf
	call :Createopensslcnf
)
if exist "%KEY_CONFIG%" (
	CALL :EchoColor 2 "[V] файл openssl-1.0.0.cnf [ПРИСУТСТВУЕТ]"
	echo.
	) else (
	CALL :EchoColor 4 "[X] файл openssl-1.0.0.cnf не удалось создать. Работа батника будет завершена"
	echo.
	timeout /t 5
	exit
	)
GoTo :EOF

:: ----------------------------------------
:: Создание конфигурационного файла openssl-1.0.0.cnf
:: При его отсутсвии, или если установлена версия 2.5.x и выше
:Createopensslcnf
:: Обязательно должно быть в начале батника или здесь @echo off, иначе некорректно экспортируется текст
:: Допустимо в начале указать @echo on, а в этой части @echo off
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
	CALL :EchoColor 6 "[ВНИМАНИЕ] В ПАПКЕ %KEY_DIR% уже присутствуют сертификаты"
	echo.
	CALL :EchoColor 6 "При продолжении работы они заменятся новыми"
	echo.
	CALL :EchoColor 6 "Рекомендуется очистить папку %KEY_DIR%"
	echo.
	echo.
	echo Выберите действие:
	echo.
	echo 99  - Очистить всё (Удалить папку "%KEY_DIR%" со всеми сертификатами^)
	echo 100 - Продолжить настройку серверной части (не рекомендуется^)
	echo.
	echo 00  - Вернуться назад
	echo 0   - Выход
	
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
		CALL :EchoColor 4 "[ОШИБКА] НЕВЕРНЫЙ ВЫБОР"
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

:: Создание cертификата удостоверяющего центра, действительного 10 лет
echo.
CALL :EchoColor 3 "Нажимайте enter, если не требуется менять значения в [] - 8 раз"
echo.
CALL :EchoColor 3 "Рекомендуется оставить по умолчанию"
echo.
echo.
"%OpenVPN_DIR%\bin\openssl.exe" req -days 3650 -nodes -new -x509 -keyout "%KEY_DIR%\ca.key" -out "%KEY_DIR%\ca.crt" -config "%KEY_CONFIG%"
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] ca.key - ключ центра сертификации создан [УСПЕШНО]"
	echo.
	CALL :EchoColor 2 "[V] ca.crt - корневой сертификат удостоверяющего центра создан [УСПЕШНО]"
	::CALL :EchoColor 2 "[V] CA certificate succesfully created"
	echo.
	)
echo.

:: Генерация ключа Диффи Хеллмана, позволяющего двум и более сторонам получить общий секретный ключ
"%OpenVPN_DIR%\bin\openssl.exe" dhparam -out "%KEY_DIR%/dh%KEY_SIZE%.pem" %KEY_SIZE%
if ERRORLEVEL 0 echo 
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] dh%KEY_SIZE%.pem - DH-файл (ключ Диффи Хеллмана) создан [УСПЕШНО]"
	::CALL :EchoColor 2 "[V] DH file succesfully created"
	echo.
	)
echo.

:: Создание  статического ключа HMAC для дополнительной защиты от DoS-атак и флуда
:: Сервер и каждый клиент должны иметь копию этого ключа
"%OpenVPN_DIR%\bin\openvpn.exe" --genkey --secret "%KEY_DIR%\ta.key"
chcp 866 >nul
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] ta.key - ключ tls-auth создан [УСПЕШНО]"
	echo.
	)
	
:addsrvname
echo.
echo 00  - Вернуться назад
echo 0   - Выход
echo.
set /P SRV_NAME="Введите имя сервера (разрешены английские буквы, цифры и символы _.-): "
@echo %SRV_NAME%|>nul findstr/bei "[a-z0-9_.-]*"
IF ERRORLEVEL 1 (
	cls
	CALL :EchoColor 4 "[ОШИБКА] ИМЯ СЕРВЕРА СОДЕРЖИТ ЗАПРЕЩЕННЫЕ БУКВЫ/СИМВОЛЫ"
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

:: Создание запроса на сертификат, который будет действителен в течение 10 лет
:: %SRV_NAME%.key - приватный ключ сервера OpenVPN, секретный
echo.
CALL :EchoColor 3 "Нажимайте enter, если не требуется менять значения в [] - 10 раз"
echo.
CALL :EchoColor 3 "Рекомендуется оставить по умолчанию"
echo.
echo.
"%OpenVPN_DIR%\bin\openssl.exe" req -days 3650 -nodes -new -keyout "%SRV_FILE1%.key" -out "%SRV_FILE1%.csr" -config "%KEY_CONFIG%"
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] %SRV_NAME%.csr - файл запроса на подпись сертификата создан [УСПЕШНО]"
	echo.
	::CALL :EchoColor 2 "[V] %SRV_NAME%.csr - certificate sign request succesfully created"
	CALL :EchoColor 2 "[V] %SRV_NAME%.key - приватный ключ сервера OpenVPN создан [УСПЕШНО]"
	::CALL :EchoColor 2 "[V] %SRV_NAME%.key succesfully created"
	echo.
	)

:: Подпись запроса на сертификат в нашем центре сертификации, создав пару сертификат/ключ
echo.
CALL :EchoColor 3 "Нажмите английскую букву y и enter дважды для подписи сертификата"
echo.
"%OpenVPN_DIR%\bin\openssl.exe" ca -days 3650 -out "%SRV_FILE1%.crt" -in "%SRV_FILE1%.csr" -extensions server -config "%KEY_CONFIG%"
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] %SRV_NAME%.crt - Сертификат сервера создан [УСПЕШНО]"
	::CALL :EchoColor 2 "[V] %SRV_NAME%.crt - Server`s certificate succesfully created"
	echo.
	)

:: Удаление всех *.old-файлов, созданных в этом процессе, чтобы избежать ошибок при создании файлов в будущем
del /q "%KEY_DIR%\*.old"
IF NOT ERRORLEVEL 0 echo ERROR!

IF NOT EXIST "%KEY_DIR%\%SRV_NAME%" mkdir "%KEY_DIR%\%SRV_NAME%"

::-----------------------------------------
:: Создание %SRV%.ovpn-файла
:: Порт, на котором будем слушать
echo port %ovpnport%>"%SRV_FILE2%.ovpn"
:: Протокол для подключения
echo proto %ovpn_protocol%>>"%SRV_FILE2%.ovpn"
:: Создаем маршрутизируемый IP туннель
echo dev tun>>"%SRV_FILE2%.ovpn"
:: Указываем адресацию сети
echo %dhcpserver%>>"%SRV_FILE2%.ovpn"
if %ServerType%==KeeneticRouter (echo push "route %pushroute%">>"%SRV_FILE2%.ovpn")
:: Каталог с описаниями конфигураций каждого из клиентов
if %ServerType%==WindowsPC (echo client-config-dir ccd>>"%SRV_FILE2%.ovpn")
:: echo ifconfig 10.10.10.1 10.10.10.2>>"%SRV_FILE2%.ovpn"
:: Разрешаем общаться клиентам внутри тоннеля
echo client-to-client>>"%SRV_FILE2%.ovpn"
:: Указывает отсылать ping на удаленный конец тунеля после указанных n-секунд,
:: если по туннелю не передавался никакой трафик.
:: Указывает, если в течении 120 секунд не было получено ни одного пакета,
:: то туннель будет перезапущен.
echo keepalive 10 120>>"%SRV_FILE2%.ovpn"
:: Включаем сжатие
echo comp-lzo>>"%SRV_FILE2%.ovpn"
:: Не перечитавать файлы ключей при перезапуске туннеля
echo persist-key>>"%SRV_FILE2%.ovpn"
:: Активирует работу tun/tap устройств в режиме persist
echo persist-tun>>"%SRV_FILE2%.ovpn"
:: Алгоритм шифрования. Должен быть одинаковый клиент/сервер
echo cipher %cipher%>>"%SRV_FILE2%.ovpn"
if %ServerType%==WindowsPC (echo status status.log>>"%SRV_FILE2%.ovpn")
:: Путь к логу
if %ServerType%==WindowsPC (echo log openvpn.log>>"%SRV_FILE2%.ovpn")
:: Путь к статус-файлу, в котором содержится информация о текущих соединениях и информация о интерфейсах TUN/TAP
if %ServerType%==WindowsPC (echo status status.log>>"%SRV_FILE2%.ovpn")
:: Уровень логирования
echo verb 4 >>"%SRV_FILE2%.ovpn"
:: Если значение установлено в 20, то в лог будет записываться только по 20 сообщений из одной категории
echo mute 20>>"%SRV_FILE2%.ovpn"
::echo sndbuf 0 >>"%SRV_FILE2%.ovpn"
::echo rcvbuf 0 >>"%SRV_FILE2%.ovpn"
if %ovpn_protocol%==udp (echo explicit-exit-notify 1 >>"%SRV_FILE2%.ovpn")

:: Интеграция ca.crt в *.ovpn-файл
echo ^<ca^>>>"%SRV_FILE2%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%KEY_DIR%\ca.crt" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ca.crt">>"%SRV_FILE2%.ovpn"
)
echo ^</ca^>>>"%SRV_FILE2%.ovpn"

:: Интеграция %server%.crt в *.ovpn-файл
echo ^<cert^>>>"%SRV_FILE2%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%SRV_FILE1%.crt" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%SRV_FILE1%.crt">>"%SRV_FILE2%.ovpn"
)
echo ^</cert^>>>"%SRV_FILE2%.ovpn"

:: Интеграция %server%.key в *.ovpn-файл
echo ^<key^>>>"%SRV_FILE2%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN PRIVATE KEY-----" "%SRV_FILE1%.key" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%SRV_FILE1%.key">>"%SRV_FILE2%.ovpn"
)
echo ^</key^>>>"%SRV_FILE2%.ovpn"

:: Интеграция ta.key в *.ovpn-файл
echo ^<tls-auth^>>>"%SRV_FILE2%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN OpenVPN Static key V1-----" "%KEY_DIR%\ta.key" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ta.key">>"%SRV_FILE2%.ovpn"
)
echo ^</tls-auth^>>>"%SRV_FILE2%.ovpn"

:: Интеграция dh%KEY_SIZE%.pem" в *.ovpn-файл
echo ^<dh^>>>"%SRV_FILE2%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN DH PARAMETERS-----" "%KEY_DIR%\dh%KEY_SIZE%.pem" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\dh%KEY_SIZE%.pem">>"%SRV_FILE2%.ovpn"
)
echo ^</dh^>>>"%SRV_FILE2%.ovpn"
:: Окончание создания %SRV%.ovpn-файла
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
echo 00  - Вернуться назад
echo 0   - Выход
echo.
set /P CLIENT_NAME="Введите имя клиента (разрешены английские буквы, цифры и символы _.-): "
@echo %CLIENT_NAME%|>nul findstr/bei "[a-z0-9_.-]*"
IF ERRORLEVEL 1 (
	cls
	CALL :EchoColor 4 "[ОШИБКА] ИМЯ КЛИЕНТА СОДЕРЖИТ ЗАПРЕЩЕННЫЕ БУКВЫ/СИМВОЛЫ"
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

:: Создание запроса на сертификат, который будет действителен в течение 10 лет
:: %CLIENT_NAME%.key - приватный ключ клиента OpenVPN, секретный
echo.
CALL :EchoColor 3 "Нажимайте enter, если не требуется менять значения в [] - 10 раз"
echo.
CALL :EchoColor 3 "Рекомендуется оставить по умолчанию"
echo.
echo.
"%OpenVPN_DIR%\bin\openssl.exe" req -days 3650 -nodes -new -keyout "%KEY_DIR%\%CLIENT_NAME%.key" -out "%KEY_DIR%\%CLIENT_NAME%.csr" -config "%KEY_CONFIG%"
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] %CLIENT_NAME%.csr - файл запроса на подпись сертификата клиента создан [УСПЕШНО]"
	echo.
	::CALL :EchoColor 2 "[V] %CLIENT_NAME%.csr - certificate sign request succesfully created"
	CALL :EchoColor 2 "[V] %CLIENT_NAME%.key - приватный ключ клиента создан [УСПЕШНО]"
	::CALL :EchoColor 2 "[V] %CLIENT_NAME%.key succesfully created"
	echo.
	)

:: Подпись запроса на сертификат в нашем центре сертификации, создав пару сертификат/ключ
echo.
CALL :EchoColor 3 "Нажмите английскую букву y и enter дважды для подписи сертификата"
echo.
"%OpenVPN_DIR%\bin\openssl.exe" ca -days 3650 -out "%KEY_DIR%\%CLIENT_NAME%.crt" -in "%KEY_DIR%\%CLIENT_NAME%.csr" -config "%KEY_CONFIG%"
if ERRORLEVEL 0 (
	CALL :EchoColor 2 "[V] %CLIENT_NAME%.crt - Сертификат клиента создан [УСПЕШНО]"
	::CALL :EchoColor 2 "[V] %CLIENT_NAME%.crt - Client`s certificate succesfully created"
	echo.
	)
	
:: Удаление всех *.old-файлов, созданных в этом процессе, чтобы избежать ошибок при создании файлов в будущем
del /q "%KEY_DIR%\*.old"
IF NOT ERRORLEVEL 0 echo ERROR!

IF NOT EXIST "%KEY_DIR%\%CLIENT_NAME%" mkdir "%KEY_DIR%\%CLIENT_NAME%"

::-----------------------------------------
:: Создание %CLIENT_NAME%.ovpn-файла
:: Указываем, чтобы клиент забирал информацию о маршрутизации с сервера
echo client>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Создаем маршрутизируемый IP туннель
echo dev tun>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Протокол для подключения
echo proto %ovpn_protocol%>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: IP-адрес сервера с портом
echo remote %IP_SERVER% %ovpnport%>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Устанавливает время в секундах для запроса об удаленном имени хоста.
:: Актуально только если используется DNS-имя удаленного хоста.
:: infinite - бесконечно
echo resolv-retry infinite>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
::echo nobind>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Указывает не перечитавать файлы ключей при перезапуске туннеля
echo persist-key>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Оставляет без изменения устройства tun/tap при перезапуске OpenVPN
echo persist-tun>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Дает указание клиенту OpenVPN разрешать подключения только к VPN-серверу,
:: у которого есть сертификат с атрибутом EKU X.509, установленным в значение TLS Web Server Authentication
echo remote-cert-tls server>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Указываем алгоритм шифрования. Должен быть одинаковый клиент/сервер
echo cipher %cipher%>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Включаем сжатие
echo comp-lzo>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Уровень логирования
echo verb 3 >>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Если значение установлено в 20, то в лог будет записываться только по 20 сообщений из одной категории
echo mute 20>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"

:: Интеграция ca.crt в *.ovpn-файл
echo ^<ca^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%KEY_DIR%\ca.crt" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ca.crt">>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
)
echo ^</ca^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"

:: Интеграция %CLIENT_NAME%.crt в *.ovpn-файл
echo ^<cert^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN CERTIFICATE-----" "%CLIENT_FILE1%.crt" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%CLIENT_FILE1%.crt">>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
)
echo ^</cert^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"

:: Интеграция %CLIENT_NAME%.key в *.ovpn-файл
echo ^<key^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN PRIVATE KEY-----" "%CLIENT_FILE1%.key" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%CLIENT_FILE1%.key">>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
)
echo ^</key^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"

:: Интеграция ta.key в *.ovpn-файл
echo ^<tls-auth^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN OpenVPN Static key V1-----" "%KEY_DIR%\ta.key" ') do set /a "header_line=%%a-1"
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\ta.key">>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
)
echo ^</tls-auth^>>>"%CLIENT_FILE1%\%KEY_ORG%.%CLIENT_NAME%.ovpn"
:: Окончание создания %CLIENT_NAME%.ovpn-файла
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
:: Отзыв сертификата пользователя
cls
Set /p revokeuser="Введите имя сертификата пользователя, который требуется отозвать: "
if not exist "%KEY_DIR%\%revokeuser%.crt" (
	CALL :EchoColor 4 "[X] Сертификат %KEY_DIR%\%revokeuser%.crt [НЕ НАЙДЕН]"
	echo.
	pause
	goto REVOKE-CRT
	)
set "event=before_REVOKE_%revokeuser%"
call :backup
"%OpenVPN_DIR%\bin\openssl.exe" ca -revoke "%KEY_DIR%\%revokeuser%.crt" -config "%KEY_CONFIG%"
rem generate new crl
"%OpenVPN_DIR%\bin\openssl.exe" ca -gencrl -out "%KEY_DIR%\crl.pem" -config "%KEY_CONFIG%"
CALL :EchoColor 2 "[V] Сертификат %revokeuser% отозван [УСПЕШНО]
echo.
echo.
call :DelCrl-verify
call :AddCrl-verify
set "event=after_REVOKE_%revokeuser%"
call :backup
goto START

:DelCrl-verify
Set /p revokeserver="Введите имя сертификата сервера, в который требуется добавить данные об удаленных клиентских сертифкатах: "
if not exist "%KEY_DIR%\%revokeserver%\%revokeserver%.ovpn" (
	CALL :EchoColor 4 "[X] Файл %KEY_DIR%\%revokeserver%\%revokeserver%.ovpn [НЕ НАЙДЕН]"
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
:: Интеграция crl-verify в *.ovpn-файл
echo ^<crl-verify^>>>"%f_in%"
set "header_line="
for /f "tokens=1  delims=[]" %%a in ('find /i /n "-----BEGIN X509 CRL-----" "%KEY_DIR%\crl.pem" ') do set /a "header_line=%%a-1" 1>nul 2>&1
if defined header_line (
  more /p +%header_line% "%KEY_DIR%\crl.pem">>"%f_in%"
)
echo ^</crl-verify^>>>"%f_in%"
echo.
echo Скопируйте файл "%KEY_DIR%\%revokeserver%\%revokeserver%.ovpn" в папку "%OpenVPN_DIR%\config\"
echo или в "%OpenVPN_DIR%\config-auto\"
echo.
echo И перезапустите службу/программу OpenVPN
echo.
echo Если у вас роутер Keenetic, то содержимое файла скопируйте в роутер и перезапустите OpenVPN-подключение
echo.
pause
goto :EOF

:PublicIP
cls
Echo Идёт процесс получения внешнего (Public) IP...
for /f %%a in ('powershell Invoke-RestMethod api.ipify.org') do set "PublicIP=%%a"
echo Ваш Public IP: %PublicIP%
set /p "x=%PublicIP%"<nul|Clip
echo уже скопирован в буфер обмена
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
:: [Ru] Удалить содержимое папки %KEY_DIR% без вывода запроса
:: [En] delete the %KEY_DIR% and any subdirs quietly
rmdir /s /q "%KEY_DIR%"
if ERRORLEVEL 0 CALL :EchoColor 2 "[V] Все сертификаты успешно удалены!"
echo.
timeout /t 3
goto :EOF
 
:EXIT
Exit

:EchoColor [%1=Color %2="Text" %3=/n (CRLF, optional)] (Support multiple arguments at once)
:: Вывод цветного текста. Ограничения - не выводится восклицательный знак, остальные спецсимволы разрешены.
:: Работа с более, чем одним набором параметров
If Not Defined multiple If Not "%~4"=="" (
	Call :EchoWrapper %*
	Set multiple=
	Exit /B
)
SetLocal EnableDelayedExpansion
If Not Defined BkSpace Call :EchoColorInit
:: Экранирование входящего текста от обратных и прямых слэшей, чистка некоторых символов.
Set "$Text=%~2"
Set "$Text=.%BkSpace%!$Text:\=.%BkSpace%\..\%BkSpace%%BkSpace%%BkSpace%!"
Set "$Text=!$Text:/=.%BkSpace%/..\%BkSpace%%BkSpace%%BkSpace%!"
Set "$Text=!$Text:"=\"!"
Set "$Text=!$Text:^^=^!"
:: Если XP, выводим обычный текст.
If "%isXP%"=="true" (
	<nul Set /P "=.!BkSpace!%~2"
	GoTo :unsupported
)
:: Подаем текст на stdout, не создавая временных файлов и используя трюк с путём.
:: В случае неудачи (проблемный\слишком длинный путь?) выводим текст as is, без расцветки.
:: Если результирующая длина строки (плюс уже имеющиеся там символы) превышает ширину консоли, то вывод тоже будет неудачным. Но получить текущую позицию каретки программно нельзя.
PushD "%~dp0"
2>nul FindStr /R /P /A:%~1 "^-" "%$Text%\..\%~nx0" nul
If !ErrorLevel! GTR 0 <nul Set /P "=.!BkSpace!%~2"
PopD
:: Убираем путь, имя файла и дефис с помощью рассчитаного ранее количества символов.
For /L %%A In (1,1,!BkSpaces!) Do <nul Set /P "=!BkSpace!"
:unsupported
:: Выводим CRLF, если указан третий аргумент.
If /I "%~3"=="/n" Echo.
EndLocal
GoTo :EOF

:EchoWrapper
:: Обработка аргументов поочерёдно
SetLocal EnableDelayedExpansion
:NextArg
Set multiple=true
:: Ох уж это удвоение "^" при передаче аргументов...
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
:: Отрабатывающая при первом запуске родительской функции инициализация нужных переменных
:: Важно! Под XP, в силу реализации тамошнего findstr, 0x08 в путях не работает, заменяясь на точку. Отключаем цветной вывод для XP.
For /F "tokens=2 delims=[]" %%A In ('Ver') Do (For /F "tokens=2,3 delims=. " %%B In ("%%A") Do (If "%%B"=="5" Set isXP=true))
:: Получаем комбинацию "0x08 0x20 0x08" с помощью prompt
For /F "tokens=1 delims=#" %%A In ('"Prompt #$H# & Echo On & For %%B In (1) Do rem"') Do Set "BkSpace=%%A"
:: Рассчитываем требуемое количество символов для подавления всего, кроме выводимого текста
Set ScriptFileName=%~nx0
Call :StrLen ScriptFileName
Set /A "BkSpaces=!strLen!+6"
GoTo :EOF

:StrLen [%1=VarName (not VALUE), ret !strLen!]
:: Получение длины строки
Set StrLen.S=A!%~1!
Set StrLen=0
For /L %%P In (12,-1,0) Do (
	Set /A "StrLen|=1<<%%P"
	For %%I In (!StrLen!) Do If "!StrLen.S:~%%I,1!"=="" Set /A "StrLen&=~1<<%%P"
)
GoTo :EOF

:: Эта строка должна быть последней и не оканчиваться на CRLF.
-