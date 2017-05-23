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

set current_path=%~dp0
set install_path=C:\time2backup


rem #
rem #  Main program
rem #

echo time2backup installer
echo.

echo Install into %install_path%...

echo Running cygwin installer...
bin\cygwin-setup.exe --quiet-mode --wait --root %install_path%\cygwin -P rsync -P nano --upgrade-also --no-startmenu --no-desktop
set exitcode=%errorlevel%
if %errorlevel% NEQ 0 goto endError

echo.
echo Copy time2backup files...
xcopy /E /I /Y src %install_path%\cygwin\opt\time2backup
if %errorlevel% NEQ 0 goto endError

echo.
echo Copy time2backup executable...
xcopy /Y bin\time2backup.bat %install_path%
if %errorlevel% NEQ 0 goto endError

rem copy link
echo.
echo Create time2backup link...
xcopy /Y time2backup.lnk %install_path%
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
