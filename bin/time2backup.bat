@echo off

rem #
rem #  time2backup for Windows
rem #
rem #  Website: https://time2backup.github.io
rem #  MIT License
rem #  Copyright (c) 2017 Jean Prunneaux
rem #
rem #  Version 0.1.0 (2017-06-05)
rem #


rem #
rem #  Init
rem #

rem clear screen
cls

set current_path=%~dp0

rem #
rem #  Main program
rem #

echo time2backup for Windows
echo.

rem run time2backup into cygwin
%current_path%\cygwin\bin\bash.exe --login -i /opt/time2backup/time2backup.sh -p %*

rem get result of the command
set exitcode=%errorlevel%
if %exitcode% NEQ 0 goto endError


rem #
rem #  End of script
rem #

:endOK
echo.
echo Finised with success!
goto endScript

:endError
echo.
echo Finished with errors (exit code: %exitcode%)
echo Please scroll up to see details

:endScript
echo.
pause
