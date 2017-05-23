@echo off

rem #
rem #  time2backup uninstall script for Windows
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

set install_path=C:\time2backup


rem #
rem #  Main program
rem #

echo time2backup uninstaller
echo.

set /p confirm="Are you sure you want to uninstall time2backup? (y/N) "
echo %confirm%
if %confirm%==y (goto uninstall) else goto endExit

:uninstall
echo Removing %install_path%...
del /S /F /Q %install_path%
if %errorlevel% NEQ 0 goto endError


rem #
rem #  End of script
rem #

:endOK
echo.
echo Uninstall successful!
goto endScript

:endError
echo.
echo Uninstall failed!

:endScript
echo.
pause

:endExit
exit
