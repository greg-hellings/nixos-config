{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		dmidecode
		guestfs-tools
		libguestfs
		OVMFFull
		ovftool
		packer
		virt-manager
		vmware-workstation
		vmfs-tools
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

		vmware.host.enable = false;

		waydroid.enable = false;
		lxd.enable = false;
	};

	users.extraGroups.vboxusers.members = [ "greg" ];

	boot.extraModprobeConfig = "options kvm_amd nested=1";

	systemd.services = {
		vbox = {
			conflicts = [ "libvirtd.service" ];
			serviceConfig = {
				Type = "oneshot";
				RemainAfterExit = "yes";
				ExecStart = [
					"rmmod kvm_amd"
					"rmmod kvm"
				];
				ExecStop = [
					"rmmod vboxnetflt"
					"rmmod vboxnetadp"
					"rmmod vboxdrv"
				];
			};
		};
	};
}
