{
	pkgs,
	git,
	...
}:

pkgs.writeShellScriptBin "inject-nixos-config" ''
hostname="''${1}"
if [ -n "''${hostname}"]; then
	echo "You must provide a hostname";
	exit 1;
fi

mv /etc/nixos /etc/nixos.bk
cd /etc
${git}/bin/git clone http://github.com/greg-hellings/nixos-config nixos
mkdir -p "/etc/nixos/hosts/''${hostname}"

# Prepares everything for the flake usage
#cp /etc/nixos.bk/configuration.nix "/etc/nixos/hosts/''${hostname}/default.nix"
cat < EOF > "/etc/nixos/hosts/''${hostname}/default.nix
{ pkgs, config, ... }:

{
	imports = [ ./hardware-configuration.nix ];

	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
	};

	networking.hostName = "''${hostname}";
	greg = {
		home = true;
		tailscale.enable = true;
	};
}
EOF
cp /etc/nixos.bk/hardware-configuration.nix "/etc/nixos/hosts/''${hostname}/hardware-configuration.nix"

# Prepare home-manager portion for setup
mkdir -p "/etc/nixos/home/hosts/''${hostname}"
cat < EOF > "/etc/nixos/home/hosts/''${hostname}/default.nix"
{ pkgs, config, ... }:

{
}
EOF

# Prepares it for injecting the use case into the flake usage
cp /etc/nixos.bk/hardware-configuration.nix /etc/nixos
chown -R greg nixos

echo "Now you should be able to just run 'nixos-rebuild switch' to enable the flake functionality"
echo "After that and adding the entry to the flake, run 'nixos-rebuild boot --flake '.#''${hostname}' and reboot"
''
