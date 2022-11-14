{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		libguestfs
		packer
		virt-manager
		vagrant
	];

	# Give my user access to the libvirtd process
	users.users.greg.extraGroups = [ "libvirtd" ];

	virtualisation = {
		libvirtd = {
			enable = true;
			onBoot = "ignore";  # Do not auto-restart VMs on boot, unless they are marked autostart
		};

		waydroid.enable = true;
		lxd.enable = true;  # Needed for waydroid

		virtualbox.host.enable = true;
	};

	users.extraGroups.vboxusers.members = [ "greg" ];

	boot.extraModprobeConfig = "options kvm_amd nested=1";
}
