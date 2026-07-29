{
  config,
  metadata,
  modulesPath,
  ...
}:
{
  # Then build nixosConfiguration.<host>.config.system.build.images.proxmox
  # SCP that to /var/lib/vz/dumps on the Proxmox host
  imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];
  greg = {
    home = true;
    nebula.enable = true;
  };
  networking = {
    defaultGateway = metadata.infra.gw;
    nameservers = [ metadata.infra.dns ];
    interfaces.ens18 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = metadata.hosts."${config.networking.hostName}".ip;
          prefixLength = 16;
        }
      ];
    };
  };
  virtualisation.diskSize = 20480; # Size in mebbibytes for the base disk image
  # Use these instead of the above to run an LXC image
  # The main reason I wouldn't use these is because Proxmox LXC does
  # not seem to be well supported by either Nebula VPN or Tailscale,
  # both of which I use for my mesh networking. If there isn't a need
  # for the service to run on those networks, then by all means go ahead
  # and use LXC!
  # imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
  # proxmoxLXC = {
  #   manageNetwork = false;
  #   privileged = true;
  # };
  # systemd.suppressedSystemUnits = [
  #   "dev-mqueue.mount"
  #   "sys-kernel-debug.mount"
  #   "sys-fs-fuse-connections.mount"
  # ];
  nix.settings = {
    sandbox = false;
  };
  services = {
    fstrim.enable = false; # Let Proxmox host handle fstrim
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        PermitEmptyPasswords = "yes";
      };
    };
  };
}
