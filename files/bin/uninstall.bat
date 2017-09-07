@echo off

rem #
rem #  time2backup uninstall script for Windows
rem #
rem #  Website: https://time2backup.github.io
rem #  MIT License
rem #  Copyright (c) 2017 Jean Prunneaux
rem #
rem #  Version 1.1.0 (2017-09-06)
rem #


rem #
rem #  Init
rem #

rem clear screen
cls

rem Get current path (time2backup install)
set current_path=%~dp0

rem dialogs library
set libbash_gui=%current_path%\cygwin\opt\time2backup\libbash\inc\libbash_gui.vbs

rem default variables
set exitcode=0

rem #
rem #  Main program
rem #

echo time2backup uninstaller
echo.

echo Waiting for confirmation dialog...
cscript /NoLogo "%libbash_gui%" lbg_yesno "Are you sure you want to uninstall time2backup?" "time2backup uninstall"
if %errorlevel% neq 0 goto endCancel

cscript /NoLogo "%libbash_gui%" lbg_yesno "Do you want to delete menu shortcut and desktop icon?" "time2backup uninstall" true
if %errorlevel% neq 0 goto uninstall


rem delete start menu shortcut (trying for all users and current user)
echo.
echo Delete start menu shortcut...
del /f "%AllUsersProfile%\Microsoft\Windows\Start Menu\Programs\Accessories\time2backup.lnk"
del /f "%AppData%\Microsoft\Windows\Start Menu\Programs\Accessories\time2backup.lnk"

rem delete desktop icon (trying for all users and current user)
echo.
echo Delete desktop icon...
del /f "%SystemDrive%\Users\Public\Desktop\time2backup.lnk"
del /f "%UserProfile%\Desktop\time2backup.lnk"


:uninstall
rem delete files
echo.
echo Removing files...
del /s /f /q %current_path%
set exitcode=%errorlevel%
if %exitcode% NEQ 0 goto endError


rem #
rem #  End of script
rem #

:endCancel
echo.
echo Cancelled.
goto endScript

:endOK
echo.
echo Uninstall successful!
goto endScript

:endError
echo.
echo Uninstall failed!
pause

:endScript
exit /b %exitcode%
