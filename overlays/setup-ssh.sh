# vim: set ft=bash:
if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
	echo "Generating a new key"
	ssh-keygen -t rsa -b 8192 -f "${HOME}/.ssh/id_rsa" -N ''
	cat "${HOME}/.ssh/id_rsa.pub" >> /etc/nixos/home/ssh/authorized_keys

	echo "Authing key to GitHub - may fail"
	gh auth refresh -h github.com -s admin:public_key
	gh ssh-key add -t ${HOSTNAME}-auto ~/.ssh/id_rsa.pub || true
fi
cp /etc/nixos/home/ssh/authorized_keys "${HOME}/.ssh/authorized_keys"
