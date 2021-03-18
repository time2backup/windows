@echo off

rem #
rem #  time2backup install script for Windows
rem #
rem #  Website: https://time2backup.org
rem #  MIT License
rem #  Copyright (c) 2017-2021 Jean Prunneaux
rem #


rem #
rem #  Init
rem #

rem clear screen
cls

rem set variables
set version=
set current_path=%~dp0
set libbash_gui=%current_path%\files\time2backup\libbash\inc\libbash_gui.vbs
set install_path=%SystemDrive%\time2backup
set shortcuts=false
set exitcode=0


rem #
rem #  Main program
rem #

rem if path specified,
if not "%1"=="" (set install_path=%1)

echo time2backup %version% installer
echo.

echo Waiting for confirmation dialog...
cscript /NoLogo "%libbash_gui%" lbg_yesno "Install time2backup in %install_path% ? To change path, run install.bat with custom path." "time2backup installer"
if %errorlevel% neq 0 goto endCancel

:install
echo Install into %install_path%...

echo Running cygwin installer...
"%current_path%\files\setup-x86_64.exe" --quiet-mode --wait -s http://mirrors.kernel.org/sourceware/cygwin --root "%install_path%\cygwin" -P rsync -P nano --upgrade-also --no-startmenu --no-desktop
if %errorlevel% NEQ 0 goto endError

rem copy files

echo.
echo Copy time2backup files...
xcopy /e /i /y /q "%current_path%\files\time2backup" "%install_path%\cygwin\usr\src\time2backup"
if %errorlevel% NEQ 0 goto endError

echo.
echo Copy windows files...
xcopy /s /y /q "%current_path%\files\bin" "%install_path%"
if %errorlevel% NEQ 0 goto endError

rem create shortcut

echo.
echo Create time2backup link...

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

echo.
echo Create start menu shortcut...

rem Delete old menu entries
del /f "%AllUsersProfile%\Microsoft\Windows\Start Menu\Programs\Accessories\time2backup.lnk"
del /f "%AppData%\Microsoft\Windows\Start Menu\Programs\Accessories\time2backup.lnk"

rem try to install for all users
xcopy /y "%install_path%\time2backup.lnk" "%AllUsersProfile%\Microsoft\Windows\Start Menu\Programs\"
if %errorlevel%==0 goto endOK

rem if not administrator
echo Failed. Creating shortcut only for current user...
xcopy /y "%install_path%\time2backup.lnk" "%AppData%\Microsoft\Windows\Start Menu\Programs\"
if %errorlevel% NEQ 0 echo Failed. Please create shortcut manually.

goto endOK


rem #
rem #  End of script
rem #

:endCancel
echo Installation cancelled
goto endScript

:endOK
echo.
cscript /NoLogo "%libbash_gui%" lbg_display_info "Install finished" "time2backup installer"
goto endScript

:endError
echo.
cscript /NoLogo "%libbash_gui%" lbg_display_error "Install failed!" "time2backup installer"
set exitcode=1

:endScript
exit /b %exitcode%
