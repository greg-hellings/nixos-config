{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		guestfs-tools
		libguestfs
		packer
		virt-manager
	];

	# Give my user access to the libvirtd process
	users.users.greg.extraGroups = [ "libvirtd" ];

	virtualisation = {
		libvirtd = {
			enable = true;
			onBoot = "ignore";  # Do not auto-restart VMs on boot, unless they are marked autostart
		};

		virtualbox.host.enable = true;

		waydroid.enable = true;
		lxd.enable = true;
	};

	users.extraGroups.vboxusers.members = [ "greg" ];

	boot.extraModprobeConfig = "options kvm_amd nested=1";
}
