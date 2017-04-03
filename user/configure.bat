@echo on
setlocal

set BASE_DIR=%~dp0\..

if not exist C:\msys\home\%USERNAME% (
    mkdir C:\msys\home\%USERNAME%
)

if not exist C:\msys\home\%USERNAME%\.vim (
    mkdir C:\msys\home\%USERNAME%\.vim

    copy %BASE_DIR%\files\vim\* C:\msys\home\%USERNAME%\.vim\
)

if not exist C:\msys\home\%USERNAME%\.vim\backup (
    mkdir C:\msys\home\%USERNAME%\.vim\backup
)

if not exist C:\msys\home\%USERNAME%\.vim\swap (
    mkdir C:\msys\home\%USERNAME%\.vim\swap
)

if exist C:\msys\usr\bin\git.exe (
    C:\msys\usr\bin\git config --global core.eol crlf
)

if exist C:\msys\mingw%PROC_TYPE%\bin\postgres.exe (
    C:\msys\mingw%PROC_TYPE%\bin\createuser -U postgres --createdb --createrole --login --echo %USERNAME%
    C:\msys\mingw%PROC_TYPE%\bin\createdb -U postgres --owner=%USERNAME% --echo %USERNAME%
)
