# vim: set ft=bash:
file="${HOME}/.ssh/id_ed25519"
if [ ! -f "${file}" ]; then
	echo "Generating a new key"
	ssh-keygen -t ed25519 -f "${file}" -N ''
	cat "${file}.pub" >> /etc/nixos/home/ssh/authorized_keys

	echo "Authing key to GitHub - may fail"
	gh auth refresh -h github.com -s admin:public_key
	gh ssh-key add -t ${HOSTNAME}-auto "${file}" || true
fi
cp /etc/nixos/home/ssh/authorized_keys "${HOME}/.ssh/authorized_keys"
