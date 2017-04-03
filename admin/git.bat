@echo on
setlocal

set BASE_DIR=%~dp0\..

call %BASE_DIR%\admin\configure.bat

if not exist C:\msys\usr\bin\git.exe (
    C:\msys\usr\bin\pacman -S --noconfirm git
)
