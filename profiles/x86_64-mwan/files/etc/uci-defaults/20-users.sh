# #!/bin/sh

#
# Create a new user for SSH access
#

USERNAME="admin"
PASSWORD="ADMIN"
PUBKEY=""
USER_SHELL="zsh"
SUDO_GROUP="sudo"

ENCRYPTED_PASSWORD=$(openssl passwd -5 $PASSWORD)

groupadd -r "${SUDO_GROUP}"
useradd -m -p "${ENCRYPTED_PASSWORD}" \
    --user-group -G "${SUDO_GROUP}" \
    -s "$(which ${USER_SHELL})" "${USERNAME}"

if [[ -n "${PUBKEY}" ]]; then
    USER_HOME=$(eval echo ~"${USERNAME}")
    mkdir -p "${USER_HOME}"/.ssh
    echo ${PUBKEY} >> "${USER_HOME}/.ssh/authorized_keys"
    chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}/.ssh"
    chmod -R 600 "${USER_HOME}/.ssh"
fi

# End of creating new user

#
# Security Enhancements
#
uci set dropbear.@dropbear[0].enable="1"
uci set dropbear.@dropbear[0].PasswordAuth="1"
uci set dropbear.@dropbear[0].RootPasswordAuth="0"
uci set dropbear.@dropbear[0].RootLogin="0"

uci commit dropbear

service dropbear restart

# End of Security Enhancements

exit 0
