{ pkgs, ... }:
let
	qemu_conf = pkgs.stdenv.mkDerivation {
		name = "qemu_conf";
		phases = [ "installPhase" ];

		cfg = pkgs.writeText "qemu.conf"
		''
			security_driver = "none"
			dynamic_ownership = 0
			remember_owner = 0
		'';
		installPhase = ''
			mkdir -p $out/opt/homebrew/etc/libvirt/
			cp $cfg $out/opt/homebrew/etc/libvirt/qemu.conf
		'';
	};
in {
	environment.systemPackages = with pkgs; [
		qemu_conf
	];

	homebrew = {
		enable = true;
		brews = [
			"qemu"
			"gcc"
			{
				name = "libvirt";
				restart_service = true;
			}
			"virt-manager"
		];
	};
}
