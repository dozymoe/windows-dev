import os
import _winreg as winreg

def fix_for_msys_bin(paths, arch=None):
    msys_bin = r'C:\msys\usr\bin'
    if msys_bin not in paths:
        paths.append(msys_bin)


def fix_for_mingw_bin(paths, arch):
    mingw_bin = r'C:\msys\mingw{0}\bin'.format(arch)
    if mingw_bin not in paths:
        paths.append(mingw_bin)


def fix_env_path():
    reg = winreg.ConnectRegistry(None, winreg.HKEY_LOCAL_MACHINE)
    key = winreg.OpenKey(reg, r'Hardware\Description\System\CentralProcessor\0')
    try:
        cpu = winreg.QueryValueEx(key, 'Identifier')[0]
        if cpu.startswith('x86'):
            arch = 32
        else:
            arch = 64
    except EnvironmentError:
        return -1

    winreg.CloseKey(key)

    key = winreg.OpenKey(reg, r'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
            0, winreg.KEY_READ | winreg.KEY_WRITE)

    try:
        env_path_str = winreg.QueryValueEx(key, 'Path')[0]
        env_path = env_path_str.split(os.pathsep)

        fix_for_msys_bin(env_path, arch)
        fix_for_mingw_bin(env_path, arch)

        env_path_str = os.pathsep.join(env_path)
        winreg.SetValueEx(key, 'Path', 0, winreg.REG_SZ, env_path_str) 
    except EnvironmentError:
        result = -1

    winreg.CloseKey(key)
    winreg.CloseKey(reg)
    return 0


if __name__ == '__main__':
    exit(fix_env_path())
