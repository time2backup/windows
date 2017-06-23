@echo off

rem #
rem #  time2backup install script for Windows
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

rem set paths
set current_path=%~dp0
set libbash_gui=%current_path%\files\time2backup\libbash\inc\libbash_gui.vbs
set default_path=%SystemDrive%\time2backup
set install_path=
set desktop_icon=false

rem #
rem #  Main program
rem #

echo Install time2backup
echo.

set /p install_path="Choose an install path WITHOUT SPACES [%default_path%]: "
if not "%install_path%"=="" goto install

echo.
echo Do you want to create a desktop icon?
set /p confirm="You need to run this script as administrator (y/N) "
if "%confirm%"=="y" set desktop_icon=true

rem default path
set install_path=%default_path%

:install
echo Install into %install_path%...

echo Running cygwin installer...
"%current_path%\files\cygwin-setup.exe" --quiet-mode --wait -s http://mirrors.kernel.org/sourceware/cygwin --root "%install_path%\cygwin" -P rsync -P nano --upgrade-also --no-startmenu --no-desktop
if %errorlevel% NEQ 0 goto endError

rem run a first

echo.
echo Copy time2backup binaries...
xcopy /e /i /y /q "%current_path%\files\time2backup" "%install_path%\cygwin\opt\time2backup"
if %errorlevel% NEQ 0 goto endError

echo.
echo Copy time2backup files...
xcopy /s /y /q "%current_path%\files\bin" "%install_path%"
if %errorlevel% NEQ 0 goto endError

rem create shortcut
echo.
echo Create time2backup links...

rem create temporary VBScript
(echo Dim shell, link
echo Set shell = CreateObject^("WScript.shell"^)
echo Set link = shell.CreateShortcut^("%install_path%\time2backup.lnk"^)
echo link.Description = "Backup and restore your files"
echo link.TargetPath = "%install_path%\time2backup.bat"
echo link.IconLocation = "%install_path%\icon.ico"
echo link.WorkingDirectory = "%install_path%"
echo link.Save
)> "%current_path%\files\create_link.vbs"
cscript /NoLogo "%current_path%\files\create_link.vbs"
if %errorlevel% NEQ 0 goto endError

rem create start menu shortcut
echo.
echo Create start menu shortcut...
xcopy /y "%install_path%\time2backup.lnk" "%AllUsersProfile%\Microsoft\Windows\Start Menu\Programs\Accessories\"
if %errorlevel% NEQ 0 echo Failed. Please create shortcut manually.

rem create desktop icon
if %desktop_icon%==false goto endOK
echo.
echo Create desktop icon...
xcopy /y "%install_path%\time2backup.lnk" "%SystemDrive%\Users\Public\Desktop\"
if %errorlevel% NEQ 0 echo Failed. Please create shortcut manually.


rem #
rem #  End of script
rem #

:endOK
echo.
cscript /NoLogo "%libbash_gui%" lbg_display_info "Install finished" "time2backup installer"
exit

:endError
echo.
cscript /NoLogo "%libbash_gui%" lbg_display_error "Install failed!" "time2backup installer"
exit 1
