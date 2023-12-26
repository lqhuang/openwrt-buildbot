USER_NAME="admin"
USER_SSHPUB="SSH_PUBLIC_KEY"
USER_SHELL="/bin/zsh"
SUDO_USER="root"
SUDO_GROUP="sudo"

groupadd -r "${SUDO_GROUP}"
useradd -m -G "${SUDO_GROUP}" -s "${USER_SHELL}" "${USER_NAME}"
passwd -l "${SUDO_USER}"

cat << EOI > /etc/sudoers.d/00-custom
%${SUDO_GROUP} ALL=(ALL) ALL
EOI

USER_HOME="$(eval echo ~"${USER_NAME}")"
mkdir -p "${USER_HOME}"/.ssh
cat << EOI > "${USER_HOME}"/.ssh/authorized_keys
${USER_SSHPUB}
EOI

uci set dropbear.@dropbear[0].PasswordAuth="0"
uci set dropbear.@dropbear[0].RootPasswordAuth="0"
uci commit dropbear
/etc/init.d/dropbear restart

exit 0
