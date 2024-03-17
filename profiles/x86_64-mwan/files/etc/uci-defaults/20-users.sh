# #!/bin/sh

#
# Create a new user for SSH access
#
USERNAME="admin"
PASSWORD="ADMIN"
PUBKEY=""
USER_SHELL="zsh"

ENCRYPTED_PASSWORD=$(openssl passwd -5 $PASSWORD)

useradd -m -p "${ENCRYPTED_PASSWORD}" \
    --user-group -s "$(which ${USER_SHELL})" "${USERNAME}"

if [[ -n "${PUBKEY}" ]]; then
    USER_HOME=$(eval echo ~"${USERNAME}")
    mkdir -p "${USER_HOME}/.ssh"
    echo ${PUBKEY} >> "${USER_HOME}/.ssh/authorized_keys"
    chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}/.ssh"
    chmod 700 "${USER_HOME}/.ssh"
    chmod 600 "${USER_HOME}/.ssh/authorized_keys"

    echo "${USERNAME} ALL=(ALL:ALL) ALL" >> "/etc/sudoers.d/${USERNAME}"
fi

# End of creating new user

#
# Security Enhancements
#
if [[ -f '/etc/dropbear/authorized_keys' ]]; then
    chmod 700 /etc/dropbear
    chmod 600 /etc/dropbear/authorized_keys
fi

uci set dropbear.@dropbear[0].enable="1"
uci set dropbear.@dropbear[0].PasswordAuth="1"
uci set dropbear.@dropbear[0].RootLogin="1"
uci set dropbear.@dropbear[0].RootPasswordAuth="0"

uci commit dropbear

service dropbear restart

# End of Security Enhancements

exit 0
