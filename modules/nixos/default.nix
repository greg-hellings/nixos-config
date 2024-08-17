{ config, pkgs, inputs, lib, ... }:

let
	crowe = inputs.crowe.legacyPackages."${pkgs.stdenv.system}";
in {
	imports = [
		../baseline.nix
		./backup.nix
		./ceph.nix
		./container.nix
		./db.nix
		./gnome.nix
		./home.nix
		./kde.nix
		./kiwix-serve.nix
		./linode.nix
		./proxy.nix
		./router.nix
		./rpi4.nix
		./sway.nix
		./syncthing.nix
		./tailscale.nix
		./vmdev.nix
	];

	environment.sessionVariables.MOZ_ENABLE_WAYLAND = "0";
	environment.systemPackages = with pkgs; [
		coreutils-full
		efibootmgr
		psmisc
		lshw
		usbutils
	];

	system.stateVersion = "24.05";

	nix = {
		gc.dates = "weekly";
		settings.auto-optimise-store = true;
	};

	# I am a fan of network manager, myself
	networking = {
		search = [
			"thehellings.lan"
			"home"
		];
		networkmanager.enable = true;
	};

	programs.xonsh = {
		enable = true;
		package = (pkgs.xonsh.passthru.wrapper.override {
			extraPackages = (ps: with ps; [
				(ps.toPythonModule pkgs.pipenv)
				pyyaml
				requests
				ruamel-yaml
				xonsh-apipenv
				xonsh-direnv
				xontrib-vox
			]);
		});
	};

	# Enable the OpenSSH daemon for remote control
	services = {
		openssh = {
			enable = true;
			settings.X11Forwarding = true;
		};
	};

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.greg = {
		isNormalUser = true;
		createHome = true;
		extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
		shell = config.programs.xonsh.package;
		openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile ../../home/ssh/authorized_keys);
	};

	i18n.defaultLocale = "en_US.UTF-8";

	console = {
		font = "Lat2-Terminus16";
		keyMap = "us";
	};
}
