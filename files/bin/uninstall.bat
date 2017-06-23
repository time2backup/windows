@echo off

rem #
rem #  time2backup uninstall script for Windows
rem #
rem #  Website: https://time2backup.github.io
rem #  MIT License
rem #  Copyright (c) 2017 Jean Prunneaux
rem #
rem #  Version 0.2.0 (2017-06-08)
rem #


rem #
rem #  Init
rem #

rem clear screen
cls

rem Get current path (time2backup install)
set current_path=%~dp0


rem #
rem #  Main program
rem #

echo time2backup uninstaller
echo.

set /p confirm="Are you sure you want to uninstall time2backup? (y/N) "
if %confirm%==y (goto uninstall) else goto endExit

:uninstall
echo Removing files...
del /s /f /q %current_path%
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
