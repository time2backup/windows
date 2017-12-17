@echo off

rem #
rem #  time2backup script for Windows
rem #
rem #  Website: https://time2backup.github.io
rem #  MIT License
rem #  Copyright (c) 2017 Jean Prunneaux
rem #

rem clear screen
cls

rem init variables
set current_path=%~dp0

rem run time2backup into cygwin
%current_path%\cygwin\bin\bash.exe --login -i /usr/src/time2backup/time2backup.sh -c "%AppData%\time2backup" %*

rem forward exit code
exit /b %errorlevel%
