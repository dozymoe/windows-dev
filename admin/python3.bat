@echo on
setlocal

set BASE_DIR=%~dp0\..

call %BASE_DIR%\admin\configure.bat

if not exist C:\msys\usr\bin\python3.exe (
    C:\msys\usr\bin\pacman -S --noconfirm python3

    C:\msys\usr\bin\python3 -m ensurepip
    C:\msys\usr\bin\python3 -m pip install --upgrade pip
    C:\msys\usr\bin\python3 -m pip install virtualenv
)

if not exist C:\msys\usr\bin\gcc.exe (
    C:\msys\usr\bin\pacman -S --noconfirm gcc
)
