@echo off

rem #
rem #  time2backup portable script for Windows
rem #
rem #  Website: https://time2backup.org
rem #  MIT License
rem #  Copyright (c) 2017-2021 Jean Prunneaux
rem #

rem clear screen
cls

rem init variables
set current_path=%~dp0

rem run time2backup into cygwin
%current_path%\cygwin\bin\mintty.exe -i %current_path%\icon.ico -T time2backup /bin/bash -l -i /usr/src/time2backup/time2backup.sh -c %current_path%\config %*

rem forward exit code
exit /b %errorlevel%
