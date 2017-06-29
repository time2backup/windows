@echo off

rem #
rem #  time2backup script for Windows
rem #
rem #  Website: https://time2backup.github.io
rem #  MIT License
rem #  Copyright (c) 2017 Jean Prunneaux
rem #
rem #  Version 0.3.0 (2017-06-29)
rem #


rem #
rem #  Init
rem #

rem clear screen
cls

rem init variables
set current_path=%~dp0


rem #
rem #  Main program
rem #

echo time2backup for Windows
echo.

rem run time2backup into cygwin
%current_path%\cygwin\bin\bash.exe --login -i /opt/time2backup/time2backup.sh -c "%AppData%\time2backup" -p %*

exit /b %errorlevel%
