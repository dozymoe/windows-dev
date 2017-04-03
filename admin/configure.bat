@echo on
setlocal

set MSYS_VER=20161025

set BASE_DIR=%~dp0\..
set OLD_PATH=%PATH%
set PATH=%BASE_DIR%\bin;%OLD_PATH%

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set PROC_TYPE=32 || set PROC_TYPE=64
for /f "tokens=4-5 delims=. " %%i in ('ver') do set OS_VER=%%i.%%j

if "%PROC_TYPE%" == "32" (
    set MSYS_ARCH=i686
    set OS_ARCH=x86
)
if "%PROC_TYPE%" == "64" (
    set MSYS_ARCH=x86_64
    set OS_ARCH=x64
)

set TARBALL=%BASE_DIR%\cache\msys2-base-%MSYS_ARCH%-%MSYS_VER%.tar.xz
if not exist C:\msys (
    cd %BASE_DIR%\cache

    curl -L -C - -O https://sourceforge.net/projects/msys2/files/Base/%MSYS_ARCH%/msys2-base-%MSYS_ARCH%-%MSYS_VER%.tar.xz --cacert %BASE_DIR%\ssl\certs\ca-bundle.crt --retry 99

    mkdir C:\msys
    cd C:\msys

    tar --strip 1 -xvpf %TARBALL:~2%
)

if not exist C:\msys\c (
    mkdir C:\msys\c
)

if not exist C:\msys\d (
    mkdir C:\msys\d
)

set PATH=C:\msys\usr\bin;C:\msys\mingw%PROC_TYPE%\bin;%OLD_PATH%

if not exist C:\msys\etc\pacman.d\gnupg\trustdb.gpg (
    C:\msys\usr\bin\bash -c "/c/msys/usr/bin/pacman-key --init"
    C:\msys\usr\bin\bash -c "/c/msys/usr/bin/pacman-key --populate"
)


if not exist C:\msys\mingw%PROC_TYPE%\bin\editrights.exe (
    C:\msys\usr\bin\pacman -S --noconfirm mingw-w64-%MSYS_ARCH%-editrights
)

if not exist C:\msys\usr\bin\cygrunsrv.exe (
    C:\msys\usr\bin\pacman -S --noconfirm cygrunsrv
)

if not exist C:\msys\mingw%PROC_TYPE%\bin\python2.exe (
    C:\msys\usr\bin\pacman -S --noconfirm mingw-w64-%MSYS_ARCH%-python2
)

C:\msys\mingw%PROC_TYPE%\bin\python2 %BASE_DIR%\scripts\set_path_env.py
