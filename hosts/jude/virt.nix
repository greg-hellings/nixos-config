{ pkgs, config, ... }:

{
	environment.systemPackages = with pkgs; [
		dmidecode
		guestfs-tools
		libguestfs
		OVMFFull
		packer
		virt-manager
		vmware-workstation
		vmfs-tools
		xorriso
	];

	# Give my user access to the libvirtd process
	users.users.greg.extraGroups = [ "libvirtd" ];

	virtualisation = {
		libvirtd = {
			enable = true;
			onBoot = "ignore";  # Do not auto-restart VMs on boot, unless they are marked autostart
			qemu.ovmf.enable = true;
		};

		virtualbox.host = {
			enable = true;
			enableExtensionPack = true;
		};

		waydroid.enable = false;
		lxd.enable = false;
	};

	users.extraGroups.vboxusers.members = [ "greg" ];

	boot.extraModprobeConfig = "options kvm_amd nested=1";

	systemd.services = {
		gitlab-runner = {
			conflicts = [ "libvirtd.service" ];
			preStart = builtins.concatStringsSep "\n" [
				"${pkgs.kmod}/bin/modprobe vboxnetflt vboxdrv"
				"${pkgs.kmod}/bin/modprobe vboxnetadp"
			];
			postStop = "${pkgs.kmod}/bin/rmmod vboxnetflt vboxnetadp vboxdrv";
			wantedBy = pkgs.lib.mkForce [];
			serviceConfig.User = "root";
		};
		libvirtd = {
			preStart = "${pkgs.kmod}/bin/modprobe kvm_amd";
			postStop = "${pkgs.kmod}/bin/rmmod kvm_amd kvm";
		};
	};

	age.secrets.runner-reg.file = ../../secrets/gitlab/myself-vbox-runner-reg.age;

	services.gitlab-runner = {
		enable = true;
		settings.concurrent = 5;
		services.vbox = {
			executor = "shell";
			limit = 5;
			registrationConfigFile = config.age.secrets.runner-reg.path;
			environmentVariables = {
				EFI_DIR = "${pkgs.OVMF.fd}/FV/";
			};
		};
	};
}
