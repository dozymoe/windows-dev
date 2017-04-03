@echo on
setlocal

set BASE_DIR=%~dp0\..

call %BASE_DIR%\admin\configure.bat

if not exist C:\msys\usr\bin\sshd.exe (
    C:\msys\usr\bin\pacman -S --noconfirm openssh

    if not exist C:\msys\etc\ssh\ssh_host_rsa_key (
        C:\msys\usr\bin\ssh-keygen -A
    )

    C:\msys\usr\bin\bash %BASE_DIR%\scripts\install_sshd.sh
)
