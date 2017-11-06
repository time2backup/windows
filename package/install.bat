@echo off

rem #
rem #  time2backup install script for Windows
rem #
rem #  Website: https://time2backup.github.io
rem #  MIT License
rem #  Copyright (c) 2017 Jean Prunneaux
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

echo.
cscript /NoLogo "%libbash_gui%" lbg_yesno "Do you want to create menu shortcut and desktop icon?" "time2backup installer" true
if %errorlevel%==0 set shortcuts=true

:install
echo Install into %install_path%...

echo Running cygwin installer...
"%current_path%\files\cygwin-setup.exe" --quiet-mode --wait -s http://mirrors.kernel.org/sourceware/cygwin --root "%install_path%\cygwin" -P rsync -P nano --upgrade-also --no-startmenu --no-desktop
if %errorlevel% NEQ 0 goto endError

rem run a first

echo.
echo Copy time2backup files...
xcopy /e /i /y /q "%current_path%\files\time2backup" "%install_path%\cygwin\opt\time2backup"
if %errorlevel% NEQ 0 goto endError

echo.
echo Copy windows files...
xcopy /s /y /q "%current_path%\files\bin" "%install_path%"
if %errorlevel% NEQ 0 goto endError

echo.
echo Install time2backup...
"%install_path%\cygwin\bin\bash.exe" --login -i /opt/time2backup/time2backup.sh install
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
if %shortcuts%==false goto endOK

echo.
echo Create start menu shortcut...

rem try to install for all users
xcopy /y "%install_path%\time2backup.lnk" "%AllUsersProfile%\Microsoft\Windows\Start Menu\Programs\Accessories\"
if %errorlevel%==0 goto desktopIcon

rem if not administrator
echo Failed. Creating shortcut only for current user.

xcopy /y "%install_path%\time2backup.lnk" "%AppData%\Microsoft\Windows\Start Menu\Programs\Accessories\"
if %errorlevel% NEQ 0 echo Failed. Please create shortcut manually.


:desktopIcon
echo.
echo Create desktop icon...

rem try to install for all users
xcopy /y "%install_path%\time2backup.lnk" "%SystemDrive%\Users\Public\Desktop\"
if %errorlevel%==0 goto endOK

rem if not administrator
echo Failed. Creating icon only for current user.

xcopy /y "%install_path%\time2backup.lnk" "%UserProfile%\Desktop\"
if %errorlevel% NEQ 0 echo Failed. Please create icon manually.

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
