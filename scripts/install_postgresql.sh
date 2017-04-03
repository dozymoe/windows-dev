#!/bin/sh

set -e

PG_VERSION=9.5

PRIV_USER=postgres
PRIV_NAME="Postgresql"

HOME_DIR=/var/lib/postgresql/${PG_VERSION}

#
# The privileged postgres user
#

# Some random password; this is only needed internally by cygrunsrv and
# is limited to 14 characters by Windows (lol)
tmp_pass="$(tr -dc 'a-zA-Z0-9' < /dev/urandom | dd count=14 bs=1 2>/dev/null)"

# Create user
add="$(if ! net user "${PRIV_USER}" >/dev/null; then echo "//add"; fi)"
if ! net user "${PRIV_USER}" "${tmp_pass}" ${add} //fullname:"${PRIV_NAME}" \
        //homedir:"$(cygpath -w ${HOME_DIR})" //yes; then
    echo "ERROR: Unable to create Windows user ${PRIV_USER}"
    exit 1
fi

# Infinite passwd expiry
passwd -e "${PRIV_USER}"

# set required privileges
for flag in SeServiceLogonRight; do
    if ! /mingw64/bin/editrights -a "${flag}" -u "${PRIV_USER}"; then
        echo "ERROR: Unable to give ${flag} rights to user ${PRIV_USER}"
	exit 1
    fi
done

#
# Add or update /etc/passwd entries
#

touch /etc/passwd
for u in "${PRIV_USER}"; do
    sed -i -e '/^'"${u}"':/d' /etc/passwd
    SED='/^'"${u}"':/s?^\(\([^:]*:\)\{5\}\).*?\1'"${HOME_DIR}"':/usr/bin/bash?p'
    mkpasswd -l -u "${u}" | sed -e 's/^[^:]*+//' | sed -ne "${SED}" \
            >> /etc/passwd
done


#
# Finally, register service with cygrunsrv and start it
#

/mingw64/bin/initdb -U "${PRIV_USER}" -D "${HOME_DIR}"
MSYS2_ARG_CONV_EXCL="*" icacls "$(cygpath -w ${HOME_DIR})" /inheritance:d
MSYS2_ARG_CONV_EXCL="*" icacls "$(cygpath -w ${HOME_DIR})" /remove "Authenticated Users"
MSYS2_ARG_CONV_EXCL="*" icacls "$(cygpath -w ${HOME_DIR})" /remove "Users"
MSYS2_ARG_CONV_EXCL="*" icacls "$(cygpath -w ${HOME_DIR})" /grant ${PRIV_USER}:\(OI\)\(CI\)\(F\)
MSYS2_ARG_CONV_EXCL="*" icacls "$(cygpath -w ${HOME_DIR})" /setowner ${PRIV_USER} /T
MSYS2_ARG_CONV_EXCL="*" icacls "$(cygpath -w ${HOME_DIR})" /remove "${USER}"

/mingw64/bin/pg_ctl register -N "postgresql" -U "${PRIV_USER}" -P "${tmp_pass}" -D "$(cygpath -w ${HOME_DIR})"

# The postgresql service should start automatically when Windows is rebooted. You can
# manually restart the service by running `net stop postgresql` + `net start postgresql`
if ! net start postgresql; then
    echo "ERROR: Unable to start postgresql service"
    exit 1
fi
