@echo off

rem #
rem #  time2backup portable script for Windows
rem #
rem #  Website: https://time2backup.org
rem #  MIT License
rem #  Copyright (c) 2017-2019 Jean Prunneaux
rem #

rem clear screen
cls

rem init variables
set current_path=%~dp0

rem run time2backup into cygwin
%current_path%\cygwin\bin\bash.exe --login -i /usr/src/time2backup/time2backup.sh -c %current_path%\config %*

rem forward exit code
exit /b %errorlevel%
