@echo off

rem #
rem #  time2backup install script for Windows
rem #
rem #  Website: https://time2backup.github.io
rem #  MIT License
rem #  Copyright (c) 2017 Jean Prunneaux
rem #
rem #  Version 0.1.0 (2017-05-24)
rem #


rem #
rem #  Init
rem #

rem clear screen
cls

set default_path=%SystemDrive%\time2backup
set current_path=%~dp0
set install_path=


rem #
rem #  Main program
rem #

echo Install time2backup
echo.

set /p install_path="Choose an install path [%default_path%]: "
if not "%install_path%"=="" goto install

rem default path
set install_path=%default_path%

:install
echo Install into %install_path%...

echo Running cygwin installer...
%current_path%\bin\cygwin-setup.exe --quiet-mode --wait -s http://mirrors.kernel.org/sourceware/cygwin --root %install_path%\cygwin -P rsync -P nano --upgrade-also --no-startmenu --no-desktop
if %errorlevel% NEQ 0 goto endError

echo.
echo Copy time2backup files...
xcopy /e /i /y %current_path%\src %install_path%\cygwin\opt\time2backup
if %errorlevel% NEQ 0 goto endError

echo.
echo Copy time2backup executable...
xcopy /y %current_path%\bin\time2backup.bat %install_path%
if %errorlevel% NEQ 0 goto endError

echo.
echo Copy uninstall script...
xcopy /y %current_path%\bin\uninstall.bat %install_path%
if %errorlevel% NEQ 0 goto endError

rem copy link
echo.
echo Create time2backup links...
xcopy /y time2backup.lnk %install_path%
if %errorlevel% NEQ 0 goto endError


rem #
rem #  End of script
rem #

:endOK
echo.
echo Install successful!
goto endScript

:endError
echo.
echo Install failed!

:endScript
echo.
pause
