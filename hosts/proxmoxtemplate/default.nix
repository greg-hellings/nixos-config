# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
  ];

  greg = {
    home = true;
    tailscale = {
      enable = true;
      tags = [ "home" ];
    };
  };

  networking = {
    hostName = "proxmoxtemplate"; # Define your hostname.
    # defaultGateway = {
    #   address = " 10.42.1.2";
    #   interface = "enp6s18";
    # };
    # interfaces = {
    #   enp6s18 = {
    #     ipv4.addresses = [
    #       {
    #         address = "10.42.1.8";
    #         prefixLength = 16;
    #       }
    #     ];
    #   };
    # };
    nameservers = [ "10.42.1.5" ];
  };

  services.qemuGuest.enable = true;

  system.stateVersion = "24.11"; # Did you read the comment?

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.greg = {
    isNormalUser = true;
    description = "Greg Hellings";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ ];
  };
}
