# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, ... }:

let
  adblockUpdate = pkgs.writeShellApplication {
    name = "adblock-update";
    runtimeInputs = with pkgs; [
      curl
      gnused
      systemd
    ];
    text = ''
      curl -s https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | sed '1,33d' > /etc/adblock_hosts
      curl -s https://adaway.org/hosts.txt | sed '1,24d' | sed 's/127.0.0.1/0.0.0.0/' >> /etc/adblock_hosts

      # Custom domains that I need to preserve for some reason
      for f in "segment.com" "segment.io" "branch.io" "dev.visualwebsiteoptimizer.com"; do
       	sed -i -e "/''${f}/d" /etc/adblock_hosts  # Blocks Trelly content for house investors
      done

      systemctl restart dnsmasq
    '';
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./networking.nix
  ];

  greg = {
    home = true;
    gnome.enable = false;
    proxies = {
    };
  };

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      edk2-uefi-shell.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    create_ssl
    step-ca
  ];

  networking.hostName = "genesis"; # Define your hostname.

  systemd = {
    services.adblock-update = {
      after = [ "network-online.target" ];
      script = lib.getExe adblockUpdate;
      serviceConfig.Type = "oneshot";
    };
    timers.adblock-update = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "adblock-update.service";
      };
    };
  };
}
