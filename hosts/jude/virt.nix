{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		dmidecode
		guestfs-tools
		libguestfs
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
}
