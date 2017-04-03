@echo on
setlocal

set BASE_DIR=%~dp0\..

call %BASE_DIR%\admin\configure.bat

if not exist C:\msys\mingw%PROC_TYPE%\bin\postgres.exe (
    C:\msys\usr\bin\pacman -S --noconfirm mingw-w64-%MSYS_ARCH%-postgresql

    C:\msys\usr\bin\bash %BASE_DIR%\scripts\install_postgresql.sh
)
