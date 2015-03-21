@echo off
TITLE Switch ORACLE server - Modifying your HOSTS file
COLOR F0
ECHO.


:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:GETINFO
FIND /C /I "ocb-server" %WINDIR%\system32\drivers\etc\hosts>>find_tmp.txt
IF %ERRORLEVEL% NEQ 0 (
ECHO No setting found.
GOTO LOOP
)

FIND /C /I "127.0.0.1 ocb-server" %WINDIR%\system32\drivers\etc\hosts>>find_tmp.txt
IF %ERRORLEVEL% NEQ 0 ECHO Using oracle SERVER - 10.62.68.7

FIND /C /I "10.62.68.7 ocb-server" %WINDIR%\system32\drivers\etc\hosts>>find_tmp.txt
IF %ERRORLEVEL% NEQ 0 ECHO Using oracle LOCAL - 127.0.0.1

del find_tmp.txt
ECHO.

:LOOP
SET Choice=
SET /P Choice="Do you want to use ORACLE server ? (Y/N)"

IF NOT '%Choice%'=='' SET Choice=%Choice:~0,1%

ECHO.
IF /I '%Choice%'=='Y' GOTO SERVER
IF /I '%Choice%'=='N' GOTO LOCAL
ECHO Please type Y (for ORACLE server) or N (for ORACLE local) to proceed!
ECHO.
GOTO Loop


:LOCAL
setlocal enabledelayedexpansion
::Create your list of host domains
set LIST=(ocb-server)
::Set the ip of the domains you set in the list above
set ocb-server=127.0.0.1
:: deletes the parentheses from LIST
set _list=%LIST:~1,-1%
::ECHO %WINDIR%\System32\drivers\etc\hosts > tmp.txt
for  %%G in (%_list%) do (
    set  _name=%%G
    set  _value=!%%G!
    SET NEWLINE=^& echo.
    ECHO Carrying out requested modifications to your HOSTS file
    ::strip out this specific line and store in tmp file
    type %WINDIR%\System32\drivers\etc\hosts | findstr /v !_name! > tmp.txt
    ::re-add the line to it
    ECHO %NEWLINE%^!_value! !_name!>>tmp.txt
    ::overwrite host file
    copy /b/v/y tmp.txt %WINDIR%\System32\drivers\etc\hosts
    del tmp.txt
)
ipconfig /flushdns
ECHO.
ECHO.
ECHO Finished, you may close this window now.
ECHO You are using ORACLE local at IP address: 127.0.0.1
GOTO END

:SERVER
setlocal enabledelayedexpansion
::Create your list of host domains
set LIST=(ocb-server)
::Set the ip of the domains you set in the list above
set ocb-server=10.62.68.7
:: deletes the parentheses from LIST
set _list=%LIST:~1,-1%
::ECHO %WINDIR%\System32\drivers\etc\hosts > tmp.txt
for  %%G in (%_list%) do (
    set  _name=%%G
    set  _value=!%%G!
    SET NEWLINE=^& echo.
    ECHO Carrying out requested modifications to your HOSTS file
    ::strip out this specific line and store in tmp file
    type %WINDIR%\System32\drivers\etc\hosts | findstr /v !_name! > tmp.txt
    ::re-add the line to it
    ECHO %NEWLINE%^!_value! !_name!>>tmp.txt
    ::overwrite host file
    copy /b/v/y tmp.txt %WINDIR%\System32\drivers\etc\hosts
    del tmp.txt
)
ipconfig /flushdns
ECHO.
ECHO.
ECHO Finished, you may close this window now.
ECHO You are using ORACLE server at IP address: 10.62.68.7
GOTO END

:END
ECHO.
ping -n 11 127.0.0.1 > nul
EXIT